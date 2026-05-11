{
  description = "Skydive420dz on MacNixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    system = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({pkgs, ...}: {
          nixpkgs.hostPlatform = "aarch64-darwin";

          programs.zsh.enable = true;
          users.users.skydive420dz = {
            home = "/Users/skydive420dz";
            shell = pkgs.zsh;
          };
          environment.shells = [pkgs.bash pkgs.zsh];
          nix.settings.experimental-features = ["nix-command" "flakes"];

          environment.systemPackages = [pkgs.coreutils];

          system.keyboard.enableKeyMapping = true;
          system.keyboard.remapCapsLockToEscape = true;

          fonts.packages = [pkgs.nerd-fonts.meslo-lg];

          system.primaryUser = "skydive420dz";
          system.stateVersion = 6;
          system.defaults.finder.AppleShowAllExtensions = true;
          system.defaults.finder._FXShowPosixPathInTitle = true;
          system.defaults.dock.autohide = true;
          system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
          system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
          system.defaults.NSGlobalDomain.KeyRepeat = 1;
        })
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.skydive420dz.imports = [
              ({pkgs, ...}: {
                home.username = "skydive420dz";
                home.homeDirectory = "/Users/skydive420dz";
                home.stateVersion = "25.11";
                home.packages = [pkgs.yazi pkgs.kitty-themes pkgs.ripgrep pkgs.fd pkgs.curl pkgs.less];
                home.sessionVariables = {
                  PAGER = "less";
                  CLICOLOR = "1";
                  EDITOR = "nvim";
                };
                programs.bat.enable = true;
                programs.bat.config.theme = "TwoDark";
                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;
                programs.eza.enable = true;
                programs.git.enable = true;
                programs.zsh.enableCompletion = true;
                programs.zsh.autosuggestion.enable = true;
                programs.zsh.syntaxHighlighting.enable = true;
                programs.zsh.shellAliases = {
                  ls = "ls -G -F";
                  vim = "nvim";
                  nrs = "sudo darwin-rebuild switch --flake ~/nixos-macos";
                  nuf = "sudo nix flake update --flake ~/nixos-macos";
                };
                programs.starship.enable = true;
                programs.starship.enableZshIntegration = true;
                programs.kitty = {
                  enable = true;
                  settings = {
                    background_opacity = "0.90";
                    scrollback_lines = 10000;
                    enable_audio_bell = "no";
                    tab_bar_style = "powerline";
                    tab_powerline_style = "round";
                    cursor_trail = 10;
                    repaint_delay = 10;
                    hide_window_decorations = "yes";
                    shell_integration = "enabled";
                    allow_remote_control = "yes";
                    window_padding_width = 10;
                  };

                  font = {
                    name = "MesloLGS Nerd Font Mono";
                    size = 16;
                  };

                  themeFile = "Catppuccin-Mocha";
                };
              })
            ];
          };
        }
      ];
    };
  in {
    darwinConfigurations.skydive420dz = system;
    darwinConfigurations."Rafaels-MacBook-Air" = system;
  };
}
