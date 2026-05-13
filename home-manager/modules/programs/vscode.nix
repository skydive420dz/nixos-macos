{ pkgs, ... }:

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

      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        jnoortheen.nix-ide
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        vscode-icons-team.vscode-icons
        vscodevim.vim
      ];
    };
  };
}
