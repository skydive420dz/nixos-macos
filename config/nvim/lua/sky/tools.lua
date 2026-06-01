local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>pt", "<cmd>Precognition toggle<cr>", { desc = "Toggle Hints" })

  vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
  vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
  vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })

  vim.keymap.set("n", "<leader>rr", "<cmd>GrugFar<cr>", { desc = "Replace in project" })
  vim.keymap.set("n", "<leader>rw", "<cmd>GrugFarWithin<cr>", { desc = "Replace in scope" })
  vim.keymap.set("x", "<leader>rw", ":GrugFarWithin<cr>", { desc = "Replace selection" })

  vim.keymap.set("n", "<leader>in", "<cmd>IconPickerNormal<cr>", { desc = "Pick icon" })
  vim.keymap.set("n", "<leader>ii", "<cmd>IconPickerInsert<cr>", { desc = "Insert icon" })
  vim.keymap.set("n", "<leader>iy", "<cmd>IconPickerYank<cr>", { desc = "Yank icon" })
  vim.keymap.set("n", "<leader>ip", "<cmd>PasteImage<cr>", { desc = "Paste image" })

  vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<cr>", { desc = "Lazy" })
  vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
  vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal terminal" })
  vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Vertical terminal" })
  vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
end

return M
