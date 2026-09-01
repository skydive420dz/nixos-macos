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

        libgphoto2 = prev.libgphoto2.overrideAttrs (old: {
          buildInputs = old.buildInputs ++ [ prev.gettext ];
        });

        mailutils = prev.mailutils.overrideAttrs (old: {
          postPatch = old.postPatch + ''
            substituteInPlace libmu_sieve/extensions/Makefile.am \
              --replace-fail 'LIBS = ../libmu_sieve.la' 'LIBS = ../libmu_sieve.la $(MU_LIB_MAILUTILS)'
            substituteInPlace examples/Makefile.am \
              --replace-fail 'numaddr_la_LIBADD = $(MU_LIB_SIEVE)' 'numaddr_la_LIBADD = $(MU_LIB_SIEVE) $(MU_LIB_MAILUTILS)'
          '';
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
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.symbols-only
  ];
}
