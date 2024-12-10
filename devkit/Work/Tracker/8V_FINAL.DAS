;       ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;       º                                                               º
;       º               Routine Playback DSP Pour Jaguar                º
;       º                                                               º
;       º        8 Voies compatible Chip PAULA (Commodore Amiga)        º
;       º                                                               º
;       º                 (c) 1994 Virtual Xperience                    º
;       º                                                               º
;       º                                                               º
;       ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

                .DSP
                .ORG    D_RAM

                movei   #DSP_START,r0           ; (interrupt 0  - DSP Control)
                jump    t,(r0)
                nop
                nop
                nop
                nop
STACKPOS:       movei   #i2s_isr,r29            ; (interrupt 1 - I2S)
                jump    t,(r29)
                nop
                nop
SEMAPHORE:      nop
                nop
HUMPFA:         nop
                nop


DSP_START:      movei   #L_DAC,r24               ; Get the DAC location
                movei   #R_DAC,r25
                movei   #ldff096,r17
                movei   #STACKPOS,r31           ; Set up a stack
                movei   #D_FLAGS,r1             ; load dsp flags to go to bank 1
                load    (r1),r0
                bset    #5,r0                   ; enable I2S interrupt
                store   r0,(r1)                 ; save dsp flags
                moveq   #0,r0
                movei   #SEMAPHORE,r1
                store   r0,(r1)                 ; Clear the SEMAPHORE
                xor     r22,r22
                xor     r23,r23
                movei   #Play_track,r20
                movei   #-1,r21
tlop:           load    (r1),r2                 ; Get SEMAPHORE
lop:            btst    #1,r2
                jr      eq,lop
                load    (r1),r2                 ; Get SEMAPHORE

                movei   #HUMPFA,r3
                load    (r3),r4
                addq    #1,r4
                store   r4,(r3)


                sharq   #17,r22
                sharq   #17,r23
                store   r22,(r24)               ; Play the previous calculated sample
                store   r23,(r25)               ; In Stereo off course !!!!
                load    (r17),r18


                movei   #ldff0a0,r14
                movei   #dsp_regs,r15
                btst    #0,r18
                jr      eq,no_dma1
                nop
                move    pc,r19
                jump    t,(r20)
                addq    #6,r19
                move     r10,r22

no_dma1:        addq    #24,r14
                btst    #1,r18
                jr      eq,no_dma2
                addq    #12,r15
                move    pc,r19
                jump    t,(r20)
                addq    #6,r19
                move     r10,r23

no_dma2:        addq    #24,r14
                btst    #2,r18
                jr      eq,no_dma3
                addq    #12,r15
                move    pc,r19
                jump    t,(r20)
                addq    #6,r19
                add     r10,r23

no_dma3:        addq    #24,r14
                btst    #3,r18
                jr      eq,no_dma4
                addq    #12,r15
                move    pc,r19
                jump    t,(r20)
                addq    #6,r19
                add     r10,r22

no_dma4:        addq    #24,r14
                addq    #12,r15
                move    pc,r19
;                jump    t,(r20)
;                addq    #6,r19
;                add     r10,r22

                addq    #24,r14
                addq    #12,r15
                move    pc,r19
;                jump    t,(r20)
;                addq    #6,r19
;                add     r10,r23

                addq    #24,r14
                addq    #12,r15
                move    pc,r19
;                jump    t,(r20)
;                addq    #6,r19
;                add     r10,r23

                addq    #24,r14
                addq    #12,r15
                move    pc,r19
;                jump    t,(r20)
;                addq    #6,r19
;                add     r10,r22

                movei   #tlop,r14
                jump    t,(r14)
                store   r0,(r1)                 ; clear the SEMAPHORE



Play_track:
                xor     r8,r8
                load    (r15),r3                ;r3=Current Ptr
                load    (r14+3),r7              ;r7=volume
                xor     r10,r10
                load    (r15+1),r4
;                loadb   (r3),r10
                load    (r15+2),r5
;                shlq    #8,r10
                load    (r14+2),r6
                add     r6,r6
                addc    r8,r8
                add     r6,r6
                addc    r10,r8
                loadb   (r3),r10
                shlq    #8,r10
                add     r8,r3
                sub     r8,r4
;                jr      ge,spl_lop
                add     r6,r5
                jr      cc,no_incr
                imult   r7,r10
                subq    #1,r4
                jr      ne,no_incr
                addq    #1,r3
spl_lop:        load    (r14+5),r4
                load    (r14+4),r3              ;Rept Ptr
no_incr:        load    (r14+1),r6
                cmp     r21,r6
                jr      eq,no_new
                nop
                load    (r14),r3
                move    r6,r4
                xor     r5,r5
                store   r21,(r14+1)
no_new:         store   r3,(r15)
                store   r4,(r15+1)
                jump    t,(r19)
                store   r5,(r15+2)

;       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;       ³                                                               ³
;       ³                  Interruption I2S (25Khz)                     ³
;       ³                                                               ³
;       ³       Registres utilises: r26,r27,r28,r29,r30,r31             ³
;       ³                                                               ³
;       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

i2s_isr:
                movei   #D_FLAGS,r30            ; get flags ptr
                load    (r30),r27
                bclr    #3,r27                  ; clear IMASK
                load    (r31),r28               ; get last instruction address
                bset    #10,r27                 ; clear I2S interrupt
                addq    #2,r28                  ; point at next to be executed
                addq    #4,r31                  ; update the stack pointer
                moveq   #1,r26
                neg     r26
                store   r26,(r1)
                jump    t,(r28)                 ; and return
                store   r27,(r30)               ; restore flags

                nop

dsp_regs:       dcb.l   24,0

;       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;       ³                             The END                           ³
;       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                .68000
