/*
* PedroM - Operating System for Ti-89/Ti-92+/V200.
* Copyright (C) 2003 - 2007 Patrick Pelissier
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
* if not, write to the* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifndef __PEDROM_INTERNAL
#define __PEDROM_INTERNAL

#define __PEDROM__BASE__

#ifdef	TI92P
# define USE_TI92PLUS
# define USE_V200
#else
# define USE_TI89
#endif

/* Define the internal macros of the system files
   so that they will beleive we have already included
   them */
#define __ALLOC
#define __ASSERT
#define __CTYPE_H
#define __DEFAULT_H
#define __LIMITS
#define __MATH
#define __SETJMP
#define __STDARG
#define __STDDEF
#define __STDINT
#define __STDIO
#define __STDLIB
#define __STRING
#define __ERRNO

/* For GMP */
#define _STDIO_H

/* Attribute for various functions */
#define __ATTR_STD__ __attribute__((__stkparm__))
#define __ATTR_STD_NORETURN__ __attribute__((__stkparm__,__noreturn__))
#define CALLBACK __ATTR_STD__
#define __ATTR_TIOS__ __ATTR_STD__
#define __ATTR_TIOS_NORETURN__ __ATTR_STD_NORETURN__
#define __ATTR_TIOS_CALLBACK__ CALLBACK
#define __ATTR_GCC__
#define __ATTR_LIB_C__ __attribute__((__regparm__(4)))
#define __ATTR_LIB_ASM__ __ATTR_STD__
#define __ATTR_LIB_ASM_NORETURN__ __ATTR_STD_NORETURN__
#define __ATTR_LIB_CALLBACK_C__ CALLBACK
#define __ATTR_LIB_CALLBACK_ASM__ CALLBACK
#define __ATTR_REG__ __attribute__((__regparm__(4)))
#define __ATTR_STK__ /*__attribute__((__stkparm__))*/

#define MIN(x,y) ((x) < (y) ? (x) : (y))
#define MAX(x,y) ((x) > (y) ? (x) : (y))


/* Define type, constant and variables */
typedef unsigned long size_t;
typedef void	*va_list;
#define va_arg(ap,type) (*(type*)((((char*)(ap))+=((sizeof(type)+1)&0xFFFE))-(((sizeof(type)+1)&0xFFFE))))
#define va_end(ap) ((void)0)
#define va_start(ap,parmN) ((void)((ap)=(va_list)((char*)(&parmN)+((sizeof(parmN)+1)&0xFFFE))))
#define va_copy(ap,ap2) ((ap) = (ap2))

typedef struct {
  unsigned short flags;
  unsigned short handle;
  unsigned long pos;
  short ungetc;
} FILE;
#define MAX_FILES 10
enum SeekModes{SEEK_SET,SEEK_CUR,SEEK_END};

#define stdin  (&FILE_TAB[0])
#define stdout (&FILE_TAB[1])
#define stderr (&FILE_TAB[2])

char *getenv(const char *name asm("a2"));

#define	EOF  (-1)
#define NULL  ((void*)0)
#define H_NULL 0
#define HS_NULL ((HSym) {0, 0})

typedef unsigned short HANDLE;

typedef char BOOL;

typedef struct {
  HANDLE folder;
  unsigned short offset;
} HSym;

typedef union {
 struct { unsigned char x0, y0, x1, y1; } xy;
 unsigned long l;
} SCR_RECT;

typedef struct {
  unsigned short exponent;
  unsigned long mantissa1;
  unsigned long mantissa2;
} bcd;

typedef struct {
  unsigned short sign;
  unsigned short exponent;
  unsigned long mantissa1;
  unsigned long mantissa2;
} internal_bcd;

typedef struct {
  unsigned short N;
  internal_bcd   x[];
} poly_bcd;

typedef struct {
  internal_bcd x;
  long	n;
} range_red;

typedef unsigned char ESQ;
typedef struct{unsigned short Size;ESQ Expr[];}MULTI_EXPR;
typedef const ESQ*CESI;
typedef ESQ*ESI;
typedef CESI SYM_STR;

