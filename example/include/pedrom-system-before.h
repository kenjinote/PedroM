#ifdef NOSTUB
#error PedroM native format is Kernel mode! Remove _nostub definition.
#endif

#ifdef DOORS
#ifndef __PEDROM__BASE__
#error Please, do not use tigcc std headers if you want to create a PedroM program.
#endif
#endif

#ifndef __PEDROM__BASE__
#define __PEDROM__BASE__

/* if no target are defined, compiled for all calcs */
#if !defined(USE_TI92PLUS) && !defined(USE_TI89) && !defined(USE_V200) \
 && !defined(USE_TI89TI)
# define USE_TI92PLUS
# define USE_TI89
# define USE_V200
# define USE_TI89TI
#endif


#undef	NO_AMS_CHECK				/* Useless for PedroM */
#undef	NO_CALC_DETECT				/* Useless for Kernel mode */
#undef	EXECUTE_IN_GHOST_SPACE			/* Useless for PedroM */
#undef	USE_KERNEL
#undef  MIN_AMS

#undef	USE_FLINE_EMULATOR			/* Useless for Pedrom? */
#undef	USE_INTERNAL_FLINE_EMULATOR		/* Useless for PedroM */
#undef	RETURN_VALUE				/* Return value are not comaptible */

#define	NO_AMS_CHECK
#define	NO_CALC_DETECT
#define	USE_KERNEL
#define MIN_AMS 101
#define _NO_INCLUDE_PATCH
#define DOORS					/* To avoid double entry point */

#include <default.h>				/* Include std header from tigcc */
#include <romsymb.h>

extern	unsigned long pedrom__0000[];
extern  void pedrom__0001(void *adr asm("a0"));

/* int main(int argc, char *argv[]);
 * It doesn't work on PedroM 0.80 (the pushed args are wrong).
 * If you cared with PedroM 0.80 compatibility, run pedrom_0001 (main)
 * in _main section:
 * void _main (void) {pedrom_0001 (main);}
 * int main (int argc, const char *argv[]);
 */
#undef main
#undef _main
#define main _main

#endif						/* __PEDROM__BASE_ */
#ifndef __CTYPE_H
#define __CTYPE_H

#include <ped-base.h>

/* NOTE: These macros use GNU C extensions for defining safe and "smart" */
/* macros, so they are not portable to other C dialects                  */

extern char _extalnum_list[];
extern char _extpunct_list[];

