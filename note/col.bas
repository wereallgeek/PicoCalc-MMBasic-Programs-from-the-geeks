' ** Note.bas color editor utility **
' meant to save within data file of
' note.bas
'

'file management
path$ = "b:\notes\"
libinfofilename$ = "libinfo"
dataext$ = ".data"
lastbook = 1
notesize = 9
lastsize = 9
filehandle=1

'compute library info file
Function libinfo$()
  libinfo$ = path$ + libinfofilename$ + dataext$
End Function

Sub storelib
  Open libinfo$() For output As filehandle
    Print #filehandle, Str$(lastbook)
    Print #filehandle, Str$(notesize)
    Print #filehandle, Hex$(colheader)
    Print #filehandle, Hex$(colbat)
    Print #filehandle, Hex$(colfkey)
    Print #filehandle, Hex$(colfhig)
    Print #filehandle, Hex$(colpage)
    Print #filehandle, Hex$(coltxt)
    Print #filehandle, Hex$(colhig)
    Print #filehandle, Hex$(colhhl)
    Print #filehandle, Hex$(colhelp)
    Print #filehandle, Hex$(colask)
    Print #filehandle, Hex$(bgcolor)
   Close #filehandle
End Sub

Sub getlibinfo
  somebook$ = "1"
  somesize$ = Str$(nsmed)
  If MM.Info(exists file libinfo$()) = 1 Then
    Open libinfo$() For INPUT As filehandle
    Line Input #filehandle, somebook$
    Line Input #filehandle, somesize$
    Line Input #filehandle, intxtheader$
    Line Input #filehandle, intxtbat$
    Line Input #filehandle, intxtfkey$
    Line Input #filehandle, intxtfhig$
    Line Input #filehandle, intxtpage$
    Line Input #filehandle, intxttxt$
    Line Input #filehandle, intxthig$
    Line Input #filehandle, intxthhl$
    Line Input #filehandle, intxthelp$
    Line Input #filehandle, intxtask$
    Line Input #filehandle, intxtbgcol$
    'read 7 color data
    Close #filehandle
  EndIf
  lastbook = Val(somebook$)
  notesize = Val(somesize$)
  lastsize = notesize
  If hex2col(intxtheader$)<>0 Then colheader=hex2col(intxtheader$)
  If hex2col(intxtbat$)<>0 Then colbat=hex2col(intxtbat$)
  If hex2col(intxtfkey$)<>0 Then colfkey=hex2col(intxtfkey$)
  If hex2col(intxtfhig$)<>0 Then colfhig=hex2col(intxtfhig$)
  If hex2col(intxtpage$)<>0 Then colpage=hex2col(intxtpage$)
  If hex2col(intxttxt$)<>0 Then coltxt=hex2col(intxttxt$)
  If hex2col(intxthig$)<>0 Then colhig=hex2col(intxthig$)
  If hex2col(intxthhl$)<>0 Then colhhl=hex2col(intxthhl$)
  If hex2col(intxthelp$)<>0 Then colhelp=hex2col(intxthelp$)
  If hex2col(intxtask$)<>0 Then colask=hex2col(intxtask$)
  If hex2col(intxtbgcol$)<>0 Then bgcolor=hex2col(intxtbgcol$)
End Sub

'color editor
bgcolindex      = 11
colEditMaxIndex = 11
colheader = &h2cdec8
colbat    = &h1eb4b4
colfkey   = &h2cdec8
colfhig   = &h187a64
colpage   = &h2cdec8
coltxt    = &hc8c8c8
colhig    = &hdcdc00
colhhl    = &hc8c814
colhelp   = &he68437
colask    = &hf02828
bgcolor   = &h000000

headx = 0
heady = 0
battx = 280
batty = heady
fkeyx = 100
fkeyy = 304
fkhix = fkeyx
fkhiy = fkeyy
mainx = 0
mainy = 10
highx = mainx
highy = 20
hhigx = mainx
hhigy = 30
askx  = mainx
asky  = 40
helpx = mainx
helpy = 50
pagex = 20
pagey = 304
bgcolx= 60
bgcoly= 135
bgcolsz= 2
headsz = 7
battsz = 7
fkeysz = 7
fkhisz = 7
pagesz = 7

