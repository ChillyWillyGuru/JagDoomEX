;       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;       |                                                       |
;       |      Driver de Musique au format Future Composer      |
;       |                                                       |
;       |    Pour Console Atari Jaguar utilisant le DSP+68000   |
;       |         (C)oderight 1994 Virtual eXperience           |
;       |                                                       |
;       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                include "j:\\include\\jaguar.inc"
                include "j:\\include\\video.inc"

;       ---------------------------------------------------------
;       --             Adresses des registres sonores          --
;       ---------------------------------------------------------
ldff096         equ     D_ENDRAM-(4*28)
ldff09a         equ     ldff096+4
ldff0a0         equ     ldff09a+4
ldff0a8         equ     ldff0a0+12
ldff0b0         equ     ldff0a8+12
ldff0b8         equ     ldff0b0+12
ldff0c0         equ     ldff0b8+12
ldff0c8         equ     ldff0c0+12
ldff0d0         equ     ldff0c8+12
ldff0d8         equ     ldff0d0+12

;       ---------------------------------------------------------
;       --                 Le Driver de Musique                --
;       ---------------------------------------------------------


                .TEXT
                .68000

                bsr     init_music
                move.l  #Frame,$100
                move.w  #n_vde+1,VI
                move.w  #1,INT1
                move.w  sr,d0
                and.w   #$f8ff,d0
                move.w  d0,sr

glop:           bra     glop

Frame:
                movem.l d0-d7/a0-a6,-(sp)
                ;add.w   #$d555,mt_sync
                ;bcc.s   step
                move.w  #5000,d0
zzz:            nop
                dbf     d0,zzz


                move.w  #$FFFF,BG
                bsr     play
step:           move.w  #$101,INT1
                move.w  #0,INT2
                move.w  #0,BG
                movem.l (sp)+,d0-d7/a0-a6
                rte

mt_sync:        dc.w    0


end_music:
                move.w  #0,onoff
                move.l  #0,ldff0a8
                move.l  #0,ldff0b8
                move.l  #0,ldff0c8
                move.l  #0,ldff0d8
                rts

init_music:
                move.w  #1,onoff
                lea     module,a0
                lea     100(a0),a1
                move.l  a1,seqpoint
                move.l  a0,a1
                add.l   8(a0),a1
                move.l  a1,patpoint
                move.l  a0,a1
                add.l   16(a0),a1
                move.l  a1,frqpoint
                move.l  a0,a1
                add.l   24(a0),a1
                move.l  a1,volpoint
                move.l  4(a0),d0
                divu    #13,d0
                lea     40(a0),a1
                lea     soundinfo+4(pc),a2
                moveq   #9,d1
initloop:       move.w  (a1)+,(a2)+
                move.l  (a1)+,(a2)+
                addq.w  #4,a2
                dbf     d1,initloop
                moveq   #0,d2
                move.l  a0,d1
                add.l   32(a0),d1
                sub.l   #waveforms,d1
                lea     soundinfo(pc),a0
                move.l  d1,(a0)+
                moveq   #9-1,d3
initloop1:      move.w  (a0),d2
                add.l   d2,d1
                add.l   d2,d1
                addq.w  #6,a0
                move.l  d1,(a0)+
                dbf     d3,initloop1
                move.l  seqpoint(pc),a0
                moveq   #0,d2
                move.b  12(a0),d2
                bne.s   speedok
                move.b  #3,d2
speedok:        move.w  d2,respcnt
                move.w  d2,repspd
init2:          move.w  #0,audtemp
                moveq   #0,d7
                mulu    #13,d0
                moveq   #4-1,d6
                lea     v1data(pc),a0
                lea     silent(pc),a1
                lea     o4a0c8(pc),a2
