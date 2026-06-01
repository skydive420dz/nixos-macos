local M = {}

local function mini_files_open(path)
  return function()
    local ok, files = pcall(require, "mini.files")
    if not ok then
      vim.notify("mini.files is not available", vim.log.levels.WARN, { title = "Files" })
      return
    end

    files.open(path(), true)
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>e", mini_files_open(function()
    local current = vim.api.nvim_buf_get_name(0)
    return current ~= "" and current or vim.uv.cwd()
  end), { desc = "Open MiniFiles" })

  vim.keymap.set("n", "<leader>E", mini_files_open(function()
    return vim.uv.cwd()
  end), { desc = "Open MiniFiles cwd" })

  vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })
end

return M
