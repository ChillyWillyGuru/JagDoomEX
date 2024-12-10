;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MACROS.INC - Copyright (c)1994 Atari Corp.
;;              All Rights Reserved
;;
;; Last Modification: 12/16/94 - SDS
;;
;; UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;; PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;; THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.gpu
;*======================================================================*
;*	MACROS
;*======================================================================*
;
;	General Purpose JSR
;

MACRO	JSR			; Jump to subroutine macro
				;	trashes R0
	subq	#4,SP		; adjust the stack pointer
	move	PC,r0		; determine current program address
	addq	#16,r0		; new address for after this macro
	store	r0,(SP)		; push return address onto stack
	movei	@1,r0		; load up subroutine address
	jump	(r0)		; jump to subroutine
	nop			; jump doesn't occur until this instr
ENDM

MACRO	RTS			; Return from Subroutine macro
				;	trashes r0
	load	(SP),r0		; load up return address
	addq	#4,SP		; adjust the stack pointer
	jump	(r0)		; jump back to return address
	nop			; jump doesn't occur until this instr
ENDM

MACRO	PUSH			; push a value onto the stack
	store	@1,(SP)		; put argument onto the stack
	subq	#4,SP		; adjust the stack pointer
ENDM

MACRO	POP			; pop a value off the stack
	load	(SP),@1		; take arguement off the stack
	addq	#4,SP		; adjust stack pointer
ENDM

;;;;;;;;;;;;;
;;;; EOF ;;;;
;;;;;;;;;;;;;