enum Tags{VAR_NAME_TAG=0x00,_VAR_Q_TAG=0x01,VAR_R_TAG=0x02,VAR_S_TAG=0x03,VAR_T_TAG=0x04,VAR_U_TAG=0x05,VAR_V_TAG=0x06,VAR_W_TAG=0x07,VAR_X_TAG=0x08,VAR_Y_TAG=0x09,VAR_Z_TAG=0x0A,VAR_A_TAG=0x0B,VAR_B_TAG=0x0C,VAR_C_TAG=0x0D,VAR_D_TAG=0x0E,VAR_E_TAG=0x0F,VAR_F_TAG=0x10,VAR_G_TAG=0x11,VAR_H_TAG=0x12,VAR_I_TAG=0x13,VAR_J_TAG=0x14,VAR_K_TAG=0x15,VAR_L_TAG=0x16,VAR_M_TAG=0x17,VAR_N_TAG=0x18,VAR_O_TAG=0x19,VAR_P_TAG=0x1A,VAR_Q_TAG=0x1B,EXT_SYSTEM_TAG=0x1C,ARB_REAL_TAG=0x1D,ARB_INT_TAG=0x1E,POSINT_TAG=0x1F,NEGINT_TAG=0x20,POSFRAC_TAG=0x21,NEGFRAC_TAG=0x22,FLOAT_TAG=0x23,BCD_TAG=0x23,PI_TAG=0x24,EXP_TAG=0x25,IM_TAG=0x26,NEGINFINITY_TAG=0x27,INFINITY_TAG=0x28,PN_INFINITY_TAG=0x29,UNDEF_TAG=0x2A,FALSE_TAG=0x2B,TRUE_TAG=0x2C,STR_TAG=0x2D,NOTHING_TAG=0x2E,ACOSH_TAG=0x2F,ASINH_TAG=0x30,ATANH_TAG=0x31,COSH_TAG=0x35,SINH_TAG=0x36,TANH_TAG=0x37,ACOS_TAG=0x3B,ASIN_TAG=0x3C,ATAN_TAG=0x3D,RACOS_TAG=0x41,RASIN_TAG=0x42,RATAN_TAG=0x43,COS_TAG=0x44,SIN_TAG=0x45,TAN_TAG=0x46,ITAN_TAG=0x4A,ABS_TAG=0x4B,ANGLE_TAG=0x4C,CEILING_TAG=0x4D,FLOOR_TAG=0x4E,INT_TAG=0x4F,SIGN_TAG=0x50,SQRT_TAG=0x51,EXPF_TAG=0x52,LN_TAG=0x53,LOG_TAG=0x54,FPART_TAG=0x55,IPART_TAG=0x56,CONJ_TAG=0x57,IMAG_TAG=0x58,REAL_TAG=0x59,APPROX_TAG=0x5A,TEXPAND_TAG=0x5B,TCOLLECT_TAG=0x5C,GETDENOM_TAG=0x5D,GETNUM_TAG=0x5E,CUMSUM_TAG=0x60,DET_TAG=0x61,COLNORM_TAG=0x62,ROWNORM_TAG=0x63,NORM_TAG=0x64,MEAN_TAG=0x65,MEDIAN_TAG=0x66,PRODUCT_TAG=0x67,STDDEV_TAG=0x68,SUM_TAG=0x69,VARIANCE_TAG=0x6A,UNITV_TAG=0x6B,DIM_TAG=0x6C,MAT2LIST_TAG=0x6D,NEWLIST_TAG=0x6E,RREF_TAG=0x6F,REF_TAG=0x70,IDENTITY_TAG=0x71,DIAG_TAG=0x72,COLDIM_TAG=0x73,ROWDIM_TAG=0x74,TRANSPOSE_TAG=0x75,FACTORIAL_TAG=0x76,PERCENT_TAG=0x77,RADIANS_TAG=0x78,NOT_TAG=0x79,MINUS_TAG=0x7A,VEC_POLAR_TAG=0x7B,VEC_CYLIND_TAG=0x7C,VEC_SPHERE_TAG=0x7D,START_TAG=0x7E,ISTORE_TAG=0x7F,STORE_TAG=0x80,WITH_TAG=0x81,XOR_TAG=0x82,OR_TAG=0x83,AND_TAG=0x84,LT_TAG=0x85,LE_TAG=0x86,EQ_TAG=0x87,GE_TAG=0x88,GT_TAG=0x89,NE_TAG=0x8A,ADD_TAG=0x8B,ADDELT_TAG=0x8C,SUB_TAG=0x8D,SUBELT_TAG=0x8E,MUL_TAG=0x8F,MULELT_TAG=0x90,DIV_TAG=0x91,DIVELT_TAG=0x92,POW_TAG=0x93,POWELT_TAG=0x94,SINCOS_TAG=0x95,SOLVE_TAG=0x96,CSOLVE_TAG=0x97,NSOLVE_TAG=0x98,ZEROS_TAG=0x99,CZEROS_TAG=0x9A,FMIN_TAG=0x9B,FMAX_TAG=0x9C,COMPLEX_TAG=0x9D,POLYEVAL_TAG=0x9E,RANDPOLY_TAG=0x9F,CROSSP_TAG=0xA0,DOTP_TAG=0xA1,GCD_TAG=0xA2,LCM_TAG=0xA3,MOD_TAG=0xA4,INTDIV_TAG=0xA5,REMAIN_TAG=0xA6,NCR_TAG=0xA7,NPR_TAG=0xA8,P2RX_TAG=0xA9,P2RY_TAG=0xAA,P2PTHETA_TAG=0xAB,P2PR_TAG=0xAC,AUGMENT_TAG=0xAD,NEWMAT_TAG=0xAE,RANDMAT_TAG=0xAF,SIMULT_TAG=0xB0,PART_TAG=0xB1,EXP2LIST_TAG=0xB2,RANDNORM_TAG=0xB3,MROW_TAG=0xB4,ROWADD_TAG=0xB5,ROWSWAP_TAG=0xB6,ARCLEN_TAG=0xB7,NINT_TAG=0xB8,PI_PRODUCT_TAG=0xB9,SIGMA_SUM_TAG=0xBA,MROWADD_TAG=0xBB,ANS_TAG=0xBC,ENTRY_TAG=0xBD,EXACT_TAG=0xBE,LOGB_TAG=0xBF,COMDENOM_TAG=0xC0,EXPAND_TAG=0xC1,FACTOR_TAG=0xC2,CFACTOR_TAG=0xC3,INTEGRATE_TAG=0xC4,DIFFERENTIATE_TAG=0xC5,AVGRC_TAG=0xC6,NDERIV_TAG=0xC7,TAYLOR_TAG=0xC8,LIMIT_TAG=0xC9,PROPFRAC_TAG=0xCA,WHEN_TAG=0xCB,ROUND_TAG=0xCC,DMS_TAG=0xCD,LEFT_TAG=0xCE,RIGHT_TAG=0xCF,MID_TAG=0xD0,SHIFT_TAG=0xD1,SEQ_TAG=0xD2,LIST2MAT_TAG=0xD3,SUBMAT_TAG=0xD4,SUBSCRIPT_TAG=0xD5,RAND_TAG=0xD6,MIN_TAG=0xD7,MAX_TAG=0xD8,LIST_TAG=0xD9,USERFUNC_TAG=0xDA,MATRIX_TAG=0xDB,FUNC_TAG=0xDC,DATA_TAG=0xDD,GDB_TAG=0xDE,PIC_TAG=0xDF,TEXT_TAG=0xE0,FIG_TAG=0xE1,MAC_TAG=0xE2,EXT_TAG=0xE3,EXT_INSTR_TAG=0xE4,END_TAG=0xE5,COMMENT_TAG=0xE6,NEXTEXPR_TAG=0xE7,NEWLINE_TAG=0xE8,ENDSTACK_TAG=0xE9,PN1_TAG=0xEA,PN2_TAG=0xEB,ERROR_MSG_TAG=0xEC,EIGVC_TAG=0xED,EIGVL_TAG=0xEE,DASH_TAG=0xEF,LOCALVAR_TAG=0xF0,DESOLVE_TAG=0xF1,FDASH_TAG=0xF2,ASM_TAG=0xF3,ISPRIME_TAG=0xF4,OTH_TAG=0xF8,ROTATE_TAG=0xF9};

