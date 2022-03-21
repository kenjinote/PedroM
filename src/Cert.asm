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

	include "Const.h"
	
        ;; Exported FUNCTIONS: 
        xdef copen
        xdef copensub
        xdef ceof
        xdef cfindfield
        xdef cgetc
        xdef cgetflen
        xdef cgetfnl
        xdef cgetnl
        xdef cgetns
        xdef ctell
        xdef cwrite
        xdef cread
        xdef cputns
        xdef cputnl
        xdef cputhdr


;void copen (CFILE *context, char *data, unsigned long size);
copen:
	move.l	4(a7),a0
	move.l	8(a7),a1
	move.l	a1,(a0)+
	move.l	a1,(a0)+
	adda.l	12(a7),a1
	move.l	a1,(a0)+
	clr.w	(a0)
	rts
	
;void copensub (CFILE *context, CERT_FIELD *subfield);
copensub:
	move.l	4(a7),a0	; context
	move.l	8(a7),a1	; subfield
	move.l	4(a1),-(a7)
	move.l	4(a1),-(a7)
	move.l	a0,-(a7)
	bsr.s	copen
	lea	12(a7),a7
	rts
	
;short ceof (CFILE *context);
ceof:
	move.l	4(a7),a0
	moveq	#1,d0
	tst.w	12(a0)
	bne.s	\End
		move.l	4(a0),d1
		cmp.l	8(a0),d1
		bcc.s	\End
			moveq	#0,d0
\End	rts	

;short cfindfield (CFILE *context, unsigned short FieldID, CERT_FIELD *dest);
cfindfield:
	movem.l	d3/a2-a3,-(a7)
	move.l	16(a7),a2
	move.w	20(a7),d3
	move.l	22(a7),a3
\Loop		pea	(a3)
		pea	(a2)
		jsr	cread
		addq.l	#8,a7
		tst.w	d0
		beq.s	\False
		cmp.w	(a3),d3
		bne.s	\Check
			moveq	#1,d0
			bra.s	\End
\Check:		cmpi.w	#$FFF0,(a3)
		bne.s	\Loop
\False:	clr.w	d0	
\End	movem.l	(a7)+,d3/a2-a3
	rts

;unsigned char cgetc (CFILE *context);
cgetc:
	move.l	4(a7),a0
	move.l	4(a0),a1
	move.b	(a1)+,d0
	move.l	a1,4(a0)
	rts
	
;unsigned long cgetflen (CFILE *context, unsigned short FieldIDWord);
cgetflen:
	move.l	d3,-(a7)
	subq.l	#4,a7
	move.l	12(a7),a0
	moveq	#$F,d3
	and.w	16(a7),d3
	moveq	#0,d2
	cmpi.w	#$FFF0,16(a7)
	bcc.s	\End
	move.b	d3,d2
	move.l	a0,(a7)
	cmpi.w	#$D,d3
	blt.s	\End
	bne.s	\Next
		bsr.s	cgetc
		moveq	#0,d2
		move.b	d0,d2
		bra.s	\End
\Next:	cmpi.w	#$E,d3
	bne.s	\Next2
		jsr	cgetns
		moveq	#0,d2
		move.w	d0,d2
		bra.s	\End
\Next2	jsr	cgetnl
	move.l	d0,d2
\End	move.l	d2,d0
	addq.l	#4,a7
	move.l	(a7)+,d3
	rts

;long cgetfnl (CERT_FIELD *field);
cgetfnl:
	move.l	4(a7),a1
	moveq	#0,d0
	move.l	4(a1),d1
	move.l	8(a1),a1
	bra.s	\EnterLoop
\Loop		lsl.l	#8,d0
		moveq	#0,d2
		move.b	(a1)+,d2
		add.l	d2,d0
\EnterLoop	dbf	d1,\Loop
		subi.l	#$10000,d1
		cmpi.l	#-1,d1
		bne.s	\Loop
	rts

;long cgetnl (CFILE *context);
cgetnl:
	move.l	d3,-(a7)
	move.l	8(a7),-(a7)
	jsr	cgetc
	moveq	#0,d3
	move.b	d0,d3
	jsr	cgetc
	lsl.l	#8,d3
	move.b	d0,d3
	jsr	cgetc
	lsl.l	#8,d3
	move.b	d0,d3
	jsr	cgetc
	lsl.l	#8,d3
	move.b	d0,d3
	move.l	d3,d0
	addq.l	#4,a7
	move.l	(a7)+,d3
	rts

;short cgetns (CFILE *context);
cgetns:
	move.l	d3,-(a7)
	move.l	8(a7),-(a7)
	jsr	cgetc
	move.b	d0,d3
	jsr	cgetc
	lsl.w	#8,d3
	move.b	d0,d3
	move.w	d3,d0
	addq.l	#4,a7
	move.l	(a7)+,d3
	rts
