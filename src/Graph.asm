;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003, 2004, 2005-2008 Patrick Pelissier
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

        ;; Exported FUNCTIONS: 
        xdef InitGraphSystem
        xdef ReInitGraphSystem
        xdef FontSetSys
        xdef FontGetSys
        xdef PortRestore
        xdef PortSet
        xdef PortSet_inline
        xdef RestoreScrState
        xdef RestoreScrState_reg
        xdef SaveScrState
        xdef SaveScrState_reg
        xdef SetCurAttr
        xdef SetCurClip
        xdef SetCurClip_reg
        xdef MakeWinRect
        xdef ScrToHome
        xdef ScrToWin
        xdef ScrRectOverlap
        xdef QScrRectOverlap
        xdef horiz
        xdef vert
        xdef ScrRectScroll
        xdef ScrRectShift
        xdef MoveTo
        xdef DrawLine
        xdef DrawLineBlack
        xdef DrawLineWhite
        xdef DrawLineXor
        xdef clrscr
        xdef ScreenClear
        xdef DrawClipPix
	xdef DrawClipPix_reg
        xdef DrawPix
        xdef DrawPix_Inline
        xdef _GetScrPtr
        xdef GetPix
        xdef GetPix_reg
        xdef DrawClipChar
        xdef DrawChar
        xdef DrawStrMax
        xdef DrawStrAttrTable
        xdef DrawStr
        xdef DrawStr_Entry
        xdef FontCharWidth
        xdef DrawStrWidth
        xdef DrawStrWidth_reg
        xdef StrWidth
        xdef ST_helpMsg
        xdef ST_helpMsg_reg
        xdef ST_eraseHelp
        xdef ST_IsHelpQuit
        xdef ST_folder
        xdef ST_busy
        xdef ST_batt
        xdef ST_modKey
        xdef ST_modKey_table
        xdef ST_graph
        xdef ST_angle
        xdef ST_precision
        xdef ST_readOnly
        xdef ST_stack
        xdef ST_refDsp
        xdef BitmapInit
        xdef BitmapSize
        xdef BitmapSize_reg
        xdef BitmapNew
        xdef DrawClipRect
        xdef DrawMultiLines
        xdef DrawIcon
        xdef DrawIcon_reg
        xdef DrawFkey
        xdef FillTriangle
        xdef DrawTriangleFillHLine
        xdef Draw_triangle
        xdef FillLines2
	xdef LineTo
	xdef ScrRectFill
	xdef ScrRect
	xdef STRect
	xdef FullRect
	xdef MenuRect

; ***************************************************************
; *								*
; *		Pedrom		/	Graph			*
; *								*
; ***************************************************************

; ***************************************************************
; 			Set functions
; ***************************************************************

; Reset the normal output of all graph functions and clear the screen.
InitGraphSystem:
	bsr.s	ReInitGraphSystem
	bra	ScreenClear

; Reset the normal output of all graph functions.
ReInitGraphSystem:
	bsr.s	PortRestore
	move.w	#LCD_MEM/8,$600010		; Set $4C00 as VRAM for HW1
	clr.b	$700017				; Set $4C00 as VRAM for HW2
	move.b	#USED_FONT,CURRENT_FONT		; Set Current Font
	clr.w	CURRENT_ATTR			; Set Current Attr
	lea	ScrRect(pc),a0			; Set Current Clip area
	move.l	(a0),ScrRectRam			; ScrRectRam is a RAM copy of ScrRect
	jsr	SetCurClip_reg			; Set clipping
	move.w	#$8001,PRINTF_LINE_COUNTER	; Reset printf counter
	jmp	InitTerminal			; Init stdin/stdout/stderr
	
;unsigned char FontSetSys (short Font);
FontSetSys:
	move.b	CURRENT_FONT,d0
	move.b	5(a7),CURRENT_FONT
	rts

;unsigned char FontGetSys(void);
FontGetSys:
	move.b	CURRENT_FONT,d0
	rts
	
; To do: Support GrayScale graphics
;void PortRestore (void);
PortRestore:
	move.l	#LCD_MEM,CURRENT_SCREEN
	move.w	#30,CURRENT_INCY
	move.w	#239,CURRENT_SIZEX
	move.w	#127,CURRENT_SIZEY
	clr.b	CURRENT_GRAPH_UNALIGNED
	rts

;void PortSet (void *vm_addr, short x_max, short y_max); ; SideEffect: Do not destroy a0/a1
PortSet:
	move.l	4(a7),CURRENT_SCREEN	; Current Target for Graph functions
	move.w	10(a7),CURRENT_SIZEY	; Height
	move.w	8(a7),d0	
	move.w	d0,CURRENT_SIZEX	; Width
PortSet_inline:
	lsr.w	#3,d0			;/8
	addq.w	#1,d0			;+1 
	move.w	d0,CURRENT_INCY		; Some programs give a non multiple of 2 arg (ex 1 !)
	or.l	CURRENT_SCREEN,d0	; In this case, and if the screen is non aligned
	andi.w	#1,d0			; Tadam 
	move.b	d0,CURRENT_GRAPH_UNALIGNED	; Set this variable and use slow functions (Byte access)
	rts

;void RestoreScrState (const void *buffer);
RestoreScrState:
	move.l	4(a7),a0
RestoreScrState_reg:
	move.l	(a0)+,CURRENT_SCREEN
	move.b	(a0)+,CURRENT_SIZEX+1
	move.b	(a0)+,CURRENT_SIZEY+1
	move.b	(a0)+,CURRENT_FONT
	addq.l	#1,a0
	move.w	(a0)+,CURRENT_ATTR
	move.w	(a0)+,CURRENT_POINT_X
	move.w	(a0)+,CURRENT_POINT_Y
	move.b	(a0)+,CLIP_MIN_X+1
	move.b	(a0)+,CLIP_MIN_Y+1
	move.b	(a0)+,CLIP_MAX_X+1
	move.b	(a0)+,CLIP_MAX_Y+1
	move.w	CURRENT_SIZEX,d0
	bra.s	PortSet_inline

;void SaveScrState (void *buffer);
SaveScrState:
	move.l	4(a7),a0
SaveScrState_reg:
	move.l	CURRENT_SCREEN,(a0)+
	move.b	CURRENT_SIZEX+1,(a0)+
	move.b	CURRENT_SIZEY+1,(a0)+
	move.b	CURRENT_FONT,(a0)+
	clr.b	(a0)+
	move.w	CURRENT_ATTR,(a0)+
	move.w	CURRENT_POINT_X,(a0)+
	move.w	CURRENT_POINT_Y,(a0)+
	move.b	CLIP_MIN_X+1,(a0)+
	move.b	CLIP_MIN_Y+1,(a0)+
	move.b	CLIP_MAX_X+1,(a0)+
	move.b	CLIP_MAX_Y+1,(a0)+
	rts
		
;short SetCurAttr (short Attr);
SetCurAttr:
	move.w	CURRENT_ATTR,d0
	move.w	4(a7),CURRENT_ATTR
	rts

;void SetCurClip (const SCR_RECT *clip);
SetCurClip:
	move.l	4(a7),a0
SetCurClip_reg:
	pea	(a2)
	lea	CLIP_MIN_X,a1
	lea	CLIP_TEMP_RECT,a2
	clr.w	d0
	moveq	#4-1,d1
\loop:		move.b	(a0)+,d0	; Read Scr Rect 
		move.b	1(a1),(a2)+	; Save Old SCR_RECT clip area to CLIP_TEMP_RECT, so that we can restore  it quite easily
		move.w	d0,(a1)+	; Write it
		dbra	d1,\loop
	move.l	(a7)+,a2
	rts

;WIN_RECT *MakeWinRect (short x0, short y0, short x1, short y1);
MakeWinRect:
	lea	WIN_RECT_X1,a0
	move.w	4(a7),(a0)+
	move.w	6(a7),(a0)+
	move.w	8(a7),(a0)+
	move.w	10(a7),(a0)+
	subq.l	#8,a0
	rts

;SCR_RECT *ScrToHome (SCR_RECT *rect); 
ScrToHome:
	move.l	4(a7),a0
	move.b	(a0),d0
	clr.b	(a0)+
	move.b	(a0),d1
	clr.b	(a0)+
	sub.b	d0,(a0)+
	sub.b	d1,(a0)+
	subq.l	#4,a0
	rts
	
;WIN_RECT *ScrToWin (const SCR_RECT *rect); 
ScrToWin:
	clr.l	WIN_RECT_X1
	clr.l	WIN_RECT_X2
	move.l	4(a7),a0	; Scr_rect
	move.b	(a0)+,WIN_RECT_X1+1
	move.b	(a0)+,WIN_RECT_Y1+1
	move.b	(a0)+,WIN_RECT_X2+1
	move.b	(a0)+,WIN_RECT_Y2+1
	lea	WIN_RECT_X1,a0
	rts

	
; ***************************************************************
; 			Rect functions
; ***************************************************************

;short ScrRectOverlap (const SCR_RECT *r1, const SCR_RECT *r2, SCR_RECT *r); 
ScrRectOverlap:
	move.l	4(a7),a0
	move.l	8(a7),a1
	bsr.s	QScrRectOverlap_reg
	tst.w	d0
	beq.s	\end
	
	move.l	4(a7),a0
	move.l	8(a7),a1
	; xmin
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bcc.s	\ok1
		move.b	-1(a1),d0
