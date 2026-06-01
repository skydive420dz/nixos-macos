local M = {}

local skip_filetypes = {
  markdown = true,
  org = true,
  text = true,
}

local function should_format(bufnr)
  return vim.bo[bufnr].buftype == "" and vim.bo[bufnr].modifiable and not skip_filetypes[vim.bo[bufnr].filetype]
end

local function format_buffer(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local async = opts.async ~= false

  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ bufnr = bufnr, async = async, lsp_format = "fallback", timeout_ms = 1000 })
  else
    vim.lsp.buf.format({ bufnr = bufnr, async = async, timeout_ms = 1000 })
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("SkyFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    desc = "Format code buffers before saving",
    callback = function(event)
      if should_format(event.buf) then
        format_buffer({ bufnr = event.buf, async = false })
      end
    end,
  })

  vim.keymap.set("n", "<leader>lf", function()
    format_buffer({ async = true })
  end, { desc = "Format buffer" })
  vim.keymap.set("n", "<leader>lF", "<cmd>ConformInfo<cr>", { desc = "Conform info" })
end

return M
