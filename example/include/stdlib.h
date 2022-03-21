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
