;*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003, 2004, 2005-2009 Patrick Pelissier
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
        xdef BUS_ERROR
        xdef SPURIOUS
        xdef ADDRESS_ERROR
        xdef ILLEGAL_INSTR
        xdef ZERO_DIVIDE
        xdef CHK_INSTR
        xdef I_TRAPV
        xdef PRIVILEGE
        xdef TRACE
        xdef FATAL_ERROR
        xdef FATAL_ERROR_SR
        xdef SYSTEM_ERROR
        xdef LINE_1010
        xdef ER_throw
        xdef LINE_1111
	xdef Trap_0
	xdef Trap_1
	xdef Trap_3
	xdef Trap_4
	xdef Trap_5
	xdef Trap_6
        xdef Trap_7
        xdef Trap_8
	xdef Trap_9
	xdef Trap_10
	xdef Trap_11
	xdef Trap_12
	xdef Trap_13
        xdef Trap_14
        xdef Trap_15
        xdef IdleRam


BUS_ERROR:
	lea	BusError_str(pc),a0
	bra.s	FATAL_ERROR_SR
SPURIOUS:
	lea	Spurious_str(pc),a0
	bra.s	FATAL_ERROR_SR
ADDRESS_ERROR:
	lea	Address_str(pc),a0
	bra.s	FATAL_ERROR_SR
ILLEGAL_INSTR:
	lea	Illegal_str(pc),a0
	bra.s	FATAL_ERROR_SR
ZERO_DIVIDE:
	lea	Zero_str(pc),a0
	bra.s	FATAL_ERROR_SR
CHK_INSTR:
	lea	Chk_str(pc),a0
	bra.s	FATAL_ERROR_SR
I_TRAPV:
	lea	TrapV_str(pc),a0
	bra.s	FATAL_ERROR_SR
PRIVILEGE:
	lea	Privelege_str(pc),a0
	bra.s	FATAL_ERROR_SR
TRACE:
	lea	Trace_str(pc),a0
	bra.s	FATAL_ERROR_SR

FATAL_ERROR:
	trap	#12
FATAL_ERROR_SR:
	move.w	#$2700,SR
	;; Check if Supervisor Stack System is within the right Range.
	cmp.w	#SSP_INIT,a7
	bgt.s	SYSTEM_ERROR_SR
	cmp.w	#$100,a7
	ble.s	SYSTEM_ERROR_SR
	move.l	a7,d0
	andi.w	#1,d0
	bne.s	SYSTEM_ERROR_SR
	clr.w	-(a7)		; Attribut 
	pea	(a0)		; String Ptr
	clr.l	-(a7)		; (x, y) coordinates
	bsr.s	LocalInitGraphSystem	; Set output
	bsr.s	LocalDrawStr		; Draw the string
	move.l	#1000000,d0	; Wait ~10s
\Stop_		subq.l	#1,d0
		bne.s	\Stop_
	jmp	OSCont		; A partial reset is possible

LocalDrawStr:
	jmp	DrawStr
LocalInitGraphSystem:	
	jmp	InitGraphSystem
		
; Error not recoverable
SYSTEM_ERROR:
	trap	#12
SYSTEM_ERROR_SR:	
	move.w	#$2700,SR
	lea	(SSP_INIT).w,a7		; Restore the SSP since it may have been corrupted
	clr.w	-(a7)			; Attr
	pea	(a0)			; String
	move.w	#10,-(a7)		; Y coord
	clr.w	-(a7)			; X
	bsr.s	LocalInitGraphSystem	; Set LCD_MEM
	bsr.s	LocalDrawStr		; Draw the string
	pea	SystemError_str(pc)	; Other string
	clr.l	-(a7)			; X & Y
	bsr.s	LocalDrawStr		; Draw the string
	; Wait ~10s
	move.l	#1000000,d0
\Stop_		subq.l	#1,d0
		bne.s	\Stop_
	jmp	CODE_START		; Reset the calc

LINE_1010:
ER_throw:
	move.w	(sp)+,d1		; Read SR
	move.l	(sp)+,a0		; Read address of crash
	move.w	(a0),d0			; Read Opcode
	ifne	DEBUG_ER_THROW
	move.l	a0,(ErThrowAddr).w	; Save address of ER_THROW
	endif
	lea	Line1010_str(Pc),a0	;
	andi.w	#$0FFF,d0		; Code
	beq	FATAL_ERROR		; dc.w	$A000
	move.w	d1,SR			; Restore SR
	jmp	ER_throwVar_reg		; ER_throw

