;**************************************************************************
; (C)1994 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;
;                                CD_inits.inc
;
;       This include file contains all of the equates needed for the CDROM
;	functions.
;
;                                REVISION HISTORY
;
; REV.  DATE       BY            DESCRIPTION OF EDIT
; """"  """"       ""            """""""""""""""""""
; 1.00  14 Jun 93  DMS   Original. Equates taken from DATA.213
; 2.00  25 Jun 93  DMS   Add more variables for full DSA Bus testing
; 3.00  19 Jul 93  DMS   Add Butch's registers. move variable mem up.
; 4.00  26 Jul 93  DMS   Add more CD variables
; 5.00  19 Aug 93  DMS   Fix half-buff pointer
; 6.01  17 Sep 93  DMS   Modify for 2 MB Sylvester (Rapier Rev 2 PCB)
; 6.02  20 Sep 93  DMS   For CD.s demos and Programmer's Interface doc
; 6.03  01 Oct 93  DMS   Add CD_retry
; 7.00  23 Feb 94  DMS   Change name of FIFO DATA register
;****************************************************************************

				; Butch's hardware registers
BUTCH     equ  $DFFF00		; base of Butch=interrupt control register, R/W
DSCNTRL   equ  BUTCH+4		; DSA control register, R/W
DS_DATA   equ  BUTCH+$A		; DSA TX/RX data, R/W
I2CNTRL   equ  BUTCH+$10	; i2s bus control register, R/W
SBCNTRL   equ  BUTCH+$14	; CD subcode control register, R/W
SUBDATA   equ  BUTCH+$18	; Subcode data register A
SUBDATB   equ  BUTCH+$1C	; Subcode data register B
SB_TIME   equ  BUTCH+$20	; Subcode time and compare enable (D24)
FIFODAT   equ  BUTCH+$24	; i2s FIFO data
I2SDAT2   equ  BUTCH+$28	; i2s FIFO data (old)

				; Butch's registers shadow in DRAM
S_BUTCH   equ  $18000		; base of Butch=interrupt control register, R/W
SDSCNTRL  equ  S_BUTCH+4	; DSA control register, R/W
SDS_DATA  equ  S_BUTCH+$A	; DSA TX/RX data, R/W
SI2CNTRL  equ  S_BUTCH+$10	; i2s bus control register, R/W
SSBCNTRL  equ  S_BUTCH+$14	; CD subcode control register, R/W
SSUBDATA  equ  S_BUTCH+$18	; Subcode data register A
SSUBDATB  equ  S_BUTCH+$1C	; Subcode data register B
SSB_TIME  equ  S_BUTCH+$20	; Subcode time and compare enable (D24)
SI2SDAT1  equ  S_BUTCH+$24	; i2s FIFO data
SI2SDAT2  equ  S_BUTCH+$28	; i2s FIFO data

CD_TOC  equ  $16000		; arbitrary start of CD TOC storage

CD_base   equ  $19000          ; arbitrary start of variable storage in DRAM
CD_found  equ  CD_base+4	; this group of variables is normally read-only
CD_setup  equ  CD_found+4	; they are command responses received from the
CD_DAC    equ  CD_setup+4       ; CD ROM module
CD_error  equ  CD_DAC+4		
CD_track  equ  CD_error+4       
CD_index  equ  CD_track+4
CD_Amins  equ  CD_index+4
CD_Asecs  equ  CD_Amins+4
CD_Afrms  equ  CD_Asecs+4
CDTOCbeg  equ  CD_Afrms+4	
CDTOCend  equ  CDTOCbeg+4
CDTOCmin  equ  CDTOCend+4
CDTOCsec  equ  CDTOCmin+4
CDTOCfrm  equ  CDTOCsec+4
CDcutnum  equ  CDTOCfrm+4
CDcutCAB  equ  CDcutnum+4
CDcutstm  equ  CDcutCAB+4
CDcutsts  equ  CDcutstm+4
CDcutstf  equ  CDcutsts+4
CD_wrd0   equ  CDcutstf+4	; raw data back from DSA Bus 
CD_stat   equ  CD_wrd0+4	
CDcutlnL  equ  CD_stat+4
CDcutlnH  equ  CDcutlnL+4
CDseshns  equ  CDcutlnH+4
CD_Rmins  equ  CDseshns+4
CD_Rsecs  equ  CD_Rmins+4
CDfatals  equ  CD_Rsecs+4
CDmaybes  equ  CDfatals+4
                                ; These variables are written to in normal
CD_retry  equ  CDmaybes+4       ; CD audio access   retry counter
PS_flag   equ  CD_retry+4	; pause flag

                                ; This group of variables must be initialized.
Init_cut  equ  PS_flag+4        ; put command & number of initial track here
CD_mode   equ  Init_cut+4       ; playback mode bits stored here
DAC_mode  equ  CD_mode+4        ; DAC output rate settings stored here

Startmin  equ  DAC_mode+4	; format is $20nn, where nn is $minute value
Startsec  equ  Startmin+2	; format is $21nn, where nn is $second value
Startfrm  equ  Startsec+2	; format is $22nn, where nn is $frame value
Stop_min  equ  Startfrm+2	; format is $23nn, where nn is $minute value
Stop_sec  equ  Stop_min+2	; format is $24nn, where nn is $second value
Stop_frm  equ  Stop_sec+2	; format is $25nn, where nn is $frame value

				; More CD inits that are required for DSA
Waittime  equ  Stop_frm+2	; hex value to use in wait loop
Session   equ  Waittime+2	; Session number to spin-up on



