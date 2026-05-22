{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
  theme = import ../../config/theme/tokens.nix;
  semantic = theme.semantic;
  customLua = import ./nvim/lua.nix {
    inherit theme semantic;
  };

  qmlImportPaths = [
    "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    "${pkgs.quickshell}/lib/qt-6/qml"
  ];
  qmlImportArgs = lib.concatMapStringsSep " " (path: "-I ${path}") qmlImportPaths;
in
{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        startPlugins = [ ];

        extraPackages =
          with pkgs;
          [
            # General editor/project utilities.
            tree-sitter # Satisfies tree-sitter-cli requirement
            ripgrep
            fd

            # Enabled language support should be operational when Neovim opens a project.
            # Project flakes can still override versions for repo-specific work.
            bash-language-server
            basedpyright
            clang-tools
            cargo
            gcc
            jdt-language-server
            lua-language-server
            marksman
            nixd
            nixfmt
            nodejs
            prettier
            rustc
            rust-analyzer
            shfmt
            stylua
            taplo
            typescript
            typescript-language-server
            vscode-langservers-extracted

            # Debuggers and framework-specific tools.
            lldb # Fixes Rustaceanvim debug warning
            qt6.qtdeclarative
            qt6.qttools
          ]
          ++ lib.optionals stdenv.isDarwin [
            pngpaste
          ]
          ++ lib.optionals stdenv.isLinux [
            quickshell
          ];

        viAlias = false;
        vimAlias = true;
        debugMode = {
          enable = false;
          level = 16;
          logFile = "/tmp/nvim.log";
        };

        opts = {
          expandtab = true;
          ignorecase = true;
          inccommand = "split";
          laststatus = 3;
          number = true;
          relativenumber = true;
          scrolloff = 8;
          shiftwidth = 4;
          signcolumn = "yes";
          smartcase = true;
          smartindent = true;
          softtabstop = 4;
          splitbelow = true;
          splitright = true;
          tabstop = 4;
          wrap = false; # Fixes cinnamon.nvim 'wrap' warning
        };

        spellcheck = {
          enable = true;
          languages = [
            "en"
            "en_us"
          ];
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = true;
          lspSignature.enable = false;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
          presets.harper.enable = true;
          servers.qmlls = {
            cmd = lib.mkForce [
              "${pkgs.writeShellScriptBin "qmlls-wrapped" ''
                exec ${pkgs.qt6.qtdeclarative}/bin/qmlls ${qmlImportArgs} "$@"
              ''}/bin/qmlls-wrapped"
            ];
          };
        };

        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          python.enable = true;
          typescript.enable = true;

          markdown.enable = true;
          nix = {
            enable = true;
            format = {
              enable = true;
              type = [ "nixfmt" ];
            };
            lsp = {
              enable = true;
              servers = [ "nixd" ];
            };
            treesitter = {
              enable = true;
            };
          };
          toml = {
            enable = true;
            format = {
              enable = true;
              type = [ "taplo" ];
            };
            lsp = {
              enable = true;
              servers = [ "taplo" ];
            };
            treesitter = {
              enable = true;
            };
          };
          rust = {
            enable = true;
            extensions.crates-nvim.enable = true;
            lsp = {
              enable = true;
              package = pkgs.rust-analyzer;
            };
          };
          bash = {
            enable = true;
            format = {
              enable = true;
              type = [ "shfmt" ];
            };
            lsp = {
              enable = true;
              servers = [ "bash-language-server" ];
            };
          };
          json = {
            enable = true;
            lsp = {
              enable = true;
              servers = [ "vscode-json-language-server" ];
            };
            treesitter = {
              enable = true;
            };
          };
          clang.enable = true;
          css = {
            enable = true;
            format = {
              enable = true;
              type = [ "prettier" ];
            };
            lsp = {
              enable = true;
              servers = [ "vscode-css-language-server" ];
            };
            treesitter = {
              enable = true;
            };
          };
          qml = {
            enable = true;
            format = {
              enable = true;
              type = [ "qmlformat" ];
            };
            lsp = {
              enable = true;
              servers = [ "qmlls" ];
            };
            treesitter = {
              enable = true;
            };
          };
          java.enable = true;
          lua.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          blink-indent.enable = true;
          indent-blankline.enable = false;
        };
        mini.icons.enable = true;

        statusline.lualine = {
          enable = true;
          activeSection.a = [
            ''
              {
                "mode",
                icons_enabled = true,
                icon = "",
                separator = {
                  left = '▎',
                  right = ''
                },
              }
            ''
            ''
              {
                "",
                draw_empty = true,
                separator = { left = '', right = '' }
              }
            ''
          ];
        };
        autocomplete.blink-cmp = {
          enable = true;
          setupOpts.keymap = {
            "<Up>" = [
              "select_prev"
              "fallback"
            ];
            "<Down>" = [
              "select_next"
              "fallback"
            ];
          };
        };
        snippets.luasnip.enable = true;
        filetree.neo-tree = {
          enable = true;
          setupOpts = {
            enable_git_status = true;
            enable_refresh_on_write = true;
            git_status_async = true;
            filesystem.use_libuv_file_watcher = true;
          };
        };
        tabline.nvimBufferline.enable = true;

        # Added explicit treesitter block to help NixOS healthcheck
        treesitter = {
          enable = true;
          context = {
            enable = true;
            setupOpts.enable = false;
          };
          highlight.enable = true;
          indent.enable = true;
        };

        binds = {
          whichKey = {
            enable = true;
            setupOpts = {
              preset = "helix";
              notify = false;
              delay = 500;
            };
          };
          cheatsheet.enable = true;
        };

        notify.nvim-notify.enable = true;
        projects.project-nvim.enable = true;

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = true;
          surround.enable = true;
          leetcode-nvim.enable = true;
          multicursors.enable = true;
          smart-splits = {
            enable = true;
            setupOpts.multiplexer_integration = mkLuaInline ''vim.env.TMUX and "tmux" or nil'';
          };
          undotree.enable = true;
          nvim-biscuits.enable = true;
          grug-far-nvim.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };

          images = {
            image-nvim.enable = false;
            img-clip.enable = true;
          };
        };

        notes = {
          neorg.enable = false;
          orgmode.enable = false;
          todo-comments.enable = true;
        };

        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          modes-nvim.enable = false;
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };

          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              nix = "110";
              ruby = "120";
              java = "130";
              go = [
                "90"
                "130"
              ];
            };
          };
          fastaction.enable = true;
        };
        dashboard = {
          dashboard-nvim.enable = false;
          alpha = {
            enable = true;
            theme = null;
            layout = [
              {
                type = "padding";
                val = 2;
              }
              {
                type = "text";
                val = [
                  "                                                        "
                  "             ████  ████                            "
                  "             █████ █████                           "
                  "              ██████████                          "
                  "      ███████████████████                         "
                  "     █████████████████████                        "
                  "    ██████████████████████                       "
                  "   ████████████████████████                      "
                  "  ██████████████████████████                     "
                  "  ██████████████████████████                     "
                  "   ███████████████████████                       "
                  "    █████████████████████                        "
                  "        ███████████████                          "
                  "          ████████████                              "
                  "                                                        "
                  "             N E O V I M   /   skydive420dz            "
                  "                                                        "
                ];
                opts = {
                  position = "center";
                  hl = "AlphaHeader";
                };
              }
              {
                type = "padding";
                val = 1;
              }
              {
                type = "group";
                val = mkLuaInline ''
                  (function()
                    local dashboard = require("alpha.themes.dashboard")
                    return {
                      dashboard.button("n", "  New file", "<cmd>ene <bar> startinsert<cr>"),
                      dashboard.button("e", "  Explorer", "<cmd>Neotree toggle<cr>"),
                      dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
                      dashboard.button("g", "󰱼  Live grep", "<cmd>Telescope live_grep<cr>"),
                      dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
                      dashboard.button("s", "󰆓  Load session", "<cmd>SessionManager load_session<cr>"),
                      dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
                    }
                  end)()
                '';
                opts = {
                  spacing = 1;
                };
              }
            ];
          };
        };

        session.nvim-session-manager = {
          enable = true;
          setupOpts.autoload_mode = "Disabled";
          mappings = {
            saveCurrentSession = "<leader>Ss";
            loadSession = "<leader>Sl";
            loadLastSession = "<leader>Sr";
            deleteSession = "<leader>Sd";
          };
        };
        gestures.gesture-nvim.enable = false;
        comments.comment-nvim.enable = true;
        presence.neocord.enable = false;

        assistant = {
          chatgpt.enable = false;
          copilot.enable = false;
          codecompanion-nvim.enable = false;
          avante-nvim.enable = false;
        };

        clipboard.enable = true;

        luaConfigRC = customLua;

        formatter.conform-nvim.enable = true;
        fzf-lua.enable = true;
        telescope.enable = true;
        autopairs.nvim-autopairs.enable = true;
        lazy.enable = true;
      };
    };
  };
}
