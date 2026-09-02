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