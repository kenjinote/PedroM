;*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003, 2005-2008 Patrick Pelissier
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

        ;; Exported FUNCTIONS: 
        xdef _dm16end
        xdef _ds16u16
        xdef _du16u16
        xdef _mu16u16
        xdef _ms32s32
        xdef _mu32u32
        xdef _ds32s32
        xdef _du32u32


; ***************************************************************
; *								*
; *		Pedrom		/	LongCalc		*
; *								*
; ***************************************************************

; ***************************************************************
; 			Divu/modu with short
;		Useless since TIGCC never use them!
; ***************************************************************

; Modulo
; In:
;	d0.w = Unsigned Int 16 bits
;	d1.w = Signed Int 16 bits
; Out:
;	d1.l = d1 % d0
_ms16u16
	ext.l	d1
	bpl.s	ms16u16_sup
		neg.l	d1
		divu	d0,d1
		swap	d1
_dm16end2	neg.w	d1
		bra.s	_dm16end
ms16u16_sup	
	divu	d0,d1
	swap	d1
_dm16end:
	ext.l	d1
	rts
	
; In:
;	d1.w = signed int
;	d0.w = unsigned int
; Out:
;	d1.l = d1/d0
_ds16u16:
	ext.l	d1
	bpl.s	\sup
		neg.l	d1
		divu	d0,d1
		bra.s	_dm16end2
\sup	divu	d0,d1
	bra.s	_dm16end
	
; In:
;	d1.w = unsigned int
;	d0.w = unsigned int
; Out:
;	d1.l = d1/d0
_du16u16:
	moveq	#0,d2
	move.w	d1,d2
	divu	d0,d2
	moveq	#0,d1
	move.w	d2,d1
	rts
	
; In:
;	d1.w = unsigned int
;	d0.w = unsigned int
; Out:
;	d1.l = d1%d0
_mu16u16:
	swap	d1
	clr.w	d1
	swap	d1
	divu	d0,d1
	clr.w	d1
	swap	d1
	rts


	
; ***************************************************************
; 			Divu/modu with long
; ***************************************************************

ms32s32_negd0:
	neg.l	d0
	tst.l	d1
	blt.s	ms32s32_negd1
	bra.s	_mu32u32

; In:
;	d1.l = long
;	d0.l = long
; Out:
;	d1.l = d1%d0
; Destroy:
;	d0-d2/a0-a1
_ms32s32:
	tst.l	d0
	beq.s	ds32s32_divby0
	blt.s	ms32s32_negd0
	tst.l	d1
	bge.s	_mu32u32
ms32s32_negd1:
	neg.l	d1
ms32s32_oneneg:
	bsr.s	_du32u32
	move.l	d2,d1
	neg.l	d1
	rts

; Here d0 <0, and d1 is ?
ds32s32_negd0:
	neg.l	d0
	tst.l	d1
	bgt.s	ds32s32_oneneg
	neg.l	d1
	bra.s	_du32u32

; Here d0 > 0 and d1 < 0
ds32s32_negd1:
	neg.l	d1
ds32s32_oneneg:
	bsr.s	_du32u32
	neg.l	d1
	rts

; In:
;	d1.l = unsigned long
;	d0.l = unsigned long
; Out:
;	d1.l = d1%d0
; Destroy:
;	d0-d2/a0-a1
_mu32u32:
	bsr.s	_du32u32
	move.l	d2,d1
	rts

ds32s32_divby0:	divu.w	#0,d1

; In:
;	d1.l = long
;	d0.l = long
; Out:
;	d1.l = d1/d0
; Destroy:
;	d0-d2/a0-a1
_ds32s32:
	tst.l	d0
	beq.s	ds32s32_divby0
	blt.s	ds32s32_negd0
	tst.l	d1
	blt.s	ds32s32_negd1

