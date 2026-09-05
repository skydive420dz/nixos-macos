#!/usr/bin/env python3
"""Exercise cutover recovery in temporary directories; never invokes sudo or SSH."""

from contextlib import redirect_stdout
import io
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
from unittest.mock import patch

sys.dont_write_bytecode = True
import cutover


def scenario(root, host, partial_swap):
    old_system, new_system = root / 'old-system', root / 'new-system'
    old_system.mkdir()
    new_system.mkdir()
    profile = root / 'User'
    profile.mkdir()
    settings = [profile / 'settings.json', root / 'external-settings.json']
    prepared = root / 'prepared.json'
    prepared.write_text('{"release": "new"}\n')
    for path in settings:
        path.write_text('{"release": "old"}\n')
    (profile / 'linked-settings.json').symlink_to(settings[1])
    database = profile / 'state.vscdb'
    original_storage = {
        'unrelated': 'keep', 'extensions.autoUpdate': '["publisher.extension"]',
        '__$__targetStorageMarker': '{"unrelated": 0, "extensions.autoUpdate": 0}',
    }
    with sqlite3.connect(database) as connection:
        connection.execute('CREATE TABLE ItemTable (key TEXT UNIQUE, value TEXT)')
        connection.executemany('INSERT INTO ItemTable VALUES (?, ?)', original_storage.items())
    targets = []
    for index in range(2):
        live, staged = root / f'live-{index}', root / f'staged-{index}'
        for directory, version in ((live, 'old'), (staged, 'new')):
            directory.mkdir()
            (directory / 'version').write_text(version)
        targets.append({'live': str(live), 'staged': str(staged)})
    cli, agent_cli = root / 'cli', root / 'agent-cli'
    cli.write_text('old CLI')
    agent_cli.write_text('new CLI')
    config = {
        'system': str(new_system), 'previousSystem': str(old_system),
        'backup': str(root / 'backup'), 'files': {str(prepared): cutover.digest(prepared)},
        'profileDirs': [str(profile)], 'settings': [(str(prepared), str(p)) for p in settings],
        'originalSettings': {str(p): cutover.digest(p) for p in settings},
        'targets': targets, 'storage': [str(database)],
        'cliDestination': str(cli), 'agentCli': str(agent_cli),
    }
    state = {host: config}
    active = [old_system]
    calls = []
    fail_rollback = [False]
    original_resolve, original_rename = Path.resolve, Path.rename

    def resolve(path, *args, **kwargs):
        return active[0] if str(path) == '/run/current-system' else original_resolve(path, *args, **kwargs)

    def run(*command):
        command = tuple(map(str, command))
        calls.append(command)
        if command[1].endswith(('/activate', '/switch-to-configuration')):
            if command[1].startswith(str(old_system)) and fail_rollback[0]:
                fail_rollback[0] = False
                raise subprocess.CalledProcessError(1, command)
            active[0] = old_system if command[1].startswith(str(old_system)) else new_system

    def rename(path, destination):
        if partial_swap and path == Path(targets[1]['staged']) and Path(destination) == Path(targets[1]['live']):
            raise OSError('injected second extension swap failure')
        return original_rename(path, destination)

    def extension_check(_config, _target, directory):
        assert (Path(directory) / 'version').read_text() == 'new'

    with patch.object(Path, 'resolve', resolve), patch.object(Path, 'rename', rename), \
            patch.object(cutover, 'run', run), patch.object(cutover, 'extension_check', extension_check), \
            patch.object(cutover, 'require_closed'), patch.object(cutover, 'stop_remote_servers'):
        try:
            cutover.apply_host(state, host)
        except OSError:
            if not partial_swap:
                raise
        else:
            assert not partial_swap, 'The partial-swap fault was not exercised'
        backup = Path(config['backup'])
        assert (backup / 'backed-up').exists()
        if not partial_swap:
            assert active[0] == new_system
            before_resume = len(calls)
            cutover.apply_host(state, host)
            assert len(calls) == before_resume, 'A completed host must resume without activation'
            changed = [(backup / 'applied', 'wrong-generation'), (settings[0], '{"release": "other"}')]
            if host == 'msi':
                changed.append((cli, 'unexpected CLI'))
            for path, replacement in changed:
                original = path.read_bytes()
                path.write_text(replacement)
                try:
                    cutover.check(state, host)
                except ValueError:
                    pass
                else:
                    raise AssertionError(f'Resume accepted changed applied state: {path}')
                finally:
                    path.write_bytes(original)
            with sqlite3.connect(database) as connection:
                frozen = dict(connection.execute('SELECT key, value FROM ItemTable'))
            assert frozen['sync.enable.extensions'] == 'false'
            assert 'extensions.autoUpdate' not in frozen
            assert json.loads(frozen['__$__targetStorageMarker']) == {'unrelated': 0, 'sync.enable.extensions': 1}
            (profile / 'new-user-note').write_text('preserve this rejected edit')
            settings[1].write_text('{"release": "new", "userEdit": true}\n')
            fail_rollback[0] = True
            try:
                cutover.rollback_host(state, host)
            except subprocess.CalledProcessError:
                pass
            else:
                raise AssertionError('The rollback activation fault was not exercised')
        else:
            assert (Path(targets[0]['live']) / 'version').read_text() == 'new'
            assert (Path(targets[1]['live']) / 'version').read_text() == 'old'
        cutover.rollback_host(state, host)
        assert active[0] == old_system
        assert not backup.exists()
        restored, = root.glob('backup-restored-*')
        for path in settings:
            assert json.loads(path.read_text()) == {'release': 'old'}
        assert (profile / 'linked-settings.json').is_symlink()
        with sqlite3.connect(database) as connection:
            assert dict(connection.execute('SELECT key, value FROM ItemTable')) == original_storage
        for target in targets:
            assert (Path(target['live']) / 'version').read_text() == 'old'
            assert (Path(target['staged']) / 'version').read_text() == 'new'
        if host == 'msi':
            assert cli.read_text() == 'old CLI'
        if not partial_swap:
            assert (restored / 'rejected-profile-0' / 'new-user-note').read_text() == 'preserve this rejected edit'
            assert json.loads((restored / 'rejected-settings-1.json').read_text())['userEdit'] is True
            if host == 'msi':
                assert (restored / 'rejected-cli').read_text() == 'new CLI'


def main():
    with tempfile.TemporaryDirectory(prefix='vscode-cutover-check-') as temporary:
        for host in ('mac', 'msi'):
            for partial_swap in (False, True):
                root = Path(temporary) / f'{host}-{partial_swap}'
                root.mkdir()
                with redirect_stdout(io.StringIO()):
                    scenario(root, host, partial_swap)
    print('Cutover checks passed: both hosts resume, restore settings/profiles/extensions, and recover from interrupted swaps and rollback activation.')


if __name__ == '__main__':
    main()