typedef struct {
  char name[8];
  unsigned short compat;
  union {
    unsigned short flags_n;
    struct {
      unsigned short busy : 1, local : 1, flag1_5 : 1, flag1_4 : 1, collapsed : 1, twin : 1, archived : 1, in_view : 1;
      unsigned short folder : 1, overwritten : 1, checked : 1, hidden : 1, locked : 1, statvar : 1, graph_ref_1 : 1, graph_ref_0 : 1;
    } bits;
  } flags;
  HANDLE handle;
} SYM_ENTRY;

enum SymFlags{SF_GREF1=0x0001,SF_GREF2=0x0002,SF_STATVAR=0x0004,SF_LOCKED=0x0008,SF_HIDDEN=0x0010,SF_OPEN=0x0010,SF_CHECKED=0x0020,SF_OVERWRITTEN=0x0040,SF_FOLDER=0x0080,SF_INVIEW=0x0100,SF_ARCHIVED=0x0200,SF_TWIN=0x0400,SF_COLLAPSED=0x0800,SF_LOCAL=0x4000,SF_BUSY=0x8000};

enum Attrs{A_REVERSE,A_NORMAL,A_XOR,A_SHADED,A_REPLACE,A_OR,A_AND,A_THICK1,A_SHADE_V,A_SHADE_H,A_SHADE_NS,A_SHADE_PS};
typedef struct{
  void*ScrAddr;
  unsigned char XMax,YMax;
  short CurFont,CurAttr,CurX,CurY;
  SCR_RECT CurClip;
}SCR_STATE;

