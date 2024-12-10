;GCC for Atari Jaguar M68K (May  4 1995)
gcc2_compiled_for_madmac:
	.DATA
	.EVEN
_rend::
	.DC.L	LC0
	.DC.L	_wfcode
	.DC.L	_wfenter
	.DC.W	0
	.DCB.B	2,0
	.DC.L	LC1
	.DC.L	_gourcode
	.DC.L	_gourenter
	.DC.W	0
	.DCB.B	2,0
	.DC.L	LC2
	.DC.L	_texcode
	.DC.L	_texenter
	.DC.W	0
	.DCB.B	2,0
	.DC.L	LC3
	.DC.L	_flattexcode
	.DC.L	_flattexenter
	.DC.W	1
	.DCB.B	2,0
	.DC.L	LC4
	.DC.L	_gstexcode
	.DC.L	_gstexenter
	.DC.W	1
	.DCB.B	2,0
	.TEXT
LC4:
	.DC.B	"Gouraud Shaded Textures",0
LC3:
	.DC.B	"Flat Shaded Textures",0
LC2:
	.DC.B	"Plain Textures",0
LC1:
	.DC.B	"Gouraud Only",0
LC0:
	.DC.B	"Wire Frames",0
	.DATA
	.EVEN
_models::
	.DC.L	_globedata
	.DC.W	0
	.DC.W	0
	.DC.W	400
	.DC.L	_ship1data
	.DC.W	0
	.DC.W	0
	.DC.W	1500
	.DC.L	_castledata
	.DC.W	0
	.DC.W	0
	.DC.W	6000
	.DC.L	_radardata
	.DC.W	0
	.DC.W	0
	.DC.W	256
	.EVEN
_buf1_olist::
	.DC.W	0
	.DC.W	20
	.DC.W	60
	.DC.L	0
	.DC.L	_DISPBUF0
	.DC.W	200
	.DC.W	240
	.DC.W	80
	.DC.W	4
	.DC.W	3
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	4
	.DCB.B	34,0
	.EVEN
_buf2_olist::
	.DC.W	0
	.DC.W	20
	.DC.W	60
	.DC.L	0
	.DC.L	_DISPBUF1
	.DC.W	200
	.DC.W	240
	.DC.W	80
	.DC.W	4
	.DC.W	3
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	4
	.DCB.B	34,0
	.EVEN
_scrn1::
	.DC.W	320
	.DC.W	200
	.DC.L	17059
	.DC.L	_DISPBUF0
	.EVEN
_scrn2::
	.DC.W	320
	.DC.W	200
	.DC.L	16995
	.DC.L	_DISPBUF1
	.EVEN
_lightm::
	.DC.W	0
	.DC.W	1
	.DC.W	-9459
	.DC.W	-9459
	.DC.W	-9459
	.DC.W	16384
	.DC.W	0
	.DC.W	0
	.DC.W	0
	.DC.W	49152
	.DC.W	16384
	.DC.W	0
	.DC.W	0
	.DC.W	16384
	.DC.W	0
	.DC.W	16384
	.DC.W	0
	.DC.W	16384
	.DC.W	0
	.DC.W	0
	.DC.W	16384
	.DC.W	16384
	.DCB.B	8,0
	.TEXT
	.EVEN
_N3Dclrbuf::
	link.w a6,#0
	move.l d2,-(sp)
	move.l 8(a6),a1
	move.l #664807328,d1
	moveq.l #-1,d0
	move.l #15737448,a0
	move.l d1,(a0)
	move.l #15737452,a0
	move.l d1,(a0)
	move.l #15737484,a0
	move.l d0,(a0)
	move.l #15737488,a0
	move.l d0,(a0)
	move.l #15737492,a0
	move.l d0,(a0)
	move.l #15737496,a0
	move.l d0,(a0)
	move.l #15737344,a0
	move.l 8(a1),(a0)
	move.l #15737360,a0
	move.w (a1),d0
	neg.w d0
	and.l #$FFFF,d0
	bset #16,d0
	move.l d0,(a0)
	move.l #15737348,a0
	move.l 4(a1),(a0)
	move.l #15737356,a0
	moveq.l #0,d2
	move.l d2,(a0)
	move.l #15737352,a0
	move.l d2,(a0)
	move.l #15737404,a0
	move.w 2(a1),d0
	swap d0
	clr.w d0
	move.w (a1),d1
	ext.l d1
	or.l d1,d0
	move.l d0,(a0)
	move.l #15737400,a0
	move.l #66080,(a0)
	move.l -4(a6),d2
	unlk a6
	rts
	.EVEN