#define _tolower(c) ((c)+'a'-'A')
#define _toupper(c) ((c)+'A'-'a')
#define isalnum(c) ({register short __c=(c);(__c>='0'&&__c<='9')||(__c>='A'&&__c<='Z')||(__c>='a'&&__c<='z');})
#define isalpha(c) ({register short __c=(c);(__c>='A'&&__c<='Z')||(__c>='a'&&__c<='z');})
#define isascii(c) ((unsigned short)(c)<128)
#define iscntrl(c) ((unsigned short)(c)<14)
#define isdigit(c) ({register short __c=(c);__c>='0'&&__c<='9';})
#define isextalnum(c) ({register short __c=(c);(unsigned short)__c<256&&_extalnum_list[__c>>3]&(1<<(__c&7));})
#define isextlower(c) ({register short __c=(c);(__c>='a'&&__c<='z')||(__c>=224&&__c<=254&&__c!=247);})
#define isextpunct(c) ({register short __c=(c);(unsigned short)__c<256&&_extpunct_list[__c>>3]&(1<<(__c&7));})
#define isextupper(c) ({register short __c=(c);(__c>='A'&&__c<='Z')||(__c>=192&&__c<=222&&__c!=215);})
#define isfrgn(c) ({register short __c=(c);(__c>=128&&__c<148)||(__c==181||__c>=192)&&(__c<=255&&__c!=215&&__c!=247);)}
#define isfrgnalnum(c) ({register short __c=(c);(__c>=128&&__c<=148&&__c!=140)||__c==181||(__c>=192&&__c<=255&&__c!=215&&__c!=247);})
#define isfrgnlower(c) ({register short __c=(c);__c>=224&&__c<=254&&__c!=247;})
#define isfrgnupper(c) ({register short __c=(c);__c>=192&&__c<=222&&__c!=215;})
#define isgraph(c) ({register short __c=(c);__c==11||(__c>13&&__c<256&&__c!=32);})
#define isGreek(c) ({register short __c=(c);(__c>=128&&__c<=148)||__c==181;})
#define islower(c) ({register short __c=(c);__c>='a'&&__c<='z';})
#define isprint(c) ({register short __c=(c);__c==11||(__c>13&&__c<256);})
#define ispunct(c) ({register short __c=(c);__c>=33&&__c<=127&&!((__c>='0'&&__c<='9')||(__c>='A'&&__c<='Z')||(__c>='a'&&__c<='z'));})
#define isspace(c) ({register short __c=(c);(__c>=9&&__c<=13)||__c==32;})
#define isupper(c) ({register short __c=(c);__c>='A'&&__c<='Z';})
#define isxdigit(c) ({register short __c=(c);(__c>='0'&&__c<='9')||(__c>='A'&&__c<='F')||(__c>='a'&&__c<='f');})
#define toascii(c) ((c)&0x7F)
#define toextlower(c) ({register short __c=(c);((__c>='A'&&__c<='Z')||(__c>=192&&__c<=222&&__c!=215))?(__c+'a'-'A'):__c;})
#define toextupper(c) ({register short __c=(c);((__c>='a'&&__c<='z')||(__c>=224&&__c<=254&&__c!=247))?(__c+'A'-'a'):__c;})
#define tolower(c) ({register short __c=(c);(__c>='A'&&__c<='Z')?(__c+'a'-'A'):__c;})
#define toupper(c) ({register short __c=(c);(__c>='a'&&__c<='z')?(__c+'A'-'a'):__c;})

#endif
#ifndef __ERRNO
#define __ERRNO

#include "ped-base.h"

#define errno (*(short *) pedrom__0000[5])

#define EDOM		1
#define ERANGE		2

#define E2BIG		3
#define EACCES		4
#define EAGAIN		5
#define EBADF		6
#define EBUSY		7
#define ECHILD		8
#define EDEADLK		9
#define EEXIST		10
#define EFAULT		11
#define EFBIG		12
#define EINTR		13
#define EINVAL		14
#define EIO		15
#define EISDIR		16
#define EMFILE		17
#define EMLINK		18
#define ENAMETOOLONG	19
#define ENFILE		20
#define ENODEV		21
#define ENOENT		22
#define ENOEXEC		23
#define ENOLCK		24
#define ENOMEM		25
#define ENOSPC		26
#define ENOSYS		27
#define ENOTDIR		28
#define ENOTEMPTY	29
#define ENOTTY		30
#define ENXIO		31
#define EPERM		32
#define EPIPE		33
#define EROFS		34
#define ESPIPE		35
#define ESRCH		36
#define EXDEV		37

#endif
#ifndef __FLOAT_H
#define __FLOAT_H

#include "ped-base.h"

/* Begin Auto-Generated Part */
#define DBL_DIG 16
#define DBL_EPSILON (1e-15)
#define DBL_MANT_BITS 64
#define DBL_MANT_DIG 16
#define DBL_MAX (9.999999999999999e999)
#define DBL_MAX_10_EXP 999
#define DBL_MAX_2_EXP 3321
#define DBL_MAX_EXP 999
#define DBL_MIN (1e-999)
#define DBL_MIN_10_EXP (-999)
#define DBL_MIN_2_EXP (-3318)
#define DBL_MIN_EXP (-999)
#define FLT_DIG 16
#define FLT_EPSILON (1e-15)
#define FLT_MANT_BITS 64
#define FLT_MANT_DIG 16
#define FLT_MAX (9.999999999999999e999)
#define FLT_MAX_10_EXP 999
#define FLT_MAX_2_EXP 3321
#define FLT_MAX_EXP 999
#define FLT_MIN (1e-999)
#define FLT_MIN_10_EXP (-999)
#define FLT_MIN_2_EXP (-3318)
#define FLT_MIN_EXP (-999)
#define FLT_NORMALIZE 1
#define FLT_RADIX 10
#define FLT_ROUNDS 1
#define LDBL_DIG 16
#define LDBL_EPSILON (1e-15)
#define LDBL_MANT_BITS 64
#define LDBL_MANT_DIG 16
#define LDBL_MAX (9.999999999999999e999)
#define LDBL_MAX_10_EXP 999
#define LDBL_MAX_2_EXP 3321
#define LDBL_MAX_EXP 999
#define LDBL_MIN (1e-999)
#define LDBL_MIN_10_EXP (-999)
#define LDBL_MIN_2_EXP (-3318)
#define LDBL_MIN_EXP (-999)
/* End Auto-Generated Part */

