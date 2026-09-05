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
    ./programs/ghostty.nix
    ./programs/starship.nix
    ./programs/vscode.nix
    ./programs/wezterm.nix
    ./programs/yazi.nix
    ./programs/zsh.nix
  ];
}
