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
  footxt$ = "<-"
  footxt$ = footxt$ + Str$(whatnote)
  footxt$ = footxt$ + "->"
  footxt$ = footxt$ + " [A]dto"
  footxt$ = footxt$ + " [I]ns"
  footxt$ = footxt$ + " [N]ew"
  Print @(0,295) footxt$
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

'get book name
Function getBookname$()
  Print "Naame of the notebook"
  Line Input bookname$
  titlen = Len(bookname$)
  If titlen > 20 Then
    titlen = 20
  EndIf
  getBookname$ = Left$(bookname$, titlen)
End Function

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

'move file left
Sub renameAtNote(cur As integer)
  nxt = cur + 1
  If hasnote(nxt) Then
    Rename notefile$(nxt) As notefile$(cur)
    'domino
    renameAtNote(nxt)
  EndIf
End Sub

'delete note
Sub deletenote(notenum As integer)
  If hasnote(notenum) = 1 Then
    Kill notefile$(notenum)
    renameAtNote(notenum)
  EndIf
  'display new current note
  If hasnote(notenum) = 0 Then
    'the deleted file was last, move
    left
  Else
    'display at current index
    loadnotes(notenum)
  EndIf
End Sub

'begin here
createbook(booknum)
loadnotes(notenum)
Do
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 97 '[a]dd to note
        addtonote
      Case 105 '[i]nsert
        insertnote
      Case 110 '[n]ew
        newnote
      Case 8 '[<-BACK]
        ' deletenote(notenum)
        askDelete
      Case 134 '[HOME] (shift-tab)
        first
      Case 135 '[END] (shift-del)
        last
      Case 131 'right
        right
      Case 130 'left
        left
      Case 114 '[r]eload
        loadnotes(notenum)
      Case 113 '[q]uit
        Exit Do
      Case 27 'ESC
        Exit Do
    End Select
  EndIf
Loop
CLS
End
