local M = {}

local fallback = {
  name = "SkyNight",
  flavor = "dark",
  foreground = "#f0efeb",
  background = "#1a1d21",
  surface = "#22262b",
  surface_strong = "#282c34",
  border = "#3d424a",
  border_active = "#b4c0c8",
  accent = "#b4c0c8",
  accent_alt = "#b4bcc4",
  muted = "#676d77",
  success = "#b8c4b8",
  warning = "#d4ccb4",
  danger = "#cdacac",
  selection_foreground = "#1a1d21",
  selection_background = "#b4c0c8",
  string = "#b8c4b8",
  ["function"] = "#b4c0c8",
  keyword = "#b4bcc4",
  number = "#d4ccb4",
  type = "#d4ccb4",
  builtin = "#b4c4bc",
  preprocessor = "#ccc4b4",
  comment = "#676d77",
  terminal = {
    black = "#22262b",
    bright_black = "#3d424a",
    red = "#cdacac",
    bright_red = "#cdacac",
    green = "#b8c4b8",
    bright_green = "#b8c4b8",
    yellow = "#d4ccb4",
    bright_yellow = "#d4ccb4",
    blue = "#b4bcc4",
    bright_blue = "#b4bcc4",
    magenta = "#ccc4b4",
    bright_magenta = "#ccc4b4",
    cyan = "#b4c0c8",
    bright_cyan = "#b4c4bc",
    white = "#ccc4b4",
    bright_white = "#f0efeb",
  },
}

local function config_home()
  return vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
end

function M.load_tokens()
  if type(vim.g.sky_theme) == "table" then
    return vim.tbl_deep_extend("force", {}, fallback, vim.g.sky_theme)
  end

  local path = config_home() .. "/theme/current/nvim.lua"
  local loader = loadfile(path)

  if loader then
    local ok, tokens = pcall(loader)
    if ok and type(tokens) == "table" then
      return vim.tbl_deep_extend("force", {}, fallback, tokens)
    end
  end

  return vim.tbl_deep_extend("force", {}, fallback)
end

