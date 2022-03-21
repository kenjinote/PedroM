;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003, 2005-2008 Patrick Pelissier
;
; This program is free software ; you can redistribute it and/or modify it under the
; terms of the GNU General Public License as published by the Free Software Foundation;
; either version 2 of the License, or (at your option) any later version. 
; 
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the GNU General Public License for more details. 
; 
; You should have received a copy of the GNU General Public License along with this program;
; if not, write to the 
; Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 

	include "Const.h"
	
        ;; Exported FUNCTIONS: 
        xdef RAM_TABLE
        xdef KernelReinit
        xdef ExtractPPG
	xdef start_kernel_prgm
	xdef reloc
	xdef reloc2
	xdef unreloc
	xdef unreloc2
	
;******************************************************************
;***                                                            ***
;***            	Kernel routines				***
;***                                                            ***
;******************************************************************

MAX_HANDLES	EQU	HANDLE_MAX		; # of handles to save (Useless)
MAX_RAMCALL	EQU	$30			; # of RAMCALLS
ROM_VECTOR	EQU	ROM_BASE+$012088

	;; This TABLE shall remain compatible with PreOS Kernel.
RAM_TABLE:
	dc.l	CALCULATOR
	ifd	PEDROM_92
		dc.l	240,128,ROM_BASE,30
		dc.l	KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,342,345,$2000,3840,$4000
	endif
	ifd	PEDROM_89
		dc.l	160,100,ROM_BASE,20
		dc.l	KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,345,342,$2000,2000,$4000
	endif
	dc.l	MediumFont
	dc.l	RETURN_VALUE_ADDR
	dc.l	TEST_PRESSED_FLAG-$1c
	dc.l	HEAP_PTR
	dc.l	FOLDER_LIST_HANDLE
	dc.l	(FOLDER_LIST_HANDLE+1)
	dc.l	$0130
	dc.l	kernel::idle
	dc.l	kernel::exec
	dc.l	kernel::Ptr2Hd
	dc.l	kernel::Hd2Sym
	dc.l	kernel::LibsBegin
	dc.l	kernel::LibsEnd
	dc.l	kernel::LibsCall
	dc.l	kernel::LibsPtr	
	dc.l	kernel::LibsExec
	dc.l	kernel::HdKeep	
	dc.l	kernel::ExtractFromPack
	dc.l	kernel::ExtractFile	
	dc.l	LCD_MEM 		
	dc.l	MediumFont+$800	; font_small	
	dc.l	MediumFont+$E00	;font_large	
	dc.l	SYM_ENTRY.name	
	dc.l	SYM_ENTRY.compat
	dc.l	SYM_ENTRY.flags	
	dc.l	SYM_ENTRY.hVal	
	dc.l	SYM_ENTRY.sizeof
	dc.l	kernel::ExtractFileFromPack
	dc.l	kernel::exit
	dc.l	kernel::atexit
	dc.l	kernel::RegisterVector
	dc.l	GHOST_SPACE
	dc.l	0 ; KERNEL_SPACE
	dc.l	kernel::SystemDir

; To be compatible with Preos, I prefer using bsr instead of ROM_THROW for ROM code.
ROM_THROW	MACRO
	jsr	\1
	ENDM
HW2TSR_PATCH	MACRO
		ENDM
GET_DATA_PTR	MACRO
	lea	Ref,a6		; Ptr to access data 
		ENDM

	;; Reinit the Kernel (Shared Linker) system
KernelReinit:
	clr.l	ExitStackPtr			
	clr.l	LibsExecList
	clr.l	LibCacheName	; This is local but we can't preempt it so let it global?
	rts
	
start_kernel_prgm:				; 'exec' function (Normally, never called except by some ugly nostub program).
	move.l	(a7)+,a0			; Load program address
	jsr	kernel::Ptr2Hd			; Get Handle of program
	clr.w	Error				; Clear Error code
	jsr	kernel::exec			; Execute it
	jsr	GKeyFlush			; Clear Keys 
	jsr	OSClearBreak			; Clear Break
	move.w	Error,d0			; Check if error
	beq.s	\No
		jsr	find_error_message_reg
		jsr	ST_helpMsg_reg		; Display it
\No	rts

	;; Include PreOS Shared Linker.
kernel::BeginSharedLinker:
	include	"sld.asm"
kernel::EndSharedLinker:

; Extract a PPH Handle
; In:
;	d4.w = Src PPG Handle
; Out:
;	d0.w = Asm Handle
ExtractPPG:
	; It is useless to check if the ppg is valid since ttunpack does the job.
	; Calculate length
	move.w	d4,a0
	trap	#3		; Deref PPG file
	addq.l	#2,a0		; Skip the PPG file size
	moveq	#0,d1
	move.w	(a0),d1		; Org size of the compresssed file
	ror.w	#8,d1		; From Big to little endian	
	move.l	d1,-(a7)	; Push size to alloc
	jsr	HeapAlloc	; Alloc (No need to lock!!!)
	move.l	d0,(a7)		; Save handle and check for null
	beq.s	\End
		lea	Decompressing(pc),a0
		jsr	ST_helpMsg_reg		; Display "Decompressing..."
		move.l	(a7),a0		; Deref the handle
		trap	#3
		pea	(a0)		; Decompress Here
		move.w	d4,a0		; Deref org PPG handle (again !)
		trap	#3
		addq.l	#2,a0		; Src is here
		pea	(a0)
		jsr	ttunpack_decompress
		addq.l	#8,a7
		tst.w	d0
		beq.s	\End
			move.l	(a7),d0		; If failed, free the block
			jsr	HeapFree_reg	
			clr.l	(a7)
\End	jsr	ST_eraseHelp	; Erase the help message
	move.l	(a7)+,d0	; Return the created Handle
	rts	
Decompressing	dc.b	"decompressing ...",0

kernel::SystemDir:
system_str	dc.b	"system",0
	EVEN
