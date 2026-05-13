{
  xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
    global = {
      check_for_updates_on_startup = false;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };

    profiles = [
      {
        name = "Default";
        selected = true;

        complex_modifications = {
          parameters = {
            "basic.simultaneous_threshold_milliseconds" = 50;
            "basic.to_delayed_action_delay_milliseconds" = 500;
            "basic.to_if_alone_timeout_milliseconds" = 1000;
            "basic.to_if_held_down_threshold_milliseconds" = 200;
            "mouse_motion_to_scroll.speed" = 100;
          };

          rules = [
            {
              description = "Caps Lock: tap Escape, hold Control+Option";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers = {
                      optional = [ "any" ];
                    };
                  };
                  to = [
                    {
                      key_code = "left_control";
                      modifiers = [ "left_option" ];
                    }
                  ];
                  to_if_alone = [
                    {
                      key_code = "escape";
                    }
                  ];
                }
              ];
            }
          ];
        };

        devices = [ ];
        fn_function_keys = [ ];
        simple_modifications = [ ];
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
      }
    ];
  };
}
