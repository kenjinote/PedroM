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
        xdef ScriptExec
        xdef ScriptReadLong
        xdef ScriptElseCmd
        xdef ScriptElifCmd
        xdef ScriptNextLine
        xdef ScriptNextBlock
        xdef ScriptIfCmd
        xdef ScriptExitCmd
        xdef ScriptExecuteLine
        xdef ScriptExecuteLineReturn
        xdef ScriptWhileCmd
        xdef ScriptLineError_str

;******************************************************************
;***                                                            ***
;***            	Script Functions 			***
;***                                                            ***
;******************************************************************


; Executes a Shell Script
; In:
;	d0.w =  Handle of the TEXT file.
;	FIXME: a4.l -> Command Line (?)
; The args are pushed on the EStack
ScriptExec:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	a7,a6				; Save stack ptr
	move.w	d0,d6
	; Search Script File
	move.w	d6,-(a7)			; Get the file
	jsr	HLock_redirect			; and lock it !
	move.l	a0,d0				; Handle exists ?.
	beq.s	\NoScriptFile			;
	; Check if it is a text file.
	moveq	#0,d0
	move.w	(a0)+,d0			; Read size
	move.b	-1(a0,d0.l),d1			; Read TAG
	cmpi.b	#$E0,d1				; Check if it is a TEXT TAG ?
	bne.s	\NoScriptFile			;
	addq.l	#3,a0				; Skip first infos.
	move.l	a0,a2				; First Line of command
	; Check signature
	lea	ScriptHeader_str,a1		; Check signa
	moveq	#ScriptHeader_end-ScriptHeader_str,d0
	jsr	memcmp_reg			; Comp
	tst.w	d0
	bne.s	\NoScriptFile			; Signature invalid ?
	; Create 'args' variable.
	jsr	push_LIST_TAG			; Push list TAG
	move.l	top_estack,-(a7)		; EStack 
	clr.w	-(a7)				; Size (Not used...)
	move.w	#STOF_ESI,-(a7)			; Flag
	pea	ScriptArgs_sym			; Var Name
	jsr	VarStore			; Store List in Variable
	; Create Line counter
	moveq	#1,d7
	; Error frame
	lea	-60(a7),a7			; Error Stack Frame
	pea	(a7)				; Push Stack Frame
	jsr	ER_catch			; Catch all errors.
	tst.w	d0
	bne	\End
	clr.b	SHELL_NG_DISPLAY		; Don't display the result of ng_execute
	; Main processing loop
	lea	(5*4)(a7),a3			; Line counter ptr (inside error frame)
	jsr	ScriptNextLine			; Get first usable line
\Loop:		jsr	ScriptExecuteLine	; Execute line
		bra.s	\Loop			; Continue with next line 
\NoScriptFile
	move.l	#ScriptError,(a7)
	jsr	printf_redirect
	bra.s	\UnLock
	
\End	cmpi.w	#NO_ERROR,d0			; Check end of script
	beq.s	\EndOfScript
		jsr	find_error_message_reg
		move.l	a0,(a7)
		move.l	d7,-(a7)
		pea	ScriptLineError_str
		jsr	printf_redirect
\EndOfScript
	; Erase 'args' file
	move.l	#ScriptArgs_sym,(a7)
	jsr	SymDel
	; Unlock Script File
\UnLock	move.w	d6,(a7)
	jsr	HeapUnlock_redirect
	move.l	a6,a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts

; Read an (un)aligned long from a2
ScriptReadLong:
	move.w	a2,d0			; 2	4
	btst.l	#0,d0			; 2	10
	beq.s	\Even			; 2
		move.l	-1(a2),d0	; 4	8+16
		lsl.l	#8,d0		; 4	24
		move.b	3(a2),d0	; 4	12
		rts			; 2	16
\Even:	move.l	(a2),d0			; 2	10+12
	rts				; 2	16

ScriptElseCmd:
ScriptElifCmd:
	bsr.s	ScriptNextLine
	bra.s	ScriptNextBlock
 
ScriptNextLine2
	addq.l #1,a2
	addq.l #1,(a3)
ScriptNextLine:
		move.b (a2)+,d0
		beq.s \Throw
		cmpi.b #SCRIPT_RETURN_CHAR,d0
		bne.s ScriptNextLine
		addq.l #1,(a3)
\SkipSpaces:
		cmpi.b #32,(a2)+
		beq.s \SkipSpaces
	move.b -(a2),d0
	beq.s \Throw
	cmpi.b	#SCRIPT_RETURN_CHAR,d0		; New line ?
	beq.s	ScriptNextLine2
	cmpi.b	#SCRIPT_COMMENT_CHAR,d0		; Comment ?
	beq.s	ScriptNextLine2
	rts