initloop2:      move.l  a1,10(a0)
                move.l  a1,18(a0)
                move.l  #0,14(a0)
                move.b  #0,45(a0)
                move.b  #0,47(a0)
                move.w  #0,8(a0)
                move.l  #0,48(a0)
                move.b  #$01,23(a0)
                move.b  #$01,24(a0)
                move.b  #0,25(a0)
                move.l  #0,26(a0)
                move.w  #0,30(a0)
                moveq   #$00,d3
                move.w  (a2)+,d1
                move.w  (a2)+,d3
                divu    #$0003,d3
                move.b  d3,32(a0)
                mulu    #$0003,d3
                andi.l  #$00ff,d3
                andi.l  #$00ff,d1
                addi.l  #ldff0a0,d1
                move.l  d1,a6
                move.l  #$0000,(a6)
                move.w  #$0100,4(a6)
                move.w  #$0000,6(a6)
                move.w  #$0000,8(a6)
                move.l  d1,60(a0)
                move.w  #0,64(a0)
                move.l  seqpoint(pc),(a0)
                move.l  seqpoint(pc),52(a0)
                add.l   d0,52(a0)
                add.l   d3,52(a0)
                add.l   d7,(a0)
                add.l   d3,(a0)
                move.w  #$d,6(a0)
                move.l  (a0),a3
                move.b  (a3),d1
                and.l   #$ff,d1
                lsl.w   #6,d1
                move.l  patpoint(pc),a4
                adda.w  d1,a4
                move.l  a4,34(a0)
                move.l  #0,38(a0)
                move.b  #1,33(a0)
                move.b  #2,42(a0)
                move.b  1(a3),44(a0)
                move.b  2(a3),22(a0)
                move.b  #0,43(a0)
                move.b  #0,45(a0)
                move.w  #0,56(a0)
                add.w   #$4a,a0
                dbf     d6,initloop2
                move.l  #$00070007,D_END        ; Set the Good Mode
                move.l  #$00000000,D_CTRL       ; Stop the DSP
                lea     mt_dsp_code(pc),a0
                move.l  (a0)+,a1
                move.l  a1,a2
                move.l  (a0)+,d0
                asr.l   #2,d0
mt_loop7:       move.l  (a0)+,(a1)+
                dbra    d0,mt_loop7
                move.l  #11,SCLK
                move.l  #$15,SMODE
                move.w  #$100,$f14000           ; Mute Bit Condition
                move.l  a2,D_PC                 ; Set DSP PC
                move.l  #$00000001,D_CTRL       ; Set the DSP going
                rts


play:
                lea     pervol(pc),a6
                tst.w   onoff
                bne.s   music_on
                rts
music_on:       subq.w  #1,respcnt
                bne.s   nonewnote
                move.w  repspd(pc),respcnt
                lea     v1data(pc),a0
                bsr     new_note
                lea     v2data(pc),a0
                bsr     new_note
                lea     v3data(pc),a0
                bsr     new_note
                lea     v4data(pc),a0
                bsr     new_note
nonewnote:      move.w  #0,audtemp
                lea     v1data(pc),a0
                bsr     effects
                move.w  d0,(a6)+
                move.w  d1,(a6)+
                lea     v2data(pc),a0
                bsr     effects
                move.w  d0,(a6)+
                move.w  d1,(a6)+
                lea     v3data(pc),a0
                bsr     effects
                move.w  d0,(a6)+
                move.w  d1,(a6)+
                lea     v4data(pc),a0
                bsr     effects
                move.w  d0,(a6)+
                move.w  d1,(a6)+
                lea     pervol(pc),a6
                moveq   #0,d1
                move.l  start1(pc),d2
                move.w  offset1(pc),d1
                add.l   d1,d2
                move.l  start2(pc),d3
                move.w  offset2(pc),d1
                add.l   d1,d3
                move.l  start3(pc),d4
                move.w  offset3(pc),d1
                add.l   d1,d4
                move.l  start4(pc),d5
                move.w  offset4(pc),d1
                add.l   d1,d5
                moveq   #0,d0
                moveq   #0,d1
                moveq   #0,d6
                moveq   #0,d7
                move.w  ssize1(pc),d0
                move.w  ssize2(pc),d1
                move.w  ssize3(pc),d6
                move.w  ssize4(pc),d7
chan1:
                lea     v1data(pc),a0
                tst.w   72(a0)
                beq     chan2
                subq.w  #1,72(a0)
                cmpi.w  #1,72(a0)
                bne.s   chan2
                move.w  #0,72(a0)
                add.w   d0,d0
                move.l  d2,ldff0a0+16
                move.l  d0,ldff0a0+20
chan2:
                lea     v2data(pc),a0
                tst.w   72(a0)
                beq.s   chan3
                subq.w  #1,72(a0)
                cmpi.w  #1,72(a0)
                bne.s   chan3
                move.w  #0,72(a0)
                add.w   d1,d1
                move.l  d3,ldff0b0+16
                move.l  d1,ldff0b0+20
