/* o_main.c -- options menu */

#include "doomdef.h"
#include "p_local.h"
#include "st_main.h"

#define MOVEWAIT	5
#define ITEMSPACE	40
#define SLIDEWIDTH  90

extern 	int	    cx, cy;
extern	int		sfxvolume;		/* range from 0 to 255 */
extern	int		controltype;	/* 0 to 5 */

extern void print (int x, int y, char *string);
extern void IN_DrawValue(int x,int y,int value);

/* action buttons can be set to BT_A, BT_B, or BT_C */
/* strafe and use should be set to the same thing */

extern	unsigned	BT_ATTACK;
extern	unsigned	BT_USE;
extern	unsigned	BT_STRAFE;
extern	unsigned	BT_SPEED;

typedef enum
{
	SFU,
	SUF,
	FSU,
	FUS,
	USF,
	UFS,
	NUMCONTROLOPTIONS
}	control_t;

typedef enum
{
    widescrn,
	soundvol,
    musicvol,
	controls,
	NUMMENUITEMS
} menupos_t;

menupos_t	cursorpos;

typedef struct
{
	int		x;
	int		y;
	boolean	hasslider;
	char 	name[20];
} menuitem_t;

menuitem_t menuitem[5];
 
typedef struct
{
	int	curval;
	int	maxval;
} slider_t;

slider_t slider[5];

int		cursorframe, cursorcount;
int		movecount;

jagobj_t		*uchar[52];

jagobj_t		*o_cursor1, *o_cursor2;
jagobj_t		*o_slider, *o_slidertrack;

char buttona[NUMCONTROLOPTIONS][8] =
		{"Speed","Speed","Fire","Fire","Use","Use"};
char buttonb[NUMCONTROLOPTIONS][8] = 
		{"Fire","Use ","Speed","Use","Speed","Fire"};
char buttonc[NUMCONTROLOPTIONS][8] =
		{"Use","Fire","Use","Speed","Fire","Speed"};

unsigned configuration[NUMCONTROLOPTIONS][3] =
{
	{BT_A, BT_B, BT_C},
	{BT_A, BT_C, BT_B},
	{BT_B, BT_A, BT_C},
	{BT_C, BT_A, BT_B},
	{BT_B, BT_C, BT_A},
	{BT_C, BT_B, BT_A} 
};

char anamorphic[2][4] = 
        {"Off","On"};

boolean initmathtbl = true;
boolean anamorphicview;
int stretch;
fixed_t stretchscale;

void O_SetButtonsFromControltype (void)
{
	BT_SPEED = configuration[controltype][0];
	BT_ATTACK =	configuration[controltype][1];
	BT_USE = configuration[controltype][2];	
	BT_STRAFE = configuration[controltype][2];	
}


/* */
/* Draw control value */
/* */
void O_DrawControl(void)
{
	EraseBlock(menuitem[widescrn].x + 40, menuitem[widescrn].y + 20, 60, 20);
	print(menuitem[widescrn].x + 40, menuitem[widescrn].y + 20, anamorphic[anamorphicview ? 1 : 0]);

	EraseBlock(menuitem[controls].x + 40, menuitem[controls].y + 20, 90, 80);
	print(menuitem[controls].x + 40, menuitem[controls].y + 20, buttona[controltype]);
	print(menuitem[controls].x + 40, menuitem[controls].y + 40, buttonb[controltype]);
	print(menuitem[controls].x + 40, menuitem[controls].y + 60, buttonc[controltype]);

/*	IN_DrawValue(30, 20, controltype); */
	
	O_SetButtonsFromControltype ();
    stretch = anamorphicview ? 28*8 : 22*8;
    stretchscale = anamorphicview ? 183501 : 144179;
}

/*
===============
=
= O_Init
=
===============
*/

void O_Init (void)
{
	int 	i, l;

/* the eeprom has set controltype, so set buttons from that */
	O_SetButtonsFromControltype ();

/* the eeprom has widescreen setting */
    stretch = anamorphicview ? 28*8 : 22*8;
    stretchscale = anamorphicview ? 183501 : 144179;

/* cache all needed graphics */
	o_cursor1 = W_CacheLumpName ("M_SKULL1",PU_STATIC);
	o_cursor2 = W_CacheLumpName ("M_SKULL2",PU_STATIC);
	o_slider = W_CacheLumpName ("O_SLIDER", PU_STATIC);
	o_slidertrack = W_CacheLumpName ("O_STRACK", PU_STATIC);

	l = W_GetNumForName ("CHAR_065");
	for (i = 0; i < 52; i++)
		uchar[i] = W_CacheLumpNum(l+i, PU_STATIC);

/*	initialize variables */

	cursorcount = 0;
	cursorframe = 0;
	cursorpos = 0;	
	
/*  chillywilly: anamorphic widescreen */
    D_strncpy(menuitem[widescrn].name, "Widescreen", 10);
	menuitem[widescrn].x = 85;
	menuitem[widescrn].y = 40;
	menuitem[widescrn].hasslider = false;

    D_strncpy(menuitem[soundvol].name, "Sfx Vol", 7); /* Fixed CEF */
	menuitem[soundvol].x = 45;
	menuitem[soundvol].y = 80;
	menuitem[soundvol].hasslider = true;

 	slider[soundvol].maxval = 16;
	slider[soundvol].curval = 16*sfxvolume/255;

/*  chillywilly: music volume */
    D_strncpy(menuitem[musicvol].name, "Mus Vol", 7);
	menuitem[musicvol].x = 45;
	menuitem[musicvol].y = 100;
	menuitem[musicvol].hasslider = true;

 	slider[musicvol].maxval = 16;
	slider[musicvol].curval = 16*musicvolume/255;

    D_strncpy(menuitem[controls].name, "  Controls", 10); /* Fixed CEF */
	menuitem[controls].x = 85;
	menuitem[controls].y = 120;
	menuitem[controls].hasslider = false;

}

