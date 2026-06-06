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

  # Fresh macOS installs still need manual Privacy & Security approvals:
  #   - /usr/local/bin/kanata: Input Monitoring
  #   - /usr/local/bin/kanata: Accessibility, if needed
  #   - Karabiner VirtualHIDDevice: Driver Extension enabled/activated
  # These cannot be declared reliably by nix-darwin because they live in macOS TCC/System Extension state.
  kanataBin = "/usr/local/bin/kanata";
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

    rm -rf ${lib.escapeShellArg "/Applications/Kanata.app"}
    mkdir -p /usr/local/bin
    cp ${lib.escapeShellArg "${pkgs.kanata}/bin/kanata"} ${lib.escapeShellArg kanataBin}
    chmod 755 ${lib.escapeShellArg kanataBin}
    /usr/bin/codesign --force --sign - ${lib.escapeShellArg kanataBin} >/dev/null 2>&1 || true
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

  launchd.daemons.karabiner-vhid-manager = {
    serviceConfig = {
      Label = "org.nixos.karabiner-vhid-manager";
      ProgramArguments = [
        manager
        "activate"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata-vhid-manager.log";
      StandardErrorPath = "/var/log/kanata-vhid-manager.log";
    };
  };

  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        kanataBin
        "--cfg"
        configFile
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
  };
}
