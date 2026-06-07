{
  xdg.configFile."kanata/kanata.kbd".text = ''
    ;; macOS Kanata config.
    ;; Keep this intentionally narrow: Kanata remaps Caps and preserves the MacBook F-row.
    ;; Delegating the function row to macOS through com.apple.keyboard.fnState
    ;; is not reliable once Kanata/VirtualHID sits in the keyboard path.
    ;; Goal parity with the old Karabiner rule:
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
