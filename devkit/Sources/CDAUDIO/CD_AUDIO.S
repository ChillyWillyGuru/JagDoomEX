;**************************************************************************
; (C)1993 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;
;                                CD_audio.s
;
;       This MC68K program demonstrates	the use of some of the subroutines 
;	presently available to drive the Jaguar CD Module in standard CD
;	audio playback mode.  All calls to the CD Module are made as "bsrs".
;
;	This program requires assembly and linking of the DSP program 
;	'Echo.gas'.
;
;	The makefile is named 'CD-audio.mak'.
;
;       The hardware assumptions here are a CDROM interface card Rev 2.0
;	mounted in the 2 MB Sylvester Development System.
;
;
;                                REVISION HISTORY
;
; REV.  DATE       BY            DESCRIPTION OF EDIT
; """"  """"       ""            """""""""""""""""""
; 1.00  01 Oct 93  DMS   Based on CD.107
; 2.00  12 Nov 93  DMS   Update to use for testing Jag CDROM V1.00 PCB
; 3.01  24 Feb 94  TD    Removed all references to memcon
;****************************************************************************

        .include 'jaguar.inc'	; cast in concrete for console
	.include 'cd_inits.inc'	; CD-related equates

;****************************************************************************

	.extern	ROM_dspcode	; needed for GPU program load by DB
	.extern	end_ROM_dspcode
	.extern	DSPORG

;****************************************************************************

DSP_stop  equ	$F1C310		; Stop-DSP semaphore from M68K

;****************************************************************************

Start_CD:                       ; Beginning of CD_related code
;				*****************************************
;				* Un Mute the audio			*
;				*****************************************
	move.l	#JOYSTICK,a0	;Joystick 0 register
	move.w	#$0100,d0	;Un mute
	move.w	d0,(a0)

;				*****************************************
;				*      Clear our own memory range	*
;				*****************************************
Clearmem:
	move.l	#CD_TOC,a0	; our lowest DRAM address, see 'CD_inits.inc'
	move.l	#$30000,d1	; our highest DRAM address

Clermem1:			; clear CD variables and data buffer area
	move.l	#0,(a0)+
	move.l	a0,d0	
	cmp.l	d0,d1
	bne	Clermem1

;				****************************************
;				*          Play audio from CD	       *
;				****************************************
Do_audio:			; audio track playback demo
	bsr	CDmode_4	; setup Jerry's i2s port and clocks
				
;				*****************************************
;				*  Load, initialize & run DSP program	*
;				*****************************************
Run_DSP:			; Leonard's thing 
	move.l	#ROM_dspcode,a0		; Get ROM storage address of code
	move.l	#DSPORG,a1		; Execution address of code
	move.l	#end_ROM_dspcode,d0	; end of ROM storage
	sub.l	a0,d0			; Get length in bytes
	asr.l	#2,d0			; Convert # bytes to # longs

.xfer_code:
	move.l	(a0)+,(a1)+		; Copy code to DSP RAM
	dbra	d0,.xfer_code

DSP_init:
	move.l	d5,D_PC		; Set DSP PC to start of code in SRAM
	move.l	#1,D_CTRL	; set DSP GO bit to start running

Play_it:			; DSP's running.  Now start disc
	move.l	#$00000004,d1	; if 0, play using time A to time B mode
;	move.l	#$00060000,d2	; start time set at 6:00:00
;	move.l	#$00060900,d3	; stop time set at 6:09:00
	bsr	Play_CD

;				*****************************************
;				* Leave Tom set for DRAM space & exit	*
;				*****************************************
Fini:                           ; load from CD failed, so...
;	bsr	Stop_CD		; stop drive
;	move.l	#0,DSP_stop	; semaphore to tell DSP to stop itself
        illegal			; end of program.  bail out to DB 


;________________________________________________________________________
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;                               Subroutines
;
;				****************************************
;				*    Setup CD Module for Mode 4, Audio *
;				****************************************
CDmode_4:			; init for audio (mode 2)
.setiobit:                       ; can't write to CD Module before setting
;        move.l  #$F00000,a0     ; the I/O bit in Tom's base register
;        move.w  #$1865,d1       ; value to init with to read ROM1 space
;        move.w  d1,(a0)         ; write to Tom

