local M = {}

local function completion_or_snippet_next()
  local ok_cmp, cmp = pcall(require, "blink.cmp")
  if ok_cmp and cmp.is_menu_visible() then
    cmp.select_next()
    return ""
  end

  local ok_snippets = pcall(require, "mini.snippets")
  if ok_snippets and MiniSnippets.session.get() ~= nil then
    MiniSnippets.session.jump("next")
    return ""
  end

  if vim.snippet and vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  end

  return "\t"
end

local function completion_or_snippet_prev()
  local ok_cmp, cmp = pcall(require, "blink.cmp")
  if ok_cmp and cmp.is_menu_visible() then
    cmp.select_prev()
    return ""
  end

  local ok_snippets = pcall(require, "mini.snippets")
  if ok_snippets and MiniSnippets.session.get() ~= nil then
    MiniSnippets.session.jump("prev")
    return ""
  end

  if vim.snippet and vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ""
  end

  return vim.keycode("<S-Tab>")
end

function M.setup()
  -- MiniSnippets maps <C-j> to manual snippet expansion by default. Completion
  -- navigation owns <C-j>/<C-k>/<C-l>; snippets use Tab/S-Tab after expansion.
  pcall(vim.keymap.del, "i", "<C-j>")
  pcall(vim.keymap.del, "s", "<C-j>")

  vim.keymap.set({ "i", "s" }, "<Tab>", completion_or_snippet_next, { expr = true, desc = "Next completion or snippet jump" })
  vim.keymap.set({ "i", "s" }, "<S-Tab>", completion_or_snippet_prev, { expr = true, desc = "Previous completion or snippet jump" })
end

return M
