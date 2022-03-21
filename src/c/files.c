/*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003-2009 Patrick Pelissier
;*
;* Original Files function - (c) 2001-2002 Tigcc Team
;* Adaptation for use with PedroM - (c) 2003 Patrick Pelissier
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

#define DEFAULT_ALLOC_SIZE 128
#define DEFAULT_INC_ALLOC 128

typedef enum {
 _F_READ=0x0001,_F_WRITE=0x0002,_F_RDWR=0x0003,
 _F_ERR=0x0010,_F_BIN=0x0040, _F_TERMINAL=0x0100, _F_TMP=0x0200, _F_NULL=0x0400, _F_TTY=0x0800
} __FileFlags;

#define __FERROR(f) ({(f)->flags|=_F_ERR; return -1;})

//#define CHECK_FILE

#ifdef CHECK_FILE
#define ER_ILLEGAL_FILE_PTR 404
__ATTR_REG__ static void fcheck(const FILE *f)
{
  if (f < FILE_TAB || f > &FILE_TAB[MAX_FILES])
    ER_throw(ER_ILLEGAL_FILE_PTR);
}
#else
#define fcheck(f) /*void*/
#endif

/*
 * Init stdin, stdout and stderr
 */
void    InitTerminal(void)
{
  stdin->flags = _F_TERMINAL | _F_READ;
  stdout->flags = _F_TERMINAL | _F_WRITE;
  stderr->flags = _F_TERMINAL | _F_WRITE;
}

__ATTR_REG__ short fclose(FILE *f)
{
  short s;

  fcheck(f);
  s = (f->flags&_F_ERR)?-1:0;

  if ((f->flags&(_F_TERMINAL|_F_NULL)) == 0)
    {
      if ((f->flags&_F_TMP) != 0)	/* If tmp, frees handle */
        HeapFree(f->handle);
      else if ((f->flags&_F_WRITE) != 0)
        HeapRealloc(f->handle, peek_w(HeapDeref(f->handle))+2);
    }
  f->handle = 0;
  f->flags = 0;
  return s;
}

__ATTR_REG__ FILE *freopen(const char *name, const char *mode, FILE *f)
{
  char name2[20], *sptr = NULL;
  char *base;
  short bmode=(mode[1]=='b'|| (mode[1]!=0 &&mode[2]=='b')),flags=0;
  SYM_ENTRY *sym = NULL;

  // Check if f is a file
  fcheck(f);

  // Close file if it has been opened
  if (f->flags)
    fclose(f);

  // Prepare f vars
  f->handle = 0;
  f->pos = (bmode?2:5);
  f->ungetc = 0;

  // Search for filename in VAT
  // If name == NULL, the file is opened as a temp file.
  if (name)
    {
      // First check for special name "/dev/null"
      if (!strcmp(name,"/dev/null"))
        switch (mode[0]) {
        case 'r': flags = _F_NULL | _F_READ; goto SetFlags;
        case 'w':
        case 'a': flags = _F_NULL | _F_WRITE; goto SetFlags;
        default:  return NULL;
        }
      // Search for the filename in the VAT
      sym=SymFindPtr(sptr = StrToTokN(name, name2),0);
      // If success
      if (sym != NULL)
        {
          // If the properties of the file are ok with the request to open it in write mode
          if((sym->flags.flags_n&(SF_LOCKED|SF_OPEN|SF_ARCHIVED|SF_BUSY))&&strpbrk(mode,"wa+"))
            return NULL;
          // Update the handle of the file
          f->handle=sym->handle;
        }
    }

  switch (mode[0])
    {
    case 'r':
      if (f->handle == 0)
        return NULL;
      /* Check if sym is a text file if text mode */
      if (!bmode && *HToESI(f->handle) != 0xE0)
        return NULL;
      flags = _F_READ;
      break;
    case 'a':
      if (f->handle)
        {
          flags = _F_WRITE;
          f->pos = (unsigned long)peek_w(HeapDeref(f->handle))+(bmode?2:0);
          break;
        }
    case 'w':
      flags=_F_WRITE;
      if (f->handle == 0)
        {
          f->handle = HeapAlloc(DEFAULT_ALLOC_SIZE);
          if (f->handle == 0)
            return NULL;
          if (name)
            {
              sym = DerefSym(SymAdd(sptr));
              if (sym == NULL)
                {
                  HeapFree(f->handle);
                  return NULL;
                }
              sym->handle = f->handle;
            }
          else
            flags=_F_WRITE|_F_TMP;		/* Open temporary file */
        }
      base=HeapDeref(f->handle);
      if (bmode)
        poke_w(base, 0);
      else
        {
          poke_l(base,0x00050001);
          poke_l(base+4,0x2000E000);
        }
      break;
    default:
      return NULL;
    }

 SetFlags:
  if(mode[1]=='+'||(mode[1]!=0 && mode[2]=='+'))
    flags|=_F_RDWR;
  if(bmode)
    flags|=_F_BIN;
  f->flags = flags;
  return f;
}

