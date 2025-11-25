'note editor
filehandle = 1
temphandle = 2
filename$ = "notes.data"
path$ = "b:\notes\"
bookinfoext$ = ".inf"
libinfofilename$ = "libinfo"
dataext$ = ".data"
tempext$ = ".temp"
note$ = ""
notenum = 1
notebook$ = "notebook"
booknum = 1
lastbook = 1
ver$ = "V1.2"
notesize = 9
nsmax = 2
nsbgr = 4
nsbig = 1
nsmed = 9
nssml = 7
nsmin = 8
mode$="read"
linedit=1
linehigh=1
mark$=Chr$(26)

bgcolor   = &h000000
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

f1pos = 95
f2pos = 145
f3pos = 195
f4pos = 255
f5pos = 305


'draw header
Sub noteheader(whatnote As integer)
  headtext$ = "["
  headtext$ = headtext$ + notebook$
  headtext$ = headtext$ + "]"
  headbat$ = batlevel$()
  batpos = 320-(Len(headbat$)*7)
  Font (7)
  Color colheader
  Print @(0,0) headtext$
  Font (7)
  Color colbat
  Print @(batpos,0) headbat$
  Font (1)
End Sub

'draw footer
Sub notefooter(whatnote As integer)
  npagetxt$ = "<"
  If hasnote(whatnote) = 1 Then
    npagetxt$ = npagetxt$ + Str$(whatnote)
  Else
    npagetxt$ = npagetxt$ + "-"
  EndIf
  npagetxt$ = npagetxt$ + "/"
  npagetxt$ = npagetxt$ + Str$(nextNoteSpot(whatnote)-1)
  npagetxt$ = npagetxt$ + ">"
  Line 1,300,319,300,1,colfkey
  f1col = colfkey
  f2col = colfkey
  f3col = colfkey
  f4col = colfkey
  f5col = colfkey
  Color colfkey
  Font (7)
  Print @(15,304) npagetxt$
  Font (7)
  If mode$="read" Then
    Color f1col
    Print @(f1pos,304)"HLP/MV"
    Color f2col
    Print @(f2pos,304)"++/REN"
    Color f3col
    Print @(f3pos,304)"NEW/BOOK"
    Color f4col
    Print @(f4pos,304)"INS/EDT"
    Color f5col
    Print @(f5pos,304)"/D"
  ElseIf mode$="edit" Then
    If linedit = lastLine(whatnote) Then f3col=colfhig
    If linedit = 1 Then f1col=colfhig
    If lastLine(whatnote) < 2 Then f5col=colfhig
    Color f1col
    Print @(f1pos,304)"UP"
    Color f2col
    Print @(f2pos,304)"ADDTO"
    Color f3col
    Print @(f3pos,304)"DOWN"
    Color f4col
    Print @(f4pos,304)"INS"
    Color f5col
    Print @(f5pos,304)"RM"
  EndIf
  Font (1)
End Sub

'draw helpscreen
Sub helpscreen
  Color colhelp
  CLS
  Font (1)
  Print "  *** PicCalc simple notepad " + ver$ + " ***"
  Print ""
  Font (9)
  Print "Meant to take notes, this software"
  Print "stores notes in files in the folder:"
  Font (1)
  Print path$
  Print ""
  Font (9)
  Print "To Use:"
  Print "[F1]       this help"
  Print "[F2]       add to current note"
  Print "[F3]       New note (end of book)"
  Print "[F4]       Insert note (here)"
  Print "[F6]       Move note (change order)"
  Print "[F9]       edit note"
  Print "[<-back]   delete current note"
  Print "LEFT dpad  previous note"
  Print "RIGHT dpad next note"
  Print "[HOME]     first note in the book"
  Print "[END]      last note in the book"
  Print "UP/DOWN    change book"
  Print ""
  Print "shift[+/-] change note font size"
  Print "[ALT]-[C]  Color configuration tool"
  Print ""
  Print "[F7]       rename current book"
  Print "[F8]       add a book"
  Print "[F10]      delete current book"
  Print ""
  Print "[ESC]      exit"
  Print ""
  Font (1)
  Print @(0,295) "       Press any key to continue"
  Do While Inkey$ = ""
  Loop
  CLS
  loadnotes(notenum)
