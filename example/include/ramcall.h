#ifndef __RAMCALL_H
#define __RAMCALL_H

#include "ped-base.h"
#include <vat.h>

extern void
	_RAM_CALL_0,_RAM_CALL_1,_RAM_CALL_2,_RAM_CALL_3,
	_RAM_CALL_4,_RAM_CALL_5,_RAM_CALL_6,_RAM_CALL_7,
	_RAM_CALL_8,_RAM_CALL_9,_RAM_CALL_A,_RAM_CALL_B,
	_RAM_CALL_C,_RAM_CALL_D,_RAM_CALL_E,_RAM_CALL_F,
	_RAM_CALL_10,_RAM_CALL_11,_RAM_CALL_12,_RAM_CALL_13,
	_RAM_CALL_14,_RAM_CALL_21,_RAM_CALL_22,_RAM_CALL_23,
	_RAM_CALL_24,_RAM_CALL_25,_RAM_CALL_26,_RAM_CALL_27,
	_RAM_CALL_28,_RAM_CALL_2D,_RAM_CALL_2E;

#define __RAM_CALL(n,type) ((type)&_RAM_CALL_##n)

#undef __CALCULATOR
#undef CALCULATOR
#undef HW_VERSION
#undef EMULATOR
#undef font_medium
#undef font_small
#undef font_large
#undef	LCD_MEM
#undef LCD_WIDTH
#undef LCD_HEIGHT
#undef LCD_LINE_BYTES
#undef LCD_SIZE
#undef	ROM_BASE
#undef	RETURN_VALUE
#undef Heap
#undef FOLDER_LIST_HANDLE
#undef MainHandle
#undef ROM_VERSION
#undef kb_globals
#undef KEY_PRESSED_FLAG
#undef GETKEY_CODE
#undef KEY_LEFT
#undef KEY_RIGHT
#undef KEY_UP
#undef KEY_DOWN
#undef KEY_UPRIGHT
#undef KEY_DOWNLEFT
#undef KEY_DIAMOND
#undef KEY_SHIFT
#undef	ROM_BASE
#undef	GHOST_SPACE
#undef Idle

/* Define Kernel values -- pass 2 */
#define __CALCULATOR    __RAM_CALL(0, const unsigned char*)
#define CALCULATOR	(__CALCULATOR[0])
#define HW_VERSION	(__CALCULATOR[1])
#define EMULATOR	(__CALCULATOR[3])
#define font_medium	__RAM_CALL(E, const void*)
#define font_small	__RAM_CALL(22, const void*)
#define font_large	__RAM_CALL(23, const void *)
#define	LCD_MEM		__RAM_CALL(21, void*)
#define LCD_WIDTH	__RAM_CALL (1, unsigned long)
#define LCD_HEIGHT	__RAM_CALL (2, unsigned long)
#define LCD_LINE_BYTES	__RAM_CALL (4, unsigned long)
#define LCD_SIZE	__RAM_CALL (C, unsigned long)
#define	ROM_BASE	__RAM_CALL(3, unsigned char *)
#define	RETURN_VALUE	(*(unsigned char **)_RAM_CALL_F = *(unsigned char **)_ROM_CALL_109)
#define Heap		__RAM_CALL(11, void***)
#define FOLDER_LIST_HANDLE __RAM_CALL (12, unsigned long)
#define MainHandle	__RAM_CALL (13, unsigned long)
#define ROM_VERSION	__RAM_CALL (14, unsigned long)
#define kb_globals	__RAM_CALL(10, void*)
#define KEY_PRESSED_FLAG (*(unsigned short*)(kb_globals+0x1C))
#define GETKEY_CODE	(*(unsigned short*)(kb_globals+0x1E))
#define KEY_LEFT	__RAM_CALL(5, unsigned long)
#define KEY_RIGHT	__RAM_CALL(6, unsigned long)
#define KEY_UP		__RAM_CALL(7, unsigned long)
#define KEY_DOWN	__RAM_CALL(8, unsigned long)
#define KEY_UPRIGHT	__RAM_CALL(9, unsigned long)
#define KEY_DOWNLEFT	__RAM_CALL(A, unsigned long)
#define KEY_DIAMOND	__RAM_CALL(B, unsigned long)
#define KEY_SHIFT	__RAM_CALL(D, unsigned long)
#define	ROM_BASE	__RAM_CALL(3, unsigned char *)
#define	GHOST_SPACE	__RAM_CALL(2D, unsigned char *)
#define	KERNEL_SPACE	__RAM_CALL(2E, unsigned char *)

/* Define kernel functions */
#define	Idle		_RAM_CALL_15
#define kernel_Idle 	Idle
extern	void	Idle(void);
#define	kernel_Exec	_RAM_CALL_16
extern	short kernel_Exec(HANDLE hd asm("d0"));
#define	kernel_Ptr2Hd	_RAM_CALL_17
extern	HANDLE kernel_Ptr2Hd(void *ptr asm("a0"));
#define	kernel_Hd2Sym	_RAM_CALL_18
extern	SYM_ENTRY *kernel_Hd2Sym(HANDLE hd asm("d0"));
typedef	struct _LibRef LibRef;
#define	kernel_LibsBegin _RAM_CALL_19
LibRef *kernel_LibsBegin(char *libname asm("a0"), unsigned char version asm("d1"));
#define kernel_LibsEnd	_RAM_CALL_1A
void kernel_LibsEnd(LibRef *lib asm("a0"));
#define	kernel_LibsPtr	_RAM_CALL_1C
void *kernel_LibsPtr(LibRef *lib asm("a0"), short function asm("d0"));
#define	kernel_LibsCall	_RAM_CALL_1B
__attribute__((__stkparm__)) unsigned long kernel_LibsCall(LibRef *lib, short function, ...);
#define	kernel_LibsExec	_RAM_CALL_1D
__attribute__((__stkparm__)) void kernel_LibsExec(char *name, short function, char version, ...);
#define	kernel_HdKeep	_RAM_CALL_1E
void	kernel_HdKeep(HANDLE hd asm("d0"));
#define	kernel_ExtractFromPack	_RAM_CALL_1F
HANDLE	kernel_ExtractFromPack(void *pack asm("a5"), short index asm("d0"));
#define	kernel_ExtractFile	_RAM_CALL_20
HANDLE	kernel_ExtractFile(const char *name asm("a2"));
#define	kernel_ExtractFileFromPack	_RAM_CALL_29
HANDLE	kernel_ExtractFileFromPack(HANDLE hd asm("d0"), const char *name asm("a2"));
#define	exit	_RAM_CALL_2A
void	exit(int c asm("d0"));
#define	atexit	_RAM_CALL_2B
int	atexit(void (*func)(void) asm("a0"));
#define kernel_RegisterVector _RAM_CALL_2C
void	kernel_RegisterVector (unsigned short vect asm("d0"), const void *func asm("a0"));
#define kernel_SystemDir _RAM_CALL_2F
extern const char kernel_SystemDir[];

#endif