chan3:
                lea     v3data(pc),a0
                tst.w   72(a0)
                beq.s   chan4
                subq.w  #1,72(a0)
                cmpi.w  #1,72(a0)
                bne.s   chan4
                move.w  #0,72(a0)
                add.w   d6,d6
                move.l  d4,ldff0c0+16
                move.l  d6,ldff0c0+20
chan4:
                lea     v4data(pc),a0
                tst.w   72(a0)
                beq.s   setpervol
                subq.w  #1,72(a0)
                cmpi.w  #1,72(a0)
                bne.s   setpervol
                move.w  #0,   72(a0)
                add.w   d7,d7
                move.l  d5,ldff0d0+16
                move.l  d7,ldff0d0+20
setpervol:      lea     ldff0a0,a5
                lea     vol_tab(pc),a0
                moveq   #3,d2
                moveq   #0,d1
setall:         move.l  #$6a0000,d0
                move.w  (a6)+,d1
                beq.s   divzero
                divu    d1,d0
                swap    d0
                and.l   #$ffff0000,d0
                move.l  d0,8(a5)
divzero:        move.w  (a6)+,d0
                lsl.w   #2,d0
                move.l  (a0,d0.w),12(a5)
                lea     24(a5),a5
                dbra    d2,setall
                rts

new_note:
                moveq   #0,d5
                move.l  34(a0),a1
                adda.w  40(a0),a1
                cmp.w   #64,40(a0)
                bne     samepat
                move.l  (a0),a2
                adda.w  6(a0),a2
                cmpa.l  52(a0),a2
                bne.s   notend
                move.w  d5,6(a0)
                move.l  (a0),a2
notend:         moveq   #0,d1
                addq.b  #1,spdtemp
                cmpi.b  #4,spdtemp
                bne.s   nonewspd
                move.b  d5,spdtemp
                move.b  -1(a1),d1
                beq.s   nonewspd
                move.w  d1,respcnt
                move.w  d1,repspd
nonewspd:       move.b  (a2),d1
                move.b  1(a2),44(a0)
                move.b  2(a2),22(a0)
                move.w  d5,40(a0)
                lsl.w   #6,d1
                add.l   patpoint(pc),d1
                move.l  d1,34(a0)
                addi.w  #$000d,6(a0)
                move.l  d1,a1
samepat:        move.b  1(a1),d1
                move.b  (a1)+,d0
                bne.s   ww1
                andi.w  #%11000000,d1
                beq.s   noport
                bra.s   ww11
ww1:            move.w  d5,56(a0)
ww11:           move.b  d5,47(a0)
                move.b  (a1),31(a0)
t_porton:       btst    #7,d1
                beq.s   noport
                move.b  2(a1),47(a0)
noport:         andi.w  #$007f,d0
                beq     nextnote
                move.b  d0,8(a0)
                move.b  (a1),9(a0)
                move.b  32(a0),d2
                moveq   #0,d3
                bset    d2,d3
                or.w    d3,audtemp
                move.b  (a1),d1
                and.w   #$3f,d1
                add.b   22(a0),d1
                move.l  volpoint(pc),a2
                lsl.w   #6,d1
                adda.w  d1,a2
                move.w  d5,16(a0)
                move.b  (a2),23(a0)
                move.b  (a2)+,24(a0)
                move.b  (a2)+,d1
                andi.w  #$00ff,d1
                move.b  (a2)+,27(a0)
                move.b  #$40,46(a0)
                move.b  (a2)+,d0
                move.b  d0,28(a0)
                move.b  d0,29(a0)
                move.b  (a2)+,30(a0)
                move.l  a2,10(a0)
                move.l  frqpoint(pc),a2
                lsl.w   #6,d1
                adda.w  d1,a2
                move.l  a2,18(a0)
                move.w  d5,50(a0)
                move.b  d5,26(a0)
                move.b  d5,25(a0)
nextnote:
                addq.w  #2,40(a0)
                rts

effects:
                moveq   #0,d7
testsustain:    tst.b   26(a0)
                beq.s   sustzero
                subq.b  #1,26(a0)
                bra     volufx
sustzero:       move.l  18(a0),a1
                adda.w  50(a0),a1
testeffects:    cmpi.b  #$e1,(a1)
                beq     volufx
                cmpi.b  #$e0,(a1)
                bne.s   testnewsound
                move.b  1(a1),d0
                andi.w  #$003f,d0
                move.w  d0,50(a0)
                move.l  18(a0),a1
                adda.w  d0,a1