; In:
;	d1.l = unsigned long
;	d0.l = unsigned long
; Out:
;	d1.l = d1/d0
;	d2.l = d1%d0
; Destroy:
;	d0-d2/a0-a1
_du32u32:
	; First check if d0 >= d1
	cmp.l	d1,d0
	bcs.s	\NotTrivial
		beq.s	\Equal
		move.l	d1,d2
		moveq	#0,d1
		rts
\Equal		moveq	#1,d1
		moveq	#0,d2
		rts
\NotTrivial:
	; Check if HIGH 16 bits of denominator if NULL
	swap	d0
	tst.w	d0
	bne.s	\High16bitsNotNull
		; High 16 bits of d0 are null
		swap	d0
		divu	d0,d1
		bvs.s	\overflow
			; No overflow! Fantastic!
			moveq	#0,d2
			move.w	d1,d2	; d2=quotient
			clr.w	d1	; d1=rest
			swap	d1
			exg	d1,d2	; Exg them
			rts
\overflow	; d1 isn't changed	
		; A.32 bits B.16 bits
		; Compute A/(2^16*B) = q1*2^16*b+r1 with 0 <= r1 < 2^16*b
		; Then r1/b is between 0 and 2^16!
		; Compute r1/b=q2*b+r2
		; Return (q1*2^16+q2, r2)
		move.w	d1,-(a7)		; Save low 16 bits
		clr.w	d1			; Shift d1 by 16
		swap	d1			;
		divu	d0,d1			; Divide d1.uw by d0.w
		move.l	d1,d2			; d2.uw = r1 shifted by 16
		swap	d1			; Put High quotient in High part of register
		move.w	(a7)+,d2		; Reload remaining of A: r'=r1<<16+ra
		divu	d0,d2			; Rediv. d2.uw=r2 and d2.w=q2
		move.w	d2,d1			; q = q1 + q2
		clr.w	d2			; d2.w = 0
		swap	d2			; d2.uw -> d2.w = d2.l
		rts
\High16bitsNotNull
	; A loop. Doesn't do more than 16 steps. Classic division algorithm.
	; q = 0
	; do
	;	qq = 1<<(nbitsA-nbitsB-1)
	;	A = A - qq*B
	;	q += qq
	; while A > B
	moveq	#0,d2		; q
	exg	d1,d2		
	; d1 = q
	; d2 = A
	; d0 = B roll
	movem.l	d3-d5,-(a7)
	; Count leading bits of B
	moveq	#9,d3
	move.w	d0,d5
	cmp.w	#$00FF,d5
	bls.s	\Read
		lsr.w	#8,d5
		moveq	#1,d3
\Read	add.b	CountLeadingZerosTable(pc,d5.w),d3
	swap	d0
\Loop:		; Count leading bits of A
		moveq	#9,d4
		move.l	d2,d5
		swap	d5
		cmp.w	#$00FF,d5
		bls.s	\Read2
			lsr.w	#8,d5
			moveq	#1,d4
\Read2		add.b	CountLeadingZerosTable(pc,d5.w),d4
		sub.w	d3,d4	; d3 > d4
		beq.s	\DiffNull
			addq.w	#1,d4
			neg.w	d4	; d4 = MAX (((32-lead(A))-(32-lead(B))-1), 0)
\DiffNull:
		moveq	#1,d5
		lsl.l	d4,d5	
		add.l	d5,d1	; q+=qq
		move.l	d0,d5
		lsl.l	d4,d5
		sub.l	d5,d2
		cmp.l	d2,d0
		bls.s	\Loop
	movem.l	(a7)+,d3-d5
	rts

CountLeadingZerosTable
	dc.b	8,7,6,6,5,5,5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



