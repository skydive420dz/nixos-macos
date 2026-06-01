local M = {}

function M.setup()
  local yank_highlight_group = vim.api.nvim_create_augroup("UserYankHighlight", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = yank_highlight_group,
    desc = "Highlight yanked text",
    callback = function()
      vim.hl.on_yank()
    end,
  })

  local markdown_navigation_group = vim.api.nvim_create_augroup("UserMarkdownNavigation", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = markdown_navigation_group,
    pattern = "markdown",
    callback = function(event)
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevel = 99

      if vim.treesitter and vim.treesitter.foldexpr then
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      else
        vim.opt_local.foldmethod = "indent"
      end

      local link_target_pattern = [=[\[[^]]\+\](\zs[^)]\+)]=]

      local function jump_link(flags)
        return function()
          local found = vim.fn.search(link_target_pattern, flags)
          if found == 0 then
            vim.notify("No markdown link found", vim.log.levels.INFO, { title = "Markdown" })
          end
        end
      end

      local opts = { buffer = event.buf, silent = true }
      vim.keymap.set("n", "]u", jump_link("W"), vim.tbl_extend("force", opts, { desc = "Next markdown link" }))
      vim.keymap.set("n", "[u", jump_link("bW"), vim.tbl_extend("force", opts, { desc = "Previous markdown link" }))
    end,
  })
end

return M
