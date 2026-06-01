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
  terminal = theme.terminal;
  repoPath = "${config.home.homeDirectory}/Projects/nixos-macos";
  customLua = {
    skyBootstrap = ''
      vim.g.sky_theme = {
        name = "${theme.name}",
        flavor = "${theme.flavor}",
        foreground = "${semantic.foreground}",
        background = "${semantic.background}",
        surface = "${semantic.surface}",
        surface_strong = "${semantic.surfaceStrong}",
        border = "${semantic.border}",
        border_active = "${semantic.borderActive}",
        accent = "${semantic.accent}",
        accent_alt = "${semantic.accentAlt}",
        muted = "${semantic.muted}",
        success = "${semantic.success}",
        warning = "${semantic.warning}",
        danger = "${semantic.danger}",
        selection_foreground = "${semantic.selectionForeground}",
        selection_background = "${semantic.selectionBackground}",
        string = "${semantic.string}",
        ["function"] = "${semantic.function}",
        keyword = "${semantic.keyword}",
        number = "${semantic.number}",
        type = "${semantic.type}",
        builtin = "${semantic.builtin}",
        preprocessor = "${semantic.preprocessor}",
        comment = "${semantic.comment}",
        terminal = {
          black = "${terminal.black}",
          bright_black = "${terminal.brightBlack}",
          red = "${terminal.red}",
          bright_red = "${terminal.brightRed}",
          green = "${terminal.green}",
          bright_green = "${terminal.brightGreen}",
          yellow = "${terminal.yellow}",
          bright_yellow = "${terminal.brightYellow}",
          blue = "${terminal.blue}",
          bright_blue = "${terminal.brightBlue}",
          magenta = "${terminal.magenta}",
          bright_magenta = "${terminal.brightMagenta}",
          cyan = "${terminal.cyan}",
          bright_cyan = "${terminal.brightCyan}",
          white = "${terminal.white}",
          bright_white = "${terminal.brightWhite}",
        },
      }

      local sky_nvim = vim.fn.expand("~/.config/sky-nvim")
      if vim.fn.isdirectory(sky_nvim) == 1 then
        vim.opt.runtimepath:prepend(sky_nvim)
      end

      local ok_sky, sky = pcall(require, "sky")
      if ok_sky then
        sky.setup()
      else
        vim.notify("Sky live config unavailable: " .. tostring(sky), vim.log.levels.WARN, { title = "Neovim" })
      end

      local ok, err = pcall(vim.cmd.colorscheme, "sky")
      if not ok then
        vim.notify("Sky colorscheme unavailable: " .. tostring(err), vim.log.levels.WARN, { title = "Theme" })
      end
    '';
  };

  qmlImportPaths = [
    "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    "${pkgs.quickshell}/lib/qt-6/qml"
  ];
  qmlImportArgs = lib.concatMapStringsSep " " (path: "-I ${lib.escapeShellArg path}") qmlImportPaths;
