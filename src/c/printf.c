/*
 * PedroM - Operating System for Ti-89/Ti-92+/V200.
 * Copyright (C) 2003, 2004, 2005 Patrick Pelissier
 *
 * This program is free software ; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program;
 * if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
#include "PedroM-Internal.h"

#define TAB_KEY		9

typedef enum {
  FLAG_LJUSTIFY=1,
  FLAG_PRECGIVEN=2,
  FLAG_BLANKER=4,
  FLAG_VARIANT=8,
  FLAG_PADZERO=0x10,
  FLAG_SIGNED=0x20,
  FLAG_LONG=0x40,
  FLAG_FPCONV=0x100
} flags_e;

typedef struct {
  const char *prefix, *hextab;
  short (*putc)(short, FILE *);
  float float_value;
  unsigned long int_value;
  flags_e flags;
  int precision, width;
} vcbprintf_display_number_t;

#define PUTC(info, ch, f) ((info)->putc(ch, f), charcount++)

#define PADDING(info, ch, n, f)  \
  do {while (n > 0) {PUTC(info, ch, f); n--;}} while (0)

/* Display a float or a long */
static int
vcbprintf_display_number (FILE *f, int ch, vcbprintf_display_number_t *dr)
{
  unsigned long v = dr->int_value;
  flags_e flags = dr->flags;
  int precision = dr->precision;
  int width = dr->width;
  bcd *b = (bcd*) (union { bcd b; float f; } *) (&(dr->float_value));
  const char *prefix = dr->prefix;

  int i, len, charcount;
  short expo;
  char sign, bzero;
  char c;
  char buffer[32];

  len = charcount = 0;

  /* Parse the number and fill buffer with the reverse digits */
  switch (ch)
    {
    case 'p':
    case 'X':
    case 'x':
      while(v != 0)
	{
	  buffer[len++] = dr->hextab[v & 0xf];
	  v = v >> 4;
	}
      break;

    case 'o':
      while(v != 0)
	{
	  buffer[len++] = '0' + (v & 7);
	  v = v >> 3;
	}
      break;

    case 'b':
      while(v != 0)
	{
	  buffer[len++] = '0' + (v & 1);
	  v = v >> 1;
	}
      break;

    case 'u':
    case 'i':
    case 'd':
      while(v != 0)
	{
	  buffer[len++] = '0' + (char)(v % 10);
	  v = v / 10;
	}
      break;

    default:    /* Float */
      expo = (b->exponent & 0x7FFF) - 0x4000;
      /* NAN */
      if (expo == (0x7FFF- 0x4000)) {
        buffer[len++] = 'f';
        buffer[len++] = 'e';
        buffer[len++] = 'd';
        buffer[len++] = 'n';
        buffer[len++] = 'u';
        /* ZERO */
      } else if (expo == (0x2000-0x4000))
        buffer[len++] = '0';
      /* INF */
      else if (expo == (0x6000-0x4000)) {
        buffer[len++] = 190;
        if (b->exponent & 0x8000)
          buffer[len++] = '-';
        else
          buffer[len++] = '+';
        /* NORMAL PRINT */
      } else if (expo >=-1 && expo <5 && ch == 'f' && precision <= 6) {
        /* Normal print */
        bzero = (flags | FLAG_VARIANT);
        v = b->mantissa2;
        for(i = 0 ; i < 8 ; i++) {
          if (bzero || (v &0x0F)) {
            buffer[len++] = (v & 0xF) + '0';
            bzero = 1;
          }
          v >>= 4;
        }
        v = b->mantissa1;
        for(i = 0 ; i < (7-expo) ; i++) {
          if (bzero || (v &0x0F)) {
            buffer[len++] = (v & 0xF) + '0';
            bzero = 1;
          }
          v >>= 4;
        }
        if (bzero)
          buffer[len++] = '.';
        for( ; i < 8 ; i++) {
          buffer[len++] = (v & 0xF) + '0';
          v >>= 4;
        }
        if (b->exponent & 0x8000)
          buffer[len++] = 175;
      } else {
	/* Scientific print */
	sign = 0;
	if (expo < 0) {
          expo=-expo;
          sign = 1;
        }
	do  {
	  buffer[len++] = '0' + (char)(expo % 10);
	  expo = expo / 10;
	} while (expo != 0) ;
	if (sign)
	  buffer[len++] ='-';
	buffer[len++]=149;
	/* Mantisse */
        int old_len = len;
	bzero = (flags|FLAG_VARIANT);
	v = b->mantissa2;
	for(i = 0 ; i < 8 ; i++) {
          if (bzero || (v &0x0F)) {
            buffer[len++] = (v & 0xF) + '0';
            bzero = 1;
          }
          v >>= 4;
        }
	v = b->mantissa1;
	for(i = 0 ; i < 7 ; i++) {
          if (bzero || (v &0x0F)) {
            buffer[len++] = (v & 0xF) + '0';
            bzero = 1;
          }
          v >>= 4;
        }
        if (len - old_len > precision) {
          memmove (&buffer[old_len], &buffer[len-precision], precision);
          len = old_len + precision;
        }
	if (bzero)
	  buffer[len++] = '.';
	buffer[len++] = (v & 0xF) + '0';
	if (b->exponent & 0x8000)
	  buffer[len++] = 175;
      }
      break;
    }

  /* Handle '0' number */
  if (v == 0 && len == 0)
    buffer[len++] = '0';

  /* Remove 'len' characters from precision. Check if overflow */
  if ((precision -= len)<0)
    precision = 0;

  /* Compute the remaining characters to print to fit 'width' characters */
  width = dr->width - (strlen (prefix) + precision + len);

  /* Print Number in FILE f, adding prefix and padding if necessary */
  if ((flags & (FLAG_PADZERO|FLAG_LJUSTIFY)) == 0)
    PADDING (dr, ' ', width, f);
  while ((c=*prefix++)!=0)
    PUTC (dr, c, f);
  if ((flags&FLAG_LJUSTIFY) == 0 && (flags & FLAG_PADZERO))
    PADDING (dr, '0', width, f);
  PADDING (dr, '0', precision, f);
  while (len-- > 0)
    PUTC (dr, buffer[len], f);
  if (flags & FLAG_LJUSTIFY)
    PADDING (dr, ' ', width, f);

  return charcount;
}