typedef struct ErrorFrameStruct{
  unsigned long A2,A3,A4,A5,A6,A7;
  unsigned long D3,D4,D5,D6,D7;
  unsigned long NG_control;
  char*RetIndex;
  unsigned long PC;
  struct ErrorFrameStruct*Link;
}ERROR_FRAME[1];


/* Define constants */
#define	GET_XMAX (ScrRect.xy.x1)
#define	GET_YMAX (ScrRect.xy.y1)


#define TRUE	1
#define FALSE	0
#define LCD_MEM	((unsigned char *) 0x4c00)

#ifdef	TI92P
#	define LCD_WIDTH 	240
#	define LCD_HEIGHT	128
#else
#ifdef	TI89
#	define LCD_WIDTH 	160
#	define LCD_HEIGHT	100
#endif
#endif

#define APD_TIMER	2


/* Define global variables */
extern  short   errno;
extern	short	TabSize;
extern	int	ARGC;
extern	char   *ARGV[];
extern  FILE    FILE_TAB[MAX_FILES];

extern	const	SCR_RECT ScrRect;
extern	short	CURRENT_POINT_X,CURRENT_POINT_Y, SHELL_SAVE_Y_POS;
extern	char	HELP_BEING_DISPLAYED ;
extern	short	PRINTF_LINE_COUNTER;
extern	short	KEY_STATUS;
extern	char	KEY_MAJ;
extern  char    CURRENT_FONT;
extern	unsigned char	*CURRENT_SCREEN;
extern	short	CURRENT_INCY;
extern char TMPNAME[10];
extern unsigned short TMPNAME_COUNT;

extern	internal_bcd	FloatReg1;
extern	internal_bcd	FloatReg2;
extern	internal_bcd	FloatReg3;
extern	internal_bcd	FloatReg4;

extern	const	internal_bcd	FloatHalf;
extern	const	internal_bcd	FloatMinusHalf;
extern	const	internal_bcd	FloatSqrtHalf;
extern	const	internal_bcd	FloatOne;
extern	const	internal_bcd	FloatPosInfinity;
extern	const	internal_bcd	FloatNegInfinity;
extern	const	internal_bcd	FloatZero;
extern	const	internal_bcd	FloatPiDiv2;
extern	const	internal_bcd	FloatMinusOne;
extern	const	internal_bcd	FloatNAN;
extern	const	internal_bcd	FloatPi;


/* Dummy and stupid functions */
void	FloatAdjust(void);
#define FAdjust(x) ({FloatReg1 = x; FloatAdjust(); asm ("":::"d3","d4"); FloatReg1; })
void	FloatCheck(void);
#define FCheck(x) ({FloatReg1 = x; FloatCheck(); asm ("":::"d3","d4"); FloatReg1; })
void	FloatCeil(void);
#define FCeil(x) ({FloatReg1 = x; FloatCeil(); asm ("":::"d3","d4"); FloatReg1;})
char	FloatCmp(void);
#define FCmp(x,y) ({FloatReg1 = x; FloatReg2 = y; FloatCmp();})
char	FloatUCmp(void);
#define FUCmp(x,y) ({FloatReg1 = x; FloatReg2 = y; FloatUCmp();})
void	Int2Float(short n);
#define FFInt(n) ({Int2Float(n); asm("":::"d3","d4","d5"); FloatReg1;})
long	Float2Int(void);
#define FFloor(x) ({register long __temp; FloatReg1 = x; __temp = Float2Int(); asm("":::"d3","d4","d5"); __temp;})
void	FloatSub(void);
#define FSub(x,y) ({FloatReg1 = x; FloatReg2 = y; FloatSub(); asm("":::"d3","d4","d5","d6"); FloatReg1;})
void	FloatAdd(void);
#define FAdd(x,y) ({FloatReg1 = x; FloatReg2 = y; FloatAdd(); asm("":::"d3","d4","d5","d6"); FloatReg1;})
void	FloatPolyEval(const poly_bcd *p asm("a4"));
#define FPolyEval(p,x) ({FloatReg3 = x; FloatPolyEval(p); asm("":::"d3","d4","d5","d6","d7","a2","a3","a4","a5"); FloatReg1;})
void	FloatMult(void);
#define FMul(x,y) ({FloatReg3 = x; FloatReg4 = y; FloatMult(); asm("":::"d3","d4","d5","d6","d7","a2","a3"); FloatReg1;})
#define FSquare(x) FMul(x,x)
#define FSpike(x,y) FAdd(FMul(x,y),y)
void	FloatDivide(void);
#define FDiv(x,y) ({FloatReg4 = x; FloatReg3 = y; FloatDivide(); asm("":::"d3","d4","d5","d6","d7","a2","a3"); FloatReg1;})
void	FloatMult2(void);
#define FMult2(x) ({FloatReg1 = x; FloatMult2(); asm("":::"d3"); FloatReg1;})
long	FloatRangeReducByMod(const internal_bcd *ix asm("a5"), const internal_bcd *parms asm("a4"));
#define FRangeRedByMod(y,p) ({range_red r; r.n = FloatRangeReducByMod(&(y),p); asm("":::"d3","d4","d5","d6","a4"); r.x = FloatReg1; r;})
#define FIsZero(x) (x.exponent == 0x2000)
#define FIsInfiny(x) (x.exponent == 0x4000)
#define FIsPos(x) (x.sign == 0)
#define FIsGreaterThan10Pow(var,pow) ((var).exponent >= 0x4000 + (pow))
void	FloatSqrt(void);
#define FSqrt(x) ({FloatReg1 = x; FloatSqrt(); asm("":::"d3","d4","d5","d6","d7","a2","a3","a4","a5"); FloatReg1;})
void	FloatExp(void);
#define FExp(x) ({FloatReg1 = x; FloatExp(); FloatReg1;})
void	FloatLn(void);
#define FLn(x) ({FloatReg1 = x; FloatLn(); FloatReg1;})
void	Float10Pow(void);
#define FExp10(x) ({FloatReg1 = x; Float10Pow(); asm("":::"a2","a3","a4","d3","d4","d5","d6","d7"); FloatReg1;})
void	FloatLog10(void);
#define FLn10(x) ({FloatReg1 = x; FloatLog10(); asm("":::"a2","a3","a4","d3","d4","d5","d6","d7"); FloatReg1;})
void	FloatPow(void);
#define FPow(x,y) ({FloatReg1 = x; FloatReg2 = y; FloatPow(); FloatReg1;})

