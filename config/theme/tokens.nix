let
  palette = rec {
    bg = "#1a1d21";
    bgAlt = "#22262b";
    base0 = "#0f1114";
    base1 = "#171a1e";
    base2 = "#1f2228";
    base3 = "#282c34";
    base4 = "#3d424a";
    base5 = "#515761";
    base6 = "#676d77";
    base7 = "#8b919a";
    base8 = "#e0dcd4";
    fg = "#f0efeb";
    fgAlt = "#ccc4b4";
    red = "#cdacac";
    orange = "#ccc4b4";
    green = "#b8c4b8";
    blue = "#b4bcc4";
    cyan = "#b4c0c8";
    yellow = "#d4ccb4";
    teal = "#b4c4bc";
    darkCyan = "#98a4ac";

    # Compatibility aliases for modules that were originally Catppuccin-shaped.
    rosewater = fgAlt;
    flamingo = red;
    pink = fgAlt;
    mauve = fgAlt;
    maroon = red;
    peach = orange;
    sky = cyan;
    sapphire = darkCyan;
    lavender = cyan;
    text = fg;
    subtext1 = fgAlt;
    subtext0 = base8;
    overlay2 = base7;
    overlay1 = base6;
    overlay0 = base6;
    surface2 = base5;
    surface1 = base4;
    surface0 = base3;
    base = bg;
    mantle = bgAlt;
    crust = base0;
  };
in
{
  name = "SkyNight";
  source = "Compline";
  flavor = "dark";
  accent = "cyan";

  inherit palette;

  semantic = {
    foreground = palette.fg;
    foregroundAlt = palette.fgAlt;
    background = palette.bg;
    backgroundAlt = palette.bgAlt;
    surface = palette.bgAlt;
    surfaceStrong = palette.base3;
    surfaceRaised = palette.base4;
    border = palette.base4;
    borderActive = palette.cyan;
    accent = palette.cyan;
    accentAlt = palette.blue;
    success = palette.green;
    warning = palette.yellow;
    danger = palette.red;
    muted = palette.base6;
    selectionForeground = palette.bg;
    selectionBackground = palette.cyan;

    string = palette.green;
    function = palette.cyan;
    keyword = palette.blue;
    number = palette.yellow;
    type = palette.yellow;
    builtin = palette.teal;
    preprocessor = palette.fgAlt;
    comment = palette.base6;
  };

  terminal = {
    black = palette.bgAlt;
    brightBlack = palette.base4;
    red = palette.red;
    brightRed = palette.red;
    green = palette.green;
    brightGreen = palette.green;
    yellow = palette.yellow;
    brightYellow = palette.yellow;
    blue = palette.blue;
    brightBlue = palette.blue;
    magenta = palette.fgAlt;
    brightMagenta = palette.fgAlt;
    cyan = palette.cyan;
    brightCyan = palette.teal;
    white = palette.fgAlt;
    brightWhite = palette.fg;
  };
}
