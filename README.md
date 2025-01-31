# Doom for the Atari Jaguar - Extended Edition

This project allows you to build Doom for the Jaguar under linux. It uses the
latest toolchain released by Atari which was put into the Public Domain. You
can read about the Jaguar saga elsewhere - we're just concerned with Doom. We
can thank Carl Forhan from Songbird Productions for that. He talked Carmack
into releasing the Jaguar source, then played with it enough to get it to work
on real hardware, then released the source for others to play with.

Having worked on Doom for a number of platforms, I always wanted to work on the
Jaguar version to make some improvements. And here it is. Since the Jaguar tools
for the PC were written for DOS, I use dosemu2 to run the compiler, assemblers,
and linker. Everything else is done from the linux terminal.

For simplicity, I'm just going to cover setting up dosemu2 in Ubuntu. You can
find it for other distros, and it's not hard to setup, but I'm going with what
I use - Ubuntu. You can find the Ubuntu PPA for dosemu2 here:
```
https://code.launchpad.net/~dosemu2/+archive/ubuntu/ppa
```
You then add the PPA to your software sources:
```
sudo add-apt-repository ppa:dosemu2/ppa
sudo apt update
```
Then you can install dosemu2 using your favorite software installer (I use the
Synaptic Package Manager app). Once you have dosemu2 installed, you'll want to
setup drive H: to point at your local copy of the repository. You should have
a .dosemu directory in your home directory (/home/username/.dosemu/). You will
copy the dosemurc file from the extra_files directory of the project. Edit the
file to set the path to wherever you cloned the repository. You are now ready
for the DOS side of building Doom. You'll need the gcc build essentials to do
the linux side of things. If you're contemplating building Doom, you should
know how to do this, so I'm not going to cover it here.

## Building JagDoomEX

Open a terminal in linux. Set your current directory to the project source.
```
cd /home/username/Projects/Jaguar/JagDoomEX/src
```
Assuming you don't have the wad file for the game, but you DO have the original
Jaguar Doom rom image (not provided!), copy the Jaguar Doom rom image into the
source directory, and make sure it's named "Doom.j64". You can then create the
wad file by running
```
make wad
```
in the terminal. This makes a file called doom.wad that has the appropriate
data from the original game. You can then delete the Doom.j64 file if you wish.
Now to build the game, you run
```
make clean
dosemu
```
You should now be in the dosemu2 terminal window. Inside that window, run
```
H:
cd src
runme
make
make boot
exitemu
```
You should now be back in the linux terminal with all the files needed to make
JagDoomEX. Do so by running
```
make rom
```
in the terminal. You should now have a file called JagDoomEX.j64 in the source
directory which is exactly 4194304 bytes in length. This rom file can be run in
a Jaguar emulator like BigPEmu, or on real hardware using a skunkboard or the
Jaguar GameDrive cart.

## New Features

You can select widescreen on/off in the Options menu. This makes Doom look the
proper aspect ratio on 16:9 TVs. Off assumes a standard 4:3 TV. Defaults to off,
and is saved in the e2prom.

## New Controls

C/B/A/PAUSE/OPTION remain as set in the game. The differences arise in the
number pad, which also affects the ProPad controller.
```
1 = select PISTOL
2 = FORWARD
3 = select SHOTGUN
4 = STRAFE LEFT
5 = BACKWARD
6 = STRAFE RIGHT
7 = select CHAINGUN
8 = select MISSILE LAUNCHER
9 = select PLASMA RIFLE
* = toggle between FIST/CHAINSAW
0 = select BFG9000
# = select AUTOMAP
* + # = reset game
```
4 and 6 are the same as the LEFT and RIGHT shoulder buttons on the ProPad, which
is why they are set for strafing. I set 2 and 5 to forward and backward because
I will be adding mouse support, and having those four buttons arranged as they
are will make it easier to play like using a keyboard and mouse on the PC. The
buttons 7, 8, and 9 map to the ProPad buttons Z, Y, and X, respectively. This
gives you quick access to the heavier weapons in Doom. I decided not to put the
BFG in there as it usually has limited ammo, so you really don't want to be 
accidentally selecting it. Likewise, selecting the fist or chainsaw is fairly
rare, so it could be one of the out-of-the-way buttons. When Doom 2 support gets
added, the SHOTGUN button will toggle between the shotgun and the super shotgun.
Note that you don't NEED a ProPad controller. It will work fine on a normal
Jaguar pad. You just don't have shoulder buttons, nor Z/Y/X.

The pad controller goes into port 1. When mouse support is done, it will plug
into port 2. You will need an Atari ST or Amiga mouse with appropriate adapter,
or a PS/2 mouse with appropriate adapter for upcoming mouse support.

## Acknowledgements
```
John Carmack for writing such an awesome game, and releasing it to the public.
Carl Forhan for arranging for the code, and doing the initial work to get it
running.
CyranoJ for fixing the offset in the HUD in the code released by Carl.
Bitbotherer for the tips that allowed me to get init.s working on real harware.
```
## Known Bugs

The network code is still as it was - kinda buggy. I don't know if or when I
will get to it. I only have one Jaguar, and the JagGD cart is not compatible
with JagLink in any case.

## Changelog
```
250131 - Anamorphic widescreen option implemented.
241216 - Unlocked all levels.
241216 - Another fix for init.s. Passed stability test.
241215 - Reverted back to using init.sav.
241215 - Fixed sprites sometimes visible thru walls bug.
241215 - Fixed transparent spectres on real hardware.
241214 - Fixed init.s to work with real hardware.
241210 - First commit to repo.
241209 - Fixed the spectre - now in Super Ghostly Phantasmagoric™ rendering.
241209 - Remapped the controls to allow for the ProPad.
```
