
    .include "../Include/JAGUAR.INC"

	.text
	.68000

;/* entry point in rom ($802000), copy game code/data to ram at $4000

reset:
	lea     $200000,a7
	move.l  #$00070007,G_END
	move.l  #$00050005,D_END
	move.w  #$FFFF,VI

	lea     $40000,a2
	lea     $2000.w,a1
	lea     gamedata(pc),a0
cpysegs:
	move.l  (a0)+,(a1)+
	cmpa.l  a2,a1
	blt.s   cpysegs
	jmp     $2000.w

    .dphrase
gamedata:
