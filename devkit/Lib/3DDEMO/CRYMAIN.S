;*======================================================================*
;*                TITLE:                  TURTLE.S                      *
;*                Function:               Complete 3D Turtle Demo       *
;*                                                                      *
;*                Project #:              RAPIER                        *
;*                Programmer:             Rob Zdybel                    *
;*                                                                      *
;*              COPYRIGHT 1993 Atari Computer Corporation               *
;*          UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,         *
;*          PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR          *
;*        THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.       *
;*                            ALL RIGHTS RESERVED.                      *
;*                                                                      *
;*======================================================================*

	include "jaguar.inc"
;
;	EXTERNAL SYMBOLS
;
	.extern	cube		; Hand-Made Cube

	.extern TXTCRY_S
	.extern	text3D
	.extern	SORT_S
	.extern	bsort
	.extern	TURTLE_S
	.extern turtpak
	.extern TXTCRY_E
	.extern	SORT_E
	.extern	TURTLE_E
	.extern	cubesize		; Hand-Made Cube
	.extern cubedata
	.extern	gpuload
	.extern	gpurun
	.extern	gpuwait
	.extern	make_olist
	.extern	pad_now
	.extern	pad_shot
	.extern	readpad
	.extern	vblank
	.extern	vidinit
	.extern	Transform

	.extern	framecnt

	.extern	bmp_data
	.extern	DISPBUF0
	.extern DISPBUF1
	.extern ZBUF


	.extern	TexVertPtr
	.extern	VertexPtr
	.extern	EndOfPack

	.globl	_main
	.globl	eyepts
	.globl	texpts
	.globl	mthpts
	.globl	brpts
;
;	USEFUL DEFINES
;


RAMSIZE   	EQU	$1000		; 4K bytes
INPUT6		EQU	G_ENDRAM-$4	; pointer to parameter 6 for GPU
INPUT5		EQU	INPUT6-$4	; pointer to parameter 5 for GPU
INPUT4		EQU	INPUT5-$4	; pointer to parameter 4 for GPU
INPUT3		EQU	INPUT4-$4	; pointer to parameter 3 for GPU
INPUT2		EQU	INPUT3-$4	; pointer to parameter 2 for GPU
INPUT1		EQU	INPUT2-$4	; pointer to parameter 1 for GPU


;
;	PROGRAM SEGMENT
;
	.text

_main:
	move.l	#DISPBUF0+15,d0		; Set up screen buffers with
	and.l	#~15,d0			; draw_ptr on a 256 byte boundary
	move.l	d0,draw_ptr
	addq	#8,d0
	move.l	d0,disp_ptr

	jsr	initurtl	; initialize turtles

	moveq.l	#0,d0
	moveq.l	#-1,d1
	move	d0,gameover	; Game not over yet
	move.l	d1,pad_now	; Clear the joypad
	move	d0,ncubes

	move	d0,rotate_flg
	move	d1,amb_flg
	move	d1,sun_flg
	move	d1,bulb_flg
	move	d0,scrublist	; ScrubList = Nil
	move	#1,drawlist	; One Object

framelp:
	move.l	#$FFFFFFFF,PIT0

	jsr	clrscreen	; Clear the draw buffer
	jsr	do_sort

	lea	TXTCRY_S,a0
	lea	text3D,a1
	move.l	#TXTCRY_E,d0
	sub.l	#TXTCRY_S,d0
	jsr	gpuload		; Load Polyhedron Draw Routine into GPU RAM

	move.l	PIT0,d0
	move.l	d0,time1

	move	drawlist,newlist
drawlp:	move	newlist,d0	; WHILE (DrawList <> Nil) DO Draw Object
	beq	.drawxit
	move	d0,d1
	mulu	#turtlsiz,d0
	add.l	#turtle,d0	; D0 = Ptr to Turtle
	move.l	d0,a0
	move	turtlnk(a0),newlist
	cmp	#0,zposn(a0)
	blt	drawlp
	lea	turtle+turtlsiz,a1
	move.l	(a1)+,(a0)+	; Cheat rotation by copying from one cube
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+

	move.l	#cubedata,model_ptr	; point to the appropriate model

	jsr	gpuwait		; Wait for GPU Idle

	jsr	do_fastdraw	; Start GPU/BLTTER Polyhedron Draw
	bra	drawlp
