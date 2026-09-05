#!/usr/bin/env python3
"""Run directly with Python; no VS Code installation or network required."""

import contextlib
import io
import hashlib
import json
from pathlib import Path
import tempfile
import zipfile

from extensions import check, fetch, repair_payloads, selected, sha256, verify_payload


manifest = json.loads(Path(__file__).with_name("release.json").read_text())
expected = selected(manifest, "msi-ssh")
assert "openai.chatgpt" in expected and "vscodevim.vim" not in expected
# Registry-only fixtures; the exact repair contract is exercised separately below.
expected = {identity: ({key: value for key, value in extension.items() if key not in ("repair", "generatedFiles")}, platform, artifact) for identity, (extension, platform, artifact) in expected.items()}
with tempfile.TemporaryDirectory() as temporary:
    directory = Path(temporary)
    registry = []
    for identity, (extension, platform, _) in expected.items():
        path = directory / identity
        path.mkdir()
        publisher, name = identity.split(".", 1)
        (path / "package.json").write_text(json.dumps({"publisher": publisher, "name": name, "version": extension["version"]}))
        registry.append({"identifier": {"id": identity}, "version": extension["version"], "relativeLocation": identity, "location": {"path": str(path)}, "metadata": {"targetPlatform": "undefined" if platform == "universal" else platform, "isPreReleaseVersion": extension["channel"] == "prerelease", "pinned": True, "isMachineScoped": True}})
    index = directory / "extensions.json"
    index.write_text(json.dumps(registry))
    with contextlib.redirect_stdout(io.StringIO()):
        check(expected, directory)
    for mutate in (lambda: registry.pop(), lambda: registry[0].update(version="0.0.0"), lambda: registry[0]["metadata"].update(isPreReleaseVersion=True), lambda: registry[0]["metadata"].update(targetPlatform="darwin-arm64")):
        original = json.loads(json.dumps(registry))
        mutate()
        index.write_text(json.dumps(registry))
        try:
            check(expected, directory)
        except ValueError:
            pass
        else:
            raise AssertionError("Incorrect extension set was accepted")
        registry = original
    artifact = {"sha256": "0" * 64, "url": "https://example.invalid/unused"}
    (directory / (artifact["sha256"] + ".vsix")).write_bytes(b"corrupt")
    try:
        fetch(artifact, directory)
    except ValueError:
        pass
    else:
        raise AssertionError("Corrupt cached VSIX was accepted")
    vsix = directory / "payload.vsix"
    with zipfile.ZipFile(vsix, "w") as archive:
        archive.writestr("extension/code.js", "original")
    (directory / "code.js").write_text("original")
    verify_payload(vsix, directory, sha256(vsix))
    (directory / "code.js").write_text("modified")
    try:
        verify_payload(vsix, directory, sha256(vsix))
    except ValueError:
        pass
    else:
        raise AssertionError("Modified installed code was accepted")
with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    directory, cache = root / "extensions", root / "cache"
    directory.mkdir()
    cache.mkdir()
    location = directory / "example.test"
    location.mkdir()
    (location / "package.json").write_text(json.dumps({"publisher": "example", "name": "test", "version": "1.0.0"}))
    (location / "code.js").write_text("original")
    (location / "other.js").write_text("unchanged")
    (location / "theme.json").write_text('{"original":true}')
    vsix = root / "payload.vsix"
    with zipfile.ZipFile(vsix, "w") as archive:
        for path in location.iterdir():
            archive.write(path, "extension/" + path.name)
    artifact_hash = sha256(vsix)
    vsix = vsix.rename(cache / (artifact_hash + ".vsix"))
    repair = {"path": "code.js", "before": "original", "after": "fixed", "before_sha256": hashlib.sha256(b"original").hexdigest(), "after_sha256": hashlib.sha256(b"fixed").hexdigest()}
    extension = {"id": "example.test", "version": "1.0.0", "channel": "stable", "targets": ["msi-ssh"], "artifacts": {"universal": {"sha256": artifact_hash, "url": "https://example.invalid/unused"}}, "repair": repair, "generatedFiles": ["theme.json"]}
    expected = selected({"extensions": [extension]}, "msi-ssh")
    registry = [{"identifier": {"id": "example.test"}, "version": "1.0.0", "relativeLocation": "example.test", "metadata": {"pinned": True, "isMachineScoped": True}}]
    index = directory / "extensions.json"
    index.write_text(json.dumps(registry))

    def must_reject(operation):
        try:
            operation()
        except ValueError:
            return
        raise AssertionError("Unsafe or unrepaired payload was accepted")

    must_reject(lambda: check(expected, directory, cache))
    must_reject(lambda: check(expected, directory))
    registry[0]["version"] = "0.0.0"
    index.write_text(json.dumps(registry))
    must_reject(lambda: repair_payloads(expected, directory, cache))
    registry[0]["version"] = "1.0.0"
    index.write_text(json.dumps(registry))
    (location / "other.js").write_text("unrelated modification")
    must_reject(lambda: repair_payloads(expected, directory, cache))
    assert (location / "code.js").read_text() == "original"
    (location / "other.js").write_text("unchanged")
    for field, wrong in (("before_sha256", "0" * 64), ("after_sha256", "0" * 64), ("before", "missing")):
        original = repair[field]
        repair[field] = wrong
        must_reject(lambda: repair_payloads(expected, directory, cache))
        repair[field] = original
    for unsafe in ("../outside.js", "/tmp/outside.js", "./code.js", "package.json"):
        repair["path"] = unsafe
        must_reject(lambda: selected({"extensions": [extension]}, "msi-ssh"))
    repair["path"] = "code.js"
    with contextlib.redirect_stdout(io.StringIO()):
        repair_payloads(expected, directory, cache)
        check(expected, directory, cache)
        check(expected, directory)
        modified = (location / "code.js").stat().st_mtime_ns
        repair_payloads(expected, directory, cache)
        assert (location / "code.js").stat().st_mtime_ns == modified
    (location / "theme.json").write_text('{"generated":true}')
    with contextlib.redirect_stdout(io.StringIO()):
        check(expected, directory, cache)
        check(expected, directory)
    for invalid in ("not JSON", "[]", "null"):
        (location / "theme.json").write_text(invalid)
        must_reject(lambda: check(expected, directory, cache))
    for unsafe in ("../theme.json", "/tmp/theme.json", "./theme.json", "code.js", "package.json"):
        extension["generatedFiles"] = [unsafe]
        must_reject(lambda: selected({"extensions": [extension]}, "msi-ssh"))
    extension["generatedFiles"] = ["theme.json"]
    (location / "theme.json").unlink()
    (location / "theme.json").symlink_to(location / "package.json")
    must_reject(lambda: check(expected, directory, cache))
    (location / "theme.json").unlink()
    (location / "theme.json").write_text('{"generated":true}')
    (location / "code.js").write_text("unexpected modification")
    must_reject(lambda: repair_payloads(expected, directory, cache))
    (location / "code.js").unlink()
    (location / "code.js").symlink_to(location / "other.js")
    must_reject(lambda: repair_payloads(expected, directory, cache))
print("Extension selection, mismatch detection, cached SHA256, payload, generated JSON, and idempotent repair safety checks passed.")
