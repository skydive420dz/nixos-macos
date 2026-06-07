{
  config,
  homeDirectory,
  lib,
  pkgs,
  ...
}:

let
  repoPath = "${homeDirectory}/Projects/nixos-macos";
  emacsPackage = pkgs.emacs30;
  aspellWithEnglish = pkgs.aspellWithDicts (
    dicts: with dicts; [
      en
    ]
  );
  qmlImportPaths = [
    "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
  ];
  qmlImportArgs = lib.concatMapStringsSep " " (path: "-I ${lib.escapeShellArg path}") qmlImportPaths;
  qmllsWrapped = pkgs.writeShellScriptBin "qmlls-wrapped" ''
    exec ${pkgs.qt6.qtdeclarative}/bin/qmlls ${qmlImportArgs} "$@"
  '';
  glibtoolWrapped = pkgs.writeShellScriptBin "glibtool" ''
    exec ${pkgs.libtool}/bin/libtool "$@"
  '';
  emacsTreeSitterGrammars = with pkgs.tree-sitter-grammars; {
    bash = tree-sitter-bash;
    c = tree-sitter-c;
    cpp = tree-sitter-cpp;
    css = tree-sitter-css;
    glsl = tree-sitter-glsl;
    haskell = tree-sitter-haskell;
    html = tree-sitter-html;
    javascript = tree-sitter-javascript;
    json = tree-sitter-json;
    lua = tree-sitter-lua;
    markdown = tree-sitter-markdown;
    markdown-inline = tree-sitter-markdown-inline;
    nix = tree-sitter-nix;
    org = tree-sitter-org;
    python = tree-sitter-python;
    qmljs = tree-sitter-qmljs;
    rust = tree-sitter-rust;
    toml = tree-sitter-toml;
    tsx = tree-sitter-tsx;
    typescript = tree-sitter-typescript;
    yaml = tree-sitter-yaml;
  };
  emacsTreeSitterGrammarBundle = pkgs.runCommand "emacs-tree-sitter-grammars" { } (
    ''
      mkdir -p "$out/lib"
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (language: grammar: ''
        ln -s ${grammar}/parser "$out/lib/libtree-sitter-${language}${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
      '') emacsTreeSitterGrammars
    )
  );
  emacsTreeSitterGrammarPath = "${emacsTreeSitterGrammarBundle}/lib";
  emacsNeovimRuntimePath = "${pkgs.neovim-unwrapped}/share/nvim/runtime";
  emacsRuntimeTools = with pkgs; [
    emacsPackage

    # Shell/build tools used by Emacs packages with native modules.
    bashInteractive
    coreutils
    findutils
    perl
    cmake
    gnumake
    gcc
    libtool
    autoconf
    automake
    pkg-config
    glibtoolWrapped

    # Core editor/project tooling.
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

    # Language server support.
    nodejs
    typescript
    typescript-language-server
    prettier
    html-tidy
    stylelint
    jsbeautifier
    lua
    lua-language-server
    stylua
    basedpyright
    pipenv
    black
    isort
    ruff
    python3Packages.pyflakes
    python3Packages.pytest
    haskell-language-server
    ghc
    cabal-install
    haskellPackages.hoogle
    vscode-langservers-extracted
    yaml-language-server
    bash-language-server
    marksman
    qt6.qtlanguageserver
    rust-analyzer
    rustc
    cargo
    rustfmt
    clang-tools
    shellcheck
    shfmt
    glslang
    glsl_analyzer
    qmllsWrapped

    # Nix editing support.
    nixd
    nixfmt
  ];
  emacsRuntimePath = lib.makeBinPath emacsRuntimeTools;
  emacsSync = pkgs.writeShellScriptBin "emacs-sync" ''
    set -euo pipefail

    export PATH="${emacsRuntimePath}:''${PATH-}"
    export SK_EMACS_TREE_SITTER_GRAMMAR_PATH="${emacsTreeSitterGrammarPath}"

    ${emacsPackage}/bin/emacs --batch \
      -l "$HOME/.config/emacs/early-init.el" \
      -l "$HOME/.config/emacs/init.el" \
      --eval "(message \"emacs packages loaded\")"

    vterm_dir="$(
      find "$HOME/.cache/emacs/elpa" \
        -maxdepth 1 \
        -type d \
        -name 'vterm-*' \
      | sort \
      | tail -n 1
    )"

    if [ -z "$vterm_dir" ]; then
      echo "emacs-sync: vterm package directory not found" >&2
      exit 1
    fi

    cmake -S "$vterm_dir" -B "$vterm_dir/build" -DUSE_SYSTEM_LIBVTERM=Off
    cmake --build "$vterm_dir/build"
    test -f "$vterm_dir/vterm-module.so"

    ${emacsPackage}/bin/emacs --batch \
      -l "$HOME/.config/emacs/early-init.el" \
      -l "$HOME/.config/emacs/init.el" \
      --eval "(progn (require 'vterm) (message \"emacs-sync complete\"))"
  '';
in
{
  home.sessionVariables.SK_EMACS_TREE_SITTER_GRAMMAR_PATH = emacsTreeSitterGrammarPath;

  home.packages = emacsRuntimeTools ++ [
    emacsSync
  ];

  # Doom is frozen reference material; clean Emacs is the active config.
  home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/doom";
  home.file.".cache/emacs/tree-sitter-grammars".source = emacsTreeSitterGrammarBundle;
  home.file.".cache/emacs/lua/neovim-runtime".source = emacsNeovimRuntimePath;
  xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/doom";
  xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/emacs";
}
