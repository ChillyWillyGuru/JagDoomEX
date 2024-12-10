/*
 *
 *	JAGUAR.H  Hardware Equates for JAGUAR System
 *
 *	COPYRIGHT 1992-1994 Atari Computer Corporation
 *	UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
 *	PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
 *	THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
 *	ALL RIGHTS RESERVED.
 *
 * Revision History:
 * 9/19/94 - Consolidated several files into first master JAGUAR.INC (SDS)
 * 2/16/95 - MF
 * 4/24/95 - Added UART Error Control and Mask definitions (NBK)
 * 5/16/95 - Added Asynchronous Serial/DAC Synonyms (SDS)
 */

/* GENERIC DEFINES */

#define DRAM		0x000000L	/* Physical Start of RAM */
#define USERRAM 	0x004000L	/* Start of Available RAM */
#define ENDRAM		0x200000L	/* End of RAM */
#define INITSTACK	(ENDRAM-4L)	/* Recommended Stack Location */

/*
 * CPU REGISTERS
 */

#define LEVEL0		0x100L		/* 68000 Level 0 Autovector */
#define USER0		0x100L		/* Pseudonym */

/*
 * Masks for INT1 CPU Interrupt Control
 */

#define C_VIDENA	0x0001L 	/* Enable CPU Video Interrupts */
#define C_GPUENA	0x0002L 	/* Enable CPU GPU Interrupts */
#define C_OPENA 	0x0004L 	/* Enable CPU OP Interrupts */
#define C_PITENA	0x0008L 	/* Enable CPU PIT Interrupts */
#define C_JERENA	0x0010L 	/* Enable CPU Jerry Interrupts */

#define C_VIDCLR	0x0100L 	/* Clear CPU Video Interrupts */
#define C_GPUCLR	0x0200L 	/* Clear CPU GPU Interrupts */
#define C_OPCLR 	0x0400L 	/* Clear CPU OP Interrupts */
#define C_PITCLR	0x0800L 	/* Clear CPU PIT Interrupts */
#define C_JERCLR	0x1000L 	/* Clear CPU Jerry Interrupts */

/*
 * JAGUAR REGISTERS
 */

#define BASE		0xF00000L	/* TOM Internal Register Base */

/*
 * TOM REGISTERS
 */

#define HC		((volatile short *)(BASE+4))	   /* Horizontal Count */
#define VC		((volatile short *)(BASE+6))	   /* Vertical Count */
#define LPH		((volatile short *)(BASE+8))	   /* Horizontal Lightpen */
#define LPV		((volatile short *)(BASE+0x0A))    /* Vertical Lightpen */
#define OB0		((volatile short *)(BASE+0x10))    /* Current Object Phrase */
#define OB1		((volatile short *)(BASE+0x12))
#define OB2		((volatile short *)(BASE+0x14))
#define OB3		((volatile short *)(BASE+0x16))
#define OLP		((volatile long *)(BASE+0x20))	   /* Object List Pointer */
#define OBF		((volatile short *)(BASE+0x26))    /* Object Processor Flag */
#define VMODE		((volatile short *)(BASE+0x28))    /* Video Mode */
#define BORD1		((volatile short *)(BASE+0x2A))    /* Border Color (Red & Green) */
#define BORD2		((volatile short *)(BASE+0x2C))    /* Border Color (Blue) */
#define HDB1		((volatile short *)(BASE+0x38))    /* Horizontal Display Begin One */
#define HDB2		((volatile short *)(BASE+0x3A))    /* Horizontal Display Begin Two */
#define HDE		((volatile short *)(BASE+0x3C))    /* Horizontal Display End */
#define VS		((volatile short *)(BASE+0x44))    /* Vertical Sync */
#define VDB		((volatile short *)(BASE+0x46))    /* Vertical Display Begin */
#define VDE		((volatile short *)(BASE+0x48))    /* Vertical Display End */
#define VI		((volatile short *)(BASE+0x4E))    /* Vertical Interrupt */
#define PIT0		((volatile short *)(BASE+0x50))    /* Programmable Interrupt Timer (Lo) */
#define PIT1		((volatile short *)(BASE+0x52))    /* Programmable Interrupt Timer (Hi) */
#define BG		((volatile short *)(BASE+0x58))    /* Background Color */

#define INT1		((volatile short *)(BASE+0xE0))    /* CPU Interrupt Control Register */
#define INT2		((volatile short *)(BASE+0xE2))    /* CPU Interrupt Resume Register */

#define CLUT		((volatile short *)(BASE+0x400))   /* Color Lookup Table */

#define LBUFA		((volatile long *)(BASE+0x800))    /* Line Buffer A */
#define LBUFB		((volatile long *)(BASE+0x1000))   /* Line Buffer B */
#define LBUFC		((volatile long *)(BASE+0x1800))   /* Line Buffer Current */

/*
 * OBJECT PROCESSOR EQUATES
 */

