;*======================================================================*
;*                TITLE:    JAGUAR.S                                    *
;*                Function: System Initialization Routines              *
;*                                                                      *
;*                Project #:              JAGUAR                        *
;*                                                                      *
;*                Programmer:             Cary J. Gee                   *
;*                                                                      *
;*              COPYRIGHT 1992,1993 Atari U.S. Corporation              *
;*          UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,         *
;*          PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR          *
;*        THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.       *
;*                            ALL RIGHTS RESERVED.                      *
;*                                                                      *
;*======================================================================*
	.title  "JAGUAR.S - System Initialization Routines"

;*======================================================================*
;*      INCLUDE FILES
;*======================================================================*

	.include        'jaguar.inc'

;*======================================================================*
;*      EXTERNAL SYMBOLS
;*======================================================================*

	.extern objlist

;*======================================================================*
;*      EXTERNAL ROUTINES
;*======================================================================*

	.extern InitLister
	.extern vidinit
	.extern vblinit

;*======================================================================*
;*      PUBLIC SYMBOLS
;*======================================================================*


;*======================================================================*
;*      PUBLIC ROUTINES
;*======================================================================*

	.globl  InitJag
	.globl  _Clear

;*======================================================================*
;*      LOCAL EQUATES
;*======================================================================*


;*======================================================================*
;*      SUBROUTINE AREA
;*======================================================================*

	.text

;*======================================================================*
;*      InitJag   Initialize Jaguar video and object list
;*
;*      Given:
;*              Control
;*
;*      Returns:
;*              
;*
;*      Register Usage:
;*
;*      Externals:
;*              None
;*
;*======================================================================*

InitJag:
	movem.l a0/d0,-(sp)

	move.l  #$00070007,G_END
	move.w  #$FFFF,VI

	jsr     vidinit                 ; Initialize video
	jsr     InitLister
	jsr     vblinit                 ; Initialize VBlank routine

	move.l  #objlist,d0             ;* use bi-phrase ptr to olist
	swap    d0                      ;* and set the OLP
	move.l  d0,OLP

	move.w  #$4C1,VMODE             ;Turn on display w/CRY

	movem.l (sp)+,a0/d0

	rts

	.end

;*======================================================================*
;*                              EOF
;*======================================================================*
