local M = {}

local function recover_hyprland_signature()
  if vim.env.HYPRLAND_INSTANCE_SIGNATURE and vim.env.HYPRLAND_INSTANCE_SIGNATURE ~= "" then
    return
  end

  if not vim.env.XDG_RUNTIME_DIR then
    return
  end

  local hypr_runtime = vim.env.XDG_RUNTIME_DIR .. "/hypr"
  local newest_signature = nil
  local newest_mtime = 0

  local ok, iter = pcall(vim.fs.dir, hypr_runtime)
  if not ok or not iter then
    return
  end

  for name, kind in iter do
    if kind == "directory" then
      local stat = vim.uv.fs_stat(hypr_runtime .. "/" .. name)
      if stat and stat.mtime and stat.mtime.sec > newest_mtime then
        newest_signature = name
        newest_mtime = stat.mtime.sec
      end
    end
  end

  if newest_signature then
    vim.env.HYPRLAND_INSTANCE_SIGNATURE = newest_signature
  end
end

local function configure_tmux_splits()
  if vim.env.TMUX then
    vim.g.smart_splits_multiplexer_integration = "tmux"
  end
end

function M.setup()
  recover_hyprland_signature()
  configure_tmux_splits()
end

return M