in
{
  xdg.configFile."sky-nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/nvim";

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        startPlugins = [
          pkgs.vimPlugins.friendly-snippets
          (pkgs.runCommand "nvim-local-snippets" { } ''
            mkdir -p $out/after/snippets/lua
            cat > $out/after/snippets/lua/lua.json <<'EOF'
            {
              "require": {
                "prefix": ["req", "require"],
                "body": ["require(''${1:module})$0"],
                "description": "Require module"
              }
            }
            EOF
          '')
        ];

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
          languages = [ "en_us" ];
        };

        lsp = {
          enable = true;
          formatOnSave = false;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = false;
          lspSignature.enable = false;
          otter-nvim.enable = false;
          nvim-docs-view.enable = false;
          presets.harper.enable = true;
          servers.qmlls = {
            cmd = lib.mkForce [
              "${pkgs.writeShellScriptBin "qmlls-wrapped" ''
                exec ${pkgs.qt6.qtdeclarative}/bin/qmlls ${qmlImportArgs} "$@"
              ''}/bin/qmlls-wrapped"
            ];
            root_markers = lib.mkForce [
              ".qmlls.ini"
              "qmldir"
              ".git"
            ];
          };
        };

        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        theme.enable = false;

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
        mini = {
          icons.enable = true;
          ai.enable = true;
          files.enable = true;
          snippets = {
            enable = true;
            setupOpts.snippets = mkLuaInline ''
              {
                require("mini.snippets").gen_loader.from_lang(),
              }
            '';
          };
        };

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
          setupOpts = {
            snippets.preset = "mini_snippets";
            sources = {
              default = lib.mkForce [
                "snippets"
                "lsp"
                "path"
                "buffer"
              ];
              providers = {
                snippets.score_offset = 100;
                lsp.score_offset = 0;
                path.score_offset = -5;
                buffer.score_offset = -10;
              };
            };
            completion = {
              documentation = {
                auto_show = true;
                auto_show_delay_ms = 400;
              };
              ghost_text.enabled = true;
              list.selection = {
                preselect = false;
                auto_insert = true;
              };
            };
            cmdline = {
              keymap = {
                preset = "none";
                "<C-Space>" = [
                  "show"
                  "fallback"
                ];
                "<C-e>" = [
                  "cancel"
                  "fallback"
                ];
                "<C-j>" = [
                  "select_next"
                  "fallback"
                ];
                "<C-k>" = [
                  "select_prev"
                  "fallback"
                ];
                "<C-l>" = [
                  "accept"
                  "fallback"
                ];
                "<Tab>" = [
                  "select_next"
                  "fallback"
                ];
                "<S-Tab>" = [
                  "select_prev"
                  "fallback"
                ];
                "<Up>" = [
                  "select_prev"
                  "fallback"
                ];
                "<Down>" = [
                  "select_next"
                  "fallback"
                ];
                "<CR>" = [ "fallback" ];
              };
              completion = {
                list.selection = {
                  preselect = false;
                  auto_insert = false;
                };
                menu.auto_show = true;
              };
            };
            signature.enabled = true;
            fuzzy.implementation = "prefer_rust_with_warning";
            keymap = lib.mkForce {
              preset = "none";
              "<C-Space>" = [
                "show"
                "fallback"
              ];
              "<C-d>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-e>" = [
                "hide"
                "fallback"
              ];
              "<C-f>" = [
                "scroll_documentation_down"
                "fallback"
              ];
              "<C-j>" = [
                "select_next"
                "fallback"
              ];
              "<C-k>" = [
                "select_prev"
                "fallback"
              ];
              "<C-l>" = [
                "select_and_accept"
                "fallback"
              ];
              "<CR>" = [
                "accept"
                "fallback"
              ];
              "<Tab>" = [
                "select_next"
                "snippet_forward"
                "fallback"
              ];
              "<S-Tab>" = [
                "select_prev"
                "snippet_backward"
                "fallback"
              ];
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
        };
        snippets.luasnip.enable = false;
        filetree.neo-tree.enable = false;
        tabline.nvimBufferline.enable = true;

        # Added explicit treesitter block to help NixOS healthcheck
        treesitter = {
          enable = true;
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
          cheatsheet.enable = false;
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
          leetcode-nvim.enable = false;
          multicursors.enable = true;
          smart-splits = {
            enable = true;
            setupOpts.multiplexer_integration = mkLuaInline ''vim.env.TMUX and "tmux" or nil'';
          };
          undotree.enable = true;
          nvim-biscuits.enable = true;
          grug-far-nvim.enable = true;

          motion = {
            hop.enable = false;
            leap.enable = true;
            precognition.enable = true;
          };

          images = {
            image-nvim.enable = false;
            img-clip.enable = false;
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
          noice.enable = false;
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
                      dashboard.button("e", "  Files", "<cmd>lua require('mini.files').open(vim.uv.cwd(), true)<cr>"),
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
        fzf-lua.enable = false;
        telescope.enable = true;
        autopairs.nvim-autopairs.enable = true;
        lazy.enable = true;
      };
    };
  };
}
