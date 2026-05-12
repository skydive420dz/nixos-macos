{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tree
    coreutils
    pngpaste
    qt6.qtdeclarative
    qt6.qttools
    inputs.nvf.packages.aarch64-darwin.default
  ];
}