.set_moto:                       ; make damn sure we're Motorola-way
	move.l	#$00070007,D_END

.butch:					
	move.l	#$0,BUTCH		; Butch enable 
	move.l	#$10000,DSCNTRL		; turn on DSA Bus
	move.l	#$f,I2CNTRL		; 5 = code, f = audio 

.make_clk:			; Init serial clk frequency to...
        move.l  #2,d1           ; 2(N+1) = 6    26/6 =~ 4.3 MHz
        move.l  #$F1A150,a0     ; put address of sclk reg into a0
        move.l  d1,(a0)         ; write to Jerry

.set_mode:
        move.l  #$F1A154,a0     ; put address into a0
        move.l  #$14,d1         ; external clk, interrupt on every sample pair
        move.l  d1,(a0)         ; write to Jerry
      
.interpol:			; interpolate audio data errors
	move.w	#$1501,DS_DATA	; DSA command
	bsr	DSA_rx

.setDAC:			; output audio data at 2X oversampled
	move.w	#$7002,DS_DATA	; DSA command
	bsr	DSA_rx
  	rts

;				*****************************************
;				*   i2s data copy to Jerry on/off	*
;				*****************************************
Jeridata:			; d1 must have a 1 or a 0 in it
.setiobit:                      ; can't write to CD Module before setting
;        move.l  #$F00000,a0     ; the I/O bit in Tom's base register
;        move.w  #$1865,d1       ; value to init with to read ROM1 space
;        move.w  d1,(a0)         ; write to Tom

.set_moto:                       ; make damn sure we're Motorola-way
	move.l	#$00070007,D_END

test_d1:			; see if we're turning copy on or off
	cmp.l	#1,d1
	beq	Jcopy_on	; d1 has 1, turn on copy

Jcopyoff:
	move.l	#$0,BUTCH	; Butch enable 
	move.l	I2CNTRL,d0	; get contents of i2s control reg
	bclr	#0,d0		; clear bit 0
	bclr	#1,d0		; clear bit 1
	move.l	d0,I2CNTRL	; now do it
	bra	Jcopyxit

Jcopy_on:
	move.l	#$0,BUTCH	; Butch enable 
	move.l	I2CNTRL,d0	; get contents of i2s control reg
	or.l	#3,d0		; or in the Jerry copy-on bits	
	move.l	d0,I2CNTRL	; do it

Jcopyxit:
	rts			; done with i2s copy to Jerry switch

;				*****************************************
;				*  Use service mode to debug drive	*
;				*****************************************
Service:			; some code to test service modes
	move.w	#$F001,DS_DATA	; kick into service mode
	bsr	DSA_rx
	move.w	#$F301,DS_DATA	; turn on laser, try to focus it, run motor
	bsr	DSA_rx
;	move.w	#$F000,DS_DATA	; turn off service mode
	rts



;				****************************************
;				*     Command CD to spin-up	       *
;				****************************************
Spin_CD:                        ; spin-up command
	cmp.l	#0,d1		; check for user-selection of mode
	bne	sessions	; not 0, jump to multi-session mode

single:				; start-up normal disc
	move.w	#$1800,DS_DATA	; Spins up on first TOC
 	bsr	DSA_rx
	rts			; end of spin-up-normal command

sessions:			; start-up multi-session on specified session
	or.w	#$1800,d1	; session number must be in d1
	move.w	d1,DS_DATA
 	bsr	DSA_rx
	rts			; end of spin-up-multi-session command

;				****************************************
;				*  Command CD to play in 1 of 3 forms  *
;				****************************************
				; 3-way switch for Play, Play @, & Play A-B
Play_CD:                        ; call play command with track number in d1
	cmp.l	#0,d1		; see if user has cleared d1
	bne	playtrak	; not 0, ie. has track number, so go play it