; ***************************************************************
; TIGCC Library Routines
;Copyright (C) 2000-2005 Zeljko Juric,
;                        Thomas Nussbaumer,
;                        Kevin Kofler, and
;                        Sebastian Reichelt
;
;Theses functions are part of TIGCC.
;
;TIGCC is free software; you can redistribute it and/or modify it
;under the terms of the GNU General Public License as published by the
;Free Software Foundation; either version 2, or (at your option) any
;later version.
;
;In addition to the permissions in the GNU General Public License, the
;TIGCC Team gives you unlimited permission to link the compiled
;versions of these files with other programs, and to distribute
;those programs without any restriction coming from the use of this
;file.  (The General Public License restrictions do apply in other
;respects; for example, they cover modification of the files, and
;distribution when not linked into another program.)
;
;These files are distributed in the hope that they will be useful, but
;WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, write to the Free Software
;Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
; ***************************************************************
	xdef	__floatunssibf
	xdef	__fixunsbfsi
	xdef	__nebf2
	xdef	__eqbf2
	xdef	__addbf3
	xdef	__gtbf2
	xdef	__ltbf2
	xdef	__gebf2
	xdef	__negbf2
	xdef	__divbf3
	xdef	__lebf2
        xdef __modsi3
        xdef __udivdi3
        xdef __muldi3
        xdef __umoddi3
        xdef __mulsi3
        xdef __divsi3
        xdef __subbf3
        xdef __fixbfsi
        xdef __floatsibf
        xdef __mulbf3
        xdef __divdi3
	xdef __udivsi3
	xdef __umodsi3
	
; Long functions
__modsi3:
	lea	_ms32s32(pc),a0
	bra.s	__div_entry
__divsi3:
	lea	_ds32s32(pc),a0
	bra.s	__div_entry
__udivsi3:
	lea	_du32u32(pc),a0
	bra.s	__div_entry
__umodsi3:
	lea	_mu32u32(pc),a0
__div_entry:
	move.l	4(sp),d1
	move.l	8(sp),d0
	jsr	(a0)
	move.l	d1,d0
	rts
__mulsi3:
	move.l 4(sp),d1
	move.l 8(sp),d2
	move.l d2,d0
	mulu d1,d0
	swap d2
	mulu d1,d2
	swap d1
	mulu 10(sp),d1
	add.w d1,d2
	swap d2
	clr.w d2
	add.l d2,d0
	rts

; Long Long functions
__udivdi3:
	movem.l d3-d6,-(a7)
	move.l 20(a7),d4
	move.l 24(a7),d5
	move.l 28(a7),d2
	move.l 32(a7),d3
	moveq.l #0,d0
	moveq.l #0,d1

	moveq.l #-1,d6
.L__udivdi3_shl:
	addq.w #1,d6
	add.l d3,d3
	addx.l d2,d2
	bcc.s .L__udivdi3_shl
	roxr.l #1,d2
	roxr.l #1,d3

.L__udivdi3_shr:
	add.l d1,d1
	addx.l d0,d0
	cmp.l d2,d4
	bne.s .L__udivdi3_cmp
	cmp.l d3,d5
.L__udivdi3_cmp:
	bcs.s .L__udivdi3_skip
	sub.l d3,d5
	subx.l d2,d4
	addq.l #1,d1
.L__udivdi3_skip:
	lsr.l #1,d2
	roxr.l #1,d3
	dbra.w d6,.L__udivdi3_shr
	movem.l (a7)+,d3-d6
	rts

__divdi3:
	tst.b 4(a7)
	blt.s .L__divdi3_numer_negative
	tst.b 12(a7)	
	blt.s .L__divdi3_denom_negative
.L__divdi3_udivdi3:
	bra.s __udivdi3
.L__divdi3_numer_negative:
	neg.l 8(a7)
	negx.l 4(a7)
	tst.b 12(a7)	
	bge.s .L__divdi3_denom_positive
	neg.l 16(a7)
	negx.l 12(a7)
	bra.s .L__divdi3_udivdi3
.L__divdi3_denom_negative:
	neg.l 16(a7)
	negx.l 12(a7)