__ATTR_REG__ FILE *fopen(const char *name, const char *mode)
{
  int i;
  for(i = 0 ; i < MAX_FILES ; i++)
    if (FILE_TAB[i].flags == 0)
      return freopen(name, mode, &(FILE_TAB[i]));
  return NULL;
}

__ATTR_REG__ short fseek(FILE *f, long offset, short wh)
{
  fcheck(f);
  if (f->flags&(_F_TERMINAL|_F_NULL|_F_ERR|_F_TTY))
    return -1;
  long start= (f->flags&_F_BIN?2:5);
  long end  = peek_w(HeapDeref(f->handle))+(f->flags&_F_BIN?2:0);
  long pos;

  f->ungetc = 0;

  switch (wh)
    {
    case SEEK_SET:
      pos = start + offset;
      break;
    case SEEK_CUR:
      pos = f->pos + offset;
      break;
    case SEEK_END:
      pos = end - offset;
      break;
    default:
      __FERROR(f);
      break;
    }
  if (pos<start || pos>end)
    __FERROR(f);
  f->pos = pos;
  return 0;
}

__ATTR_REG__ long ftell(FILE *f)
{
  fcheck(f);

  if (f->flags&(_F_ERR|_F_TERMINAL|_F_NULL|_F_TTY))
    __FERROR(f);
  return f->pos-((f->flags&_F_BIN)?2:5);
}

__ATTR_REG__ short feof(const FILE *f)
{
  // TODO: stdin mustn't tell feof
  if (f->flags&(_F_NULL|_F_TERMINAL))
    return 1;
  // TODO: terminal: WRITE: 1 READ: If diamond+D, pop it, returns 1. Set feof flags.
  return (peek_w(HeapDeref(f->handle))+(f->flags&_F_BIN?2:0) == f->pos);
}

__ATTR_STK__ short fputc(short c, FILE *f)
{
  char *base, tmode = !(f->flags&_F_BIN);
  unsigned long size;

  fcheck(f);

  if (f->flags&_F_ERR)
    return -1;
  else if (!(f->flags&_F_WRITE))
    __FERROR(f);
  else if (f->flags&_F_TERMINAL)
    return PrintChar(c);
  else if (f->flags&_F_NULL)
    return 0;
  base = HeapDeref(f->handle);
  size = HeapSize(f->handle);
  if (peek_w(base)+10 > size)
    {
      if (HeapRealloc2(f->handle,DEFAULT_INC_ALLOC +size) == 0)
        __FERROR(f);
      base = HeapDeref(f->handle);
    }
  if (feof(f))
    (*(short*)base)++;

  if ((c=='\n' || c == '\r') && tmode)
    {
      poke(base + f->pos++, '\r');
      if (feof(f))
        (*(unsigned short*)base)++;
      poke(base + f->pos++, ' ');
    }
  else
    poke(base + f->pos++,c);

  if (feof(f) && tmode)
    {
      poke(base + f->pos,0);
      poke(base + f->pos+1,0xE0);
    }
  return c;
}

__ATTR_REG__ short fputs(const char *s, FILE *f)
{
  while (*s)
    fputc(*s++, f);
  return fputc('\n', f);
}

__ATTR_REG__ unsigned short fwrite(const char *ptr, unsigned short size, unsigned short n, FILE *f)
{
  fcheck(f);

  unsigned short num,j;
  short binmode = f->flags&_F_BIN;
  f->flags|=_F_BIN;
  for(num=0;num<n;num++)
    for(j=0;j<size;j++)
      if (fputc(*ptr++,f)<0)
        goto fwrite_error;
fwrite_error:
  f->flags&=binmode|(~_F_BIN);
  return num;
}


