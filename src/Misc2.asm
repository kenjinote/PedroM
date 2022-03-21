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
        xdef OSSetSR
        xdef OSReset
        xdef NeedStack
        xdef setjmp
        xdef longjmp
        xdef EX_patch
        xdef cmd_disphome
        xdef MD5Done
        xdef OSqhead
        xdef OSqinquire
        xdef OSenqueue
        xdef OSdequeue
        xdef kbd_queue
        xdef QSysKey
        xdef WordInList
        xdef WordInList_reg
        xdef StrToTokN
        xdef TokToStrN
        xdef HomePushEStack
        xdef HS_newFIFONode
        xdef HS_pushFIFONode
        xdef HS_getFIFONode
        xdef HS_getEntry
        xdef HS_getAns
        xdef HS_freeFIFONode
        xdef HS_freeAll
        xdef HS_deleteFIFONode
        xdef HS_chopFIFO
        xdef HS_countFIFO
        xdef rand
        xdef srand
        xdef calloc
        xdef realloc
        xdef atof
        xdef sscanf
        xdef perror
        xdef setvbuf
        xdef strerror
        xdef StrWidthFromTo
        xdef CharNumber
        xdef StrError_msg_str
	xdef	TabSize
	

;******************************************************************
;***                                                            ***
;***            	Misc Functions (2)			***
;***                                                            ***
;******************************************************************

TabSize		dc.w	TAB_SIZE

;short OSSetSR(short mask);
OSSetSR:
	move.w	4(a7),d0
	trap	#1
	rts

;void OSReset(void);
OSReset:
	trap	#2

; void NeedStack(unsigned short size)	
NeedStack:
	move.w	4(a7),d1
	ext.l	d1
	lea	-$400(a7),a0
	cmp.l	d1,a0
	bge.s	\ok
		ER_THROW $29E
\ok	rts

;short setjmp (void *j_buf); 
setjmp:
	movea.l	4(a7),a0
	movem.l	d2-d7/a2-a7,(a0)
	move.l	(a7),$30(a0)	; Useless
	moveq	#0,d0
	rts
	
;void longjmp (void *j_buf, short ret_val);
longjmp:
	move.l	4(a7),a0
	move.w	8(a7),d0
	bne.s	\not
		moveq	#1,d0
\not:	movem.l	(a0)+,d2-d7/a2-a7
	move.l	(a0),(a7)
	rts
	
;void EX_patch (void *base_addr, void *tag_ptr);
EX_patch:
	move.l	4(a7),a0		; Base Ptr
	move.l	8(a7),a1		; End Ptr
	pea	(a2)
	; Due to some nasty reason, it may be unaligned... Suck
\loop:		moveq	#0,d1
		move.b	-(a1),d1
		moveq	#0,d0
		move.b	-(a1),d0
		lsl.w	#8,d0
		or.w	d0,d1		; Patch addr
		beq.s	\EndOfReloc
		moveq	#0,d2
		move.b	-(a1),d2
		moveq	#0,d0
		move.b	-(a1),d0
		lsl.w	#8,d0
		or.w	d0,d2		; What to write
		move.l	a0,d0
		add.l	d2,d0		; Reloc it
		lea	4(a0,d1.l),a2
		move.b	d0,-(a2)
		lsr.l	#8,d0
		move.b	d0,-(a2)
		lsr.l	#8,d0
		move.b	d0,-(a2)
		lsr.l	#8,d0
		move.b	d0,-(a2)
		bra.s	\loop
\EndOfReloc:
	move.l	(a7)+,a2
	rts


; void cmd_disphome (void); 
cmd_disphome:
	jmp	clrscr

;void MD5Done (BN *digest, MD5_CTX *context);
MD5Done:
	move.l	4(a7),a0
	move.l	8(a7),-(a7)
	pea	1(a0)
	jsr	MD5Final
	addq.l	#8,a7
	move.l	4(a7),a0
	moveq	#16,d0
\loop		tst.b	0(a0,d0.w)
		bne.s	\done
		subq.w	#1,d0
		bgt.s	\loop
\done	move.b	d0,(a0)
	rts
	

