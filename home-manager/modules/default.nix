{ inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./home.nix
    ./nvim.nix
    ./programs/bat.nix
    ./programs/emacs.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/kanata.nix
    ./programs/kitty.nix
    ./programs/starship.nix
    ./programs/vscode.nix
    ./programs/yazi.nix
    ./programs/zsh.nix
  ];
}