End Sub

'ask to delete book
Sub askDebook
  CLS
  Color colask
  Font (1)
  Print "delete book "
  Color colheader
  Font (7)
  Print notebook$
  Color colask
  Font (1)
  Print " (Y/N) ?"
  cmd$ = Inkey$
  Do While cmd$ = ""
    cmd$ = Inkey$
  Loop
  If cmd$ = "y" Or cmd$ = "Y" Then
    deletebook(booknum)
    If hasbook(booknum) = 0 Then
      booknum = booknum - 1
      If booknum = 0 Then
        'no more books
        booknum = 1
        notenum = 1
        createbook(booknum)
        loadnotes(notenum)
      Else
        notenum = 1
        notebook$ = loadbookinfo$(booknum)
        loadnotes(notenum)
      EndIf
    Else
      notenum = 1
      notebook$ = loadbookinfo$(booknum)
      loadnotes(notenum)
    EndIf
  Else
    notebook$ = loadbookinfo$(booknum)
    loadnotes(notenum)
  EndIf
  bookchanged
End Sub

'ask to delete note
Sub askDelete
  CLS
  Font (notesize)
  loadnotetext(notenum)
  Font (1)
  Color colask
  Print "delete note #" + Str$(notenum) + " (Y/N) ?"
  cmd$ = Inkey$
  Do While cmd$ = ""
    cmd$ = Inkey$
  Loop
  If cmd$ = "y" Or cmd$ = "Y" Then
    deletenote(notenum)
  Else
    loadnotes(notenum)
  EndIf
End Sub

'ask to move note
Sub askmove
  If notenum = nextBookSpot(notenum) Then
    Exit Sub
  EndIf
  CLS
  okleft = 0
  okright = 0
  Font (notesize)
  loadnotetext(notenum)
  Font (1)
  moveq$ = "move note #" + Str$(notenum) + " ("
  If notenum > 1 Then
    moveq$ = moveq$ + "<"
    okleft = 1
  Else
    moveq$ = moveq$ + " "
  EndIf
  moveq$ = moveq$ + "/"
  If notenum < (nextBookSpot(notenum) -1) Then
    moveq$ = moveq$ + ">"
    okright = 1
  Else
    moveq$ = moveq$ + " "
  EndIf
  moveq$ = moveq$ + ") ?"
  Color colask
  Print moveq$
  Do
    cmd$ = Inkey$
    If cmd$ <> "" Then
      Select Case Asc(cmd$)
        Case 131 'right
          If okright = 1 Then
            swapNotes(notenum, notenum + 1)
            Exit Do
          EndIf
        Case 130 'left
          If okleft = 1 Then
            swapNotes(notenum, notenum - 1)
            Exit Do
          EndIf
        Case 27 'ESC
          Exit Do
      End Select
    EndIf
  Loop
  loadnotes(notenum)
End Sub

'convert hex string to color
'will return black if string is invalid
Function hex2col(colorrgb$)
  hex2col=0
  If Len(colorrgb$) = 6 Then
    hex2col=Val("&h"+colorrgb$)
  EndIf
End Function

'Compute battery info
Function batlevel$()
  buildstring$ = "+"
  If MM.Info(charging) = 0 Then
    buildstring$ = " "
  EndIf
  buildstring$ = buildstring$ + Str$(MM.Info(battery))
  batlevel$ = buildstring$ + "%"
End Function

'compute library info file
Function libinfo$()
  libinfo$ = path$ + libinfofilename$ + dataext$
End Function

'compute book foldername
Function bookfolder$(whatbook As integer)
  bookfolder$ = path$ + Str$(whatbook)
End Function

'compute book info filename
Function bookinfo$(whatbook As integer)
  bookinfo$ = path$ + Str$(whatbook) + bookinfoext$
End Function

'compute tempfile name
Function tempfile$(whatnote As integer)
  filename$ = path$
  filename$ = filename$ + Str$(booknum)
  filename$ = filename$ + "\"
  filename$ = filename$ + Str$(whatnote)
  filename$ = filename$ + tempext$
  tempfile$ = filename$
End Function

