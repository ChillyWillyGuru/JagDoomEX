;       ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;       º                                                               º
;       º            Driver de Musique au format Protracker             º
;       º                                                               º
;       º        Pour Console Atari Jaguar utilisant le DSP+68000       º
;       º             (C)oderight 1994 Virtual eXperience               º
;       º                                                               º
;       º   8 Canaux DMAs Enables: 16000 Cycles (800 move.l (An),(An))  º
;       ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

                include         "j:\\trax\\sound.inc"



;       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;       ³                  Le Driver de Musique                 ³
;       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                .TEXT
                .68000

mt_init:
                lea     mt_data,a0
                lea     $043c(a0),a1
                lea     $03b8(a0),a2
                lea     $2a(a0),a0
                lea     mt_samplestarts(pc),a3
                move.b  -2(a2),mt_endpos
                moveq   #0,d1
                moveq   #0,d2
                moveq   #127,d0
mt_loop1:       move.b  (a2)+,d1
                cmp.w   d1,d2
                bgt.s   mt_loop2
                move.w  d1,d2
mt_loop2:       dbra    d0,mt_loop1
                addq.w  #1,d2
                lsl.w   #8,d2
                lsl.l   #2,d2
                adda.l  d2,a1
                moveq   #0,d1
                moveq   #30,d0
mt_loop3:       move.l  a1,(a3)+
                move.w  (a0),d1
                add.w   d1,d1
                adda.l  d1,a1
                lea     30(a0),a0
                dbra    d0,mt_loop3
                lea     mt_periods(pc),a0
                moveq   #0,d2
                moveq   #36,d0
mt_loop4:       lea     mt_transtab(pc),a1
                move.w  (a0)+,d1
mt_loop5:       move.b  d2,(a1)+
                dbra    d1,mt_loop5
                addq.w  #2,d2
                dbra    d0,mt_loop4
                move.b #0,mt_counter
                move.w #0,mt_pattpos
                move.b #0,mt_songpos
                move.b #0,mt_pattdelay
                lea     mt_voldivtab(pc),a0
                moveq   #64,d0
                moveq   #0,d1
mt_loop6:       move.w  d1,d2
                mulu    #32767,d2
                divu    #64,d2
                ext.l   d2
                move.l  d2,(a0)+
                addq.w  #1,d1
                dbra    d0,mt_loop6
                move.l  #$00070007,D_END        ;Set the Good Mode
                move.l  #$00000000,D_CTRL       ; Stop the DSP
                lea     mt_dsp_code(pc),a0
                move.l  (a0)+,a1
                move.l  a1,mt_DSP_PC
                move.l  (a0)+,d0
                asr.l   #2,d0
mt_loop7:       move.l  (a0)+,(a1)+
                dbra    d0,mt_loop7
                move.l  #45,SCLK
                move.l  #$15,SMODE
                move.w  #$100,$f14000           ; Mute Bit Condition
                move.l  mt_DSP_PC,D_PC          ; Set DSP PC
                move.l  #$00000001,D_CTRL       ; Set the DSP going
mt_stop:        and.l  #$fffffff0,ldff096
                lea     ldff0a0,a0
                lea     mt_silent(pc),a1
                moveq   #7,d0
track_off:      move.l  a1,(a0)+
                move.l  #2,(a0)+
                move.l  #0,(a0)+
                move.l  #0,(a0)+
                move.l  a1,(a0)+
                move.l  #2,(a0)+
                dbra    d0,track_off
                rts

mt_music:
                movem.l d0-a6,-(sp)
                addq.b  #$01,mt_counter
                move.b  mt_counter,d0
                cmp.b   mt_speed,d0
                blt.s   mt_nonew
                move.b #0,mt_counter
                tst.b   mt_pattdelay
                beq     mt_getnew
                subq.b  #1,mt_pattdelay
                bne.s   mt_nonew
                bra     mt_getnew
mt_nonew:       move.w  #0,mt_dmacon
                lea     mt_voice1(pc),a6
                lea     ldff0a0,a5
                bsr     mt_checkcom
                lea     mt_voice2(pc),a6
                lea     ldff0b0,a5
                bsr     mt_checkcom
                lea     mt_voice3(pc),a6
                lea     ldff0c0,a5
                bsr     mt_checkcom
                lea     mt_voice4(pc),a6
                lea     ldff0d0,a5
                bsr     mt_checkcom
                moveq   #0,d0
                move.w  mt_dmacon,d0
                or.l    d0,ldff096
                bra     mt_endr

