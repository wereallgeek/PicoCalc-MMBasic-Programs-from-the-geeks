' Matrix Rain +
' 8-LED WS2812 Sync with LED On/Off Toggle  PicoMite MMBasic
' plus mp3 and modfile player

' Mode Selectiom and nav variables
mpdmode$ = "matrix"
mpcover = 0
newcover = 0
mpnext = 0
mpsec = 0
mpmin = 0
mptime$ = Time$
bat = MM.Info(battery)
isplug = MM.Info(charging)

' Screen constants
Const WIDTH = 320
Const HEIGHT = 320
Const COL_WIDTH = 8
Const CHAR_HEIGHT = 10
Const NUM_COLS = WIDTH \ COL_WIDTH
Const TRAIL_LENGTH = 8
Const MAX_ACTIVE_COLS = 12

' LED constants & buffers
Const LEDCOUNT = 8
Const WHITE_THRESHOLD = 250   ' threshold for white?green transition
Const FADE_STEP      = 20     ' fade step per frame (slower fade)
Dim ledBuf%(LEDCOUNT - 1)     ' WS2812 RGB buffer
Dim ledFade%(LEDCOUNT - 1)    ' per-LED fade counter (0255)
Dim ledEnabled               ' 0 = off, 1 = on

' Matrix state buffers
Dim colY(NUM_COLS)            ' vertical position of head
Dim colMode(NUM_COLS)         ' 0=idle, 1=raining, 1=blanking
Dim colSpeed(NUM_COLS)        ' pixels per frame
Dim fadeRGB(TRAIL_LENGTH)     ' precomputed green fade colors

' Precompute green fades for the rain trail
For i = 0 To TRAIL_LENGTH - 1
  brightness = 255 - (i * (230 \ TRAIL_LENGTH))
  If brightness < 45 Then brightness = 45
  fadeRGB(i) = RGB(0, brightness, 0)
Next i

'music
mpx=1
Dim mzk$(127)
path$="b:\mzk\"
mp3ext$ = "mp3"
modext$ = "mod"
setupfile$ = "mzk.ini"
mpquit = 0
mpnext = 0
mppathlen = Len(path$)

'music folder init
mpf1=1
mpf$=Dir$(path$ + "*.m*", FILE) 'mp3+mod

Do While mpf$<>""
 mzk$(mpf1)=path$+mpf$
 mpf$=Dir$()
 mpf1=mpf1+1
Loop

On error skip 4
 Open (path$ + setupfile$) For input As #1
  Line Input #1, shuffle$
  Line Input #1, mpdmode$
 Close #1
On error abort

If shuffle$ = "true" Then
 doshuffle
EndIf

'set shuffled play
Sub doshuffle
 Randomize
 For mpi=1 To mpf1 - 1
  mpk$ = mzk$(mpi)
  mpj = Int(Rnd*(mpf1 - 1)) + 1
  mzk$(mpi) = mzk$(mpj)
  mzk$(mpj) = mpk$
 Next
End Sub

'set ordered play
Sub unshuffle
 mpf1=1
 mpf$=Dir$(path$ + "*.m*",FILE)
 Do While mpf$<>""
  mzk$(mpf1)=path$+mpf$
  mpf$=Dir$()
  mpf1=mpf1+1
 Loop
End Sub

'handle next song
Sub nextSong
 mpnext = 1
End Sub

'write setup
Sub writesetup
 Open (path$ + setupfile$) For OUTPUT As #1
  Print #1, shuffle$
  Print #1, mpdmode$
 Close #1
End Sub

'handle shuffle change
Sub writeshuffle
 If shuffle$ = "true" Then
  Color RGB(myrtle)
  Print @(0,0) " -"
  shuffle$= "false"
  unshuffle
 Else
  Color RGB(myrtle)
  Print @(0,0) "S-"
  shuffle$= "true"
  doshuffle
 EndIf
 writesetup
End Sub

' time computation
Sub counttime
  myhrs = Val(Mid$(mptime$,1,2))
  tmhrs = Val(Mid$(Time$,1,2))
  mymin = Val(Mid$(mptime$,4,2))
  tmmin = Val(Mid$(Time$,4,2))
  mysec = Val(Mid$(mptime$,7,2))
  tmsec = Val(Mid$(Time$,7,2))
  If tmsec < mysec Then
    tmsec = tmsec + 60
    If tmmin = 0 Then
      tmmin = 59
    Else
      tmmin = tmmin - 1
    EndIf
  EndIf
  If tmmin < mymin Then
    tmmin = tmmin + 60
    If tmhrs = 1 Then
      tmhrs = 12
    Else
      tmhrs = tmhrs - 1
    EndIf
  EndIf
  If tmhrs < myhrs Then
    tmhrs = tmhrs + 12
  EndIf
  mphrs = tmhrs - myhrs
  mpmin = tmmin - mymin + (mphrs * 60)
  mpsec = tmsec - mysec