.drawxit:


	jsr	readpad		; Read the Joypad

	jsr	gpuwait		; Wait for GPU Idle
	
	move.l	PIT0,d0
	move.l	d0,time2

	move.l	#$0,BORD1	; **KLUDGE** Bug Test

	move.l	disp_ptr,d0
	move.l	draw_ptr,disp_ptr
	move.l	d0,draw_ptr	; Swap buffers

	move.l	disp_ptr,bmp_data

	jsr	input		; DEBUG Interpret the Joypad input

	move.l	framecnt,d7	; D7 = Current Frame for sync later

.wsync:	cmp.l	framecnt,d7
	beq	.wsync		; Wait for video sync

;	move	gameover,d0
;	beq	framelp		; UNTIL (Game Over)

timecheck:
	move.l	PIT0,d0
	move.l	d0,time3
;	move.l	PIT0,d0
;	move.l	d0,time3
	; go forever
	bra	framelp
stop:
	illegal			; **KLUDGE** FORCE EXIT TO ADB
;	rts
	nop


;
;	SUBROUTINE AREA
;

;
;	INPUT  Interpret Joypad results and act accordingly
;
;	Given:
;		PAD_NOW = Current Joypad reading
;		PAD_SHOT = One-Shot Joypad
;
;	Returns:
;		Input handled
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		GPULOAD, DO_TURTLE
;
;	NOTE:  SHOULD CONVERT TO THE GPU.
input:
	movem.l	d0-d7/a0-a1,-(sp)


	lea	TURTLE_S,a0
	lea	turtpak,a1
	move.l	#TURTLE_E,d0
	sub.l	#TURTLE_S,d0
	jsr	gpuload		; Load Turtle Package into GPU
;
;	Handle ViewPoint Rotation and Translation
;
	move.l	pad_now,d0
	moveq	#0,d1
	btst.l	#JOY_UP,d0
	beq	.noup
	addq	#4,d1		; PITCH Down
.noup:	btst.l	#JOY_DOWN,d0
	beq	.nodwn
	subq	#4,d1		; PITCH Up
.nodwn:	moveq	#0,d2
	btst.l	#JOY_LEFT,d0
	beq	.nolft
	addq	#4,d2		; YAW Left
.nolft:	btst.l	#JOY_RIGHT,d0
	beq	.norit
	subq	#4,d2		; YAW Right
.norit:	moveq	#0,d3
	btst.l	#KEY_1,d0
	beq	.nocw
	subq	#4,d3		; ROLL Clockwise
.nocw:	btst.l	#KEY_3,d0
	beq	.noccw
	addq	#4,d3		; ROLL CounterClockwise
.noccw:	moveq	#0,d4
	btst.l	#KEY_STAR,d0
	beq	.norev
	subq	#4,d4		; REVERSE
.norev:	btst.l	#KEY_HASH,d0
	beq	.nofor
	addq	#4,d4		; FORWARD
.nofor:	btst.l	#FIRE_A,d0
	beq	.nomor
	add	#20,d4		; FAST FORWARD
.nomor:	moveq	#0,d0
	jsr	do_turtle	; ViewPoint Rotation and Translation
;
;	Handle all other input
;
	move.l	pad_shot,d0
	btst.l	#KEY_0,d0
	beq	.noquit
	move	#-1,gameover	; 0 = Exit
.noquit:
;
;	Light Source Toggle and Intensity
;
	btst.l	#FIRE_B,d0
	beq	.nob
	eor	#-1,sun_flg	; Toggle Sun On/Off
.nob:	btst.l	#FIRE_C,d0
	beq	.noc
	eor	#-1,bulb_flg	; Toggle InScene On/Off
.noc:	btst.l	#KEY_5,d0
	beq	.noa
	eor	#-1,amb_flg	; Toggle Ambient On/Off
.noa:	move.l	pad_now,d1
	moveq	#0,d2
	btst.l	#KEY_6,d1
	beq	.noinc
	addq	#1,d2		; Increase Intensity
; Since intensity isn't used in this version, overload this key and KEY_4
	cmp	#-160,stretch
	ble	.skipstm
	sub	#2,stretch
.skipstm:
.noinc:	btst.l	#KEY_4,d1
	beq	.nodec
	subq	#1,d2		; Decrease Intensity
	cmp	#0,stretch
	bge	.skipst
	add	#2,stretch
