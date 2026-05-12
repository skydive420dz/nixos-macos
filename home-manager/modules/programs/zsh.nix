{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "ls -G -F";
      vim = "nvim";
      nrs = "sudo darwin-rebuild switch --flake ~/nixos-macos";
      nuf = "sudo nix flake update --flake ~/nixos-macos";
    };
  };
}