maybe_AB:
	cmp.l	#0,d3		; if d3 has target value, user wants A-B play
	bne	A_B_play	; branch to A-B play mode

gotimeCD:			; d3 was 0 so play from user's time-code setup
	move.l	d2,d4		; safe copy of whole start time in d4
	and.l	#$00FF0000,d2	; mask for minutes
	ror.l	#8,d2		; shift the byte over
	ror.l	#8,d2		
	or.w	#$1000,d2	; format it for goto
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d2		; bring in copy of original user value of d2
	and.l	#$0000FF00,d2	; mask for seconds
	ror.l	#8,d2
	or.w	#$1100,d2	; format it for goto
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d2		; bring in copy of original user value of d2
	and.l	#$000000FF,d2	; mask for frames
	or.w	#$1200,d2	; format it for goto
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_rx		; verify receipt 
	rts			; end of goto time and play command

playtrak:			; play a track 
	or.w	#$0100,d1	; no pause, format for DSA play-track command
	move.w	d1,DS_DATA	; DSA TX command to play track specified
	bsr	DSA_rx		; get response
	rts			; end of play-track

A_B_play:
	move.l	d2,d4		; safe copy of whole start time in d4
	and.l	#$00FF0000,d2	; mask for minutes
	ror.l	#8,d2		; shift the byte over
	ror.l	#8,d2		
	or.w	#$2000,d2	; format it for play A-B
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d2		; bring in copy of original user value of d2
	and.l	#$0000FF00,d2	; mask for seconds
	ror.l	#8,d2
	or.w	#$2100,d2	; format it for play A-B
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d2		; bring in copy of original user value of d2
	and.l	#$000000FF,d2	; mask for frames
	or.l	#$2200,d2	; format it for play A-B
	move.w	d2,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l	d3,d4		; safe copy of whole stop time in d4
	and.l	#$00FF0000,d3	; mask for minutes
	ror.l	#8,d3		; shift the byte over
	ror.l	#8,d3		
	or.w	#$2300,d3	; format it for play A-B
	move.w	d3,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d3		; bring in copy of original user value of d3
	and.l	#$0000FF00,d3	; mask for seconds
	ror.l	#8,d3
	or.w	#$2400,d3	; format it for play A-B
	move.w	d3,DS_DATA	; DSA tx
        bsr     DSA_tx		; wait till sent before sending next 1

	move.l  d4,d3		; bring in copy of original user value of d3
	and.l	#$000000FF,d3	; mask for frames
	or.l	#$2500,d3	; format it for play A-B
	move.w	d3,DS_DATA	; DSA tx
        bsr     DSA_rx		; verify receipt 
	rts			; end of Play A_B command

;				****************************************
;				*     Command CD to stop	       *
;				****************************************
Stop_CD:                        
	move.w	#$0200,DS_DATA	; DSA TX command to stop
 	bsr	DSA_rx
	rts			; end of stop command

;				****************************************
;				*     Command CD to mute the decoder   *
;				****************************************
Mute_CD:                        
	move.w	#$5100,DS_DATA	; DSA TX command to mute
 	bsr	DSA_rx
	rts			; end of mute command

;				****************************************
;				*  Command CD to un-mute the decoder   *
;				****************************************
UnmuteCD:                        
	move.w	#$51FF,DS_DATA	; DSA TX command to un-mute
 	bsr	DSA_rx
	rts			; end of un-mute command

;				****************************************
;				*     Command CD to pause	       *
;				****************************************
Pause_CD:                       
	move.w	#$0400,DS_DATA	; DSA TX command to pause
 	bsr	DSA_rx
	rts			; end of pause command

;				****************************************
;				*     Command CD to un-pause	       *
;				****************************************
UnpausCD:                       
	move.w	#$0500,DS_DATA	; DSA TX command to un-pause
 	bsr	DSA_rx
	rts			; end of un-pause command

