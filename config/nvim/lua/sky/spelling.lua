local M = {}

function M.setup()
  vim.keymap.set("n", "]s", "]s", { desc = "Next spelling error" })
  vim.keymap.set("n", "[s", "[s", { desc = "Previous spelling error" })
  vim.keymap.set("n", "<leader>zg", "zg", { desc = "Add word to dictionary" })
  vim.keymap.set("n", "<leader>zw", "zw", { desc = "Mark word wrong" })
  vim.keymap.set("n", "<leader>z=", "z=", { desc = "Spelling suggestions" })
end

return M
