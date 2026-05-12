{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";

    settings = {
      background_opacity = "0.90";
      scrollback_lines = 10000;
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      cursor_trail = 10;
      repaint_delay = 10;
      hide_window_decorations = "yes";
      shell_integration = "enabled";
      allow_remote_control = "yes";
      window_padding_width = 10;
    };

    font = {
      name = "MesloLGS Nerd Font Mono";
      size = 16;
    };
  };
}