'compute note filename
Function notefile$(whatnote As integer)
  filename$ = path$
  filename$ = filename$ + Str$(booknum)
  filename$ = filename$ + "\"
  filename$ = filename$ + Str$(whatnote)
  filename$ = filename$ + dataext$
  notefile$ = filename$
End Function

'check if library exist
Function haslibrary()
  haslibrary = MM.Info(exists dir path$)
End Function

'check if book exist
Function hasbook(whatbook As integer)
  hasbook = MM.Info(exists dir bookfolder$(whatbook))
End Function

'check if bookinfo exist
Function hasbookinfo(whatbook As integer)
  hasbookinfo = MM.Info(exists file bookinfo$(whatbook))
End Function

'check if note exist
Function hasnote(whatnote As integer)
  hasnote = MM.Info(exists file notefile$(whatnote))
End Function

'find next available book
Function nextBookSpot(whatbook As integer)
  nextBookSpot = whatbook
  Do While hasbook(nextBookSpot) = 1
    nextBookSpot = nextBookSpot + 1
  Loop
End Function

'find next available spot
Function nextNoteSpot(whatnote As integer)
  nextNoteSpot = whatnote
  Do While hasnote(nextNoteSpot) = 1
    nextNoteSpot = nextNoteSpot + 1
  Loop
End Function

'save book info
Sub writeBookinfo(infotoadd$ As string)
  Open bookinfo$(booknum) For output As filehandle
    Print #filehandle, infotoadd$
  Close #filehandle
End Sub

'store main data to file
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
   Close #filehandle
End Sub

'handle changing font
Sub fontchanged
  If lastsize <> notesize Then
    lastsize = notesize
    storelib
  EndIf
End Sub

'handle changing book
Sub bookchanged
  If lastbook <> booknum Then
    lastbook = booknum
    storelib
  EndIf
End Sub

'save the new note to the file
Sub writeNote(notetoadd$ As string)
  Open notefile$(notenum) For append As filehandle
    Print #filehandle, notetoadd$
  Close #filehandle
  loadnotes(notenum)
End Sub

'add new note at the end
Sub addnote(notetoadd$ As string)
  notenum = nextNoteSpot(notenum)
  CLS
  writeNote(notetoadd$)
End Sub

'move notes to add one here
Sub insertNoteHere(notetoadd$ As string)
  addNoteSpotAt(notenum)
  CLS
  writeNote(notetoadd$)
End Sub

'get numbe of lines
Function lastLine(whatnote As integer)
  Open notefile$(whatnote) For INPUT As filehandle
  lineread=0
  Do While Not Eof(filehandle)
    Line Input #filehandle, note$
    lineread=lineread+1
  Loop
  Close #filehandle
  lastLine = lineread
End Function

'get specific line
Function getLine$(whatnote As integer, lineNum As integer)
  Open notefile$(whatnote) For INPUT As filehandle
  lineread=1
  getLine$=""
  Do While Not Eof(filehandle)
    Line Input #filehandle, note$
    If lineread=lineNum Then
      getLine$=note$
    EndIf
    lineread=lineread+1
  Loop
  Close #filehandle
End Function

'mark current line
Sub markNote(whatnote As integer, lineToMark As integer)
  Open tempfile$(whatnote) For append As temphandle
  Open notefile$(whatnote) For INPUT As filehandle
    lineread=1
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      If lineread=lineToMark Then
        marklen = Len(mark$)
        notelen = Len(note$)
        If notelen > marklen Then
          If Left$(note$, marklen) = mark$ Then
            Print #temphandle, Right$(note$, (notelen - marklen))
          Else
            Print #temphandle, mark$ + note$
          EndIf
        Else
          Print #temphandle, note$
        EndIf
      Else
        Print #temphandle, note$
      EndIf
      lineread=lineread+1
    Loop
  Close #filehandle
  Close #temphandle

  Kill notefile$(whatnote)
  Rename tempfile$(whatnote) As notefile$(whatnote)
End Sub

'add text within note
Sub addInNote(whatnote As integer, lineToAdd$ As string, lineTo As integer)
  Open tempfile$(whatnote) For append As temphandle
  Open notefile$(whatnote) For INPUT As filehandle
    lineread=1
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      If lineread=lineTo Then
        Print #temphandle, lineToAdd$
      EndIf
      Print #temphandle, note$
      lineread=lineread+1
    Loop
  Close #filehandle
  Close #temphandle

  Kill notefile$(whatnote)
  Rename tempfile$(whatnote) As notefile$(whatnote)
