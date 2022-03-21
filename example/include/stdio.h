#ifndef __STDIO
#define __STDIO
#define __STDIO_H

#include "ped-base.h"

#ifndef __HAVE_CONSOLE
#define __HAVE_CONSOLE
asm (".xdef _flag_2");
#endif

typedef void (*vcbprintf_callback_t)(char,void**)__ATTR_TIOS_CALLBACK__;
typedef void (*__vcbprintf__type__)(vcbprintf_callback_t,void**,const char*,void*)__ATTR_TIOS__;

#define EOF (-1)
#define NULL ((void*)0)
#define TMP_MAX 65536
#define L_tmpnam 10
#define FILENAME_MAX	20
#define FOPEN_MAX	10

typedef void FILE;
enum SeekModes{SEEK_SET,SEEK_CUR,SEEK_END};
#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif

#ifndef __HAVE_va_list
#define __HAVE_va_list
typedef void*va_list;
#endif

#define clrscr pedrom__0006
void clrscr(void);

#define printf pedrom__0004
void printf(const char*,...)__ATTR_TIOS__;

#define stdin ((FILE*) pedrom__0000[0])
#define stdout ((FILE*) pedrom__0000[1])
#define stderr ((FILE*) pedrom__0000[2])

#define fopen pedrom__0009
FILE *fopen(const char *name asm("a0"), const char*mode asm("a1"));
#define fclose pedrom__0007
short fclose(FILE *stream asm("a0"));
#define freopen pedrom__0008
FILE *freopen(const char *filename asm("a0"), const char *mode asm("a1"), FILE *stream asm("a2"));

#define clearerr pedrom__0015
void clearerr (FILE *stream asm("a0")); 
#define feof pedrom__000c
short feof (const FILE *stream asm("a0"));
#define ferror pedrom__0016
short ferror (const FILE *stream asm("a0")); 
#define fflush pedrom__0014
short fflush (FILE *stream asm("a0"));
#define rewind pedrom__0017
void rewind (FILE *stream asm("a0"));
#define ungetc pedrom__0013
short ungetc (short c asm("d0"), FILE *stream asm("a0"));

#define fseek pedrom__000a
short fseek(FILE *f asm("a0"), long pos asm("d0"), short mode asm("d1"));
#define ftell pedrom__000b
long ftell(FILE *f asm("a0"));

#define fgetc pedrom__0010
short fgetc(FILE *stream) __ATTR_TIOS_CALLBACK__;
#define fgetchar() fgetc(stdin)
#define fgets pedrom__0012
char *fgets(char *s asm("a0"), short n asm("d0"), FILE *f asm("a1"));

#define fprintf pedrom__0018
short fprintf(FILE*,const char*,...)__ATTR_TIOS__;
#define fputc pedrom__000d
short fputc(short,FILE*)__ATTR_TIOS_CALLBACK__;
#define fputchar(v) fputc(v, stdout)
#define fputs pedrom__000e
short fputs(const char *str asm("a0"), FILE *f asm("a1"));

#define fread pedrom__0011
unsigned short fread(void *dest asm("a0"), short num asm("d0"), short size asm("d1"), FILE *f asm("a1"));
#define fwrite pedrom__000f
unsigned short fwrite(const void *src asm("a0"), short num asm("d0"), short size asm("d1"), FILE * asm("a1"));

#define getc fgetc
#define getchar fgetchar
#define gets(s) fgets(s, sizeof(s), stdin)
#define putc fputc
#define putchar fputchar
#define puts(s) fputs(s, stdout)

#define remove pedrom__001f
#define unlink pedrom__001f
short unlink(const char *asm("a0"));
#define rename pedrom__0020
short rename(const char *old asm("a0"), const char *new asm("a1"));
#define tmpnam pedrom__0019
char *tmpnam(char *dest asm("a0"));

#define sprintf _rom_call_attr(short,(char*,const char*,...),__attribute__((__format__(__printf__,2,3))),53)
#define strerror _rom_call(char*,(short),27D)

#define strputchar pedrom__0028
void strputchar(char,void**)__ATTR_TIOS_CALLBACK__;

#define vcbprintf pedrom__0005
short vcbprintf (vcbprintf_callback_t callback, void **param, const char *format, va_list arglist) __ATTR_TIOS__;

static inline short
vfprintf(FILE *s, const char *f, va_list a)
{ return vcbprintf((vcbprintf_callback_t)fputc,(void**)(s),(f),(a)); }
static inline short
vprintf(const char *f, va_list a)
{ return vcbprintf((vcbprintf_callback_t)fputc,(void**)stdout,(f),(a)); }
static inline short 
vsprintf(char *b, const char *f, va_list a)
{ void*__p=(b); int ret;
  ret = vcbprintf((vcbprintf_callback_t)strputchar,&__p,(f),(a));
  *(char*)__p=0;
  return ret;
}

static inline short
fgetpos(FILE *f, unsigned long *p)
{ return (((long)((*(p)=ftell(f))))==EOF); } 
static inline short
fsetpos(FILE *f, unsigned long *p)
{ return fseek((f),*(p),SEEK_SET); }

#define perror pedrom__0029
void perror(const char *str asm("a2"));

static inline FILE *
tmpfile (void)
{ return fopen(NULL, "rwb"); }

enum _setbufmode{_IOLBF=1,_IOFBF=2,_IONBF=3};
#define BUFSIZ 0

#define setvbuf pedrom__002c
int 
setvbuf(FILE *stream asm("a0"), char *buf asm("a1"), int mode asm("d0"), size_t size asm("d1"));

static inline int
setbuf (FILE *stream, char *buf)
{ return setvbuf(stream, buf, buf ? _IOFBF : _IONBF, BUFSIZ); }

static inline int
setlinebuf (FILE *stream)
{ return setvbuf(stream, (char*)0, _IOLBF, 0); }

static inline int
setbuffer (FILE *stream, char *buf, size_t s)
{ return setbuffer(stream,buf,s); }

#endif