.skipst:
.nodec:	move	amb_flg,d1
	beq	.litem		; IF (Ambient On) THEN Alter Ambient Intensity
	add.b	d2,ambient+1
.litem:
	lea	litemodel,a0
	move	ambient,(a0)+
	move	sun_flg,d1	; Build a lighting model
	beq	.nosun
	add.b	d2,sun+1	; IF (Sun On) THEN Update Intensity and add Sun
	lea	sun,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.nosun:	move	bulb_flg,d1
	beq	.nobulb
	add.b	d2,bulb+1	; IF (Bulb On) THEN Update Intensity and add Bulb
	lea	bulb,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.nobulb:
	move.w	#0,(a0)+
;
;	CUBE Rotation and Propogation
;
	btst.l	#KEY_7,d0
	bne	.less
	btst.l	#KEY_9,d0
	beq	.same
	move	ncubes,d2	; More Cubes
	addq	#1,d2
	cmp	#8,d2
	bge	.same		; BUT No more than EIGHT
	bra	.cubes	
.less:	move	ncubes,d2	; Fewer Cubes
	subq	#1,d2
	bmi	.same		; BUT No fewer than ONE
.cubes:	lea	turtle+turtlsiz,a0
	move	d2,ncubes	; Build the CUBES
;; keep track of number!
	move	ncubes,d4
;	move	d4,nturtles
	beq	.noexp
	ext.l	d4
	add.l	#1,d4
	move.l	d4,d1
	mulu	d4,d1
	mulu	d4,d1
	move.l	d1,nturtles
.noexp:
	move	#0,drawlist
	move	#0,scrublist
	move	d2,d4
	move	d2,d5
	move	d2,d6
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#1,d7
.xcube:	move	d1,xposn(a0)	; Initialize a Cube
	move	d2,yposn(a0)
	move	d3,zposn(a0)
	move	drawlist,turtlnk(a0)
	move	d7,drawlist	; Link to DRAWLIST
	addq	#1,d7
	adda.l	#turtlsiz,a0
	add	#$200,d1
	dbra	d4,.xcube	; All X
	move	ncubes,d4
	moveq	#0,d1
	add	#$200,d2
	dbra	d5,.xcube	; All Y
	move	ncubes,d5
	moveq	#0,d2
	add	#$200,d3
	dbra	d6,.xcube	; All Z
.same:
  	btst.l	#KEY_8,d0
	beq	.norot
	eor	#-1,rotate_flg
.norot:	move	rotate_flg,d1
	beq	.done
	moveq	#1,d0
	moveq	#6,d1
	moveq	#6,d2
	moveq	#6,d3
	moveq	#0,d4
	jsr	do_turtle	; Cube Rotation
.done:
	movem.l	(sp)+,d0-d7/a0-a1
	rts


;
;	INITURTL   Initialize the TURTLE database
;
;	Given:
;		Control
;
;	Returns:
;		All Turtles initialized to Origin
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		
;
initurtl:
	movem.l	d0-d2/a0,-(sp)

	move.l	#0,nturtles
	move.w	#0,stretch

	lea	turtle,a0
	clr	d0
	move	#$4000,d1
	move	#maxturtl-1,d2
.clrlp:	move	d1,xrite(a0)	; FOR (All Turtles) DO
	move	d0,yrite(a0)	; Init to Origin - Ordirnally aligned
	move	d0,zrite(a0)
	move	d0,xdown(a0)
	move	d1,ydown(a0)
	move	d0,zdown(a0)
	move	d0,xhead(a0)
	move	d0,yhead(a0)
	move	d1,zhead(a0)
	move	d0,xposn(a0)
	move	d0,yposn(a0)
	move	d0,zposn(a0)
	move	d0,turtlnk(a0)
	add.l	#turtlsiz,a0
	dbra	d2,.clrlp

	lea	turtle,a0
	move	#$fe00,zposn(a0)	; **DOUBLE*KLUDGE** Position Viewpt in front of object

	movem.l	(sp)+,d0-d2/a0
	rts


