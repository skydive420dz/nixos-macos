local M = {}

local function lsp_clients_for_buffer()
  return vim.lsp.get_clients({ bufnr = 0 })
end

local function lsp_info()
  local lines = { "LSP clients for current buffer:", "" }
  local clients = lsp_clients_for_buffer()

  if #clients == 0 then
    table.insert(lines, "  none")
  else
    for _, client in ipairs(clients) do
      local root = client.config and client.config.root_dir or "--"
      local cmd = client.config and client.config.cmd or {}
      table.insert(lines, ("  %s (id: %s)"):format(client.name, client.id))
      table.insert(lines, ("    root: %s"):format(root or "--"))
      table.insert(lines, ("    cmd: %s"):format(table.concat(cmd, " ")))
      table.insert(lines, ("    definition: %s"):format(tostring(client.server_capabilities.definitionProvider)))
      table.insert(lines, ("    document symbols: %s"):format(tostring(client.server_capabilities.documentSymbolProvider)))
      table.insert(lines, "")
    end
  end

  vim.cmd("botright new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function lsp_restart()
  local clients = lsp_clients_for_buffer()
  if #clients == 0 then
    vim.notify("No LSP clients attached to this buffer", vim.log.levels.INFO, { title = "LSP" })
    return
  end

  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id, true)
  end

  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(0) then
      vim.cmd("edit")
    end
  end, 300)
end

function M.setup()
  vim.api.nvim_create_user_command("LspInfo", lsp_info, { desc = "Show LSP clients for the current buffer" })
  vim.api.nvim_create_user_command("LspRestart", lsp_restart, { desc = "Restart LSP clients for the current buffer" })
  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("edit " .. vim.fn.fnameescape(vim.lsp.get_log_path()))
  end, { desc = "Open the Neovim LSP log" })
end

return M
