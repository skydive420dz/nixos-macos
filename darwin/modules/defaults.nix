{
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
    };

    dock = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
      tilesize = 40;

      persistent-apps = [
        "/System/Applications/Messages.app"
        "/Applications/Safari.app"
        "/System/Applications/Mail.app"
        "/Users/skydive420dz/Applications/Home Manager Apps/kitty.app"
        "/System/Applications/Music.app"
        "/System/Applications/iPhone Mirroring.app"
        "/System/Applications/Maps.app"
        "/Users/skydive420dz/Applications/Home Manager Apps/Visual Studio Code.app"
        "/System/Applications/Reminders.app"
        "/System/Applications/Notes.app"
      ];

      persistent-others = [ ];
    };

    WindowManager = {
      GloballyEnabled = false;
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      EnableTiledWindowMargins = false;
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
  };
}
