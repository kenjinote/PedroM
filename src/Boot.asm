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

        ;; Exported FUNCTIONS: 
        xdef OSStart
	xdef OSCont
	xdef OSCont2


; ***************************************************************
; 		Boot code : setup IO ports
; ***************************************************************

	; Init the calc
	bclr.b	#1,$70001D		; Disable Screen on HW2: it must be the first instruction. Why ?.
	move.w	#$2700,SR		; Prevent Auto Ints
	lea	(SSP_INIT).w,sp		; Setup Supervisor Stack 
	moveq	#0,d0
	
	; Setup IO ports
	lea	$600000,a5		; Address of Port IO 6
	lea	$700000,a6		; Address of Port IO 7
	
	move.w	#$40,$10(a6)		; Link Speed on HW2

	move.b	d0,$15(a5)		; OSC2 and LCD mem stopped on HW1. Don't use clr.b (it reads before).

	move.w	#$FFFF,$18(a5)		; Setup Batt Level to the lowest trigger level (FIXME: WOrks on HW2 ?)
	move.w	#$8000,(a5)		; Pin 100 Enable / Write Protect Vectors desable / 256K of RAM
	move.w	#$374,d1		; Delay to make sure that the hardware has stabilized
	dbf	d1,*
	ifd	PEDROM_92
	btst.b	#$2,(a5)		; Check if Batts are below the lowest level
	beq.s	\voltage_below		; FIXME: bne ?
	endif
		move.b	d0,(a5)		; Do not set Pin100 
\voltage_below

	; Unprotect access to special IO ports
	lea	$1C5EA4,a0
	nop
	nop
	nop
	move.w	#$2700,SR
	move.w	d0,(a0)
	nop
	nop
	nop
	move.w	#$2700,SR
	move.w	d0,(a0)
	
	; Can not use registers to access IO ports <= we have disabled the hardware protection, so a hack may be used.
	; Set Protected IO ports
	ori.b	#4+2+1,$70001F		; HW2: ??? / Enable OSC2 / 5 contrasts bits.

	moveq	#0,d0			; d0.l = 0 (Even if d0=0, I must set it again <= AntiHack).
	move.w	#$003F,$700012		; Allow Execution of all Flash ROM on HW2
	move.w	d0,$45E00		; Allow Execution of all Flash ROM on HW1
	move.w	d0,$85E00
	move.w	d0,$C5E00
	
	; Allow Execution of all RAM on HW2	/* clr.l $700000 : This instruction is potentially dangerous since we reed it before setting it ! */
	move.l	d0,$700000
	move.l	d0,$700004
	
	; Protect access to special IO ports
	nop
	nop
	nop
	move.w	#$2700,SR
	move.w	(a0),d0
	
	; Setup IO ports
	moveq	#0,d0
	ifd	PEDROM_92
		move.b	d0,$3(a5)	; Setup Bus Wait States (Very slow).
	endif
	ifd	PEDROM_89
		move.b	#$FF,$3(a5)	; Setup Bus Wait State (Very fast).
	endif	
	move.b	d0,$C(a5)		; Setup Link Port (Nothing enable link ports)
	move.w	#$3180,$12(a5)		; Set LCD logical width / Set LCD logical height
	move.w	#LCD_MEM/8,$10(a5)	; Set LCD memory address on HW1
	move.b	d0,$17(a6)		; Set LCD memory address on HW2.
	move.b	#$21,$1C(a5)		; Set LCD RS
	move.b	#$B2,$17(a5)		; Reset $600017 cycles on HW1.
	move.b	#$1B,$15(a5)		; Enable Timer Interrupts / Increment rate of $600017 (OSC2/2^9) / Enable $600017 / Disable Int 3 / Enable OSC2 / Enable LCD on HW1
	bset.b	#1,$1D(a6)		; Enable LCD on HW2
	move.w	#$FFFF,$1A(a5)		; acknowledge AutoInt 6 & AutoInt 2
	
	; Clear 256K of RAM
	suba.l	a0,a0
	moveq	#-1,d0			; 256K / 4 = 64K-1 = $FFFF
