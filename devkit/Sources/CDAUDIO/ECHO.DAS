;**************************************************************************
; (C)1993 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;
;                                echo.gas
;
;       This program uses the i2s external sample word clock to generate
;	an interrupt, set up by the calling 68K host program, to time data
;	moves from the i2s port input to i2s output; a simple loopthru.
;
;
;                                REVISION HISTORY
;
; REV.  DATE       BY            DESCRIPTION OF EDIT
; """"  """"       ""            """""""""""""""""""
; 1.00  15 Sep 93  DMS	Based on loop.gas, used by butch.415
; 2.00  12 Nov 93  DMS	Add shutdown semaphore, per bugfix
;**************************************************************************

	.include	"jaguar.inc"

	.globl	end_ROM_dspcode

					; addresses of...
STACKPOS	equ	$F1CF00		; stack in DSP SRAM
DSP_stop	equ	$F1C310		; Stop-DSP semaphore from M68K

	.68000
ROM_dspcode::
	.dsp
	.org	D_RAM			; put this program at start of DSP SRAM

DSPORG::
	movei	#d_start,r0		; (interrupt 0  - DSP Control)
	jump	(r0)
	nop
	nop
	nop
	nop
	movei	#i2s_isr,r29		; (interrupt 1 - I2S)
	jump	(r29)
	nop
	nop
	nop
	nop

d_start:
	movei	#DSP_stop,r19	; address of stop semaphore
	moveq	#0,r0
	store	r0,(r19)	; clear stop bit
	movei	#STACKPOS,r31	; Set up a stack
	movei	#D_FLAGS,r1	; load dsp flags
	load	(r1),r0
	bset	#5,r0		; enable I2S interrupt
	store	r0,(r1) 	; save dsp flags

fake_it:			; a dummy loop to encapsulate the ISR
	jr	fake_it
	nop
				; Sample pair-rate ISR
i2s_isr:
	movei	#D_FLAGS,r30	; get flags ptr
	load	(r30),r29	; load flags
	movei	#L_I2S,r18	; address of left i2s input port
	load	(r18),r13	; data from left channel in r13
	movei	#R_I2S,r17	; right input
	load	(r17),r12	; rt. in r12
	movei	#L_I2S,r9	; left TX port
	store	r13,(r9)	; echo sample back out left
	movei	#R_I2S,r8	; and same for rt.
	store	r12,(r8)

stop_req:			; M68K wants us to stop?
	movei	#halt_DSP,r3	; prep for jump
	load	(r19),r0	; get semaphore
	cmpq	#1,r0		; no, do cleanup
	jump	eq,(r3)		; yes, stop
	nop

clean_up:			; do the housekeeping, per Leonard
	bclr	#3,r29		; clear IMASK
	bset	#10,r29		; set I2S interrupt clear bit
	load	(r31),r28	; get last instruction address
	addq	#2,r28		; point at next to be executed
	addq	#4,r31		; update the stack pointer
	jump	(r28)		; and return
	store	r29,(r30)	; restore flags

halt_DSP:			; do this to stop the damn thing
	movei	#$DEADC0DE,r9	; breadcrumb
	movei	#0,r1
	movei	#SMODE,r0	; turn off i2s port
	store	r1,(r0)
	movei	#$23E00,r1
	movei	#D_FLAGS,r0	; kill interrupts
	store	r1,(r0)
	movei	#0,r1
	movei	#D_CTRL,r0	; and halt it
	store	r1,(r0)

verydead:			; if the DSP is not stopped now
	nop			; try turning the power off
	jr	verydead
	nop
	nop

	.68000
end_ROM_dspcode::
	.end

