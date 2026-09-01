# macOS configuration

This repository contains a nix-darwin and Home Manager configuration for macOS.

## Tools

Run the helper from this directory or by absolute path:

```sh
./scripts/macos-config doctor
./scripts/macos-config check
./scripts/macos-config build
./scripts/macos-config switch
./scripts/macos-config update
```

`switch` applies the configuration to the configured host. Use
`--target NAME` or set `MACOS_CONFIG_TARGET` when working with another flake
target.

`doctor` only checks local prerequisites and does not change the system.