;unsigned short OSqhead (unsigned short *dummy, void *Queue); 
OSqhead:
	move.l	8(a7),a0
	tst.w	QUEUE.used(a0)
	beq.s	\Nothing
		move.w	QUEUE.head(a0),d1
		subq.w	#2,d1
		move.w	QUEUE.data(a0,d1.w),d0
\Nothing:
	rts

;short OSqinquire (unsigned short *dest, void *Queue);
OSqinquire:
	move.l	8(a7),a0
	move.l	4(a7),a1
	moveq	#0,d0
	tst.w	QUEUE.used(a0)
	beq.s	\done
		move.w	QUEUE.tail(a0),d1
		move.w	QUEUE.data(a0,d1.w),(a1)
		moveq	#1,d0
\done:	rts

;short OSenqueue (unsigned short data, void *Queue);
OSenqueue:
	move.l	4(a7),d2
	move.l	6(a7),a0
	clr.w	d0
	move.w	QUEUE.used(a0),d1
	cmp.w	QUEUE.size(a0),d1
	bge.s	\Cant
		addq.w	#2,QUEUE.used(a0)
		move.w	QUEUE.head(a0),d1
		move.w	d2,QUEUE.data(a0,d1.w)
		addq.w	#2,d1
		cmp.w	QUEUE.size(a0),d1
		blt.s	\Ok
			clr.w	d1
\Ok		move.w	d1,QUEUE.head(a0)
		moveq	#1,d0
\Cant	rts

;short OSdequeue (unsigned short *dest, void *Queue); 
OSdequeue:
	move.l	4(a7),a1
	move.l	8(a7),a0
	moveq	#1,d0			; Return TRUE if Queue is empty
	tst.w	QUEUE.used(a0)
	beq.s	\Cant
		move.w	QUEUE.tail(a0),d1
		move.w	QUEUE.data(a0,d1.w),(a1)
		subq.w	#2,QUEUE.used(a0)
		addq.w	#2,d1
		cmp.w	QUEUE.size(a0),d1
		blt.s	\Ok
			clr.w	d1
\Ok		move.w	d1,QUEUE.tail(a0)
		moveq	#0,d0
\Cant	rts
	
;void *kbd_queue (void); 
kbd_queue:
	lea	KBD_QUEUE,a0
	rts
	
;short QModeKey (short code);
QModeKey
	bsr.s	\PushT				; Push the next address
	dc.w	$110B,$0109,$010A,$102D		; It is not the return address,
	dc.w	$1109,$1036,$1108,$2051		; but the address of a table
	dc.w	$2057,$2048,$2052,$2054
	dc.w	$2059,0
\PushT	move.w	4+4(a7),-(a7)			; Push Code
	bsr.s	WordInList			; Check for it.
	addq.l	#6,a7
	rts

;short QSysKey (short code);
QSysKey:
	bsr.s	\PushT
	dc.w	$1035,$1032,$102B,$1033,0
\PushT	move.w	4+4(a7),-(a7)
	bsr.s	WordInList
	addq.l	#6,a7
	rts

;short WordInList (unsigned short Word, unsigned short *List); 
WordInList:
	move.w	4(a7),d1		; What to search
	move.l	6(a7),a0		; In table
WordInList_reg:
	moveq	#0,d0			; Fail
\loop		move.w	(a0)+,d2	; Read next word
		beq.s	\fail		; =0, end of table => Fail
		cmp.w	d1,d2		; Cmp 2 numbers
		bne.s	\loop		; Equal, success. Different, next 
	moveq	#1,d0			; Success
\fail	rts

;ESI StrToTokN (const char *src, unsigned char *dest);
StrToTokN:
	move.l	4(a7),a0		; ANSI src
	jsr	strlen_reg_redirect	; d0.l = src len
	move.l	4(a7),a0		; ANSI src
	move.l	8(a7),a1		; Tokn Dest
	lea	$14(a1),a1		; End of Tokn Dest
	lea	1(a0,d0.l),a0		; End of ANSI str
\loop		move.b	-(a0),-(a1)
		dbf	d0,\loop
	clr.b	-(a1)
	move.l	8(a7),a0		; Tokn Dest
	lea	$14-1(a0),a0		; End of Tokn Dest
	rts