\ok1	lsl.w	#8,d0
	
	; ymin
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bcc.s	\ok3
		move.b	-1(a1),d0
\ok3	lsl.l	#8,d0

	; xmax
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bls.s	\ok2
		move.b	-1(a1),d0
\ok2	lsl.l	#8,d0	

	; ymax
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bls.s	\ok4
		move.b	-1(a1),d0
\ok4	
	move.l	12(a7),a0
	move.l	d0,(a0)
	moveq	#1,d0
\end:	rts

;short QScrRectOverlap (const SCR_RECT *r1, const SCR_RECT *r2);
QScrRectOverlap:
	move.l	4(a7),a0
	move.l	8(a7),a1
QScrRectOverlap_reg
	moveq	#0,d0
	move.b	(a0)+,d1	; xmin
	cmp.b	2(a1),d1	; xmax
	bhi.s	\end
	move.b	(a0)+,d1	; ymin
	cmp.b	3(a1),d1	; ymax
	bhi.s	\end
	
	move.b	(a0)+,d1	; xmax
	cmp.b	(a1),d1		; xmin
	bcs.s	\end
	move.b	(a0)+,d1	; ymax
	cmp.b	1(a1),d1	; ymin
	bcs.s	\end
		moveq	#1,d0
\end:	rts	
	
;void ScrRectFill (const SCR_RECT *rect, const SCR_RECT *clip, short Attr);
ScrRectFill:	
	movem.l d3-d4,-(a7)

	move.l	8+4*2(a7),a0	; Clip Area
	jsr	SetCurClip_reg

	move.l	4+4*2(a7),a1	; SCR_RECT
	clr.w	d0
	clr.w	d1
	clr.w	d2
	clr.w	d4

	move.b	(a1)+,d0	; X1
	move.b	(a1)+,d1	; Y1
	move.b	(a1)+,d2	; X2
	move.b	(a1)+,d4	; Y2
	sub.w	d1,d4
	bge.s	\ok
		neg.w	d4
\ok
	move.w	12+4*2(a7),d3	; Attr
\loop:		bsr.s	horiz
		addq.w	#1,d1
		dbra	d4,\loop
	; Restore Clip Area
	lea	CLIP_TEMP_RECT,a0
	jsr	SetCurClip_reg
	movem.l	(a7)+,d3-d4
	rts

horiz:
;Input:	d0.w = x1
;	d1.w = y
;	d2.w = x2
;	d3.w = color  	0 -> White	A_REVERSE
;			1 -> Black	A_NORMAL
;			2 -> XOR	A_XOR

	movem.l	d0-d4/a1,-(a7)

	; Check Clipping Y
	cmp.w	CLIP_MIN_Y,d1
	blt	\Exit
	cmp.w	CLIP_MAX_Y,d1
	bgt	\Exit
	; Ord X values
	cmp.w	d0,d2
	bgt.s	\plush
		exg	d0,d2
\plush:
	; Check Clipping X
	move.w	CLIP_MIN_X,d4
	cmp.w	d4,d2
	blt	\Exit
	cmp.w	d4,d0
	bge.s	\ok1
		move.w	d4,d0
\ok1:
	move.w	CLIP_MAX_X,d4
	cmp.w	d4,d0
	bgt	\Exit
	cmp.w	d4,d2
	ble.s	\ok2
		move.w	d4,d2
\ok2		
	; Get Screen Ptr
	move.l	CURRENT_SCREEN,a1
	mulu.w	CURRENT_INCY,d1
	adda.l	d1,a1

	; Check alignement
	tst.b	CURRENT_GRAPH_UNALIGNED
	bne	\horiz_slow
	
	moveq	#15,d4
	eor.w	d4,d2
	and.w	d2,d4
	lsr.w	#4,d2

	moveq	#$F,d1
	and.b	d0,d1
	lsr.w	#4,d0

	sub.b	d0,d2	; d1 = Nbr d'octets à remplir brutalement
	bne.s	\Long_line
		add.w	d0,d0
		adda.w	d0,a1	; A1 -> Screen + What I need
	
		moveq	#-1,d0	; D0 = #$FFFFFFFF
		add.w	d1,d4
		lsl.w	d4,d0
		lsr.w	d1,d0

		subq.b	#1,d3
		blt.s	\blanc
		beq.s	\black
\invert			; Invert
			eor.w	d0,(a1)
			bra.s	\Exit
\blanc:			; Blanc
			not.w	d0
			and.w	d0,(a1)
			bra.s	\Exit
\black:			; Noir
			or.w	d0,(a1)
			bra.s	\Exit

\Long_line:
	add.w	d0,d0
	adda.w	d0,a1	; A0 -> Screen + What I need

	moveq	#-1,d0	; D0 = #$FFFFFFFF
	lsr.w	d1,d0

	subq.b	#1,d3
	blt.s	\blanc2
	beq.s	\black2
		; Invert
\invert2	eor.w	d0,(a1)+
		moveq	#-1,d0
		subq.b	#2,d2
		blt.s	\FinishI
\LoopI:			not.w	(a1)+
			dbf	d2,\LoopI
\FinishI:	lsl.w	d4,d0
		eor.w	d0,(a1)
		bra.s	\Exit

\blanc2		; Blanc
		not.w	d0
		and.w	d0,(a1)+
		moveq	#0,d0
		subq.b	#2,d2
		blt.s	\FinishB
\LoopB:			move.w	d0,(a1)+
			dbf	d2,\LoopB
\FinishB:	moveq	#-1,d0
		lsl.w	d4,d0
		not.w	d0
		and.w	d0,(a1)
		bra.s	\Exit

\black2:	; Noir 
		or.w	d0,(a1)+

		moveq	#-1,d0
		subq.b	#2,d2
		blt.s	\FinishN
\LoopN:			move.w	d0,(a1)+
			dbf	d2,\LoopN
\FinishN:	lsl.w	d4,d0
		or.w	d0,(a1)
\Exit:
	movem.l	(a7)+,d0-d4/a1
	rts

; In case we can not used the fast word fill...
\horiz_slow:
;Input:	d0.w = x1 (clipped)
;	d2.w = x2 (clipped)
;	d3.w = color  	0 -> White
;			1 -> Black
;			2 -> XOR
;	a1 -> Screen
	sub.w	d0,d2		; Largeur
	move.w	d0,d4
	lsr.w	#3,d4		; / 8
	add.w	d4,a1		
	not.b	d0
	andi.w	#7,d0

\Start:
	tst.b	d3
	beq.s	\Blanc
	cmp.b	#2,d3
	beq.s	\Change

\Noir:		bset	d0,(a1)
		subq.w	#1,d2
		bmi.s	\Exit
		dbra	d0,\Noir
	addq.l	#1,a1
\Noir2:
		subq.w	#8,d2
		blt.s	\End
		st.b	(a1)+
		bra.s	\Noir2

\Change:
		bchg	d0,(a1)
		subq.w	#1,d2
		bmi.s	\Exit
		dbra	d0,\Change
	addq.l #1,a1
\Change2:
		subq.w	#8,d2
		blt.s	\End
		not.b	(a1)+
		bra.s	\Change2

\Blanc:
		bclr	d0,(a1)
		subq.w	#1,d2
		bmi.s	\Exit
		dbra	d0,\Blanc
	addq.l #1,a1
\Blanc2:
		subq.w	#8,d2
		blt.s	\End
		clr.b	(a1)+
		bra.s	\Blanc2

\End:	moveq	#7,d0
	addq.w	#8,d2
	bra.s	\Start

vert:
;Input:	d0.w = x
;	d1.w = y1
;	d2.w = y2
	movem.l	d0-d5/a0,-(a7)
	; Check Clipping X
	cmp.w	CLIP_MIN_X,d0
	blt	\Exit
	cmp.w	CLIP_MAX_X,d0
	bgt	\Exit
	; Ord Y values
	cmp.w	d1,d2
	bgt.s	\plush
		exg	d0,d2
\plush:
	; Check Clipping Y
	move.w	CLIP_MIN_Y,d4
	cmp.w	d4,d2
	blt	\Exit
	cmp.w	d4,d1
	bge.s	\ok1
		move.w	d4,d1
\ok1:
	move.w	CLIP_MAX_Y,d4
	cmp.w	d4,d1
	bgt	\Exit
	cmp.w	d4,d2
	ble.s	\ok2
		move.w	d4,d2
\ok2		

	sub.w	d1,d2	;hauteur
	move.w	d2,d4
	
	jsr	_GetScrPtr

	move.w	CURRENT_INCY,d5

	clr.b	d2
	bset	d1,d2
	subq.w	#1,d3
	blt.s	\blanc 
	bgt.s	\invert
	; Black
\loop
		or.b	d2,(a0)
		adda.w	d5,a0
		dbf	d4,\loop
	bra.s	\Exit
	; Invertion
\invert
		eor.b	d2,(a0)
		adda.w	d5,a0
		dbf	d4,\invert
	bra.s	\Exit
	; White
\blanc
	not.b	d2
\loop_b
		and.b	d2,(a0)
		adda.w	d5,a0
		dbf	d4,\loop_b
\Exit	movem.l	(a7)+,d0-d5/a0
	rts

