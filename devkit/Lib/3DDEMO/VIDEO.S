;*======================================================================*
;*                TITLE:    VIDEO.S                                     *
;*                Function: Video and Object Processor Routines         *
;*                                                                      *
;*                Project #:              JAGUAR                        *
;*                                                                      *
;*                Programmer:             Leonard Tramiel               *
;*                                        Andrew J Burgess              *
;*                                        Rob Zdybel                    *
;*                                                                      *
;*              COPYRIGHT 1992,1993 Atari U.S. Corporation              *
;*          UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,         *
;*          PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR          *
;*        THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.       *
;*                            ALL RIGHTS RESERVED.                      *
;*                                                                      *
;*======================================================================*

	.title  "VIDEO.S - video initialization and VBLANK routines"

	.include        "jaguar.inc"

;*======================================================================*
;*      EXTERNAL SYMBOLS
;*======================================================================*

	.extern disp_ptr                ;* Display buffer ptr
	.extern rate                    ;* frame rate specifier
	.extern ratecnt                 ;* frame rate count
	.extern framecnt                ;* Count of Video Frames

;*======================================================================*
;*      EXTERNAL ROUTINES
;*======================================================================*

	.extern UpdateList

;*======================================================================*
;*      PUBLIC SYMBOLS
;*======================================================================*

	.globl a_vdb
	.globl a_vde
	.globl height
	.globl width

;*======================================================================*
;*      PUBLIC ROUTINES
;*======================================================================*

	.globl  vblank
	.globl  vidinit
	.globl  vblinit

;*======================================================================*
;*      LOCAL EQUATES
;*======================================================================*

PHRASE          EQU     8
SCRNADDR        EQU     PHRASE
OBJSIZE         EQU     3*2


;*======================================================================*
;*      SUBROUTINE AREA
;*======================================================================*


;*======================================================================*
;*      VIDINIT   Initialize Video to 320x288 NTSC
;*
;*      Given:
;*              Control
;*
;*      Returns:
;*              Video Disabled, but ready for 320x288 NTSC
;*
;*      Register Usage:
;*              None
;*
;*      Externals:
;*              None
;*
;*======================================================================*

vidinit:
	movem.l d0-d6,-(sp)
	clr.l   framecnt
	
	move.w  CONFIG,d0               ; Also is joystick register
	andi.w  #VIDTYPE,d0             ; 0 = PAL, 1 = NTSC
	beq     palvals

	move.w  #NTSC_HMID,d2
	move.w  #NTSC_WIDTH,d0

	move.w  #NTSC_VMID,d6
	move.w  #NTSC_HEIGHT,d4

	bra     calc_vals
palvals:
	move.w  #PAL_HMID,d2
	move.w  #PAL_WIDTH,d0

	move.w  #PAL_VMID,d6
	move.w  #PAL_HEIGHT,d4

calc_vals:
	move.w  d0,width
	move.w  d4,height

	move.w  d0,d1
	asr     #1,d1                   ; Width/2

	sub.w   d1,d2                   ; Mid - Width/2
	add.w   #4,d2                   ; (Mid - Width/2)+4

	sub.w   #1,d1                   ; Width/2 - 1
	ori.w   #$400,d1                ; (Width/2 - 1)|$400
		
	move.w  d1,a_hde
	move.w  d1,HDE

	move.w  d2,a_hdb
	move.w  d2,HDB1
	move.w  d2,HDB2

	move.w  d6,d5
	sub.w   d4,d5
	move.w  d5,a_vdb

	add.w   d4,d6
	move.w  d6,a_vde

	move.w  a_vdb,VDB
	move.w  #$FFFF,VDE
			
	move.l  #0,BORD1                ; Black border
	move.w  #0,BG                   ; Init line buffer to black
			
	movem.l (sp)+,d0-d6
	rts

;*======================================================================*
;*      VBLANK   Vertical Sync Interrupt Handler
;*
;*      Given:
;*              Control
;*
;*      Returns:
;*              Object List restored for next frame
;*
;*      Register Usage:
;*              All Registers Preserved
;*
;*      Externals:
;*              framecnt, disp_ptr, olist_ptr
;*
;*======================================================================*
vblank:
	movem.l a0-a1/d0-d1,-(sp)

	jsr     UpdateList
	addq.l  #1,framecnt     ;* Count a video frame

	move.w  #$101,INT1      ;* enable Video interrupt and clear all others pending
	move.w  #0,INT2

	movem.l (sp)+,d0-d1/a0-a1
	rte

;
;
; This will set up the VI (Vertical line counter Interrupt)
; Or it would if the low order bit of INT1 REALLY was the VI interrupt
;
;
vblinit:

	movem.l d0,-(sp)

	move.l  #vblank,LEVEL0

	move.w  a_vde,d0
	ori.w   #$1,d0
	move.w  d0,VI

	move.w  INT1,d0
	ori.w   #$1,d0
	move.w  d0,INT1

	move.w  sr,d0
	and.w   #$f8ff,d0
	move.w  d0,sr

	movem.l (sp)+,d0

	rts

		.bss

a_hdb:          .ds.w   1
a_hde:          .ds.w   1
a_vdb:          .ds.w   1
a_vde:          .ds.w   1
width:          .ds.w   1
height:         .ds.w   1

		.end
;*======================================================================*
;*                              EOF
;*======================================================================*
