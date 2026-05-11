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

    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs: let
    system = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # Darwin base module
        ./darwin/modules/default.nix

        # System configuration
        ({pkgs, ...}: {
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.skydive420dz = {
            home = "/Users/skydive420dz";
            shell = pkgs.zsh;
          };

          environment.variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };

          environment.shells = [pkgs.bash pkgs.zsh];
          environment.pathsToLink = ["/bin" "/share"];

          nix.settings.experimental-features = ["nix-command" "flakes"];

          environment.systemPackages = with pkgs; [
            tree
            coreutils
            pngpaste
            qt6.qtdeclarative
            qt6.qttools
            inputs.nvf.packages.aarch64-darwin.default
          ];

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

        # Home Manager integration for Darwin
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # User configuration as a function, pkgs in scope
            users.skydive420dz = {pkgs, ...}: {
              imports = [
                inputs.nvf.homeManagerModules.default
                ./home-manager/modules/default.nix
              ];

              home.username = "skydive420dz";
              home.homeDirectory = "/Users/skydive420dz";
              home.stateVersion = "25.11";

              home.packages = with pkgs; [
                yazi
                kitty-themes
                ripgrep
                fd
                curl
                less
              ];

              home.sessionVariables = {
                PAGER = "less";
                CLICOLOR = "1";
              };

              programs.bat.enable = true;
              programs.bat.config.theme = "TwoDark";
              programs.fzf.enable = true;
              programs.fzf.enableZshIntegration = true;
              programs.eza.enable = true;
              programs.git.enable = true;

              programs.zsh = {
                enable = true;
                enableCompletion = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                shellAliases = {
                  ls = "ls -G -F";
                  vim = "nvim";
                  nrs = "sudo darwin-rebuild switch --flake ~/nixos-macos";
                  nuf = "sudo nix flake update --flake ~/nixos-macos";
                };
              };

              programs.starship.enable = true;
              programs.starship.enableZshIntegration = true;

              programs.kitty.enable = true;
              programs.kitty.themeFile = "Catppuccin-Mocha";
              programs.kitty.settings = {
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
              programs.kitty.font = {
                name = "MesloLGS Nerd Font Mono";
                size = 16;
              };
            };
          };
        }
      ];
    };
  in {
    darwinConfigurations.skydive420dz = system;
    darwinConfigurations."Rafaels-MacBook-Air" = system;
  };
}
