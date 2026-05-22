{
  xdg.configFile."kanata/kanata.kbd".text = ''
    ;; macOS Kanata config.
    ;; Keep this intentionally narrow: Kanata remaps Caps only.
    ;; macOS owns the function row through com.apple.keyboard.fnState:
    ;;   false -> brightness/media keys by default, hold Fn for F1-F12.
    ;; Duplicating that mapping in Kanata makes the top row drift across
    ;; different Apple keyboards and macOS releases.
    ;; Goal parity with the old Karabiner rule:
    ;;   tap Caps  -> Escape
    ;;   hold Caps -> Control+Option

    (defcfg
      process-unmapped-keys no
    )

    (defsrc
      caps
    )

    (defalias
      caps (tap-hold 200 200 esc (multi lctl lalt))
    )

    (deflayer base
      @caps
    )
  '';
}