End Sub

'alter note--swap two lines
Sub alterNote(whatnote As integer, lineFrom As integer, lineTo As integer)
  lineinsert = lineTo
  If lineFrom < lineTo Then lineinsert = lineTo + 1
  addAfter = 0
  If lineTo = lastLine(whatnote) Then addAfter = 1
  lineToMove$=getLine$(whatnote,lineFrom)

  Open tempfile$(whatnote) For append As temphandle
  Open notefile$(whatnote) For INPUT As filehandle
    lineread=1
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      If lineread=lineinsert Then
        Print #temphandle, lineToMove$
      EndIf
      If lineread<>lineFrom Then
        Print #temphandle, note$
      EndIf
      lineread=lineread+1
    Loop
    If addAfter = 1 Then Print #temphandle, lineToMove$
  Close #filehandle
  Close #temphandle

  Kill notefile$(whatnote)
  Rename tempfile$(whatnote) As notefile$(whatnote)
End Sub

'create library
Sub createlibrary
  If haslibrary() = 0 Then
    Mkdir path$
    lastbook = 1
    lastsize = nsmed
    notesize = nsmed
  Else 'use preexisting library
    getlibinfo
  EndIf
End Sub

'create book
Sub createbook(whatbook As integer)
  If hasbook(whatbook) = 1 Then
    loadbook(whatbook)
  Else
    If hasbookinfo(whatbook) = 0 Then
      notebook$ = getBookname$()
      booknum = whatbook
      writeBookinfo(notebook$)
    Else
      notebook$ = loadbookinfo$(whatbook)
    EndIf
    newbook(whatbook)
  EndIf
  booknum = whatbook
  bookchanged
End Sub

'create and load book
Sub createloadbook
  CLS
  createbook(nextBookSpot(booknum))
  bookchanged
  loadnotes(notenum)
End Sub

'get main data fron file
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
End Sub

'load bookinfo
Function loadbookinfo$(whatbook As integer)
  loadbookinfo$ = notebook$
  If hasbookinfo(whatbook) = 1 Then
    ' load existing info from file
    Open bookinfo$(whatbook) For INPUT As filehandle
    Line Input #filehandle, loadbookinfo$
    Close #filehandle
  EndIf
End Function

'load book
Sub loadbook(whatbook As integer)
  If hasbook(whatbook) = 1 Then
    booknum = whatbook
    notebook$ = loadbookinfo$(whatbook)
  EndIf
End Sub

'load and display the note
Sub loadnotes(whatnote As integer)
  CLS
  noteheader(whatnote)
  loadnotetext(whatnote)
  notefooter(whatnote)
End Sub

'get note text from disk
Sub loadnotetext(whatnote As integer)
  If hasnote(whatnote) = 1 Then
    ' load existing notes from file
    Font (notesize)
    Open notefile$(whatnote) For INPUT As filehandle
    linehigh=1
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      If mode$ <> "read" And linehigh=linedit Then
        Color colhig
      Else
        Color coltxt
      EndIf
      If mode$ <> "read" And note$ = "" And linehigh=linedit Then
        note$="<empty line>"
        Color colhhl
      EndIf
      marklen = Len(mark$)
      notefluo = Len(note$)-marklen
      revertcolor = MM.Info(fcolour)
      If Left$(note$, marklen) = mark$ Then
        Color bgcolor, revertcolor
        note$ = Right$(note$, notefluo)
      EndIf
      Print note$
      Color revertcolor, bgcolor
      linehigh=linehigh+1
    Loop
    Close #filehandle
  EndIf
  Font (1)
End Sub

'change displayed note
Sub first
  notenum = 1
  loadnotes(notenum)
End Sub

'change displayed note
Sub last
  notenum = nextNoteSpot(notenum)
  If notenum > 1 Then
    notenum = notenum - 1
  EndIf
  loadnotes(notenum)
End Sub

'change displayed note
Sub right
  'only go right if not on empty note
  If hasnote(notenum) = 1 Then
    notenum = notenum + 1
  EndIf
  loadnotes(notenum)