_N3Drender::
	link.w a6,#0
	movem.l #$3830,-(sp)
	move.l 8(a6),d4
	move.l 12(a6),a2
	move.l 16(a6),d2
	move.l 20(a6),d3
	move.l 24(a6),a3
	move.l 4(a3),-(sp)
	jsr _GPUload
	move.l (a2),a0
	move.w 2(a0),d0
	ext.l d0
	asl.l #4,d0
	move.l d0,-(sp)
	jsr _malloc
	move.l d0,_tpoints
	move.l (a2)+,_params
	move.l a2,_params+4
	move.l d4,_params+8
	move.l d2,_params+12
	move.l d3,_params+16
	move.l d0,_params+20
	move.l 8(a3),-(sp)
	jsr _GPUrun
	move.l _tpoints,-(sp)
	jsr _free
	movem.l -20(a6),#$c1c
	unlk a6
	rts
	.EVEN
_fixtexture::
	link.w a6,#0
	move.l d3,-(sp)
	move.l d2,-(sp)
	move.l 8(a6),a0
	move.w (a0),d0
	muls.w 2(a0),d0
	bpl L24
	addq.l #3,d0
L24:
	move.l d0,d2
	asr.l #2,d2
	move.l 8(a0),a0
	moveq.l #0,d1
	cmp.l d1,d2
	ble L26
	move.l #8388736,d3
L28:
	move.l (a0),d0
	eor.l d3,d0
	move.l d0,(a0)+
	move.l (a0),d0
	eor.l d3,d0
	move.l d0,(a0)+
	addq.l #1,d1
	cmp.l d1,d2
	bgt L28
L26:
	move.l -8(a6),d2
	move.l -4(a6),d3
	unlk a6
	rts
	.EVEN
_fixalltextures::
	link.w a6,#0
	movem.l #$3830,-(sp)
	move.w 8(a6),d4
	cmp.w _texturestate.l,d4
	beq L31
	clr.w d3
	lea _models,a3
L35:
	move.w d3,d0
	muls.w #10,d0
	move.l (a3,d0.l),a2
	clr.w d2
	cmp.w 4(a2),d2
	bge L34
L39:
	move.w d2,d0
	ext.l d0
	move.l 16(a2),a0
	asl.l #3,d0
	move.l 4(a0,d0.l),d0
	beq L38
	move.l d0,-(sp)
	jsr _fixtexture
	addq.w #4,sp
L38:
	addq.w #1,d2
	cmp.w 4(a2),d2
	blt L39
L34:
	addq.w #1,d3
	cmp.w #3,d3
	bls L35
	move.w d4,_texturestate
L31:
	movem.l -20(a6),#$c1c
	unlk a6
	rts
LC5:
	.DC.B	"%d faces/%d fps",0
LC6:
	.DC.B	"%08lx draw time",0
LC7:
	.DC.B	"%ld polys/sec",0
	.EVEN
