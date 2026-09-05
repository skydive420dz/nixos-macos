#!/usr/bin/env python3
"""Apply a prepared, paired release from a terminal outside VS Code (Python 3.9+)."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import signal
import sqlite3
import subprocess
import sys
import time


def run(*command):
    subprocess.run([str(arg) for arg in command], check=True)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def check(state, host):
    config = state[host]
    backup = Path(config['backup'])
    applied = (backup / 'applied').exists()
    if applied and (backup / 'applied').read_text().strip() != config['system']:
        raise ValueError('The completed-release marker names a different generation.')
    expected_system = config['system'] if applied else config['previousSystem']
    if str(Path('/run/current-system').resolve()) != expected_system:
        raise ValueError('The active system changed after preparation; prepare this release again.')
    for path, expected in config['files'].items():
        if digest(path) != expected:
            raise ValueError(f'Prepared file changed: {path}')
    if not Path(config['system']).is_dir():
        raise ValueError('Prepared Nix generation is missing.')
    if backup.exists() and not applied:
        raise ValueError(f'An incomplete attempt exists at {backup}; use --rollback before retrying.')
    if not os.access(backup.parent, os.W_OK):
        raise ValueError(f'Rollback directory parent is not writable: {backup.parent}')
    for target in config['targets']:
        extension_check(config, target, target['live'] if applied else target['staged'])
        live = Path(target['live'])
        if live.is_symlink() or not live.is_dir() or live.stat().st_uid != os.getuid():
            raise ValueError(f'Expected a user-owned extension directory: {live}')
        if not applied and len({live.stat().st_dev, backup.parent.stat().st_dev,
                                Path(target['staged']).stat().st_dev}) != 1:
            raise ValueError('Extension staging, live, and rollback directories must share a filesystem.')
    if not applied:
        for path in config['profileDirs']:
            source = Path(path)
            if source.exists() and source.stat().st_dev != backup.parent.stat().st_dev:
                raise ValueError(f'Profile and rollback directories must share a filesystem: {source}')
        for path, expected in config['originalSettings'].items():
            if digest(path) != expected or not os.access(path, os.W_OK):
                raise ValueError(f'Live settings changed or are not writable: {path}')
        for path in config.get('permissionRepairs', []):
            path = Path(path)
            if path.exists() and path.stat().st_uid != os.getuid():
                raise ValueError(f'Unexpected permission-repair owner: {path}')
        for path in config['storage']:
            if Path(path).exists() and not os.access(Path(path).parent, os.W_OK):
                raise ValueError(f'Storage directory is not writable: {path}')
    else:
        for prepared, destination in config['settings']:
            if json.loads(Path(prepared).read_text()) != json.loads(Path(destination).read_text()):
                raise ValueError(f'Applied settings differ from the prepared release: {destination}')
        if host == 'msi' and digest(config['cliDestination']) != digest(config['agentCli']):
            raise ValueError('The applied Agent Host CLI changed; do not resume this release.')
    print(f'{host}: prepared generation and extension sets verified.', flush=True)
    return applied


def extension_check(config, target, directory):
    run(sys.executable, Path(__file__).with_name('extensions.py'), 'check',
        '--manifest', Path(__file__).with_name('release.json'),
        '--target', target['target'], '--code', target['code'],
        '--extensions-dir', directory, '--user-data-dir', target['data'],
        '--cache-dir', config['cache'])


def require_closed(host):
    if host == 'mac':
        commands = subprocess.check_output(['ps', '-axo', 'comm='], text=True)
        running = any(line.endswith('Visual Studio Code.app/Contents/MacOS/Code')
                      or ('Visual Studio Code.app/Contents/' in line and '/Code Helper' in line)
                      for line in commands.splitlines())
    else:
        running = False
        for process in Path('/proc').iterdir():
            try:
                if process.name.isdigit() and process.stat().st_uid == os.getuid():
                    executable = os.readlink(process / 'exe')
                    running |= '/lib/vscode/' in executable and executable.endswith('/code')
            except (FileNotFoundError, ProcessLookupError, PermissionError):
                pass
    if running:
        raise ValueError(f'Close the {host} VS Code frontend, then rerun from an external terminal.')


def stop_remote_servers():
    processes = {}
    roots = set()
    prefix = str(Path.home() / '.vscode-server') + '/'
    for process in Path('/proc').iterdir():
        if not process.name.isdigit():
            continue
        try:
            if process.stat().st_uid != os.getuid():
                continue
            args = (process / 'cmdline').read_bytes().split(b'\0')
            args = [arg.decode(errors='replace') for arg in args if arg]
            parent = int((process / 'stat').read_text().rsplit(')', 1)[1].split()[1])
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            continue
        pid = int(process.name)
        processes[pid] = parent
        if args and args[0].startswith(prefix) and (
                'agent' in args or 'command-shell' in args
                or any(arg.endswith('/out/server-main.js') for arg in args)):
            roots.add(pid)
    selected = set(roots)
    while True:
        children = {pid for pid, parent in processes.items() if parent in selected}
        if children <= selected:
            break
        selected |= children
    if os.getpid() in selected:
        raise ValueError('Run the cutover through independent SSH, outside the remote VS Code terminal.')
    print(f'Stopping {len(selected)} processes belonging to the old SSH servers and Agent Host.', flush=True)
    for pid in selected:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    deadline = time.monotonic() + 20
    while time.monotonic() < deadline:
        alive = [pid for pid in selected if Path(f'/proc/{pid}').exists()]
        if not alive:
            return
        time.sleep(0.25)
    raise ValueError(f'Old server processes did not stop cleanly: {alive}; no forced termination attempted.')


def freeze_storage(path):
    path = Path(path)
    if not path.exists():
        return
    with sqlite3.connect(str(path)) as database:
        database.execute("INSERT OR REPLACE INTO ItemTable(key,value) VALUES (?,?)",
                         ('sync.enable.extensions', 'false'))
        database.execute("DELETE FROM ItemTable WHERE key = ?", ('extensions.autoUpdate',))
        # The native storage service records machine-scoped keys in this marker.
        row = database.execute("SELECT value FROM ItemTable WHERE key = ?", ('__$__targetStorageMarker',)).fetchone()
        marker = json.loads(row[0]) if row else {}
        marker['sync.enable.extensions'] = 1
        marker.pop('extensions.autoUpdate', None)
        database.execute("INSERT OR REPLACE INTO ItemTable(key,value) VALUES (?,?)",
                         ('__$__targetStorageMarker', json.dumps(marker)))


def apply_host(state, host):
    config = state[host]
    if check(state, host):
        print(f'{host}: already applied and verified; continuing the paired release.', flush=True)
        return
    require_closed(host)
    run('sudo', '-v')
    if host == 'msi':
        stop_remote_servers()
    backup = Path(config['backup'])
    backup.mkdir(parents=True, exist_ok=False)
    backup.chmod(0o700)
    (backup / 'state.json').write_text(json.dumps(state, indent=2) + '\n')
    for index, path in enumerate(config['profileDirs']):
        source = Path(path)
        if source.exists():
            shutil.copytree(source, backup / f'profile-{index}', symlinks=True)
    for index, (_, destination) in enumerate(config['settings']):
        shutil.copy2(destination, backup / f'settings-{index}.json')
    if host == 'msi' and Path(config['cliDestination']).exists():
        shutil.copy2(config['cliDestination'], backup / 'previous-cli')
    (backup / 'backed-up').touch()
    for path in config.get('permissionRepairs', []):
        path = Path(path)
        if path.exists():
            path.chmod(path.stat().st_mode | 0o200)
    for prepared, destination in config['settings']:
        Path(destination).write_bytes(Path(prepared).read_bytes())
    for path in config['storage']:
        freeze_storage(path)
    for index, target in enumerate(config['targets']):
        live = Path(target['live'])
        old = backup / f'extensions-{index}'
        live.rename(old)
        try:
            Path(target['staged']).rename(live)
        except OSError:
            old.rename(live)
            raise
    if host == 'msi':
        cli = Path(config['cliDestination'])
        temporary = cli.with_suffix('.release-tmp')
        shutil.copyfile(config['agentCli'], temporary)
        temporary.chmod(0o755)
        temporary.replace(cli)
    run('sudo', 'nix-env', '-p', '/nix/var/nix/profiles/system', '--set', config['system'])
    if host == 'mac':
        run('sudo', Path(config['system']) / 'activate')
    else:
        run('sudo', Path(config['system']) / 'bin/switch-to-configuration', 'switch')
    for target in config['targets']:
        extension_check(config, target, target['live'])
    if host == 'msi' and digest(config['cliDestination']) != digest(config['agentCli']):
        raise ValueError('Installed Agent Host CLI differs from the prepared package.')
    (backup / 'applied').write_text(config['system'] + '\n')
    print(f'{host}: applied. Rollback data: {backup}', flush=True)


def rollback_host(state, host):
    config = state[host]
    backup = Path(config['backup'])
    if not backup.exists():
        print(f'{host}: no cutover attempt to restore.')
        return
    if str(Path('/run/current-system').resolve()) not in (config['previousSystem'], config['system']):
        raise ValueError('An unrelated generation is active; refuse rollback from an obsolete release file.')
    require_closed(host)
    run('sudo', '-v')
    if host == 'msi':
        stop_remote_servers()
    if not (backup / 'backed-up').exists():
        backup.rename(backup.with_name(backup.name + f'-incomplete-{time.time_ns()}'))
        print(f'{host}: backup failed before mutable changes; preparation can be retried.')
        return
    for index, target in enumerate(config['targets']):
        old = backup / f'extensions-{index}'
        if old.exists():
            live = Path(target['live'])
            if live.exists():
                # Preserve the rejected release so it can be checked and retried.
                live.rename(target['staged'])
            old.rename(live)
    for index, path in enumerate(config['profileDirs']):
        old = backup / f'profile-{index}'
        if old.exists():
            live = Path(path)
            if live.exists():
                live.rename(backup / f'rejected-profile-{index}')
            old.rename(live)
    for index, (_, destination) in enumerate(config['settings']):
        rejected = backup / f'rejected-settings-{index}.json'
        if not rejected.exists():
            shutil.copy2(destination, rejected)
        Path(destination).write_bytes((backup / f'settings-{index}.json').read_bytes())
    if host == 'msi':
        cli = Path(config['cliDestination'])
        if cli.exists() and not (backup / 'rejected-cli').exists():
            cli.rename(backup / 'rejected-cli')
        if (backup / 'previous-cli').exists():
            shutil.copy2(backup / 'previous-cli', cli)
    run('sudo', 'nix-env', '-p', '/nix/var/nix/profiles/system', '--set', config['previousSystem'])
    old = Path(config['previousSystem'])
    run('sudo', old / ('activate' if host == 'mac' else 'bin/switch-to-configuration'),
        *([] if host == 'mac' else ['switch']))
    backup.rename(backup.with_name(backup.name + f'-restored-{time.time_ns()}'))
    print(f'{host}: previous release restored; rejected state retained.', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--state', type=Path, required=True)
    parser.add_argument('--host', choices=('mac', 'msi'), default='mac')
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--apply', action='store_true')
    action.add_argument('--rollback', action='store_true')
    args = parser.parse_args()
    state = json.loads(args.state.read_text())
    if not args.rollback:
        check(state, args.host)
    if args.host == 'mac':
        remote = [state['msi']['python'], state['msi']['script'], '--state',
                  state['msi']['state'], '--host', 'msi']
        if not args.rollback:
            run('ssh', '-o', 'BatchMode=yes', 'msi', shlex.join(remote))
        if args.apply or args.rollback:
            require_closed('mac')
            run('sudo', '-v')
            run('ssh', '-t', 'msi', shlex.join(remote + ['--rollback' if args.rollback else '--apply']))
    if args.rollback:
        rollback_host(state, args.host)
        return
    if args.apply:
        apply_host(state, args.host)
        if args.host == 'mac':
            run('/etc/profiles/per-user/skydive420dz/bin/code-msi',
                '/home/skydive420dz/Projects/nixos-macos')
            print('Both installations applied. Verify the SSH window, Agent Host, and Astra before accepting the release.')
    else:
        print('Preflight only; no live state changed.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(f'Cutover stopped: {error}\nA paired release may be partial. Rerun a completed host safely, or replace --apply with --rollback to restore both hosts.')