# define M_PI           3.14159265358979323846  /* pi */
# define M_PI_2         1.57079632679489661923  /* pi/2 */
# define M_PI_4         0.78539816339744830962  /* pi/4 */
# define M_E            2.7182818284590452354   /* e */

#define isnan(d) ((d) != (d))

void	      DrawChar(short,short,short,short);
unsigned char FontGetSys(void);
short	      FontCharWidth (short c);
void	      ScrRectScroll (const SCR_RECT *rect, const SCR_RECT *clip, short NumRows, short Attr);
void	      ScreenClear(void);
void	      ST_busy (short mode);
short	      PrintChar(short c);
void	      ST_eraseHelp (void);

void          off (void);

short         OSdequeue (unsigned short *dest, void *Queue);
short         OSTimerExpired (short timer_no);
unsigned long OSTimerRestart (short timer_no);
short         OSInitKeyInitDelay (short delay);
short         OSInitBetweenKeyDelay (short rate);

void          HeapFree (HANDLE Handle);
HANDLE        HeapRealloc (HANDLE Handle, unsigned long NewSize);
HANDLE        HeapRealloc2 (HANDLE Handle, unsigned long NewSize);
HANDLE        HeapAlloc (unsigned long Size);
void         *HeapDeref (HANDLE Handle);
void         *HeapAllocPtr (unsigned long Size);
void          HeapFreePtr(void *ptr);
HANDLE        HeapUnlock (HANDLE Handle);
unsigned long HeapSize (HANDLE Handle);
int           HeapGetLock (HANDLE);
void         *HLock (HANDLE);
void          HeapLock (HANDLE);

SYM_ENTRY    *SymFindPtr (SYM_STR SymName, unsigned short Flags);
ESI           HToESI (HANDLE Handle);
HSym          SymAdd (SYM_STR SymName);
SYM_ENTRY    *DerefSym (HSym Sym);
short         SymDel (SYM_STR SymName);
short         EM_moveSymFromExtMem (SYM_STR SymName, HSym Sym);
short         EM_moveSymToExtMem (SYM_STR SymName, HSym Sym);
void          EM_delSym (SYM_STR SymName);
short         SymMove (SYM_STR SrcName, SYM_STR DestName);
ESI           StrToTokN (const char *src, unsigned char *dest);
unsigned short TokenizeName (const char *srcFile, unsigned char *destTokn);

short	      ngetchx (void);
short	      GetKey (void);
void	     *kbd_queue(void);
void          pushkey (short code);
void          GKeyFlush (void);

short         push_parse_text (const char *str);
void          NG_execute (HANDLE Handle, short approx_flag);
HANDLE        HS_popEStack (void);

short         _sputc(short ch, FILE *fp);
int	      PID_Switch(long flags asm("d0"), short pid asm("d1"), const char *str asm("a0"), void (*killfunc)(void) asm("a1"));
int	      PID_CheckSwitch(short key asm("d0"), const char *str asm("a0"));



