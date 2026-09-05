{
  config,
  pkgs,
  ...
}:

let
  repoPath = "${config.home.homeDirectory}/Projects/nixos-macos";
  vscode = import ../../../config/vscode/package.nix { inherit pkgs; };
  launchMsi = pkgs.writeShellScript "launch-vscode-msi" ''
    unset VSCODE_IPC_HOOK_CLI VSCODE_CLI_AUTHORITY
    exec ${vscode}/bin/code --remote ssh-remote+msi "$@"
  '';
in
{
  home.file."Library/Application Support/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/vscode/settings.json";

  programs.vscode = {
    enable = true;
    package = vscode;
    mutableExtensionsDir = true;
  };

  home.packages = [
    (pkgs.runCommandLocal "vscode-msi-launcher" { } ''
      app="$out/Applications/VS Code MSI.app/Contents"
      mkdir -p "$app/MacOS" "$app/Resources"
      cp ${launchMsi} "$app/MacOS/launch"
      cp '${vscode}/Applications/Visual Studio Code.app/Contents/Resources/Code.icns' "$app/Resources/Code.icns"
      cat > "$app/Info.plist" <<'PLIST'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
      <key>CFBundleIdentifier</key><string>local.vscode-msi</string>
      <key>CFBundleName</key><string>VS Code MSI</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleExecutable</key><string>launch</string>
      <key>CFBundleIconFile</key><string>Code.icns</string>
      <key>LSUIElement</key><true/>
      </dict></plist>
      PLIST
    '')
    (pkgs.writeShellApplication {
      name = "vscode-install-extensions";
      runtimeInputs = [ pkgs.python3 ];
      text = ''
        exec python3 ${../../../config/vscode/extensions.py} "$@" --manifest ${../../../config/vscode/release.json}
      '';
    })
    (pkgs.writeShellApplication {
      name = "code-msi";
      text = ''
        exec ${launchMsi} "$@"
      '';
    })
  ];
}