mt_arptab:      dc.b    0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arpeggio:
                moveq   #0,d0
                move.b  mt_counter(pc),d0
                move.b  mt_arptab(pc,d0.w),d0
                beq.s   mt_arp0
                cmp.w   #1,d0
                beq.s   mt_arp1
                bra.s   mt_arp2
mt_arp0:        move.w  $10(a6),d2
                bra.s   mt_arp4
mt_arp1:        move.b  $03(a6),d0
                lsr.b   #4,d0
                bra.s   mt_arp3
mt_arp2:        move.b  $03(a6),d0
                and.b   #$0f,d0
mt_arp3:        add.w   d0,d0
                moveq   #0,d2
                move.w  $10(a6),d1
                lea     mt_transtab(pc),a0
                move.b  (a0,d1.w),d2
                lea     mt_periods(pc),a0
                add.w   d2,a0
                add.w   d0,a0
                lea     mt_mulu74(pc),a1
                move.b  $12(a6),d2
                and.w   #$f,d2
                add.w   d2,d2
                add.w   (a1,d2.w),a0
                move.w  (a0),d2
mt_arp4:        move.w  d2,d0
                bra     mt_putfreq

mt_getnew:
                lea     mt_data,a0
                lea     $c(a0),a3
                lea     $3b8(a0),a2
                lea     $43c(a0),a0
                moveq   #0,d0
                move.l  d0,d1
                move.b  mt_songpos(pc),d0
                move.b  (a2,d0.w),d1
                swap    d1
                lsr.l   #6,d1
                move.w  mt_pattpos(pc),d0
                add.l   d0,d1
                add.l   d1,a0
                move.w #0,mt_dmacon
                lea     ldff0a0,a5
                lea     mt_voice1(pc),a6
                bsr.s   mt_playvoice
                lea     ldff0b0,a5
                lea     mt_voice2(pc),a6
                bsr.s   mt_playvoice
                lea     ldff0c0,a5
                lea     mt_voice3(pc),a6
                bsr.s   mt_playvoice
                lea     ldff0d0,a5
                lea     mt_voice4(pc),a6
                bsr.s   mt_playvoice
                bra     mt_setdma

mt_playvoice:
                move.l  (a0)+,(a6)
                moveq   #0,d2
                move.b  2(a6),d2
                lsr.b   #4,d2
                move.b  (a6),d0
                and.b   #$f0,d0
                or.b    d0,d2
                beq     mt_setregs
                moveq   #0,d3
                lea     mt_samplestarts(pc),a1
                add.w   d2,d2
                move.w  d2,d4
                subq.w  #2,d2
                add.w   d2,d2
                move.l  (a1,d2.w),$04(a6)
                move.l  a3,a1
                add.w   mt_mulu30(pc,d4.w),a1
                move.w  (a1)+,$08(a6)
                move.w  (a1)+,$12(a6)
                move.w  (a1)+,d3
                beq     mt_noloop
                move.w  d3,d0
                move.l  4(a6),d2
                add.w   d3,d3
                add.l   d3,d2
                move.l  d2,$a(a6)
                add.w   (a1),d0
                move.w  d0,8(a6)
                move.w  (a1),$e(a6)
                moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
                bra.s   mt_setregs

mt_mulu30:      dc.w    00,30,60,90,120,150,180,210,240,270,300
                dc.w    330,360,390,420,450,480,510,540,570,600
                dc.w    630,660,690,720,750,780,810,840,870,900,930

mt_mulu74:      dc.w    0,74,74*2,74*3,74*4,74*5,74*6,74*7,74*8
                dc.w    74*9,74*10,74*11,74*12,74*13,74*14,74*15

mt_noloop:      move.l  $04(a6),$0a(a6)
                move.w  (a1),$0e(a6)
                moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
mt_setregs:
                move.w  (a6),d0
                and.w   #$0fff,d0
                beq     mt_checkcom2
                moveq   #0,d2
                lea     mt_transtab(pc),a4
                move.b  (a4,d0.w),d2
                lea     mt_periods(pc),a4
                add.w   d2,a4
                move.b  $12(a6),d2
                and.w   #$f,d2
                add.w   d2,d2
                add.w   mt_mulu74(pc,d2.w),a4
                move.w  (a4),d2
                move.b  $02(a6),d0
                and.b   #$0f,d0
                cmp.b   #$03,d0
                beq     mt_setmyport
                cmp.b   #$05,d0
                beq     mt_setmyport
                move.w  d2,$10(a6)
                cmp.b   #$09,d0
                beq     mt_sampleoffset
