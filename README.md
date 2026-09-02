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

## VS Code ownership

Nix installs `pkgs.vscode` from the repository's locked nixpkgs input, so each
generation is reproducible without a separate VS Code version pin. Home
Manager links the tracked `config/vscode/settings.json` into the live user
profile with an out-of-store symlink, so VS Code can edit it and Git exposes
the changes. The tracked settings disable VS Code's application updater.
Keep the checkout at `~/Projects/nixos-macos`, which is the symlink target.

VS Code owns and updates extension payloads in its mutable user extension
directory. Run `vscode-install-extensions` without `sudo` to install the
declared extension-ID baseline. The helper is manual and additive: activation
does not run it, and it neither removes unlisted extensions nor pins extension
versions.

This module governs the local macOS profile only. It does not manage
Remote-SSH server state or Codex tools, agents, and skills.