#endif
#ifndef __LIMITS
#define __LIMITS

#include "ped-base.h"

#ifdef __CHAR_UNSIGNED__
#define CHAR_MAX 255
#define CHAR_MIN 0
#else
#define CHAR_MAX 127
#define CHAR_MIN (-128)
#endif

#ifdef __INT_SHORT__
#define INT_MAX 0x7FFF
#define INT_MIN ((int)0x8000)
#define UINT_MAX 0xFFFFU
#else
#define INT_MAX 0x7FFFFFFFL
#define INT_MIN ((int)0x80000000L)
#define UINT_MAX 0xFFFFFFFFUL
#endif

/* Begin Auto-Generated Part */
#define CHAR_BIT 8
#define LONG_MAX 0x7FFFFFFFL
#define LONG_MIN ((long)0x80000000L)
#define SCHAR_MAX 127
#define SCHAR_MIN (-128)
#define SHRT_MAX 0x7FFF
#define SHRT_MIN ((short)0x8000)
#define UCHAR_MAX 255
#define ULONG_MAX 0xFFFFFFFFUL
#define USHRT_MAX 0xFFFFU
/* End Auto-Generated Part */

#endif
#ifndef __MATH
#define __MATH

#include <ped-base.h>

#define HALF_PI (1.570796326794897)
#define NAN (*(float*)&(bcd){0x7FFF,0xAA00000000000000ULL})
#define NEGATIVE_INF (1/NEGATIVE_ZERO)
#define NEGATIVE_ZERO (-POSITIVE_ZERO)
#define PI (3.141592653589793)
#define POSITIVE_INF (1/POSITIVE_ZERO)
#define POSITIVE_ZERO (1.e-8192*1.e-8192)
#define UNSIGNED_INF (1/UNSIGNED_ZERO)
#define UNSIGNED_ZERO (0.)
#define ZERO (0.)
#ifndef __HAVE_bcd
#define __HAVE_bcd
typedef struct{unsigned short exponent;unsigned long long mantissa;}bcd __attribute__((__may_alias__));
#endif
#define abs(x) ({typeof(x) __x = (x); __x >= 0 ? __x : -__x;})
#define acos(x) _tios_float_1(F5,x,float)
#define acosh(x) _tios_float_1(288,x,float)
#define asin(x) _tios_float_1(F6,x,float)
#define asinh(x) _tios_float_1(287,x,float)
#define atan2(x,y) _tios_float_2(F8,x,y,float,float)
#define atan(x) _tios_float_1(F7,x,float)
#define atanh(x) _tios_float_1(289,x,float)
#define cacos _rom_call(void,(float,float,float*,float*),13A)
#define cacosh _rom_call(void,(float,float,float*,float*),13D)
#define casin _rom_call(void,(float,float,float*,float*),13B)
#define casinh _rom_call(void,(float,float,float*,float*),13E)
#define catan _rom_call(void,(float,float,float*,float*),13C)
#define catanh _rom_call(void,(float,float,float*,float*),13F)
#define ccos _rom_call(void,(float,float,float*,float*),140)
#define ccosh _rom_call(void,(float,float,float*,float*),143)
#define ceil(x) _tios_float_1(105,x,float)
#define cexp _rom_call(void,(float,float,float*,float*),149)
#define cln _rom_call(void,(float,float,float*,float*),147)
#define clog10 _rom_call(void,(float,float,float*,float*),148)
#define cos(x) _tios_float_1(F9,x,float)
#define cosh(x) _tios_float_1(FC,x,float)
#define csin _rom_call(void,(float,float,float*,float*),141)
#define csinh _rom_call(void,(float,float,float*,float*),144)
#define csqrt _rom_call(void,(float,float,float*,float*),146)
#define ctan _rom_call(void,(float,float,float*,float*),142)
#define ctanh _rom_call(void,(float,float,float*,float*),145)
#define exp(x) _tios_float_1(FF,x,float)
#define fabs(x) _tios_float_1(106,x,float)
#define floor(x) _tios_float_1(107,x,float)
#define fmod(x,y) _tios_float_2(108,x,y,float,float)
#define hypot(x,y) ({float __x=(x),__y=(y);sqrt(fadd(fmul((__x),(__x)),fmul((__y),(__y))));})
#ifndef __HAVE_labs
#define __HAVE_labs
long labs(long)__ATTR_GCC__;
#endif
#define ldexp10(x,e) ({float __f=(x);((bcd*)&__f)->exponent+=(e);__f;})
#define log(x) _tios_float_1(100,x,float)
#define log10(x) _tios_float_1(101,x,float)
#define modf(x,y) _tios_float_2(102,x,y,float,float*)
#define pow(x,y) _tios_float_2(103,x,y,float,float)
#define sin(x) _tios_float_1(FA,x,float)
#define sinh(x) _tios_float_1(FD,x,float)
#define sqrt(x) _tios_float_1(104,x,float)
#define tan(x) _tios_float_1(FB,x,float)
#define tanh(x) _tios_float_1(FE,x,float)
#ifndef __HAVE_atof
#define __HAVE_atof
extern float atof(const char*)__ATTR_LIB_ASM__;
#endif
#define frexp10(x,y) _tios_float_2(2FB,x,y,float,__pshort)
#define is_inf _rom_call(short,(float),2FF)
#define is_nan _rom_call(short,(float),306)
#define is_nzero _rom_call(short,(float),300)
#define is_pzero _rom_call(short,(float),301)
#define is_sinf _rom_call(short,(float),302)
#define is_transfinite _rom_call(short,(float),303)
#define is_uinf_or_nan _rom_call(short,(float),304)
#define is_uzero _rom_call(short,(float),305)