;void ScrRectScroll (const SCR_RECT *rect, const SCR_RECT *clip, short NumRows, short Attr); 
ScrRectScroll:
	movem.l	d3-d6/a2,-(a7)
	move.w	(4+4*5+4*2+0)(a7),d3	; NumRows
	move.w	(4+4*5+4*2+2)(a7),d5	; Attr	
	move.w	CURRENT_INCY,d6
	subq.l	#4,a7	
	move.l	a7,a2		; Rect to scroll
	pea	(a2)
	move.l	(4+4+4+4+4*5)(a7),-(a7)	; Rect
	move.l	(4+4+4+4+4*5)(a7),-(a7)	; CLip
	jsr	ScrRectOverlap
	tst.w	d0
	beq	\end		; No overlap => No Scroll
		move.l	CURRENT_SCREEN,a0	; Screen Ptr
		; Because I am lazy, I assume x1 and x2 are 8x.
		; Otherwise I should do a pixel copy, and not a byte copy...
		clr.w	d0
		move.b	(a2),d0
		lsr.w	#3,d0		; X1 / 8
		clr.w	d2
		move.b	1(a2),d2	; Y1
		clr.w	d4
		move.b	3(a2),d4	; Y2-Y1
		sub.w	d2,d4
		mulu.w	d6,d2		; Y1 *30
		add.w	d0,d2
		adda.w	d2,a0		; Starting Address
		clr.w	d1
		move.b	2(a2),d1
		lsr.w	#3,d1		; X2 / 8
		sub.w	d0,d1		; d1 = Number of bytes to copy
		blt.s	\end
			tst.w	d3
			bge.s	\UpWards
			neg.w	d3
			sub.w	d3,d4	; ScrollRow > Height ?
			bls.s	\Fill
				sub.b	d4,3(a2)	; Y2 - D4
				move.w	d4,d0
				mulu.w	d6,d0
				adda.w	d0,a0		; A0 = A0 + 30*(Y2-Y1-Row)
				move.w	d3,d0
				mulu.w	d6,d0
				lea	0(a0,d0.w),a1	; A1 = A0 + 30*(Y2-Y1-Row) + 30 * Row
\VLoop2					move.w	d1,d0	; d0 = Bytes to copy
					movem.l	a0/a1,-(a7)
\HLoop2						move.b	(a1)+,(a0)+
						subq.w	#1,d0							
						bge.s	\HLoop2
					movem.l	(a7)+,a0-a1
					suba.w	d6,a0
					suba.w	d6,a1
					subq.w	#1,d4
					bne.s	\VLoop2				
				bra.s	\Fill
\UpWards:		sub.w	d3,d4	; ScrollRow > Height ?
			bls.s	\Fill
				add.b	d4,1(a2)	; Y1 + D4
				move.w	d3,d0
				mulu.w	d6,d0
				lea	0(a0,d0.w),a1	
\VLoop					move.w	d1,d0	; d0 = Bytes to copy
					movem.l	a0/a1,-(a7)
\HLoop						move.b	(a1)+,(a0)+
						subq.w	#1,d0							
						bge.s	\HLoop
					movem.l	(a7)+,a0-a1
					adda.w	d6,a0
					adda.w	d6,a1
					subq.w	#1,d4
					bne.s	\VLoop
\Fill:			move.w	d5,-(a7)
			pea	(a2)
			pea	(a2)
			jsr	ScrRectFill
\end	lea	4(a2),a7
	movem.l	(a7)+,d3-d6/a2
	rts

;void ScrRectShift (const SCR_RECT *rect, const SCR_RECT *clip, short NumCols, short Attr);
ScrRectShift:
	movem.l	d3-d7/a2-a6,-(a7)
	; Read args
	move.l	(40+4)(a7),a4		; Rect
	move.l	(40+8)(a7),a3		; Clip
	move.w	(40+12)(a7),d4		; NumCols
	move.w	(40+14)(a7),d5		; ATTR	
	; Alloc Buffers
	subq.l	#8,a7				; 2 Buffers
	move.l	a7,a2				; Rect to scroll
	; Source = Overlap(rect & clip)
	pea	(a2)				; SourceRect
	pea	(a4)				; Rect
	pea	(a3)				; Clip
	jsr	ScrRectOverlap			; Intersection of the 2 rect
	tst.w	d0
	beq	\end				; No overlap => No Shift
	; dest = Overlap(rect-NumCols & clip)
	move.l	(a4),4(a2)			; Copy rect
	tst.w	d4
	bge.s	\ShiftLeft
		sub.b	d4,4(a2)
		sub.b	d4,6(a2)
		bra.s	\O2
\ShiftLeft
	sub.b	d4,4(a2)
	bcc.s	\O1
		clr.b	4(a2)
\O1	sub.b	d4,6(a2)			; WARNING: Overflow !
	bcc.s	\O2
		clr.b	6(a2)
\O2	
	pea	4(a2)				; DestRect
	pea	4(a2)				; Rect
	pea	(a3)				; Clip
	jsr	ScrRectOverlap			; Intersection of the 2 rect
	tst.w	d0
	beq	\Fill				; No overlap => Fill source
	; dest = Overlap(dest+NumCols & clip)
	add.b	d4,4(a2)
	add.b	d4,6(a2)			; WARNING: Overflow !
	pea	4(a2)				; DestRect
	pea	(a2)				; Source
	pea	4(a2)				; Dest
	jsr	ScrRectOverlap			; Intersection of the 2 rect (MUST Overlap)
	; Get the region dest
	jsr	\ReadRect	; Read Rect (d0, d1, d2, d3)
	jsr	BitmapNew	
	move.w	d0,d7		; Handle
	beq.s	\Fill		; Error memory
	; Fill the region source
	move.w	d5,-(a7)		; ATTR
	pea	(a2)			; ScrRect to fill
	pea	(a2)			; "
	jsr	ScrRectFill
	; Put the Bitmap
	move.w	d7,a0
	trap	#3		; Deref Bitmap
	move.w	#4,-(a7)	; ATTR_REPLACE
	pea	ScrRect(pc)	; CLipping
	pea	(a0)
	jsr	\ReadRect
	sub.w	d4,d0
	move.w	d1,-(a7)	; X
	move.w	d0,-(a7)	; Y
	jsr	BitmapPut
	; Free the region
	move.w	d7,-(a7)
	jsr	HeapFree
	bra.s	\end
\Fill:	move.w	d5,-(a7)		; ATTR
	pea	(a2)			; ScrRect to fill
	pea	(a2)			; "
	jsr	ScrRectFill
\end	lea	8(a2),a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts
\ReadRect
	lea	4(a2),a0
	clr.w	d0
	move.b	(a0)+,d0
	clr.w	d1
	move.b	(a0)+,d1
	clr.w	d2
	move.b	(a0)+,d2
	clr.w	d3
	move.b	(a0)+,d3
	rts
	
; ***************************************************************
; 			Line functions
; ***************************************************************

;void MoveTo (short x, short y); 
MoveTo:
	move.w	4(a7),CURRENT_POINT_X
	move.w	6(a7),CURRENT_POINT_Y
	rts

;void LineTo (short x, short y);
LineTo:		; To fix use DrawClipLine
	move.w	CURRENT_ATTR,-(a7)
	move.w	CURRENT_POINT_Y,-(a7)
	move.w	CURRENT_POINT_X,-(a7)
	move.w	2+4+6(a7),-(a7)
	move.w	(a7),CURRENT_POINT_Y
	move.w	4+6+2(a7),-(a7)
	move.w	(a7),CURRENT_POINT_X
	bsr.s	DrawLine
	lea	(2+2+2+2+2)(a7),a7
	rts

;void DrawLine (short x0, short y0, short x1, short y1, short Attr);
DrawLine:
	movem.l d3-d7/a2,-(a7)
	move.w	4+6*4+0(a7),d0		; X1
	move.w	4+6*4+2(a7),d1		; Y1
	move.w	4+6*4+4(a7),d2		; X2
	move.w	4+6*4+6(a7),d3		; Y2
	move.l	CURRENT_SCREEN,a0
	move.w	CURRENT_INCY,a2
	; Classement des points
	cmp.w	d0,d2
	bge.s	\no_exg
		exg	d2,d0
		exg	d1,d3
\no_exg:
	; * 30
	move.w	a2,d4
	mulu.w	d1,d4	; d4 = '30' * d1

	; X / 8 
	move.w	d0,d6
	lsr.w	#3,d6		; x/8->x
	add.w	d6,d4		; D4 = 30*y + x /8
	adda.w	d4,a0

	move.w	d0,d6
	not.w	d6
	and.w	#07,d6		;obtient le pixel à changer ; *

	; Calcul de Dx, Dy et Offset
	move.w	d2,d5
	sub.w	d0,d5		; D5 = Dx = x2 - x1 >0
	move.w	a2,d4		; +30
	move.w	d3,d7
	sub.w	d1,d7		; D7 = Dy = y2 - y1
	bcc.s	\no
		neg.w	d4	; -30
		neg.w	d7
\no:	
	move.w	4+6*4+8(a7),d2		; Attr
	beq	DrawLineWhite
	subq.w	#1,d2
	bne	DrawLineXor
	
DrawLineBlack:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	\up
	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	\loop1b		; 
\loop1a:
	bset.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	\mb
\ma:	subq.w	#1,d6	; *
	bge.s	\OK1a
		moveq	#7,d6
		addq.w	#1,a0
\OK1a:	dbra	d2,\loop1a
	bra.s	\end
\loop1b:
	bset.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	\ma