#define BITOBJ		0		/* Bitmap Object Type */
#define SCBITOBJ	1		/* Scaled Bitmap Object Type */
#define GPUOBJ		2		/* GPU Interrupt Object Type */
#define BRANCHOBJ	3		/* Branch Object Type */
#define STOPOBJ 	4		/* Stop Object Type */

#define O_REFLECT	0x00002000L	/* OR with top LONG of BITMAP object */
#define O_RMW		0x00004000L
#define O_TRANS 	0x00008000L
#define O_RELEASE	0x00010000L

#define O_DEPTH1	(0L<<12)	 /* DEPTH Field for BITMAP objects */
#define O_DEPTH2	(1L<<12)
#define O_DEPTH4	(2L<<12)
#define O_DEPTH8	(3L<<12)
#define O_DEPTH16	(4L<<12)
#define O_DEPTH32	(5L<<12)

#define O_NOGAP 	(1L<<15)	 /* Phrase GAP between image phrases */
#define O_1GAP		(2L<<15)
#define O_2GAP		(3L<<15)
#define O_3GAP		(4L<<15)
#define O_4GAP		(5L<<15)
#define O_5GAP		(6L<<15)
#define O_6GAP		(7L<<15)

#define O_BREQ		(0L<<14)	 /* CC field of BRANCH objects */
#define O_BRGT		(1L<<14)
#define O_BRLT		(2L<<14)
#define O_BROP		(3L<<14)
#define O_BRHALF	(4L<<14)

#define O_STOPINTS	0x00000008L	/* Enable Interrupts in STOP object */

/*
 * VIDEO INITIALIZATION CONSTANTS
 */

#define NTSC_WIDTH	1409		/* Width of screen in clocks */
#define NTSC_HMID	823		/* Middle of screen in clocks */
#define NTSC_HEIGHT	241		/* Height of screen in pixels */
#define NTSC_VMID	266		/* Middle of screen in half-lines */

#define PAL_WIDTH	1381		/* Same as above for PAL  */
#define PAL_HMID	843
#define PAL_HEIGHT	287
#define PAL_VMID	322

/* The following mask will extract the PAL/NTSC flag bit from the */
/* CONFIG register. NTSC = Bit Set, PAL = Bit Clear		  */

#define VIDTYPE 0x10

/* The following are Video Mode Regiter Masks */

#define VIDEN		0x0001		/* Enable Video Interrupts */

#define CRY16		0x0000		/* 16-bit CRY mode */
#define RGB24		0x0002		/* 24-bit RGB mode */
#define DIRECT16	0x0004		/* 16-bit Direct mode */
#define RGB16		0x0006		/* 16-bit RGB mode */

#define GENLOCK 	0x0008		/* Not supported on Jaguar Console */
#define INCEN		0x0010		/* Enable Encrustation */
#define BINC		0x0020		/* Select Local Border Color */
#define CSYNC		0x0040		/* Enable Composite Sync */
#define BGEN		0x0080		/* Clear Line Buffer to BG register */
#define VARMOD		0x0100		/* Enable Variable Resolution mode */

#define PWIDTH1 	0x0000		/* Pixel Dividers */
#define PWIDTH2 	0x0200
#define PWIDTH3 	0x0400
#define PWIDTH4 	0x0600
#define PWIDTH5 	0x0800
#define PWIDTH6 	0x0A00
#define PWIDTH7 	0x0C00
#define PWIDTH8 	0x0E00

/*
 * GPU REGISTERS
 */

#define G_FLAGS 	((volatile long *)(BASE+0x2100))   /* GPU Flags */
#define G_MTXC		((volatile long *)(BASE+0x2104))   /* GPU Matrix Control */
#define G_MTXA		((volatile long *)(BASE+0x2108))   /* GPU Matrix Address */
#define G_END		((volatile long *)(BASE+0x210C))   /* GPU Data Organization */
#define G_PC		((volatile long *)(BASE+0x2110))   /* GPU Program Counter */
#define G_CTRL		((volatile long *)(BASE+0x2114))   /* GPU Operation Control/Status */
#define G_HIDATA	((volatile long *)(BASE+0x2118))   /* GPU Bus Interface high data */
#define G_REMAIN	((volatile long *)(BASE+0x211C))   /* GPU Division Remainder */
#define G_DIVCTRL	((volatile long *)(BASE+0x211C))   /* GPU Divider control */
#define G_RAM		((volatile long *)(BASE+0x3000))   /* GPU Internal RAM */
#define G_ENDRAM	((volatile long *)(((volatile char *)G_RAM)+(4*1024)))

/* GPU Flags Register Equates */