#endif
#ifndef __SETJMP__
#define __SETJMP__

#include "ped-base.h"

typedef struct {
  unsigned long D2,D3,D4,D5,D6,D7;
  unsigned long A2,A3,A4,A5,A6,A7;
  unsigned long PC;
}JMP_BUF[1];

#define longjmp _rom_call(void,(void*,short),267)
#define setjmp _rom_call(short,(void*),266)

#define jmp_buf JMP_BUF

#endif
#ifndef __SIGNAL
#define __SIGNAL

#include "ped-base.h"

/* Signals.  */
#define	SIGINT		1	/* Interrupt (ANSI).  */
#define	SIGILL		2	/* Illegal instruction (ANSI).  */
#define	SIGABRT		3	/* Abort (ANSI).  */
#define	SIGFPE		4	/* Floating-point exception (ANSI).  */
#define	SIGSEGV		5	/* Segmentation violation (ANSI).  */
#define	SIGTERM		6	/* Termination (ANSI).  */

/* Fake signals */
#define SIG_ERR void (*-1)(int)
#define SIG_DFL void (* 0)(int)
#define SIG_IGN void (* 1)(int)

void (*signal(int sig asm("d0"), void (*fonc asm("a0"))(int)))(int);
int raise(int sig asm("d0"));

#endif /* __SIGNAL__*/
#ifndef __STDARG
#define __STDARG

#include "ped-base.h"

/* Begin Auto-Generated Part */
#ifndef __HAVE_va_list
#define __HAVE_va_list
typedef void*va_list;
#endif
#define va_arg(ap,type) (*(type*)(((*(char**)&(ap))+=((sizeof(type)+1)&0xFFFE))-(((sizeof(type)+1)&0xFFFE))))
#define va_end(ap) ((void)0)
#define va_start(ap,parmN) ((void)((ap)=(va_list)((char*)(&parmN)+((sizeof(parmN)+1)&0xFFFE))))
#define va_copy(d,a) ((d) = (a))