__ATTR_STK__ short fgetc(FILE *f)
{
  fcheck(f);

  short c;
  if (f->flags&_F_ERR)
    return -1;
  else if (!(f->flags&_F_READ))
    __FERROR(f);
  else if (f->ungetc < 0)
    {
      c = f->ungetc & 0x7FFF;
      f->ungetc = 0;
      return c;
    }
  else if (f->flags&_F_TERMINAL)
    {
      c = GetKey();
      PrintChar(c);
      return c;
    }
  // _F_NULL returns 1 for feof, so we don't need to handle it here.
  else if (feof(f))
    return -1;
  c = peek_b((char *)HeapDeref(f->handle)+(f->pos++));
  if(c=='\r' && ((f->flags&_F_BIN) == 0))
    if (!feof(f))
      f->pos++;
  return c;
}

__ATTR_REG__ unsigned short fread(unsigned char *ptr, unsigned short size, unsigned short n, FILE *f)
{
  fcheck(f);

  unsigned short num,j;
  short c,binmode=f->flags&_F_BIN;
  f->flags|=_F_BIN;
  for(num=0;num<n;num++)
    for(j=0;j<size;j++)
      {
        if ((c=fgetc(f))<0)
          goto fread_error;
        *ptr++=c;
      }
 fread_error:
  f->flags&=binmode|(~_F_BIN);
  return num;
}

__ATTR_REG__ char *fgets(char *s, short n, FILE *fp)
{
  fcheck(fp);

  /* In case of a terminal, use the function InputString from the Shell interface */
  if ((fp->flags&_F_TERMINAL)!=0) {
    InputString (s, n-1);
    return s;
  }

  short c = -1;
  char *cs=s;
  while(--n>0 && (c=fgetc(fp))>0)
    {
      if (c=='\r' && ((fp->flags&_F_BIN)==0))
        {
          *cs++ = '\n';
          break;
        }
      else if ((*cs++=c)=='\n')
        break;
    }
  *cs=0;
  return ((c<0 && cs==s)?NULL:s);
}

__ATTR_REG__ short ungetc(short c, FILE *f)
{
  fcheck(f);

  if (!(f->flags&_F_READ))
    __FERROR(f);
  if (f->ungetc <0)
    return -1;
  f->ungetc = c | 0x8000;
  return c;
}

__ATTR_REG__ short fflush(FILE *f)
{
  fcheck(f);

  if ((f->flags&_F_TERMINAL) && (f->flags&_F_READ))
    GKeyFlush();
  f->ungetc = 0;
  return 0;
}

__ATTR_REG__ void clearerr(FILE *f)
{
  fcheck(f);
  f->flags &= ~_F_ERR;
}

__ATTR_REG__ short ferror (const FILE *f)
{
  fcheck(f);
  return (((f)->flags)&_F_ERR);
}

__ATTR_REG__ void rewind (FILE *f)
{
  f->pos = (f->flags&_F_BIN?2:5);
  f->flags &= ~_F_ERR;
  f->ungetc = 0;
}

short fprintf(FILE *f, const char *fmt, ...)
{
  va_list a;
  int length;
  va_start(a, fmt);
  length = vcbprintf(fputc, f, fmt, a);
  va_end(a);
  return length;
}

char *tmpnam(char *out asm("a0"))
{
  char buffer[10], *s = buffer;
  *s++ = 0;
  do {
    /* Don't check if we do a loop, since Ti can't have 65536 files */
    sprintf(s, "temp%04x", TMPNAME_COUNT++);
  } while (SymFindPtr(s+8,0));
  return strcpy (out == 0 ? TMPNAME : out, s);
}

short unlink(const char *fname asm("a0"))
{
  char sym[20];
  EM_delSym(StrToTokN(fname,sym));
  return 0;
}

short rename(const char *old asm("a0"), const char *new asm("a1"))
{
  char sym1[20];
  char sym2[20];
  return SymMove(StrToTokN(old, sym1), StrToTokN(new, sym2) )-1;
}

/* Print the given data to a file (the filename is stored in the env variable system\linklog) */
void LinkLog (int mid, int cid, const unsigned int size, const unsigned char *data, int send0)
{
  const char *filename = getenv ("linklog");
  if (filename != NULL) {
    FILE *f = fopen (filename, "a");
    if (f != NULL) {
      fprintf (f, "MID=%02x CID=%02x SIZE=%u ", mid, cid, size);
      if (data != NULL && size > 0) {
	fprintf (f, "DATA=");
	if (send0)
	  fprintf (f, "00.00.00.00.");
        unsigned int i;
	for (i = 0; i < size; i++)
	  fprintf (f, "%02x.", (int) data[i]);
	fprintf (f, "CRC OK");
      }
      fprintf (f, "\n");
      fclose (f);
    }
  }
}
