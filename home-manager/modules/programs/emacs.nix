{
  config,
  homeDirectory,
  lib,
  pkgs,
  ...
}:

let
  repoPath = "${homeDirectory}/Projects/nixos-macos";
  doomDir = "${config.home.homeDirectory}/.config/doom";
  emacsDir = "${config.home.homeDirectory}/.config/emacs";
  aspellWithEnglish = pkgs.aspellWithDicts (dicts: with dicts; [
    en
  ]);
  qmlImportPaths = [
    "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
  ];
  qmlImportArgs = lib.concatMapStringsSep " " (path: "-I ${lib.escapeShellArg path}") qmlImportPaths;
in
{
  home.packages = with pkgs; [
    emacs30

    # Core Doom/project tooling.
    git
    ripgrep
    fd
    editorconfig-core-c
    tree-sitter

    # Runtime basics and rich document support.
    sqlite
    gnutls
    imagemagick
    zstd
    unzip
    pandoc
    texliveSmall
    aspellWithEnglish
    harper

    # vterm native module build support.
    cmake
    gnumake
    gcc
    libtool
    pkg-config

    # Language server support for the Emacs experiment.
    lua
    lua-language-server
    qt6.qtlanguageserver
    rust-analyzer
    clang-tools

    (writeShellScriptBin "qmlls-wrapped" ''
      exec ${qt6.qtdeclarative}/bin/qmlls ${qmlImportArgs} "$@"
    '')

    # Nix editing support for the Emacs experiment.
    nil
    nixfmt

    (writeShellScriptBin "glibtool" ''
      exec ${libtool}/bin/libtool "$@"
    '')

    (writeShellScriptBin "doom-bootstrap" ''
      set -euo pipefail

      export DOOMDIR="${doomDir}"
      emacs_dir="${emacsDir}"

      if [ ! -d "$emacs_dir/.git" ]; then
        git clone --depth 1 https://github.com/doomemacs/doomemacs "$emacs_dir"
      else
        git -C "$emacs_dir" pull --ff-only
      fi

      "$emacs_dir/bin/doom" install
      "$emacs_dir/bin/doom" sync
    '')
  ];

  home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/doom";

  xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/doom";

  home.sessionPath = [
    "${emacsDir}/bin"
  ];

  home.sessionVariables = {
    DOOMDIR = doomDir;
  };
}