testnewsound:   cmpi.b  #$e2,(a1)
                bne.s   o49c64
                moveq   #0,d0
                moveq   #0,d1
                move.b  32(a0),d1
                bset    d1,d0
                or.w    d0,audtemp
                move.b  1(a1),d0
                andi.w  #$00ff,d0
                lea     soundinfo(pc),a4
                add.w   d0,d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d1,d1
                add.w   d1,d0
                adda.w  d0,a4
                move.l  60(a0),a3
                move.l  (a4),d1
                add.l   #waveforms,d1
                move.l  d1,(a3)
                move.l  d1,68(a0)
                moveq   #0,d0
                move.w  4(a4),d0
                add.w   d0,d0
                move.l  d0,4(a3)
                move.l  6(a4),64(a0)
                swap    d1
                move.w  #$0003,72(a0)
                tst.w   d1
                bne.s   o49c52
                move.w  #$0002,72(a0)
o49c52:         move.w  #0,16(a0)
                move.b  #$01,23(a0)
                addq.w  #2,50(a0)
                bra     o49d02
o49c64:         cmpi.b  #$e4,(a1)
                bne.s   testpatjmp
                move.b  1(a1),d0
                andi.w  #$00ff,d0
                lea     soundinfo(pc),a4
                add.w   d0,d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d1,d1
                add.w   d1,d0
                adda.w  d0,a4
                move.l  60(a0),a3
                move.l  (a4),d1
                add.l   #waveforms,d1
                move.l  d1,(a3)
                move.l  d1,68(a0)
                moveq   #0,d0
                move.w  4(a4),d0
                add.w   d0,d0
                move.l  d0,4(a3)
                move.l  6(a4),64(a0)
                swap    d1
                move.w  #$0003,72(a0)
                tst.w   d1
                bne.s   o49cae
                move.w  #$0002,72(a0)
o49cae:         addq.w  #2,50(a0)
                bra.s   o49d02
testpatjmp:     cmpi.b  #$e7,(a1)
                bne.s   testnewsustain
                move.b  1(a1),d0
                andi.w  #$00ff,d0
                lsl.w   #6,d0
                move.l  frqpoint(pc),a1
                adda.w  d0,a1
                move.l  a1,18(a0)
                move.w  d7,50(a0)
                bra     testeffects
testnewsustain: cmpi.b  #$e8,(a1)
                bne.s   o49cea
                move.b  1(a1),26(a0)
                addq.w  #2,50(a0)
                bra     testsustain
o49cea:         cmpi.b  #$e3,(a1)
                bne.s   o49d02
                addq.w  #3,50(a0)
                move.b  1(a1),27(a0)
                move.b  2(a1),28(a0)
o49d02:         move.l  18(a0),a1
                adda.w  50(a0),a1
                move.b  (a1),43(a0)
                addq.w  #1,50(a0)
volufx:         tst.b   25(a0)
                beq.s   o49d1e
                subq.b  #1,25(a0)
                bra.s   o49d70
o49d1e:         subq.b  #1,23(a0)
                bne.s   o49d70
                move.b  24(a0),23(a0)
o49d2a:         move.l  10(a0),a1
                adda.w  16(a0),a1
                move.b  (a1),d0
                cmpi.b  #$e8,d0
                bne.s   o49d4a
                addq.w  #2,16(a0)
                move.b  1(a1),25(a0)
                bra.s   volufx
o49d4a:         cmpi.b  #$e1,d0
                beq.s   o49d70
                cmpi.b  #$e0,d0
                bne.s   o49d68
                move.b  1(a1),d0
                andi.l  #$003f,d0
                subq.b  #5,d0
                move.w  d0,16(a0)
                bra.s   o49d2a
o49d68:         move.b  (a1),45(a0)
                addq.w  #1,16(a0)
o49d70:         move.b  43(a0),d0
                bmi.s   o49d7e
                add.b   8(a0),d0
                add.b   44(a0),d0
o49d7e:         andi.w  #$007f,d0
                lea     periods(pc),a1
                add.w   d0,d0
                move.w  d0,d1
                adda.w  d0,a1
                move.w  (a1),d0
                move.b  46(a0),d7
                tst.b   30(a0)
                beq.s   o49d9e
                subq.b  #1,30(a0)
                bra.s   o49df4
o49d9e:         move.b  d1,d5
                move.b  28(a0),d4
                add.b   d4,d4
                move.b  29(a0),d1
                tst.b   d7
                bpl.s   o49db4
                btst    #0,d7
                bne.s   o49dda