/* End Auto-Generated Part */

#endif
#ifndef __STDDEF
#define __STDDEF

#include "ped-base.h"

/* Begin Auto-Generated Part */
#define NULL ((void*)0)
#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif
#define offsetof(type,member) ((unsigned long)&(((type*)0)->member))
#define OFFSETOF offsetof
/* End Auto-Generated Part */

#endif
#ifndef __STDINT
#define __STDINT

#include "ped-base.h"

typedef signed char		int8_t;
typedef short int		int16_t;
typedef long int		int32_t;
typedef long long int		int64_t;

typedef unsigned char		uint8_t;
typedef unsigned short int	uint16_t;
typedef unsigned long int	uint32_t;
typedef unsigned long long int	uint64_t;

typedef signed char		int_least8_t;
typedef short int		int_least16_t;
typedef long int		int_least32_t;
typedef long long int		int_least64_t;

typedef unsigned char		uint_least8_t;
typedef unsigned short int	uint_least16_t;
typedef unsigned long int	uint_least32_t;
typedef unsigned long long int	uint_least64_t;

typedef signed char		int_fast8_t;
typedef short int		int_fast16_t;
typedef long int		int_fast32_t;
typedef long long int		int_fast64_t;

typedef unsigned char		uint_fast8_t;
typedef unsigned short int	uint_fast16_t;
typedef unsigned long int	uint_fast32_t;
typedef unsigned long long int	uint_fast64_t;

typedef long int		intptr_t;
typedef unsigned long int	uintptr_t;

typedef long long int		intmax_t;
typedef unsigned long long int	uintmax_t;

#if !defined __cplusplus || defined __STDC_LIMIT_MACROS

# define INT8_MIN		(-128)
# define INT16_MIN		(-32767-1)
# define INT32_MIN		(-2147483647L-1)
# define INT64_MIN		(-9223372036854775807LL-1)

# define INT8_MAX		(127)
# define INT16_MAX		(32767)
# define INT32_MAX		(2147483647L)
# define INT64_MAX		(9223372036854775807LL)

# define UINT8_MAX		(255)
# define UINT16_MAX		(65535)
# define UINT32_MAX		(4294967295UL)
# define UINT64_MAX		(18446744073709551615ULL)

# define INT_LEAST8_MIN		(-128)
# define INT_LEAST16_MIN	(-32767-1)
# define INT_LEAST32_MIN	(-2147483647L-1)
# define INT_LEAST64_MIN	(-9223372036854775807LL-1)

# define INT_LEAST8_MAX		(127)
# define INT_LEAST16_MAX	(32767)
# define INT_LEAST32_MAX	(2147483647L)
# define INT_LEAST64_MAX	(9223372036854775807LL)

# define UINT_LEAST8_MAX	(255)
# define UINT_LEAST16_MAX	(65535)
# define UINT_LEAST32_MAX	(4294967295U)
# define UINT_LEAST64_MAX	(18446744073709551615ULL)

# define INT_FAST8_MIN		(-128)
# define INT_FAST16_MIN		(-32767-1)
# define INT_FAST32_MIN		(-2147483647L-1)
# define INT_FAST64_MIN		(-9223372036854775807LL-1)

# define INT_FAST8_MAX		(127)
# define INT_FAST16_MAX		(32767)
# define INT_FAST32_MAX		(2147483647L)
# define INT_FAST64_MAX		(9223372036854775807LL)

# define UINT_FAST8_MAX		(255)
# define UINT_FAST16_MAX	(65535)
# define UINT_FAST32_MAX	(4294967295UL)
# define UINT_FAST64_MAX	(18446744073709551615ULL)

# define INTPTR_MIN		(-2147483647L-1)
# define INTPTR_MAX		(2147483647L)
# define UINTPTR_MAX		(4294967295UL)

