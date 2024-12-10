;PIC GPU Signed 32.32->32 Divide (8-jun-1994)
;In: r0=operand 0 r1=operand 1
;Out: r0=r0/r1
;This code assumes DIV mode is 32-bit (default).
;Slightly enhanced version of Adisak Pochanayon @ High Voltage 's already enhanced one.
	.INCLUDE	"libinc.s"
___adivsi3::
	move	r0,r2
	abs	r0
	xor	r1,r2
	abs	r1
	sharq	#31,r2
	div	r1,r0
	xor	r2,r0
	sub	r2,r0
	_RTS

;;Adisak Pochanayon @ High Voltage 's code:
;;	move	r0,r2
;;	abs	r0
;;	xor	r1,r2
;;	abs	r1
;;	move	r2,r3
;;	div	r1,r0
;;	load	(ST),TMP	;Get return address
;;	shrq	#31,r3	;sign determination
;;	sharq	#31,r2
;;	addqt	#4,ST
;;	xor	r2,r0	;correct sign
;;	jump	T,(TMP)	;rts
;;	add	r3,r0	;handle 2's complement

;;Old code (debugged from Adisak Pochanayon @ High Voltage 's bug report):
;;	abs	r0
;;	moveq	#0,r2
;;	jr	CC,.l0
;;	abs	r1
;;	subqt	#1,r2
;;.l0:	jr	CC,.l1
;;	div	r1,r0	
;;	not	r2
;;.l1:	xor	r2,r0
;;	sub	r2,r0
;;	_RTS

	