mt_setregs2:    moveq   #0,d0
                move.w  $14(a6),d0
                not.l   d0
                and.l   d0,ldff096
                btst    #2,$1e(a6)
                bne.s   mt_noclrvib
                move.b #0,$1b(a6)
mt_noclrvib:    btst    #6,$1e(a6)
                bne.s   mt_noclrtrem
                move.b #0,$1d(a6)
mt_noclrtrem:
                move.l  $04(a6),$00(a5)
                moveq   #0,d0
                move.w  $08(a6),d0
                add.w   d0,d0
                move.l  d0,4(a5)
                move.w  $10(a6),d0
                bsr     mt_putfreq
                move.l  $0a(a6),$10(a5)
                moveq   #0,d0
                move.w  $0e(a6),d0
                add.w   d0,d0
                move.l  d0,$14(a5)
                move.w  $14(a6),d0
                or.w    d0,mt_dmacon
                bra     mt_checkcom2

mt_setdma:      moveq   #0,d0
                move.w  mt_dmacon,d0
                or.l    d0,ldff096
                addi.w  #$10,mt_pattpos
                cmpi.w  #$0400,mt_pattpos
                bne.s   mt_endr
mt_nex:         move.w #0,mt_pattpos
                move.b #0,mt_break
                addq.b  #1,mt_songpos
                andi.b  #$7f,mt_songpos
                move.b  mt_songpos(pc),d1
                cmp.b   mt_endpos(pc),d1
                bne.s   mt_endr
                move.b  #0,mt_songpos
mt_endr:        moveq   #0,d0
                tst.b   mt_break
                bne.s   mt_nex
                movem.l (sp)+,d0-a6
                rts

mt_setmyport:
                move.w  d2,$18(a6)
                move.w  $10(a6),d0
                move.b #0,$16(a6)
                cmp.w   d0,d2
                beq.s   mt_clrport
                bge.s   mt_rt
                move.b  #$01,$16(a6)
                bra     mt_checkcom2

mt_clrport:
                move.w #0,$18(a6)
mt_rt:          bra     mt_checkcom2

mt_myport:
                move.b  $03(a6),d0
                beq.s   mt_myslide
                move.b  d0,$17(a6)
                move.b #0,$03(a6)
mt_myslide:
                tst.w   $18(a6)
                beq.s   mt_rt
                moveq   #0,d0
                move.b  $17(a6),d0
                tst.b   $16(a6)
                bne.s   mt_mysub
                add.w   d0,$10(a6)
                move.w  $18(a6),d0
                cmp.w   $10(a6),d0
                bgt.s   mt_myok
                move.w  $18(a6),$10(a6)
                move.w #0,$18(a6)
                bra.s   mt_myok
mt_mysub:
                sub.w   d0,$10(a6)
                move.w  $18(a6),d0
                cmp.w   $10(a6),d0
                blt.s   mt_myok
                move.w  $18(a6),$10(a6)
                move.w #0,$18(a6)
mt_myok:
                move.w  $10(a6),d2
                move.b  $1f(a6),d0
                and.b   #$0f,d0
                beq.s   mt_portnorm
                moveq   #0,d0
                move.b  $12(a6),d0
                mulu    #$4a,d0
                lea     mt_periods(pc),a0
                adda.w  d0,a0
                moveq   #45,d0
mt_fineport:    cmp.w   (a0)+,d2
                dbcc    d0,mt_fineport
                move.w  -2(a0),d2
mt_portnorm:    move.w  d2,d0
                bsr     mt_putfreq
                rts

mt_vib:         move.b  $03(a6),d0
                beq.s   mt_vi
                move.b  $1a(a6),d2
                and.b   #$0f,d0
                beq.s   mt_novibampl
                and.b   #$f0,d2
                or.b    d0,d2
mt_novibampl:   move.b  3(a6),d0
                and.b   #$f0,d0
                beq.s   mt_novibspeed
                and.b   #$0f,d2
                or.b    d0,d2
mt_novibspeed:  move.b  d2,$1a(a6)
mt_vi:          move.b  $1b(a6),d0
                lea     mt_sin(pc),a4
                lsr.w   #2,d0
                and.w   #$1f,d0
                moveq   #0,d2
                move.b  $1e(a6),d2
                and.b   #3,d2
                beq.s   mt_dosinus
                lsl.b   #3,d0
                cmp.b   #1,d2
                beq.s   mt_scie
                move.b  #$ff,d2
                bra.s   mt_dovib