End Sub


' get battery state
'--------------------
' constantly poking stm32 cause
' mp3 audible glitch. but adjust every
' songchange is good ennough info.
Sub checkbat
 bat = MM.Info(battery)
 isplug = MM.Info(charging)
End Sub

Function tracktime$()
  min$ = Str$(mpmin)
  sec$ = ":" + Str$(mpsec) + "-"
  If mpmin < 100 Then
    min$ = "-" + Str$(mpmin)
  EndIf
  If mpmin < 10 Then
    min$ = "-0" + Str$(mpmin)
  EndIf
  If mpsec < 10 Then
    sec$ = ":0" + Str$(mpsec) + "-"
  EndIf
  tracktime$ = min$ + sec$
End Function

Function trackname$()
  mpnamelen = (Len(mzk$(mpx))-mppathlen)-4
  trackname$ = Mid$(mzk$(mpx), mppathlen + 1, mpnamelen)
End Function

Sub noinfo
  msg$="-LOAD-"
  If mpquit = 1 Then
    msg$="       "
  EndIf
  If mpdmode$ = "matrix" Then
    displayinfo("", msg$)
  Else
    displayinfo("                             ", msg$)
  EndIf
End Sub

Sub trackinfo
  displayinfo(trackname$(), "------")
End Sub


' Print information line
Sub displayinfo(namein$ As string, timein$ As string)
  'dispay information
  ind$ = " -"

  infotrack$ = timein$ + namein$

  If shuffle$ = "true" Then
   ind$ = "S-"
  EndIf
  If mpquit = 1 Then
    ind$ = "  "
  EndIf
  If mpquit = 1 Then
    Color RGB(green)
  ElseIf mpdmode$ = "matrix" Then
    Color RGB(myrtle)
  Else
    Color RGB(white)
  EndIf

  Print @(0,0) ind$ + infotrack$

  Print @(300,0) " %"
  Print @(275,0) bat

  If isplug = 1 Then
    Print @(275,0) "+"
  ElseIf mpdmode$ <> "matrix" Then
    Print @(275,0) " "
  EndIf
End Sub


' Initialize matrix
CLS
Font 1
Randomize Timer
ledEnabled = 0 ' start with LEDs active

