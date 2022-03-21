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
        xdef Idle
        xdef idle
        xdef OSContrastInit
        xdef OSContrastUp
        xdef OSContrastSet
        xdef OSContrastDn
        xdef off
        xdef ER_catch
        xdef ER_success
        xdef ER_throwVar
        xdef ER_throwVar_reg
        xdef OSVFreeTimer
        xdef OSFreeTimer
        xdef OSTimerCurVal
        xdef OSTimerCurVal_Reg
        xdef OSTimerExpired
        xdef OSTimerRestart
        xdef OSVRegisterTimer
        xdef OSRegisterTimer
        xdef _RegisterTimer
        xdef OSDisableBreak
        xdef OSEnableBreak
        xdef OSClearBreak
        xdef OSCheckBreak
        xdef OSInitBetweenKeyDelay
        xdef OSInitKeyInitDelay
        xdef GKeyDown
        xdef kbhit
        xdef GetKey
        xdef GKeyIn
        xdef ngetchx
        xdef GKeyFlush
        xdef pushkey
        xdef HToESI
        xdef HToESI_reg
        xdef OSqclear
        xdef errorPrintf
        xdef printf
        xdef printf_toFILE
        xdef getenv
        xdef atol
        xdef atoi
        xdef CU_stop
        xdef CU_start
        xdef CU_restore
        xdef CU_BlinkCursor
        xdef CU_Interrupt


;******************************************************************
;***                                                            ***
;***            	Misc Functions (1)			***
;***                                                            ***
;******************************************************************

; void idle(void)
Idle:
idle:
	trap	#0
	rts
	
; void OSContrastInit(void)
OSContrastInit:
	moveq	#$0F,d1				; Max value on HW1
	cmpi.b	#1,(HW_VERSION).w
	bls.s	\ok
		moveq	#$1F,d1			; Max value on HW2
\ok:	move.b	d1,(CONTRAST_MAX_VALUE).w	; Save Max Contrast Value
	lsr.b	#1,d1
	move.b	d1,(CONTRAST_VALUE).w		; Initial value of contrast is Max/2+1
	
; void OSContrastUp(void)
OSContrastUp:
	movem.l	d0-d1,-(a7)			; Some programs assume d0,d1 aren't destroy ! (Tbo68k for example !)
	move.b	(CONTRAST_MAX_VALUE).w,d1
	move.b	(CONTRAST_VALUE).w,d0
	and.b	d1,d0
	cmp.b	d1,d0
	beq.s	ContrastReturn
	addq.b	#1,d0
	bra.s	ContrastSet

;void OSContrastSet(void)
OSContrastSet:
	movem.l	d0-d1,-(a7)			; Some programs assume d0,d1 aren't destroy ! (Tbo68k for example !)
	move.b	(CONTRAST_VALUE).w,d0
	bra.s	ContrastSet

;void OSContrastDn(void)
OSContrastDn:
	movem.l	d0-d1,-(a7)			; Some programs assume d0,d1 aren't destroy ! (Tbo68k for example !)
	move.b	(CONTRAST_MAX_VALUE).w,d1	; =$0F sur HW1
	move.b	(CONTRAST_VALUE).w,d0
	and.b	d1,d0
	beq.s	ContrastReturn
	subq.b	#1,d0

ContrastSet:
	move.b	d0,(CONTRAST_VALUE).w
	ifd	PEDROM_92
		not.b	d0		; For 92+/V200
		cmpi.b	#1,(HW_VERSION).w
		bne.s	Contrastno_hw1
			btst.l	#0,d0
			beq.s	Contrastclearit
				bset.b	#5,($600000).l
Contrastcont:		lsr.b	#1,d0
Contrastno_hw1	move.b	d0,($60001D).l
ContrastReturn:
	movem.l	(a7)+,d0-d1			; Some programs assume d0,d1 aren't destroy ! (Tbo68k for example !)
	rts
Contrastclearit:	bclr.b	#5,($600000).l
			bra.s	Contrastcont
	endif
	ifd	PEDROM_89
		ori.b	#$80,d0		; For 89
		cmpi.b	#1,(HW_VERSION).w
		bne.s	Contrastno_hw1
			andi.b	#$EF,d0
Contrastno_hw1	move.b	d0,$60001D
ContrastReturn:
	movem.l	(a7)+,d0-d1			; Some programs assume d0,d1 aren't destroy ! (Tbo68k for example !)
	rts
	endif

; void off(void)
off:
	trap	#4
	rts
	