#define G_CPUENA	0x00000010L	/* CPU Interrupt enable bits */
#define G_DSPENA	0x00000020L	/* DSP Interrupt enable bits */
#define G_PITENA	0x00000040L	/* PIT Interrupt enable bits */
#define G_OPENA 	0x00000080L	/* Object Processor Interrupt enable bits */
#define G_BLITENA	0x00000100L	/* Blitter Interrupt enable bits */
#define G_CPUCLR	0x00000200L	/* CPU Interrupt clear bits */
#define G_DSPCLR	0x00000400L	/* DSP Interrupt clear bits */
#define G_PITCLR	0x00000800L	/* PIT Interrupt clear bits */
#define G_OPCLR 	0x00001000L	/* Object Processor Interrupt clear bits */
#define G_BLITCLR	0x00002000L	/* Blitter Interrupt clear bits */

/* GPU Control/Status Register */

#define GPUGO		0x00000001L	/* Start and Stop the GPU */
/*#define GPUINT0 	0x00000004L  */   /* generate a GPU type 0 interrupt */

#define G_CPULAT	0x00000040L	/* Interrupt Latches */
#define G_DSPLAT	0x00000080L
#define G_PITLAT	0x00000100L
#define G_OPLAT 	0x00000200L
#define G_BLITLAT	0x00000400L

/*
 * BLITTER REGISTERS
 */

#define A1_BASE 	((volatile long *)(BASE+0x2200))  /* A1 Base Address */
#define A1_FLAGS	((volatile long *)(BASE+0x2204))  /* A1 Control Flags */
#define A1_CLIP 	((volatile long *)(BASE+0x2208))  /* A1 Clipping Size */
#define A1_PIXEL	((volatile long *)(BASE+0x220C))  /* A1 Pixel Pointer */
#define A1_STEP 	((volatile long *)(BASE+0x2210))  /* A1 Step (Integer Part) */
#define A1_FSTEP	((volatile long *)(BASE+0x2214))  /* A1 Step (Fractional Part) */
#define A1_FPIXEL	((volatile long *)(BASE+0x2218))  /* A1 Pixel Pointer (Fractional) */
#define A1_INC		((volatile long *)(BASE+0x221C))  /* A1 Increment (Integer Part) */
#define A1_FINC 	((volatile long *)(BASE+0x2220))  /* A1 Increment (Fractional Part) */
#define A2_BASE 	((volatile long *)(BASE+0x2224))  /* A2 Base Address */
#define A2_FLAGS	((volatile long *)(BASE+0x2228))  /* A2 Control Flags */
#define A2_MASK 	((volatile long *)(BASE+0x222C))  /* A2 Address Mask */
#define A2_PIXEL	((volatile long *)(BASE+0x2230))  /* A2 PIXEL */
#define A2_STEP 	((volatile long *)(BASE+0x2234))  /* A2 Step (Integer) */

#define B_CMD		((volatile long *)(BASE+0x2238))  /* Command */
#define B_COUNT 	((volatile long *)(BASE+0x223C))  /* Counters */
#define B_SRCD		((volatile long *)(BASE+0x2240))  /* Source Data */
#define B_DSTD		((volatile long *)(BASE+0x2248))  /* Destination Data */
#define B_DSTZ		((volatile long *)(BASE+0x2250))  /* Destination Z */
#define B_SRCZ1 	((volatile long *)(BASE+0x2258))  /* Source Z (Integer) */
#define B_SRCZ2 	((volatile long *)(BASE+0x2260))  /* Source Z (Fractional) */
#define B_PATD		((volatile long *)(BASE+0x2268))  /* Pattern Data */
#define B_IINC		((volatile long *)(BASE+0x2270))  /* Intensity Increment */
#define B_ZINC		((volatile long *)(BASE+0x2274))  /* Z Increment */
#define B_STOP		((volatile long *)(BASE+0x2278))  /* Collision stop control */

#define B_I3		((volatile long *)(BASE+0x227C))  /* Blitter Intensity 3 */
#define B_I2		((volatile long *)(BASE+0x2280))  /* Blitter Intensity 2 */
#define B_I1		((volatile long *)(BASE+0x2284))  /* Blitter Intensity 1 */
#define B_I0		((volatile long *)(BASE+0x2288))  /* Blitter Intensity 0 */

#define B_Z3		((volatile long *)(BASE+0x228C))  /* Blitter Z 3 */
#define B_Z2		((volatile long *)(BASE+0x2290))  /* Blitter Z 2 */
#define B_Z1		((volatile long *)(BASE+0x2294))  /* Blitter Z 1 */
#define B_Z0		((volatile long *)(BASE+0x2298))  /* Blitter Z 0 */

/* BLITTER Command Register defines */

