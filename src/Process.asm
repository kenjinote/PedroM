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


	include "Const.h"
	
        ;; Exported FUNCTIONS: 
        xdef PID_CheckSwitch
        xdef PID_Switch
        xdef PID_Check
        xdef PID_Go
        xdef PID_clean
        xdef PID_Init


; TASK SWITCHER.

; Check if a key should start a switch and starts it.
;In:
;	a0 ->  String
;	d0.w = Key
; Return
;	d0.w <> 0 if no switch.
PID_CheckSwitch:
	moveq	#-1,d1				; Start Shell
	cmpi.w	#KEY_SWITCH,d0			; 
	beq.s	\Switch
	sub.w	#KEY_DIAMOND+KEY_F1,d0
	blt.s	\ret
	move.w	d0,d1
	cmpi.w	#8,d1
	ble.s	\Switch
\ret	rts
\Switch	suba.l	a1,a1				; No Kill function
	moveq	#1+4+8,d0			; Save everything important

; Stop the current process, and open a new one.
; In:
;	d0.l = Flags
;	d1.w = PID to go or -1 if start another shell.
;	a0.l = String
;	a1.l = Kill Function	
; Return
;	1 if fail.
PID_Switch:
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a7,a6
	move.l	d0,d4
	move.w	d1,d5
	;Stop AutoInts (0x600) - We still want Protected Memory int.
	move.w	#$0600,d0
	trap	#1
	move.w	d0,d6
	move.w	d0,-(a7)		; Push old SR
	; Check if we want to go to the current Process
	cmp.w	CURRENT_PROCESS,d5
	beq	\Fail
	;Load Current Process Number and check if it is valid.
	move.w	CURRENT_PROCESS,d0
	move.w	d0,PREVIOUS_PROCESS
	jsr	PID_Check
	tst.w	d1
	bne	\Fail
	; Push special things
	btst.l	#0,d4
	beq.s	\NoPushLcdMem
		lea	(LCD_MEM).w,a3
		move.w	#960-1,d0
		\LcdLoop:	move.l	(a3)+,-(a7)
				dbf	d0,\LcdLoop
\NoPushLcdMem
	btst.l	#1,d4
	beq.s	\NoPushAutoInts
		lea	($64).w,a3
		move.w	#7-1,d0
		\IntsLoop:	move.l	(a3)+,-(a7)
				dbf	d0,\IntsLoop
\NoPushAutoInts
	btst.l	#2,d4
	beq.s	\NoPushVectors
		suba.l	a3,a3
		move.w	#$3F,d0
		\VectorsLoop:	move.l	(a3)+,-(a7)
				dbf	d0,\VectorsLoop
\NoPushVectors
	btst.l	#3,d4
	beq.s	\NoPushIO
		lea	$600000,a3
		move.w	(a3),-(a7)
		move.b	$C(a3),-(a7)
		move.b	$E(a3),-(a7)
		move.w	$14(a3),-(a7)
		move.w	$18(a3),-(a7)
		\LoopHardCpt1:	move.b	$17(a3),d1
				bne.s	\LoopHardCpt1
		\LoopHardCpt2:	move.b	$17(a3),d1
				beq.s	\LoopHardCpt2
		move.b	d1,-(a7)
\NoPushIO:	
	; Push Flags
	move.l	d4,-(a7)
	; Push Global Vars
	lea	(FloatReg1).w,a3
	move.w	#(PREVIOUS_PROCESS-FloatReg1)/2-1,d0
\VarsLoop	move.w	(a3)+,-(a7)
		dbf	d0,\VarsLoop
	; Push String
	lea	19(a0),a0
	move.l	a7,a3
	clr.b	-(a3)
	moveq	#19-1,d0
\StringLoop	move.b	-(a0),-(a3)
		dbf	d0,\StringLoop
	move.l	a3,a7
	; Push Kill Function
	pea	(a1)
	; StackSize = USP_INIT-a7
	move.l	#USP_INIT,d0
	sub.l	a7,d0
	addq.l	#4,d0
	; PushStackSize
	move.l	d0,-(a7)
	blt.s	\Fail
	; Alloc() if 0? => Fail
	jsr	HeapAlloc
	; Save Hd in ProcessNumber.
	move.w	d0,(a2)
	beq.s	\Fail
	move.w	d0,a0
	trap	#3
	; Copy the stack.
	move.l	(a7),d0
	lsr.l	#1,d0
	subq.w	#1,d0
\CopyStack	move.w	(a7)+,(a0)+
		dbf	d0,\CopyStack
	; Starts a new one.
	move.w	d5,d0				; Process to select
	moveq	#-1,d2				; Invalid secondary PID
	bra.s	PID_Go
\Fail	move.w	d6,d0
	trap	#1
	move.l	a6,a7
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#1,d0
	rts

