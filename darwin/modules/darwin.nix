{
  pkgs,
  hostname,
  username,
  homeDirectory,
  ...
}:

{
  networking.hostName = hostname;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (_final: prev: {
        chromaprint = prev.chromaprint.overrideAttrs (_old: {
          doCheck = false;
        });

        kvazaar = prev.kvazaar.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];
  };

  users.users.${username} = {
    home = homeDirectory;
    shell = pkgs.zsh;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shells = [
      pkgs.bash
      pkgs.zsh
    ];
    pathsToLink = [
      "/bin"
      "/share"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system = {
    primaryUser = username;
    stateVersion = 6;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = false;
    };
  };

  fonts.packages = [
    pkgs.inter
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.symbols-only
  ];
}
