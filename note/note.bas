'note editor
filehandle = 1
filename$ = "notes.data"
path$ = "b:\notes\"
dataext$ = ".data"
note$ = ""
notenum = 1

'draw header
Sub noteheader(whatnote As integer)
  Print @(0,0) whatnote
End Sub

'draw footer
Sub notefooter(whatnote As integer)
  Print @(0,295) "<- " + Str$(whatnote) + " -> move, [A]dd, [D]elete, [Q]uit"
End Sub

'compute mote filename
Function notefile$(whatnote As integer)
  notefile$ = path$ + Str$(whatnote) + dataext$
End Function

'check if note exist
Function hasnote(whatnote As integer)
  hasnote = MM.Info(exists file notefile$(whatnote))
End Function

'save new note
Sub addnote(notetoadd$ As string)
  Do While hasnote(notenum) = 1
    notenum = notenum + 1
  Loop
  'save the new note to the file
  Open notefile$(notenum) For append As filehandle
  Print #filehandle, notetoadd$
  Close #filehandle
  loadnotes(notenum)
End Sub

'get note from disk
Sub loadnotes(whatnote As integer)
  CLS
  noteheader(whatnote)
  If hasnote(whatnote) = 1 Then
    ' load existing notes from file
    Open notefile$(whatnote) For INPUT As filehandle
    Do While Not Eof(filehandle)
      Line Input #filehandle, note$
      Print note$
    Loop
    Close #filehandle
  EndIf
  notefooter(whatnote)
End Sub

'change note
Sub right
  'only go right if not on empty note
  If hasnote(notenum) = 1 Then
    notenum = notenum + 1
  EndIf
  loadnotes(notenum)
End Sub

'change note
Sub left
  If notenum > 1 Then
    notenum = notenum - 1
  EndIf
  loadnotes(notenum)
End Sub

'add new note
Sub newnote
  Print "enter a note"
  Line Input note$
  addnote(note$)
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
loadnotes(notenum)
Do
  cmd$ = Inkey$
  If cmd$ <> "" Then
    Select Case Asc(cmd$)
      Case 97 '[a]dd
        newnote
      Case 100 '[d]elete
        deletenote(notenum)
      Case 131
        right
      Case 130
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

End