Do While mpquit = 0
  curext$ = Right$(mzk$(mpx), 3)
  If curext$ = mp3ext$ Then
    On error skip 1
      Play mp3 mzk$(mpx), nextsong
    On error abort
  ElseIf curext$ = modext$ Then
    On error skip 1
      Play modfile mzk$(mpx), nextsong
    On error abort
    checkbat()
  EndIf

  ' 0) Check for toggle key (L)
  k$ = Inkey$
  If k$ = "l" Then
    ledEnabled = 1 - ledEnabled
    If ledEnabled = 0 Then
      ' clear strip immediately when turning off
      For j% = 0 To LEDCOUNT - 1
        ledBuf%(j%) = 0
      Next j%
      Device ws2812 o, GP28, LEDCOUNT, ledBuf%()
    EndIf
  EndIf

  If mpdmode$ = "matrix" Then
   ' 1) Spawn new drops up to the MAX_ACTIVE_COLS limit
   activeCount = 0
   For i = 0 To NUM_COLS - 1
     If colMode(i) <> 0 Then activeCount = activeCount + 1
   Next i

   For i = 0 To NUM_COLS - 1
     If activeCount >= MAX_ACTIVE_COLS Then Exit For
     If colMode(i) = 0 And Rnd < 0.02 Then
       If Rnd < 0.75 Then
         colMode(i) = 1
       Else
         colMode(i) = -1
       EndIf
       colY(i) = -TRAIL_LENGTH * CHAR_HEIHT
       colSpeed(i) = 6 + Int(Rnd * 7)
       activeCount = activeCount + 1
     EndIf
   Next i

   ' 2) Draw each column, update positions, and trigger LEDs
   For i = 0 To NUM_COLS - 1
     If colMode(i) = 0 Then Continue For
     x = i * COL_WIDTH
     y = colY(i)

     If colMode(i) = 1 Then
       ' Rain trail
       For t = 0 To TRAIL_LENGTH - 1
         ty = y - t * CHAR_HEIGHT
         If ty >= 0 And ty < HEIGHT Then
           Color fadeRGB(t)
           Text x, ty, Chr$(33 + Int(Rnd * 94))
         EndIf
       Next t
       ' Rain head (with glitch chance)
       If y >= 0 And y < HEIGHT Then
         gch = Rnd
         If gch < 0.05 Then
           Color RGB(100 + Int(Rnd * 155), 255, 255)
         ElseIf gch < 0.08 Then
           Color RGB(255, 255, 255)
         Else
           baseB = 255 - (TRAIL_LENGTH - 1) * (230 \ TRAIL_LENGTH)
           If baseB < 45 Then baseB = 45
           Color RGB(0, baseB, 0)
         EndIf
         Text x, y, Chr$(33 + Int(Rnd * 94))
       EndIf

     ElseIf colMode(i) = -1 Then
       ' Blanking trail
       For t = 0 To TRAIL_LENGTH - 1
         ty = y - t * CHAR_HEIGHT
         If ty >= 0 And ty < HEIGHT Then
           b = 45 - t * (45 \ TRAIL_LENGTH)
           If b < 0 Then b = 0
           Color RGB(0, b, 0)
           Text x, ty, Chr$(33 + Int(Rnd * 94))
         EndIf
       Next t
       ' Blanking head
       If y >= 0 And y < HEIGHT Then
         b = 45 - (TRAIL_LENGTH - 1) * (45 \ TRAIL_LENGTH)
         If b < 0 Then b = 0
         Color RGB(0, b, 0)
         Text x, y, Chr$(33 + Int(Rnd * 94))
       EndIf
     EndIf

     ' Move the drop
     colY(i) = y + colSpeed(i)

     ' Only trigger on raining drops
     If colMode(i) = 1 And y < HEIGHT And colY(i) >= HEIGHT Then
       slice = i \ (NUM_COLS \ LEDCOUNT)
       ledFade%(slice) = 255
     EndIf

     ' Deactivate when fully off-screen
     If colY(i) > HEIGHT + TRAIL_LENGTH * CHAR_HEIGHT Then
       colMode(i) = 0
     EndIf
   Next i

   ' 3) Update LED fade & pack RGB values if enabled
   If ledEnabled Then
     For j% = 0 To LEDCOUNT - 1
       If ledFade%(j%) > 0 Then
         If ledFade%(j%) > WHITE_THRESHOLD Then
           rVal = ledFade%(j%)
           gVal = 255
           bVal = ledFade%(j%)
         Else
           rVal = 0
           gVal = ledFade%(j%)
           bVal = 0
         EndIf
         ledBuf%(j%) = (rVal * &H10000) + (gVal * &H100) + bVal
         ledFade%(j%) = ledFade%(j%) - FADE_STEP
       Else
         ledBuf%(j%) = 0
       EndIf
     Next j%
     Device ws2812 o, GP28, LEDCOUNT, ledBuf%()
   EndIf
  EndIf 'mpdmode matrix

  If mpdmode$ = "cover" Then
   If mpcover = 0 Then
    CLS
    trackinfo
    'displey cover
    mpnamelen = Len(mzk$(mpx)) - 4
    If mpnamelen > 0 Then
     covername$ = Left$(mzk$(mpx), mpnamelen) + ".bmp"
    Else
     covername$ = mzk$(mpx)
    EndIf
    'try it
    On error skip 3
     Open (covername$) For random As #3
     coverlen = Lof(3)
     Close #3
    On error abort
    If coverlen = 0 Then
     'clean
     On error skip 1
      Kill (covername$)'0bytes removal
     On error abort
     'no cover, use default
     covername$ = path$ + "cover.bmp"
    EndIf
    ' load it
    On error skip 1
     Load image covername$
    On error abort
    Print @(0,0) "                                        "
    mpcover = 1
   EndIf
  Else
   mpcover = 0
  EndIf 'mpdmode cover

  If mpx = 0 Then
   mpx = 1
   mpnext = 1
   mpcover = 0
  'mp3 handling
  ElseIf mpx = mpf1 Or mpx = 0 Then
    mpx = 1 'rollover
    If shuffle$ = "true" Then
      doshuffle
    EndIf
  EndIf

  displayinfo(trackname$(), tracktime$())

  'mp3 key control
  mpk$ = Inkey$
  If mpk$ <> "" Then
   Select Case Asc(mpk$)
   Case 131: Play stop
    mpx = mpx + 1
    mpcover = 0
    mpnext = 0
    checkbat
    mptime$ = Time$
    noinfo
   Case 130: Play stop
    If (mpx > 2) Then
      mpx = mpx - 1
    Else
      mpx = mpf1 - 1 'rollover
      If shuffle$ = "true" Then
        doshuffle
      EndIf
    EndIf
    mpcover = 0
    mpnext = 0
    checkbat
    mptime$ = Time$
    noinfo
   Case 27: Play stop
    mpquit = 1
    CLS
   Case 145
    If mpcover = 1 Then CLS endif
    mpdmode$ = "matrix"
    writesetup
   Case 146
    If mpdmode$ <> "cover" Then
     mpcover = 0
    EndIf
    mpdmode$ = "cover"
    writesetup
   Case 9
    mpx = 0
    writeshuffle
    checkbat
   End Select
  End If

  If mpnext = 1 Then
   Play stop
   mpx = mpx + 1
   mpcover = 0
   mpnext = 0
   checkbat
   mptime$ = Time$
   noinfo
  EndIf
  ' /mp3

  ' time computation
  counttime

Loop