_main::
	link.w a6,#-288
	movem.l #$3f3c,-(sp)
	jsr ___main
	pea _packed_olist1
	pea _buf1_olist
	lea _OLbldto,a2
	jsr (a2)
	pea _packed_olist2
	pea _buf2_olist
	jsr (a2)
	move.l #_packed_olist2,_OList
	move.w #1729,-(sp)
	jsr _VIDon
	jsr _VIDsync
	move.l #384000,-(sp)
	clr.w -(sp)
	pea _DISPBUF0
	lea _memset,a2
	jsr (a2)
	clr.w d5
	moveq.l #4,d3
	clr.w d6
	pea 28.w
	clr.w -(sp)
	pea _testobj
	jsr (a2)
	move.l _models,_testobj
	move.w _models+4,_objangles+6
	move.w _models+6,_objangles+8
	move.w _models+8,_objangles+10
	lea _objangles,a0
	clr.w _objangles+4
	clr.w _objangles+2
	clr.w (a0)
	clr.w _camangles+4
	clr.w _camangles+2
	clr.w _camangles
	clr.w _camangles+8
	clr.w _camangles+6
	clr.w _camangles+10
	move.l a0,a3
	move.l __timestamp,-284(a6)
	moveq.l #1,d4
	clr.w _texturestate
	add.w #38,sp
	move.w _rend+76,-(sp)
	jsr _fixalltextures
	addq.w #2,sp
	lea (-24,a6),a1
	move.l a1,-288(a6)
	move.l #_FNTstr,d7
	lea (-280,a6),a5
L44:
	lea _scrn1,a4
	tst.w d5
	beq L47
	lea _scrn2,a4
L47:
	pea _objangles
	pea _testobj+4
	lea _mkMatrix,a2
	jsr (a2)
	pea _camangles
	move.l -288(a6),-(sp)
	jsr (a2)
	move.l a4,-(sp)
	jsr _N3Dclrbuf
	jsr _clock
	move.l d0,d2
	move.w d3,d0
	ext.l d0
	asl.l #4,d0
	move.l d0,a2
	add.l #_rend,a2
	move.l a2,-(sp)
	pea _lightm
	move.l -288(a6),-(sp)
	pea _testobj
	move.l a4,-(sp)
	jsr _N3Drender
	add.w #40,sp
	jsr _clock
	sub.l d2,d0
	move.l d0,d2
	clr.w -(sp)
	move.w #32767,-(sp)
	pea _usefnt
	move.l 4(a4),-(sp)
	move.l 8(a4),-(sp)
	move.l (a2),-(sp)
	clr.w -(sp)
	move.w #20,-(sp)
	move.l d7,a1
	jsr (a1)
	move.w d4,-(sp)
	move.l _testobj,a0
	move.w (a0),-(sp)
	pea LC5
	move.l a5,-(sp)
	jsr _sprintf
	add.w #36,sp
	clr.w -(sp)
	move.w #10239,-(sp)
	pea _usefnt
	move.l 4(a4),-(sp)
	move.l 8(a4),-(sp)
	move.l a5,-(sp)
	move.w #12,-(sp)
	move.w #20,-(sp)
	move.l d7,a1
	jsr (a1)
	move.l d2,-(sp)
	pea LC6
	move.l a5,-(sp)
	jsr _sprintf
	add.w #36,sp
	clr.w -(sp)
	move.w #61695,-(sp)
	pea _usefnt
	move.l 4(a4),-(sp)
	move.l 8(a4),-(sp)
	move.l a5,-(sp)
	move.w #24,-(sp)
	move.w #20,-(sp)
	move.l d7,a1
	jsr (a1)
	move.l _testobj,a0
	move.w (a0),d1
	ext.l d1
	move.l d1,d0
	asl.l #6,d0
	add.l d1,d0
	asl.l #4,d0
	sub.l d1,d0
	asl.l #2,d0
	sub.l d1,d0
	asl.l #2,d0
	sub.l d1,d0
	asl.l #2,d0
	sub.l d1,d0
	asl.l #2,d0
	move.l d2,-(sp)
	move.l d0,-(sp)
	jsr ___divsi3
	addq.w #8,sp
	move.l d0,d1
	add.l d1,d1
	add.l d0,d1
	asl.l #3,d1
	add.l d0,d1
	asl.l #2,d1
	move.l d1,-(sp)
	pea LC7
	move.l a5,-(sp)
	jsr _sprintf
	add.w #36,sp
	clr.w -(sp)
	move.w #10239,-(sp)
	pea _usefnt
	move.l 4(a4),-(sp)
	move.l 8(a4),-(sp)
	move.l a5,-(sp)
	move.w #36,-(sp)
	move.w #20,-(sp)
	move.l d7,a1
	jsr (a1)
	move.l _JOY1,-(sp)
	jsr _JOYget
	move.l d0,d2
	move.l _JOY1,-(sp)
	jsr _JOYedge
	move.l d0,d4
	add.w #32,sp
	btst #29,d2
	beq L49
	add.w #-16,10(a3)
	bra L50
	.EVEN
