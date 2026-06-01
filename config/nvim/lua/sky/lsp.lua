local M = {}

local function open_navbuddy()
  local ok, navbuddy = pcall(require, "nvim-navbuddy")
  if ok then
    navbuddy.open()
  else
    vim.notify("nvim-navbuddy is not available", vim.log.levels.WARN, { title = "LSP" })
  end
end

local function code_action()
  local ok, fastaction = pcall(require, "fastaction")
  if ok then
    fastaction.code_action()
  else
    vim.lsp.buf.code_action()
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(event)
      local opts = { buffer = event.buf, silent = true }
      vim.keymap.set("n", "<leader>ln", open_navbuddy, vim.tbl_extend("force", opts, { desc = "Navbuddy" }))
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
      vim.keymap.set({ "n", "x" }, "<leader>la", code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
      vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
    end,
  })
end

return M
