local M = {}

function M.setup()
  vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
  vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

  vim.opt.clipboard = "unnamedplus"
  vim.opt.autoindent = true
  vim.opt.smartindent = true
  vim.cmd("filetype plugin indent on")

  local undo_dir = vim.fn.stdpath("state") .. "/undo"
  vim.fn.mkdir(undo_dir, "p")
  vim.opt.undofile = true
  vim.opt.undodir = undo_dir .. "//"
  vim.opt.undolevels = 10000
  vim.opt.undoreload = 10000

  vim.opt.spell = true
  vim.opt.spelllang = { "en_us" }
end

return M
