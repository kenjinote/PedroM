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
        xdef PedroMLibKernel
        xdef PedoMLibExportTable
        xdef PedoMLibExportTableEnd
        xdef KernelExec_redirect
        xdef RamDataTable
        xdef RunMainFunction
        xdef PedroMLibraryEntry
        xdef HeapRealloc_redirect
        xdef HeapMax_redirect	
        xdef getenv_redirect	
        xdef HeapAlloc_redirect	
        xdef HeapAllocPtr_redirect
        xdef HeapDeref_redirect	
        xdef HeapFree_redirect	
        xdef HeapLock_redirect	
        xdef HeapUnlock_redirect	
        xdef HeapGetLock_redirect
        xdef HLock_redirect	
        xdef sprintf_redirect	
        xdef Float2Int_redirect	
        xdef system_redirect	
        xdef ERD_dialog_redirect
        xdef DrawStr_redirect	
        xdef InitGraphSystem_redirect
        xdef printf_redirect	
        xdef SymFindPtr_redirect
        xdef KernelExec_redirect
	xdef kernel__Ptr2Hd
	xdef kernel__clean_up
	xdef kernel__Hd2Sym
        xdef strlen_reg_redirect
        xdef clrscr_redirect	
	xdef __main
	xdef	__trampoline_offset

; Exported PedroM library

PedroMLibKernel:
	dc.l	$4E754E75		; Header
	dc.l	'68kL'			; Signature
	dc.b	0,2			; InternalFormat, RelocCount
	dc.w	0,0,0			; Offset to main, comment, exit
	dc.b	1,32+2+1		; VersionNumber,Flags
	dc.w	0,0,PedoMLibExportTable-PedroMLibKernel,0	; Handle,Bss,Export,RamTable
PedoMLibExportTable:
	;; 	dc.w	(PedoMLibExportTableEnd-PedoMLibExportTable-2)/2 ;
	dc.w	$2F
	dc.w	RamDataTable-PedroMLibKernel		; 0
	dc.w	RunMainFunction-PedroMLibKernel		; 1
	dc.w	HeapRealloc_redirect-PedroMLibKernel	; 2
	dc.w	HeapMax_redirect-PedroMLibKernel	; 3
	dc.w	printf_redirect-PedroMLibKernel			; 4
	dc.w	vcbprintf_redirect-PedroMLibKernel		; 5
	dc.w	clrscr_redirect-PedroMLibKernel			; 6
	dc.w	fclose_redirect-PedroMLibKernel			; 7
	dc.w	freopen_redirect-PedroMLibKernel			; 8
	dc.w	fopen_redirect-PedroMLibKernel			; 9
	dc.w	fseek_redirect-PedroMLibKernel			; A
	dc.w	ftell_redirect-PedroMLibKernel			; B
	dc.w	feof_redirect-PedroMLibKernel			; C
	dc.w	fputc_redirect-PedroMLibKernel			; D
	dc.w	fputs_redirect-PedroMLibKernel			; E
	dc.w	fwrite_redirect-PedroMLibKernel			; F
	dc.w	fgetc_redirect-PedroMLibKernel			; 10
	dc.w	fread_redirect-PedroMLibKernel			; 11
	dc.w	fgets_redirect-PedroMLibKernel			; 12
	dc.w	ungetc_redirect-PedroMLibKernel			; 13
	dc.w	fflush_redirect-PedroMLibKernel			; 14
	dc.w	clearerr_redirect-PedroMLibKernel		; 15
	dc.w	ferror_redirect-PedroMLibKernel			; 16
	dc.w	rewind_redirect-PedroMLibKernel			; 17
	dc.w	fprintf_redirect-PedroMLibKernel			; 18
	dc.w	tmpnam_redirect-PedroMLibKernel			; 19
	dc.w	DIALOG.Do_redirect-PedroMLibKernel		; 1A
	dc.w	qsort_redirect-PedroMLibKernel			; 1B
	dc.w	PID_Switch_redirect-PedroMLibKernel		; 1C
	dc.w	_tt_Decompress_redirect-PedroMLibKernel		; 1D
	dc.w	bsearch_redirect-PedroMLibKernel			; 1E
	dc.w	unlink_redirect-PedroMLibKernel			; 1F
	dc.w	rename_redirect-PedroMLibKernel			; 20
	dc.w	atoi_redirect-PedroMLibKernel			; 21
	dc.w	kbd_queue_redirect-PedroMLibKernel		; 22
	dc.w	rand_redirect-PedroMLibKernel			; 23
	dc.w	srand_redirect-PedroMLibKernel			; 24
	dc.w	calloc_redirect-PedroMLibKernel			; 25
	dc.w	realloc_redirect-PedroMLibKernel			; 26
	dc.w	atof_redirect-PedroMLibKernel			; 27
	dc.w	_sputc_redirect-PedroMLibKernel			; 28
	dc.w	perror_redirect-PedroMLibKernel			; 29
	dc.w	getenv_redirect-PedroMLibKernel		; 2A
	dc.w	system_redirect-PedroMLibKernel		; 2b
	dc.w	setvbuf_redirect-PedroMLibKernel			; 2c
	dc.w	kernel__exit-PedroMLibKernel		; 2d
	dc.w	kernel__atexit-PedroMLibKernel		; 2e
	