;				****************************************
;				*   Command CD to send ABS timecode    *
;				****************************************
Get_time:                       ; send-absolute-timecode command
	move.w	#$0D00,DS_DATA	
 	bsr	DSA_rx		; receive 3 times to get min:sec:frm
	bsr	DSA_rx
	bsr	DSA_rx
	rts			; end of get-time command

;				****************************************
;				* Command CD to send no. of sessions   *
;				****************************************
Seshn_CD:                       ; send the number of sessions on disc 
	move.w	#$5400,DS_DATA	
 	bsr	DSA_rx		
	rts			; end of get-sessions command


;				****************************************
;				*    Command CD to kill its A-B flags  *
;				****************************************
KillCDAB:                       
	move.w	#$2600,DS_DATA	
 	bsr	DSA_rx		
	rts			; end of kill A-B flags command

;				****************************************
;				*     Command CD to search forward     *
;				****************************************
ForwrdCD:                       ; low byte of d4 sets search mode
	or.l	#$0600,d4	; gets user's search mode byte
	move.w	d4,DS_DATA	; DSA TX command to search
 	bsr	DSA_rx
	rts			; end of search command

;				****************************************
;				*     Command CD to search backward    *
;				****************************************
BckwrdCD:                       ; low byte of d4 sets search mode
	or.l	#$0700,d4	; gets user's search mode byte
	move.w	d4,DS_DATA	; DSA TX command to search
 	bsr	DSA_rx
	rts			; end of search command

;				****************************************
;				*     Command CD to stop searching     *
;				****************************************
NosrchCD:                       
	move.w	#$0800,DS_DATA	; DSA TX command to stop searching
 	bsr	DSA_rx
	rts			; end of stop-search command

;				****************************************
;				*     Command CD to send TOC min-max   *
;				****************************************
CDminmax:                       ; returns first, last cut nums & endtime
	or.l	#$0300,d4	; get user's session number
	move.w	d4,DS_DATA	
 	bsr	DSA_rx		; gets min cut number
 	bsr	DSA_rx		; gets max cut number
 	bsr	DSA_rx		; gets end min
 	bsr	DSA_rx		; gets end sec
 	bsr	DSA_rx		; gets end frame
	rts			; end of CDminmax command

;				****************************************
;				*     Command CD to send whole TOC     *
;				****************************************
CDbigTOC:                       ; gets the entire table of contents
	move.l	#CD_TOC,a0	; setup address of start of TOC storage area
	or.l	#$1400,d4	; get user's session number
	move.w	d4,DS_DATA	; note that CDminmax must be called first

Get_item:			; receive a TOC entry
 	bsr	DSA_rx		; gets cut number
	move.l	CD_wrd0,d1	; the word just fetched from DSA Bus
	and.l	#$FF,d1		; mask for low byte
	move.l	CDTOCend,d2	; get highest cut number known to be on CD
	and.l	#$FF,d2		; mask for low byte
	cmp.l	d1,d2		; compare 'em
	beq	Enuf_TOC	; we're done when they are equal
 	bsr	DSA_rx		; gets control and address byte
 	bsr	DSA_rx		; gets start min of cut
 	bsr	DSA_rx		; gets start sec
 	bsr	DSA_rx		; gets start frame

Saveitem:			; Save another valid TOC entry to memory
	move.l	CDcutnum,(a0)+
	move.l	CDcutCAB,(a0)+
	move.l	CDcutstm,(a0)+
	move.l	CDcutsts,(a0)+
	move.l	CDcutstf,(a0)+
	bra	Get_item	; go get the next TOC entry

Enuf_TOC:			; get last item, and exit
	move.l	CDcutnum,(a0)+
	move.l	CDcutCAB,(a0)+
	move.l	CDcutstm,(a0)+
	move.l	CDcutsts,(a0)+
	move.l	CDcutstf,(a0)+
	rts			; end of CDbigTOC command

;				****************************************
;				*  Command CD to send status of disc   *
;				****************************************
Stat_CD:                       
	move.w	#$5000,DS_DATA	
 	bsr	DSA_rx
	rts			; end of send-disc-status command