#define SRCEN		0x00000001L	/* d00:     source data read (inner loop) */
#define SRCENZ		0x00000002L	/* d01:     source Z read (inner loop) */
#define SRCENX		0x00000004L	/* d02:     source data read (realign) */
#define DSTEN		0x00000008L	/* d03:     destination data read (inner loop) */
#define DSTENZ		0x00000010L	/* d04:     destination Z read (inner loop) */
#define DSTWRZ		0x00000020L	/* d05:     destination Z write (inner loop) */
#define CLIP_A1 	0x00000040L	/* d06:     A1 clipping enable */
#define UPDA1F		0x00000100L	/* d08:     A1 update step fraction */
#define UPDA1		0x00000200L	/* d09:     A1 update step */
#define UPDA2		0x00000400L	/* d10:     A2 update step */
#define DSTA2		0x00000800L	/* d11:     reverse usage of A1 and A2 */
#define GOURD		0x00001000L	/* d12:     enable Gouraud shading */
#define ZBUFF		0x00002000L	/* d13:     polygon Z data updates */
#define TOPBEN		0x00004000L	/* d14:     intensity carry into byte */
#define TOPNEN		0x00008000L	/* d15:     intensity carry into nibble */
#define PATDSEL 	0x00010000L	/* d16:     Select pattern data */
#define ADDDSEL 	0x00020000L	/* d17:     diagnostic */
					/* d18-d20: Z comparator inhibit */
#define ZMODELT 	0x00040000L	/*	     source < destination */
#define ZMODEEQ 	0x00080000L	/*	     source = destination */
#define ZMODEGT 	0x00100000L	/*	     source > destination */
					/* d21-d24: Logic function control */
#define LFU_NAN 	0x00200000L	/*	     !source & !destination */
#define LFU_NA		0x00400000L	/*	     !source &	destination */
#define LFU_AN		0x00800000L	/*	      source & !destination */
#define LFU_A		0x01000000L	/*	      source &	destination */
#define CMPDST		0x02000000L	/* d25:     pixel compare pattern & dest */
#define BCOMPEN 	0x04000000L	/* d26:     bit compare write inhibit */
#define DCOMPEN 	0x08000000L	/* d27:     data compare write inhibit */
#define BKGWREN 	0x10000000L	/* d28:     data write back */
#define BUSHI		0x20000000L	/* d29	   blitter priority */
#define SRCSHADE	0x40000000L	/* d30:    shade src data w/IINC value */

/* The following are ALL 16 possible logical operations of the LFUs */

#define LFU_ZERO	0x00000000L	/* All Zeros */
#define LFU_NSAND	0x00200000L	/* NOT Source AND NOT Destination */
#define LFU_NSAD	0x00400000L	/* NOT Source AND Destination */
#define LFU_NOTS	0x00600000L	/* NOT Source */
#define LFU_SAND	0x00800000L	/* Source AND NOT Destination */
#define LFU_NOTD	0x00A00000L	/* NOT Destination */
#define LFU_N_SXORD	0x00C00000L	/* NOT (Source XOR Destination) */
#define LFU_NSORND	0x00E00000L	/* NOT Source OR NOT Destination */
#define LFU_SAD 	0x01000000L	/* Source AND Destination */
#define LFU_SXORD	0x01200000L	/* Source XOR Destination */
#define LFU_D		0x01400000L	/* Destination */
#define LFU_NSORD	0x01600000L	/* NOT Source OR Destination */
#define LFU_S		0x01800000L	/* Source */
#define LFU_SORND	0x01A00000L	/* Source OR NOT Destination */
#define LFU_SORD	0x01C00000L	/* Source OR Destination */
#define LFU_ONE 	0x01E00000L	/* All Ones */

/* These are some common combinations with less boolean names */

#define LFU_REPLACE	0x01800000L	/* Source REPLACEs destination */
#define LFU_XOR 	0x01200000L	/* Source XOR with destination */
#define LFU_CLEAR	0x00000000L	/* CLEAR destination */

/* BLITTER Flags (A1 or A2) register defines */

/* Pitch d00-d01:
	distance between pixel phrases */
#define PITCH1		0x00000000L	/* 0 phrase gap */
#define PITCH2		0x00000001L	/* 1 phrase gap */
#define PITCH4		0x00000002L	/* 3 phrase gap */
#define PITCH3		0x00000003L	/* 2 phrase gap */

/* Pixel d03-d05
	bit depth (2^n) */
#define PIXEL1		0x00000000L	/* n = 0 */
#define PIXEL2		0x00000008L	/* n = 1 */
#define PIXEL4		0x00000010L	/* n = 2 */
#define PIXEL8		0x00000018L	/* n = 3 */
#define PIXEL16 	0x00000020L	/* n = 4 */
#define PIXEL32 	0x00000028L	/* n = 5 */

/* Z offset d06-d08
	offset from phrase of pixel data from its corresponding
	Z data phrases	*/
#define ZOFFS0		0x00000000L	/* offset = 0	UNUSED */
#define ZOFFS1		0x00000040L	/* offset = 1 */
#define ZOFFS2		0x00000080L	/* offset = 2 */
#define ZOFFS3		0x000000C0L	/* offset = 3 */
#define ZOFFS4		0x00000100L	/* offset = 4 */
#define ZOFFS5		0x00000140L	/* offset = 5 */
#define ZOFFS6		0x00000180L	/* offset = 6 */
#define ZOFFS7		0x000001C0L	/* offset = 7	UNUSED */