# define INTMAX_MIN		(-9223372036854775807LL-1)
# define INTMAX_MAX		(9223372036854775807LL)
# define UINTMAX_MAX		(18446744073709551615ULL)

#endif

#if !defined __cplusplus || defined __STDC_CONSTANT_MACROS

# define INT8_C(c)	c
# define INT16_C(c)	c
# define INT32_C(c)	c ## L
# define INT64_C(c)	c ## LL

# define UINT8_C(c)	c ## U
# define UINT16_C(c)	c ## U
# define UINT32_C(c)	c ## UL
# define UINT64_C(c)	c ## ULL

# define INTMAX_C(c)	c ## LL
# define UINTMAX_C(c)	c ## ULL

#endif

#endif
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
#define tmpname pedrom__0019
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
#ifndef __STDLIB
#define __STDLIB

#include "ped-base.h"

#define NULL ((void*)0)
#define RAND_MAX 32767
typedef void(*atexit_t)(void);
typedef CALLBACK short(*compare_t)(const void*elem1,const void*elem2);
#ifndef __HAVE_div_t
#define __HAVE_div_t
typedef struct{short quot,rem;}div_t;
#endif
#ifndef __HAVE_ldiv_t
#define __HAVE_ldiv_t
typedef struct{long quot,rem;}ldiv_t;
#endif
#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif
#ifndef __HAVE_alloca
#define __HAVE_alloca
#define alloca __builtin__alloca
#endif

#define exit pedrom__002d
void	exit(int x asm("d0")) __ATTR_LIB_ASM_NORETURN__;
#define atexit pedrom__002e
short	atexit(atexit_t p asm("a0"));

static inline void abort ()
{ _rom_call(void,(const char*),E6)("ABNORMAL PROGRAM TERMINATION"); exit(1);}

#define ldiv(n,d) ({ldiv_t __r;long __n=(n),__d=(d);asm("move.l %2,%%d1;move.l %3,%%d0;jsr _ROM_CALL_2A8;move.l %%d1,%0;move.l %2,%%d1;move.l %3,%%d0;jsr _ROM_CALL_2A9;move.l %%d1,%1" : "=g"(__r.quot),"=g"(__r.rem) : "g"(__n),"g"(__d) : "a0","a1","d0","d1","d2");__r;})
#define div(n,d) ({short __n=(n),__d=(d);div_t __r;__r.quot=__n/__d;__r.rem=__n%__d;__r;})

/* atoi == atol: casting is ok :) */
#define atoi pedrom__0021
#define atol pedrom__0021
long atol (const char *str asm("a0")); 

#define bsearch pedrom__001e
void *bsearch(const void *key asm("a0"), const void *bptr asm("a1"), short n asm("d0"), short w asm("d1"), compare_t cmp_func asm("a2"));
#define qsort pedrom__001b
void qsort(void *list asm("a0"), short num_items asm("d0"), short size asm("d1"), compare_t cmp_func asm("a1"));

#define fabs(x) _tios_float_1(106,x,float)
#ifndef __HAVE_labs
#define __HAVE_labs
#define labs abs
#endif
#define abs(x) ({typeof(x) __x = (x); __x >= 0 ? __x : -__x;})
#define max(a,b) ({typeof(a) __a = (a); typeof(b) __b = (b); (__a > __b) ? __a : __b;})
#define min(a,b) ({typeof(a) __a = (a); typeof(b) __b = (b); (__a < __b) ? __a : __b;})

#define free _rom_call(void,(void*),A3)
#define malloc _rom_call(void*,(long),A2)
#ifndef __HAVE_realloc
#define __HAVE_realloc
#define realloc pedrom__0026
void	*realloc (void *Ptr asm("a0"), unsigned long NewSize asm("d1"));
#endif
#ifndef __HAVE_calloc
#define __HAVE_calloc
#define calloc pedrom__0025
void	*calloc (unsigned short NoOfItems asm("d0"), unsigned short SizeOfItems asm("d1"));
#endif

#define rand pedrom__0023
short rand(void);
#define srand pedrom__0024
void srand(long seed asm("d0"));
#define random(x) ((short)((long)(unsigned short)rand()*(unsigned short)(x)/32768))
#define randomize() srand(*(volatile char*)0x600017)

