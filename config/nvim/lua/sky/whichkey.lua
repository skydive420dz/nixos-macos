local M = {}

function M.setup()
  local ok_which_key, which_key = pcall(require, "which-key")
  if not ok_which_key then
    return
  end

  which_key.add({
    { "g", group = "󰁔 Go / LSP" },
    { "gd", desc = "Go to definition" },
    { "gD", desc = "Go to declaration" },
    { "gi", desc = "Go to implementation" },
    { "gr", group = "󰁔 LSP actions" },
    { "<leader>b", group = "󰓩 Buffers" },
    { "<leader>bm", group = "󰁌 Move Buffer" },
    { "<leader>bs", group = "󰒺 Sort Buffers" },
    { "<leader>d", group = " Debug" },
    { "<leader>dg", group = "󰆹 Debug Step" },
    { "<leader>dv", group = "󰕮 Debug Stack" },
    { "<leader>f", group = "󰱼 Find" },
    { "<leader>fl", group = " LSP Search" },
    { "<leader>fv", group = " Git Search" },
    { "<leader>fvc", group = "󰜘 Commits" },
    { "<leader>g", group = " Git / Diff" },
    { "<leader>i", group = "󰀻 Insert / Media" },
    { "<leader>l", group = " LSP / Code" },
    { "<leader>lg", group = "󰁔 LSP Go" },
    { "<leader>lt", group = "󰔡 LSP Toggles" },
    { "<leader>lw", group = "󰖲 Workspace" },
    { "<leader>m", group = "󰯈 Multicursor" },
    { "<leader>mc", group = "󰯈 Multicursor" },
    { "<leader>p", group = "󰐃 Plugins / Toggles" },
    { "<leader>q", group = "󰗼 Quit / Write" },
    { "<leader>r", group = "󰑕 Replace" },
    { "<localleader>r", group = " Rust" },
    { "<leader>S", group = "󰆓 Sessions" },
    { "<leader>s", group = "󰿅 Seek / Leap" },
    { "<leader>t", group = " Terminal / Tabs / Tools" },
    { "<leader>td", group = " Todos" },
    { "<leader>w", group = "󰖲 Windows" },
    { "<leader><leader>", group = "󰘳 Quick Actions" },
    { "<leader>z", group = "󰓆 Spelling" },
  })
end

return M
