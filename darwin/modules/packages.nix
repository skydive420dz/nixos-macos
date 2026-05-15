{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tree
    coreutils
    pngpaste
    nil
    lua-language-server
    qt6.qtdeclarative
    qt6.qttools
    qt6.qtlanguageserver
    inputs.nvf.packages.aarch64-darwin.default
  ];
}
