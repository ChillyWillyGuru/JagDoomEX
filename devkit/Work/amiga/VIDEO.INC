vclk		equ	376
horiz_per	equ	317778
sync_per	equ	46050
eq_per		equ	23800
front_porch	equ	17450
line_blank	equ	109500
disp_width	equ	1155		; (384 + 1)*3
disp_height	equ	240		; nb lignes

; Horizontal computations (haha)

n_hp		equ	horiz_per/vclk
n_hbb		equ	((horiz_per-sync_per-front_porch)/vclk)+$400
n_hbe		equ	(line_blank-sync_per-front_porch)/vclk
n_hs		equ	((horiz_per-sync_per)/vclk)+$400
n_hvs		equ	(horiz_per-(2*sync_per))/vclk
n_heq		equ	(horiz_per-eq_per)/vclk
n_hde		equ	((disp_width/2)-1)+$400
n_hdb1		equ	((n_hp)-(disp_width/2))
n_hdb2		equ	n_hdb1

n_vp		equ	523
n_vee		equ	6
n_vbe		equ	40
n_vdb		equ	n_vbe-2
n_vde		equ	n_vdb+(disp_height*2)
n_vbb		equ	n_vde
n_vs		equ	n_vp-10
n_veb		equ	n_vs-n_vee

SCRN_TOP	equ	n_vdb		
SCRN_BOTTOM	equ	n_vde		