; Check if the PID is valid.
; In: 
;	PID (d0) 
; Out: 	StackHandle(d1) or 0
; 	(a2).w = Ptr in Process Table
PID_Check:
	moveq	#-1,d1
	tst.w	d0
	blt.s	\Fail
	cmp.w	#MAX_PROCESS,d0
	bge.s	\Fail
	lea	PROCESS_TABLE,a2
	add.w	d0,d0
	adda.w	d0,a2
	move.w	(a2),d1
\Fail:	rts

; Terminate the current Process, and restore another one.
; Select by itself a new process if a problem occurs.
; If both PID are invalid, starts a new shell.
; In:
;	d0.w =	PID	: Starts selected Process.
;		-1	: Starts another shell.
;		-2	: Starts a shell (Tries to find a used one). (TODO)
;	d2.w = Secondary PID if the first one is invalid or -1 if no previous.
PID_Go:
	move.w	d0,CURRENT_PROCESS		; Set New Current Process
	; Check given PID
	bsr.s	PID_Check
	tst.w	d1
	bgt.s	\Found
		; else select the previous one if it is still valid
		move.w	d2,d0
		bsr.s	PID_Check
		tst.w	d1
		bgt.s	\Found
			; else start another shell with the given PID.
			trap	#12
			jmp	OSCont2
\Found:
	move.w	d1,a0
	;Stop AutoInts (0x600)
	move.w	#$0600,d0
	trap	#1
	; Restore Stack Ptr
	trap	#3
	move.l	(a0),d0
	lea	(USP_INIT).w,a7
	sub.l	d0,a7
	move.l	a7,a1
	; Copy the stack.
	lsr.l	#1,d0
	subq.w	#1,d0
\CopyStack	move.w	(a0)+,(a1)+
		dbf	d0,\CopyStack
	; Free Handle Process
	move.w	(a2),d0
	clr.w	(a2)
	jsr	HeapFree_reg
	; Pop stack (Size/KillFunc/Name)
	lea	28(a7),a7
	; Pop Global Vars
	lea	(PREVIOUS_PROCESS).w,a3
	move.w	#(PREVIOUS_PROCESS-FloatReg1)/2-1,d0
\VarsLoop	move.w	(a7)+,-(a3)
		dbf	d0,\VarsLoop
	; Pop Flags
	move.l	(a7)+,d4
	move.w	#LCD_MEM/8,$600010		; Set $4C00 as VRAM for HW1
	; Pop special things
	btst.l	#3,d4
	beq.s	\NoPushIO
		lea	$600000,a3
		move.b	(a7)+,$17(a3)
		move.w	(a7)+,$18(a3)
		move.w	(a7)+,$14(a3)
		move.b	(a7)+,$0E(a3)
		move.b	(a7)+,$0C(a3)
		move.w	(a7)+,(a3)
\NoPushIO:	
	btst.l	#2,d4
	beq.s	\NoPushVectors
		lea	GHOST_SPACE+$40*4,a3
		move.w	#$40-1,d0
		\VectorsLoop:	move.l	(a7)+,-(a3)
				dbf	d0,\VectorsLoop
\NoPushVectors
	btst.l	#1,d4
	beq.s	\NoPushAutoInts
		lea	GHOST_SPACE+$64+7*4,a3
		move.w	#7-1,d0
		\IntsLoop:	move.l	(a7)+,-(a3)
				dbf	d0,\IntsLoop
\NoPushAutoInts
	btst.l	#0,d4
	beq.s	\NoPushLcdMem
		lea	(LCD_MEM+30*128).w,a3
		move.w	#960-1,d0
		\LcdLoop:	move.l	(a7)+,-(a3)
				dbf	d0,\LcdLoop
\NoPushLcdMem
	; Restore Int Level
	move.w	(a7)+,d0
	trap	#1
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts
	
; Clean all the background process
PID_clean:
	lea	PROCESS_TABLE,a2
	moveq	#MAX_PROCESS-1,d3
\loop		move.w	(a2),-(a7)		; May be H_NULL
		jsr	HeapFree		; That's why we can't use _reg
		addq.l	#2,a7
		clr.w	(a2)+	;  H_NULL this process
		dbf	d3,\loop
	clr.w	CURRENT_PROCESS
	clr.w	PREVIOUS_PROCESS
	rts

;Set the current Process Number
PID_Init:
	; First check if the previous PID is free and ok!
	move.w	CURRENT_PROCESS,d0
	jsr	PID_Check
	tst.w	d1
	beq.s	\Ok
		; Find another PID free.
		lea	PROCESS_TABLE,a0
		moveq	#MAX_PROCESS-1,d0
		moveq	#-1,d1
\Loop:			addq.w	#1,d1
			tst.w	(a0)+
			dbeq	d0,\Loop
		; If it is not found, d0=MAX_PROCESS which is invalid.
		move.w	d1,CURRENT_PROCESS
\Ok	rts
