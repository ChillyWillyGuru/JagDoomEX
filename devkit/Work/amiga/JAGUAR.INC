;****************************************************************************
;
;	JAGUAR.INC  Hardware Equates for JAGUAR System
;
;			COPYRIGHT 1992 Atari Computer Corporation
;          UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;          PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;        THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;                            ALL RIGHTS RESERVED.		
;
;****************************************************************************

;
;	JAGUAR REGISTERS
;

BASE			equ	$f00000		; TOM Internal Register Base


MEMCON1		equ	BASE+0		; Memory Configuration Register One
MEMCON2		equ	BASE+2		; Memory Configuration Register Two
HC		equ	BASE+4		; Horizontal Count
VC		equ	BASE+6		; Vertical Count
LPH		equ	BASE+8		; Horizontal Lightpen
LPV		equ	BASE+$0a	; Vertical Lightpen
CLK1		equ	BASE+$0c	; System Clock Frequency
CLK2		equ	BASE+$0e	; Video Clock Frequency
OB0		equ	BASE+$10	; Current Object Phrase
OB1		equ	BASE+$12
OB2		equ	BASE+$14
OB3		equ	BASE+$16
OLP		equ	BASE+$20	; Object List Pointer
OLPLO		equ	BASE+$20
OLPHI		equ	BASE+$22
ODP		equ	BASE+$24	; Object Data Pointer
OBF		equ	BASE+$26	; Object Processor Flag
VMODE		equ	BASE+$28	; Video Mode
BORD1		equ	BASE+$2a	; Border Color (Red & Green)
BORD2		equ	BASE+$2c	; Border Color (Blue)
HP		equ	BASE+$2e	; Horizontal Period
HBB		equ	BASE+$30	; Horizontal Blanking Begin
HBE		equ	BASE+$32	; Horizontal Blanking End
HS		equ	BASE+$34	; Horizontal Sync
HVS		equ	BASE+$36	; Horizontal Vertical Sync
HDB1		equ	BASE+$38	; Horizontal Display Begin One
HDB2		equ	BASE+$3a	; Horizontal Display Begin Two
HDE		equ	BASE+$3c	; Horizontal Display End
VP		equ	BASE+$3e	; Vertical Period
VBB		equ	BASE+$40	; Vertical Blanking Begin
VBE		equ	BASE+$42	; Vertical Blanking End
VS		equ	BASE+$44	; Vertical Sync
VDB		equ	BASE+$46	; Vertical Display Begin
VDE		equ	BASE+$48	; Vertical Display End
VEB		equ	BASE+$4a	; Vertical equalization Begin
VEE		equ	BASE+$4c	; Vertical equalization End
VI		equ	BASE+$4e	; Vertical Interrupt
PIT0		equ	BASE+$50	; Programmable Interrupt Timer (Lo)
PIT1		equ	BASE+$52	; Programmable Interrupt Timer (Hi)
HEQ		equ	BASE+$54	; Horizontal equalization End
TEST1		equ	BASE+$56	; Undocumented Register - DO NOT USE
BG		equ	BASE+$58	; Background Color

INT1		equ	BASE+$e0	; CPU Interrupt Control Register
INT2		equ	BASE+$e2	; CPU Interrupt Resume Register

CLUT		equ	BASE+$400	; Color Lookup Table

LBUFA		equ	BASE+$800	; Line Buffer A
LBUFB		equ	BASE+$1000	; Line Buffer B
LBUFC		equ	BASE+$1800	; Line Buffer Current

;
;	GPU REGISTERS
;
G_FLAGS 	equ	BASE+$2100	; GPU Flags
G_MTXC		equ	BASE+$2104	; GPU Matrix Control
G_MTXA		equ	BASE+$2108	; GPU Matrix Address
G_END		equ	BASE+$210c	; GPU Data Organization
G_PC		equ	BASE+$2110	; GPU Program Counter
G_CTRL		equ	BASE+$2114	; GPU Operation Control/Status
G_HIDATA 	equ	BASE+$2118	; GPU Bus Interface high data
G_REMAIN 	equ	BASE+$211c	; GPU Division Remainder
G_DIVCTRL 	equ	BASE+$211c	; DSP Divider control
G_RAM		equ	BASE+$3000	; GPU Internal RAM
G_ENDRAM	equ	G_RAM+4*1024	; 4K bytes
;
;	BLTTER REGISTERS
;
A1_BASE 	equ	BASE+$2200	; A1 Base Address
A1_FLAGS	equ	BASE+$2204	; A1 Control Flags
A1_CLIP		equ	BASE+$2208	; A1 Clipping Size
A1_PIXEL	equ	BASE+$220C	; A1 Pixel Pointer
A1_STEP		equ	BASE+$2210	; A1 Step (Integer Part)
A1_FSTEP	equ	BASE+$2214	; A1 Step (Fractional Part)
A1_FPIXEL	equ	BASE+$2218	; A1 Pixel Pointer (Fractional)
A1_INC		equ	BASE+$221C	; A1 Increment (Integer Part)
A1_FINC		equ	BASE+$2220	; A1 Increment (Fractional Part)
A2_BASE		equ	BASE+$2224	; A2 Base Address
A2_FLAGS	equ	BASE+$2228	; A2 Control Flags
A2_MASK		equ	BASE+$222C	; A2 Address Mask
A2_PIXEL	equ	BASE+$2230	; A2 PIXEL
A2_STEP		equ	BASE+$2234	; A2 Step (Integer)

