Print @(0,0) "hit any key"
Do

  keypres$ = Inkey$
  keycode = Asc(keypres$)

  If keycode <> 0 Then
    Print @(0,20) "keycode :       "
    Print @(80,20) keycode
  EndIf

Loop