mt_scie:        tst.b   $1b(a6)
                bpl.s   mt_noinitscie
                move.b  #$ff,d2
                sub.b   d0,d2
                bra.s   mt_dovib
mt_noinitscie:  move.b  d0,d2
                bra.s   mt_dovib
mt_dosinus:     move.b  0(a4,d0.w),d2
mt_dovib:       move.b  $1a(a6),d0
                and.w   #$0f,d0
                mulu    d0,d2
                lsr.w   #7,d2
                move.w  $10(a6),d0
                tst.b   $1b(a6)
                bmi.s   mt_vibmin
                add.w   d2,d0
                bra.s   mt_vib2
mt_vibmin:      sub.w   d2,d0
mt_vib2:        bsr     mt_putfreq
                move.b  $1a(a6),d0
                lsr.w   #$02,d0
                and.w   #$3c,d0
                add.b   d0,$1b(a6)
                rts


mt_tremolo:     move.b  $03(a6),d0
                beq.s   mt_trem
                move.b  $1c(a6),d2
                and.b   #$0f,d0
                beq.s   mt_notreampl
                and.b   #$f0,d2
                or.b    d0,d2
mt_notreampl:   move.b  3(a6),d0
                and.b   #$f0,d0
                beq.s   mt_notrespeed
                and.b   #$0f,d2
                or.b    d0,d2
mt_notrespeed:  move.b  d2,$1c(a6)
mt_trem:        move.b  $1d(a6),d0
                lea     mt_sin(pc),a4
                lsr.w   #2,d0
                and.w   #$1f,d0
                moveq   #0,d2
                move.b  $1e(a6),d2
                lsr.b   #4,d2
                and.b   #3,d2
                beq.s   mt_dosinus2
                lsl.b   #3,d0
                cmp.b   #1,d2
                beq.s   mt_scie2
                move.b  #$ff,d2
                bra.s   mt_dotrem
mt_scie2:       tst.b   $1d(a6)
                bpl.s   mt_noinitscie2
                move.b  #$ff,d2
                sub.b   d0,d2
                bra.s   mt_dotrem
mt_noinitscie2: move.b  d0,d2
                bra.s   mt_dotrem
mt_dosinus2:    move.b  0(a4,d0.w),d2
mt_dotrem:      move.b  $1c(a6),d0
                and.w   #$0f,d0
                mulu    d0,d2
                lsr.w   #$06,d2
                moveq   #0,d0
                move.b  $13(a6),d0
                tst.b   $1d(a6)
                bmi.s   mt_tremin
                add.w   d2,d0
                bra.s   mt_trem2
mt_tremin:      sub.w   d2,d0
                bcc.s   mt_trem2
                moveq   #0,d0
mt_trem2:       cmp.w   #$40,d0
                ble.s   mt_trem3
                moveq   #$40,d0
mt_trem3:       bsr     mt_putvol
                move.w  d0,$08(a5)
                move.b  $1c(a6),d0
                lsr.w   #$02,d0
                and.w   #$3c,d0
                add.b   d0,$1d(a6)
                rts

mt_nop:         move.w  $10(a6),d0
                bsr     mt_putfreq
                rts

mt_checkcom:
                move.w  $02(a6),d1
                and.w   #$0fff,d1
                beq.s   mt_nop
                lsr.w   #8,d1
                cmp.b   #6,d1
                ble.s   mt_jumpcom1
                move.w  $10(a6),d0
                bsr     mt_putfreq
mt_jumpcom1:    lsl.w   #2,d1
                jmp     mt_tabcom1(pc,d1.w)

mt_tabcom1:     bra     mt_arpeggio
                bra     mt_portup
                bra     mt_portdown
                bra     mt_myport
                bra     mt_vib
                bra     mt_volport
                bra     mt_volvib
                bra     mt_tremolo
                bra     mt_rts2
                bra     mt_rts2
                bra     mt_volslide
                bra     mt_rts2
                bra     mt_rts2
                bra     mt_rts2
                bra     mt_ext_com
                bra     mt_rts2

mt_sampleoffset:
                moveq   #0,d0
                move.b  3(a6),d0
                beq.s   mt_no_offset
                move.b  d0,$20(a6)
