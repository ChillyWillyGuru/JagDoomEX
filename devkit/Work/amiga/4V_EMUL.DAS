;       -------------------------------------------------------------
;       --                                                         --
;       --            Routine Playback DSP Pour Jaguar             --
;       --                                                         --
;       --     8 Voies compatible Chip PAULA (Commodore Amiga)     --
;       --                                                         --
;       --              (c) 1994 Virtual Xperience                 --
;       --                                                         --
;       --                                                         --
;       -------------------------------------------------------------
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


DSP_START:      movei   #LTXD,r24               ; Get the DAC location
                movei   #RTXD,r25
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
                movei   #$ffff0000,r21
tlop:           load    (r1),r2                 ; Get SEMAPHORE
lop:            btst    #1,r2
                jr      eq,lop
                load    (r1),r2                 ; Get SEMAPHORE
                store   r22,(r24)               ;Play the previous calculated sample
                store   r23,(r25)               ;In Stereo off course !!!!
                xor     r22,r22
                xor     r23,r23


                movei   #ldff0a0,r14
                movei   #dsp_reg1,r15
                load    (r15),r3                ;r3=Current Ptr

                load    (r15+1),r4
                load    (r15+2),r5
                load    (r14+2),r6
                add     r6,r5
                jr      cc,no_incr1             ;$4
                nop
                subq    #1,r4
                jr      ne,no_incr1
                addq    #1,r3
                load    (r14+4),r3              ;Rept Ptr
                load    (r14+5),r4
no_incr1:       load    (r14+1),r6
                movei   #-1,r7
                cmp     r7,r6
                jr      eq,no_new1
                nop
                load    (r14),r3
                move    r6,r4
                store   r7,(r14+1)
no_new1:        store   r3,(r15)
                store   r4,(r15+1)
                store   r5,(r15+2)
                load    (r14+3),r4              ;r4=volume
                xor     r5,r5
                loadb   (r3),r5
                shlq    #8,r5
                imult   r4,r5
                sharq   #16,r5
                add     r5,r22                  ;r22=left data

                movei   #ldff0d0,r14
                movei   #dsp_reg4,r15
                load    (r15),r3                ;r3=Current Ptr

                load    (r15+1),r4
                load    (r15+2),r5
                load    (r14+2),r6
                add     r6,r5
                jr      cc,no_incr2             ;$4
                nop
                subq    #1,r4
                jr      ne,no_incr2
                addq    #1,r3
                load    (r14+4),r3              ;Rept Ptr
                load    (r14+5),r4
no_incr2:       load    (r14+1),r6
                movei   #-1,r7
                cmp     r7,r6
                jr      eq,no_new2
                nop
                load    (r14),r3
                move    r6,r4
                store   r7,(r14+1)
no_new2:        store   r3,(r15)
                store   r4,(r15+1)
                store   r5,(r15+2)
                load    (r14+3),r4              ;r4=volume
                xor     r5,r5
                loadb   (r3),r5
                shlq    #8,r5
                imult   r4,r5
                sharq   #16,r5
                add     r5,r22                  ;r22=left data

                movei   #ldff0b0,r14
                movei   #dsp_reg2,r15
                load    (r15),r3                ;r3=Current Ptr

                load    (r15+1),r4
                load    (r15+2),r5
                load    (r14+2),r6
                add     r6,r5
                jr      cc,no_incr3             ;$4
                nop
                subq    #1,r4
                jr      ne,no_incr3
                addq    #1,r3
                load    (r14+4),r3              ;Rept Ptr
                load    (r14+5),r4
no_incr3:       load    (r14+1),r6
                movei   #-1,r7
                cmp     r7,r6
                jr      eq,no_new3
                nop
                load    (r14),r3
                move    r6,r4
                store   r7,(r14+1)
no_new3:        store   r3,(r15)
                store   r4,(r15+1)
                store   r5,(r15+2)
                load    (r14+3),r4              ;r4=volume
                xor     r5,r5
                loadb   (r3),r5
                shlq    #8,r5
                imult   r4,r5
                sharq   #16,r5
                add     r5,r23                  ;r22=left data

                movei   #ldff0c0,r14
                movei   #dsp_reg3,r15
                load    (r15),r3                ;r3=Current Ptr

                load    (r15+1),r4
                load    (r15+2),r5
                load    (r14+2),r6
                add     r6,r5
                jr      cc,no_incr4             ;$4
                nop
                subq    #1,r4
                jr      ne,no_incr4
                addq    #1,r3
                load    (r14+4),r3              ;Rept Ptr
                load    (r14+5),r4
no_incr4:       load    (r14+1),r6
                movei   #-1,r7
                cmp     r7,r6
                jr      eq,no_new4
                nop
                load    (r14),r3
                move    r6,r4
                store   r7,(r14+1)
no_new4:        store   r3,(r15)
                store   r4,(r15+1)
                store   r5,(r15+2)
                load    (r14+3),r4              ;r4=volume
                xor     r5,r5
                loadb   (r3),r5
                shlq    #8,r5
                imult   r4,r5
                sharq   #16,r5
                add     r5,r23                  ;r22=left data

                movei   #tlop,r14
                jump    t,(r14)
                store   r0,(r1)                 ; clear the SEMAPHORE

;       -----------------------------------------------------------------
;       --                                                             --
;       --                 Interruption I2S (25Khz)                    --
;       --                                                             --
;       --      Registres utilises: r26,r27,r28,r29,r30,r31            --
;       --                                                             --
;       -----------------------------------------------------------------

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
dsp_reg1:       dc.l    0
                dc.l    0
                dc.l    0
dsp_reg2:       dc.l    0
                dc.l    0
                dc.l    0
dsp_reg3:       dc.l    0
                dc.l    0
                dc.l    0
dsp_reg4:       dc.l    0
                dc.l    0
                dc.l    0


;       -----------------------------------------------------------------
;       --                            The END                          --
;       -----------------------------------------------------------------
                .68000