#define peek_b(addr) (*((unsigned char*)(long)(addr)))
#define peek_bit(addr,bit) (!!(*((unsigned char*)(long)(addr))&(1<<(bit))))
#define peek_l(addr) (*((unsigned long*)(long)(addr)))
#define peek_w(addr) (*((unsigned short*)(long)(addr)))
#define peekIO(port) (*((volatile unsigned char*)(long)(port)))
#define peekIO_bit(port,bit) (!!(*((volatile unsigned char*)(long)(port))&(1<<(bit))))
#define peekIO_w(port) (*((volatile unsigned short*)(long)(port)))
#define poke(addr,val) (void)(*((unsigned char*)(long)(addr))=(val))
#define poke_bclr(__dest_addr__,__bit_nr__) ({register char *__addr_temp__=(char *)(__dest_addr__);asm("bclr.b %2,%0":"+dm"(*__addr_temp__):"0"(*__addr_temp__),"di"(__bit_nr__));})
#define poke_bset(__dest_addr__,__bit_nr__) ({register char *__addr_temp__=(char *)(__dest_addr__);asm("bset.b %2,%0":"+dm"(*__addr_temp__):"0"(*__addr_temp__),"di"(__bit_nr__));})
#define poke_l(addr,val) (void)(*((unsigned long*)(long)(addr))=(val))
#define poke_w(addr,val) (void)(*((unsigned short*)(long)(addr))=(val))
#define pokeIO(port,val) (void)(*((volatile unsigned char*)(long)(port))=(val))
#define pokeIO_bclr(__dest_addr__,__bit_nr__) ({register char *__addr_temp__=(char *)(__dest_addr__);asm("bclr.b %2,%0":"+dm"(*__addr_temp__):"0"(*__addr_temp__),"di"(__bit_nr__));})
#define pokeIO_bset(__dest_addr__,__bit_nr__) ({register char *__addr_temp__=(char *)(__dest_addr__);asm("bset.b %2,%0":"+dm"(*__addr_temp__):"0"(*__addr_temp__),"di"(__bit_nr__));})
#define pokeIO_w(port,val) (void)(*((volatile unsigned short*)(long)(port))=(val))
#define speek(addr) (*((signed char*)(long)(addr)))
#define speek_l(addr) (*((signed long*)(long)(addr)))
#define speek_w(addr) (*((signed short*)(long)(addr)))

short   ER_catch (void *ErrorFrame);
void    ER_success (void);
void    ER_throw (short err_no);
#define TRY {ERROR_FRAME __errFrame;unsigned short errCode;errCode=ER_catch(__errFrame);if(!errCode){
#define ONERR ER_success();}else{register short _ONERR_=1;
#define ENDTRY ;_ONERR_=0;}}


void	BitmapInit(const SCR_RECT *rect, short *BitMap);
void	ScrRectFill (const SCR_RECT *rect, const SCR_RECT *clip, short Attr);
short   ScrRectOverlap (const SCR_RECT *r1, const SCR_RECT *r2, SCR_RECT *r);
void    SaveScrState (void *buffer);
void    RestoreScrState (const void *buffer);
void    PortSet (void *vm_addr, short x_max, short y_max);
void    PortRestore (void);

void    idle (void);



/* ctypes.h */
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


/* string.h */
void *memset (void *buffer, short c, unsigned long num);
void *memchr (const void *str, short c, unsigned long len);
int memcmp (const void *s1, const void *s2, unsigned long len);
void *memcpy (void *dest, const void *src, unsigned long len);
void *memmove (void *dest, const void *src, unsigned long len);
char *strcat (char *dest, const char *src);
unsigned long strlen (const char *str);
char *strchr (const char *str, short c);
char *strrchr(const char *, short);
int strcmp (const char *s1, const char *s2);
char *strstr (const char *s1, const char *s2);
char *strcpy (char *dest, const char *src);
char *strncat (char *dest, const char *src, unsigned long maxlen);
int strncmp (const char *s1, const char *s2, unsigned long maxlen);
char *strncpy (char *dest, const char *src, unsigned long maxlen);
char *strpbrk (const char *s1, const char *s2);


/* stdlib.h */
int system(const char *command asm("a0"));
#define malloc(x) HeapAllocPtr(x)
#define free(x)   HeapFreePtr(x)
#define alloca __builtin_alloca
short	atoi (const char *str asm("a0"));
long    atol(const char *str asm("a0"));
float   atof (const char *s asm("a2"));
void	*realloc (void *Ptr asm("a0"), unsigned long NewSize asm("d1"));

/* stdio */
#define fputchar(c) fputc(c, stdout)
#define putchar(c) fputc(c, stdout)
#define putc fputc