mt_no_offset:   move.b  $20(a6),d0
                lsl.w   #7,d0
                cmp.w   8(a6),d0
                bge.s   mt_offsetmax
                sub.w   d0,8(a6)
                add.w   d0,d0
                add.l   d0,4(a6)
                bra     mt_setregs2
mt_offsetmax:   move.l  $a(a6),4(a6)
                move.w  $e(a6),8(a6)
                bra     mt_setregs2

mt_volvib:
                bsr     mt_vi
                bra.s   mt_volslide
mt_volport:
                bsr     mt_myslide
                bra.s   mt_volslide
mt_fine_vol_up:
                move.b  $03(a6),d0
                and.b   #$0f,d0
                bra.s   mt_dovolup
mt_volslide:
                move.b  $03(a6),d0
                lsr.b   #4,d0
                beq.s   mt_voldown
mt_dovolup:     add.b   d0,$13(a6)
                cmpi.b  #$40,$13(a6)
                bcs.s   mt_vol2
                move.b  #$40,$13(a6)
mt_vol2:        moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
                rts

mt_voldown:
                move.b  $03(a6),d0
                and.b   #$0f,d0
                sub.b   d0,$13(a6)
                bcc.s   mt_vol3
                move.b #0,$13(a6)
mt_vol3:        moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
                rts

mt_fine_portup:
                move.b  $03(a6),d0
                and.w   #$0f,d0
                bra.s   mt_doportup
mt_portup:
                moveq   #0,d0
                move.b  $03(a6),d0
mt_doportup:    sub.w   d0,$10(a6)
                move.w  $10(a6),d0
                cmp.w   #$71,d0
                bpl.s   mt_por2
                move.w  #$71,$10(a6)
mt_por2:        move.w  $10(a6),d0
                bsr     mt_putfreq
                rts

mt_fine_portdwn:
                move.b  3(a6),d0
                and.w   #$0f,d0
                bra.s   mt_doportdwn
mt_portdown:
                move.w #0,d0
                move.b  $03(a6),d0
mt_doportdwn:   add.w   d0,$10(a6)
                move.w  $10(a6),d0
                cmp.w   #$0358,d0
                bmi.s   mt_por3
                move.w  #$0358,$10(a6)
mt_por3:        move.w  $10(a6),d0
                bsr     mt_putfreq
mt_rts:         rts

mt_checkcom2:
                move.b  $02(a6),d0
                and.w   #$0f,d0
                sub.w   #$b,d0
                bcs.s   mt_rts
                lsl.w   #2,d0
                jmp     mt_tabcom2(pc,d0.w)

mt_tabcom2:     bra     mt_posjmp
                bra     mt_setvol
                bra     mt_pattbreak
                bra     mt_ext_com
                bra     mt_setspeed


mt_setfilt:
                move.b  $03(a6),d0
                and.b   #$01,d0
                rts
mt_pattbreak:
                not.b   mt_break
                rts
mt_posjmp:
                move.b  $03(a6),d0
                subq.b  #$01,d0
                move.b  d0,mt_songpos
                not.b   mt_break
                rts
mt_setvol:
                moveq   #0,d0
                move.b  3(a6),d0
                move.b  d0,$13(a6)
                bsr     mt_putvol
                rts
mt_setspeed:
                moveq   #0,d0
                move.b  $03(a6),d0
                cmp.w   #$20,d0
                bge.s   mt_rts2
                move.b  d0,mt_speed
mt_rts2:        rts

mt_ext_com:
                moveq   #0,d0
                move.b  3(a6),d0
                lsr.b   #4,d0
                tst.b   mt_counter
                bne.s   mt_res_com
                lsl.w   #2,d0
                jmp     mt_tabext1(pc,d0.w)
mt_res_com:     sub.w   #9,d0
                bcs.s   mt_rts2
                lsl.w   #2,d0
                jmp     mt_tabext2(pc,d0.w)

mt_tabext1:     bra.w   mt_setfilt
                bra     mt_fine_portup
                bra     mt_fine_portdwn
                bra     mt_setportctrl
                bra     mt_setvibform
                bra     mt_setfinetune
                bra     mt_pattern_loop
                bra     mt_settremform
                bra     mt_rts
                bra     mt_roll
                bra     mt_fine_vol_up
                bra     mt_voldown
                bra     mt_notecut
                bra     mt_notedelay
                bra     mt_pattern_delay
                bra     mt_rts
mt_tabext2:     bra     mt_roll
                bra     mt_rts
                bra     mt_rts
                bra     mt_notecut
                bra     mt_notedelay
                bra     mt_rts
                bra     mt_rts

