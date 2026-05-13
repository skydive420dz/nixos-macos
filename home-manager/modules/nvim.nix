{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;

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

        statusline.lualine.enable = true;
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
          context.enable = true;
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
                  hl = "Type";
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

        luaConfigRC.navigation = ''
          -- Health check path fixes
          vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
          vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

          -- Clipboard fix
          vim.opt.clipboard = 'unnamedplus'

          -- Spelling
          vim.opt.spell = true
          vim.opt.spelllang = { "en_us" }
          vim.keymap.set("n", "]s", "]s", { desc = "Next spelling error" })
          vim.keymap.set("n", "[s", "[s", { desc = "Previous spelling error" })
          vim.keymap.set("n", "<leader>zg", "zg", { desc = "Add word to dictionary" })
          vim.keymap.set("n", "<leader>zw", "zw", { desc = "Mark word wrong" })
          vim.keymap.set("n", "<leader>z=", "z=", { desc = "Spelling suggestions" })

          -- Autosave changed normal file buffers after 3 seconds idle in normal mode
          vim.opt.updatetime = 3000
          local autosave_group = vim.api.nvim_create_augroup("NormalModeAutosave", { clear = true })
          local autosave_pending = false

          local function can_autosave()
            return vim.bo.modified
              and vim.bo.modifiable
              and not vim.bo.readonly
              and vim.bo.buftype == ""
              and vim.fn.expand("%") ~= ""
              and vim.fn.mode() == "n"
          end

          vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            group = autosave_group,
            callback = function()
              autosave_pending = true
            end,
          })

          vim.api.nvim_create_autocmd("CursorHold", {
            group = autosave_group,
            callback = function()
              if autosave_pending and can_autosave() then
                local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
                autosave_pending = false
                vim.cmd("silent! update")
                vim.notify("Saved " .. filename, vim.log.levels.INFO, { title = "Autosave" })
              end
            end,
          })

          -- Navigation Hints Toggle
          vim.keymap.set("n", "<leader>pt", "<cmd>Precognition toggle<cr>", { desc = "Toggle Hints" })

          -- Trouble Diagnostics Toggle
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })

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
