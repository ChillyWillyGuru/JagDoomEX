        .include        "j:\\include\\video.inc"
        .include        "j:\\include\\jaguar.inc"
        .include        "j:\\include\\objlist.inc"
        .include        "j:\\include\\joypad.inc"
        .include        "j:\\include\\blit.inc"

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Constantes du jeu.³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
level2          equ     4*$40
total_ob        equ     1

        .68000
        .TEXT

        bsr     INIT_GAME

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Main Boucle.                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
loop:
        jsr     wait_vbl

        move.l  #total_ob,d6
        bsr     copy_ol                 ;copy la liste objet.
        move.l  #total_ob,d6
        jsr     build                   ;rebuild the object list pour le processeur objet.
        bra     loop

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  THE INITIALISATION                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INIT_GAME:
        move.l  #total_ob,nb_obj        ;number of Object Headers
        move.l  #$00070007,G_END        ;don't need to swap for GPU
        move.w  #$35cc,MEMCON2          ; Do the old endian thing
        move.w  #$8000,CHRO_CLK
        move.l  #8,$00f02114            ; stoppe le GPU
        move.w  #$100,JOYSTICK          ;turns off audio mute

;
; Copie le code GPU
;
        move.l  #GPU_END,d0             ; d0 = adresse fin code
        sub.l   #gpu_star,d0            ; - adresse debut
        lsr     #2,d0                   ; / 4
        lea     $f03000,a1              ; a1 = adresse RAM GPU
        lea     gpu_star,a0             ; a0 = adresse code gpu
cop_gpu:
        move.l  (a0)+,(a1)+             ; copie le code
        dbf     d0,cop_gpu



;
; Init Video / List objet.
;
        lea     ppal,a0                 ;adresse ou se trouve la palette.
        jsr     set_                    ;init la palette de la jaguar.
        jsr     VideoIni                ;init les frequence pour le 384*240
        jsr     IntInit                 ;init la vbl.
        move.l  #total_ob,d6            ;nbre d'objet a traiter dans la liste objet.
        jsr     build                   ;cree la liste objet.
        jsr     copy_ol                 ;copy la liste objet pour le processeur objet.
        move.l  #olist,d0               ;get address of start of object list
        swap    d0
        move.l  d0,OLP                  ;Object List Pointer...
        move.w  #%010111000111,VMODE    ;RBV en 4/8/16 bits...

        rts

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DIALOGUE AVEC LE GPU                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
build:  move.l  d6,nb_obj
        move.l  #0,sema
        move.l  #gen_list,$f02110
        move.l  #$11,$f02114
wait1:  move.l  sema,d0
        beq.s   wait1
        rts


copy_ol:
        move.l  #0,sema
        move.l  #cop_list,$f02110
        move.l  #$11,$f02114
wait2:  move.l  sema,d0
        beq.s   wait2
        rts

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³INIT LA VIDEO DE LA BETE              ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VideoIni:
        move.w  #n_hp,HP
        move.w  #n_hbb,HBB
        move.w  #n_hbe,HBE
        move.w  #n_hs,HS
        move.w  #n_hvs,HVS
        move.w  #n_heq,HEQ
        move.w  #n_hde,HDE
        move.w  #n_hdb1,HDB1
        move.w  #n_hdb2,HDB2

        move.w  #n_vp,VP
        move.w  #n_vee,VEE
        move.w  #n_vbe,VBE
        move.w  #n_vdb,VDB
        move.w  #n_vde,VDE
        move.w  #n_vbb,VBB
        move.w  #n_veb,VEB
        move.w  #n_vs,VS
        move.w  #$0000,BG
        move.l  #$00000000,BORD1
        rts


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³SET LA PALETTE                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
set_:   lea     CLUT,a1                 ;get address of color lookup table
        move.w  #255,d0                 ;number of colors to set
f10f:   move.w  (a0)+,(a1)+             ;put color value into color lookup table
        dbra    d0,f10f                 ;continue through palette table
        rts

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init la VBL                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wait_vbl:
        move.b  framecnt,d0
g10g:   cmp.b   intcount,d0
        bgt.b   g10g
        clr.b   intcount
        rts
