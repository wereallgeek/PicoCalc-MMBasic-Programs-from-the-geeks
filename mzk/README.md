# [MZK.BAS](https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/mzk/mzk.bas) - playing MuZiK on the PicoCalc

## tinkering with MMBasic and programs

Playing music on your calculator is very geeky. PicoCalc is not any calculator, it is a raspberry pi pico.
And it can play music. MP3 on this project.


This project is what happens when you have too much time on your hands, and see a cool idea, and try something, and mashup something else, and test, and tinker, and end up with something else.


At its base, there is the [matrix animation](https://github.com/VanzT/PicoCalc-Toys/blob/master/matrix.bas) software by [VanzT](https://github.com/VanzT). This is not really a fork of his [PicoCalc-Toys](https://github.com/VanzT/PicoCalc-Toys) as the program really just mashes it up with another program...

There is a thread on the PicoCalc section of [Clockwork pi forums](https://forum.clockworkpi.com/) about [Building your own mp3 player](https://forum.clockworkpi.com/t/building-my-own-mp3-player-in-mmbasic/) in MMBasic, with interesting (and functionning) code from [Dominikus_Koch](https://forum.clockworkpi.com/u/dominikus_koch/summary) for a basic MP3 player.

This is a nice headstart into making some MP3 music playing software!


What happens if you join the MP3 player with the Matrix animation? You get a Matrix MP3 player.

There was already the ability to display one cover art image... Add the ability to display a cover with the same name as the mp3. Make the matrix/cover art selectable. and what do you get?

I don't know. But it is very geeky...



## disclaimer
this is a very crude software coded directly on the PicoCalc which is initially based on two different programs in different coding standards. The result is very crude.

Use at your own risk.

But have fun.



## instructions
put the MP3s in a folder b:/mp3/ on the PicoCalc SD card. (or change the folder in the .bas file)

The supplied /mp3/cover.bmp 320x320 image can be use as a default image or can be changed to your need
Add up to 99 MP3 files

Each MP3 can had its own 320x320 (or less) image with the same name (extension: bmp) to display
run "mzk" 

### display
The top line is an information line that shows the filename and elapsed time.

First character is S for shuffle, - otherwise



### KEYS
Left/right previous & next song

F1 setup for MATRIX animation

F2 setup for COVER image

TAB Toggle Shuffle mode

ESC exit

L (while in MATRIX mode) to emable LED strip (untested, came with VanzT's awesome matrix software)