;
;	CLRSCREEN   BLTTER Zero fill the draw buffer and Zbuffer
;
;	Given:
;		DRAW_PTR = Ptr to Current draw buffer
;
;	Returns:
;		Draw buffer and Zbuffer zeroed
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		clrbuffer
;
clrscreen:
	movem.l	d0/a0,-(sp)

	moveq.l	#0,d0
	move.l	draw_ptr,a0
	jsr	clrbuffer

	movem.l	(sp)+,a0/d0
	rts


;
;	CLRBUFFER   BLTTER Zero fill a 320x200x2 screen buffer
;
;	Given:
;		D0 = Data Pattern to fill with
;		A0 = Ptr to Buffer to Clear
;
;	Returns:
;		Draw buffer zeroed
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		None
;
clrbuffer:
	movem.l	d0-d1/a0-a1,-(sp)

	move.l	#B_CMD,a1
.waitblit:			; Wait for BLTTER Idle
	move.l	(a1),d1
	lsr.w	#1,d1
	bcc	.waitblit

 	move.l	#(PITCH2|PIXEL16|WID320|XADDPHR),A1_FLAGS
	move.l	a0,A1_BASE	; Point to the buffer

	move.l	d0,B_PATD
	move.l	d0,B_PATD+4	; Select Fill Pattern

	clr.l	d0
	move.l	d0,A1_PIXEL	; Point to (0,0)

	move.w	#1,d0
	swap	d0
	move.w	#-320,d0
	move.l	d0,A1_STEP	; Step -320 x, +1 y each line

	move.w	#200,d0
	swap	d0
	move.w	#320,d0
	move.l	d0,B_COUNT	; Do 320x200

	move.l	#(PATDSEL|UPDA1),B_CMD	; Start the BLTTER


	movem.l	(sp)+,d0-d1/a0-a1
	rts



;
;	DO_TURTLE   Execute the turtle package
;

;	Given:
;		d0 = Index of Turtle to Operate on
;		d1 = PITCH
;		d2 = YAW
;		d3 = ROLL
;		d4 = VELOCITY
;
;	Returns:
;		Turtle updated
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		GPURUN, GPUWAIT
;
do_turtle:
	movem.l	a0/d0-d4,-(sp)

	mulu	#turtlsiz,d0
	add.l	#turtle,d0	; D0 = Address of Turtle Record
	move.l	d0,INPUT1

	move.l	d1,INPUT2
	move.l	d2,INPUT3
	move.l	d3,INPUT4
	move.l	d4,INPUT5	; Remaining inputs

	lea	TURTLE_S,a0
	jsr	gpurun		; run the GPU program

	movem.l	(sp)+,a0/d0-d4
	rts


;
;	DO_FASTDRAW   Execute the Polyhedron Draw package
;
;	Given:
;		D0 = Ptr to Turtle to Draw
;
;	Returns:
;		Object Drawn
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		GPURUN
;
do_fastdraw:
	movem.l	a0/d0,-(sp)

	jsr	gpuwait

	move.l	d0,INPUT3	; Pass Ptr to Viewed Object

	move.l	model_ptr,INPUT1	; Ptr to Instance

	move.l	#turtle,INPUT2	; Turtle[0] is Viewer

	move.l	#litemodel,INPUT4	; Ptr to Lighting model

	move.l	draw_ptr,INPUT5	; tell GPU where to find parameters

	move.l	#instance,INPUT6	; use for vertex copies

	lea	TXTCRY_S,a0
	jsr	gpurun		; run the GPU program

	movem.l	(sp)+,a0/d0
	rts


;*======================================================================*
;*
;*	DO_SORT   Execute GPU Bubble Sort
;*
;*	Given:
;*		DRAWLIST  = Last Frame's Sorted See-ables (Inverted, Please)
;*		SCRUBLIST = Last Frame's UNSee-ables
;*		NTURTLES  = Number of Active Turtles
;*		TURTLE    = Turtle Record Array
;*
;*	Returns:
;*		DRAWLIST  = Painter's Sorted See-ables list root index
;*		SCRUBLIST =  UNSee-ables list root index
;*
;*	Register Usage:
;*		All Registers Restored
;*
;*	Externals:
;*		GPURUN, GPULOAD
;*
;*======================================================================*
do_sort:
	movem.l	a0/d0-d1,-(sp)

	jsr	gpuwait			;* Wait for GPU Idle

	lea	SORT_S,a0
	lea	bsort,a1
	move.l	#SORT_E,d0
	sub.l	#SORT_S,d0
	jsr	gpuload		; Load Polyhedron Draw Routine into GPU RAM

	move.l	#turtle,INPUT1		; Address of Viewpt Record
	move.l	#drawlist,INPUT2	; Address of Drawlist Root
	move.l	#scrublist,INPUT3	; Address of Scrublist Root
	move.l	#turtle+turtlsiz,INPUT4	; Address of Turtle[1]
	move.l	nturtles,d0
	beq	skipsort
	move.l	d0,INPUT5		; Number of Active Turtles
	move.l	#turtlsiz,d0
	move.l	d0,INPUT6		; Length of a Turtle Record
   
	lea	SORT_S,a0
	jsr	gpurun		; run the GPU program