int
vcbprintf (short (*callback)(short,FILE *), FILE *p, const char *fmt, va_list args)
{
  vcbprintf_display_number_t dr;
  long w;
  int charcount;
  char  ch;

  charcount = 0;
  dr.putc = callback;
  while ( (ch = *fmt++) != 0)
    {
      if (ch != '%') /* Normal char: print it directly */
	{
	  PUTC (&dr, ch, p);
          continue;
	}
      /* Special character %something: decode it */

      /* FIXME: Implement support variable argument field '%m$' (Single Unix Specification) */

      /* Read flags (Ti special flags not supported!) */
      dr.flags = 0;
      for (;;)
        switch (ch = *fmt++)
          {
          case '#':
            dr.flags |= FLAG_VARIANT;
            break;
          case '0':
            if ((dr.flags & FLAG_LJUSTIFY) == 0)
              dr.flags |= FLAG_PADZERO;
            break;
          case '-':
            dr.flags = FLAG_LJUSTIFY | (dr.flags & ~FLAG_PADZERO);
            break;
          case ' ':
            dr.flags |= FLAG_BLANKER;
            break;
          case '+':
            dr.flags |= FLAG_SIGNED;
            break;
          case '\'':
            /* TODO: SUSv2 specifies one */
            break;
          case 'I':
            /* TODO: glibc 2.2 specific one */
            break;
          case 'z':
          case '^':
          case '|':
            /* TODO: Ti specific ones */
            break;
          default:
            goto end_read_flags;
          }
    end_read_flags:

      /* Read width field */
      dr.width = 0;
      /* FIXME: Doesn't support variable argument '*m$' */
      if (ch=='*')
        {
          dr.width = va_arg (args, int);
          ch = *fmt++;
        }
      else
        while (isdigit (ch))
          {
            dr.width = dr.width*10 + ch - '0';
            ch = *fmt++;
          }
      /* For '*' parameter we can get a negative number. */
      if (dr.width < 0)
        {
          dr.width = -dr.width;
          dr.flags ^= FLAG_LJUSTIFY;
        }

      /* Read precision */
      /* FIXME: Doesn't support variable argument field '*m$' */
      dr.precision = 0;
      if (ch == '.')
        {
          ch = *fmt++;
          if (ch == '*')
            {
              dr.precision = va_arg (args, int);
              ch = *fmt++;
            }
          else if (ch =='-')	/* -1 (Ti specific) */
            {
              ch = *fmt++;
              if (ch == '1')
                {
                  dr.precision = 6;
                  ch = *fmt++;
                }
              else
                dr.precision = -1;
            }
          else
            while (isdigit(ch))
              {
                dr.precision = dr.precision*10 + ch - '0';
                ch = *fmt++;
              }
          if (dr.precision >= 0)
            dr.flags |= FLAG_PRECGIVEN;
          else
            dr.precision = 0;
        }

      /* Read Short or Long? */
      /* TODO: Support 'hh' (char argument), 'll' 'L', 'q', 'j' (long long argument) */
      if (ch=='l' || ch == 'z' || ch == 't')
        {
          dr.flags |= FLAG_LONG;
          ch = *fmt++;
        }
      else if (ch=='h')
        {
          ch = *fmt++;
        }

      /* Get the nature of the variable to display */
      dr.int_value = 0;
      dr.float_value = 0.0;
      dr.prefix = "";
      switch (ch)
        {
          /* End of String */
        case 0:
          fmt--;
          continue;
          
          /* String */
        case 's':
          {
            /* TODO: Support the long argument FLAG_LONG to display wchar_t ? */
            const char *str = va_arg(args, const char *);
            long i, n;
            n = strlen (str);
            if (dr.flags & FLAG_PRECGIVEN)
              n = MIN (n, dr.precision);
            dr.width -= n;
            if ((dr.flags&FLAG_LJUSTIFY) == 0)
              {
                ch = dr.flags & FLAG_PADZERO ? '0' : ' ';
                PADDING (&dr, ch, dr.width, p);
              }
            for (i=0; i<n; i++)
              PUTC (&dr, str[i], p);
            if (dr.flags&FLAG_LJUSTIFY)
              PADDING (&dr, ' ', dr.width, p);
            /* We have printed the string. Go no next format character */
            continue;
          }
          
          /* Pointer */
        case 'p':
          dr.int_value = (unsigned long) va_arg(args, const void *);
          dr.hextab    = "0123456789abcdef";
          dr.prefix    = (dr.flags&FLAG_VARIANT) ? "@" : "";
          dr.precision = 6;	/* Only 24 bits avialble */
          dr.flags       |= FLAG_PRECGIVEN;
          break;
          
          /* Unsigned Numbers */
        case 'X':
          dr.hextab = "0123456789ABCDEF";
          dr.prefix = (dr.flags&FLAG_VARIANT) ? "0X" : "";
          goto ReadNumber;
        case 'x':
          dr.hextab = "0123456789abcdef";
          dr.prefix = (dr.flags&FLAG_VARIANT) ? "0x" : "";
          goto ReadNumber;
        case 'b':
          dr.prefix = (dr.flags&FLAG_VARIANT) ? "0b" : "";
          goto ReadNumber;
        case 'o':
          dr.prefix = (dr.flags&FLAG_VARIANT) ? "0" : "";
          goto ReadNumber;
        case 'u':
          dr.prefix = "";
        ReadNumber:
          if (dr.flags & FLAG_LONG)
            dr.int_value = va_arg (args, unsigned long);
          else
            dr.int_value = va_arg (args, unsigned short);
          if (dr.flags & FLAG_PRECGIVEN)
            dr.flags &= ~FLAG_PADZERO;
          break;
          
          /* Signed numbers */
        case 'i':
        case 'd':
          if (dr.flags & FLAG_LONG)
            w = va_arg(args, signed long);
          else
            w = va_arg(args, signed short);
          dr.int_value = (w < 0) ? -w : w;
          dr.prefix = (w < 0) ? "-" : (dr.flags & FLAG_SIGNED) ? "+" :
            (dr.flags & FLAG_BLANKER) ? " " : "";
          if (dr.flags & FLAG_PRECGIVEN)
            dr.flags &= ~FLAG_PADZERO;
          break;
          
          /* Float numbers */
        case 'f':
        case 'F':
        case 'e':
        case 'E':
        case 'g':
        case 'G':
        case 'r':
        case 'R':
        case 'y':
        case 'Y':
          if ((dr.flags & FLAG_PRECGIVEN) == 0)
            dr.precision = 6;
          dr.float_value = va_arg (args, double);
          dr.prefix = (dr.flags&FLAG_SIGNED) ? "+" : (dr.flags&FLAG_BLANKER) ? " " : "";
          break;
          
          /* Single character case */
        case 'c':
          ch = va_arg(args, int);
          /* Go down to default handler */
          
          /* The number of characters written so far is stored into the integer indicated by the int * (or variant) pointer argument */
        case 'n':
          /* FIXME: Implement it ? */

         /* Unknow character code */
        default:
          dr.width--;                        /* char width is 1 */
          if ((dr.flags & FLAG_LJUSTIFY) == 0)
            {
              const char c = dr.flags & FLAG_PADZERO ? '0' : ' ';
              PADDING (&dr, c, dr.width, p);
            }
          PUTC (&dr, ch, p);
          if (dr.flags&FLAG_LJUSTIFY)
            PADDING (&dr, ' ', dr.width, p);
          continue;
        }

      /* Print the number */
      charcount += vcbprintf_display_number (p, ch, &dr);
    } /* while not the end of the format string */
  return charcount;
}

