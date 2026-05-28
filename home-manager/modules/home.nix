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
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [
      bitwarden-cli
      kitty-themes
      ripgrep
      fd
      curl
      jq
      less
      ffmpeg-full
      vlc-bin
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
