let
  theme = import ../../../config/theme/tokens.nix;
  colors = theme.palette;
  semantic = theme.semantic;
  terminal = theme.terminal;
in
{
  programs.kitty = {
    enable = true;

    settings = {
      background_opacity = "0.90";
      remember_window_size = "no";
      initial_window_width = 9999;
      initial_window_height = 9999;
      scrollback_lines = 10000;
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      cursor_trail = 10;
      cursor_trail_decay = "0.2 0.6";
      cursor_trail_color = "yellow";
      repaint_delay = 10;
      hide_window_decorations = "yes";
      shell_integration = "enabled";
      allow_remote_control = "yes";
      window_padding_width = 10;

      foreground = semantic.foreground;
      background = semantic.background;
      selection_foreground = semantic.selectionForeground;
      selection_background = semantic.selectionBackground;

      cursor = colors.rosewater;
      cursor_text_color = semantic.selectionForeground;
      url_color = colors.rosewater;

      active_border_color = semantic.accent;
      inactive_border_color = semantic.muted;
      bell_border_color = semantic.warning;

      active_tab_foreground = colors.crust;
      active_tab_background = semantic.accentAlt;
      inactive_tab_foreground = semantic.foreground;
      inactive_tab_background = colors.mantle;
      tab_bar_background = colors.crust;

      color0 = terminal.black;
      color8 = terminal.brightBlack;
      color1 = terminal.red;
      color9 = terminal.brightRed;
      color2 = terminal.green;
      color10 = terminal.brightGreen;
      color3 = terminal.yellow;
      color11 = terminal.brightYellow;
      color4 = terminal.blue;
      color12 = terminal.brightBlue;
      color5 = terminal.magenta;
      color13 = terminal.brightMagenta;
      color6 = terminal.cyan;
      color14 = terminal.brightCyan;
      color7 = terminal.white;
      color15 = terminal.brightWhite;
    };

    font = {
      name = "MesloLGS Nerd Font Mono";
      size = 16;
    };
  };

  xdg.configFile."kitty/macos-launch-services-cmdline".text = ''
    --start-as=maximized
  '';
}
