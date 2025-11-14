'note editor
filehandle = 1
filename$ = "notes.data"
path$ = "b:\notes\"
bookinfoext$ = ".inf"
dataext$ = ".data"
note$ = ""
notenum = 1
notebook$ = "notebook"
booknum = 1
ver$ = "V1.0"

'draw header
Sub noteheader(whatnote As integer)
  headtext$ = "["
  headtext$ = headtext$ + notebook$
  headtext$ = headtext$ + "] #"
  If hasnote(whatnote) = 1 Then
   headtext$ = headtext$ + Str$(whatnote)
  Else
    headtext$ = headtext$ + "-"
  EndIf
  Print @(0,0) headtext$
End Sub

'draw footer
Sub notefooter(whatnote As integer)
  npagetxt$ = "<-"
  npagetxt$ = npagetxt$ + Str$(whatnote)
  npagetxt$ = npagetxt$ + "->"
  footxt$ = "Note " + ver$ + "     "
  footxt$ = footxt$ + "[F1] or help"
  Print @(0,295) footxt$
  Print @(250,295) npagetxt$
End Sub

'draw helpscreen
Sub helpscreen
  CLS
  Print "  *** PicCalc simple notepad " + ver$ + " ***"
  Print ""
  Print "Meant to take note, this software"
  Print "stores notes in files in the folder"
  Print path$
  Print ""
  Print ""
  Print "To Use:"
  Print "[F1]       this help"
  Print "[F2]       add to current note"
  Print "[F3]       New note (end of book)"
  Print "[F4]       Insert note (here)"
  Print "[<-back]   delete current note"
  Print "LEFT dpad  previous note"
  Print "RIGHT dpad next note"
  Print "[HOME]     first note in the book"
  Print "[END]      last note in the book"
  Print "UP/DOWN    change book"
  Print ""
  Print "[F7]       rename current book"
  Print "[F8]       add a book"
  Print "[F10]      delete current book"
  Print ""
  Print "[ESC]      exit"
  Print ""
  Print @(0,295) "       Press any key to continue"
  Do While Inkey$ = ""
  Loop
  CLS
  loadnotes(notenum)
End Sub

'ask to delete book
Sub askDebook
  CLS
  Print "delete book " + notebook$ + " (Y/N) ?"
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
End Sub

'ask to delete note
Sub askDelete
  CLS
  loadnotetext(notenum)
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

'compute book foldername
Function bookfolder$(whatbook As integer)
  bookfolder$ = path$ + Str$(whatbook)
End Function

'compute book info filename
Function bookinfo$(whatbook As integer)
  bookinfo$ = path$ + Str$(whatbook) + bookinfoext$
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
End Sub

'create and load book
Sub createloadbook
  CLS
  createbook(nextBookSpot(booknum))
  loadnotes(notenum)
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
    Open notefile$(whatnote) For INPUT As filehandle
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      Print note$
    Loop
    Close #filehandle
  EndIf
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
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub

'fist book
Sub shiftup
  booknum = 1
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
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub

'last book
Sub shiftdown
  booknum = nextBookSpot(booknum) - 1
  notebook$ = loadbookinfo$(booknum)
  notenum = 1
  loadnotes(notenum)
End Sub


'get book name
Function getBookname$()
  Print "Name of the notebook"
  Line Input bookname$
  titlen = Len(bookname$)
  If titlen > 20 Then
    titlen = 20
  EndIf
  getBookname$ = Left$(bookname$, titlen)
End Function

'rename current book
Sub renamebook
  CLS
  Print "Rename book."
  Print "current name is : " + notebook$
  notebook$ = getBookname$()
  writeBookinfo(notebook$)
  loadnotes(notenum)
End Sub

'get data to store
Function getNote$()
  Print "text to note"
  Line Input getNote$
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

'begin here
createbook(booknum)
loadnotes(notenum)
Do
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 144 '[F2] add to note
        addtonote
      Case 97 '[A]dd to note
        addtonote
      Case 146 '[F4] insert
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
      Case 114 '[R]eload
        loadnotes(notenum)
      Case 145 '[F1] help
        helpscreen
      Case 151 '[F7] rename book
        renamebook
      Case 152 '[F8] add a book
        createloadbook
      Case 154 '[F10] add a book
        askDebook
      Case 113 '[Q]uit
        Exit Do
      Case 27 'ESC
        Exit Do
    End Select
  EndIf
Loop
CLS
End
