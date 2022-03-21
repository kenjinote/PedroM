/*
;* Extgraph Bitmap functions
;* Copyright (C) 2002 Thomas Nussbaumer
;*
;* Adaptated for PedroM and Clipping
;* Copyright (C) 2003, 2004, 2005 Patrick Pelissier
;*
;* This program is free software ; you can redistribute it and/or modify it under the
;* terms of the GNU General Public License as published by the Free Software Foundation;
;* either version 2 of the License, or (at your option) any later version. 
;* 
;* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
;* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;* See the GNU General Public License for more details. 
;* 
;* You should have received a copy of the GNU General Public License along with this program;
;* if not, write to the 
;* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 */
 
#include "PedroM-Internal.h"

void	BitmapGet(const SCR_RECT *rect, short *BitMap)
{
  short x, y, h, w, bytewidth;
  unsigned char* dest;
  unsigned short FinalMask;
  
  BitmapInit(rect, BitMap);
  x = rect->xy.x0;
  y = rect->xy.y0;
  h = rect->xy.y1 - rect->xy.y0 + 1;
  w = rect->xy.x1 - rect->xy.x0 + 1;
  FinalMask = (w&7) ? (0xFF >> (8-(w&7))) << (8-(w&7)) : 0xFF;
  bytewidth = (w+7) >> 3;
  dest = (unsigned char *) ((short *) BitMap+2);
  {
    register unsigned char* addr  = (CURRENT_SCREEN)+(y*CURRENT_INCY+(x>>3));
    register unsigned short mask1 = x & 7;
    register unsigned short mask2;
    register unsigned short lineoffset = CURRENT_INCY-bytewidth;
    register          short loop;
    
    if (mask1) 
      {
	mask2 = 8 - mask1;
	for (;h;h--,addr+=lineoffset)
	  {
	    *dest = (*addr++) << mask1;
	    for (loop=1;loop<bytewidth;loop++)
	      {
		*dest++ |= (*addr >> mask2);
		*dest = (*addr++) << mask1;
	      }
	    *dest = (*dest | (*addr >> mask2)) & FinalMask;
	    dest++;
	  }
      }
    else {
      for (;h;h--,addr+=lineoffset)
	{
	  for (loop=0;loop<bytewidth;loop++) *dest++ = *addr++;
	  dest[-1] &= FinalMask;
	}
    }
  }
}

#define SPRITE_FUNC(FUNC_NAME, OP) \
void FUNC_NAME(short x, short y, short h, const unsigned char* sprite, short bytewidth) { \
    register unsigned char* addr  = CURRENT_SCREEN + CURRENT_INCY*y + (x>>3); \
    register unsigned short mask1 = x & 7;  \
    register unsigned short mask2; \
    register unsigned short lineoffset = CURRENT_INCY-bytewidth; \
    register          short loop; \
    if (mask1) { \
       mask2 = 8 - mask1; \
       for ( ; h ; h--, addr+=lineoffset) { \
         *addr++ OP (*sprite >> mask1); \
         for (loop=1;loop<bytewidth;loop++) { \
             *addr OP ((*sprite++) << mask2); \
             *addr++ OP (*sprite >> mask1); \
         } \
         *addr OP (*sprite++ << mask2); \
       } \
    } else { \
        for (;h;h--,addr+=lineoffset) { \
            for (loop=0;loop<bytewidth;loop++) *addr++ OP *sprite++; \
        } \
    } \
}

SPRITE_FUNC(SpriteX8_or, |=)
SPRITE_FUNC(SpriteX8_and, &=)
SPRITE_FUNC(SpriteX8_xor, ^=)

void BitmapPut (short x, short y, const short *BitMap, const SCR_RECT *clip, short Attr)
{
  SCR_RECT	r, newClip;
  short	h, w;
  short Left, Right, Up, Down;
  
  h = *(BitMap++);
  w = *(BitMap++);
  
  r.xy.x0 = x < 0 ? 0 : x;
  r.xy.y0 = y < 0 ? 0 : y;
  r.xy.y1 = y+h-1 > 128 ? 128 : y+h-1;
  r.xy.x1 = x+w-1 > 240 ? 240 : x+w-1;
  
  /* Clipping : Merge clip area with the current ScrRect */
  if (!ScrRectOverlap (clip, &ScrRect, &newClip) )
    return;

  /* To avoid problems due to cast */
  Left  = newClip.xy.x0; 
  Right = newClip.xy.x1;
  Up    = newClip.xy.y0; 
  Down  = newClip.xy.y1;
  /* Full Clipping ? */
  if (x>Right || y>Down || x+w<Left || y+h<Up)
    return;
  /* Vertical clipping */
  if (y < Up)
    {
      short inc = Up-y;
      BitMap = (const short *) ((const unsigned char *) BitMap + (inc * ((w+7)>>3)));
      y = Up;
      h -= inc;
    }
  if (y+h > Down)
    h = Down - y + 1;
  /* Horizontal clipping */
  if (x<Left || x+w > Right) {
    SCR_STATE current;
    short *newBitmap;
    newClip.xy.y0 = 0; newClip.xy.y1 = h - 1;
    newClip.xy.x0 = x>=Left ? 0 : Left-x;
    newClip.xy.x1 = (x+w<=Right ? w : Right-x);
    newBitmap = alloca( 2 + h * ((w+7)>>3) );
    SaveScrState(&current);
    PortSet((void*)BitMap, w-1, h-1);
    BitmapGet(&newClip, newBitmap);
    RestoreScrState(&current);
    BitMap = newBitmap + 2;
    w = newClip.xy.x1 - newClip.xy.x0 + 1;
    x += newClip.xy.x0;
  }
  /* Drawing */
  switch (Attr)
    {
    case	A_REVERSE:
      ScrRectFill(&r, clip, A_NORMAL);
    case	A_XOR:
      SpriteX8_xor(x, y, h, (const unsigned char *) BitMap, (w+7)>>3);
      break;
    case	A_REPLACE:
      ScrRectFill(&r, clip, A_REVERSE);
    case	A_NORMAL:
    case	A_OR:
      SpriteX8_or(x, y, h, (const unsigned char *) BitMap, (w+7)>>3);
      break;	
    case	A_AND:
      SpriteX8_and(x, y, h, (const unsigned char *) BitMap, (w+7)>>3);
    default:
      break;
    }
}