headtxt$ = "[header colour]"
batttxt$ = "batt%"
maintxt$ = "colour of the note text"
hightxt$ = "highlighted texts"
empttxt$ = "<empty highlight>"
fkeytxt$ = "[f]unction keys"
fkhitxt$ = "disabled [f]key"
pagetxt$ = "<page>"
asktxt$  = "Asking questions"
helptxt$ = "Text of the help page"
bgcoltxt$= "<Background Color>"

notesize=1
editsel = 1
colsel = colheader
selx = 0
sely = 0
seltxt$ = ""

'color picker
rgbrx = 60
rgbry = 94
rgbgx = 130
rgbgy = 94
rgbbx = 200
rgbby = 94
rgbtxtx = 50
rgbtxty = 190
rgbaupy = 70
rgbadny = 160

cur_r = 120
cur_g = 200
cur_b = 120

currgbsel=1

'setup color edit
Sub setupColEdit
  flashst = 1
  Timer = 0
  colEditIndex = 1
  colEditScreen
End Sub

'draw the color edit screen
Sub colEditScreen
  Color bgcolor, bgcolor
  CLS
  'head
  Font (headsz)
  Color colheader
  Print @(headx,heady) headtxt$
  Font (battsz)
  Color colbat
  Print @(battx,heady) batttxt$
  'foot
  Line 1,300,319,300,1,colfkey
  Font (pagesz)
  Color colpage
  Print @(pagex,pagey) pagetxt$
  Font (fkeysz)
  Color colfkey
  Print @(fkeyx,fkeyy) fkeytxt$
  'text
  Font (notesize)
  Color coltxt
  Print @(mainx,linposy(3)) maintxt$
  Color colhig
  Print hightxt$
  Color coltxt
  Print maintxt$
  Color colask
  Print asktxt$
  Color colhelp
  Print helptxt$
  'bg
  Font (bgcolsz)
  Color coltxt
  Print @(bgcolx,bgcoly) bgcoltxt$
End Sub

Function editflash(curtxt$, curcol, posx, posy, flshst)
  fgcolor = curcol
  If fgcolor = bgcolor Then fgcolor = coltxt
  If flshst = 1 Then
    Color fgcolor, bgcolor
    editflash = 0
  Else
    Color bgcolor, fgcolor
    editflash = 1
  EndIf
  Font (txtsize())
  Print @(posx,posy) curtxt$
End Function

'flash if elapsed enough
Sub decideflash
 If Timer > 500 Then
  flashst = editflash(title$(), txtcol(), txtposx(), txtposy(), flashst)
  Timer = 0
 EndIf
End Sub

'pos X
Function txtposx()
  Select Case colEditIndex
    Case 1 'header
      txtposx = headx
    Case 2 'batt
      txtposx = battx
    Case 3 'main txt
      txtposx = mainx
    Case 4 'empty highlight
      txtposx = mainx
    Case 5 'hightlight
      txtposx = mainx
    Case 6 'aask
      txtposx = mainx
    Case 7 'help
      txtposx = mainx
    Case 8 'page
      txtposx = pagex
    Case 9 'f-keys select
      txtposx = fkhix
    Case 10 'f-keys
      txtposx = fkeyx
    Case 11 'bg
      txtposx = bgcolx
  End Select
End Function

'pos Y
Function txtposy()
  txtposy = linposy(colEditIndex)
End Function

'pos Y
Function linposy(selindex)
  Select Case selindex
    Case 1 'header
      linposy = heady
    Case 2 'batt
      linposy = batty
    Case 3 'main txt
      linposy = fnth(1)
    Case 4 'empty highlight
      linposy = fnth(1)+fnth(3)
    Case 5 'hightlight
      linposy = fnth(1)+fnth(3)
    Case 6 'ask
      linposy = fnth(1)+(3*fnth(3))
    Case 7 'help
      linposy = fnth(1)+(4*fnth(3))
    Case 8 'page
      linposy = pagey
    Case 9 'f-keys select
      linposy = fkhiy
    Case 10 'f-keys
      linposy = fkeyy
    Case 11 'bg
      linposy = bgcoly
  End Select
End Function

'text color
Function txtcol()
  txtcol = fntcol(colEditIndex)
End Function