;short ER_catch (void *ErrorFrame);
ER_catch:
	move.l	4(a7),a0
	move.l	(ERROR_LIST).w,d1		; Get Error List
	move.l	a0,(ERROR_LIST).w		; Save New Error List Header
	movem.l	d3-d7/a2-a7,(a0)		; Save Registers
	lea	(7-3+1+7-2+1)*4(a0),a0
	move.l	(VAR_SYSTEM1).w,(a0)+		; Save System Var
	move.l	(top_estack).w,(a0)+		; Save top_estack
	move.l	(a7),(a0)+			; Save Return Address
	move.l	d1,(a0)+			; Save Old Error List to create the list
	clr.w	d0
	rts

;void ER_success (void);
ER_success:
	move.l	(ERROR_LIST).w,a0			; Pop the header of the current list
	move.l	$38(a0),(ERROR_LIST).w
	rts
	
;void ER_throwVar (short err_no); 
ER_throwVar:
	move.w	4(a7),d0			; Transform error 0 in 1
	bne.s	ER_throwVar_reg
		moveq	#1,d0
ER_throwVar_reg:
	jsr	OSClearBreak			; CLear break (FIXME: good idea?)
	move.l	(ERROR_LIST).w,d1		; Is List Empty ?
	bne.s	\ok
		jsr	find_error_message_reg
		jmp	FATAL_ERROR		; Yes => Fatal Error
\ok:	move.l	d1,a0			
	movem.l	(a0)+,d3-d7/a2-a7		; Restore registers
	addq.l	#4,a7				; Pop return address (should be the same as a1)
	move.l	(a0)+,(VAR_SYSTEM1).w
	move.l	(a0)+,(top_estack).w		; Get top_estack
	move.l	(a0)+,a1			; Read Return address
	move.l	(a0),(ERROR_LIST).w			; Pop current header
	jmp	(a1)				; Return to program 
						; A rts without doing an addq should do the same job.
						
;short OSVFreeTimer (short timer_no); 
;short OSFreeTimer (short timer_no); 
OSVFreeTimer:
OSFreeTimer:
	moveq	#0,d0
	move.w	4(a7),d2
	subq.w	#1,d2
	cmpi.w	#TIMER_NUMBER,d2
	bcc.s	\error
		mulu.w	#TIMER_SIZE,d2
		lea	(TIMER_TABLE).w,a0
		clr.w	TIMER_TYPE(a0,d2.w)
		clr.l	TIMER_CUR_VAL(a0,d2.w)
		clr.l	TIMER_CALLBACK(a0,d2.w)
		moveq	#1,d0
\error:	rts

;unsigned long OSTimerCurVal (short timer_no);
OSTimerCurVal:
	move.w	4(a7),d0
OSTimerCurVal_Reg:
	subq.w	#1,d0
	lea	(TIMER_TABLE).w,a0
	mulu.w	#TIMER_SIZE,d0
	move.l	TIMER_CUR_VAL(a0,d0.w),d0
	rts

;short OSTimerExpired (short timer_no);
OSTimerExpired:
	move.w	4(a7),d0
	bsr.s	OSTimerCurVal_Reg
	tst.l	d0
	seq	d0
	ext.w	d0
	rts
	
;unsigned long OSTimerRestart (short timer_no);
OSTimerRestart:
	moveq	#-1,d0
	move.w	4(a7),d2
	subq.w	#1,d2
	cmpi.w	#TIMER_NUMBER,d2
	bcc.s	\error
		mulu.w	#TIMER_SIZE,d2
		lea	(TIMER_TABLE).w,a0
		move.l	TIMER_CUR_VAL(a0,d2.w),d0
		move.l	TIMER_RESET_VAL(a0,d2.w),TIMER_CUR_VAL(a0,d2.w)
\error:	rts

;short OSVRegisterTimer (short timer_no, unsigned long T, Timer_Callback_t Action);
OSVRegisterTimer:
	move.l	10(a7),a1	; CallBack
	bra.s	_RegisterTimer

;short OSRegisterTimer (short timer_no, unsigned long T);
OSRegisterTimer:
	suba.l	a1,a1		; No Callback