/* Width d09-d14
	width used for address generation
	This is a 6-bit floating point value in pixels
	4-bit unsigned exponent
	2-bit mantissa with implied 3rd bit of 1	*/
#define WID2		0x00000800L	/* 1.00 X 2^1  ( 4<<9) */
#define WID4		0x00001000L	/* 1.00 X 2^2  ( 8<<9) */
#define WID6		0x00001400L	/* 1.10 X 2^2  (10<<9) */
#define WID8		0x00001800L	/* 1.00 x 2^3  (12<<9) */
#define WID10		0x00001A00L	/* 1.01 X 2^3  (13<<9) */
#define WID12		0x00001C00L	/* 1.10 X 2^3  (14<<9) */
#define WID14		0x00001E00L	/* 1.11 X 2^3  (15<<9) */
#define WID16		0x00002000L	/* 1.00 X 2^4  (16<<9) */
#define WID20		0x00002200L	/* 1.01 X 2^4  (17<<9) */
#define WID24		0x00002400L	/* 1.10 X 2^4  (18<<9) */
#define WID28		0x00002600L	/* 1.11 X 2^4  (19<<9) */
#define WID32		0x00002800L	/* 1.00 X 2^5  (20<<9) */
#define WID40		0x00002A00L	/* 1.01 X 2^5  (21<<9) */
#define WID48		0x00002C00L	/* 1.10 X 2^5  (22<<9) */
#define WID56		0x00002E00L	/* 1.11 X 2^5  (23<<9) */
#define WID64		0x00003000L	/* 1.00 X 2^6  (24<<9) */
#define WID80		0x00003200L	/* 1.01 X 2^6  (25<<9) */
#define WID96		0x00003400L	/* 1.10 X 2^6  (26<<9) */
#define WID112		0x00003600L	/* 1.11 X 2^6  (27<<9) */
#define WID128		0x00003800L	/* 1.00 X 2^7  (28<<9) */
#define WID160		0x00003A00L	/* 1.01 X 2^7  (29<<9) */
#define WID192		0x00003C00L	/* 1.10 X 2^7  (30<<9) */
#define WID224		0x00003E00L	/* 1.11 X 2^7  (31<<9) */
#define WID256		0x00004000L	/* 1.00 X 2^8  (32<<9) */
#define WID320		0x00004200L	/* 1.01 X 2^8  (33<<9) */
#define WID384		0x00004400L	/* 1.10 X 2^8  (34<<9) */
#define WID448		0x00004600L	/* 1.11 X 2^8  (35<<9) */
#define WID512		0x00004800L	/* 1.00 X 2^9  (36<<9) */
#define WID640		0x00004A00L	/* 1.01 X 2^9  (37<<9) */
#define WID768		0x00004C00L	/* 1.10 X 2^9  (38<<9) */
#define WID896		0x00004E00L	/* 1.11 X 2^9  (39<<9) */
#define WID1024 	0x00005000L	/* 1.00 X 2^10 (40<<9) */
#define WID1280 	0x00005200L	/* 1.01 X 2^10 (41<<9) */
#define WID1536 	0x00005400L	/* 1.10 X 2^10 (42<<9) */
#define WID1792 	0x00005600L	/* 1.11 X 2^10 (43<<9) */
#define WID2048 	0x00005800L	/* 1.00 X 2^11 (44<<9) */
#define WID2560 	0x00005A00L	/* 1.01 X 2^11 (45<<9) */
#define WID3072 	0x00005C00L	/* 1.10 X 2^11 (46<<9) */
#define WID3584 	0x00005E00L	/* 1.11 X 2^11 (47<<9) */

/* X add control d16-d17
	controls the update of the X pointer on each pass
	round the inner loop */
#define XADDPHR 	0x00000000L	/* 00 - add phrase width and truncate */
#define XADDPIX 	0x00010000L	/* 01 - add pixel size (add 1)	 */
#define XADD0		0x00020000L	/* 10 - add zero */
#define XADDINC 	0x00030000L	/* 11 - add the increment */

/* Y add control	d18
	controls the update of the Y pointer within the inner loop.
	it is overridden by the X add control if they are in add increment */
#define YADD0		0x00000000L	/* 00 - add zero */
#define YADD1		0x00040000L	/* 01 - add 1 */

/* X sign d19
	add or subtract pixel size if X add control = 01 (XADDPIX) */
#define XSIGNADD	0x00000000L	/* 0 - add pixel size */
#define XSIGNSUB	0x00080000L	/* 1 - subtract pixel size */

/* Y sign d20
	add or subtract pixel size if Y add control = 01 (YADD1) */
#define YSIGNADD	0x00000000L	/* 0 - add 1 */
#define YSIGNSUB	0x00100000L	/* 1 - sub 1 */


/*
 * JERRY REGISTERS
 */

