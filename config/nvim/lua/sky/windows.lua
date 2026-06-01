local M = {}

local function smart_resize(method, fallback)
  return function()
    local ok, splits = pcall(require, "smart-splits")
    if ok and type(splits[method]) == "function" then
      splits[method]()
      return
    end

    vim.cmd(fallback)
  end
end

function M.setup()
  vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
  vim.keymap.set("n", "<leader>bN", "<cmd>enew<cr>", { desc = "󰈔 New buffer" })
  vim.keymap.set("n", "<leader>bx", "<cmd>bdelete<cr>", { desc = "󰅖 Close buffer" })

  vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "󰓩 New tab" })
  vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "󰅖 Close tab" })
  vim.keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "󰝤 Only tab" })

  vim.keymap.set("n", "<Left>", smart_resize("resize_left", "vertical resize -2"), { desc = "󰁍 Resize left" })
  vim.keymap.set("n", "<Down>", smart_resize("resize_down", "resize +2"), { desc = "󰁅 Resize down" })
  vim.keymap.set("n", "<Up>", smart_resize("resize_up", "resize -2"), { desc = "󰁝 Resize up" })
  vim.keymap.set("n", "<Right>", smart_resize("resize_right", "vertical resize +2"), { desc = "󰁔 Resize right" })

  vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "󰤻 Vertical split" })
  vim.keymap.set("n", "<leader>ws", "<cmd>split<cr>", { desc = "󰤼 Horizontal split" })
  vim.keymap.set("n", "<leader>wx", "<cmd>close<cr>", { desc = "󰅖 Close window" })
  vim.keymap.set("n", "<leader>wo", "<cmd>only<cr>", { desc = "󰝤 Only window" })
  vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "󰇽 Equalize windows" })

  vim.keymap.set("n", "<leader><leader>w", "<cmd>write<cr>", { desc = "󰆓 Write file" })
  vim.keymap.set("n", "<leader>qq", "<cmd>quit<cr>", { desc = "󰗼 Quit" })
  vim.keymap.set("n", "<leader>qa", "<cmd>quitall<cr>", { desc = "󰩈 Quit all" })
  vim.keymap.set("n", "<leader>qw", "<cmd>wquit<cr>", { desc = "󰆓 Write and quit" })
  vim.keymap.set("n", "<leader>qf", "<cmd>quit!<cr>", { desc = "󰜺 Force quit" })
end

return M
