# [NOTE.BAS](https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/note/note.bas) - Simple note editor for PicoCalc

## tinkering with MMBasic and programs

When I needed to take note and figured the touchscreen of my smartphone was not the correct way to do it, I wondered if there was an easy way to store notes on my PicoCalc.

So I made a simple note editor.


## disclaimer
this is a very crude software coded directly on the PicoCalc.

Use at your own risk.

But have fun.

 at 
## instructions
The program will create a notes folder at the root of the SD card. The path is within the BAS, but currently points to b:\notes\

It will store each note (numbered) as a file with .data extension in a notebook (collection) subfolder. It is plain text.
Each subfolder (notebook) will have a .info file for data storage.


### KEYS
F1 shows an help screen

F2 to add to an existing note
F3 to create a new note at the end of the notebook
F4 to insert a note at the current location
Backspace - to delete current note. It will domino the files back to remove the "hole"

Left/right/home/end  navigate notes
up/down navigate notebooks

F7 to rename a book
F8 to add a new book
F10 to remove a whole book (permanently delete)

ESC to exit