;				****************************************
;				*     Command CD to send cut length    *
;				****************************************
CtlnthCD:                       ; low byte of d4 must have cut $number
	or.l	#$0900,d4	; gets user's cut number byte
	move.w	d4,DS_DATA	; DSA TX command to search
 	bsr	DSA_rx		; do rx twice to get low byte, high byte
	bsr	DSA_rx		; the value of the word is $seconds
	rts			; end of get-cut-length command

;				****************************************
;				*         DSA error handler	       *
;				****************************************
GetCDerr:			; gets & classifies most recent error 
	move.w	#$1600,DS_DATA	; request error code
	bsr	DSA_rx		; receive it
	move.l	CD_error,d1	; analyze it
	and.l	#$FF,d1		; low byte only, please
	cmp.l	#0,d1		; if it's 0 there's no error...
	beq	Clearerr	; so blow out of here, otherwise...
	cmp.l	#$1F,d1		; see if its fatal or not
	bge	Retry_OK	; not fatal

Fatals:
	move.l	CDfatals,d0	; get current number of fatal errors
	add.l	#1,d0		; increment
	move.l	d0,CDfatals	; store it
	bra	Clearerr	; done
	
Retry_OK:
	move.l	CDmaybes,d0	; get current number of retry-able errors
	add.l	#1,d0		; increment
	move.l	d0,CDmaybes	; store it

Clearerr:
	move.w	#$1700,DS_DATA	; ask CD to clear error its register
	bsr	DSA_rx
	rts			; end of DSA error handler

;				****************************************
;				*   Transmit a DSA Bus command	       *
;				****************************************
DSA_tx:				; set up as a polling loop
	move.l	BUTCH,d1	; get Butch's ICR into d1
	and.l	#$1000,d1	; mask for d12, DSA TX Intr. pending
	beq	DSA_tx		; nothing here yet, so wait for bit to set 
	move.w	DS_DATA,d1	; flag set, so get the word from Butch
	move.l	d1,CD_wrd0	; store it where Sort can find it
	move.l	DSCNTRL,d5	; read here to clear interrupt flag
	bra	Sort_CD		; parse the DSA response

;				****************************************
;				* Receive DSA Bus response & parse it  *
;				****************************************
DSA_rx:				; set up as a polling loop
	move.l	BUTCH,d1	; get Butch's ICR into d1
	and.l	#$2000,d1	; mask for d13, DSA RX Intr. pending
	beq	DSA_rx		; nothing here yet, so wait for bit to set 
	move.w	DS_DATA,d1	; flag set, so get the word from Butch
	move.l	d1,CD_wrd0	; store it where we can see it for debugging
	move.l	DSCNTRL,d5	; read here to clear interrupt flag
;	bra	Endsort		; un-comment to skip the sorting business

Sort_CD:                        ; the commands are decoded per DSA spec.
        move.l  CD_wrd0,d1      ; load data word 
        move.l  d1,d2           ; copy it for debugging
        andi.l  #$FF00,d1       ; mask to see hi byte only

cmnd_01:                        ; parse it
        cmp.l   #$0100,d1       ; test
        beq     Found		; found "found" message

cmnd_03:                        ; parse it
        cmp.l   #$0300,d1       ; test
        beq     Discstat	; found disc status message

cmnd_04:                        ; parse it
        cmp.l   #$0400,d1       ; test
        beq     error		; found error message

cmnd_09:                        ; parse it
        cmp.l   #$0900,d1       ; test
        beq     CutlenL		; found cut-length low byte of seconds 

cmnd_0A:                        ; parse it
        cmp.l   #$0A00,d1       ; test
        beq     CutlenH		; found cut-length high byte of seconds 

cmnd_10:                        ; parse it
        cmp.l   #$1000,d1       ; test
        beq     track           ; found track number

cmnd_11:
        cmp.l   #$1100,d1       ; test
        beq     index           ; found index

cmnd_12:
        cmp.l   #$1200,d1       ; test
        beq     rel_mins        ; found rel. minutes

