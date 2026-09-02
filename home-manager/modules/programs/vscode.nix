{ lib, pkgs, ... }:

let
  extensions = [
    "bbenoist.qml"
    "davidanson.vscode-markdownlint"
    "eamodio.gitlens"
    "editorconfig.editorconfig"
    "evzen-wybitul.magic-racket"
    "fireblast.hyprlang-vscode"
    "jnoortheen.nix-ide"
    "mads-hartmann.bash-ide-vscode"
    "malmaud.tmux"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode.cmake-tools"
    "ms-vscode.cpp-devtools"
    "ms-vscode.cpptools"
    "ms-vscode.cpptools-extension-pack"
    "ms-vscode.cpptools-themes"
    "ms-vscode.powershell"
    "openai.chatgpt"
    "qingpeng.common-lisp"
    "rszyma.vscode-kanata"
    "sjhuangx.vscode-scheme"
    "sumneko.lua"
    "theqtcompany.qt-core"
    "theqtcompany.qt-qml"
    "tootone.org-mode"
    "volvo-antoniacanizares.ponytail-vscode"
    "vscode-icons-team.vscode-icons"
    "vscodevim.vim"
  ];

  preReleaseExtension = "ms-vscode.vscode-chat-customizations-evaluations";
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;

    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "Dark+";
        "chat.mcp.gallery.enabled" = true;
        "workbench.iconTheme" = "vscode-icons";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
      };
    };
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "vscode-install-extensions";
      runtimeInputs = [ pkgs.vscode ];
      text = ''
        # ponytail: installs the declared baseline; add pruning only if exact-set convergence is needed.
        for extension in ${lib.escapeShellArgs extensions}; do
          code --install-extension "$extension"
        done

        code --install-extension ${lib.escapeShellArg preReleaseExtension} --pre-release
      '';
    })
  ];
}
