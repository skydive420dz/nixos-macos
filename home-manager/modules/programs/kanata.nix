{
  xdg.configFile."kanata/kanata.kbd".text = ''
    ;; macOS trial config.
    ;; Keep Karabiner installed while testing, but do not let both remap Caps.
    ;; Goal parity with the current Karabiner rule:
    ;;   tap Caps  -> Escape
    ;;   hold Caps -> Control+Option

    (defcfg
      process-unmapped-keys yes
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