IntInit:
        move.l  #Frame,level2
        move.w  #n_vde+1,VI
        move.w  #1,INT1
        move.w  sr,d0
        and.w   #$f8ff,d0
        move.w  d0,sr
        rts
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³The VBL ...                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frame:  movem.l d0-d6/a0-a6,-(sp)
        add.b   #1,intcount
        move.w  #$101,INT1
        move.w  #0,INT2
        movem.l (sp)+,d0-d6/a0-a6
        rte


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                      ³
;³SECTION DATA ET BSS DE LA ZONE 68000. ³
;³                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        .BSS                                    ;   +$100000
        .phrase
olist:          .ds.l   ((20*8)+2)

        .DATA                                   ;   +$10000
list_obj:       .dc.l   0                      ; O_XPOS
                .dc.l   10                      ; O_YPOS
                .dc.l   176                      ; O_HEIGHT
                .dc.l   192/8                    ; O_WIDTH
                .dc.l   pic                     ; O_DATA

                .phrase
vbl:            .dc.l   1

                .phrase
pic:            incbin  "a:\\jupiter.rbv"

                .phrase
ppal:           .incbin "pal.pal"

                .phrase
olist_ram:      .dcb.l  (60*8)+2,0              ; List objet reserv‚ au processeur objet...

                .phrase
sema:           .dc.l   0
nb_obj:         .dc.l   10
intcount:       .dc.b   0
framecnt:       .dc.b   1                       ;60 frames per second

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                      º
;º      SECTION CODE GPU                º
;º                                      º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
        .phrase
        .GPU
gpu_star:
        .org    $f03000
gen_list:
        moveq   #0,r10                  ;r10 = 0
        store   r10,(r0)                ;deplacement du scroll en x revenu a 0.
        movei   #list_obj,r14           ;r14 = adresse liste objet "normale"
        movei   #olist,r7               ;r25 = adresse de la liste qui va etre copi‚e en vbl
        movei   #olist_ram,R15          ;r15 = adresse de la liste qui va ˆtre g‚n‚r‚e
        shrq    #3,r7                   ;r7 / 8 pour le processeur objet
        movei   #nb_obj,r0              ;r0  = adresse nb objets
        load    (r0),r6                 ;r6  = nb objets

;ÚÄÄÄÄÄÄÄÄ¿
;³PHRASE 1³
;ÀÄÄÄÄÄÄÄÄÙ
bcl1:   movei   #SCRNTOP,r2             ; r2  = haut de l'‚cran
        load    (r14+1),r11             ; r11 = O_YPOS
        add     r2,r11
        sub     r11,r2
        jr      pl,sp0                  ; si  > 0 -> suite
        nop
        move    r10,r2                  ; sinon lignes hors ecran = 0
sp0:    cmpq    #0,r11
        jr      pl,hclip
        nop
        move    r10,r11
hclip:  shrq    #1,r2                   ; en demi-lignes
        movei   #$7ff,r25               ; pour ander Y_POS
        and     r25,r11                 ; formatte sur 11 bits
        shlq    #3,r11                  ; bits 3 … 13

        load    (r14+2),r12             ; r12 = O_HEIGHT
        sub     r2,r12                  ; - debut de l'ecran
        jr      hi,sp1                  ; si > 0 on passe a la suite
        nop
        move    r10,r12                 ; sinon O_HEIGHT = 0
sp1:    shlq    #14,r12                 ; bits 14 … 23

        addq    #2,r7                   ; objet suivant 2 phrases plus loin
        move    r7,r13                  ; r13 = O_LINK
        movei   #$ff,r25                ; pour ander O_LINK
        and     r25,r13                 ; prends les 8 bits faibles
        shlq    #24,r13                 ; bits 24 … 31

        move    r7,r16                  ; r16 = O_LINK
        shrq    #8,r16                  ; d‚cale de 8 bits pour virer les 8 faibles

        load    (r14+4),r17             ; r17 = O_DATA
        cmpq    #0,r2                   ; y-a-t-il des lignes hors ‚cran ?
        jr      eq,sp3                  ; non -> suite
        load    (r14+3),r18             ; r18 = O_DWITDH
        shlq    #3,r18                  ; phrase * 8 octets par phrase
        mult    r2,r18                  ; lignes hors de l'ecran * taille d'une ligne
        add     r18,r17                 ; ajoute … l'adresse de base