/*
==================
=
= O_Control
=
= Button bits can be eaten by clearing them in ticbuttons[playernum]
==================
*/

void O_Control (player_t *player)
{
	int		buttons, oldbuttons;
	
	buttons = ticbuttons[playernum];
	oldbuttons = oldticbuttons[playernum];
	
	if ( (buttons & BT_OPTION) && !(oldbuttons & BT_OPTION) )
	{
		cursorpos = 0;	
		player->automapflags ^= AF_OPTIONSACTIVE;
		if (player->automapflags & AF_OPTIONSACTIVE)
			DoubleBufferSetup ();
		else
			WriteEEProm ();		/* save new settings */
	}
	if ( !(player->automapflags & AF_OPTIONSACTIVE) )
		return;


/* clear buttons so game player isn't moving aroung */
	ticbuttons[playernum] &= BT_OPTION;	/* leave option status alone */

	if (playernum != consoleplayer)
		return;
		
/* animate skull */
	if (++cursorcount == 4)
	{
		cursorframe ^= 1;
		cursorcount = 0;
	}

/* check for movement */
	if (! (buttons & (JP_UP|JP_DOWN|JP_LEFT|JP_RIGHT) ) )
		movecount = 0;		/* move immediately on next press */
	else
	{
			if (buttons & JP_RIGHT)
			{
				if (menuitem[cursorpos].hasslider)
				{
					slider[cursorpos].curval++;
					if (slider[cursorpos].curval > slider[cursorpos].maxval)
						slider[cursorpos].curval = slider[cursorpos].maxval;
					if (cursorpos == soundvol)
					{
						sfxvolume = 255*slider[soundvol].curval / slider[soundvol].maxval;
						S_StartSound (NULL, sfx_pistol);
					}
					else if (cursorpos == musicvol)
					{
						musicvolume = 255*slider[musicvol].curval / slider[musicvol].maxval;
					}
				}
			}
			if (buttons & JP_LEFT)
			{
				if (menuitem[cursorpos].hasslider)
				{
					slider[cursorpos].curval--;
					if (slider[cursorpos].curval < 0)
						slider[cursorpos].curval = 0;
					if (cursorpos == soundvol)
					{
						sfxvolume = 255*slider[soundvol].curval / slider[soundvol].maxval;
						S_StartSound (NULL, sfx_pistol);
					}
					else if (cursorpos == musicvol)
					{
						musicvolume = 255*slider[musicvol].curval / slider[musicvol].maxval;
					}
				}
			}

		if (movecount == MOVEWAIT)
			movecount = 0;		/* repeat move */
		if (++movecount == 1)
		{
			if (buttons & JP_DOWN)
			{
				cursorpos++;
				if (cursorpos == NUMMENUITEMS)
					cursorpos = 0;
			}
		
			if (buttons & JP_UP)
			{
				cursorpos--;
				if (cursorpos == -1)
					cursorpos = NUMMENUITEMS-1;
			}
			if (buttons & JP_RIGHT)
			{
				if (cursorpos == controls)
				{
					controltype++;
					if(controltype == NUMCONTROLOPTIONS)
						controltype = (NUMCONTROLOPTIONS - 1); 
				} else if (cursorpos == widescrn)
                {
                    anamorphicview = true;
                    initmathtbl = true;
                }
			}
			if (buttons & JP_LEFT)
			{
				if (cursorpos == controls)
				{
					controltype--;
					if(controltype == -1)
						controltype = 0; 
				} else if (cursorpos == widescrn)
                {
                    anamorphicview = false;
                    initmathtbl = true;
                }
			}
		}
	}
}

void O_Drawer (void)
{
	int		i;
	int		offset;
	
/* Erase old and Draw new cursor frame */
	EraseBlock(16, 40, o_cursor1->width, 200);
	if(cursorframe)
		DrawJagobj(o_cursor1, 20, menuitem[cursorpos].y - 2);
	else
		DrawJagobj(o_cursor2, 20, menuitem[cursorpos].y - 2);

/* Draw menu */

	print(104, 10, "Options");
	
	for (i = 0; i < NUMMENUITEMS; i++)
	{
		print(menuitem[i].x, menuitem[i].y, menuitem[i].name);		

		if(menuitem[i].hasslider == true)
		{
			DrawJagobj(o_slidertrack , menuitem[i].x + 112, menuitem[i].y + 2);
			offset = (slider[i].curval * SLIDEWIDTH) / slider[i].maxval;
			DrawJagobj(o_slider, menuitem[i].x + 117 + offset, menuitem[i].y + 2);
		}
	}
	
/* Draw control info */

	print(menuitem[controls].x + 10, menuitem[controls].y + 20, "A");
	print(menuitem[controls].x + 10, menuitem[controls].y + 40, "B");
	print(menuitem[controls].x + 10, menuitem[controls].y + 60, "C");

	O_DrawControl();

/* debug stuff */
#if 0
	cx = 30;
	cy = 40;
	D_printf("Speed = %d", BT_SPEED);
	cy = 60;
	D_printf("Use/Strafe = %d", BT_SPEED);
	cy = 80;
	D_printf("Fire = %d", BT_SPEED);
#endif
/* end of debug stuff */

	UpdateBuffer ();
}