;unsigned long ctell (CFILE *context);
ctell:
	move.l	4(a7),a0
	move.l	4(a0),d0
	sub.l	(a0),d0
	rts
	
;short cwrite (CFILE *context, CERT_FIELD *source);
cwrite:
	movem.l	d3/a2-a3,-(a7)
	move.l	16(a7),a2
	move.l	20(a7),a3
	move.l	4(a3),d3
	move.l	d3,-(a7)
	move.w	(a3),-(a7)
	pea	(a2)
	jsr	cputhdr
	lea	10(a7),a7
	tst.w	d0
	beq.s	\End
		move.l	4(a2),a0
		move.l	8(a3),a3
		bra.s	\InLoop
\Loop			move.b	(a3)+,(a0)+
\InLoop			dbf	d3,\Loop
			subi.l	#$10000,d3
			cmpi.l	#-1,d3
			bne.s	\Loop
		move.l	a0,4(a2)
		moveq	#1,d0
\End	movem.l	(a7)+,d3/a2-a3
	rts
					
;short cread (CFILE *context, CERT_FIELD *dest);
cread:
	movem.l	d3/a2-a4,-(a7)
	move.l	$18(a7),a3
	move.l	$14(a7),a2
	pea	(a2)
	jsr	ceof
	addq.l	#4,a7
	tst.w	d0
	beq.s	\Cont
		move.w	#$FFF0,(a3)+
		move.w	#$2,(a3)+
		clr.l	(a3)+
		clr.l	(a3)
		bra.s	\End
\Cont	move.l	4(a2),a4
	cmpi.b	#$FF,(a4)
	bne.s	\O1
	cmpi.b	#$FF,1(a4)
	beq.s	\O1
		addq.l	#1,a4
	move.l	a4,4(a2)
\O1	pea	(a2)
	jsr	cgetns
	move.w	d0,d3
	move.w	d0,-(a7)
	pea	(a2)
	jsr	cgetflen
	lea	10(a7),a7
	move.l	d0,d1
	andi.w	#$FFF0,d3
	move.l	4(a2),d0
	sub.w	a4,d0
	move.w	d3,(a3)+
	move.w	d0,(a3)+
	move.l	d1,(a3)+
	move.l	4(a2),(a3)
	add.l	d1,4(a2)
	cmpi.w	#$FFF0,d3
	bne.s	\O2
		move.w	#1,$C(a2)
\O2	moveq	#1,d0
\End	movem.l	(a7)+,d3/a2-a4
	rts
								
;void cputns (CFILE *context, short s);
cputns:	
	move.l	4(a7),a0
	move.l	4(a0),a1
	move.b	8(a7),(a1)+
	move.b	9(a7),(a1)+
	move.l	a1,4(a0)
	rts
	
;void cputnl (CFILE *context, long l); 
cputnl:
	move.l	4(a7),a0
	move.l	4(a0),a1
	move.b	8(a7),(a1)+
	move.b	9(a7),(a1)+
	move.b	10(a7),(a1)+
	move.b	11(a7),(a1)+
	move.l	a1,4(a0)
	rts

;short cputhdr (CFILE *context, unsigned short FieldID, unsigned short len); 
cputhdr:
	movem.l	d3-d5/a2,-(a7)
	move.l	$14(a7),a2
	move.l	$1A(a7),d3
	moveq	#$C,d0
	cmp.l	d0,d3
	bhi.s	\Cont
		moveq	#2,d4
		move.w	d3,d5
		bra.s	\Do
\Cont	cmpi.l	#$100,d3
	bcc.s	\Cont2
		moveq	#3,d4
		moveq	#13,d5
		bra.s	\Do
\Cont2	cmpi.l	#$10000,d3
	bcc.s	\Cont3
		moveq	#4,d4
		moveq	#14,d5
		bra.s	\Do
\Cont3	moveq	#6,d4
	moveq	#15,d5
\Do	move.l	4(a2),a0
	adda.l	d4,a0
	adda.l	d3,a0
	cmp.l	8(a2),a0
	bls.s	\Ok
		clr.w	d0
		bra.s	\End2
\Ok	move.w	$18(a7),d0
	andi.w	#$FFF0,d0
	or.w	d5,d0
	move.w	d0,-(a7)
	pea	(a2)
	jsr	cputns
	addq.l	#6,a7
	cmpi.w	#3,d4
	blt.s	\End
		beq.s	\Byte
		cmpi.w	#4,d4
		beq.s	\Word
\Long:		move.l	d3,-(a7)
		pea	(a2)
		jsr	cputnl
		addq.l	#8,a7
		bra.s	\End
\Byte:		move.l	4(a2),a1
		move.b	d3,(a1)+
		move.l	a1,4(a2)
		bra.s	\End
\Word:		move.w	d3,-(a7)
		pea	(a2)
		jsr	cputns
		addq.l	#6,a7
\End	moveq	#1,d0			
\End2	movem.l	(a7)+,d3-d5/a2
	rts
						