\ClearRAM_loop:
		clr.l	(a0)+
		dbf	d0,\ClearRAM_loop
		
	; Copy Vector Table
	jsr	InstallVectors
	
	; Check the range of the system
	move.l	#BASE1_END,a1
	cmp.l	#ROM_BASE+$18000,a1
	bhi	*
	move.l	#BSSSectionStart,a1
	cmp.l	#data_start_offset,a1
	bne	*

; ***************************************************************
; 		Init the Operating System
; ***************************************************************

	; Check ON-Key : if it is pressed, do not run the start script
	btst.b	#1,$60001A			; Test if ON key if pressed
	sne	(RUN_START_SCRIPT).w		; ON key is pressed : Do not start 'start' script.
	; Reset time
	clr.l	(Tick).w ; FiftyMSecTick
OSStart:
	; Display License while booting.
	jsr	InitGraphSystem
	pea	Pedrom_str(pc)
	bsr.s	\printf
	pea	Author_str(pc)
	bsr.s	\printf
	pea	License_str
	bsr.s	\printf
	; Boot System
	jsr	HeapInit			; Init Handles.
	jsr	VATInit				; Init VAT.
	jsr	EStackInit			; Init the EStack.
	jsr	FlashCheck			; Init & Check the Flash.
	jsr	FlashAddArchivedFiles		; Add the archived files in the VAT.
	ifnd	GPL
	lea	StdLib_sym(pc),a0
	lea	StdLib_FILE,a4
	jsr	VATAddSpecialFile		; Add 'stdlib' to the system.
	endif
	bra.s	OSCont2
\printf	jmp	printf

OSCont:	; Reset OS without reseting the Heap and the VAT
	clr.b	(RUN_START_SCRIPT).w		; Do not run the 'start' script
OSCont2	lea	(SSP_INIT).w,sp			; Setup Supervisor Stack 
	lea	(USP_INIT).w,a0
	move.l	a0,usp				; Setup User Stack

	jsr	InstallVectors			; Install Vectors (Again)

	jsr	FL_getHardwareParmBlock		; Get the Hardware Parm Block
	move.w	(a0)+,d1			; Read and skip size
	move.l	(a0)+,d2			; Read Calculator ( 1 : 92+ / 3 : 89 / V200 : 8)
	move.l	(a0)+,d5			; Read Hardware Revision version
	move.w	#$B2,$600016			; Reset $600017 cycles on HW1.
	moveq	#1,d3				; HW_VERSION = 1
	cmpi.w	#$16,d1				; Gate Array field to
	bls.s	\OrgHw1				; see which hardware it is.
		move.l	($16-2-4-4)(a0),d3	; Read HW_VERSION (Even on EMULATOR, HW_VERSION =1, since the default is 1, not 2 !)
\OrgHw1	cmpi.w	#1,d3
	beq.s	\Hw1
		move.w	#$CC,$600016		; Reset $600017 cycles on HW2.
\Hw1	
	lea	WrongCalc_str(pc),a0
	ifnd	TI89TI				; Titanium is 9, so can't use subq
	subq.l	#CALC_BOOT_TYPE,d2		; Check if ROM and calc are compatible
	endif
	ifd	TI89TI
	sub.l	#CALC_BOOT_TYPE,d2
	endif
	bne	BOOT_ERROR			; System Error

	; Detection of Emulator ?
	clr.b	d4				; Emulator = False
	moveq	#-97,d1				; Vti detection by JM
	nbcd	d1
	bmi.s	\real_calc
\emu:		st.b	d4			; EMULATOR = TRUE
\real_calc

	; Save Kernel values
	lea	(CALCULATOR).w,a0
	move.b	#CALC_KERNEL_TYPE,(a0)+		; Detec CALCULATOR
	move.b	d3,(a0)+			; Detect HW version
	move.b	d5,(a0)+			; Detect HW revision version
	move.b	d4,(a0)+			; Emulator
	move.l	-4(a0),(a0)	                ; Copy it for emulation
	ifd	PEDROM_92
	move.b	#1,(a0)				; Emulate a 92+
	endif
	ifd	PEDROM_89
	clr.b	(a0)				; Emulate a 89
	endif
	jsr	KernelReinit			; Reinit some Kernel Pointer
	
	; Init ER_throw
	clr.l	ERROR_LIST			; Empty List
	
	; Init Timers
	clr.l	-(a7)				; Timer 0
	moveq	#TIMER_NUMBER-1,d3