mt_setportctrl:
                move.b  3(a6),d0
                and.b   #$0f,d0
                and.b   #$f0,$1f(a6)
                or.b    d0,$1f(a6)
                rts
mt_setvibform:
                move.b  3(a6),d0
                and.b   #$0f,d0
                and.b   #$f0,$1e(a6)
                or.b    d0,$1e(a6)
                rts
mt_setfinetune:
                move.b  3(a6),d0
                and.b   #$0f,d0
                move.b  d0,$12(a6)
                rts
mt_pattern_loop:
                move.b  3(a6),d0
                and.b   #$0f,d0
                beq.s   mt_setloopstart
                tst.b   $22(a6)
                beq.s   mt_setnumloop
                subq.b  #1,$22(a6)
                beq     mt_rts2
mt_doloop:      moveq   #0,d0
                move.b  $21(a6),d0
                ext.w   d0
                asl.w   #4,d0
                move.w  d0,mt_pattpos
                rts
mt_setnumloop:  move.b  d0,$22(a6)
                bra.s   mt_doloop
mt_setloopstart:move.w  mt_pattpos(pc),d0
                lsr.w   #4,d0
                subq.b  #1,d0
                move.b  d0,$21(a6)
                rts

mt_settremform:
                move.b  3(a6),d0
                lsl.b   #4,d0
                andi.b  #$0f,$1e(a6)
                or.b    d0,$1e(a6)
                rts
mt_notecut:
                move.b  $03(a6),d0
                and.b   #$0f,d0
                cmp.b   mt_counter,d0
                bne     mt_rts2
                move.b  #0,$13(a6)
                moveq   #0,d0
                bsr     mt_putvol
                rts
mt_notedelay:
                tst.b   mt_counter
                bne.s   mt_waitdelay
                move.w  $14(a6),d0
                not.w   d0
                and.w   d0,mt_dmacon
mt_waitdelay:   move.b  $03(a6),d0
                and.b   #$0f,d0
                cmp.b   mt_counter,d0
                bne     mt_rts2
                moveq   #0,d0
                move.w  $14(a6),d0
                or.w    d0,mt_dmacon
                not.l   d0
                and.l   d0,ldff096
                move.l  4(a6),$00(a5)
                moveq   #0,d0
                move.w  8(a6),d0
                add.w   d0,d0
                move.l  d0,4(a5)
                move.w  $10(a6),d0
                bsr     mt_putfreq
                moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
                rts

mt_pattern_delay:
                tst.b   mt_pattdelay
                bne     mt_rts2
                move.b  $03(a6),d0
                and.b   #$0f,d0
                move.b  d0,mt_pattdelay
                rts
mt_roll:
                moveq   #0,d0
                move.b  3(a6),d0
                and.b   #$0f,d0
                beq.s   mt_roll_ret
                moveq   #0,d1
                move.b  mt_counter,d1
                divu    d0,d1
                swap    d1
                tst.w   d1
                bne.s   mt_roll_ret
                moveq   #0,d0
                move.w  $14(a6),d0
                or.w    d0,mt_dmacon
                not.l   d0
                and.l  d0,ldff096
                move.l  4(a6),(a5)
                moveq   #0,d0
                move.w  8(a6),d0
                add.w   d0,d0
                move.l  d0,4(a5)
                move.w  $10(a6),d0
                bsr     mt_putfreq
                moveq   #0,d0
                move.b  $13(a6),d0
                bsr     mt_putvol
mt_roll_ret:    rts

mt_putvol:
                movem.l d0/a0,-(sp)
                lea     mt_voldivtab(pc),a0
                lsl.w   #2,d0
                move.l  (a0,d0.w),d0
                move.l  d0,12(a5)
                movem.l (sp)+,d0/a0
                rts
mt_putfreq:
                move.l  d1,-(sp)
;                move.l  #$702424,d1             ;SCLK=12 --> 31.92Khz
                move.l  #$671800,d1             ;SCLK=11 --> 34.56Khz
                tst.w   d0
                beq.s   mt_div0
                divu    d0,d1
                swap    d1
                clr.w   d1
                move.l  d1,8(a5)
mt_div0:        move.l  (sp)+,d1
                rts



