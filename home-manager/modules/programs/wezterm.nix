{ lib, pkgs, ... }:

let
  theme = import ../../../config/theme/tokens.nix;
  inherit (theme) palette terminal;
in
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      font = lib.generators.mkLuaInline ''wezterm.font("MesloLGS Nerd Font")'';
      font_dirs = [ "${pkgs.nerd-fonts.meslo-lg}/share/fonts/truetype/NerdFonts/MesloLG" ];
      font_size = 16;

      colors = {
        foreground = palette.fg;
        background = palette.bg;
        selection_fg = palette.bg;
        selection_bg = palette.cyan;
        cursor_fg = palette.bg;
        cursor_bg = palette.cyan;
        cursor_border = palette.cyan;
        split = palette.base4;
        ansi = with terminal; [
          black
          red
          green
          yellow
          blue
          magenta
          cyan
          white
        ];
        brights = with terminal; [
          brightBlack
          brightRed
          brightGreen
          brightYellow
          brightBlue
          brightMagenta
          brightCyan
          brightWhite
        ];
        tab_bar = {
          background = palette.bg;
          active_tab = {
            bg_color = palette.bgAlt;
            fg_color = palette.fg;
          };
          inactive_tab = {
            bg_color = palette.bg;
            fg_color = palette.fgAlt;
          };
          inactive_tab_hover = {
            bg_color = palette.base3;
            fg_color = palette.fg;
          };
        };
      };

      alternate_buffer_wheel_scroll_speed = 5;
      scrollback_lines = 10000000;
      window_decorations = "RESIZE";
      window_padding = {
        left = 10;
        right = 10;
        top = 10;
        bottom = 10;
      };
      hide_tab_bar_if_only_one_tab = true;
      use_fancy_tab_bar = false;
      show_new_tab_button_in_tab_bar = false;
      quit_when_all_windows_are_closed = false;
      window_close_confirmation = "AlwaysPrompt";
    };

    extraConfig = ''
      local act = wezterm.action

      config:set_strict_mode(true)

      local function activate_pane_or_send_key(direction, key)
        return wezterm.action_callback(function(window, pane)
          if pane:tab():get_pane_direction(direction) then
            window:perform_action(act.ActivatePaneDirection(direction), pane)
          else
            window:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
          end
        end)
      end

      local copy_and_clear = act.Multiple {
        act.CopyTo 'Clipboard',
        act.ClearSelection,
      }

      config.leader = { key = 'Space', mods = 'ALT', timeout_milliseconds = 1000 }
      config.keys = {
        { key = 'Enter', mods = 'ALT', action = act.SpawnWindow },
        { key = 'h', mods = 'CTRL', action = activate_pane_or_send_key('Left', 'h') },
        { key = 'j', mods = 'CTRL', action = activate_pane_or_send_key('Down', 'j') },
        { key = 'k', mods = 'CTRL', action = activate_pane_or_send_key('Up', 'k') },
        { key = 'l', mods = 'CTRL', action = activate_pane_or_send_key('Right', 'l') },
        { key = 'LeftArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Left', 5 } },
        { key = 'DownArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Down', 5 } },
        { key = 'UpArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Up', 5 } },
        { key = 'RightArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Right', 5 } },
        { key = 'z', mods = 'ALT', action = act.TogglePaneZoomState },
        { key = '<', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
        { key = 'c', mods = 'CMD', action = copy_and_clear },
        { key = 'C', mods = 'CTRL|SHIFT', action = copy_and_clear },

        { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
        { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
        { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },
        { key = 'q', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
        { key = 'v', mods = 'LEADER', action = act.SplitPane { direction = 'Right' } },
        { key = 's', mods = 'LEADER', action = act.SplitPane { direction = 'Down' } },
        { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
        { key = 'y', mods = 'LEADER', action = copy_and_clear },
        { key = 'p', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },
        { key = 'c', mods = 'LEADER', action = act.ActivateCopyMode },
        { key = 'LeftArrow', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
        { key = 'RightArrow', mods = 'LEADER', action = act.ActivateTabRelative(1) },
        { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
        { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
        { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
        { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
        { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
        { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
        { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
        { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
        { key = '9', mods = 'LEADER', action = act.ActivateTab(-1) },
      }
    '';
  };
}