local function set(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function link(group, target)
  vim.api.nvim_set_hl(0, group, { link = target })
end

local function terminal_colors(c)
  local names = {
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "white",
    "bright_black",
    "bright_red",
    "bright_green",
    "bright_yellow",
    "bright_blue",
    "bright_magenta",
    "bright_cyan",
    "bright_white",
  }

  for index, name in ipairs(names) do
    vim.g["terminal_color_" .. (index - 1)] = c.terminal[name]
  end
end

local function transparent_lualine_body(c)
  set("StatusLine", { fg = c.foreground, bg = "NONE" })
  set("StatusLineNC", { fg = c.muted, bg = "NONE" })
  set("WinBar", { fg = c.foreground, bg = "NONE" })
  set("WinBarNC", { fg = c.muted, bg = "NONE" })

  for name, spec in pairs(vim.api.nvim_get_hl(0, {})) do
    if name:match("^lualine_") and not name:match("^lualine_a_") then
      local next_spec = vim.deepcopy(spec)
      next_spec.bg = "NONE"
      set(name, next_spec)
    end
  end
end

function M.apply()
  local c = M.load_tokens()

  vim.o.termguicolors = true
  vim.o.background = c.flavor == "light" and "light" or "dark"

  if vim.g.colors_name then
    vim.cmd("highlight clear")
  end

  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "sky"
  vim.g.theme_tokens = c
  terminal_colors(c)

  set("Normal", { fg = c.foreground, bg = "NONE" })
  set("NormalNC", { fg = c.foreground, bg = "NONE" })
  set("NormalFloat", { fg = c.foreground, bg = c.surface })
  set("FloatBorder", { fg = c.border_active, bg = c.surface })
  set("SignColumn", { bg = "NONE" })
  set("EndOfBuffer", { fg = c.muted, bg = "NONE" })
  set("CursorLine", { bg = c.surface_strong })
  set("CursorColumn", { bg = c.surface_strong })
  set("LineNr", { fg = c.muted, bg = "NONE" })
  set("CursorLineNr", { fg = c.accent, bold = true, bg = "NONE" })
  set("ColorColumn", { bg = c.surface })
  set("WinSeparator", { fg = c.border })
  set("VertSplit", { fg = c.border })
  set("Folded", { fg = c.muted, bg = c.surface })
  set("FoldColumn", { fg = c.muted, bg = "NONE" })
  set("NonText", { fg = c.muted })
  set("Whitespace", { fg = c.border })
  set("SpecialKey", { fg = c.muted })
  set("Directory", { fg = c.accent })
  set("Title", { fg = c.accent, bold = true })

  set("Visual", { fg = c.selection_foreground, bg = c.selection_background })
  set("Search", { fg = c.selection_foreground, bg = c.warning })
  set("IncSearch", { fg = c.selection_foreground, bg = c.accent })
  set("CurSearch", { fg = c.selection_foreground, bg = c.accent })
  set("MatchParen", { fg = c.selection_foreground, bg = c.accent_alt, bold = true })
  set("Substitute", { fg = c.selection_foreground, bg = c.accent_alt })

  set("StatusLine", { fg = c.foreground, bg = "NONE" })
  set("StatusLineNC", { fg = c.muted, bg = "NONE" })
  set("WinBar", { fg = c.foreground, bg = "NONE" })
  set("WinBarNC", { fg = c.muted, bg = "NONE" })
  set("TabLine", { fg = c.muted, bg = c.surface })
  set("TabLineSel", { fg = c.foreground, bg = c.surface_strong, bold = true })
  set("TabLineFill", { bg = "NONE" })
  set("Pmenu", { fg = c.foreground, bg = c.surface })
  set("PmenuSel", { fg = c.selection_foreground, bg = c.selection_background })
  set("PmenuSbar", { bg = c.surface_strong })
  set("PmenuThumb", { bg = c.accent })

  set("Comment", { fg = c.comment, italic = true })
  set("Constant", { fg = c.number })
  set("String", { fg = c.string })
  set("Character", { fg = c.string })
  set("Number", { fg = c.number })
  set("Boolean", { fg = c.number })
  set("Float", { fg = c.number })
  set("Identifier", { fg = c.foreground })
  set("Function", { fg = c["function"] })
  set("Statement", { fg = c.keyword })
  set("Conditional", { fg = c.keyword })
  set("Repeat", { fg = c.keyword })
  set("Label", { fg = c.keyword })
  set("Operator", { fg = c.keyword })
  set("Keyword", { fg = c.keyword })
  set("Exception", { fg = c.keyword })
  set("PreProc", { fg = c.preprocessor })
  set("Include", { fg = c.preprocessor })
  set("Define", { fg = c.preprocessor })
  set("Macro", { fg = c.preprocessor })
  set("PreCondit", { fg = c.preprocessor })
  set("Type", { fg = c.type })
  set("StorageClass", { fg = c.type })
  set("Structure", { fg = c.type })
  set("Typedef", { fg = c.type })
  set("Special", { fg = c.builtin })
  set("SpecialChar", { fg = c.builtin })
  set("Tag", { fg = c.accent })
  set("Delimiter", { fg = c.muted })
  set("Underlined", { fg = c.accent, underline = true })
  set("Bold", { bold = true })
  set("Italic", { italic = true })
  set("Todo", { fg = c.background, bg = c.warning, bold = true })
  set("Error", { fg = c.danger })

  set("@comment", { fg = c.comment, italic = true })
  set("@variable", { fg = c.foreground })
  set("@variable.builtin", { fg = c.builtin })
  set("@constant", { fg = c.number })
  set("@constant.builtin", { fg = c.builtin })
  set("@module", { fg = c.accent_alt })
  set("@property", { fg = c.foreground })
  set("@field", { fg = c.foreground })
  set("@parameter", { fg = c.foreground })
  set("@function", { fg = c["function"] })
  set("@function.builtin", { fg = c.builtin })
  set("@constructor", { fg = c.type })
  set("@keyword", { fg = c.keyword })
  set("@keyword.return", { fg = c.keyword })
  set("@keyword.operator", { fg = c.keyword })
  set("@operator", { fg = c.keyword })
  set("@string", { fg = c.string })
  set("@number", { fg = c.number })
  set("@boolean", { fg = c.number })
  set("@type", { fg = c.type })
  set("@type.builtin", { fg = c.type })
  set("@punctuation.delimiter", { fg = c.muted })
  set("@punctuation.bracket", { fg = c.muted })
  set("@tag", { fg = c.accent })
  set("@tag.attribute", { fg = c.foreground })
  set("@tag.delimiter", { fg = c.muted })

  set("DiagnosticError", { fg = c.danger })
  set("DiagnosticWarn", { fg = c.warning })
  set("DiagnosticInfo", { fg = c.accent })
  set("DiagnosticHint", { fg = c.accent_alt })
  set("DiagnosticOk", { fg = c.success })
  set("DiagnosticVirtualTextError", { fg = c.danger, bg = "NONE" })
  set("DiagnosticVirtualTextWarn", { fg = c.warning, bg = "NONE" })
  set("DiagnosticVirtualTextInfo", { fg = c.accent, bg = "NONE" })
  set("DiagnosticVirtualTextHint", { fg = c.accent_alt, bg = "NONE" })
  set("DiagnosticUnderlineError", { sp = c.danger, undercurl = true })
  set("DiagnosticUnderlineWarn", { sp = c.warning, undercurl = true })
  set("DiagnosticUnderlineInfo", { sp = c.accent, undercurl = true })
  set("DiagnosticUnderlineHint", { sp = c.accent_alt, undercurl = true })

  set("DiffAdd", { fg = c.success, bg = "NONE" })
  set("DiffChange", { fg = c.warning, bg = "NONE" })
  set("DiffDelete", { fg = c.danger, bg = "NONE" })
  set("DiffText", { fg = c.accent, bg = c.surface })
  set("GitSignsAdd", { fg = c.success, bg = "NONE" })
  set("GitSignsChange", { fg = c.warning, bg = "NONE" })
  set("GitSignsDelete", { fg = c.danger, bg = "NONE" })

  set("AlphaHeader", { fg = c.accent })
  set("WhichKeyFloat", { bg = c.surface })
  set("WhichKeyBorder", { fg = c.border_active, bg = c.surface })
  set("WhichKey", { fg = c.accent })
  set("WhichKeyGroup", { fg = c.accent_alt })
  set("WhichKeyDesc", { fg = c.foreground })
  set("WhichKeySeparator", { fg = c.muted })
  set("TelescopeNormal", { fg = c.foreground, bg = c.surface })
  set("TelescopeBorder", { fg = c.border_active, bg = c.surface })
  set("TelescopePromptNormal", { fg = c.foreground, bg = c.surface_strong })
  set("TelescopePromptBorder", { fg = c.border_active, bg = c.surface_strong })
  set("TelescopeSelection", { fg = c.foreground, bg = c.surface_strong })
  set("TelescopeMatching", { fg = c.accent, bold = true })
  set("NotifyBackground", { fg = c.foreground, bg = c.surface })
  set("NotifyERRORBorder", { fg = c.danger, bg = c.surface })
  set("NotifyWARNBorder", { fg = c.warning, bg = c.surface })
  set("NotifyINFOBorder", { fg = c.accent, bg = c.surface })
  set("NotifyDEBUGBorder", { fg = c.muted, bg = c.surface })
  set("NotifyTRACEBorder", { fg = c.accent_alt, bg = c.surface })
  set("NotifyERRORIcon", { fg = c.danger, bg = c.surface })
  set("NotifyWARNIcon", { fg = c.warning, bg = c.surface })
  set("NotifyINFOIcon", { fg = c.accent, bg = c.surface })
  set("NotifyDEBUGIcon", { fg = c.muted, bg = c.surface })
  set("NotifyTRACEIcon", { fg = c.accent_alt, bg = c.surface })
  set("NotifyERRORTitle", { fg = c.danger, bg = c.surface, bold = true })
  set("NotifyWARNTitle", { fg = c.warning, bg = c.surface, bold = true })
  set("NotifyINFOTitle", { fg = c.accent, bg = c.surface, bold = true })
  set("NotifyDEBUGTitle", { fg = c.muted, bg = c.surface, bold = true })
  set("NotifyTRACETitle", { fg = c.accent_alt, bg = c.surface, bold = true })
  set("NotifyERRORBody", { fg = c.foreground, bg = c.surface })
  set("NotifyWARNBody", { fg = c.foreground, bg = c.surface })
  set("NotifyINFOBody", { fg = c.foreground, bg = c.surface })
  set("NotifyDEBUGBody", { fg = c.foreground, bg = c.surface })
  set("NotifyTRACEBody", { fg = c.foreground, bg = c.surface })
  local bufferline_groups = {
    Fill = { bg = c.surface },
    Background = { fg = c.muted, bg = c.surface },
    Buffer = { fg = c.muted, bg = c.surface },
    BufferVisible = { fg = c.foreground, bg = c.surface },
    BufferSelected = { fg = c.foreground, bg = c.surface_strong, bold = true },
    IndicatorVisible = { fg = c.surface, bg = c.surface },
    IndicatorSelected = { fg = c.accent, bg = c.surface_strong },
    Separator = { fg = c.surface, bg = c.surface },
    SeparatorVisible = { fg = c.surface, bg = c.surface },
    SeparatorSelected = { fg = c.surface, bg = c.surface_strong },
    CloseButton = { fg = c.muted, bg = c.surface },
    CloseButtonVisible = { fg = c.foreground, bg = c.surface },
    CloseButtonSelected = { fg = c.foreground, bg = c.surface_strong },
    Modified = { fg = c.warning, bg = c.surface },
    ModifiedVisible = { fg = c.warning, bg = c.surface },
    ModifiedSelected = { fg = c.warning, bg = c.surface_strong },
    Numbers = { fg = c.muted, bg = c.surface },
    NumbersVisible = { fg = c.foreground, bg = c.surface },
    NumbersSelected = { fg = c.foreground, bg = c.surface_strong, bold = true },
    Duplicate = { fg = c.muted, bg = c.surface },
    DuplicateVisible = { fg = c.foreground, bg = c.surface },
    DuplicateSelected = { fg = c.foreground, bg = c.surface_strong },
    Diagnostic = { fg = c.muted, bg = c.surface },
    DiagnosticVisible = { fg = c.muted, bg = c.surface },
    DiagnosticSelected = { fg = c.foreground, bg = c.surface_strong, bold = true },
    Hint = { fg = c.accent_alt, bg = c.surface },
    HintVisible = { fg = c.accent_alt, bg = c.surface },
    HintSelected = { fg = c.accent_alt, bg = c.surface_strong, bold = true },
    HintDiagnostic = { fg = c.accent_alt, bg = c.surface },
    HintDiagnosticVisible = { fg = c.accent_alt, bg = c.surface },
    HintDiagnosticSelected = { fg = c.accent_alt, bg = c.surface_strong, bold = true },
    Info = { fg = c.accent, bg = c.surface },
    InfoVisible = { fg = c.accent, bg = c.surface },
    InfoSelected = { fg = c.accent, bg = c.surface_strong, bold = true },
    InfoDiagnostic = { fg = c.accent, bg = c.surface },
    InfoDiagnosticVisible = { fg = c.accent, bg = c.surface },
    InfoDiagnosticSelected = { fg = c.accent, bg = c.surface_strong, bold = true },
    Warning = { fg = c.warning, bg = c.surface },
    WarningVisible = { fg = c.warning, bg = c.surface },
    WarningSelected = { fg = c.warning, bg = c.surface_strong, bold = true },
    WarningDiagnostic = { fg = c.warning, bg = c.surface },
    WarningDiagnosticVisible = { fg = c.warning, bg = c.surface },
    WarningDiagnosticSelected = { fg = c.warning, bg = c.surface_strong, bold = true },
    Error = { fg = c.danger, bg = c.surface },
    ErrorVisible = { fg = c.danger, bg = c.surface },
    ErrorSelected = { fg = c.danger, bg = c.surface_strong, bold = true },
    ErrorDiagnostic = { fg = c.danger, bg = c.surface },
    ErrorDiagnosticVisible = { fg = c.danger, bg = c.surface },
    ErrorDiagnosticSelected = { fg = c.danger, bg = c.surface_strong, bold = true },
    Pick = { fg = c.danger, bg = c.surface, bold = true },
    PickVisible = { fg = c.danger, bg = c.surface, bold = true },
    PickSelected = { fg = c.danger, bg = c.surface_strong, bold = true },
    Tab = { fg = c.muted, bg = c.surface },
    TabSelected = { fg = c.foreground, bg = c.surface_strong, bold = true },
    TabClose = { fg = c.muted, bg = c.surface },
    TabSeparator = { fg = c.surface, bg = c.surface },
    TabSeparatorSelected = { fg = c.surface, bg = c.surface_strong },
    TruncMarker = { fg = c.muted, bg = c.surface },
    OffsetSeparator = { fg = c.surface, bg = c.surface },
    GroupLabel = { fg = c.foreground, bg = c.surface_strong },
    GroupSeparator = { fg = c.surface_strong, bg = c.surface },
  }

  for suffix, spec in pairs(bufferline_groups) do
    set("BufferLine" .. suffix, spec)
  end
  set("MiniFilesNormal", { fg = c.foreground, bg = c.surface })
  set("MiniFilesBorder", { fg = c.border_active, bg = c.surface })
  set("MiniFilesCursorLine", { bg = c.surface_strong })
  set("MiniIndentscopeSymbol", { fg = c.border_active })

  link("LspReferenceText", "Visual")
  link("LspReferenceRead", "Visual")
  link("LspReferenceWrite", "Visual")

  pcall(vim.api.nvim_del_user_command, "SkyThemeReload")
  vim.api.nvim_create_user_command("SkyThemeReload", function()
    package.loaded["sky.theme"] = nil
    require("sky.theme").apply()
  end, { desc = "Reload the active Sky Neovim theme" })

  transparent_lualine_body(c)
  vim.defer_fn(function()
    transparent_lualine_body(c)
  end, 50)
end

return M