\mb:	subq.w	#1,d6	; *
	bge.s	\OK1b
		moveq	#7,d6
		addq.w	#1,a0
\OK1b:	dbra	d2,\loop1b
	bra.s	\end
	; Dx < Dy
\up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	\loop2b
\loop2a:
	bset.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	\m2b
\m2a	adda.w	d4,a0
	dbra	d3,\loop2a
	bra.s	\end
\loop2b:
	bset.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	\Ok2b
		moveq	#7,d6
		addq.w	#1,a0
\Ok2b:	add.w	d2,d7
	bmi.s	\m2a
\m2b:	adda.w	d4,a0
	dbra	d3,\loop2b
\end:	movem.l (a7)+,d3-d7/a2
	rts

DrawLineWhite:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	\up
	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	\loop1b		; 
\loop1a:
	bclr.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	\mb
\ma:	subq.w	#1,d6	; *
	bge.s	\OK1a
		moveq	#7,d6
		addq.w	#1,a0
\OK1a:	dbra	d2,\loop1a
	bra.s	\end
\loop1b:
	bclr.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	\ma
\mb:	subq.w	#1,d6	; *
	bge.s	\OK1b
		moveq	#7,d6
		addq.w	#1,a0
\OK1b:	dbra	d2,\loop1b
	bra.s	\end
	; Dx < Dy
\up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	\loop2b
\loop2a:
	bclr.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	\m2b
\m2a	adda.w	d4,a0
	dbra	d3,\loop2a
	bra.s	\end
\loop2b:
	bclr.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	\Ok2b
		moveq	#7,d6
		addq.w	#1,a0
\Ok2b:	add.w	d2,d7
	bmi.s	\m2a
\m2b:	adda.w	d4,a0
	dbra	d3,\loop2b
\end:	movem.l (a7)+,d3-d7/a2
	rts

DrawLineXor:
	cmp.w	d5,d7		; Cmp Dx et Dy 
	bcc.s	\up

	; Dx > Dy
	move.w	d5,d2		; D2 = Dx
	move.w	d7,d3
	sub.w	d5,d3
	add.w	d3,d3
	add.w	d7,d7
	sub.w	d7,d5
	neg.w	d5
	bpl.s	\loop1b		; 
\loop1a:
	bchg.b	d6,(a0)		; *
	add.w	d7,d5
	bpl.s	\mb
\ma:	subq.w	#1,d6	; *
	bge.s	\OK1a
		moveq	#7,d6
		addq.w	#1,a0
\OK1a:	dbra	d2,\loop1a
	bra.s	\end
\loop1b:
	bchg.b	d6,(a0)		; *
	adda.w	d4,a0
	add.w	d3,d5
	bmi.s	\ma
\mb:	subq.w	#1,d6	; *
	bge.s	\OK1b
		moveq	#7,d6
		addq.w	#1,a0
\OK1b:	dbra	d2,\loop1b
	bra.s	\end

	; Dx < Dy
\up:	
	move.w	d7,d3
	move.w	d5,d2
	sub.w	d7,d2
	add.w	d2,d2
	add.w	d5,d5
	sub.w	d5,d7
	neg.w	d7
	bpl.s	\loop2b
\loop2a:
	bchg.b	d6,(a0)		; *
	add.w	d5,d7
	bpl.s	\m2b
\m2a	adda.w	d4,a0
	dbra	d3,\loop2a
	bra.s	\end
	
\loop2b:
	bchg.b	d6,(a0)		; *
	subq.w	#1,d6		; *
	bge.s	\Ok2b
		moveq	#7,d6
		addq.w	#1,a0
\Ok2b:	add.w	d2,d7
	bmi.s	\m2a
\m2b:	adda.w	d4,a0
	dbra	d3,\loop2b

\end:	movem.l (a7)+,d3-d7/a2
	rts

; ***************************************************************
; 			Misc functions
; ***************************************************************

clrscr:
	clr.w	DeskTopWindow+WINDOW.Flags
	clr.w	CURRENT_POINT_X
	clr.w	CURRENT_POINT_Y
	clr.w	SHELL_SAVE_Y_POS
	move.w	#-32767,PRINTF_LINE_COUNTER
	bsr.s	ScreenClear
	move.b	#1,HELP_BEING_DISPLAYED
	bra	ST_eraseHelp
	
ScreenClear:
	moveq	#0,d2			; D2 = PATTERN
	move.l	CURRENT_SCREEN,a0	; a0 = DEST
	move.w	CURRENT_SIZEY,d0
	addq.w	#1,d0			
	mulu.w	CURRENT_INCY,d0		; d0 = SIZE
	bra	memset_reg_align
	
;void DrawClipPix (short x, short y); 
DrawClipPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
DrawClipPix_reg:	
	cmp.w	CLIP_MIN_X,d0
	blt.s	\end
	cmp.w	CLIP_MAX_X,d0
	bge.s	\end
	cmp.w	CLIP_MIN_Y,d1
	blt.s	\end
	cmp.w	CLIP_MAX_Y,d1
	bge.s	\end
	bsr.s	_GetScrPtr
	move.w	CURRENT_ATTR,d2
	bra.s	DrawPix_Inline
\end	rts

;void DrawPix (short x, short y, short Attr);
DrawPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
	bsr.s	_GetScrPtr
	move.w	8(a7),d2
DrawPix_Inline:
	beq.s	\revers
	subq.w	#1,d2
	beq.s	\normal
	bchg.b	d1,(a0)
	rts
\normal	bset.b	d1,(a0)
	rts
\revers	bclr.b	d1,(a0)
	rts

; In:
;	d0.w = X
;	d1.w = Y
; Out:
;	a0 -> Screen + 30*Y + X/8
;	d1 = 7-x&7
; Destroy:
;	d0-d2/a0
_GetScrPtr:
	move.l	CURRENT_SCREEN,a0
	move.w	d1,d2
	mulu.w	CURRENT_INCY,d2
	moveq	#7,d1
	eor.w	d1,d0
	and.w	d0,d1
	lsr.w	#3,d0
	add.w	d0,d2
	add.w	d2,a0
	rts
	
;short GetPix (short x, short y);
GetPix:
	move.w	4(a7),d0
	move.w	6(a7),d1
GetPix_reg:
	bsr.s	_GetScrPtr
	btst.b	d1,(a0)
	sne	d0
	ext.w	d0
	rts


; ***************************************************************
; 			String functions
; ***************************************************************

; void DrawClipChar (short x, short y, short c, const SCR_RECT *clip, short Attr);
DrawClipChar:
	move.w	4(a7),d0	; X
	move.w	6(a7),d1	; Y
	move.w	8(a7),d2	; Char
	move.l	10(a7),a0	; Clip Area
	movem.l	d3-d7/a2-a6,-(a7)
	; Get the Width/Height/Ptr/Mask of the char
	move.b	CURRENT_FONT,d5		; 0, 1 or 2
	subq.b	#1,d5
	beq.s	\medium
	blt.s	\small
		moveq	#8,d3		; Large Width
		moveq	#10,d6		; Large Height
		moveq	#-1,d4
		clr.b	d4			; d4.l = $FFFFFF00 = Masque pour Replace
		lea	MediumFont+$E00,a4
		mulu.w	d6,d2
		adda.w	d2,a4		; Character Ptr
		bra.s	\end_char
\small		lea	MediumFont+$800,a4 ; Small Font
		mulu.w	#6,d2		; x6
		adda.w	d2,a4		; Character Ptr
		move.b	(a4)+,d3	; Width
		moveq	#5,d6		; Height
		moveq	#-1,d4		; Start the calcul of the mask
		lsr.l	d3,d4		; Create the '0'
		rol.l	#8,d4		; Mask (it is left aligned)
		bra.s	\end_char
\medium:	moveq	#6,d3		; Medium Width
		moveq	#8,d6		; Medium Height
		move.l	#$FFFFFFC0,d4	; = Masque pour Replace
		lea	MediumFont,a4	; Medium Font
		lsl.w	#3,d2
		adda.w	d2,a4		; Character Ptr
\end_char:	
	; Check Big Clipping
	clr.w	d7
	add.w	d3,d0		; 
	add.w	d6,d1
	move.b	(a0)+,d7
	cmp.w	d7,d0
	ble	\NoDraw
	move.b	(a0)+,d7
	cmp.w	d7,d1
	ble	\NoDraw
	sub.w	d3,d0
	sub.w	d6,d1
	move.b	(a0)+,d7
	cmp.w	d7,d0
	bgt	\NoDraw
	move.b	(a0)+,d7
	cmp.w	d7,d1
	bgt	\NoDraw
	; Something to draw
	subq.l	#4,a0
	; Check Y clipping
	clr.w	d7
	move.b	1(a0),d7
	cmp.w	d7,d1
	bge.s	\NoYTop
		sub.w	d7,d1
		add.w	d1,d6		; Height + (y) (y <0)
		suba.w	d1,a4		; Y first char
		move.w	d7,d1
\NoYTop	move.w	d1,d2
	add.w	d6,d2
	move.b	3(a0),d7
	sub.w	d7,d2
	ble.s	\NoYDn
		sub.w	d2,d6		; Height - (Y+Height-Ydown)
		addq.w	#1,d6