'text color
Function fntcol(cursel)
  Select Case cursel
    Case 1 'header
      fntcol = colheader
    Case 2 'batt
      fntcol = colbat
    Case 3 'main txt
      fntcol = coltxt
    Case 4 'empty highlight
      fntcol = colhhl
    Case 5 'hightlight
      fntcol = colhig
    Case 6 'ask
      fntcol = colask
    Case 7 'help
      fntcol = colhelp
    Case 8 'page
      fntcol = colpage
    Case 9 'f-keys select
      fntcol = colfhig
    Case 10 'f-keys
      fntcol = colfkey
    Case 11 'bg
      fntcol = bgcolor
  End Select
End Function


'set txt color
Sub settxtcol(whatcolor)
  setfntcol(colEditIndex, whatcolor)
End Sub

'set txt color
Sub setfntcol(cursel, whatcolor)
  Select Case cursel
    Case 1 'header
      colheader = whatcolor
    Case 2 'batt
      colbat = whatcolor
    Case 3 'main txt
      coltxt = whatcolor
    Case 4 'empty highlight
      colhhl = whatcolor
    Case 5 'hightlight
      colhig = whatcolor
    Case 6 'ask
      colask = whatcolor
    Case 7 'help
      colhelp = whatcolor
    Case 8 'page
      colpage = whatcolor
    Case 9 'f-keys select
      colfhig = whatcolor
    Case 10 'f-keys
      colfkey = whatcolor
    Case 11 'bg
      bgcolor = whatcolor
  End Select
End Sub

'txt size curr font
Function txtsize()
  txtsize = fntsize(colEditIndex)
End Function

'txt size any font
Function fntsize(fontindex)
  Select Case fontindex
    Case 1 'header
      fntsize = headsz
    Case 2 'batt
      fntsize = battsz
    Case 3 'main txt
      fntsize = notesize
    Case 4 'empty highlight
      fntsize = notesize
    Case 5 'hightlight
      fntsize = notesize
    Case 6 'ask
      fntsize = notesize
    Case 7 'help
      fntsize = notesize
    Case 8 'page
      fntsize = pagesz
    Case 9 'f-keys select
      fntsize = fkhisz
    Case 10 'f-keys
      fntsize = fkeysz
    Case 11 'bg
      fntsize = bgcolsz
  End Select
End Function

'fontheight
Function fnth(fontindex)
  resetfontto = MM.Info(font)
  Font (fntsize(fontindex))
  fnth=MM.Info(FONTHEIGHT)
  Font (resetfontto)
End Function

'title text
Function title$()
  Select Case colEditIndex
    Case 1 'header
      title$ = headtxt$
    Case 2 'batt
      title$ = batttxt$
    Case 3 'main txt
      title$ = maintxt$
    Case 4 'empty highlight
      title$ = empttxt$
    Case 5 'hightlight
      title$ = hightxt$
    Case 6 'ask
      title$ = asktxt$
    Case 7 'help
      title$ = helptxt$
    Case 8 'page
      title$ = pagetxt$
    Case 9 'f-keys select
      title$ = fkhitxt$
    Case 10 'f-keys
      title$ = fkeytxt$
    Case 11 'bg
      title$ = bgcoltxt$
  End Select
End Function

'rotate highlight
Sub colEditChange(updown)
  deltachoice = editflash(title$(), txtcol(), txtposx(), txtposy(), 1)
  deltachoice = -1
  If updown > 0 Then deltachoice = 1
  colEditIndex = colEditIndex + deltachoice
  If colEditIndex > colEditMaxIndex Then colEditIndex = 1
  If colEditIndex < 1 Then colEditIndex = colEditMaxIndex
End Sub

Function rgbselpos()
  If currgbsel=1 Then rgbselpos = rgbrx
  If currgbsel=2 Then rgbselpos = rgbgx
  If currgbsel=3 Then rgbselpos = rgbbx
End Function