PedoMLibExportTableEnd:

	;;  Redirect reference (for short form)
HeapRealloc_redirect	jmp	HeapRealloc
HeapMax_redirect	jmp	HeapMax
getenv_redirect		jmp	getenv
HeapAlloc_redirect	jmp	HeapAlloc
HeapAllocPtr_redirect	jmp	HeapAllocPtr
HeapDeref_redirect	jmp	HeapDeref
HeapFree_redirect	jmp	HeapFree
HeapLock_redirect	jmp	HeapLock
HeapUnlock_redirect	jmp	HeapUnlock
HeapGetLock_redirect	jmp	HeapGetLock
HLock_redirect		jmp	HLock
sprintf_redirect	jmp	sprintf
Float2Int_redirect	jmp	Float2Int
system_redirect		jmp	system
ERD_dialog_redirect	jmp	ERD_dialog
DrawStr_redirect	jmp	DrawStr
InitGraphSystem_redirect	jmp	InitGraphSystem
printf_redirect		jmp	printf
SymFindPtr_redirect	jmp	SymFindPtr
KernelExec_redirect	jmp	kernel::exec
strlen_reg_redirect	jmp	strlen_reg
clrscr_redirect		jmp	clrscr
perror_redirect		jmp	perror
setvbuf_redirect	jmp	setvbuf
_sputc_redirect		jmp	_sputc
atof_redirect		jmp	atof
calloc_redirect		jmp	calloc
realloc_redirect	jmp	realloc
rand_redirect		jmp	rand
srand_redirect		jmp	srand
atoi_redirect		jmp	atoi
bsearch_redirect	jmp	bsearch
vcbprintf_redirect	jmp	vcbprintf
DIALOG.Do_redirect	jmp	DIALOG.Do
qsort_redirect		jmp	qsort
PID_Switch_redirect	jmp	PID_Switch
kbd_queue_redirect	jmp	kbd_queue
fgets_redirect		jmp	fgets
ungetc_redirect		jmp	ungetc
fflush_redirect		jmp	fflush
clearerr_redirect	jmp	clearerr
ferror_redirect		jmp	ferror
rewind_redirect		jmp	rewind
fprintf_redirect	jmp	fprintf
tmpnam_redirect		jmp	tmpnam
unlink_redirect		jmp	unlink
rename_redirect		jmp	rename
fread_redirect		jmp	fread
fgetc_redirect		jmp	fgetc
fwrite_redirect		jmp	fwrite
fputs_redirect		jmp	fputs
feof_redirect		jmp	feof
ftell_redirect		jmp	ftell
fseek_redirect		jmp	fseek
fopen_redirect		jmp	fopen
freopen_redirect	jmp	freopen
fclose_redirect		jmp	fclose
fputc_redirect		jmp	fputc
	
kernel__Ptr2Hd		jmp	kernel::Ptr2Hd
kernel__clean_up	jmp	kernel::clean_up
kernel__Hd2Sym		jmp	kernel::Hd2Sym
kernel__exit		jmp	kernel::exit
kernel__atexit		jmp	kernel::atexit

	;; To keep ABI compatibility with previous releases of PedroMs.
_tt_Decompress_redirect:
	pea	(a1)
	pea	(a0)
	jsr	ttunpack_decompress
	addq.l	#8,a7
__main:				; This symbol does nothing and must do nothing (used if an program add-on uses 'main' for its entry point).
	rts

; See tigcclib source for details.
__trampoline_offset:
	moveq	#0,d0
	rts
	
RamDataTable:
	dc.l	stdin
	dc.l	stdout
	dc.l	stderr
	dc.l	ARGC
	dc.l	ARGV
	dc.l	errno
	dc.l	TextFont46

; Keep for previous release of PedroM.
; In: a0-> main function to call.
RunMainFunction:
	jmp	(a0)					; The Kernel (sld) does all the job.

PedroMLibraryEntry:
	;; Library Entry is:
	;;  LIBRARY.name   8 bytes
	;;  LIBRARY.org    4 bytes
	;;  LIBRARY.code   4 bytes 
	;;  LIBRARY.data   4 bytes
	;;  LIBRARY.refcnt 2 bytes
	;;  LIBRARY.relocf 2 bytes 
	dc.b	"pedrom",0,0
	dc.l	PedroMLibKernel
	dc.l	PedroMLibKernel
	dc.l	0
	dc.w	2
	dc.b	1,1
	