;short TokToStrN (unsigned char *dest, SYM_STR src);
TokToStrN:
	move.l	4(a7),a0		; ANSI dest
	move.l	8(a7),a1		; Tokn Src
\loop		tst.b	-(a1)		; From VAT to ANSI
		bne.s	\loop
	addq.l	#1,a1
\loop2:		move.b	(a1)+,(a0)+
		bne.s	\loop2
	moveq	#1,d0
	rts

;void HomePushEStack (void);
HomePushEStack:
;HANDLE HS_newFIFONode (void);
HS_newFIFONode:
;void HS_pushFIFONode (HANDLE Node);
HS_pushFIFONode:
	ER_THROW $10
	
;HANDLE HS_getFIFONode (unsigned short Index);
HS_getFIFONode:
;HANDLE HS_getEntry (unsigned short Index);
HS_getEntry:
;HANDLE HS_getAns (unsigned short Index);
HS_getAns:
;void HS_freeFIFONode (HANDLE Node);
HS_freeFIFONode:
;void HS_freeAll (void); 
HS_freeAll:
;HANDLE HS_deleteFIFONode (HANDLE Node);
HS_deleteFIFONode:
;void HS_chopFIFO (void);
HS_chopFIFO:
;unsigned short HS_countFIFO (void);
HS_countFIFO:
	moveq	#0,d0
	rts

; int setvbuf(FILE *stream, char *buf, int mode , size_t size);
; mode value: _IONBF (Unbuffered), _IOLBF (Line), _IOFBF (Fully Buffered)
setvbuf:
	moveq	#1,d0		; Error: streams can't be buffered.
	rts			; At least for the moment

;short StrWidthFromTo(const char *str asm("a0"), const char *end asm("a1"));
StrWidthFromTo:
	movem.l	d1-d2/a0-a2,-(a7)
	
	lea	MediumFont+$800,a2	; Small Font
	moveq	#6,d2			; Medium Height

	moveq	#0,d0
	moveq	#0,d1
	
	; Select Font
	cmpi.b	#1,CURRENT_FONT
	blt.s	\final_small
	beq.s	\final_calc

	; Large / Medium
	moveq	#8,d2		; Large
	bra.s	\final_calc
\loop_calc	add.w	d2,d0
\final_calc	addq.l	#1,a0
		cmp.l	a0,a1
		bge.s	\loop_calc
\rets	movem.l	(a7)+,d1-d2/a0-a2
	rts
	; Small
\loop_small	mulu.w	#6,d2		; Each character is 6 bytes
		move.b	0(a2,d2.w),d1
		add.w	d1,d0
\final_small	clr.w	d2
		move.b	(a0)+,d2
		cmp.l	a0,a1
		bge.s	\loop_small
	bra.s	\rets
	
; char CharNumber (char number, char offset, char *dest)
CharNumber:
	clr.w	d0
	clr.w	d1
	move.b	5(a7),d1		; number
	move.b	7(a7),d0		; offset
	move.l	8(a7),a0		; Dest ptr
	adda.w	d0,a0			; Real dest (Ptr+Offset)
	divu.w	#10,d1			; d1.uw= remainder d1.w=quo
	tst.w	d1			; Test quo == 0
	beq.s	\Skip
		addi.b	#'0',d1		; GO to ASCII code
		move.b	d1,(a0)+	; No, so fill the dest
		addq.w	#1,d0		; One offset more write
\Skip:
	swap	d1			; Remainder
	addi.b	#'0',d1			; GO to ASCII code 
	move.b	d1,(a0)+
	addq.w	#1,d0			; One offset more write
	clr.b	(a0)			; NULL char
	rts

; *****************************
;     Standard C FUNCTIONS
; *****************************
	
; int rand (rand)
rand:
	move.l	#$41C64E6D,d2
	move.l	(randseed).w,d1
	move.l	d2,d0
	mulu	d1,d0
	swap	d2
	mulu	d1,d2
	swap	d1
	mulu	#$4E6D,d1
	add.w	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	add.l	#12345,d0
	move.l	d0,(randseed).w
	lsr.l	#8,d0
	and.w	#32767,d0
	rts
; void srand (unsigned long seed asm ("d0"))
srand:	move.l	d0,(randseed).w
	rts
	