#define JPIT1		((volatile short *)(BASE+0x10000L)) /* Timer 1 Pre-Scaler */
#define JPIT2		((volatile short *)(BASE+0x10002L)) /* Timer 1 Divider */
#define JPIT3		((volatile short *)(BASE+0x10004L)) /* Timer 2 Pre-Scaler */
#define JPIT4		((volatile short *)(BASE+0x10006L)) /* Timer 2 Divider */

#define J_INT		((volatile short *)(BASE+0x10020L))  /* Jerry Interrupt control (to TOM) */

#define JOYSTICK	((volatile short *)(BASE+0x14000L))  /* Joystick register and mute */
#define JOYBUTS 	((volatile short *)(BASE+0x14002L)) /* Joystick register */
#define CONFIG		((volatile short *)(BASE+0x14002L)) /* Also has NTSC/PAL */

#define SCLK		((volatile long *)(BASE+0x1A150L)) /* SSI Clock Frequency */
#define SMODE		((volatile long *)(BASE+0x1A154L)) /* SSI Control */

#define L_I2S		((volatile long *)(BASE+0x1A148L)) /* Left I2S Serial */
#define R_I2S		((volatile long *)(BASE+0x1A14CL)) /* Right I2S Serial */
#define LTXD		((volatile long *)(BASE+0x1A148L)) /* Synonyms */
#define RTXD		((volatile long *)(BASE+0x1A14CL))
#define LRXD		((volatile long *)(BASE+0x1A148L))
#define RRXD		((volatile long *)(BASE+0x1A14CL))

#define R_DAC		((volatile long *)(BASE+0x1A148L)) /* Swapped on Purpose! */
#define L_DAC		((volatile long *)(BASE+0x1A14CL))

#define ASICLK		((volatile short *)(BASE+0x10034)) /* Async Clock Register */
#define ASICTRL		((volatile short *)(BASE+0x10032)) /* Async Control Register */
#define ASISTAT		((volatile short *)(BASE+0x10032)) /* Async Status Register */
#define ASIDATA		((volatile short *)(BASE+0x10030)) /* Async Data Register */

/*
 * UART Definitions (new in this file as of 24-Apr-95)
 *
 * UART control register Masks
 * All unused bits in the control register need to be written as zeros !
 * With exception of U_CLRERR these are valid for read in ASISTAT, too
 */

#define	U_MODD		(1<<0)		/* selects odd parity */
#define	U_MPAREN	(1<<1)		/* enable parity */
#define	U_MTXOPOL	(1<<2)		/* transmit output polarity (if set: active low) */
#define	U_MRXIPOL	(1<<3)		/* receive input polarity (if set: invert input) */
#define	U_MTINTEN	(1<<4)		/* enable transmitter interrupts */
#define	U_MRINTEN	(1<<5)		/* enable reciever interrupts */
#define	U_MCLRERR	(1<<6)		/* clear error (only use if U_SERIN is */
					/* inactive otherwise the UART locks up. */
					/* By default input is active low. This */
					/* depends on U_MRXIPOL)  */
#define	U_MTXBRK	(1<<14)		/* transmit break */

/*
 * UART control register (ONLY) bit numbers
 */

#define	U_CLRERR	(6)

/*
 * UART control AND status register (SHARED) bit numbers
 */

#define	U_ODD		(0)		/* selects odd parity */
#define	U_PAREN		(1)		/* enable parity */
#define	U_TXOPOL	(2)		/* transmit output polarity (if set: active low) */
#define	U_RXIPOL	(3)		/* receive input polarity (if set: invert input) */
#define	U_TINTEN	(4)		/* enable transmitter interrupts */
#define	U_RINTEN	(5)		/* enable reciever interrupts */
#define	U_TXBRK		(14)		/* transmit break */

/*
 * UART status register (ONLY) bit number
 */

#define	U_ERR		(15)		/* error condition exists */
#define	U_SERIN		(13)		/* state of UART1 Pin (serial input data) */
#define	U_OE		(11)		/* overrun error */
#define	U_FE		(10)		/* frame error */
#define	U_PE		(9)		/* parity error */
#define	U_TBE		(8)		/* transitter buffer empty */
#define	U_RBF		(7)		/* receiver buffer full */


/*
 * Jerry Interrupt Control Flags
 */

#define J_EXTENA	0x0001		/* Enable Jerry External Ints */
#define J_DSPENA	0x0002		/* Enable Jerry DSP Ints */
#define J_TIM1ENA	0x0004		/* Enable Jerry Timer 1 Ints */
#define J_TIM2ENA	0x0008		/* Enable Jerry Timer 2 Ints */
#define J_ASYNENA	0x0010		/* Enable Jerry Asynch Serial Ints */
#define J_SYNENA	0x0020		/* Enable Jerry Synch Serial Ints */

#define J_EXTCLR	0x0100		/* Clear Pending External Ints */
#define J_DSPCLR	0x0200		/* Clear Pending DSP Ints */
#define J_TIM1CLR	0x0400		/* Clear Pending Timer 1 Ints */
#define J_TIM2CLR	0x0800		/* Clear Pending Timer 2 Ints */
#define J_ASYNCLR	0x1000		/* Clear Pending Asynch Serial Ints */
#define J_SYNCLR	0x2000		/* Clear Pending Synch Serial Ints */