cmnd_13:
        cmp.l   #$1300,d1       ; test
        beq     rel_secs        ; found rel. seconds

cmnd_14:
        cmp.l   #$1400,d1       ; test
        beq     abs_mins        ; found abs. minutes 

cmnd_15:
        cmp.l   #$1500,d1       ; test
        beq     abs_secs        ; found abs. seconds 

cmnd_16:
        cmp.l   #$1600,d1       ; test
        beq     frames          ; found frames

cmnd_17:
        cmp.l   #$1700,d1       ; test
        beq     Mode		; found mode

cmnd_20:
        cmp.l   #$2000,d1       ; test
        beq     firs_trk        ; found first track number in TOC

cmnd_21:
        cmp.l   #$2100,d1       ; test
        beq     endtrack        ; found last track number in TOC

cmnd_22:
        cmp.l   #$2200,d1       ; test
        beq     end_mins        ; found last minute of last track in this TOC
      
cmnd_23:
        cmp.l   #$2300,d1       ; test
        beq     end_secs        ; found last second of last track in this TOC

cmnd_24:
        cmp.l   #$2400,d1       ; test
        beq     endframe        ; found last frame of last track in this TOC

cmnd_54:
        cmp.l   #$5400,d1       ; test
        beq     Sessions	; found Number of Sessions on disc message

cmnd_60:
        cmp.l   #$6000,d1       ; test
        beq     Cutnum		; found TOC cut number

cmnd_61:
        cmp.l   #$6100,d1       ; test
        beq     CutCAB		; found TOC cut control and address byte

cmnd_62:
        cmp.l   #$6200,d1       ; test
        beq     Cutstm		; found TOC cut start minute

cmnd_63:
        cmp.l   #$6300,d1       ; test
        beq     Cutsts		; found TOC cut start sec

cmnd_64:
        cmp.l   #$6400,d1       ; test
        beq     Cutstf		; found TOC cut start frame

cmnd_70:
        cmp.l   #$7000,d1       ; test
        beq     DAC		; found DAC setting
        bra     Endsort         ; no command number match - fell thru to here

DAC:				; now copy the value to named storage 
	move.l	d2,CD_DAC
	bra	Endsort

Discstat:
	move.l	d2,CD_stat
	bra	Endsort

Mode:
	move.l	d2,CD_setup
	bra	Endsort

Found:
	move.l	d2,CD_found
	bra	Endsort

error:
        move.l  d2,CD_error
	bra     Endsort

track:				
        move.l  d2,CD_track     
        bra     Endsort		

index:
        move.l  d2,CD_index     
        bra     Endsort

abs_mins:
        move.l  d2,CD_Amins      
        bra     Endsort

abs_secs:
        move.l  d2,CD_Asecs
        bra     Endsort

rel_mins:			
        move.l  d2,CD_Rmins     
        bra     Endsort

rel_secs:			
        move.l  d2,CD_Rsecs
        bra     Endsort

frames:
        move.l  d2,CD_Afrms
        bra     Endsort

firs_trk:
        move.l  d2,CDTOCbeg
        bra     Endsort

endtrack:
        move.l  d2,CDTOCend
        bra     Endsort

end_mins:
        move.l  d2,CDTOCmin
        bra     Endsort

end_secs:
        move.l  d2,CDTOCsec
        bra     Endsort

endframe:
        move.l  d2,CDTOCfrm
        bra     Endsort

Sessions:
	move.l	d2,CDseshns
        bra     Endsort

CutlenL:
	move.l	d2,CDcutlnL
        bra     Endsort

CutlenH:
	move.l	d2,CDcutlnH
        bra     Endsort

Cutnum:
	move.l	d2,CDcutnum
        bra     Endsort

CutCAB:
	move.l	d2,CDcutCAB
        bra     Endsort

Cutstm:
	move.l	d2,CDcutstm
        bra     Endsort

Cutsts:
	move.l	d2,CDcutsts
        bra     Endsort

Cutstf:
	move.l	d2,CDcutstf
      
Endsort:
        rts			; end of sorting routine

				; end of code


	