_RegisterTimer:
	moveq	#0,d0
	move.w	4(a7),d2	; Timer No
	subq.w	#1,d2
	cmpi.w	#TIMER_NUMBER,d2
	bcc.s	\error
		mulu.w	#TIMER_SIZE,d2
		lea	(TIMER_TABLE).w,a0
		tst.b	TIMER_TYPE(a0,d2.w)
		bne.s	\error
			move.l	6(a7),d0			; Read initial value of timer
			move.l	d0,TIMER_RESET_VAL(a0,d2.w)	; Reset Value
			move.l	d0,TIMER_CUR_VAL(a0,d2.w)	; Current Value of Timer
			move.l	a1,TIMER_CALLBACK(a0,d2.w)
			moveq	#TIMER_TYPE_COUNT,d0
			move.l	a1,d1
			beq.s	\done
				moveq	#TIMER_TYPE_VECTOR,d0
\done:			move.b	d0,TIMER_TYPE(a0,d2.w)
\error	rts

;void OSDisableBreak (void); 
OSDisableBreak:
	clr.b	(ENABLE_BREAK_KEY).w
	bra.s	OSClearBreak

;void OSEnableBreak (void);
OSEnableBreak:
	st.b	(ENABLE_BREAK_KEY).w

;void OSClearBreak (void);
OSClearBreak:
	st.b	$60001A			; Clear call int 6 (If SR = 2700)
	clr.b	(BREAK_KEY).w
	rts

;short OSCheckBreak (void);
OSCheckBreak:
	clr.w	d0
	move.b	(BREAK_KEY).w,d0
	rts
	
;short OSInitBetweenKeyDelay (short rate);
OSInitBetweenKeyDelay:
	move.w	(KEY_ORG_REPEAT_CPT).w,d0
	move.w	4(a7),(KEY_ORG_REPEAT_CPT).w
	rts

;short OSInitKeyInitDelay (short delay);
OSInitKeyInitDelay:
	move.w	(KEY_ORG_START_CPT).w,d0
	move.w	4(a7),(KEY_ORG_START_CPT).w
	rts
	
;short GKeyDown (void);
;short kbhit (void);
GKeyDown:
kbhit:
	move.w	(TEST_PRESSED_FLAG).w,d0
	or.b	(BREAK_KEY).w,d0
	rts

; short GetKey(void)
GetKey:
;short GKeyIn (SCR_RECT *cursor_shape, unsigned short Flags); 
GKeyIn:
	movem.l	d1-d3/a0-a1,-(a7)		; For internal functions, I preserve d1-d2/a0-a1
	clr.w	d0
	trap	#1				; All ints allowed
	move.l	(OLD_DISP_STATUS).w,d3		; Reload previous displayed status
	move.w	#APD_TIMER_ID,-(a7)		; Push Timer 2 (APD)
\restart:
	jsr	OSTimerRestart			; Reset APD timer
\wait:		jsr	OSTimerExpired		; Check APD timer expired?
		tst.w	d0
		bne.s	\Off			; Yes so turn off.
		jsr	Idle			; Wait for a new hardware event to occur.
		jsr	OSCheckSilentLink	; Something received in the link port ?
		tst.w	d0			
		bne.s	\Link			; Yes so deal with the link.
		cmp.l	(KEY_STATUS).w,d3		; Check if the status bar has to been updated ?
		bne.s	\UpdateStatus
		tst.b	(BREAK_KEY).w		; Check Break Key
		bne.s	\Break
		tst.w	(TEST_PRESSED_FLAG).w	; Check other keys
		beq.s	\wait
	moveq	#0,d0
	move.w	(GETKEY_CODE).w,d0
	clr.w	(TEST_PRESSED_FLAG).w		; Aknowlegedment of Current Key
	cmpi.w	#KEY_SWITCH,d0
	beq.s	\Switch
\End	move.l	d3,(OLD_DISP_STATUS).w		; Save status bar info.
	andi.w	#~KEY_AUTO_REPEAT,d0		; Disable auto-repeat bit
	addq.l	#2,a7				; Pop APD timer
	movem.l	(a7)+,d1-d3/a0-a1		; Restore registers.
	rts

\Off:	trap	#5				; Turn the calc off.
	bra.s	\restart
\Link:	jsr	OSLinkCmd			; Yes -> Interpret received packet
	bra.s	\restart
\Break:	jsr	OSClearBreak			; Clear Break Key
	move.w	#KEY_ON,d0			; Return ON Key
	bra.s	\End
\UpdateStatus:
	move.l	(KEY_STATUS).w,d0			; Update Statut in Stat Line
	move.l	d0,d3
	rol.l	#4,d0				; SHIFT-Alpha Lock: 16 / Alpha Lock: 32
	ifd	PEDROM_89
		move.b	(KEY_MAJ).w,d1
		beq.s	\StatusDone
		moveq	#8,d0
		lsl.w	d1,d0			; D0 = 16 if ShiftAlphaLock(KEY_MAJ=2) / 32 If AlphAlpha