/*
 * Joystick Equates
 *
 * Bits when LONGword is formatted as below (from JOYTEST\JT_LOOP.S).
 * Format: xxApxxBx RLDU147* xxCxxxox 2580369#
 */

#define JOY_UP		20		/*joypad */
#define JOY_DOWN	21
#define JOY_LEFT	22
#define JOY_RIGHT	23

#define FIRE_A		29		/*fire buttons */
#define FIRE_B		25
#define FIRE_C		13
#define OPTION		9
#define PAUSE		28

#define KEY_STAR	16		/*keypad */
#define KEY_7		17
#define KEY_4		18
#define KEY_1		19

#define KEY_0		4
#define KEY_8		5
#define KEY_5		6
#define KEY_2		7

#define KEY_HASH	0
#define KEY_9		1
#define KEY_6		2
#define KEY_3		3

#define ANY_JOY 	0x00F00000L	/* AND joyedge with this - joypad was pressed if result is not 0 */
#define ANY_FIRE	0x32002200L	/* AND joyedge with this - A,B C, Option or Pause was pressed if result is not 0 */
#define ANY_KEY 	0x000F00FFL	/* AND joyedge with this - 123456789*0# was pressed if result is not 0 */

/*
 *	ROM Tables built into Jerry - 128 samples each
 *	16 bit samples sign extended to 32
 */

#define ROM_TABLE	((volatile long *)(BASE+0x1D000L)) /* Base of tables */

#define ROM_TRI 	((volatile long *)(BASE+0x1D000L)) /* A triangle wave */
#define ROM_SINE	((volatile long *)(BASE+0x1D200L)) /* Full amplitude SINE */
#define ROM_AMSINE	((volatile long *)(BASE+0x1D400L)) /* Linear (?) ramp SINE */
#define ROM_12W 	((volatile long *)(BASE+0x1D600L)) /* SINE(X)+SINE(2*X) : (was ROM_SINE12W) */
#define ROM_CHIRP16	((volatile long *)(BASE+0x1D800L)) /* SHORT SWEEP */
#define ROM_NTRI	((volatile long *)(BASE+0x1DA00L)) /* Triangle w/NOISE */
#define ROM_DELTA	((volatile long *)(BASE+0x1DC00L)) /* Positive spike */
#define ROM_NOISE	((volatile long *)(BASE+0x1DE00L)) /* Noise */

/*
 * JERRY Registers (DSP)
 */

#define D_FLAGS 	((volatile long *)(BASE+0x1A100L)) /* DSP Flags */
#define D_MTXC		((volatile long *)(BASE+0x1A104L)) /* DSP Matrix Control */
#define D_MTXA		((volatile long *)(BASE+0x1A108L)) /* DSP Matrix Address */
#define D_END		((volatile long *)(BASE+0x1A10CL)) /* DSP Data Organization */
#define D_PC		((volatile long *)(BASE+0x1A110L)) /* DSP Program Counter */
#define D_CTRL		((volatile long *)(BASE+0x1A114L)) /* DSP Operation Control/Status */
#define D_MOD		((volatile long *)(BASE+0x1A118L)) /* DSP Modulo Instruction Mask */
#define D_REMAIN	((volatile long *)(BASE+0x1A11CL)) /* DSP Division Remainder */
#define D_DIVCTRL	((volatile long *)(BASE+0x1A11CL)) /* DSP Divider control */
#define D_MACHI 	((volatile long *)(BASE+0x1A120L)) /* DSP Hi byte of MAC operations */
#define D_RAM		((volatile long *)(BASE+0x1B000L)) /* DSP Internal RAM */
#define D_ENDRAM	((volatile long *)(((volatile char *)D_RAM)+(8*1024)))

/*
 * JERRY Flag Register Equates
 */

#define D_CPUENA	0x00000010L	/* CPU Interrupt Enable Bit */
#define D_I2SENA	0x00000020L	/* I2S Interrupt Enable Bit */
#define D_TIM1ENA	0x00000040L	/* Timer 1 Interrupt Enable Bit */
#define D_TIM2ENA	0x00000080L	/* Timer 2 Interrupt Enable Bit */
#define D_EXT0ENA	0x00000100L	/* External Interrupt 0 Enable Bit */
#define D_EXT1ENA	0x00010000L	/* External Interrupt 1 Enable Bit */

#define D_CPUCLR	0x00000200L	/* CPU Interrupt Clear Bit */
#define D_I2SCLR	0x00000400L	/* I2S Interrupt Clear Bit */
#define D_TIM1CLR	0x00000800L	/* Timer 1 Interrupt Clear Bit */
#define D_TIM2CLR	0x00001000L	/* Timer 2 Interrupt Clear Bit */
#define D_EXT0CLR	0x00002000L	/* External Interrupt 0 Clear Bit */
#define D_EXT1CLR	0x00020000L	/* External Interrupt 1 Clear Bit */

