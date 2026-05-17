{
  xdg.configFile."kanata/kanata.kbd".text = ''
    ;; macOS Kanata config.
    ;; Keep this intentionally narrow: Kanata remaps Caps and preserves the MacBook F-row.
    ;; Kanata on macOS can otherwise turn the top row into literal F1-F12 keys.
    ;; Goal parity with the current Karabiner rule:
    ;;   tap Caps  -> Escape
    ;;   hold Caps -> Control+Option
    ;; Top row:
    ;;   default -> brightness/mission/spotlight/dictation/dnd/media/volume
    ;;   hold Fn -> literal F1-F12

    (defcfg
      process-unmapped-keys no
    )

    (defsrc
      f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      fn
      caps
    )

    (defalias
      caps (tap-hold 200 200 esc (multi lctl lalt))
      fn (layer-while-held fn)
    )

    (deflayer base
      brdn brup mctl sls  dtn  dnd  prev pp   next mute vold volu
      @fn
      @caps
    )

    (deflayer fn
      f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      fn
      _
    )
  '';
}