\NoYDn	
	; Check X clipping
	moveq	#-1,d5			; Clipping Mask
	move.w	d0,d2
	add.w	d3,d2			; X +w
	move.w	d2,d7
	addq.w	#8,d7
	andi.w	#$F8,d7	
	move.w	d7,a2
	clr.w	d7
	move.b	(a0),d7
	cmp.w	d7,d0
	bge.s	\NoLf
		move.w	a2,d7		
		sub.b	(a0),d7
		moveq	#1,d5
		lsl.w	d7,d5
		subq.w	#1,d5		; d5 = 2^(((X+w)/8+1)*8-Xclip)-1
\NoLf	clr.w	d7
	move.b	2(a0),d7
	cmp.w	d7,d2
	ble.s	\NoRg
		move.w	a2,d7
		sub.b	2(a0),d7
		move.w	d5,-(a7)
		moveq	#1,d5
		lsl.w	d7,d5
		subq.w	#1,d5
		not.w	d5
		and.w	(a7)+,d5
\NoRg:	add.w	d3,d0			; X+= Len of first char	
	move.w	d0,d7			; Calcul des coordonnées X
	lsr.w	#4,d0			; / 16
	add.w	d0,d0			; *2
	mulu.w	CURRENT_INCY,d1		; 30 *d1
	add.w	d1,d0			; x/16*2 + 30 *y
	move.l	CURRENT_SCREEN,a1
	adda.w	d0,a1			; Ecran positionné
	; Calcul decalage
	moveq	#16-8,d2	; 16 - ((x+size)%16 - (8 - size)
	and.w	#15,d7		; (X+Size)%16
	sub.w	d7,d2
	add.w	d3,d2
	bge.s	\OkDeca		; If (<0)
		add.w	#16,d2	; deca+=16
		addq.w	#2,a1	; Ecran++
\OkDeca:
	; Display the char according to ATTR
	move.w	CURRENT_INCY,a6	; A6 = 30 (Inc Vertical)
	subq.w	#1,d6		; Line -1
	move.w	40+14(a7),d0	; Attr
	cmpi.w	#4,d0
	bhi.s	\NoDraw
	addq.w	#5,d0		; We must use the slow version
	add.w	d0,d0
	move.w	DrawStrAttrTable(Pc,d0.w),d0
	jsr	DrawStrAttrTable(Pc,d0.w)	; Get the draw char function
\NoDraw	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
; void DrawChar(short x, short y, 'short' c, short Attr);
DrawChar:
	move.w	4(a7),d0	; X
	move.w	6(a7),d1	; Y
	move.b	9(a7),DRAW_CHAR	; Char
	clr.b	NULL_CHAR
	move.w	10(a7),-(a7)	; Attr
	pea	DRAW_CHAR
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	bsr.s	DrawStr
	lea	10(a7),a7
	rts

; Contrary to Tios, DrawStr returns a char* (The first non-printed char).
; Usefull if you use DrawStrMax !
; Since you can easily displayed a long String:
;	while (*str)
;		str = DrawStrMax(x, y, str, Attr, Xmax), y+=8;

;char *DrawStrMax(short x, short y, const char *str, short Attr, short Xmax);
DrawStrMax:
	move.w	4(a7),d0
	move.w	6(a7),d1
	move.l	8(a7),a0
	move.w	12(a7),d2
	movem.l	d3-d7/a2-a6,-(a7)
	
	move.w	(14+10*4)(a7),d7		; X-max
	bra.s	DrawStr_Entry
	
DrawStrAttrTable:
	dc.w	_put_char_off-DrawStrAttrTable
	dc.w	_put_char_or-DrawStrAttrTable
	dc.w	_put_char_xor-DrawStrAttrTable
	dc.w	_put_char_and-DrawStrAttrTable
	dc.w	_put_char_replace-DrawStrAttrTable

	dc.w	_put_char_off_slow-DrawStrAttrTable
	dc.w	_put_char_or_slow-DrawStrAttrTable
	dc.w	_put_char_xor_slow-DrawStrAttrTable
	dc.w	_put_char_and_slow-DrawStrAttrTable
	dc.w	_put_char_replace_slow-DrawStrAttrTable
	
; Tigcc Fast Draw Hack Support
	dc.l	MediumFont+$800
	dc.l	MediumFont
	dc.l	MediumFont+$E00
	dc.l	'Pedr'

;char *DrawStr (short x, short y, const char *str, short Attr); 
DrawStr:
	move.w	4(a7),d0
	move.w	6(a7),d1
	move.l	8(a7),a0
	move.w	12(a7),d2
	movem.l	d3-d7/a2-a6,-(a7)
	
	move.w	#240,d7		; X-max = 240
DrawStr_Entry:
	cmpi.w	#4,d2
	bhi	\END
	
	tst.b	CURRENT_GRAPH_UNALIGNED	; Can we use fast version ?
	beq.s	\Yes
		addq.w	#5,d2		; No, we must use the slow version
\Yes	add.w	d2,d2
	move.w	DrawStrAttrTable(Pc,d2.w),d2
	lea	DrawStrAttrTable(Pc,d2.w),a5	; Get the draw char function
	
	moveq	#-1,d5			; Clipping Mask (Not used)

	move.w	CURRENT_INCY,a6		; A6 = 30 (Inc Vertical)
	mulu.w	CURRENT_INCY,d1		; Calcul des coordonnées Y = OK
	
	; Get the len of the first char
	moveq	#4,d3			; Small Font
	move.b	CURRENT_FONT,d2		; 0, 1 or 2
	add.b	d2,d3			; 4 + 1/2
	add.b	d2,d3			; 4 + 2/4 = 6 (Medium Font) or 8 (Large Font)
	subq.b	#1,d2
	bge.s	\end_char
		lea	MediumFont+$800,a1 ; Small Font
		clr.w	d2
		move.b	(a0),d2		; Read Char
		mulu.w	#6,d2		; x6
		move.b	0(a1,d2.w),d3
