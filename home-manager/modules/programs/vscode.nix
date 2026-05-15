{ pkgs, ... }:

let
  marketplaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "bbenoist";
      name = "qml";
      version = "1.0.0";
      sha256 = "1ncabpljax9kr49paxy2whjwq683cjvar0z5pf00wb7ra1b6g65n";
    }
    {
      publisher = "ms-python";
      name = "vscode-python-envs";
      version = "1.30.0";
      arch = "darwin-arm64";
      sha256 = "1rh7pfc4v4rbqi115zszrx35dcm4vl4prhy9h0vb090yrxzh73rm";
    }
    {
      publisher = "ms-vscode";
      name = "cpp-devtools";
      version = "0.5.13";
      sha256 = "0g2nmpvhfx2yrsb9k1qfrc66hghv1iabqms54hjal1qa91s5gil3";
    }
    {
      publisher = "ms-vscode";
      name = "cpptools-themes";
      version = "2.0.0";
      sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31";
    }
    {
      publisher = "openai";
      name = "chatgpt";
      version = "26.506.31421";
      arch = "darwin-arm64";
      sha256 = "1dcd8kqp7fh8xs92rk9wyb5lx5rq0g414l3s3jp77hxxr1xns4g8";
    }
  ];
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

      extensions = (with pkgs.vscode-extensions; [
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
      ]) ++ marketplaceExtensions;
    };
  };
}