short
_sputc(short ch, FILE *fp)
{
  char **op = (char **) fp;
  *((*op)++) = ch;
  return ch;
}

int
sprintf(char *buff, const char *fmt, ...)
{
  char *sf = buff;
  va_list a;
  int length;
  va_start(a, fmt);
  asm ("nop\n nop\n nop");
  length = vcbprintf(_sputc, (FILE *)(((void*)(&sf))), fmt, a);
  *sf = 0;
  va_end(a);
  return length;
}

short
PrintChar (short ch)
{
  short	Size = FontCharWidth (ch);
  short	x = CURRENT_POINT_X, y = CURRENT_POINT_Y;
  short Height = (CURRENT_FONT*2+6);	// NewLine

  if (ch == TAB_KEY)		// Tab code
    {
      CURRENT_POINT_X = ((x/TabSize)+1)*TabSize;
      return ch;
    }
  if (ch == '\r')
    ch = '\n';
  if ((ch == '\n') || (x + Size > (GET_XMAX+1)))
    {
      y += Height;
      if (++PRINTF_LINE_COUNTER > 13)
	{
	  ST_busy (2);		// Display 'Pause'
	  while (!PID_CheckSwitch (GetKey(), ARGV[0]));
	  ST_busy (0);		// Return to normal mode
	  PRINTF_LINE_COUNTER = 0;
	}
      x = 0;
    }
  if (y + Height > GET_YMAX)
    {
      ScrRectScroll (&ScrRect, &ScrRect, y+Height-GET_YMAX, 0);
      y = GET_YMAX - Height;
    }
  if (ch != '\n')
    {
      DrawChar(x, y, ch, 4);
      x+=Size;
    }
  CURRENT_POINT_X = x;
  CURRENT_POINT_Y = y;
  return ch;
}