\Throw	ER_THROW NO_ERROR
 
ScriptNextBlock:
	cmpi.b	#SCRIPT_OPEN_BLOCK_CHAR,(a2)
	bne.s	ScriptNextLine
	moveq	#1,d2
\Loop:
	tst.w	d2
	beq.s	ScriptNextLine
	bsr.s	ScriptNextLine
	move.b	(a2),d0
	cmpi.b	#SCRIPT_OPEN_BLOCK_CHAR,d0
	bne.s	\NoInc
		addq.w	#1,d2
		bra.s	\Loop
\NoInc	cmpi.b #SCRIPT_CLOSE_BLOCK_CHAR,d0
	bne.s \Loop
		subq.w #1,d2
		bra.s \Loop

ScriptIfCmd:
	addq.l	#3,a2
	pea	(a2)
	jsr	ScriptExecuteLine
	move.l	(a7)+,a2
	cmp.w	#$2000,FloatReg1+FLOAT.exponent
	beq.s	\Else
\Execute	bsr.s	ScriptNextLine
		cmpi.b	#SCRIPT_OPEN_BLOCK_CHAR,(a2)
		bne.s	ScriptExecuteLine
		bsr.s	ScriptNextLine
\LoopIf			cmpi.b	#SCRIPT_CLOSE_BLOCK_CHAR,(a2)
			beq.s	ScriptNextLine
			bsr.s	ScriptExecuteLine
			bra.s	\LoopIf
\Else	bsr.s	ScriptNextLine
	bsr.s	ScriptNextBlock
	jsr	ScriptReadLong
	cmpi.l	#'else',d0
	beq.s	\Execute
	cmpi.l	#'elif',d0
	beq.s	ScriptIfCmd
\End	rts

ScriptExitCmd:
	ER_THROW NO_ERROR

ScriptExecuteLine:
	;1. Check special command: if / else/elif
	jsr	ScriptReadLong
	cmpi.l	#'else',d0
	beq	ScriptElseCmd
	cmpi.l	#'elif',d0
	beq	ScriptElifCmd
	cmpi.l	#'exit',d0
	beq.s	ScriptExitCmd
	cmpi.l	#'whil',d0
	beq.s	ScriptWhileCmd
	lsr.l	#8,d0
	cmpi.l	#'if ',d0
	beq.s	ScriptIfCmd
ScriptExecuteLineReturn:
	;2. Copy Line in stack buffer
 	lea	(-SHELL_MAX_LINE-10)(a7),a7	; Temp buffer
	move.l	a7,a4				; Ptr to buffer
	clr.b	(a4)+				; NULL starting buffer.
	move.l	a2,a0
	move.l	a4,a1
\Loop		move.b	(a0)+,d0
		beq.s	\Done
		cmpi.b	#SCRIPT_RETURN_CHAR,d0
		beq.s	\Done
		move.b	d0,(a1)+
		bra.s	\Loop
\Done:	clr.b	(a1)
	; 3. Execute command
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	ShellExecuteCommand
	movem.l	(a7)+,d0-d7/a0-a6
	lea	SHELL_MAX_LINE+10(a7),a7
	; 4. Next line
	bra	ScriptNextLine
 
ScriptWhileCmd:
	cmpi.b	#'e',4(a2)
	bne.s	ScriptExecuteLineReturn
	cmpi.b	#' ',5(a2)
	bne.s	ScriptExecuteLineReturn
	addq.l	#6,a2
	pea	(a5)
	move.l	a2,a5
\Loop:
		move.l	a5,a2
		jsr	ScriptExecuteLine
		move.l	a5,a2
		jsr	ScriptNextLine		; Skip 'while condition'
		cmp.w	#$2000,FloatReg1+FLOAT.exponent
		beq.s	\End
		cmpi.b	#SCRIPT_OPEN_BLOCK_CHAR,(a2)
		beq.s	\Block
			jsr	ScriptExecuteLine
			bra.s	\Loop
\Block		jsr	ScriptNextLine		; Skip '{'
\InternalLoop		cmpi.b	#SCRIPT_CLOSE_BLOCK_CHAR,(a2)
			beq.s	\Loop
			jsr	ScriptExecuteLine
			bra.s	\InternalLoop
\End	jsr	ScriptNextBlock			; Skip Block
	move.l	(a7)+,a5
	rts
	
ScriptHeader_str	dc.b	SCRIPT_COMMENT_CHAR,"!PedroM"
ScriptHeader_end
ScriptError		dc.b	"Not a script!",10,0
ScriptLineError_str	dc.b	10,"Line %ld: %s",10,0
	EVEN
	