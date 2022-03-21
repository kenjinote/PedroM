/*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003-2009 Patrick Pelissier
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

#undef	min
#define min(a,b) (((a)>(b)?(b):(a)))
#undef	max
#define max(a,b) (((a)>(b)?(a):(b)))

void DrawLine (short x0, short y0, short x1, short y1, short Attr);

typedef struct {
  short x0, y0, x1, y1;
} WIN_RECT;

typedef struct {
 short Left, Up, Right, Down;
} CLIP_STRUCT;

typedef union {
  struct {
    unsigned char x0, y0, x1, y1;
  } xy;
  unsigned long l;
} SCR_RECT;

#define swap(a,b) { register short temp=a; a = b;b = temp; }

/*
 * Clip the line
 * It returns directly if the line is totally outside
 * A macro is used since it updates the value (x1,y1) and (x2,y2)
 *
 * At the end of the macro, x1 < x2 and the line is clipped
 */
#define ClipLine(x1, y1, x2, y2)                                        \
  {	register short dx,dy,t;                                         \
    dx = x2 - x1;                                                       \
    if (dx < 0)                                                         \
      {                                                                 \
        swap(x1,x2);                                                    \
        swap(y1,y2);                                                    \
        dx = -dx;                                                       \
      }                                                                 \
    if ((x1 > Clip.Right) || (x2 < Clip.Left) || (y1 > Clip.Down && y2 > Clip.Down ) || (y2 < Clip.Up && y1 < Clip.Up)) \
      return;                                                           \
    dy = y2 - y1;                                                       \
    if (dx == 0)                                                        \
      {                                                                 \
        if (y2 < y1)                                                    \
          swap(y1,y2);                                                  \
        y1 = max(y1, Clip.Up);                                          \
        y2 = min(y2, Clip.Down);                                        \
      }                                                                 \
    else if (dy == 0)                                                   \
      {                                                                 \
        x1 = max(x1, Clip.Left);                                        \
        x2 = min(x2, Clip.Right);                                       \
      }                                                                 \
    else if (dy >= 0)                                                   \
      {                                                                 \
        if (x1 < Clip.Left)                                             \
          {                                                             \
            if ((y1 < Clip.Up) && ((t = x1 + dx *(Clip.Up-y1) /dy) >= Clip.Left)) \
              {                                                         \
                x1 = t;                                                 \
                y1 = Clip.Up;                                           \
                if (x1 > Clip.Right) return;                            \
              }                                                         \
            else	{                                               \
              y1 += dy * (Clip.Left-x1) / dx;                           \
              x1 = Clip.Left;                                           \
              if (y1 > Clip.Down) return;                               \
            }                                                           \
          }                                                             \
        else if (y1 < Clip.Up)                                          \
          {                                                             \
            x1 += dx * (Clip.Up-y1) / dy;                               \
            y1 = Clip.Up;                                               \
            if (x1 > Clip.Right) return;                                \
          }                                                             \
        if (x2 > Clip.Right)                                            \
          {                                                             \
            if ((y2 > Clip.Down) && ((t = x2 - dx*(y2-Clip.Down)/dy) <= Clip.Right)) \
              {                                                         \
                x2 = t;                                                 \
                y2 = Clip.Down;                                         \
              }                                                         \
            else	{                                               \
              y2 -= dy * (x2-Clip.Right) / dx;                          \
              x2 = Clip.Right;                                          \
            }                                                           \
          }                                                             \
        else if (y2 > Clip.Down)                                        \
          {                                                             \
            x2 -= dx * (y2-Clip.Down) / dy;                             \
            y2 = Clip.Down;                                             \
          }                                                             \
      }                                                                 \
    else	{                                                       \
      if (x1 < Clip.Left)                                               \
        {                                                               \
          if ((y1 > Clip.Down) && ((t = x1 + dx *(Clip.Down-y1)/dy) >= Clip.Left)) \
            {                                                           \
              x1 = t;                                                   \
              y1 = Clip.Down;                                           \
              if (x1 > Clip.Right) return;                              \
            }                                                           \
          else	{                                                       \
            y1 = y1 + dy * (Clip.Left-x1) / dx;                         \
            x1 = Clip.Left;                                             \
            if (y1 < Clip.Up) return;                                   \
          }                                                             \
        }                                                               \
      else if (y1 > Clip.Down)                                          \
        {                                                               \
          x1 = x1 + dx * (Clip.Down-y1) / dy;                           \
          y1 = Clip.Down;                                               \
          if (x1 > Clip.Right) return;                                  \
        }                                                               \
      if (x2 > Clip.Right)                                              \
        {                                                               \
          if ((y2 < Clip.Up) && ((t = x2 + dx*(Clip.Up-y2)/dy) <= Clip.Right)) \
            {                                                           \
              x2 = t;                                                   \
              y2 = Clip.Up;                                             \
            }                                                           \
          else	{                                                       \
            y2 = y2 + dy * (Clip.Right-x2) / dx;                        \
            x2 = Clip.Right;                                            \
          }                                                             \
        }                                                               \
      else if (y2 < Clip.Up)                                            \
        {                                                               \
          x2 = x2 + dx * (Clip.Up-y2) / dy;                             \
          y2 = Clip.Up;                                                 \
        }                                                               \
    }                                                                   \
  }

void DrawClipLine (const WIN_RECT *Line, const SCR_RECT *clip, short Attr)
{
  short	x1,y1,x2,y2;
  CLIP_STRUCT Clip;
  x1 = Line->x0;
  y1 = Line->y0;
  x2 = Line->x1;
  y2 = Line->y1;
  Clip.Left = clip->xy.x0;
  Clip.Up = clip->xy.y0;
  Clip.Right = clip->xy.x1;
  Clip.Down = clip->xy.y1;
  ClipLine(x1, y1, x2, y2);
  //if (x1 < 0 || x2 >239 || y1 < 0 || y1 > 127 || y2 < 0 || y2 > 127)
  //  asm ("toto: bra toto\n");
  DrawLine(x1,y1,x2,y2,Attr);
}