;void *calloc (unsigned short NoOfItems asm("d0"), unsigned short SizeOfItems asm("d1"));
calloc:
	mulu.w	d1,d0
	move.l	d0,-(a7)
	jsr	HeapAllocPtr_redirect
	move.l	(a7)+,d0
	move.l	a0,d2
	beq.s	\Error
		move.l	a0,-(a7)
		moveq	#0,d2
		jsr	memset_reg_align
		move.l	(a7)+,a0
\Error:	rts

;void *realloc (void *Ptr asm("a0"), unsigned long NewSize asm("d1"));
realloc:
	move.l	a0,d0				; Read Ptr
	bne.s	\ReAlloc
		move.l	d1,-(a7)
		jsr	HeapAllocPtr_redirect
		addq.l	#4,a7
		rts
\ReAlloc
	addq.l	#2,d1				; Size+2
	move.l	d1,-(a7)			; Push size
	move.w	-2(a0),-(a7)			; Push Handle
	jsr	HeapUnlock_redirect		; Unlock Handle
	jsr	HeapRealloc_redirect		; Realloc
	tst.w	d0
	bne.s	\Deref
		jsr	HeapFree_redirect	; Free Handle
		sub.l	a0,a0			; Return NULL
		bra.s	\Done
\Deref	jsr	HLock_redirect			; Lock and deref
	addq.l	#2,a0				; Skip Handle
\Done	addq.l	#6,a7				; Pop frame
	rts

;float atof (const char *s asm("a2"));
atof:
	link.w	a6,#-80
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	top_estack,-(a7)
	pea	-80(a6)
	jsr	ER_catch 
	tst.w	d0
	beq.s	\Start
		move.l	#$7FFFAA00,d0
		moveq	#0,d1
		clr.w	d2
		bra.s	\End
\Start:
	move.l	a2,(sp)
	jsr	push_parse_text
	move.l	top_estack,a0
	move.b	(a0),d5
	cmpi.b	#$7A,d5
	bne.s	\NotNeg
		subq.l	#1,a0
\NotNeg:
	move.l	a0,(sp)
	jsr	estack_number_to_Float
	jsr	ER_success
	move.l	-10(a6),d0
	move.l 	-6(a6),d1
	move.w	-2(a6),d2
	cmpi.b	#$7A,d5
	bne.s	\End
		bset	#31,d0
\End:	move.l	(a7)+,top_estack
	movem.l -116(a6),d3-d7/a2-a5
	unlk a6
	rts

;; Theses functions are not defined yet, but may be needed for linking with C code.
sscanf:
	ER_THROW BREAK_ERROR


;  void perror(const char *str asm("a2"))
perror:	
	move.w	errno,-(a7)
	jsr	strerror
	pea	(a0)
	pea	(a2)
	bsr.s	\Call
	dc.b	"%s: %s",10,0
\Call:	jsr	errorPrintf
	lea	14(a7),a7
	rts
	

;char *strerror (short err_no);
strerror:
	move.w	4(a7),d0
	lea	StrError_msg_str(Pc),a0
	cmpi.w	#21,d0
	bhi.s	\end
\loop			tst.b	(a0)+
			bne.s	\loop
		dbf	d0,\loop
\end:	rts

	; Standardised error messages.
StrError_msg_str:
	dc.b	"undefined errno value",0
	dc.b	"no error",0
	dc.b	"no such file entry",0
	dc.b	"I/O error",0
	dc.b	"not a serial device",0
	dc.b	"out of memory",0
	dc.b	"permission denied",0
	dc.b	"block dev required",0
	dc.b	"no such dev",0
	dc.b	"invalid arg",0
	dc.b	"full file table",0
	dc.b	"full dev directory",0
	dc.b	"no space left on dev",0
	dc.b	"no more alloc blocks",0
	dc.b	"no more data blocks on dev",0
	dc.b	"file is open",0
	dc.b	"no RAM space configured",0
	dc.b	"no heap space configured",0
	dc.b	"seek can't extend read only file",0
	dc.b	"bad file descriptor - file not open",0
	dc.b	"invalid signal number",0
	dc.b	"argument out of range",0
	dc.b	"result out of range",0
	EVEN