#define clrscr ScreenClear
__ATTR_REG__ short fclose(FILE *f);
__ATTR_REG__ FILE *freopen(const char *name, const char *mode, FILE *f);
__ATTR_REG__ FILE *fopen(const char *name, const char *mode);
__ATTR_REG__ short fseek(FILE *f, long offset, short wh);
__ATTR_REG__ long ftell(FILE *f);
__ATTR_REG__ short feof(const FILE *f);
__ATTR_STK__ short fputc(short c, FILE *f);
__ATTR_REG__ short fputs(const char *s, FILE *f);
__ATTR_REG__ unsigned short fwrite(const char *ptr, unsigned short size, unsigned short n, FILE *f);
__ATTR_STK__ short fgetc(FILE *f);
__ATTR_REG__ unsigned short fread(unsigned char *ptr, unsigned short size, unsigned short n, FILE *f);
__ATTR_REG__ char *fgets(char *s, short n, FILE *fp);
__ATTR_REG__ short ungetc(short c, FILE *f);
__ATTR_REG__ short fflush(FILE *f);
__ATTR_REG__ void clearerr(FILE *f);
__ATTR_REG__ short ferror (const FILE *f);
__ATTR_REG__ void rewind (FILE *f);
#define getc fgetc
#define puts(s) fputs((s),stdout)

int sprintf (char *buffer, const char *format, ...);
//short vsprintf (char *buffer, const char *format, va_list arglist);
int printf (const char *format, ...);

int vcbprintf (short (*callback)(short,FILE *), FILE *p, const char *fmt, va_list args);
short fprintf(FILE *f, const char *fmt, ...);
static inline int vfprintf(FILE *s, const char *f, va_list a) {
  return vcbprintf((short (*)(short,FILE*))fputc,(s),(f),(a));
}
//#define vfprintf(s,f,a) vcbprintf((short (*)(short,FILE*))fputc,(void**)(s),(f),(a))
//#define vprintf(f,a) vcbprintf(((short (*)(short,FILE*)))fputc,stdout,(f),(a))
//#define vsprintf(b,f,a) ((void)({void*__p=(b);vcbprintf(((short (*)(short,FILE*)))_sputc,&__p,(f),(a)); *(char*)__p=0;}))

char *tmpnam(char *s asm("a0"));

#define setbuf(f,b) /* nothing */

short unlink(const char *fname asm("a0"));
#define remove unlink

/* Define the assert header */
#define assert(p) ((void)0)


/* Define the Limits header */
#ifdef __CHAR_UNSIGNED__
#define CHAR_MAX 255
#define CHAR_MIN 0
#else
#define CHAR_MAX 127
#define CHAR_MIN (-128)
#endif

#ifdef __INT_SHORT__
#define INT_MAX 32767
#define INT_MIN (-32767 - 1)
#define UINT_MAX 0xFFFFU
#else
#define INT_MAX 0x7FFFFFFFL
#define INT_MIN ((int)0x80000000L)
#define UINT_MAX 0xFFFFFFFFUL
#endif

#define CHAR_BIT 8
#define LONG_MAX 2147483647
#define LONG_MIN (-2147483647 - 1)
#define SCHAR_MAX 127
#define SCHAR_MIN (-128)
#define SHRT_MAX 32767
#define SHRT_MIN (-32767 - 1)
#define UCHAR_MAX 255
#define ULONG_MAX 0xFFFFFFFFUL
#define USHRT_MAX 0xFFFFU


/* Setjump */
typedef struct {
  unsigned long D2,D3,D4,D5,D6,D7;
  unsigned long A2,A3,A4,A5,A6,A7;
  unsigned long PC;
} JMP_BUF[1];
#define jmp_buf JMP_BUF
void __attribute__((__noreturn__)) longjmp (void *, short);
short setjmp (void *);

#define offsetof(type,member) ((unsigned long)&(((type*)0)->member))


/* stdint.h */
typedef signed char             int8_t;
typedef short int               int16_t;
typedef long int                int32_t;
typedef long long int           int64_t;

typedef unsigned char           uint8_t;
typedef unsigned short int      uint16_t;
typedef unsigned long int       uint32_t;
typedef unsigned long long int  uint64_t;

typedef signed char             int_least8_t;
typedef short int               int_least16_t;
typedef long int                int_least32_t;
typedef long long int           int_least64_t;

typedef unsigned char           uint_least8_t;
typedef unsigned short int      uint_least16_t;
typedef unsigned long int       uint_least32_t;
typedef unsigned long long int  uint_least64_t;

typedef signed char             int_fast8_t;
typedef short int               int_fast16_t;
typedef long int                int_fast32_t;
typedef long long int           int_fast64_t;