\StatusDone
	endif
	move.w	d0,-(a7)
	jsr	ST_modKey
	addq.l	#2,a7
	bra.s	\restart
\Switch:
	btst.l	#2,(SHELL_FLAGS).w
	beq.s	\End
		move.l	(ARGV).w,a0
		suba.l	a1,a1
		moveq	#PID_SAVE_LCD_MEM+PID_SAVE_VECTORS+PID_SAVE_IO,d0
		moveq	#-1,d1			; Another shell
		jsr	PID_Switch		; Task Switch
		bra	\restart


;short ngetchx (void);
ngetchx:
	move.l	d3,-(a7)		
	clr.w	d0
	trap	#1			; All ints allowed
	move.l	(OLD_DISP_STATUS).w,d3	; Status
\wait:		jsr	OSCheckSilentLink	; Something received in the link port ?
		tst.w	d0
		bne.s	\Link
		cmp.l	(KEY_STATUS).w,d3		; Check if the statut has been updated ?
		bne.s	\UpdateStatut
		tst.b	(BREAK_KEY).w		; Check Break Key
		bne.s	\Break
		tst.w	(TEST_PRESSED_FLAG).w	; Check other keys
		beq.s	\wait
	moveq	#0,d0
	move.w	(GETKEY_CODE).w,d0
	clr.w	(TEST_PRESSED_FLAG).w	; Aknowlegedment of Current Key
	cmpi.w	#KEY_SWITCH,d0
	beq.s	\Switch
\End	move.l	d3,(OLD_DISP_STATUS).w
	andi.w	#~KEY_AUTO_REPEAT,d0		; Disable auto-repeat bit
	move.l	(a7)+,d3
	rts
\Switch:
	btst.l	#2,(SHELL_FLAGS).w
	beq.s	\End
		move.l	(ARGV).w,a0
		suba.l	a1,a1
		moveq	#PID_SAVE_LCD_MEM+PID_SAVE_VECTORS+PID_SAVE_IO,d0
		moveq	#-1,d1			; Another shell
		jsr	PID_Switch	; Switch !
		bra.s	\wait
\Link:	jsr	OSLinkCmd	; Yes -> Interpret command
	bra.s	\wait
\Break:	jsr	OSClearBreak	; Clear Break Key
	move.w	#KEY_ON,d0	; Return ON Key
	bra.s	\End
\UpdateStatut:
	move.l	(KEY_STATUS).w,d0		; Update Statut in Stat Line
	move.l	d0,d3
	rol.l	#4,d0
	ifd	PEDROM_89
		move.b	(KEY_MAJ).w,d1
		beq.s	\StatusDone
		moveq	#8,d0
		lsl.w	d1,d0		; D0 = 16 if ShiftAlphaLock(KEY_MAJ=2) / 32 If AlphAlpha
\StatusDone
	endif
	move.w	d0,-(a7)
	jsr	ST_modKey
	addq.l	#2,a7
	bra.s	\wait


; void GKeyFlush(void)
GKeyFlush:
	clr.w	(KEY_CUR_POS).w
	clr.w	(TEST_PRESSED_FLAG).w
	clr.w	(KEY_STATUS).w
;	clr.b	KEY_MAJ
	rts
	
; void pushkey(short key)
pushkey:
	move.w	4(a7),(GETKEY_CODE).w
	st.b	(TEST_PRESSED_FLAG).w
	rts
	
;ESI HToESI (HANDLE Handle);
HToESI:
	move.w	4(a7),a0
HToESI_reg:
	trap	#3
	moveq	#0,d0
	move.w	(a0),d0
	lea	1(a0,d0.l),a0
	rts

;void OSqclear (void *Queue); 
OSqclear:
	move.l	4(a7),a0
	clr.l	(a0)+
	move.w	#2,(a0)+
	clr.w	(a0)+
	rts
	
	;; Print to sdterr
errorPrintf:
	lea	(FILE_TAB+20).w,a0
	bra.s	printf_toFILE

	;; Print to stdout
printf:
	lea	(FILE_TAB+10).w,a0
printf_toFILE:	
	link.w	a6,#0
	pea	12(a6)
	move.l	8(a6),-(sp)
	pea	(a0)
	pea	fputc
	jsr	vcbprintf
	unlk	a6
	rts

