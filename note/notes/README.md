# [NOTE.BAS](https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/note/note.bas) - Simple note editor for PicoCalc

## tinkering with MMBasic and programs

When I needed to take note and figured the touchscreen of my smartphone was not the correct way to do it, I wondered if there was an easy way to store notes on my PicoCalc.

So I made a simple note editor.


## disclaimer
this is a very crude software coded directly on the PicoCalc.

Use at your own risk.

But have fun.


## instructions
The path to files is within the BAS, but currently points to b:\notes\
I have put a notes folder in this GIT as an example.

The program would store each note (numbered) as a file with .data extension in a notebook (collection) subfolder. It is plain text.
Each subfolder (notebook) will have a .info file for data storage.


### KEYS
F1 shows an help screen

Left/right/home/end  navigate notes

A to add to a note. 

N for new note - It will be added at the end of current notes

I for insert note - like new note but at current location

Backspace - to delete current note. It will domino the files back to remove the "hole"

ESC to exit

R to reload
