{
  lib,
  pkgs,
  homeDirectory,
  ...
}:

let
  driver = pkgs.karabiner-elements.driver;
  driverRoot = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice";
  managerRoot = "/Applications/.Nix-Kanata-VirtualHIDDevice";
  manager = "${managerRoot}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  daemon = "${driverRoot}/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
  configFile = "${homeDirectory}/.config/kanata/kanata.kbd";
  appRoot = "/Applications/Kanata.app";
  appBin = "${appRoot}/Contents/MacOS/Kanata";

  kanataAppBin = pkgs.stdenv.mkDerivation {
    pname = "kanata-app-bin";
    version = "1.0";
    dontUnpack = true;

    buildPhase = ''
      cat > kanata-app.c <<'C'
      #include <stdio.h>
      #include <unistd.h>

      int main(void) {
        const char *kanata = "${pkgs.kanata}/bin/kanata";
        const char *config = "${configFile}";
        execl(kanata, "kanata", "--cfg", config, (char *)NULL);
        perror("execl");
        return 1;
      }
      C

      $CC kanata-app.c -o Kanata
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -m 0755 Kanata $out/bin/Kanata
    '';
  };
in
{
  environment.systemPackages = [ pkgs.kanata ];

  # DriverKit system extensions must live under /Applications as real files.
  # We use only Karabiner's VirtualHID driver/daemon; Karabiner-Elements itself is removed.
  system.activationScripts.preActivation.text = ''
    rm -rf ${lib.escapeShellArg driverRoot}
    mkdir -p ${lib.escapeShellArg "/Library/Application Support/org.pqrs"}
    cp -R ${lib.escapeShellArg "${driver}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice"} ${lib.escapeShellArg driverRoot}

    rm -rf ${lib.escapeShellArg managerRoot}
    mkdir -p ${lib.escapeShellArg managerRoot}
    cp -R ${lib.escapeShellArg "${driver}/Applications/.Karabiner-VirtualHIDDevice-Manager.app"} ${lib.escapeShellArg managerRoot}/

    rm -rf ${lib.escapeShellArg appRoot}
    mkdir -p ${lib.escapeShellArg "${appRoot}/Contents/MacOS"} ${lib.escapeShellArg "${appRoot}/Contents/Resources"}
    cat > ${lib.escapeShellArg "${appRoot}/Contents/Info.plist"} <<'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key>
      <string>Kanata</string>
      <key>CFBundleIdentifier</key>
      <string>org.nixos.kanata</string>
      <key>CFBundleName</key>
      <string>Kanata</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>1.0</string>
      <key>CFBundleVersion</key>
      <string>1</string>
      <key>NSInputMonitoringUsageDescription</key>
      <string>Kanata needs Input Monitoring to remap keyboard events.</string>
    </dict>
    </plist>
PLIST
    cp ${lib.escapeShellArg "${kanataAppBin}/bin/Kanata"} ${lib.escapeShellArg appBin}
    chmod 755 ${lib.escapeShellArg appBin}
    /usr/bin/codesign --force --deep --sign - ${lib.escapeShellArg appRoot} >/dev/null 2>&1 || true
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ${lib.escapeShellArg appRoot} >/dev/null 2>&1 || true
  '';

  system.activationScripts.postActivation.text = ''
    echo "Activating Karabiner VirtualHIDDevice driver for Kanata..." >&2
    ${lib.escapeShellArg manager} activate || true
  '';

  launchd.daemons.karabiner-vhid-daemon = {
    serviceConfig = {
      Label = "org.nixos.karabiner-vhid-daemon";
      ProgramArguments = [ daemon ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata-vhid-daemon.log";
      StandardErrorPath = "/var/log/kanata-vhid-daemon.log";
    };
  };

  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [ appBin ];
      RunAtLoad = false;
      KeepAlive = false;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
  };
}