mt_sin:         dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
                dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:     dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
                dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$fe,$f0,$e2,$d6,$ca,$be,$b4
                dc.w $aa,$a0,$97,$8f,$87,$7f,$78,$71,0
                dc.w $0352,$0322,$02f5,$02cb,$02a2,$027d,$0259,$0237,$0217,$01f9,$01dd
                dc.w $01c2,$01a9,$0191,$017b,$0165,$0151,$013e,$012c,$011c,$010c,$fd,$ef
                dc.w $e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86,$7e,$77,$71,0
                dc.w $034c,$031c,$02f0,$02c5,$029e,$0278,$0255,$0233,$0214,$01f6,$01da,$01bf,$01a6,$018e
                dc.w $0178,$0163,$014f,$013c,$012a,$011a,$010a,$fb,$ed,$e0,$d3,$c7,$bc,$b1,$a7,$9e
                dc.w $95,$8d,$85,$7d,$76,$70,0
                dc.w $0346,$0317,$02ea,$02c0,$0299,$0274,$0250,$022f,$0210,$01f2,$01d6,$01bc,$01a3
                dc.w $018b,$0175,$0160,$014c,$013a,$0128,$0118,$0108,$f9,$eb,$de,$d1,$c6,$bb,$b0,$a6
                dc.w $9d,$94,$8c,$84,$7d,$76,$6f,0
                dc.w $0340,$0311,$02e5,$02bb,$0294,$026f,$024c,$022b,$020c,$01ef,$01d3,$01b9
                dc.w $01a0,$0188,$0172,$015e,$014a,$0138,$0126,$0116,$0106,$f7,$e9,$dc,$d0,$c4,$b9,$af
                dc.w $a5,$9c,$93,$8b,$83,$7c,$75,$6e,0
                dc.w $033a,$030b,$02e0,$02b6,$028f,$026b,$0248,$0227,$0208,$01eb,$01cf,$01b5,$019d,$0186
                dc.w $0170,$015b,$0148,$0135,$0124,$0114,$0104,$f5,$e8,$db,$ce,$c3,$b8,$ae,$a4,$9b,$92,$8a
                dc.w $82,$7b,$74,$6d,0
                dc.w $0334,$0306
                dc.w $02da,$02b1,$028b,$0266
                dc.w $0244,$0223,$0204,$01e7
                dc.w $01cc,$01b2,$019a,$0183
                dc.w $016d,$0159,$0145,$0133
                dc.w $0122,$0112,$0102,$f4
                dc.w $e6,$d9,$cd,$c1
                dc.w $b7,$ac,$a3,$9a
                dc.w $91,$89,$81,$7a
                dc.w $73,$6d,0,$032e
                dc.w $0300,$02d5,$02ac,$0286
                dc.w $0262,$023f,$021f,$0201
                dc.w $01e4,$01c9,$01af,$0197
                dc.w $0180,$016b,$0156,$0143
                dc.w $0131,$0120,$0110,$0100
                dc.w $f2,$e4,$d8,$cc
                dc.w $c0,$b5,$ab,$a1
                dc.w $98,$90,$88,$80
                dc.w $79,$72,$6c,0
                dc.w $038b,$0358,$0328,$02fa
                dc.w $02d0,$02a6,$0280,$025c
                dc.w $023a,$021a,$01fc,$01e0
                dc.w $01c5,$01ac,$0194,$017d
                dc.w $0168,$0153,$0140,$012e
                dc.w $011d,$010d,$fe,$f0
                dc.w $e2,$d6,$ca,$be
                dc.w $b4,$aa,$a0,$97
                dc.w $8f,$87,$7f,$78
                dc.w 0,$0384,$0352,$0322
                dc.w $02f5,$02cb,$02a3,$027c
                dc.w $0259,$0237,$0217,$01f9
                dc.w $01dd,$01c2,$01a9,$0191
                dc.w $017b,$0165,$0151,$013e
                dc.w $012c,$011c,$010c,$fd
                dc.w $ee,$e1,$d4,$c8
                dc.w $bd,$b3,$a9,$9f
                dc.w $96,$8e,$86,$7e
                dc.w $77,0,$037e,$034c
                dc.w $031c,$02f0,$02c5,$029e
                dc.w $0278,$0255,$0233,$0214
                dc.w $01f6,$01da,$01bf,$01a6
                dc.w $018e,$0178,$0163,$014f
                dc.w $013c,$012a,$011a,$010a
                dc.w $fb,$ed,$df,$d3
                dc.w $c7,$bc,$b1,$a7
                dc.w $9e,$95,$8d,$85
                dc.w $7d,$76,0,$0377
                dc.w $0346,$0317,$02ea,$02c0
                dc.w $0299,$0274,$0250,$022f
                dc.w $0210,$01f2,$01d6,$01bc
                dc.w $01a3,$018b,$0175,$0160
                dc.w $014c,$013a,$0128,$0118
                dc.w $0108,$f9,$eb,$de
                dc.w $d1,$c6,$bb,$b0
                dc.w $a6,$9d,$94,$8c
                dc.w $84,$7d,$76,0
                dc.w $0371,$0340,$0311,$02e5
                dc.w $02bb,$0294,$026f,$024c
                dc.w $022b,$020c,$01ee,$01d3
                dc.w $01b9,$01a0,$0188,$0172
                dc.w $015e,$014a,$0138,$0126
                dc.w $0116,$0106,$f7,$e9
                dc.w $dc,$d0,$c4,$b9
                dc.w $af,$a5,$9c,$93
                dc.w $8b,$83,$7b,$75
                dc.w 0,$036b,$033a,$030b
                dc.w $02e0,$02b6,$028f,$026b
                dc.w $0248,$0227,$0208,$01eb
                dc.w $01cf,$01b5,$019d,$0186
                dc.w $0170,$015b,$0148,$0135
                dc.w $0124,$0114,$0104,$f5
                dc.w $e8,$db,$ce,$c3
                dc.w $b8,$ae,$a4,$9b
                dc.w $92,$8a,$82,$7b
                dc.w $74,0,$0364,$0334
                dc.w $0306,$02da,$02b1,$028b
                dc.w $0266,$0244,$0223,$0204
                dc.w $01e7,$01cc,$01b2,$019a
                dc.w $0183,$016d,$0159,$0145
                dc.w $0133,$0122,$0112,$0102
                dc.w $f4,$e6,$d9,$cd
                dc.w $c1,$b7,$ac,$a3
                dc.w $9a,$91,$89,$81
                dc.w $7a,$73,0,$035e
                dc.w $032e,$0300,$02d5,$02ac
                dc.w $0286,$0262,$023f,$021f
                dc.w $0201,$01e4,$01c9,$01af
                dc.w $0197,$0180,$016b,$0156
                dc.w $0143,$0131,$0120,$0110
                dc.w $0100,$f2,$e4,$d8
                dc.w $cb,$c0,$b5,$ab
                dc.w $a1,$98,$90,$88
                dc.w $80,$79,$72,0