; const char *getenv(const char *name asm("a2"));
; Environement variable are stored in system folder as strings.
; So it searchs for "system\name", check it is a string file and returns it 
getenv:
	movea.w	#FOLDER_LIST_HANDLE,a0
	lea	SystemFolder_str,a1
	bsr.s	\FindSymEntry
	move.l	a0,d0
	beq.s	\Failed
	move.w	SYM_ENTRY.hVal(a0),a0
	move.l	a2,a1
	bsr.s	\FindSymEntry
	move.l	a0,d0
	beq.s	\Failed
	move.w	SYM_ENTRY.hVal(a0),a0
	trap	#3
	moveq	#0,d0
	move.w	(a0)+,d0
	cmpi.b	#$2D,-1(a0,d0.l)
	beq.s	\Success
\Failed:
	suba.l	a0,a0
	rts
\FindSymEntry
	jmp	FindSymEntry
\Success:
	addq.l	#1,a0
	rts

; getenv_si
;In:
;  a2 -> String
;  d1.w = Min
;  d2.w = Max
;  d3.w = Default value
;Out:
;  d0.w = Value
getenv_si:
	movem.l	d1-d3,-(a7)
	jsr	getenv
	move.l	a0,d0
	beq.s	\Default		; Symbol not found.
	bsr.s	atol			; Transform it to a number
	movem.l	(a7),d1-d3		; Read back min and max
	cmp.w	d1,d0			; Check if the value is out of range
	blt.s	\Default		; min
	cmp.w	d2,d0			; max
	ble.s	\End
\Default:
	move.w	d3,d0
\End:	movem.l (a7)+,d1-d3
	rts

; Convert an hexdecimal/decimal string in an unsigned number
; In:
;	a0 -> string(NULL)
; Out:
;	d0.l = Number (atol)
;	d0.w = Number (atoi)
; Destroy:
;	d0-d2/a0
; atoi performs the same function but returns only d0.w (simpler & smaller)
atoi:	
atol:
	clr.w	d0
	suba.l	a1,a1
	jmp	strtol

;short CU_stop (void);
; Destroy only d0
CU_stop:
	clr.w	d0
	move.b	(CURSOR_STATE).w,d0		; Read current state of cursor (active/inactive)
	clr.b	(CURSOR_STATE).w		; Stop Cursor : stop auto-int
	tst.b	(CURSOR_PHASE).w		; Check if cursor is currently displayed
	bne.s	CU_BlinkCursor			; Yes, so erase it
	rts

;short CU_start (void);
; Destroy only d0
CU_start:
	bsr.s	CU_stop
	bsr.s	CU_BlinkCursor
	st.b	(CURSOR_STATE).w
	rts

;void CU_restore (short State);
; Destroy only d0
CU_restore:
	bsr.s	CU_stop
	move.w	4(a7),d0
	move.b	d0,(CURSOR_STATE).w
	rts

; void CU_BlinkCursor(void)
CU_BlinkCursor:
	movem.l	d0-d2/a0,-(a7)
	not.b	(CURSOR_PHASE).w	; change the phase 00->ff or ff->00
	move.w	(CURRENT_POINT_X).w,d0
	move.w	(CURRENT_POINT_Y).w,d1
	cmpi.w	#SCR_WIDTH-8,d0		; Check overflow
	bhi.s	\End
	cmpi.w	#SCR_HEIGHT-8,d1
	bhi.s	\End
	movea.l	(CURRENT_SCREEN).w,a0	; a0 = *VideoRAM
	; calculate the offset and Mask of the cursor
	addq.w	#USED_FONT*2+5,d1	; d1 = Y-coord of bottom of cursor
	mulu	#30,d1			; d1 = line-offset of -"-
	move.w	d0,d2			; d2 = number of byte within line
	lsr.w	#3,d2			
	add.w	d2,d1			; d1 = byte offset within screen
	adda.w	d1,a0			; a0 = absolute byte offset of cursor
	andi.w	#$0007,d0		; d0 = pixel number within byte
	move.w	#%1111110000000000,d1	; d1 = cursor-mask
	lsr.w	d0,d1			; d1.b = cursor mask 2
	move.w	d1,d0			; d0.b = cursor mask 1
	lsr.w	#8,d0
	; invert the cursor
	moveq	#CURSOR_SIZE-1,d2
\Loop:		eor.b	d0,(a0)+
		eor.b	d1,(a0)+
		lea	-32(a0),a0
		dbra	d2,\Loop
\End	movem.l	(a7)+,d0-d2/a0
	rts

CU_Interrupt:
	tst.b	(CURSOR_STATE).w	; Check if the cursor is displayed
	bne.s	CU_BlinkCursor		; Yes, display it.
\End:	rts	
