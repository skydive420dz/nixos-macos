{ pkgs, ... }:

let
  yaziConfig = ../../../config/yazi;
  theme = import ../../../config/theme/tokens.nix;
  colors = theme.palette;
  semantic = theme.semantic;

  tokenizedTheme =
    builtins.replaceStrings
      [
        "#f5e0dc"
        "#f2cdcd"
        "#f5c2e7"
        "#cba6f7"
        "#f38ba8"
        "#eba0ac"
        "#fab387"
        "#f9e2af"
        "#a6e3a1"
        "#94e2d5"
        "#89dceb"
        "#74c7ec"
        "#89b4fa"
        "#b4befe"
        "#cdd6f4"
        "#bac2de"
        "#a6adc8"
        "#9399b2"
        "#7f849c"
        "#6c7086"
        "#585b70"
        "#45475a"
        "#313244"
        "#1e1e2e"
        "#181825"
        "#11111b"
        "#ffffff"
      ]
      [
        colors.rosewater
        colors.flamingo
        colors.pink
        colors.mauve
        semantic.danger
        colors.maroon
        colors.peach
        semantic.warning
        semantic.success
        colors.teal
        colors.sky
        colors.sapphire
        semantic.borderActive
        semantic.accent
        semantic.foreground
        colors.subtext1
        colors.subtext0
        colors.overlay2
        colors.overlay1
        semantic.muted
        colors.surface2
        semantic.surfaceStrong
        semantic.surface
        semantic.background
        colors.mantle
        colors.crust
        semantic.foreground
      ]
      (builtins.readFile "${yaziConfig}/theme.toml");
in
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableZshIntegration = true;
    shellWrapperName = "y";

    extraPackages = with pkgs; [
      fd
      ffmpegthumbnailer
      jq
      ouch
      poppler
      ripgrep
    ];

    settings = builtins.fromTOML (builtins.readFile "${yaziConfig}/yazi.toml");
    keymap = builtins.fromTOML (builtins.readFile "${yaziConfig}/keymap.toml");
    theme = builtins.fromTOML tokenizedTheme;

    plugins = {
      smart-enter = "${yaziConfig}/plugins/smart-enter.yazi";
      ouch = "${yaziConfig}/plugins/ouch.yazi";
    };
  };
}