End Sub

'change displayed note
Sub left
  If notenum > 1 Then
    notenum = notenum - 1
  EndIf
  loadnotes(notenum)
End Sub

'previous book
Sub up
  If booknum > 1 Then
    booknum = booknum - 1
  Else
    booknum = nextBookSpot(booknum) - 1
  EndIf
  bookchanged
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub

'fist book
Sub shiftup
  booknum = 1
  bookchanged
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub

'next book
Sub down
  toofar = nextBookSpot(booknum)
  booknum = booknum + 1
  If booknum = toofar Then
    booknum = 1
  EndIf
  bookchanged
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub

'last book
Sub shiftdown
  booknum = nextBookSpot(booknum) - 1
  bookchanged
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub


'get book name
Function getBookname$()
  Color colask
  Print "Name of the notebook"
  Color colheader
  Font (7)
  Line Input bookname$
  titlen = Len(bookname$)
  If titlen > 45 Then
    titlen = 45
  EndIf
  getBookname$ = Left$(bookname$, titlen)
  Font (1)
End Function

'rename current book
Sub renamebook
  CLS
  Color colask
  Font (1)
  Print "Rename book."
  Print "current name is : "
  Color coltxt
  Font (7)
  Print notebook$
  Color colheader
  Font (1)
  notebook$ = getBookname$()
  writeBookinfo(notebook$)
  loadnotes(notenum)
End Sub

'data to note
Function getNote$()
  Color colask
  Print "text to note"
  Color coltxt
  Font (notesize)
  Line Input getNote$
  Font (1)
End Function

'create book folder
Sub newbook(whatbook As integer)
  If hasbook(whatbook) = 0 Then
    Mkdir bookfolder$(whatbook)
  EndIf
End Sub

'add new note
Sub newnote
  CLS
  addnote(getNote$())
End Sub

'add note at curent location
Sub insertNote
  CLS
  insertNoteHere(getNote$())
End Sub

'add to existing note
Sub addtonote
  CLS
  loadnotetext(notenum)
  writeNote(getNote$())
End Sub

'move file right
Sub addNoteSpotAt(dst As integer)
  nxt = nextNoteSpot(dst)
  Do While nxt > dst
    cur = nxt - 1
    Rename notefile$(cur) As notefile$(nxt)
    nxt = nxt - 1
  Loop
End Sub

'move folder left
Sub renameAtBook(cur As integer)
  nxt = cur + 1
  If hasbook(nxt) Then
    Rename bookfolder$(nxt) As bookfolder$(cur)
    Rename bookinfo$(nxt) As bookinfo$(cur)
    'domino
    renameAtBook(nxt)
  EndIf
End Sub

'move file left
Sub renameAtNote(cur As integer)
  nxt = cur + 1
  If hasnote(nxt) Then
    Rename notefile$(nxt) As notefile$(cur)
    'domino
    renameAtNote(nxt)
  EndIf
End Sub

'swap two files
Sub swapNotes(nfrom As integer, nto As integer)
  If hasnote(nfrom) And hasnote(nto) Then
    Rename notefile$(nfrom) As tempfile$()
    Rename notefile$(nto) As notefile$(nfrom)
    Rename tempfile$() As notefile$(nto)
    notenum = nto
  EndIf
End Sub

'delete book
Sub deletebook(whatbook As integer)
  deletepath$ = bookfolder$(whatbook)
  dltf$=Dir$(deletepath$ + "\*.*",FILE)
  Do While dltf$<>""
    Kill deletepath$ + "\" + dltf$
    dltf$ = Dir$()
  Loop
  Rmdir deletepath$
  Kill bookinfo$(whatbook)
  renameAtBook(whatbook)
End Sub

'delete note
Sub deletenote(whatnote As integer)
  If hasnote(whatnote) = 1 Then
    Kill notefile$(whatnote)
    renameAtNote(whatnote)
  EndIf
  'display new current note
  If hasnote(whatnote) = 0 Then
    'the deleted file was last, move
    left
  Else
    'display at current index
    notenum = whatnote
    loadnotes(whatnote)
  EndIf
End Sub

