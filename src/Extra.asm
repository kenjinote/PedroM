;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2005-2009 Patrick Pelissier
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
        xdef GetDataType
        xdef SmapTypeStringsTable
        xdef SmapTypeStrings
	ifd	USE_MAIN_PROGRAM
	xdef Zs_function_call
	xdef exit
	endif
	xdef	LinkLogSend
	xdef	LinkLogReceive
	
 ; __ATTR_TIOS__ short GetDataType (CESI ptr); (ROM_CALL_435) 
; Implementated by Lionel Debroux
; The cascade of subq and the simplified inline version of GetFuncPrgmBodyPtr make this routine much
; smaller than that of AMS. It is slower on average, though, but who needs speed for such a routine ?
GetDataType:
	move.l 4(a7),a0
	move.b (a0),d1
	moveq #15,d0
	cmpi.b #$F3,d1 ; ASM_TAG -> 15;
	beq.s \GetDataTypeEnd
	subq.w #3,d0 ; 13 and 14 do not seem to be returned by GetDataType ??
	cmpi.b #$F8,d1 ; OTH_TAG -> 12;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$E2,d1 ; MAC_TAG -> 11;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$E1,d1 ; FIG_TAG -> 10;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$DD,d1 ; DATA_TAG -> 9;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$DE,d1 ; GDB_TAG -> 8;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$E0,d1 ; TEXT_TAG -> 7;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$2D,d1 ; STR_TAG -> 6;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$DF,d1 ; PIC_TAG -> 5;
	beq.s \GetDataTypeEnd
	subq.w #1,d0
	cmpi.b #$DC,d1 ; FUNC_TAG -> 3 (FUNC) or 4 (PRGM).
	bne.s \GetDataTypeCheck12
	; Based on the optimized version of GetFuncPrgmBodyPtr previously used in tictex.
	; Note that GetFuncPrgmBodyPtr is much more complicated, but it does the same thing !
\GetDataType34Loop:
	cmpi.b #$E5,-(a0)
	bne.s \GetDataType34Loop
	cmpi.b #$E4,(a0)
	beq.s \GetDataType34OK ; Branch not taken -> strange data... Return EXPR.
\GetDataType0:
	moveq #0,d0
	bra.s \GetDataTypeEnd
\GetDataType34OK:
	cmpi.b #$19,-(a0)
	beq.s \GetDataType34Over
	subq.w #1,d0 ; Assume FUNC if not PRGM, like TICT-Explorer did.
	bra.s \GetDataType34Over
\GetDataTypeCheck12:
	subq.w #2,d0
	cmpi.b #$DB,d1 ; MATRIX_TAG -> 2;
	beq.s \GetDataTypeEnd
	cmpi.b #$D9,d1 ; LIST_TAG -> 1 (LIST) or 2 (MAT)
	bne.s \GetDataType0 ; Not LIST_TAG -> 0 (EXPR).
	cmpi.b #$D9,-(a0)
	beq.s \GetDataType12Over
	subq.w #1,d0 ; Single LIST_TAG -> 1 (LIST).
\GetDataType12Over:
\GetDataType34Over:
\GetDataTypeEnd:
	rts


; __ATTR_TIOS__ const char *SmapTypeStrings (short type); (ROM_CALL_436)
; Implemented by Lionel Debroux.

; Work around a bug in the assembler by not using "\".
; Having an array of 5-character strings was the most size-efficient way I (Lionel Debroux) could think of:
; * Using a C array of strings was obviously out of the question.
; * Using a packed array of strings (offsets of each string from the beginning + strings) would not save space either.
SmapTypeStringsTable:
	dc.b "EXPR",0
	dc.b "LIST",0
	dc.b "MAT",0,0
	dc.b "FUNC",0
	dc.b "PRGM",0
	dc.b "PIC",0,0
	dc.b "STR",0,0
	dc.b "TEXT",0
	dc.b "GDB",0,0
	dc.b "DATA",0
	dc.b "FIG",0,0
	dc.b "MAC",0,0
	dc.b "OTH",0,0
	dc.b "SYS",0,0
	dc.b "ALL",0,0
	dc.b "ASM",0,0

SmapTypeStrings:
	suba.l a0,a0
	move.w 4(sp),d0
	cmpi.w #15,d0
	bhi.s \SmapTypeStringsEnd
	move.w d0,d1
	lsl.w #2,d1
	add.w d1,d0 ; * 5
	lea SmapTypeStringsTable(pc,d0.w),a0
\SmapTypeStringsEnd
	rts 

	;; Call the MAIN program if the 'zs' command is run
;; Exported here for space reasons
	ifd	USE_MAIN_PROGRAM
Zs_function_call:
	lea	-60(a7),a7		; Push Error Frame
	pea	(a7)
	jsr	ER_catch
	tst.w	d0
	bne.s	\Error
		;; Init some MPFR globals: __gmpfr_cache_const_log2, __gmpfr_cache_const_pi, __gmpfr_cache_const_euler, __gmpfr_cache_const_catalan
		lea	mpfr_init_cache,a3
		pea	mpfr_const_log2_internal
		pea	__gmpfr_cache_const_log2
		jsr	(a3)
		pea	mpfr_const_pi_internal
		pea	__gmpfr_cache_const_pi
		jsr	(a3)
		pea	mpfr_const_euler_internal
		pea	__gmpfr_cache_const_euler
		jsr	(a3)
		pea	mpfr_const_catalan_internal
		pea	__gmpfr_cache_const_catalan
		jsr	(a3)
		lea	8*4(a7),a7
		;;  Start program
		pea	ARGV
		move.w	ARGC,-(a7)
		trap	#6				;  Potential BP
		jsr	main
		addq.l	#6,a7
		jsr	ER_success
\Error:	lea	64(a7),a7
	rts
exit:	ER_THROW 1		; Pas génial, mais suffisant.
	endif


LinkLogReceive:
	movem.l	d0-d2/a0-a1,-(a7)
	move.w	PACKET_HANDLE,a0
	trap	#3
	clr.w	-(a7)
	pea	(a0)
	move.w	PACKET_LEN,-(a7)
	clr.w	d0
	move.b	PACKET_CID,d0
	move.w	d0,-(a7)
	move.b	PACKET_MID,d0
	move.w	d0,-(a7)
	jsr	LinkLog
	lea	12(a7),a7
	movem.l	(a7)+,d0-d2/a0-a1
	rts

LinkLogSend:
	movem.l	d0-d2/a0-a1,-(a7)
	move.w	d5,-(a7)
	pea	(a2)
	move.w	d4,-(a7)
	moveq	#0,d0
	move.b	d3,d0
	move.w	d0,-(a7)
	move.w	d3,d0
	lsr.w	#8,d0
	move.w	d0,-(a7)
	jsr	LinkLog
	lea	12(a7),a7
	movem.l	(a7)+,d0-d2/a0-a1
	rts