o49db4:         btst    #5,d7
                bne.s   o49dc8
                sub.b   27(a0),d1
                bcc.s   o49dd6
                bset    #5,d7
                moveq   #0,d1
                bra.s   o49dd6
o49dc8:         add.b   27(a0),d1
                cmp.b   d4,d1
                bcs.s   o49dd6
                bclr    #5,d7
                move.b  d4,d1
o49dd6:         move.b  d1,29(a0)
o49dda:         lsr.b   #1,d4
                sub.b   d4,d1
                bcc.s   o49de4
                subi.w  #$0100,d1
o49de4:         addi.b  #$a0,d5
                bcs.s   o49df2
o49dea:         add.w   d1,d1
                addi.b  #$18,d5
                bcc.s   o49dea
o49df2:         add.w   d1,d0
o49df4:         eori.b  #$01,d7
                move.b  d7,46(a0)
                moveq   #0,d1
                move.b  47(a0),d1
                beq.s   a56d0
                cmpi.b  #$1f,d1
                bls.s   portaup
portadown:      and.w   #$1f,d1
                neg.w   d1
portaup:        sub.w   d1,56(a0)
a56d0:          add.w   56(a0),d0
o49e3e:         cmpi.w  #$0070,d0
                bhi.s   nn1
                move.w  #$0071,d0
nn1:            cmpi.w  #$06b0,d0
                bls.s   nn2
                move.w  #$06b0,d0
nn2:            moveq   #0,d1
                move.b  45(a0),d1
                rts



pervol:         dcb.b   16,0
respcnt:        dc.w    0
repspd:         dc.w    0
onoff:          dc.w    0
firseq:         dc.w    0
lasseq:         dc.w    0
audtemp:        dc.w    0
spdtemp:        dc.w    0
v1data:         dcb.b   64,0
offset1:        dcb.b   02,0
ssize1:         dcb.b   02,0
start1:         dcb.b   06,0

v2data:         dcb.b   64,0
offset2:        dcb.b   02,0
ssize2:         dcb.b   02,0
start2:         dcb.b   06,0

v3data:         dcb.b   64,0
offset3:        dcb.b   02,0
ssize3:         dcb.b   02,0
start3:         dcb.b   06,0

v4data:         dcb.b   64,0
offset4:        dcb.b   02,0
ssize4:         dcb.b   02,0
start4:         dcb.b   06,0

o4a0c8:         dc.l    $00000000,$00180003,$00300006,$00480009
seqpoint:       dc.l    0
patpoint:       dc.l    0
frqpoint:       dc.l    0
volpoint:       dc.l    0
silent:         dc.w    $0100,$0000,$0000,$00e1
periods:        dc.w    $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
                dc.w    $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
                dc.w    $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
                dc.w    $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
                dc.w    $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
                dc.w    $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
                dc.w    $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
                dc.w    $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
                dc.w    $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
                dc.w    $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
                dc.w    $10d0,$0fe0,$0f00,$0e28
soundinfo:
;offset.l       ,       sound-length.w  ,       start-offset.w  ,       repeat-length.w
;reserved       for     samples
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
                dc.w    $0000,$0000,$0000,$0000,$0001