.L__divdi3_denom_positive:
	move.l (a7)+,a1
	bsr.s .L__divdi3_udivdi3
	neg.l d1
	negx.l d0
	jmp (a1)

__umoddi3:
	movea.l d3,a0
	move.l 4(a7),d0
	move.l 8(a7),d1
	move.l 12(a7),d2
	move.l 16(a7),d3
	movea.l d4,a1
	moveq.l #-1,d4
.L__umoddi3_shl:
	addq.w #1,d4
	add.l d3,d3
	addx.l d2,d2
	bcc.s .L__umoddi3_shl
	roxr.l #1,d2
	roxr.l #1,d3
.L__umoddi3_shr:
	cmp.l d2,d0
	bne.s .L__umoddi3_cmp
	cmp.l d3,d1
.L__umoddi3_cmp:
	bcs.s .L__umoddi3_skip
	sub.l d3,d1
	subx.l d2,d0
.L__umoddi3_skip:
	lsr.l #1,d2
	roxr.l #1,d3
	dbra.w d4,.L__umoddi3_shr
	move.l a1,d4
	move.l a0,d3
	rts

__muldi3:
	move.w 18(a7),d0
	mulu 4(a7),d0
	move.w 16(a7),d2
	mulu 6(a7),d2
	add.w d2,d0
	move.w 14(a7),d2
	mulu 8(a7),d2
	add.w d2,d0
	move.w 12(a7),d2
	mulu 10(a7),d2
	add.w d2,d0
	swap d0
	clr.w d0

	move.w 18(a7),d2
	mulu 6(a7),d2
	add.l d2,d0
	move.w 16(a7),d2
	mulu 8(a7),d2
	add.l d2,d0
	move.w 14(a7),d2
	mulu 10(a7),d2
	add.l d2,d0

	move.w 18(a7),d1
	mulu 8(a7),d1
	swap d1
	add.w d1,d0
	clr.w d1
	swap d0
	addx.w d1,d0
	swap d0

	move.w 16(a7),d2
	mulu 10(a7),d2
	swap d2
	add.w d2,d0
	clr.w d2
	swap d0
	addx.w d2,d0
	swap d0
	add.l d2,d1
	moveq.l #0,d2
	addx.l d2,d0

	move.w 18(a7),d2
	mulu 10(a7),d2
	add.l d2,d1
	moveq.l #0,d2
	addx.l d2,d0

	rts

; Float Functions
__addbf3:
	moveq.l #0,d0
	bra.s	__fp_entry
__subbf3:
	moveq.l #4,d0
	bra.s	__fp_entry
__mulbf3:
	moveq.l #8,d0
	bra.s	__fp_entry
__divbf3:
	moveq.l #12,d0
	bra.s	__fp_entry
__negbf2:
	moveq.l #16,d0
	bra.s	__fp_entry
__floatunssibf:			; TODO: Really support 'unsigned long' --> BCD convertion
__floatsibf:
	moveq.l #28,d0
__fp_entry:
	link a6,#-10
	lea	28(a6),a1
	bsr.s 	__fp_call
	movem.l -10(a6),d0-d1
	move.w -2(a6),d2
	unlk a6
	rts
__cmpbf2:
__nebf2:
__eqbf2:
__gebf2:
__ltbf2:
__gtbf2:
__lebf2:
	moveq.l #20,d0
	bra.s __fp_entry_1
__fixbfsi:
__fixunsbfsi:
	moveq.l #24,d0
__fp_entry_1:
	lea 24(sp),a1
__fp_call:
	add.w #728,d0
	move.l -(a1),-(sp)
	move.l -(a1),-(sp)
	move.l -(a1),-(sp)
	move.l -(a1),-(sp)
	move.l -(a1),-(sp)
	lea	ROMCALLS_TABLE,a0
	move.l 0(a0,d0.w),a0
	jsr (a0)
	lea 20(sp),sp
	rts