; If $FFF0,  
;	~ jsr abs.l (Return address +6 / jsr to a1 ->Crash code+2 a1+(a1) 
;	Ex:	dc.w	$FFF0 dc.l JumpAdr-* 
; If $FFF2, 
;	ROM_CALL avec un word. 
;	Example: dc.w $FFF2, HeapAlloc*4
	;; Copyright 2009 Martial Demolins
LINE_1111: 
	movem.l	d0-d2/a0-a3,-(sp)	; Musn't trash any register for ramcalls. a3 won't be trashed, but it reserves space 
	move.w	4*7(sp),d1		; Get Old SR 
	movea.l	4*7+2(sp),a0		; Get Address of the 'crash' 
	move.w	(a0)+,d0		; We get the instruction and a0 ->next instruction 
	subi.w	#$F800,d0		; Is it > $F800 ? 
	bls.s	\ramcall		; No, so it is perhaps a ramcall (FirstWindow is not a romcall) 
		lea.l	4*7+6(sp),sp	; Pop 7 registers + SR + Address of the 'crash' 
		movea.l	a0,a1		; Jsr/Jmp with a 32 bits offset	 
		cmpi.w	#$FFF0-$F800,d0 
		bne.s	\NoRelJsr 
			adda.l	(a0)+,a1	; Get the Sub Routine 
			bra.s	\Jump 
\NoRelJsr	cmpi.w	#$FFF1-$F800,d0 
		bne.s	\NoRelJmp 
			adda.l	(a0)+,a1	; Get the Sub Routine 
			move.w	d1,SR		; Restore SR 
			jmp	(a1)		; Jmp with a 32 bits offset 
\NoRelJmp	cmpi.w	#$FFF2-$F800,d0 
		bne.s	\NoBigRomCall 
			move.w	(a0)+,d0	; Read Offset 
			lsr.w	#2,d0 
\NoBigRomCall	movea.l	($C8).w,a1	; The address of the rom_call table 
		cmp.w	-(a1),d0	; Compare rom_call and number of entries 
		bcc.s	\crash		; Out of range ? => Crash 
			lsl.w	#2,d0		; * 4 
			movea.l	2(a1,d0.w),a1	; + ($C8) MAX: 8000 rom_calls 
\Jump			move.w	d1,SR		; Restore SR 
			pea	(a0)		; Push return address 
			jmp	(a1)		; Jump to Rom_call function 
 
\ramcall: 
	addi.w #$F800-$F000,d0				; Clean data 
	cmpi.w	#MAX_RAMCALL,d0				; Valid ramcall ? 
	bcc.s	\crash					; No, it's a crash (>=) 
		lea	RAM_TABLE(Pc),a1		; Ptr to the Ramcall table
		lsl.w	#2,d0				; Table of longwords 
		movea.l	0(a1,d0.w),a1			; Read ramcall
		cmp.l	#kernel::BeginSharedLinker,a1	; Compare the address. Is-it inside the PreOs kernel routine?
		bcs.s	\NotAFunctionCall
		cmp.l	#kernel::EndSharedLinker,a1	; Compare the address. Is-it inside the PreOs kernel routine?
		bhi.s	\NotAFunctionCall
			btst.l	#13,d1			; Called in supervisor mode ?  (Bit 13 is the Supervisor Bit of SR).
			beq.s	\UserMode		; No 
				move.w	d1,6*4(sp)		; Rewrite SR (need another return adress on the stack) 
				move.l	a1,6*4+2(sp)		; Set the ramcall ptr as the return adress of the handler 
				move.l	a0,7*4+2(sp)		; Push the return adress of the ramcall 
				movem.l	(sp)+,d0-d2/a0-a2	; Restore registers, but not a3 which hasn't ben destroyed 
				rte				; And quit the handler, calling the ramcall 
\UserMode: 
				move.l	USP,a2			; Read user stack pointer 
				move.l	a0,-(a2)		; And push the return adress of the ramcall 
				move.l	a2,USP			; Save the new stack pointer 
				move.l	a1,4*7+2(sp)		; Set the ramcall ptr as the return adress of the handler 
				movem.l	(sp)+,d0-d2/a0-a3	; Restore all registers 
				rte				; Call ramcall 
	 
\NotAFunctionCall:
		move.l	a1,3*4(sp)				; Modify saved a0 
		move.l	a1,(sp)					; Modify saved d0 
		movem.l	(sp)+,d0-d2/a0-a3			; Restore destroyed registers 
		addq.l	#2,2(sp)				; Fix adress points after the 'crash' 
		rte						; And come back 
 
\crash:	lea	Line1111_str(Pc),a0 
	bra	FATAL_ERROR 

Trap_7:
Trap_8:
Trap_10:		; Enter self test
Trap_13:		; Used by db92.
Trap_14:
Trap_15:
	lea	Trap_NotDefined_str(Pc),a0
	bra	FATAL_ERROR
	
; Returns some internal AMS functions ptr. Mainly for compatibility reasons with ti-92.
Trap_9:
	lsl.w	#2,d0
	move.l	Trap9_Table(pc,d0.w),a0
Trap_11:		; Hardware protection function (does nothing on PedroM).
	rte
Trap9_Table:
	dc.l	OSContrastUp
	dc.l	WinOpen
	dc.l	OSLinkReset
	dc.l	0		; TIMERV *OSTimerVectors
	dc.l	CONTRAST_VALUE  ;04       (ROM)  ?contrast
 	dc.l	WinStr
	dc.l	KBD_QUEUE	;$6-$1C ?key_buffer
	dc.l	OSqclear	; flush word buffer, set size to 1 word (push *buffer)
	dc.l	0		; table for isupper(), etc.
	dc.l	OSContrastUp	;?contrast_up()
	dc.l	OSContrastDn	; ?contrast_down()
	dc.l	OSClearBreak	;(ROM)  [60001A] = $FF, [05342] = $00
	dc.l	0		;(ROM)  getkey() table
	dc.l	OSCheckBreak	; (ROM)  ?
	dc.l	LCD_MEM		;(RAM)       LCD memory
	dc.l	OSdequeue	;(ROM)  Boolean ?read_word_buffer(WORD *a, BUFFER *b)
	dc.l	0		;(ROM)  RAM test
	dc.l	WinMoveTo
	
	
;  Change Interrupt Mask (d0.w = new int ,ask)
Trap_1:
	move.w	(sp),-(sp)		; Push 'old' SR
	and.w	#$0F00,d0		; Filter entry
	and.w	#$F0FF,2(sp)		; Filter Flags
	or.w	d0,2(sp)		; Change SR
	move.w	(sp)+,d0		; Reload Old SR
	rte
	
; UniOs Deref (a0.w = handle).
Trap_3:
	;; Doesn't work anymore due to dynamic allocation of HEAP_TABLE by the linker
	;; 	add.w	a0,a0
	;; 	add.w	#HEAP_TABLE/2,a0
	;; 	move.l	0(a0,a0.l),a0	;
	adda.w	a0,a0
	adda.w	a0,a0
	adda.w	#HEAP_TABLE,a0
	move.l	(a0),a0
Trap_6:				; For debugging purpose (Set BP on trap #6)
	rte
	
; En cas de changement de piles, on reset la calc !
; (Meme si la memoire est saine, le processeur a ete arrete).
; Il faudrait fixer un flag special, sauver TOUS les registres
; Et se demerder au boot pour reprendre apres le trap #4 : pas facile.
Trap_4:
	; If User Mode & Special Shell Bit, switch
	; Else Turn Off.
	move.w	(sp),d0				; Check If call from User Mode
	andi.w	#$2000,d0			
	bne.s	\Continue
		btst.b	#1,SHELL_FLAGS		; Check if Switch instead of Off ?
		beq.s	\Continue
			move.w	(sp)+,d0	; Yes pop SR
			move.l	(sp)+,a0	; Pop return address
			move.w	d0,SR		; Restore SR
			pea	(a0)		; Push return address
			move.l	ARGV,a0		; Process Name
			suba.l	a1,a1		; No Exit Function
			moveq	#PID_SAVE_LCD_MEM+PID_SAVE_VECTORS+PID_SAVE_IO,d0
			moveq	#-1,d1		; Start new shell.
			bra	PID_Switch	; Switch !
\Continue
Trap_5:	; Trap_5 really turns off the calc.
	movem.l	d0-d7/a0-a6,-(sp)	; Save All registers
	
	lea	$600000,a6
	
	; Wait for ON Key to be released.
	move.w	#$2400,SR
\reset	move.w	#$A00,d1
\loop		st.b	$1A(a6)
		moveq	#$50,d0
		dbra	d0,*
		btst.b	#1,$1A(a6)
		beq.s	\reset
		dbra	d1,\loop
	move.w	#$2700,SR
	
	st.b	$1C(a6)			; Turn Off the RS completly
	bclr.b	#1,$70001D		; Disable Screen on HW2
	clr.w	$14(a6)			; Disable Timer $600017 / Disable Int 3 / Disable Lcd on Hw1
					; Calculate CheckSum ?
	clr.b	$03(a6)			; Set Ram Wait State to the highest value
	bset.b	#5,(a6)			; ????
	move.w	#$380,$18(a6)		; Reset KeyBoard / Trig value
	st.b	$1A(a6)			; ackowlegment of On key
	;clr.b	$13(a6)			; 89: Set Logical Height on HW1 ?
					; Save USP & SSP registers ?
	; Copy in RAM of the ShutDown Function (Since we disabled Flash).
	moveq	#8,d0			; Code
	jsr	IdleRam

	move.b	#$21,$1C(a6)		; Reset RS
	move.w	#$200,$18(a6)		; Reset Key board Trig value and set Battery voltage level to 
	
	; Wait a lot
	move.w	#$8000,d0		; $8000 for HW1 / $A666 for HW2 ?
\loop1		moveq	#12*4/10,d1
		dbra	d1,*
		dbra	d0,\loop1
	btst.b	#2,(a6)
	bne.s	\all_right
		moveq	#0,d0
		jsr	IdleRam		; Stop the calculator: the batteries are too low to continue.
		stop	#$2700
\all_right
	move.w	#$1B,$14(a6)		; Reset Timers Ints + Lcd Enable on Hw1
	move.b	#$80,$13(a6)		; 89: Set logical Height
	move.b	#$DE,$3(a6)		; Wait States if < 4.0V
	move.w	#$380,$18(a6)		; Battery Voltage Level
	bset.b	#1,$70001D		; Screen Enable on HW2
	;jsr	OSLinkReset		; Reset Link (FIXME: I think it is a bad idea since we can lost a byte).
	jsr	OSClearBreak		; Clear break Key
	jsr	GKeyFlush		; Reset KeyBoard
	jsr	CheckBatt		; Reset Batt
	cmpi.l	#APD_MIN*20,TIMER_TABLE+TIMER_SIZE+TIMER_RESET_VAL		; APD < 200 ? (10s)
	bge.s	\OkAPD
		move.l	#APD_MIN*20,TIMER_TABLE+TIMER_SIZE+TIMER_RESET_VAL	; APD = 200 ? (10s)
\OkAPD	move.w	#APD_TIMER_ID,-(sp)		; Reset APD timer ?
	jsr	OSTimerRestart
	addq.l	#2,sp
	jsr	OSContrastSet		; Set contrast
	movem.l	(sp)+,d0-d7/a0-a6
	rte


Trap_0:	; Idle
	move.w	#$2700,SR
	move.w	#$280,$600018
	moveq	#$1E,d0		 ; Default: Wake up only for auto int 2, 3, 4, 5, 6 or 7
	tst.w	(KEY_PREVIOUS).w ;	Check if a key is currently processed by the Auto int 1 (in which case the auto int 1 has to handle the auto repeat feature ==> The calculator needs to be awaken in case of auto int 1).
	beq.s	\DontWakeUpIfAutoInt1
		moveq	#$1F,d0		 ; Wake up only for auto int 1, 2, 3, 4, 5, 6 or 7
\DontWakeUpIfAutoInt1:
	ifd	PEDROM_92
		bsr.s	IdleRam		; For 92+ & V200; shut dowwn flash
	endif
	ifd	PEDROM_89		
		move.b	d0,$600005	; Shut Down Micro-proc until an int is trigered	for 89
		nop
	endif
	rte	

IdleRam:
	;Code in ExecRam must be executed with SR = $2700.
	lea	EXEC_RAM,a0
	lea	__offRAM(Pc),a1
	move.w	#__offRAMEnd-__offRAM-1,d1
\loop		move.b	(a1)+,(a0)+
		dbf	d1,\loop
	jmp	EXEC_RAM

__offRAM:
	move.w	$185E00,d1		; Shut Down Flash Rom
	move.b	d0,$600005		; Shut Down Micro-proc until an int is trigered
	nop
	move.w	d1,$185E00		; Enable Flash Rom
	nop
	nop
	rts
__offRAMEnd
	
	
; Go to supervisor mode.
Trap_12:
	move.w	(sp)+,d0
	rts

Trap_NotDefined_str:	dc.b	"Trap not defined",0
ReadError_str		dc.b	"Protected Memory",0
User_str		dc.b	"Abort by user",0
BusError_str		dc.b	"BUS ERROR",0
Spurious_str		dc.b	"SPURIOUS ERROR",0
Address_str		dc.b	"Address error",0
Illegal_str		dc.b	"Illegal instruction",0
Zero_str		dc.b	"Divided by zero",0
Chk_str			dc.b	"Chk instruction",0
TrapV_str		dc.b	"TrapV instruction",0
Privelege_str		dc.b	"Privilege violation",0
Trace_str		dc.b	"Debug mode not available",0
Line1111_str		dc.b	"Line 1111 Emulator",0
Line1010_str		dc.b	"Line 1010 Emulator",0
SystemError_str		dc.b	"SYSTEM ERROR: rebooting...",0
RomCall_str		dc.b	"Rom call not available",0
	EVEN