mt_transtab:    dcb.b $35a,0
mt_voldivtab:   dc.l    $0000
                dc.l    $0000,$1546,$21af,$2a8c,$31a3,$36f5,$3bec,$3fd2
                dc.l    $43b9,$46e9,$49c0,$4c96,$4f11,$5132,$5352,$5573
                dc.l    $5739,$58ff,$5ac4,$5c30,$5d9b,$5f06,$6071,$61dc
                dc.l    $62ec,$6457,$6567,$6678,$6788,$6898,$69a9,$6ab9
                dc.l    $6b6e,$6c7f,$6d8f,$6e45,$6efa,$700a,$70c0,$7176
                dc.l    $722b,$72e1,$7396,$744c,$7501,$75b7,$766c,$7722
                dc.l    $77d7,$788d,$78e8,$799d,$7a53,$7aad,$7b63,$7bbe
                dc.l    $7c73,$7cce,$7d84,$7dde,$7e94,$7eef,$7fa4,$7fff
mt_silent:      dc.l 0
mt_sync:        dc.w 0
mt_DSP_PC:      dc.l 0
mt_speed:       dc.b $06
mt_songpos:     dc.b $00
mt_counter:     dc.b $00
mt_break:       dc.b $00
mt_pattdelay:   dc.b $00
mt_endpos:      dc.b $00
                even
mt_oldirq:      dc.l 0
mt_pattpos:     dc.w $00
mt_dmacon:      dc.w $00
mt_samplestarts:dcb.l 31,0
mt_voice1:      dcb.w 10,0
                dc.w $01
                dcb.w 9,0
mt_voice2:      dcb.w 10,0
                dc.w $02
                dcb.w 9,0
mt_voice3:      dcb.w 10,0
                dc.w $04
                dcb.w 9,0
mt_voice4:      dcb.w 10,0
                dc.w $08
                dcb.w 9,0
mt_dsp_code:    dc.l    D_RAM
                dc.l    mt_fincode-mt_debcode
mt_debcode:     include "j:\\trax\\8v_final.das"
mt_fincode:

                .DATA

mt_data:        incbin  "j:\\trax\\mod.rac"
