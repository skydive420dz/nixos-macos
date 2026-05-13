let
  palette = {
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    overlay2 = "#9399b2";
    overlay1 = "#7f849c";
    overlay0 = "#6c7086";
    surface2 = "#585b70";
    surface1 = "#45475a";
    surface0 = "#313244";
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
  };
in
{
  name = "catppuccin-mocha";
  flavor = "mocha";
  accent = "lavender";

  inherit palette;

  semantic = {
    foreground = palette.text;
    background = palette.base;
    surface = palette.surface0;
    surfaceStrong = palette.surface1;
    border = palette.surface1;
    borderActive = palette.blue;
    accent = palette.lavender;
    accentAlt = palette.mauve;
    success = palette.green;
    warning = palette.yellow;
    danger = palette.red;
    muted = palette.overlay0;
    selectionForeground = palette.base;
    selectionBackground = palette.rosewater;
  };

  terminal = {
    black = palette.surface1;
    brightBlack = palette.surface2;
    red = palette.red;
    brightRed = palette.red;
    green = palette.green;
    brightGreen = palette.green;
    yellow = palette.yellow;
    brightYellow = palette.yellow;
    blue = palette.blue;
    brightBlue = palette.blue;
    magenta = palette.pink;
    brightMagenta = palette.pink;
    cyan = palette.teal;
    brightCyan = palette.teal;
    white = palette.subtext1;
    brightWhite = palette.subtext0;
  };
}