'draw r g b
Sub drawCurRgb
 Font (3)
 Colour RGB(190,190,190)
 Print @(rgbrx,rgbry) Str$(cur_r,3,0,"0")
 Print @(rgbrx+9,rgbry+25) Hex$(cur_r)
 Print @(rgbgx,rgbgy) Str$(cur_g,3,0,"0")
 Print @(rgbgx+9,rgbgy+25) Hex$(cur_g)
 Print @(rgbbx,rgbby) Str$(cur_b,3,0,"0")
 Print @(rgbbx+9,rgbby+30) Hex$(cur_b)
 If colEditIndex = bgcolindex Then
  Colour coltxt, RGB(cur_r,cur_g,cur_b)
 Else
  Colour RGB(cur_r,cur_g,cur_b)
 EndIf
 Print @(rgbtxtx,rgbtxty) "selected color"
End Sub

'arrow
Sub onearrow(pointingup)
  adir = 1
  arwy = rgbadny
  If pointingup Then
    adir = -1
    arwy = rgbaupy
  EndIf
  For trindex = 0 To 10
    arsiz = trindex * adir
    arwx = rgbselpos() + 25
    arwcol = RGB(190,190,190)
    Line arwx,arwy+arsiz,arwx-arsiz,arwy-arsiz,1,arwcol
    Line arwx-arsiz,arwy-arsiz,arwx+arsiz,arwy-arsiz,1,arwcol
    Line arwx+arsiz,arwy-arsiz,arwx,arwy+arsiz,1,arwcol
  Next
End Sub

'arrows
Sub rgbselarrow
  onearrow(1)
  onearrow(0)
End Sub


'change current rgb by amnt
Sub rgbchange(amnt)
  If currgbsel=1 Then
    cur_r=cur_r+amnt
    If cur_r < 0   Then cur_r = 0
    If cur_r > 255 Then cur_r = 255
  EndIf
  If currgbsel=2 Then
    cur_g=cur_g+amnt
    If cur_g < 0   Then cur_g = 0
    If cur_g > 255 Then cur_g = 255
  EndIf
  If currgbsel=3 Then
    cur_b=cur_b+amnt
    If cur_b < 0   Then cur_b = 0
    If cur_b > 255 Then cur_b = 255
  EndIf
  redrawRgbPicker
End Sub

'change current r-g-b
Sub rgbsel(amnt)
  currgbsel=currgbsel+amnt
  If currgbsel < 1 Then currgbsel = 1
  If currgbsel > 3 Then currgbsel = 3
  redrawRgbPicker
End Sub

Sub redrawRgbPicker
  cur_back = bgcolor
  If colEditIndex = bgcolindex Then
    cur_back = RGB(cur_r,cur_g,cur_b)
  EndIf
  Colour cur_back, cur_back
  CLS
  drawCurrgb
  rgbselarrow
End Sub

Function hex2col(colorrgb$)
  hex2col=0
  If Len(colorrgb$) = 6 Then
    hex2col=Val("&h"+colorrgb$)
  EndIf
End Function

Sub separate_r_g_b(refcolor)
  colorrgb$ = Hex$(refcolor)
  cur_r = Val("&h"+Mid$(colorrgb$,1,2))
  cur_g = Val("&h"+Mid$(colorrgb$,3,2))
  cur_b = Val("&h"+Mid$(colorrgb$,5,2))
End Sub

Function rgbpickertool(whatcolor)
  rgbpickertool = whatcolor
  separate_r_g_b(whatcolor)
  redrawRgbPicker
  Do
   'loop
   cmd$=Inkey$
   If cmd$ <> "" Then
     Select Case Asc(cmd$)
       Case 136'shf-up
         rgbchange(20)
       Case 137'sht-down
         rgbchange(-20)
       Case 128'up
         rgbchange(1)
       Case 129'down
         rgbchange(-1)
       Case 130'left
         rgbsel(-1)
       Case 131'right
         rgbsel(1)
       Case 27'[ESC]
         rgbpickertool = whatcolor
         Exit Do
       Case 13'enter
         rgbpickertool = RGB(cur_r,cur_g,cur_b)
         Exit Do
     End Select
   EndIf
  Loop
End Function

'process keypress
Sub handlekey
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 130 'left
        colEditChange(0)
      Case 131 'right
        colEditChange(1)
      Case 13  'enter
       settxtcol(rgbpickertool(txtcol()))
       colEditScreen 'redraw
     Case 27'[ESC]
       storelib
       Color bgcolor, bgcolor
       CLS
       Run "note.bas"
    End Select
  EndIf
End Sub

'start here
getlibinfo
setupColEdit
Do
 decideflash
 handlekey
Loop