'display note biger
Sub biggerfont
  If notesize = nsmin Then
    notesize = nssml
  Else If notesize = nssml Then
    notesize = nsmed
  Else If notesize = nsmed Then
    notesize = nsbig
  Else If notesize = nsbig Then
    notesize = nsbgr
  Else If notesize = nsbgr Then
    notesize = nsmax
  EndIf
  fontchanged
  loadnotes(notenum)
End Sub

'display note smaller
Sub smallerfont
  If notesize = nsmax Then
    notesize = nsbgr
  Else If notesize = nsbgr Then
    notesize = nsbig
  Else If notesize = nsbig Then
    notesize = nsmed
  Else If notesize = nsmed Then
    notesize = nssml
  Else If notesize = nssml Then
    notesize = nsmin
  EndIf
  fontchanged
  loadnotes(notenum)
End Sub

Sub newmode(inmode$ As string)
  mode$=inmode$
  linedit = 1
  loadnotes(notenum)
End Sub

Sub checkkey
  If mode$="read" Then
    checkReadKey
  ElseIf mode$="edit" Then
    checkEditKey
  EndIf
End Sub

Sub checkEditKey
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 27 'ESC
        newmode("read")
      Case 128 'up
        If linedit>1 Then
          linedit = linedit - 1
          loadnotes(notenum)
        EndIf
      Case 129 'down
        If linedit < lastLine(notenum) Then
          linedit = linedit + 1
          loadnotes(notenum)
        EndIf
      Case 145 '[F1] move up
        If linedit > 1 Then
          alterNote(notenum, linedit, linedit - 1)
          linedit = linedit - 1
          loadnotes(notenum)
        EndIf
      Case 146 '[F2] add to
        addtonote
      Case 147 '[F3] move dn
        If linedit < lastLine(notenum) Then
          alterNote(notenum, linedit, linedit + 1)
          linedit = linedit + 1
          loadnotes(notenum)
        EndIf
      Case 148 '[F4] insert
        CLS
        addInNote(notenum, getNote$(), linedit)
        loadnotes(notenum)
      Case 149 '[F5] rm
        If lastLine(notenum) > 1 Then
          alterNote(notenum, linedit, 0)
          If linedit > 1 Then linedit = linedit - 1
          loadnotes(notenum)
        EndIf
      Case 9 '[TAB]
        markNote(notenum, linedit)
        loadnotes(notenum)
     End Select
  EndIf
End Sub

Sub checkReadKey
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 146 '[F2] add to note
        addtonote
      Case 97 '[A]dd to note
        addtonote
      Case 148 '[F4] insert
        insertnote
      Case 105 '[I]nsert
        insertnote
      Case 147 '[F3] new
        newnote
      Case 110 '[N]ew
        newnote
      Case 8 '[<-BACK]
        askDelete
      Case 134 '[HOME] (shift-tab)
        first
      Case 135 '[END] (shift-del)
        last
      Case 128 'up
        up
      Case 136 'shift-up
        shiftup
      Case 129 'down
        down
      Case 137 'shift-down
        shiftdown
      Case 131 'right
        right
      Case 130 'left
        left
      Case 134 '[HOME] (shift-tab)
        first
      Case 135 '[END] (shift-del)
        last
      Case 128 'up
        up
      Case 136 'shift-up
        shiftup
      Case 129 'down
        down
      Case 137 'shift-down
        shiftdown
      Case 131 'right
        right
      Case 130 'left
        left
      Case 114 '[R]eload
        loadnotes(notenum)
      Case 145 '[F1] help
        helpscreen
      Case 150 '[F6] move note
        askmove
      Case 151 '[F7] rename book
        renamebook
      Case 152 '[F8] add a book
        createloadbook
      Case 153 '[F9] edit note mode
        newmode("edit")
      Case 154 '[F10] add a book
        askDebook
      Case 43 'shift-[+]
        biggerfont
      Case 95 'shift-[-]
        smallerfont
      Case 113 '[Q]uit
        Exit Do
      Case 27 'ESC
        Exit Do
   Case 67 'ALT-C = configure
       Color 0,0
       CLS
    Run "col.bas"
    End Select
  EndIf
End Sub

'begin here
createlibrary
'get last book + validate
createbook(lastbook)
loadnotes(notenum)
Do
  checkkey
Loop
CLS
End
