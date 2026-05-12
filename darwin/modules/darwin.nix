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
      remapCapsLockToEscape = true;
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];
}