\end_char:	
	sub.w	d0,d7			; Xmax - X = DeltaX
	add.w	d3,d0			; X+= Len of first char	

	move.w	d0,d4			; Calcul des coordonnées X
	lsr.w	#4,d0			; / 16
	add.w	d0,d0			; *2
	add.w	d1,d0
	move.l	CURRENT_SCREEN,a1
	adda.w	d0,a1			; Ecran positionné

	; Calcul decalage (J'en ai bave pour trouver le bon calcul a faire... Pas si evident)
	moveq	#16-8,d2	; 16 - ((x+size)%16 - (8 - size)
	and.w	#15,d4		; (X+Size)%16
	sub.w	d4,d2
	add.w	d3,d2
	bge.s	\OkDeca		; If (<0)
		add.w	#16,d2	; deca+=16
		addq.w	#2,a1	; Ecran++
\OkDeca:

	; Selon la fonte courante
	move.b	CURRENT_FONT,d3
	subq.b	#1,d3
	blt.s	\small
	beq.s	\medium

	; Huge Font & Loop
	lea	MediumFont+$E00,a3
	moveq	#-1,d4
	clr.b	d4			; d4.l = $FFFFFF00 = Masque pour Replace
\LOOP_H
		clr.w	d0
		move.b	(a0)+,d0		; Test de présence d'un indicateur
		beq.s	\END			; Check end of Ptr
		cmpi.b	#KEY_ENTER,d0		; IF LINE_RETURN
		beq.s	\END			; End of line (Usefull for DrawText function !)
		subq.w	#8,d7			; Gestion X-max
		blt.s	\END			; If (X < 0) quit
		mulu.w	#10,d0			; x10
		lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
		moveq	#9,d6			; Height = 10
		jsr	(a5)			; Print Char
		subq.w	#8,d2
		bge.s	\LOOP_H
			and.w	#15,d2
			addq.w	#2,a1
			bra.s	\LOOP_H
\END	subq.l	#1,a0			; Return the last ptr to the first non-printed char
	movem.l	(a7)+,d3-d7/a2-a6
	moveq	#0,d1			; Some Buggy asm programs need it ! <JezzBall>
	moveq	#0,d0			; Some Buggy asm programs need it ! <MegaCar>
	rts


\medium	; Normal Font
	lea	MediumFont,a3
	move.l	#$FFFFFF03,d4		; = Masque pour Replace
\LOOP_N
		clr.w	d0
		move.b	(a0)+,d0		; Test end of string
		beq.s	\END
		cmpi.b	#KEY_ENTER,d0		; IF LINE_RETURN
		beq.s	\END			; End of line (Usefull for DrawText function !)
		subq.w	#6,d7			; Check X max
		blt.s	\END			; If (X <0) quit
		lsl.w	#3,d0			; x8
		lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
		moveq	#7,d6			; Height = 8
		jsr	(a5)			; Print Char
		subq.w	#6,d2
		bge.s	\LOOP_N
			and.w	#15,d2
			addq.w	#2,a1
			bra.s	\LOOP_N
	
\small	; Small Font
	lea	MediumFont+$800,a3
\LOOP_S
	clr.w	d0
	move.b	(a0)+,d0		; Test de présence d'un indicateur
	beq.s	\END
	cmpi.b	#KEY_ENTER,d0
	beq.s	\END
	mulu.w	#6,d0			; x6
	lea	0(a3,d0.w),a4		; A4 = Pointeur sur fonte
	move.b	(a4)+,d3		; Width
	sub.w	d3,d7			; Gestion Xmax
	blt.s	\END			; If (X<0) quit.
	moveq	#-1,d4			; Start the calcul of the mask
	lsr.l	d3,d4			; Create the '0'
	rol.l	#8,d4			; Mask (it is left aligned)
	moveq	#4,d6			; Height = 5
	jsr	(a5)			; Print Char
	sub.b	d3,d2
	bge.s	\LOOP_S
		and.w	#15,d2
		addq.w	#2,a1
		bra.s	\LOOP_S
	
; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_and:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.w	#2,a2
\put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			not.l	d0
			and.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\put
		rts
\word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			not.w	d0
			and.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_or:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.w	#2,a2
\put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			or.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\put
		rts
\word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			or.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_xor:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.w	#2,a2
\put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			eor.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\put
		rts
\word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			eor.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6/d1
_put_char_replace:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.w	#2,a2
\put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			and.l	d1,(a2)
			or.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\put
		rts
\word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			and.w	d1,(a2)
			or.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\word
		rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_off:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque
	not.l	d1

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.w	#2,a2
\put:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.l	d2,d0
			not.l	d0
			or.l	d1,(a2)
			and.l	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\put
		rts
\word:			moveq	#0,d0
			move.b	(a4)+,d0
			lsl.w	d2,d0
			not.w	d0
			or.w	d1,(a2)
			and.w	d0,(a2)
			adda.w	a6,a2
			dbra	d6,\word
		rts
	

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_and_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.l	#1,a2
		subq.w	#8,d2
\word		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		not.w	d0
		and.b	d0,1(a2)
		lsr.w	#8,d0
		and.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,\word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_or_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.l	#1,a2
		subq.w	#8,d2
\word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		or.b	d0,1(a2)
		lsr.w	#8,d0
		or.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,\word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_xor_slow:
	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\word
		subq.l	#1,a2
		subq.w	#8,d2
\word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		eor.b	d0,1(a2)
		lsr.w	#8,d0
		eor.b	d0,(a2)
		adda.w	a6,a2
		dbra	d6,\word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6/d1
_put_char_replace_slow:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\start
		subq.l	#1,a2
		subq.w	#8,d2
		ror.l	#8,d1
\start	not.w	d5
	or.w	d5,d1
	not.w	d5
\word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		ror.w	#8,d1
		and.b	d1,(a2)+
		ror.w	#8,d1
		and.b	d1,(a2)
		or.b	d0,(a2)
		lsr.w	#8,d0
		or.b	d0,-(a2)
		adda.w	a6,a2
		dbra	d6,\word
	rts

; In:
; a1 -> Pointeur vers ecran
; a4 -> Pointeur vers caractere
; d2 = Decalage horizontal
; d4 = Masque
; d6 = Nbr de ligne
; Destroy:
;	a2/a4/d0/d6
_put_char_off_slow:
	move.l	d4,d1
	rol.l	d2,d1		; d1.l = Masque
	not.l	d1

	move.l	a1,a2
	cmp.w	#8,d2
	ble.s	\start
		subq.l	#1,a2
		subq.w	#8,d2
		ror.l	#8,d1
\start	and.w	d5,d1
\word:		moveq	#0,d0
		move.b	(a4)+,d0
		lsl.w	d2,d0
		and.w	d5,d0
		not.w	d0
		ror.w	#8,d1
		or.b	d1,(a2)+
		ror.w	#8,d1
		or.b	d1,(a2)
		and.b	d0,(a2)
		lsr.w	#8,d0
		and.b	d0,-(a2)
		adda.w	a6,a2
		dbra	d6,\word
	rts




;short FontCharWidth (short c);
FontCharWidth:
	moveq	#4,d0			; Small
	move.b	CURRENT_FONT,d1
	add.b	d1,d0
	add.b	d1,d0			; d0 = 4 (Small), 6 (Medium), 8 (Large
	subq.b	#1,d1
	bge.s	\end
		lea	MediumFont+$800,a1
		clr.w	d1
		move.b	5(a7),d1		; Read Char
		mulu.w	#6,d1			; x6
		move.b	0(a1,d1.w),d0		;  d0.ub is cleared
\end:	rts

;short DrawStrWidth (const char *str, short Font);
DrawStrWidth:
	move.l	4(a7),a0	; Str
	move.w	8(a7),d1	; Font

DrawStrWidth_reg:	
	lea	MediumFont+$800,a1
	moveq	#6,d2		; Medium
	moveq	#0,d0

	; Select Font
	subq.b	#1,d1
	blt.s	\final_small
	beq.s	\final_calc

	; Large / Medium
	moveq	#8,d2		; Large
	bra.s	\final_calc
\loop_calc	add.w	d2,d0
\final_calc	tst.b	(a0)+
		bne.s	\loop_calc
	rts
	; Small
\loop_small	mulu.w	#6,d2
		add.b	0(a1,d2.w),d0		; Ca peut pas depasser 240 !
\final_small	clr.w	d2
		move.b	(a0)+,d2
		bne.s	\loop_small
	rts

; In :
;	a0 -> Str (in CURRENT FONT)
StrWidth:
	movem.l	d1-d2/a0-a1,-(a7)
	move.b	CURRENT_FONT,d1
	bsr.s	DrawStrWidth_reg
	movem.l	(a7)+,d1-d2/a0-a1
	rts
	

; ***************************************************************
; 			ST functions
; ***************************************************************

;void ST_helpMsg (const char *msg); 
ST_helpMsg:
	move.l	4(a7),a0
ST_helpMsg_reg:
	movem.l	d3-d4/a2/a6,-(a7)
	move.l	a7,a6
	move.l	a0,a2
	jsr	PortRestore
	clr.w	-(a7)		; Erase Help
	pea	STRect(pc)
	pea	STRect(pc)
	jsr	ScrRectFill
	lea	FullRect(pc),a0
	jsr	SetCurClip_reg	; Set clipping coordinate
	moveq	#A_NORMAL,d3	; Set Black Line
	moveq	#0,d0
	move.w	#239,d2
	moveq	#ST_Y,d1
	jsr	horiz
	move.l	a2,d0
	beq.s	\End
		; Display the string in small font
		clr.w	(a7)		; Set small Font
		jsr	FontSetSys
		move.w	d0,d4		
		move.w	#A_NORMAL,(a7)	; ATTR
		pea	(a2)		; String
		move.w	#ST_Y+1,-(a7)	; Y
		clr.w	-(a7)		; X
		jsr	DrawStr		; DrawStr
		move.w	d4,(a7)
		jsr	FontSetSys	; Restore old font		
		st.b	HELP_BEING_DISPLAYED
\End:	lea	CLIP_TEMP_RECT,a0
	jsr	SetCurClip_reg		; Restore current clipping
	move.l	a6,a7
	movem.l	(a7)+,d3-d4/a2/a6
	rts

;short ST_eraseHelp (void);
ST_eraseHelp:
	clr.w	d0
	tst.b	HELP_BEING_DISPLAYED
	beq.s	\quit
		lea	-20(a7),a7		; Save the Current Graph State
		move.l	a7,a0
		jsr	SaveScrState_reg
		clr.b	HELP_BEING_DISPLAYED
		suba.l	a0,a0
		jsr	ST_helpMsg_reg		; Clear the area
		lea	CUR_FOLDER_STR,a0
		jsr	ST_folder_reg		; Display Folder
		move.b	BATT_LEVEL,d0
		move.w	d0,-(a7)
		jsr	ST_batt			; Display BATT
		clr.w	(a7)
		jsr	ST_modKey		; Display 2ND/SHIFT/...
		addq.l	#2,a7
		move.l	a7,a0
		jsr	RestoreScrState_reg	; Restore Graph State
		lea	20(a7),a7
		moveq	#1,d0
\quit:	rts

ST_IsHelpQuit:
	tst.b	HELP_BEING_DISPLAYED
	beq.s	\ok
		addq.l	#4,a7	; pop return1
\ok	rts

ST_folder:
	move.l	4(a7),a0
ST_folder_reg
	jsr	ST_IsHelpQuit
	; Cvt to Upper case
	lea	FOLDER_TEMP,a1
	moveq	#8-1,d1
\loop		move.b	(a0)+,(a1)+
		beq.s	\do_fill
		dbf	d1,\loop
		bra.s	\final
\do_fill	subq.l	#1,a1
\fill		move.b	#' ',(a1)+
		dbf	d1,\fill
\final	move.b	#' ',(a1)+
	clr.b	(a1)+
	; Display the string in small font
	clr.w	-(a7)		; Set small Font
	jsr	FontSetSys
	move.w	d0,(a7)		; Save Old Font
	move.w	#A_REPLACE,-(a7); ATTR
	pea	(FOLDER_TEMP)	; String
	move.w	#ST_Y+1,-(a7)	; Y
	clr.w	-(a7)		; X
	jsr	DrawStr		; DrawStr
	lea	10(a7),a7
	jsr	FontSetSys	; Restore old font		
	addq.l	#2,a7
	rts

ST_busy:
	jsr	ST_IsHelpQuit
	clr.w	-(a7)		; Set small Font
	jsr	FontSetSys
	move.w	d0,(a7)		; Save Old Font
	move.w	6(a7),d0	; Read it
	cmp.w	#3,d0
	bge.s	\end
		lea	ST_none_str(pc),a0
		subq.w	#1,d0	; Idle mode ?
		blt.s	\done
			lea	ST_busy_str(pc),a0	; Busy ?
			beq.s	\done
				lea	ST_pause_str(pc),a0	; Pause ?
\done:		; Display the string
		move.w	#A_REPLACE,-(a7)		; Format
		pea	(a0)
		move.w	#ST_Y+1,-(a7)			; Y
		move.w	#ST_FOLDER_STAT,-(a7)		; X
		jsr	DrawStr				; DrawStr
		lea	10(a7),a7
\end	jsr	FontSetSys	; Restore old font		
	addq.l	#2,a7
	rts
	
ST_batt:
	jsr	ST_IsHelpQuit
	clr.w	-(a7)		; Set small Font
	jsr	FontSetSys
	move.w	d0,(a7)		; Save Old Font
	move.w	6(a7),d0	; Read Mode
	beq.s	\done
		; Display the string
		move.w	#A_AND,-(a7)
		subq.b	#1,d0
		bne.s	\Ok
			move.w	#A_REPLACE,(a7)		
\Ok		pea	ST_batt_str(pc)
		move.w	#ST_Y+1,-(a7)	; Y
		move.w	#ST_FOLDER_STAT,-(a7)		; X
		jsr	DrawStr		; DrawStr
		lea	10(a7),a7
\done	jsr	FontSetSys	; Restore old font		
	addq.l	#2,a7
	rts

ST_modKey:
	jsr	ST_IsHelpQuit
	clr.w	-(a7)		; Set small Font
	jsr	FontSetSys
	move.w	d0,(a7)		; Save Old Font
	move.w	6(a7),d0	; Read Flag
	cmp.w	#32,d0
	bhi.s	\done
		; Get the char index
		add.w	d0,d0
		moveq	#-1,d1
\loop			addq.w	#1,d1
			lsr.w	#1,d0
			bne.s	\loop
		; Display the string
		add.w	d1,d1
		move.w	ST_modKey_table(pc,d1.w),d1
		move.w	#A_REPLACE,-(a7)		
		pea	ST_modKey_table(pc,d1.w)	; Push string
		move.w	#ST_Y+1,-(a7)	; Y
		move.w	#ST_FOLDER_MOD,-(a7)		; X
		jsr	DrawStr		; DrawStr
		lea	10(a7),a7
\done	jsr	FontSetSys	; Restore old font		
	addq.l	#2,a7
	rts
ST_modKey_table:
	dc.w	ST_none_str-ST_modKey_table
	dc.w	ST_2nd_str-ST_modKey_table
	dc.w	ST_diamond_str-ST_modKey_table
	dc.w	ST_shift_str-ST_modKey_table
	dc.w	ST_alpha_str-ST_modKey_table
	dc.w	ST_SalphaLock_str-ST_modKey_table
	dc.w	ST_alphaLock_str-ST_modKey_table

; Usefull ?
; I will write theses functions if I think I should
; I don't think there are usefull, since they are no EStack, no Home Stack, no...
ST_graph:
ST_angle:
ST_precision:
ST_readOnly:
ST_stack:	
	rts
ST_refDsp:
	lea	ST_refDsp_str(pc),a0
	bra	ST_helpMsg_reg

; ***************************************************************
; 			Bitmap functions
; ***************************************************************

;void BitmapInit (const SCR_RECT *rect, void *BitMap)
BitmapInit:
	move.l	4(a7),a0	; Scr_rect
	clr.w	d0
	move.b	(a0)+,d0	; Xmin
	clr.w	d1
	move.b	(a0)+,d1	; Ymin
	clr.w	d2
	move.b	(a0)+,d2	; Xmax
	sub.w	d0,d2
	addq.w	#1,d2
	clr.w	d0
	move.b	(a0)+,d0	; Ymax
	sub.w	d1,d0
	addq.w	#1,d0
	move.l	8(a7),a0	; Bitmap
	move.w	d0,(a0)+	; Number of rows
	move.w	d2,(a0)+	; Number of cols
	rts

;unsigned short BitmapSize (const SCR_RECT *rect)
; Note: extended to return a long !
BitmapSize:
	move.l	4(a7),a0	; Scr_rect
BitmapSize_reg:
	moveq	#0,d0
	move.b	(a0)+,d0	; xmin
	clr.w	d1
	move.b	(a0)+,d1	; ymin
	clr.w	d2
	move.b	(a0)+,d2	; xmax
	sub.w	d0,d2		; Dx
	lsr.w	#3,d2
	addq.w	#1,d2
	clr.w	d0
	move.b	(a0)+,d0
	sub.w	d1,d0		; Dy
	addq.w	#1,d0
	mulu.w	d2,d0		; Size = ((xmax-xmin)/8+1)*(ymax-ymin+1)
	addq.w	#4,d0		; + Header
	rts
	
; Create a new bitmap of given size and coordinate
; In:
;	d0.w = x1 / d1.w = y1
;	d2.w = x2 / d3.w = y2
; Out:
;	d0.w = HANDLE of the bitmap
;	a0 -> Ptr
BitmapNew:
	movem.l	d3-d7/a2-a6,-(a7)
	subq.l	#4,a7
	move.l	a7,a2
	move.b	d0,(a2)+
	move.b	d1,(a2)+
	move.b	d2,(a2)+
	move.b	d3,(a2)+
	move.l	a7,a2
	move.l	a7,a0
	jsr	BitmapSize_reg
	move.l	d0,-(a7)
	jsr	HeapAlloc
	move.w	d0,d4
	beq.s	\Fail
		move.w	d4,a0
		trap	#3
		pea	(a0)
		pea	(a2)
		jsr	BitmapGet	; Get the bitmap		
\Fail	lea	4(a2),a7
	move.w	d4,d0
	move.w	d0,a0
	trap	#3
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
	
; ***************************************************************
; 			Draw functions
; ***************************************************************
;void DrawClipRect (const WIN_RECT *rect, const SCR_RECT *clip, short Attr)
DrawClipRect:
	move.l	8(a7),a0		; Clip Area
	jsr	SetCurClip_reg		; Set it as current
	move.l	4(a7),a0		; WinRect
	move.w	12(a7),d2		; Attr
	movem.l	d3-d5,-(a7)
	move.w	(a0)+,d0		; Read x0
	move.w	(a0)+,d1		; Read y0
	move.w	(a0)+,d4		; Read x2
	move.w	(a0)+,d5		; Read y2
	cmp.w	d0,d4
	bge.s	\Ok1
		exg	d0,d4
\Ok1	sub.w	d0,d4
	cmp.w	d1,d5
	bge.s	\Ok2
		exg	d1,d5
\Ok2	sub.w	d1,d5
	moveq	#$F,d3
	and.w	d2,d3			; DrawRect ATTRIBUTE
	jsr	DrawRect
	btst.l	#6,d2
	beq.s	\End
		addq.w	#1,d0
		addq.w	#1,d1
		subq.w	#2,d4
		subq.w	#2,d5
		jsr	DrawRect
\End	movem.l	(a7)+,d3-d5
	lea	CLIP_TEMP_RECT,a0	; Restore Clip Area
	bra	SetCurClip_reg
	
;void DrawMultiLines (short x, short y, const void *multi_lines)
DrawMultiLines:
	movem.l	d3-d5/a2-a3,-(a7)
	clr.w	d5
	move.w	4*5+4(a7),d3		; x
	move.w	4*5+6(a7),d4		; y
	move.l	4*5+8(a7),a2		; Multi_lines Ptr
	lea	-2*4-4(a7),a7
	move.l	a7,a3			; DrawRect
	lea	2*4(a3),a0		; Clipping area
	move.b	CLIP_MIN_X+1,(a0)+
	move.b	CLIP_MIN_Y+1,(a0)+
	move.b	CLIP_MAX_X+1,(a0)+
	move.b	CLIP_MAX_Y+1,(a0)+	
	move.b	(a2)+,d5		; Number of lines
	subq.w	#1,d5
	blt.s	\End
\Loop	
		clr.w	d0
		move.b	(a2)+,d0
		move.w	d0,-(a7)	; Push ATTR
		move.l	a3,a0
		clr.w	d0
		move.b	(a2)+,d0
		add.w	d3,d0
		move.w	d0,(a0)+	; x1
		clr.w	d0
		move.b	(a2)+,d0
		add.w	d4,d0
		move.w	d0,(a0)+	; Y1
		clr.w	d0
		move.b	(a2)+,d0
		add.w	d3,d0
		move.w	d0,(a0)+	; X2
		clr.w	d0
		move.b	(a2)+,d0
		add.w	d4,d0
		move.w	d0,(a0)+	; Y2
		pea	2*4(a3)		; SCR_RECT_CLIP		
		pea	(a3)		; WIN_RECT_LINE
		jsr	DrawClipLine
		lea	10(a7),a7
		dbf	d5,\Loop	
\End:	
	lea	2*4+4(a3),a7
	movem.l	(a7)+,d3-d5/a2-a3
	rts
	
;void DrawIcon (short x, short y, const void *Icon, short Attr)
DrawIcon:
	move.w	4(a7),d0	; x
	move.w	6(a7),d1	; y
	move.l	8(a7),a0	; Icon
	move.w	12(a7),d2	; ATTR
DrawIcon_reg
	cmpi.w	#3,d2
	bne.s	\NoShade
		; FIXME: It seems that it should do set or erase a pixel according to a tiny cpt
		moveq	#1,d2	; ATTR = A_NORMAL
\NoShade:			; ATTR = A_REVERSE doesn't work directly
	cmpi.w	#2,d2
	bhi.s	\Ret
		move.w	#2,-(a7)
		pea	(a0)
		move.w	#16,-(a7)
		move.w	d1,-(a7)
		move.w	d0,-(a7)
		lsl.w	#2,d2
		move.l	DrawIconTable(pc,d2.w),a0
		jsr	(a0)
		lea	12(a7),a7
\Ret:	rts
DrawIconTable:
	dc.l	SpriteX8_and
	dc.l	SpriteX8_or
	dc.l	SpriteX8_xor
	
;void DrawFkey (short x, short y, short fkey_no, short Attr) 
DrawFkey:
	clr.w	-(a7)
	jsr	FontSetSys
	move.w	d0,(a7)
	
	lea	FOLDER_TEMP,a0
	move.b	#'F',(a0)+
	move.w	6+4(a7),d0
	addi.b	#'0',d0
	move.b	d0,(a0)+
	clr.b	(a0)	
	move.w	6+6(a7),-(a7)	; ATTR
	pea	FOLDER_TEMP
	move.w	12+2(a7),-(a7)	; Y
	move.w	14+0(a7),-(a7)	; X
	jsr	DrawStr
	lea	10(a7),a7
	jsr	FontSetSys
	addq.w	#2,a7
	rts

; ***************************************************************
; 			Triangles functions
; ***************************************************************

;FillTriangle (short x0, short y0, short x1, short y1, short x2, short y2, const SCR_RECT *clip, short Attr)
FillTriangle:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	44+12(a7),a0		; Clip Area
	jsr	SetCurClip_reg
	move.w	44+16(a7),-(a7)
	jsr	SetCurAttr		; ATTR
	move.w	d0,(a7)
	lea	46+0(a7),a1		; Get point 1
	lea	46+4(a7),a2		; Point 2
	lea	46+8(a7),a3		; Point 3
	lea	DrawTriangleFillHLine(pc),a6	; Function
	bsr.s	Draw_triangle
	jsr	SetCurAttr
	addq.l	#2,a7
	lea	CLIP_TEMP_RECT,a0
	jsr	SetCurClip_reg
	movem.l	(a7)+,d3-d7/a2-a6
	rts

DrawTriangleFillHLine:
	move.w	d1,d2			; Xmax
	move.w	d3,d1			; Y
	move.w	CURRENT_ATTR,d3		; Attr
	bra	horiz
	
xe	EQU	0
ye	EQU	2

;	a1 -> Point structure.
;	a2 -> Point structure.
;	a3 -> Point structure.
;	a6 -> HLine routine
Draw_triangle:
	; Sorting points.
	move.w	ye(a3),d2
	cmp.w	ye(a2),d2
	bge.s	\Ok1
		exg	a3,a2
\Ok1:	
	move.w	ye(a2),d2
	cmp.w	ye(a1),d2
	bge.s	\Ok2
		exg	a2,a1
		move.w	ye(a3),d2
		cmp.w	ye(a2),d2
		bge.s	\Ok2
			exg	a3,a2
\Ok2:
	
; Calculating slopes
	move.w	xe(a3),d5
	sub.w	xe(a1),d5
	ext.l	d5
	asl.l	#8,d5		; d5 = (x3 - x1) << 8	; Ici
	move.w	ye(a3),d1
	sub.w	ye(a1),d1
	beq	Straight_Line
	divs.l	d1,d5		; d5 = DeltaX / DeltaY = Dx 13
	ext.l	d5
	asl.l	#8,d5

	move.w	xe(a3),d6
	sub.w	xe(a2),d6
	ext.l	d6
	asl.l	#8,d6	; Ici
	move.w	ye(a3),d1
	sub.w	ye(a2),d1
	beq.s	Flat_Bottom
	divs.l	d1,d6		; d6 = (x3 - x2 << 8 / (y3 - y2)
	ext.l	d6
	asl.l	#8,d6

	move.w	xe(a2),d7
	sub.w	xe(a1),d7
	ext.l	d7
	asl.l	#8,d7	; Ici
	move.w	ye(a2),d2
	sub.w	ye(a1),d2
	beq	Flat_Top
	divs.l	d2,d7		; d7 = (x2 - x1) << 8 / (y2 - y1)
	ext.l	d7
	asl.l	#8,d7

	subq.w	#1,d1
	subq.w	#1,d2

	move.w	d1,a5		; a5 = Numbers of rows between 2 and 3
				; As it will use by dbf, we need
				; only a word.

; Render face with all 3 points at different Y-Coordinate.
; D3 is current Y coordinate
; a4 is the adress of the screen.
	move.w	ye(a1),d3	; Y

	move.w	xe(a1),d0	; Xmin
	swap	d0
	clr.w	d0
	move.l	d0,d1		; Xmax

Loop_Upper
		movem.l	d0-d3,-(a7)
		swap	d0
		swap	d1
		jsr	(a6)
		movem.l	(a7)+,d0-d3
		add.l	d7,d0
		add.l	d5,d1
		addq.w	#1,d3
		dbf	d2,Loop_Upper

	movem.l	d0-d1/d3,-(a7)
	swap	d0
	swap	d1
	jsr	(a6)
	movem.l	(a7)+,d0-d1/d3
	move.w	a5,d2		; Restore counter between 2 and 3

Loop_Lower
	add.l	d6,d0
	add.l	d5,d1
	addq.w	#1,d3
		movem.l	d0-d3,-(a7)
		swap	d0
		swap	d1
		jsr	(a6)
		movem.l	(a7)+,d0-d3
		dbf	d2,Loop_Lower
	rts

Flat_Bottom
	move.w	xe(a2),d7
	sub.w	xe(a1),d7
	ext.l	d7
	asl.l	#8,d7	; Ici
	move.w	ye(a2),d2
	sub.w	ye(a1),d2
;	beq.s	Flat_Top	; Normally, we can not have 0
	divs.l	d2,d7		; d7 = (x2 - x1) << 8 / (y2 - y1)
				; d2 = y2 - y1
	ext.l	d7
	asl.l	#8,d7

	; Render face with all 3 points at different Y-Coordinate.
	; D4 is current Y coordinate
	; a0 is current adress on the screen.
	; a4 and a5 are the limit of A0
	move.w	ye(a1),d3	; Y
	move.w	xe(a1),d0	; Xmin
	swap	d0
	clr.w	d0
	move.l	d0,d1		; Xmax

Loop_Upper3
		movem.l	d0-d3,-(a7)
		swap	d0
		swap	d1
		jsr	(a6)
		movem.l	(a7)+,d0-d3
		add.l	d7,d0
		add.l	d5,d1
		addq.w	#1,d3
		dbf	d2,Loop_Upper3
	rts

Flat_Top
	; Render face with all 3 points at different Y-Coordinate.
	; D4 is current Y coordinate
	; a0 is current adress on the screen.
	move.w	ye(a1),d3	; Y

	move.w	d1,d2		; Compteur
	subq.w	#1,d2

	move.w	xe(a1),d0	; Xmin
	swap	d0
	clr.w	d0
	
	move.w	xe(a2),d1
	swap	d1
	clr.w	d1		; xmax

Loop_Lower3
		movem.l	d0-d3,-(a7)
		swap	d0
		swap	d1
		jsr	(a6)
		movem.l	(a7)+,d0-d3
		add.l	d5,d0
		add.l	d6,d1
		addq.w	#1,d3
		dbf	d2,Loop_Lower3
	rts

Straight_Line
	move.w	ye(a1),d3	; Y

	move.w	xe(a1),d0
	move.w	xe(a2),d2
	move.w	xe(a3),d1
	cmp.w	d2,d0
	ble.s	\Ok1
		exg	d2,d0
\Ok1:
	cmp.w	d1,d2
	ble.s	\Ok2
		exg	d1,d2
		cmp.w	d2,d0
		ble.s	\Ok2
			exg	d2,d0
\Ok2:
	jmp	(a6)


;void FillLines2 (const WIN_RECT *lower_line, const WIN_RECT *upper_line, const SCR_RECT *clip, short Attr); 
FillLines2:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	44+8(a7),a0		; Clip Area
	jsr	SetCurClip_reg
	move.w	44+12(a7),-(a7)
	jsr	SetCurAttr		; ATTR
	move.w	d0,(a7)
	lea	DrawTriangleFillHLine(pc),a6	; HLine Function
	move.l	2+44+0(a7),a1		; lower_line (1st point)
	lea	4(a1),a2		; 2nd point
	move.l	2+44+4(a7),a3		; 3rd point
	jsr	Draw_triangle
	move.l	2+44+4(a7),a1		; upper_line (1st point)
	lea	4(a1),a2		; 2nd point
	move.l	2+44+0(a7),a3		; 
	addq.l	#4,a3			; 3rd point
	jsr	Draw_triangle
	jsr	SetCurAttr
	addq.l	#2,a7
	lea	CLIP_TEMP_RECT,a0
	jsr	SetCurClip_reg
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
ScrRect:	dc.b	0,0,SCR_WIDTH-1,ST_Y-1			; Working screen
STRect:		dc.b	0,ST_Y+1,SCR_WIDTH-1,SCR_HEIGHT-1	; ST screen
FullRect:	dc.b	0,0,SCR_WIDTH-1,SCR_HEIGHT-1		; Full Screen
MenuRect:	dc.b	0,0,SCR_WIDTH-1,18			; Menu Screen