skipsort:
	movem.l	(sp)+,d0-d1/a0
	rts

;
;	VARIABLE RAM
;
	.bss
	.even
disp_ptr:		; Display buffer ptr
	.ds.l	1
draw_ptr:		; Draw buffer ptr
	.ds.l	1
zbuf_ptr:		; Z buffer ptr
	.ds.l	1

drawlist:		; Root (Index really) to List of See-able turtles
	.ds.w	1
scrublist:		; Root (Index really) to List of UNSee-able turtles
	.ds.w	1
newlist:
	.ds.w	1

model_ptr:		; Ptr to Instance
	.ds.l	1
.phrase
instance:		; Storage for INSTANCE
	.ds.l	4*2048	; 32K Bytes
.phrase
litemodel:		; Lighting Model
	.ds.w	12	; Enough for Ambient and 2 sources

gameover:		; Game Over Flag (0 ==> Game Active)
	.ds.w	1
rotate_flg:		; Cube rotation Flag (0 ==> Sit Still)
	.ds.w	1
sun_flg:		; Sun Lighting Flag (0 ==> No Sun)
	.ds.w	1
bulb_flg:		; InScene Lighting Flag (0 ==> No Bulb)
	.ds.w	1
amb_flg:		; Ambient Lighting Flag (0 ==> No Intensity Change)
	.ds.w	1
ncubes:			; Number of Cubes in space (Less One)
	.ds.w	1
nturtles:		; Number of turtles in space
	.ds.l	1
stretch:
	.ds.w	1	; stretch factor to modify the cube
time1: .ds.l	1
time2:	.ds.l	1
time3:	.ds.l	1
;
;	TURTLE RECORDS
;
xrite	=	0		; IMPORTANT NOTE:
yrite	=	xrite+2		; These first record offsets are hard-wired
zrite	=	yrite+2		; into associated GPU routines.
xdown	=	zrite+2		; DO NOT Insert, Delete or Swap any of these
ydown	=	xdown+2		;	^
zdown	=	ydown+2		;	|
xhead	=	zdown+2		;	|
yhead	=	xhead+2		;	|
zhead	=	yhead+2		;	|
xposn	=	zhead+2		;	|
yposn	=	xposn+2		;	|
zposn	=	yposn+2		;	v
turtlnk =	zposn+2		; Dont change this or anything above here
turtlsiz =	turtlnk+2
maxturtl =	1400

.phrase
turtle:			; All Motion Objects
	.ds.b	maxturtl*turtlsiz


;
;	CONSTANT DATA
;
	.data
;	.even
	.long
ambient:			; Ambient Intensity
	.dc.w	$80
bulb:				; InScene Light
	.dc.w	$00FF		; Intensity
	.dc.w	$f000		; X
	.dc.w	$f000		; Y
	.dc.w	$f000		; Z
;	.dc.w	$80FF		; Intensity
;	.dc.w	$f000		; X
;	.dc.w	$f000		; Y
;	.dc.w	$f000		; Z
sun:				; Sun
	.dc.w	$00ff		; Intensity
	.dc.w	$4000		; X
	.dc.w	$0000		; Y
	.dc.w	$0000		; Z


.long
texpts:	dc.w	0,0,63,0,63,63,0,63	; texturemap ptsin		
eyepts: dc.w	0,0,127,0,127,79,0,79
mthpts:	dc.w	0,0,191,0,191,67,0,67
brpts:	dc.w	0,0,191,0,191,119,0,119

	.end
;*======================================================================*
;*                                 EOF                                  *
;*======================================================================*