sp3:    shlq    #8,r17                  ; divise l'adresse par 8 et place dans bits 11 … fin

        or      r11,r10                 ; copie O_YPOS
        or      r12,r10                 ; copie O_HEIGHT
        or      r13,r10                 ; copie O_LINK (8 bits low)
        or      r17,r16                 ; copie O_DATA
        store   r16,(R15)               ; sauve mot haut de la phrase 1
        store   r10,(R15+1)             ; sauve mot bas de la phrase 1

;ÚÄÄÄÄÄÄÄÄ¿
;³PHRASE 2³
;ÀÄÄÄÄÄÄÄÄÙ
        load    (r14),r11               ; r11 = O_XPOS
        movei   #%111111111111,r25
        and     r25,r11
        movei   #3<<12,r12              ; r12 = O_DEPTH  (bits 12 a 14)
        movei   #1<<15,r13              ; r13 = O_PITCH  (bits 15 a 17)

        load    (r14+3),r16             ; r16 = O_DWIDTH
        move    r16,r17                 ; r17 = r16 = O_IWIDTH
        move    r17,r18                 ; r18 = r17
        shlq    #18,r16                 ; bits 18 … 27

        moveq   #$f,r25                 ; r25 = $f (pour ander IWIDTH)
        and     r25,r17                 ; 4 bits faibles
        shlq    #28,r17                 ; bits 28 … 31 (partie low IWIDTH)

        shrq    #4,r18                  ; r16 = partie high (6 bits) de IWIDTH

        movei   #1<<15,r19              ; r19 = O_TRANS bit transparent
        movei   #1<<17,r21              ; r21 = O_FIRSTPIX

        or      r12,r11                 ; copie O_DEPTH
        or      r13,r11                 ; copie O_PITCH
        or      r16,r11                 ; copie O_DWIDTH
        or      r17,r11                 ; copie O_IWIDTH (partie low)
        or      r19,r18                 ; copie O_TRANS
        or      r21,r18                 ; copie O_FIRSTPIX
        store   r18,(R15+2)             ; sauve mot haut de la phrase 2
        store   r11,(R15+3)             ; sauve mot bas de la phrase 2

;ÚÄÄÄÄÄÄÄ¿
;³SUIVANT³
;ÀÄÄÄÄÄÄÄÙ
        addq    #20,R14                 ; objet suivant a generer

        addq    #16,R15                 ; 2 phrases suivantes
        movei   #bcl1,r25
        subq    #1,r6                   ; nb objet -1
        jump    ne,(r25)                ; boucle

        moveq   #0,r10                  ; r10=0
        store   r10,(R15)
        moveq   #4,r10
        store   r10,(R15+1)             ; objet STOP

        movei   #sema,r0                ; r0 = adresse sema
        moveq   #1,r1                   ; sema = 1
        store   r1,(r0)                 ; sauve sema

        movei   #8,R30                  ; stoppe le GPU
        movei   #$f02114,R31
        store   R30,(R31)
        nop
        nop

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;ºRoutine de copie de la liste º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
cop_list:
        movei   #olist_ram,r0           ; r0 = adresse liste cr‚‚e
        movei   #olist,r1               ; r1 = adresse liste proc. objet
cop:    load    (r0),r2                 ; r2 = contenu liste cr‚‚e
        store   r2,(r1)                 ; copie dans la liste proc
        addq    #4,r0                   ; long suivant
        addq    #4,r1                   ; long suivant
        cmpq    #4,r2                   ; objet stop ?
        jr      ne,cop                  ; non -> boucle
        nop
        nop
        movei   #sema,r0                ; r0 = adresse sema
        moveq   #1,r1                   ; sema = 1
        store   r1,(r0)                 ; sauve sema
        moveq   #8,R30                  ; stoppe le GPU
        movei   #$f02114,R31
        store   R30,(R31)
        nop
        nop

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                      º
;ºSECTION BSS ET DATA DANS LA MEMOIRE GPU !             º
;º                                                      º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
        .phrase
Buf_GcP1:       .dc.l   0
Buf_DrP1:       .dc.l   12

                .phrase
                .68000
GPU_END:        .END


ÿÿ
