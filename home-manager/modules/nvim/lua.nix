{
  theme,
  semantic,
}:

{
  themeTokens = ''
    local theme_tokens = {
      name = "${theme.name}",
      foreground = "${semantic.foreground}",
      background = "${semantic.background}",
      surface = "${semantic.surface}",
      border = "${semantic.border}",
      border_active = "${semantic.borderActive}",
      accent = "${semantic.accent}",
      accent_alt = "${semantic.accentAlt}",
      muted = "${semantic.muted}",
      warning = "${semantic.warning}",
    }

    vim.g.theme_tokens = theme_tokens

    local function apply_theme_token_highlights()
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = theme_tokens.accent })
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = theme_tokens.background })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = theme_tokens.border_active, bg = theme_tokens.background })
      vim.api.nvim_set_hl(0, "WhichKey", { fg = theme_tokens.accent })
      vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = theme_tokens.accent_alt })
      vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = theme_tokens.foreground })
      vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = theme_tokens.muted })

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "EndOfBuffer",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeEndOfBuffer",
      }

      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE" })
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = apply_theme_token_highlights,
    })
    apply_theme_token_highlights()
  '';

  navigation = ''
    -- Health check path fixes
    vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
    vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

    -- Clipboard fix
    vim.opt.clipboard = 'unnamedplus'

    -- Neovim terminals inherit from the Neovim process, so recover the
    -- Hyprland instance when Neovim starts from a stale environment.
    if (vim.env.HYPRLAND_INSTANCE_SIGNATURE == nil or vim.env.HYPRLAND_INSTANCE_SIGNATURE == "") and vim.env.XDG_RUNTIME_DIR then
      local hypr_runtime = vim.env.XDG_RUNTIME_DIR .. "/hypr"
      local newest_signature = nil
      local newest_mtime = 0

      local ok, iter = pcall(vim.fs.dir, hypr_runtime)
      if ok and iter then
        for name, kind in iter do
          if kind == "directory" then
            local stat = vim.uv.fs_stat(hypr_runtime .. "/" .. name)
            if stat and stat.mtime and stat.mtime.sec > newest_mtime then
              newest_signature = name
              newest_mtime = stat.mtime.sec
            end
          end
        end
      end

      if newest_signature then
        vim.env.HYPRLAND_INSTANCE_SIGNATURE = newest_signature
      end
    end

    -- Smart-splits should talk to tmux when Neovim is running inside tmux.
    if vim.env.TMUX then
      vim.g.smart_splits_multiplexer_integration = "tmux"
    end

    local function smart_move(method, fallback)
      return function()
        local ok, splits = pcall(require, "smart-splits")
        if ok and type(splits[method]) == "function" then
          splits[method]()
          return
        end

        vim.cmd("wincmd " .. fallback)
      end
    end

    local neo_tree_navigation_group = vim.api.nvim_create_augroup("UserNeoTreeNavigation", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = neo_tree_navigation_group,
      pattern = "neo-tree",
      callback = function(event)
        local function opts(desc)
          return { buffer = event.buf, silent = true, desc = desc }
        end

        vim.keymap.set("n", "<C-h>", smart_move("move_cursor_left", "h"), opts("Move left"))
        vim.keymap.set("n", "<C-j>", smart_move("move_cursor_down", "j"), opts("Move down"))
        vim.keymap.set("n", "<C-k>", smart_move("move_cursor_up", "k"), opts("Move up"))
        vim.keymap.set("n", "<C-l>", smart_move("move_cursor_right", "l"), opts("Move right"))
      end,
    })

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

    -- Pane and Neo-tree navigation
    vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Toggle Neo-tree" })
    vim.keymap.set("n", "<leader>E", "<cmd>Neotree reveal_force_cwd<cr>", { desc = "Focus Neo-tree" })

    -- Navigation Hints Toggle
    vim.keymap.set("n", "<leader>pt", "<cmd>Precognition toggle<cr>", { desc = "Toggle Hints" })
    vim.keymap.set("n", "<leader>pc", function()
      local ok, context = pcall(require, "treesitter-context")
      if ok then
        context.toggle()
      end
    end, { desc = "Toggle Context" })

    -- Trouble Diagnostics Toggle
    vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
  '';
}
