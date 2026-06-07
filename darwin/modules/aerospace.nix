{ ... }:

{
  services.aerospace = {
    enable = true;

    settings = {
      config-version = 2;
      start-at-login = false;
      automatically-unhide-macos-hidden-apps = true;

      after-startup-command = [
        "layout accordion"
      ];

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = false;
      default-root-container-layout = "accordion";
      default-root-container-orientation = "horizontal";
      accordion-padding = 1;

      gaps = {
        inner = {
          horizontal = 1;
          vertical = 1;
        };
        outer = {
          left = 1;
          right = 1;
          top = 1;
          bottom = 1;
        };
      };

      key-mapping.preset = "qwerty";

      on-focused-monitor-changed = [
        "move-mouse monitor-lazy-center"
      ];

      on-window-detected = [
        {
          "if".app-name-regex-substring = "Finder|System Settings|Activity Monitor|Calculator";
          run = "layout floating";
        }
      ];

      mode.main.binding = {
        ctrl-alt-enter = "exec-and-forget open -na kitty";
        ctrl-alt-t = "exec-and-forget open -na Emacs";
        ctrl-alt-v = "exec-and-forget open -na 'Visual Studio Code'";
        ctrl-alt-b = "exec-and-forget open -na Safari";

        ctrl-alt-h = "focus left";
        ctrl-alt-j = "focus down";
        ctrl-alt-k = "focus up";
        ctrl-alt-l = "focus right";

        ctrl-alt-shift-h = "move left";
        ctrl-alt-shift-j = "move down";
        ctrl-alt-shift-k = "move up";
        ctrl-alt-shift-l = "move right";

        ctrl-alt-minus = "resize smart -50";
        ctrl-alt-equal = "resize smart +50";

        ctrl-alt-f = "fullscreen";
        ctrl-alt-space = "layout floating tiling";
        ctrl-alt-slash = "layout tiles horizontal vertical";
        ctrl-alt-comma = "layout accordion horizontal vertical";

        ctrl-alt-1 = "workspace 1";
        ctrl-alt-2 = "workspace 2";
        ctrl-alt-3 = "workspace 3";
        ctrl-alt-4 = "workspace 4";
        ctrl-alt-5 = "workspace 5";
        ctrl-alt-6 = "workspace 6";
        ctrl-alt-7 = "workspace 7";
        ctrl-alt-8 = "workspace 8";
        ctrl-alt-9 = "workspace 9";

        ctrl-alt-shift-1 = [
          "move-node-to-workspace 1"
          "workspace 1"
        ];
        ctrl-alt-shift-2 = [
          "move-node-to-workspace 2"
          "workspace 2"
        ];
        ctrl-alt-shift-3 = [
          "move-node-to-workspace 3"
          "workspace 3"
        ];
        ctrl-alt-shift-4 = [
          "move-node-to-workspace 4"
          "workspace 4"
        ];
        ctrl-alt-shift-5 = [
          "move-node-to-workspace 5"
          "workspace 5"
        ];
        ctrl-alt-shift-6 = [
          "move-node-to-workspace 6"
          "workspace 6"
        ];
        ctrl-alt-shift-7 = [
          "move-node-to-workspace 7"
          "workspace 7"
        ];
        ctrl-alt-shift-8 = [
          "move-node-to-workspace 8"
          "workspace 8"
        ];
        ctrl-alt-shift-9 = [
          "move-node-to-workspace 9"
          "workspace 9"
        ];

        ctrl-alt-semicolon = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];
      };
    };
  };
}