B_CMD		equ	BASE+$2238	; Command
B_COUNT		equ	BASE+$223C	; Counters
B_SRCD		equ	BASE+$2240	; Source Data
B_DSTD		equ	BASE+$2248	; Destination Data
B_DSTZ		equ	BASE+$2250	; Destination Z
B_SRCZ1		equ	BASE+$2258	; Source Z (Integer)
B_SRCZ2		equ	BASE+$2260	; Source Z (Fractional)
B_PATD		equ	BASE+$2268	; Pattern Data
B_IINC		equ	BASE+$2270	; Intensity Increment
B_ZINC		equ	BASE+$2274	; Z Increment
B_STOP		equ	BASE+$2278	; Collision stop control

B_I3		equ	BASE+$227C	; Blitter Intensity 3
B_I2		equ	BASE+$2280	; Blitter Intensity 2
B_I1		equ	BASE+$2284	; Blitter Intensity 1
B_I0		equ	BASE+$2288	; Blitter Intensity 0

B_Z3		equ	BASE+$228C	; Blitter Z 3
B_Z2		equ	BASE+$2290	; Blitter Z 2
B_Z1		equ	BASE+$2294	; Blitter Z 1
B_Z0		equ	BASE+$2298	; Blitter Z 0

;	ROM Tables built into Jerry 128 samples
;	16 bit samples sign extended to 32

CHRO_CLK	equ	BASE+$10014	; Chroma clock control

ROM_TABLE   	equ	BASE+$1D000	; Base of tables
TRI     	equ	BASE+$1D000	; A triangle wave
SINE    	equ	BASE+$1D200	; Full amplitude SINE
AMSINE  	equ	BASE+$1D400	; Linear (?) ramp SINE
SINE12W 	equ	BASE+$1D600	; SINE(X)+SINE(2*X)
CHIRP16 	equ	BASE+$1D800	; SHORT SWEEP
NTRI    	equ	BASE+$1DA00	; Triangle w/NOISE
DELTA   	equ	BASE+$1DC00	; Positive spike
NOISE   	equ	BASE+$1DE00	; Guess

;	JERRY Registers (DSP)

D_FLAGS		equ	BASE+$1A100	; DSP Flags
D_MTXC		equ	BASE+$1A104	; DSP Matrix Control
D_MTXA		equ	BASE+$1A108	; DSP Matrix Address
D_END		equ	BASE+$1A10c	; DSP Data Organization
D_PC		equ	BASE+$1A110	; DSP Program Counter
D_CTRL		equ	BASE+$1A114	; DSP Operation Control/Status
D_MODMASK 	equ	BASE+$1A118	; DSP Bus Interface high data
D_REMAIN 	equ	BASE+$1A11c	; DSP Division Remainder
D_DIVCTRL 	equ	BASE+$1A11c	; DSP Divider control
D_RAM		equ	BASE+$1B000	; DSP Internal RAM
D_ENDRAM	equ	D_RAM+(8*1024)	; 8K bytes
JPIT1W		equ	BASE+$10000	; timer 1 pre-scaler write
JPIT1R		equ	BASE+$10036	; timer 1 pre-scaler read
JPIT3W		equ	BASE+$10004	; timer 2 pre-scaler write
JPIT3R		equ	BASE+$1003A	; timer 2 pre-scaler read
JPIT2W		equ	BASE+$10002	; timer 1 divider write
JPIT2R		equ	BASE+$10038	; timer 1 divider read
JPIT4W		equ	BASE+$10006	; timer 2 divider write
JPIT4R		equ	BASE+$1003C	; timer 2 divider read
INT		equ	BASE+$10020	; Interupt control register
DAC1		equ	BASE+$1A140	; Left DAC
DAC2		equ	BASE+$1A144	; Right DAC
SCLK		equ	BASE+$1A150	; Serial clock frequency
SMODE		equ	BASE+$1A154	; Serial mode
LTXD		equ	BASE+$1A148	; Left transmit data
RTXD		equ	BASE+$1A14C	; Right transmit data
LRXD		equ	BASE+$1A148	; Left receive data
RRXD		equ	BASE+$1A14C	; Right transmit data
SSTAT		equ	BASE+$1A150	; Serial status
ASICLK		equ	BASE+$10034	; Asynchronous serial clock
ASICTRL		equ	BASE+$10032	; Asynchronous serial control write
ASISTAT		equ	BASE+$10032	; idem read
ASIDATA		equ	BASE+$10030	; Asynchronous serial data
JOY1		equ	BASE+$14000	; Joystick register
JOY2		equ	BASE+$14002	; Button register
