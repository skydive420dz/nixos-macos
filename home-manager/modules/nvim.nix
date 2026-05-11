{
  config,
  pkgs,
  lib,
  ...
}: let
  qmlImportPaths =
    [
      "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      "${pkgs.quickshell}/lib/qt-6/qml"
    ];
  qmlImportArgs = lib.concatMapStringsSep " " (path: "-I ${path}") qmlImportPaths;
in {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        startPlugins = ["chatgpt-nvim"];

        extraPackages = with pkgs;
          [
            tree-sitter # Satisfies tree-sitter-cli requirement
            gcc
            ripgrep
            fd
            lldb # Fixes Rustaceanvim debug warning
            pngpaste
            qt6.qtdeclarative
            qt6.qttools
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
          wrap = false; # Fixes cinnamon.nvim 'wrap' warning
        };

        spellcheck = {
          enable = true;
          languages = ["en"];
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
              type = ["nixfmt"];
            };
            lsp = {
              enable = true;
              servers = ["nixd"];
            };
            treesitter = {
              enable = true;
            };
          };
          toml = {
            enable = true;
            format = {
              enable = true;
              type = ["taplo"];
            };
            lsp = {
              enable = true;
              servers = ["taplo"];
            };
            treesitter = {
              enable = true;
            };
          };
          rust = {
            enable = true;
            extensions.crates-nvim.enable = true;
          };
          bash = {
            enable = true;
            format = {
              enable = true;
              type = ["shfmt"];
            };
            lsp = {
              enable = true;
              servers = ["bash-language-server"];
            };
          };
          json = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["vscode-json-language-server"];
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
              type = ["prettier"];
            };
            lsp = {
              enable = true;
              servers = ["vscode-css-language-server"];
            };
            treesitter = {
              enable = true;
            };
          };
          qml = {
            enable = true;
            format = {
              enable = true;
              type = ["qmlformat"];
            };
            lsp = {
              enable = true;
              servers = ["qmlls"];
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
          indent-blankline.enable = true;
        };

        statusline.lualine.enable = true;
        autocomplete.blink-cmp.enable = true;
        snippets.luasnip.enable = true;
        filetree.neo-tree.enable = true;
        tabline.nvimBufferline.enable = true;

        # Added explicit treesitter block to help NixOS healthcheck
        treesitter = {
          enable = true;
          context.enable = true;
          highlight.enable = true;
          indent.enable = true;
        };

        binds = {
          whichKey.enable = true;
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
          smart-splits.enable = true;
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
          alpha.enable = true;
        };

        session.nvim-session-manager.enable = false;
        gestures.gesture-nvim.enable = false;
        comments.comment-nvim.enable = true;
        presence.neocord.enable = false;

        assistant = {
          chatgpt.enable = true;
          copilot.enable = false;
          codecompanion-nvim.enable = true;
          avante-nvim.enable = false;
        };

        clipboard.enable = true;

        luaConfigRC.navigation = ''
          -- Health check path fixes
          vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
          vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

          -- Clipboard fix
          vim.opt.clipboard = 'unnamedplus'

          -- Navigation Hints Toggle
          vim.keymap.set("n", "<leader>pt", "<cmd>Precognition toggle<cr>", { desc = "Toggle Hints" })

          -- Trouble Diagnostics Toggle
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })

          -- CodeCompanion Setup for DeepSeek
          require("codecompanion").setup({
            strategies = {
              chat = { adapter = "ollama" },
              inline = { adapter = "ollama" },
            },
            adapters = {
              ollama = function()
                return require("codecompanion.adapters").extend("ollama", {
                  schema = {
                    model = {
                      default = "deepseek-r1:7b",
                    },
                  },
                })
              end,
            },
          })

        '';

        formatter.conform-nvim.enable = true;
        fzf-lua.enable = true;
        telescope.enable = true;
        autopairs.nvim-autopairs.enable = true;
        lazy.enable = true;
      };
    };
  };
}