/*
 * JERRY Control/Status Register
 */

#define DSPGO		0x00000001L	/* Start DSP */
#define DSPINT0 	0x00000004L	/* Generate a DSP Interrupt 0 */

#define D_CPULAT	0x00000040L	/* Interrupt Latches */
#define D_I2SLAT	0x00000080L
#define D_TIM1LAT	0x00000100L
#define D_TIM2LAT	0x00000200L
#define D_EXT1LAT	0x00000400L
#define D_EXT2LAT	0x00010000L

/*
 * JERRY Modulo Instruction Masks
 */

#define MODMASK2	0xFFFFFFFEL	/* 2 byte circular buffer */
#define MODMASK4	0xFFFFFFFCL	/* 4 byte circular buffer */
#define MODMASK8	0xFFFFFFF8L	/* 8 byte circular buffer */
#define MODMASK16	0xFFFFFFF0L	/* 16 byte circular buffer */
#define MODMASK32	0xFFFFFFE0L	/* 32 byte circular buffer */
#define MODMASK64	0xFFFFFFC0L	/* 64 byte circular buffer */
#define MODMASK128	0xFFFFFF80L	/* 128 byte circular buffer */
#define MODMASK256	0xFFFFFF00L	/* 256 byte circular buffer */
#define MODMASK512	0xFFFFFE00L	/* 512 byte circular buffer */
#define MODMASK1K	0xFFFFFC00L	/* 1k circular buffer  */
#define MODMASK2K	0xFFFFF800L	/* 2k circular buffer */
#define MODMASK4K	0xFFFFF000L	/* 4k circular buffer */
#define MODMASK8K	0xFFFFE000L	/* 8k circular buffer */
#define MODMASK16K	0xFFFFC000L	/* 16k circular buffer */
#define MODMASK32K	0xFFFF8000L	/* 32k circular buffer */
#define MODMASK64K	0xFFFF0000L	/* 64k circular buffer */
#define MODMASK128K	0xFFFE0000L	/* 128k circular buffer */
#define MODMASK256K	0xFFFC0000L	/* 256k circular buffer */
#define MODMASK512K	0xFFF80000L	/* 512k circular buffer */
#define MODMASK1M	0xFFF00000L	/* 1M circular buffer */

/*
 * SHARED Equates for TOM (GPU) and JERRY (DSP)
 */

/* Control/Status Registers */

#define RISCGO		0x00000001L	/* Start GPU or DSP */
#define CPUINT		0x00000002L	/* Allow the GPU/DSP to interrupt CPU */
#define FORCEINT0	0x00000004L	/* Cause an INT 0 on GPU or DSP */
#define SINGLE_STEP	0x00000008L	/* Enter SINGLE_STEP mode */
#define SINGLE_GO	0x00000010L	/* Execute one instruction */

#define REGPAGE 	0x00004000L	/* Register Bank Select */
#define DMAEN		0x00008000L	/* Enable DMA LOAD and STORE */

/* Flags Register */

#define ZERO_FLAG	0x00000001L	/* ALU Zero Flag */
#define CARRY_FLAG	0x00000002L	/* ALU Carry Flag */
#define NEGA_FLAG	0x00000004L	/* ALU Negative Flag */

#define IMASK		0x00000008L	/* Interrupt Service Mask */

/* Matrix Control Register */

#define MATRIX3 	0x00000003L	/* use for 3x1 Matrix */
#define MATRIX4 	0x00000004L	/* etc... */
#define MATRIX5 	0x00000005L
#define MATRIX6 	0x00000006L
#define MATRIX7 	0x00000007L
#define MATRIX8 	0x00000008L
#define MATRIX9 	0x00000009L
#define MATRIX10	0x0000000AL
#define MATRIX11	0x0000000BL
#define MATRIX12	0x0000000CL
#define MATRIX13	0x0000000DL
#define MATRIX14	0x0000000EL
#define MATRIX15	0x0000000FL

#define MATROW		0x00000000L	/* Access Matrix by Row */
#define MATCOL		0x00000010L	/* Access Matrix by Column */

/* Data Organisation Register */

#define BIG_IO		0x00010001L	/* Make I/O Big-Endian */
#define BIG_PIX 	0x00020002L	/* Access Pixels in Big-Endian */
#define BIG_INST	0x00040004L	/* Fetch Instructions in Big-Endian */

/* Divide Unit Control */

#define DIV_OFFSET	0x00000001L	/* Divide 16.16 values if set */



/**********************************************************************/
/* Old definitions maintained for compatibility with old source code. */
/* You must #define _COMPAT (1) for these to be active.               */
/**********************************************************************/

#if (_COMPAT_ == 1)

#define MOD_MASK	((volatile long *)(BASE+0x1A118L)) /* Mask for ADDQ(SUBQ)MOD */

#endif

/*******/
/* EOF */
/*******/
