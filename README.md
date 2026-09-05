# macOS configuration

This repository contains a nix-darwin and Home Manager configuration for macOS.

## Tools

Run the helper from this directory or by absolute path:

```sh
./scripts/macos-config doctor
./scripts/macos-config arch
./scripts/macos-config apple-silicon
./scripts/macos-config check
./scripts/macos-config build
./scripts/macos-config switch
./scripts/macos-config update
```

`switch` applies the configuration to the configured host. Use
`--target NAME` or set `MACOS_CONFIG_TARGET` when working with another flake
target.

`doctor` checks prerequisites and architecture. `arch` prints the current
machine architecture, and `apple-silicon` exits non-zero unless the host is an
Apple Silicon Mac (`arm64` or `aarch64`).

## Coordinated VS Code releases

`config/vscode/release.json` selects the exact application commit and extension
versions, channels, platforms, and destinations. `package.nix` overrides only
VS Code in the locked nixpkgs package set. Keep the shared release files
identical in MSI's `nixos-dotfiles/config/vscode`; compare their checksums before
activation. Independent application and extension updates are disabled.

The release covers four components: macOS frontend, MSI frontend, the matching
Remote-SSH server, and the separately launched Agent Host. Open projects with
`code-msi /home/skydive420dz/Projects/PROJECT`. The Mac Dock and Ctrl-Alt-C
shortcut, plus MSI's desktop launcher, use SSH. Frontends retain UI extensions;
project extensions, Codex, terminals, and
builds run on MSI. Existing local projects remain preserved.

Nix owns application binaries and the Agent Host CLI. VS Code's native installer
owns mutable extension directories, separately for each target. Home Manager
links tracked settings into the live profiles, so editing these JSON files
changes running settings. Keep the macOS checkout at `~/Projects/nixos-macos`.

The Agent Host CLI is built from the selected VS Code source and pins backend
resolution and cache selection to its compiled commit. Its native argument
parser accepts only Agent commands. Both frontends must retain
`remote.SSH.useExecServer=false`: this uses Remote-SSH's native Node server path
and avoids the stock CLI independently spawning an updating Agent Host. This
configuration does not provide exec-server features such as WSL/Dev Containers
over SSH. Install the CLI as an executable copy at
`~/.vscode-server/code-COMMIT` on MSI; a symlink into the Nix store is unsuitable
because the native client touches that path.

For each upgrade:

1. Resolve one compatible release, update artifact hashes and the Agent Host
   source/dependency hashes, then freeze that selection. Build both system
   candidates from baselines matching their active generations; retain the
   previous generations and check that the delta is confined to this release.
2. Run `python3 config/vscode/test_extensions.py`. Use
   `vscode-install-extensions stage --target TARGET --code CODE --extensions-dir
   NEW_DIR --user-data-dir NEW_DATA --cache-dir CACHE` for `mac-ui`, `msi-ui`,
   and `msi-ssh`. Staging uses exact native installs and checks the resulting
   payloads against hashed artifacts. New directories keep the live sets intact.
3. Save work and close both frontends. Preserve settings, profile state,
   extension directories, CLI binaries, and the previous generation paths.
   Stop the old remote extension hosts and Agent Host. Activate both prepared
   generations in the same maintenance window and switch all staged extension
   sets; any partial failure leaves the release incomplete.
4. Disable extension Settings Sync and clear per-extension auto-update opt-ins
   through the native UI. If preparing state offline, change only the verified
   native storage keys after closing VS Code and backing up its databases.
   Keep `extensions.autoUpdate="off"`, `extensions.autoCheckUpdates=false`, and
   `update.mode=none`. Set `extensions.allowed` to the selected versions,
   including the bundled Copilot version: its product configuration forces
   auto-updates even without a stored `forceAutoUpdate` flag.
5. Run the helper's `check` command for every target. Confirm the running editor,
   server, and Agent Host commits, successful protocol negotiation, and extension
   placement. Run a real Astra task in an SSH window, inspect its MSI execution,
   and repeat after reconnect. Check the logs for activation and permission errors.

To roll back, close the participating clients again, restore the paired Nix
generations, extension directories, CLI copy, settings, and backed-up profile
state, then reconnect and verify the previous set. Do not merge native and SSH
extension directories or run their installers as root. In the current audit,
only two MSI native Copilot generated shim files needed owner-write permission;
their ownership was correct. Nix sources are intentionally read-only, so the
supported project workflow keeps Copilot on MSI's writable SSH server.

`config/vscode/cutover.py --state PREPARED_STATE.json` checks a prepared release
on both hosts. Add `--apply` from an external Mac terminal after closing VS Code;
sudo credentials are entered interactively. Completed hosts can be resumed.
Replace `--apply` with `--rollback` to restore both hosts and retain rejected
state. Run `python3 config/vscode/test_cutover.py` to check recovery behavior.
Prepared state files are specific to their recorded generations and hashes.

The source-built CLI preserves the SSH Agent Host operations `endpoints`,
`host`, and `relay`. Upstream 1.136.1's `agent ps` uses an older AHP client and
fails against its own backend; use the frontend or the verified 0.9 protocol
check for diagnostics. This does not affect the tested native relay path.

The release controls installed extensions and their bundled runtimes. Account
model availability and services hosted by OpenAI/Microsoft remain external;
confirm Astra with an actual request for each accepted release.
