{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "ls -G -F";
      vim = "nvim";
      nrs = "sudo darwin-rebuild switch --flake ~/Projects/nixos-macos";
      nuf = "nix flake update --flake ~/Projects/nixos-macos";
    };
  };
}
