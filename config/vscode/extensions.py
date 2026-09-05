#!/usr/bin/env python3
"""Stage, repair, or check a frozen extension set with VS Code's CLI (Python 3.9+)."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import zipfile


PLATFORMS = {"mac-ui": "darwin-arm64", "msi-ui": "linux-x64", "msi-ssh": "linux-x64"}


def selected(manifest, target):
    result = {}
    for extension in manifest["extensions"]:
        if target not in extension["targets"]:
            continue
        identity = extension["id"]
        if not re.fullmatch(r"[a-z0-9-]+\.[a-z0-9-]+", identity) or identity in result:
            raise ValueError(f"Invalid or duplicate extension ID: {identity}")
        if extension["channel"] not in ("stable", "prerelease"):
            raise ValueError(f"Invalid release channel: {identity}")
        platform = PLATFORMS[target]
        if platform not in extension["artifacts"]:
            platform = "universal"
        artifact = extension["artifacts"][platform]
        if not re.fullmatch(r"[0-9a-f]{64}", artifact["sha256"]):
            raise ValueError(f"Invalid SHA256: {identity}")
        if not artifact["url"].startswith("https://"):
            raise ValueError(f"HTTPS artifact URL required: {identity}")
        repair = extension.get("repair")
        if repair:
            path = Path(repair["path"])
            if path.is_absolute() or ".." in path.parts or not path.parts or path.as_posix() != repair["path"] or path.name in ("package.json", "extensions.json"):
                raise ValueError(f"Unsafe repair path: {path}")
            if not repair["before"] or repair["before"] == repair["after"]:
                raise ValueError(f"Invalid repair replacement: {identity}")
            for key in ("before_sha256", "after_sha256"):
                if not re.fullmatch(r"[0-9a-f]{64}", repair[key]):
                    raise ValueError(f"Invalid repair SHA256: {identity}")
        generated = extension.get("generatedFiles", [])
        if not isinstance(generated, list) or len(set(generated)) != len(generated):
            raise ValueError(f"Invalid generated file declarations: {identity}")
        for relative in generated:
            path = Path(relative)
            if path.is_absolute() or ".." in path.parts or path.as_posix() != relative or path.suffix != ".json" or path.name in ("package.json", "extensions.json") or (repair and relative == repair["path"]):
                raise ValueError(f"Unsafe generated file declaration: {relative}")
        result[identity] = (extension, platform, artifact)
    if not result:
        raise ValueError(f"No extensions selected for {target}")
    return result


def check(expected, directory, cache=None, allow_original=False):
    registry = json.loads((directory / "extensions.json").read_text())
    actual = {}
    for entry in registry:
        identity = entry["identifier"]["id"].lower()
        if identity in actual:
            raise ValueError(f"Duplicate installed extension: {identity}")
        actual[identity] = entry
    errors = []
    for identity in sorted(expected.keys() - actual.keys()):
        errors.append(f"missing {identity}")
    for identity in sorted(actual.keys() - expected.keys()):
        errors.append(f"extra {identity}")
    for identity in sorted(expected.keys() & actual.keys()):
        extension, platform, artifact = expected[identity]
        entry = actual[identity]
        metadata = entry.get("metadata", {})
        observed_platform = metadata.get("targetPlatform") or "undefined"
        if observed_platform == "undefined":
            observed_platform = "universal"
        wanted = (extension["version"], extension["channel"] == "prerelease", platform)
        observed = (entry["version"], bool(metadata.get("isPreReleaseVersion")), observed_platform)
        if observed != wanted:
            errors.append(f"{identity}: expected {wanted}, found {observed}")
        if bool(metadata.get("preRelease", wanted[1])) != wanted[1]:
            errors.append(f"{identity}: update channel differs from release")
        if metadata.get("forceAutoUpdate"):
            errors.append(f"{identity}: forced auto-update enabled")
        if not metadata.get("pinned") or not metadata.get("isMachineScoped"):
            errors.append(f"{identity}: extension must be pinned and excluded from Settings Sync")
        location = directory / (entry.get("relativeLocation") or entry["location"]["path"])
        if not location.resolve().is_relative_to(directory.resolve()):
            errors.append(f"{identity}: extension files are outside {directory}")
            continue
        package = json.loads((location / "package.json").read_text())
        if (f"{package['publisher']}.{package['name']}".lower(), package["version"]) != (identity, wanted[0]):
            errors.append(f"{identity}: package.json disagrees with release")
        repair = extension.get("repair")
        if cache:
            verify_payload(cache / (artifact["sha256"] + ".vsix"), location, artifact["sha256"], repair, allow_original, extension.get("generatedFiles", []))
        elif repair:
            path = location / repair["path"]
            if not path.resolve().is_relative_to(location.resolve()) or path.is_symlink():
                raise ValueError(f"Unsafe repair file: {path}")
            accepted = {repair["after_sha256"]}
            if allow_original:
                accepted.add(repair["before_sha256"])
            if sha256(path) not in accepted:
                errors.append(f"{identity}: declared repair is missing or altered")
        if not cache:
            for relative in extension.get("generatedFiles", []):
                verify_generated_json(location / relative, location)
    if errors:
        raise ValueError("\n".join(errors))
    print(f"Verified {len(expected)} exact extension versions, channels, and platforms.")


def digest_stream(source):
    digest = hashlib.sha256()
    for chunk in iter(lambda: source.read(1024 * 1024), b""):
        digest.update(chunk)
    return digest.hexdigest()


def sha256(path):
    with path.open("rb") as source:
        return digest_stream(source)


def repaired_payload(original, repair):
    before, after = repair["before"].encode(), repair["after"].encode()
    if hashlib.sha256(original).hexdigest() != repair["before_sha256"] or original.count(before) != 1:
        raise ValueError("Repair does not match the exact upstream payload")
    result = original.replace(before, after)
    if hashlib.sha256(result).hexdigest() != repair["after_sha256"]:
        raise ValueError("Repair output SHA256 mismatch")
    return result


def verify_generated_json(path, directory):
    if not path.resolve().is_relative_to(directory.resolve()) or path.is_symlink() or not path.is_file():
        raise ValueError(f"Unsafe generated JSON file: {path}")
    if not isinstance(json.loads(path.read_text()), dict):
        raise ValueError(f"Generated JSON must be an object: {path}")


def verify_payload(vsix, directory, expected_hash, repair=None, allow_original=False, generated_files=()):
    if sha256(vsix) != expected_hash:
        raise ValueError(f"Cached artifact SHA256 mismatch: {vsix}")
    with zipfile.ZipFile(vsix) as archive:
        repair_found = False
        generated_found = set()
        for member in archive.infolist():
            if not member.filename.startswith("extension/") or member.is_dir():
                continue
            relative = member.filename[len("extension/"):]
            path = directory / relative
            if not path.resolve().is_relative_to(directory.resolve()):
                raise ValueError(f"Unsafe artifact path: {member.filename}")
            if repair and relative == repair["path"]:
                repair_found = True
                if path.is_symlink():
                    raise ValueError(f"Unsafe repair file: {path}")
                original = archive.read(member)
                wanted = repaired_payload(original, repair)
                actual = path.read_bytes()
                matches = actual == wanted or (allow_original and actual == original)
            elif relative in generated_files:
                # vscode-icons persists its native generated theme data inside its installation.
                verify_generated_json(path, directory)
                generated_found.add(relative)
                matches = True
            elif relative == "package.json":
                wanted = json.loads(archive.read(member))
                actual = json.loads(path.read_text())
                # VS Code adds installation metadata to the publisher's manifest.
                wanted.pop("__metadata", None)
                actual.pop("__metadata", None)
                matches = wanted == actual
            else:
                with archive.open(member) as source:
                    matches = digest_stream(source) == sha256(path)
            if not matches:
                raise ValueError(f"Installed payload differs from verified VSIX: {path}")
        if repair and not repair_found:
            raise ValueError("Repair path is absent from the upstream VSIX")
        if generated_found != set(generated_files):
            raise ValueError("Generated file path is absent from the upstream VSIX")


def repair_payloads(expected, directory, cache):
    # Verify every extension before changing any; existing MSI payloads stay authoritative.
    check(expected, directory, cache, allow_original=True)
    registry = json.loads((directory / "extensions.json").read_text())
    for entry in registry:
        extension = expected[entry["identifier"]["id"].lower()][0]
        repair = extension.get("repair")
        if not repair:
            continue
        path = directory / (entry.get("relativeLocation") or entry["location"]["path"]) / repair["path"]
        original = path.read_bytes()
        if hashlib.sha256(original).hexdigest() == repair["after_sha256"]:
            continue
        result = repaired_payload(original, repair)
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as output:
                temporary = Path(output.name)
                os.fchmod(output.fileno(), path.stat().st_mode & 0o777)
                output.write(result)
            temporary.replace(path)
        finally:
            if temporary:
                temporary.unlink(missing_ok=True)


def fetch(artifact, cache):
    destination = cache / (artifact["sha256"] + ".vsix")
    if not destination.exists():
        temporary = destination.with_suffix(".partial")
        try:
            with urllib.request.urlopen(artifact["url"], timeout=120) as response, temporary.open("wb") as output:
                shutil.copyfileobj(response, output)
            if sha256(temporary) != artifact["sha256"]:
                raise ValueError(f"Artifact SHA256 mismatch: {artifact['url']}")
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)
    if sha256(destination) != artifact["sha256"]:
        raise ValueError(f"Cached artifact SHA256 mismatch: {destination}")
    return destination


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("stage", "repair", "check"))
    parser.add_argument("--manifest", type=Path, default=Path(__file__).with_name("release.json"))
    parser.add_argument("--target", choices=PLATFORMS, required=True)
    parser.add_argument("--code", required=True)
    parser.add_argument("--extensions-dir", type=Path, required=True)
    parser.add_argument("--user-data-dir", type=Path, required=True, help="For msi-ssh, use the code-server CLI and a directory named data")
    parser.add_argument("--cache-dir", type=Path)
    args = parser.parse_args(argv)
    manifest = json.loads(args.manifest.read_text())
    expected = selected(manifest, args.target)
    directory = args.extensions_dir.expanduser().absolute()
    user_data = args.user_data_dir.expanduser().absolute()
    if args.target == "msi-ssh" and user_data.name != "data":
        raise ValueError("code-server requires --user-data-dir to end in /data")
    # Never inherit an SSH window's CLI routing into an unrelated live profile.
    environment = {key: value for key, value in os.environ.items() if key not in ("VSCODE_IPC_HOOK_CLI", "VSCODE_CLI_AUTHORITY")}
    # code-server creates its data directories even for --version.
    with tempfile.TemporaryDirectory(prefix="vscode-version-") as temporary:
        version_args = ["--server-data-dir", temporary] if args.target == "msi-ssh" else []
        version = subprocess.run([args.code, *version_args, "--version"], check=True, text=True, capture_output=True, env=environment).stdout.splitlines()
    if version[:2] != [manifest["app"]["version"], manifest["app"]["commit"]]:
        raise ValueError(f"VS Code version/commit differs from release: {version}")
    if args.command in ("stage", "repair") and not args.cache_dir:
        parser.error(f"{args.command} requires --cache-dir")
    if args.command == "stage":
        cache = args.cache_dir.expanduser().absolute()
        for path in (directory, user_data):
            if path.exists() or path.is_symlink():
                raise ValueError(f"Staging requires a new directory: {path}")
            if cache.resolve().is_relative_to(path.resolve()):
                raise ValueError("Artifact cache must be outside staging directories")
        if directory.resolve().is_relative_to(user_data.resolve()) or user_data.resolve().is_relative_to(directory.resolve()):
            raise ValueError("Extension and user-data staging directories must be separate")
        cache.mkdir(parents=True, exist_ok=True)
        artifacts = [(extension, fetch(artifact, cache)) for extension, _, artifact in expected.values()]
        directory.mkdir(parents=True)
        (user_data / "User").mkdir(parents=True)
        settings = json.dumps({"extensions.autoUpdate": "off", "extensions.autoCheckUpdates": False, "update.mode": "none"}) + "\n"
        (user_data / "User/settings.json").write_text(settings)
        if args.target == "msi-ssh":
            (user_data / "Machine").mkdir()
            (user_data / "Machine/settings.json").write_text(settings)
        data_args = ["--server-data-dir", str(user_data.parent)] if args.target == "msi-ssh" else ["--user-data-dir", str(user_data)]
        for extension, _ in artifacts:
            # VSIX installation loses platform/channel metadata; exact gallery installs retain it.
            command = [args.code, "--extensions-dir", str(directory), *data_args, "--install-extension", f"{extension['id']}@{extension['version']}", "--force", "--do-not-sync", "--do-not-include-pack-dependencies"]
            if extension["channel"] == "prerelease":
                command.append("--pre-release")
            subprocess.run(command, check=True, env=environment)
    if args.command in ("stage", "repair"):
        repair_payloads(expected, directory, args.cache_dir.expanduser().absolute())
    check(expected, directory, args.cache_dir.expanduser().absolute() if args.cache_dir else None)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
