local M = {}

local modules = {
  "options",
  "autocmds",
  "environment",
  "diagnostics",
  "commands",
  "spelling",
  "files",
  "windows",
  "formatting",
  "lsp",
  "tools",
  "whichkey",
  "completion",
}

function M.setup()
  for _, name in ipairs(modules) do
    local ok, mod = pcall(require, "sky." .. name)
    if ok and type(mod.setup) == "function" then
      mod.setup()
    elseif not ok then
      vim.notify("Sky module unavailable: " .. name .. ": " .. tostring(mod), vim.log.levels.WARN, { title = "Neovim" })
    end
  end
end

return M