typedef unsigned char           uint_fast8_t;
typedef unsigned short int      uint_fast16_t;
typedef unsigned long int       uint_fast32_t;
typedef unsigned long long int  uint_fast64_t;

typedef long int                intptr_t;
typedef unsigned long int       uintptr_t;
typedef long int                ptrdiff_t;

typedef long long int           intmax_t;
typedef unsigned long long int  uintmax_t;
# define INT8_MIN               (-128)
# define INT16_MIN              (-32767-1)
# define INT32_MIN              (-2147483647L-1)
# define INT64_MIN              (-9223372036854775807LL-1)

# define INT8_MAX               (127)
# define INT16_MAX              (32767)
# define INT32_MAX              (2147483647L)
# define INT64_MAX              (9223372036854775807LL)

# define UINT8_MAX              (255)
# define UINT16_MAX             (65535)
# define UINT32_MAX             (4294967295UL)
# define UINT64_MAX             (18446744073709551615ULL)

# define INT_LEAST8_MIN         (-128)
# define INT_LEAST16_MIN        (-32767-1)
# define INT_LEAST32_MIN        (-2147483647L-1)
# define INT_LEAST64_MIN        (-9223372036854775807LL-1)

# define INT_LEAST8_MAX         (127)
# define INT_LEAST16_MAX        (32767)
# define INT_LEAST32_MAX        (2147483647L)
# define INT_LEAST64_MAX        (9223372036854775807LL)

# define UINT_LEAST8_MAX        (255)
# define UINT_LEAST16_MAX       (65535)
# define UINT_LEAST32_MAX       (4294967295U)
# define UINT_LEAST64_MAX       (18446744073709551615ULL)

# define INT_FAST8_MIN          (-128)
# define INT_FAST16_MIN         (-32767-1)
# define INT_FAST32_MIN         (-2147483647L-1)
# define INT_FAST64_MIN         (-9223372036854775807LL-1)

# define INT_FAST8_MAX          (127)
# define INT_FAST16_MAX         (32767)
# define INT_FAST32_MAX         (2147483647L)
# define INT_FAST64_MAX         (9223372036854775807LL)

# define UINT_FAST8_MAX         (255)
# define UINT_FAST16_MAX        (65535)
# define UINT_FAST32_MAX        (4294967295UL)
# define UINT_FAST64_MAX        (18446744073709551615ULL)

# define INTPTR_MIN             (-2147483647L-1)
# define INTPTR_MAX             (2147483647L)
# define UINTPTR_MAX            (4294967295UL)
# define INTMAX_MIN             (-9223372036854775807LL-1)
# define INTMAX_MAX             (9223372036854775807LL)
# define UINTMAX_MAX            (18446744073709551615ULL)

# define INT8_C(c)      c
# define INT16_C(c)     c
# define INT32_C(c)     c ## L
# define INT64_C(c)     c ## LL

# define UINT8_C(c)     c ## U
# define UINT16_C(c)    c ## U
# define UINT32_C(c)    c ## UL
# define UINT64_C(c)    c ## ULL

# define INTMAX_C(c)    c ## LL
# define UINTMAX_C(c)   c ## ULL

# define  SIZE_MAX (((1UL << 31) - 1) * 2 + 1)

/* Stdlib */
typedef void(*atexit_t)(void);
typedef CALLBACK short(*compare_t)(const void*elem1,const void*elem2);
void	exit(int x asm("d0")) __ATTR_LIB_ASM_NORETURN__;
short	atexit(atexit_t asm("a0"));
static inline int abs (int x) { return x < 0 ? -x : x; }
static inline void abort (void) { exit (-1); }
long int strtol(const char *, char **, short )__ATTR_LIB_C__;
unsigned long int strtoul(const char *, char **, short )__ATTR_LIB_C__;
void *calloc (unsigned short asm("d0"), unsigned short asm("d1"));
void qsort(void *list asm("a0"), short num_items asm("d0"), short size asm("d1"), compare_t cmp_func asm("a1"));
void *bsearch(const void *key asm("a0"), const void *bptr asm("a1"), short n asm("d0"), short w asm("d1"), compare_t cmp_func asm("a2"));


/* To implement */
int scanf(const char *, ...);
int fscanf(FILE *, const char *, ...);
int sscanf(const char *, const char *, ...);
int vscanf(const char *, va_list);
int vsscanf(const char *, const char *, va_list);
int vfscanf(FILE *, const char *, va_list);

static inline char *strdup(const char *s) {
  unsigned long size = strlen(s)+1;
  char *tmp = malloc (size);
  memcpy (tmp, s, size);
  return tmp;
}

/* Signal */
#define raise(x) (*(char*)0 = 0)

unsigned short InputString (char *string asm("a0"), unsigned short size asm("d3"));

#endif