;reserved       for     synth   sounds
                dc.w    $0000,$0000,$0010,$0000,$0010
                dc.w    $0000,$0020,$0010,$0000,$0010
                dc.w    $0000,$0040,$0010,$0000,$0010
                dc.w    $0000,$0060,$0010,$0000,$0010
                dc.w    $0000,$0080,$0010,$0000,$0010
                dc.w    $0000,$00a0,$0010,$0000,$0010
                dc.w    $0000,$00c0,$0010,$0000,$0010
                dc.w    $0000,$00e0,$0010,$0000,$0010
                dc.w    $0000,$0100,$0010,$0000,$0010
                dc.w    $0000,$0120,$0010,$0000,$0010
                dc.w    $0000,$0140,$0010,$0000,$0010
                dc.w    $0000,$0160,$0010,$0000,$0010
                dc.w    $0000,$0180,$0010,$0000,$0010
                dc.w    $0000,$01a0,$0010,$0000,$0010
                dc.w    $0000,$01c0,$0010,$0000,$0010
                dc.w    $0000,$01e0,$0010,$0000,$0010
                dc.w    $0000,$0200,$0010,$0000,$0010
                dc.w    $0000,$0220,$0010,$0000,$0010
                dc.w    $0000,$0240,$0010,$0000,$0010
                dc.w    $0000,$0260,$0010,$0000,$0010
                dc.w    $0000,$0280,$0010,$0000,$0010
                dc.w    $0000,$02a0,$0010,$0000,$0010
                dc.w    $0000,$02c0,$0010,$0000,$0010
                dc.w    $0000,$02e0,$0010,$0000,$0010
                dc.w    $0000,$0300,$0010,$0000,$0010
                dc.w    $0000,$0320,$0010,$0000,$0010
                dc.w    $0000,$0340,$0010,$0000,$0010
                dc.w    $0000,$0360,$0010,$0000,$0010
                dc.w    $0000,$0380,$0010,$0000,$0010
                dc.w    $0000,$03a0,$0010,$0000,$0010
                dc.w    $0000,$03c0,$0010,$0000,$0010
                dc.w    $0000,$03e0,$0010,$0000,$0010
                dc.w    $0000,$0400,$0008,$0000,$0008
                dc.w    $0000,$0410,$0008,$0000,$0008
                dc.w    $0000,$0420,$0008,$0000,$0008
                dc.w    $0000,$0430,$0008,$0000,$0008
                dc.w    $0000,$0440,$0008,$0000,$0008
                dc.w    $0000,$0450,$0008,$0000,$0008
                dc.w    $0000,$0460,$0008,$0000,$0008
                dc.w    $0000,$0470,$0008,$0000,$0008
                dc.w    $0000,$0480,$0010,$0000,$0010
                dc.w    $0000,$04a0,$0008,$0000,$0008
                dc.w    $0000,$04b0,$0010,$0000,$0010
                dc.w    $0000,$04d0,$0010,$0000,$0010
                dc.w    $0000,$04f0,$0008,$0000,$0008
                dc.w    $0000,$0500,$0008,$0000,$0008
                dc.w    $0000,$0510,$0018,$0000,$0018
waveforms:
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $3f37,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c037,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b027,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a017,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$0f07,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9007,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$ff07,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8007,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$0f17,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$9017,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$9098,$1f27,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a027,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$2f37
                dc.w    $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
                dc.w    $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$b037
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                dc.w    $8181,$8181,$8181,$8181,$8181,$8181,$817f,$7f7f
                dc.w    $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
                dc.w    $8080,$8080,$8080,$8080,$8080,$8080,$8080,$7f7f
                dc.w    $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
                dc.w    $8080,$8080,$8080,$8080,$8080,$8080,$8080,$807f
                dc.w    $8080,$8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
                dc.w    $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
                dc.w    $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
                dc.w    $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070
                dc.w    $4545,$797d,$7a77,$7066,$6158,$534d,$2c20,$1812
                dc.w    $04db,$d3cd,$c6bc,$b5ae,$a8a3,$9d99,$938e,$8b8a
                dc.w    $4545,$797d,$7a77,$7066,$5b4b,$4337,$2c20,$1812
                dc.w    $04f8,$e8db,$cfc6,$beb0,$a8a4,$9e9a,$9594,$8d83
                dc.w    $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
                dc.w    $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
                dc.w    $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
                dc.w    $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
                dc.w    $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070

vol_tab:        dc.l    $0000
                dc.l    $0000,$1546,$21af,$2a8c,$31a3,$36f5,$3bec,$3fd2
                dc.l    $43b9,$46e9,$49c0,$4c96,$4f11,$5132,$5352,$5573
                dc.l    $5739,$58ff,$5ac4,$5c30,$5d9b,$5f06,$6071,$61dc
                dc.l    $62ec,$6457,$6567,$6678,$6788,$6898,$69a9,$6ab9
                dc.l    $6b6e,$6c7f,$6d8f,$6e45,$6efa,$700a,$70c0,$7176
                dc.l    $722b,$72e1,$7396,$744c,$7501,$75b7,$766c,$7722
                dc.l    $77d7,$788d,$78e8,$799d,$7a53,$7aad,$7b63,$7bbe
                dc.l    $7c73,$7cce,$7d84,$7dde,$7e94,$7eef,$7fa4,$7fff

mt_dsp_code:    dc.l    D_RAM
                dc.l    mt_fincode-mt_debcode
mt_debcode:     include "j:\\zok\\4v_emul.das"
mt_fincode:     dc.l    0

                .DATA
module:          incbin  "j:\\zok\\astarot2.mod"

;ÿ               .END