L49:
	btst #25,d2
	beq L51
	subq.w #2,10(a3)
	bra L50
	.EVEN
L51:
	btst #13,d2
	beq L53
	add.w #16,10(a3)
	bra L50
	.EVEN
L53:
	tst.b d2
	bge L55
	subq.w #4,8(a3)
	bra L50
	.EVEN
L55:
	btst #5,d2
	beq L57
	addq.w #4,8(a3)
	bra L50
	.EVEN
L57:
	btst #18,d2
	beq L59
	subq.w #4,6(a3)
	bra L50
	.EVEN
L59:
	btst #2,d2
	beq L50
	addq.w #4,6(a3)
L50:
	btst #20,d2
	beq L62
	add.w #-16,(a3)
	bra L63
	.EVEN
L62:
	btst #21,d2
	beq L63
	add.w #16,(a3)
L63:
	btst #22,d2
	beq L65
	add.w #-16,2(a3)
	bra L66
	.EVEN
L65:
	btst #23,d2
	beq L66
	add.w #16,2(a3)
L66:
	btst #19,d2
	beq L68
	add.w #-16,4(a3)
	bra L69
	.EVEN
L68:
	btst #3,d2
	beq L69
	add.w #16,4(a3)
L69:
	lea _objangles,a3
	btst #4,d2
	beq L71
	lea _camangles,a3
L71:
	btst #9,d4
	beq L73
	addq.w #1,d6
	cmp.w #3,d6
	bls L74
	clr.w d6
L74:
	move.w d6,d0
	muls.w #10,d0
	lea _models,a0
	move.l (a0,d0.l),_testobj
	move.w 4(a0,d0.l),_objangles+6
	move.w 6(a0,d0.l),_objangles+8
	move.w 8(a0,d0.l),_objangles+10
	clr.w _objangles+4
	clr.w _objangles+2
	clr.w _objangles
L73:
	btst #0,d4
	beq L75
	addq.w #1,d3
	cmp.w #4,d3
	bls L76
	clr.w d3
L76:
	move.w d3,d0
	ext.l d0
	asl.l #4,d0
	lea _rend,a0
	move.w 12(a0,d0.l),-(sp)
	jsr _fixalltextures
	addq.w #2,sp
L75:
	btst #16,d4
	beq L77
	tst.w d3
	bne L78
	moveq.l #5,d3
L78:
	subq.w #1,d3
	move.w d3,d0
	ext.l d0
	asl.l #4,d0
	lea _rend,a0
	move.w 12(a0,d0.l),-(sp)
	jsr _fixalltextures
	addq.w #2,sp
L77:
	move.l #_packed_olist1,d0
	tst.w d5
	beq L79
	move.l #_packed_olist2,d0
L79:
	move.l d0,_OList
	jsr _VIDsync
	move.l __timestamp,d0
	sub.l -284(a6),d0
	move.l d0,-(sp)
	pea 300.w
	jsr ___divsi3
	addq.w #8,sp
	move.l d0,d4
	move.l __timestamp,-284(a6)
	tst.w d5
	seq d0
	move.b d0,d5
	ext.w d5
	neg.w d5
	bra L44
	.EVEN
	nop
	.COMM	_option_key,2
	.COMM	_texturestate,2
	.COMM	_tpoints,4
	.COMM	_packed_olist1,320
	.COMM	_packed_olist2,320
	.COMM	_camangles,12
	.COMM	_objangles,12
	.COMM	_testobj,28
