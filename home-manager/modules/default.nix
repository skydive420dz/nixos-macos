{ inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./home.nix
    ./nvim.nix
    ./programs/bat.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/starship.nix
    ./programs/vscode.nix
    ./programs/zsh.nix
  ];
}
