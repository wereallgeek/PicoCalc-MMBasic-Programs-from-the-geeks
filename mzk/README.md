# [MZK.BAS](https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/mzk/mzk.bas) - playing MuZiK on the PicoCalc

## tinkering with MMBasic and programs

Playing music on your calculator is very geeky. PicoCalc is not any calculator, it is a raspberry pi pico.
And it can play music. MP3 and MOD files on this project.


This project is what happens when you have too much time on your hands, and see a cool idea, and try something, and mashup something else, and test, and tinker, and end up with something else.


At its base, there is the [matrix animation](https://github.com/VanzT/PicoCalc-Toys/blob/master/matrix.bas) software by [VanzT](https://github.com/VanzT). This is not really a fork of his [PicoCalc-Toys](https://github.com/VanzT/PicoCalc-Toys) as the program really just mashes it up with another program...

There is a thread on the PicoCalc section of [Clockwork pi forums](https://forum.clockworkpi.com/) about [Building your own mp3 player](https://forum.clockworkpi.com/t/building-my-own-mp3-player-in-mmbasic/) in MMBasic, with interesting (and functionning) code from [Dominikus_Koch](https://forum.clockworkpi.com/u/dominikus_koch/summary) for a basic MP3 player.

This is a nice headstart into making some music playing software!


What happens if you join the MP3 player with the Matrix animation? You get a Matrix MP3 player. What if next you add Modfile compatibility??

There was already the ability to display one cover art image... Add the ability to display a cover with the same name as the audiofile (mp3 or mod). Make the matrix/cover art selectable. and what do you get?

I don't know. But it is very geeky...



## disclaimer
this is a very crude software coded directly on the PicoCalc which is initially based on two different programs in different coding standards. The result is very crude.

Use at your own risk.

But have fun.

<img src="https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/mzk/assets/MZKalbum.jpg?raw=true" width="300"/> <img src="https://github.com/wereallgeek/PicoCalc-MMBasic-Programs-from-the-geeks/blob/main/mzk/assets/MZKmatrix.jpg?raw=true" width="300"/>


## instructions
put the MP3s, MODs and cover BMPs in a folder b:/mzk/ on the PicoCalc SD card. (or change the folder in the .bas file)

The supplied /mzk/cover.bmp 320x320 image can be use as a default image or can be changed to your need
Add up to 127 audio files of the MP3 and MOD variety.
MP3s may need to be converted as not everybitrates seems compatible with the pi pico
MOD files are to be lower than 192k

Each audio file can have its own 320x320 (or less) image with the same name (extension: bmp) to display
run "mzk" 

In PicoMite, run these commands

#### OPTION CPUSPEED 200000
  -- this will overclock the pi and reboot
#### OPTION MODBUFF ENABLE 192
  -- this will enable modfile buffering on the A: drive. This process will reformat the A: drive so be sure to backup anything valuable.

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