long strtol(const char*,char**,short)__ATTR_LIB_C__;
unsigned long strtoul(const char*,char**,short)__ATTR_LIB_C__;

#ifndef __HAVE_atof
#define __HAVE_atof
#define atof pedrom__0027
float atof(const char *str asm("a2"));
#endif

#define getenv pedrom__002A
const char *getenv(const char *name asm("a2"));

#define system pedrom__002b
int system(const char *command asm("a0"));
 
#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

#endif
#ifndef __STRING
#define __STRING

#include "ped-base.h"

/* Begin Auto-Generated Part */
#define NULL ((void*)0)
#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif
#define _memset _rom_call(void*,(void*,short,long),27B)
#define cmpstri _rom_call(short,(const unsigned char*,const unsigned char*),16F)
#define memchr _rom_call(void*,(const void*,short,long),273)
#define memcmp _rom_call(short,(const void*,const void*,long),270)
#define memcpy _rom_call(void*,(void*,const void*,long),26A)
#define memmove _rom_call(void*,(void*,const void*,long),26B)
#define memset _rom_call(void*,(void*,short,long),27C)
#define sprintf _rom_call_attr(short,(char*,const char*,...),__attribute__((__format__(__printf__,2,3))),53)
#define strcat _rom_call(char*,(char*,const char*),26E)
#define strchr _rom_call(char*,(const char*,short),274)
#define strcmp _rom_call(short,(const unsigned char*,const unsigned char*),271)
#define strcpy _rom_call(char*,(char*,const char*),26C)
#define strcspn _rom_call(unsigned long,(const char*,const char*),275)
#define strerror _rom_call(char*,(short),27D)
#define strlen _rom_call(unsigned long,(const char*),27E)
#define strncat _rom_call(char*,(char*,const char*,long),26F)
#define strncmp _rom_call(short,(const unsigned char*,const unsigned char*,long),272)
#define strncpy _rom_call(char*,(char*,const char*,long),26D)
#define strpbrk _rom_call(char*,(const char*,const char*),276)
#define strrchr _rom_call(char*,(const char*,short),277)
#define strspn _rom_call(unsigned long,(const char*,const char*),278)
#define strstr _rom_call(char*,(const char*,const char*),279)
#define strtok _rom_call(char*,(char*,const char*),27A)
/* End Auto-Generated Part */

#endif
#ifndef __TIME
#define __TIME

#include "ped_base.h"

#ifndef __HAVE_size_t
#define __HAVE_size_t
typedef unsigned long size_t;
#endif

typedef unsigned long clock_t;
typedef unsigned long time_t;
struct tm
{
  int	tm_sec;
  int	tm_min;
  int	tm_hour;
  int	tm_mday;
  int	tm_mon;
  int	tm_year;
  int	tm_wday;
  int	tm_yday;
  int	tm_isdst;
};

#define CLOCKS_PER_SEC 20
#define CLK_TCK CLOCKS_PER_SEC

#define clock() (*((volatile unsigned long*)__jmp_Tbl[0x4FC]) + 0)
#define time(_tp)  ({time_t _t = clock () / CLOCKS_PER_SEC; if (_tp) *(_tp) = _t; _t})
#define difftime(_t1,_t2) ((double) ((_t1)-(_t2)))

time_t    mktime(struct tm  *_t);
struct tm *gmtime(const time_t *_timer);

#define localtime gmtime

static char __time_buffer[30];
static const char *const __month[]= {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
static const char *const __day[]  = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};

#define asctime(_tptr) (sprintf(__time_buffer, "%s %s %d %2.2d:%2.2d:%2.2d %4.4d\n", __day[(_tptr)->tm_wday], __month[(_tptr)->tm_mon], (_tptr)->tm_mday, (_tptr)->tm_hour, (_tptr)->min, (_tptr)->sec, (_tptr)->tm_year+1900), __time_buffer)
#define ctime(_time) asctime(localtime(_time))

size_t	   strftime(char *_s, size_t _maxsize, const char *_fmt, const struct tm *_t);

#endif
