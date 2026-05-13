{
  pkgs,
  username,
  homeDirectory,
  ...
}:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";

    packages = with pkgs; [
      bitwarden-cli
      yazi
      kitty-themes
      ripgrep
      fd
      curl
      jq
      less
      inkscape
      darktable
      libreoffice-bin
      vesktop
    ];

    sessionVariables = {
      PAGER = "less";
      CLICOLOR = "1";
    };
  };
}
