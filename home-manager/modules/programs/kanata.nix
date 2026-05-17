{
  xdg.configFile."kanata/kanata.kbd".text = ''
    ;; macOS Kanata config.
    ;; Keep this intentionally narrow: Kanata only remaps Caps.
    ;; Goal parity with the current Karabiner rule:
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