\timer_loop	addq.w	#1,(a7)			; Timer++
		jsr	OSFreeTimer
		dbf	d3,\timer_loop
	; Register Batt Timer
	pea	CheckBatt
	pea	(BATT_TIMER_VALUE).w		; 5s
	move.w	#BATT_TIMER_ID,-(a7)		; Batt Timer
	jsr	OSVRegisterTimer		; Every 5s we check the BATTS
	; Register APD Timer
	pea	(20*APD_DEFAULT).w			; 100s
	move.w	#APD_TIMER_ID,-(a7)		; APD Timer
	jsr	OSRegisterTimer			; We put the calc off after 100s
	; Register LIO Timer
	pea	(LIO_TIMER_VALUE).w		; 6s
	move.w	#LIO_TIMER_ID,-(a7)		; LIO Timer
	jsr	OSRegisterTimer			; Max wait for the link functions

	; Init Cursor: Register Cursor Timer
	pea	CU_Interrupt
	pea	(CURSOR_TIMER_VALUE).w		; .50s
	move.w	#CURSOR_TIMER_ID,-(a7)		; CURSOR
	jsr	OSVRegisterTimer		; Clignotement speed
	jsr	CU_stop
	
	; Init Contrast
	jsr	OSContrastInit

	; Init Key System
	jsr	GKeyFlush
	move.w	#KEY_INIT_BETWEEN_KEY_DELAY,(a7)
	jsr	OSInitBetweenKeyDelay
	move.w	#KEY_INIT_KEY_INIT_DELAY,(a7)
	jsr	OSInitKeyInitDelay
	pea	(KBD_QUEUE).w
	jsr	OSqclear
	jsr	OSEnableBreak			; Allow Break

	; ReInit Graph System
	jsr	InitGraphSystem
	
	; Init Window System
	lea	(DeskTopWindow).w,a0			
	move.l	a0,(DeskTop).w			; Set the DeskTop ptr
	clr.w	WINDOW.Flags(a0)		; Set flags
	move.b	#1,WINDOW.CurAttr(a0)		; Set Attr
	move.b	#1,WINDOW.CurFont(a0)		; Set Font
	jsr	WinHome_reg			; Set X,Y
	clr.w	WINDOW.Background(a0)		; Set BackGround
	clr.w	WINDOW.DupScr(a0)		; Set Save Screen
	move.l	#239*256+120,d0			
	move.l	d0,WINDOW.Window(a0)		; Set Window
	move.l	d0,WINDOW.Client(a0)		; client
	move.l	d0,WINDOW.Clip(a0)		; & clip
	move.l	#LCD_MEM,WINDOW.Screen(a0)	; Set duplicate (Well it is LCD ;))
	clr.l	WINDOW.Next(a0)			; No next window
	move.l	a0,(FirstWindow).w		; Add it in the list
	
	; Init Link System
	jsr	OSLinkReset			; Reset the link
	
	; ReInit Heap before any other services which used the Heap !
	; Ie Estack
	jsr	HeapCheck			; Check Heap
	jsr	HeapCompress			; Compress the Heap

	; ReInit EStack
	jsr	EStackReInit
	
	; ReInit Side
	jsr	init_side

	; Check ON Key : Do a system reset if it is pressed ?
	btst.b	#1,$60001A			; Test if ON key if pressed
	beq	CODE_START			; ON key is pressed : Reset the calc.
	
	lea	(SSP_INIT).w,sp			; Pop all args ;)
	move.w	#$0000,SR			; Start System : User Mode
	
	bra	ShellCommand			; Go to the Command Shell
BOOT_ERROR:
	jmp	SYSTEM_ERROR			; Error while booting ! System Error !

InstallVectors:
	bclr.b	#2,$600001			; Unprotect Vector Table
	; Copy org Vectors
	lea	VECTORS_TABLE(PC),a0
	suba.l	a1,a1
	moveq	#$3F,d0
\loop		move.l	(a0)+,(a1)+
		dbf	d0,\loop
	bset.b	#2,$600001			; Protect Vector Table
	rts
