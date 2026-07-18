{ inputs, pkgs, ... }:

let
  vial = pkgs.callPackage ../../pkgs/vial.nix {
    vialSrc = inputs.vial-gui;
  };
in
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
    vial
    inputs.nvf.packages.aarch64-darwin.default
  ];
}
