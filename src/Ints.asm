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

	include "Const.h"
	
        ;; Exported FUNCTIONS: 
        xdef Int_1
        xdef Int_2
	xdef Int_3
	xdef Int_4
        xdef Int_5
        xdef Int_6
        xdef Int_7
        xdef CheckBatt
        xdef KeyScan
        xdef UpDateKeyBuffer
        xdef AddKey
        xdef AddKeyToFIFOKeyBuffer


; Scan for the hardware to know what keys are pressed 
Int_1:
	move.w	#$2600,SR
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	KeyScan			; Scan all the keys of the calc
	jsr	UpDateKeyBuffer		; Update the Key Buffer
	tst.w	d4			; Check if a new key has been pressed
	beq.s	\NoKey
		jsr	ST_eraseHelp	; Erase the help (A key has been pressed)
		jsr	AddKey		; Add this new key in the buffer.
\NoKey:	movem.l	(a7)+,d0-d7/a0-a6
	rte

	
; Does nothing. Why ? Look:
;  Triggered when the *first* unmasked key (see $600019) is *pressed*.
;  Keeping the key pressed, or pressing another without released the first
;  key, will not generate additional interrupts.  The keyboard is not
;  debounced in hardware and the interrupt can occasionally be triggered many
;  times when the key is pressed and sometimes even when the key is released!
;  So, you understand why you don't use it ;)
;  Write any value to $60001B to acknowledge this interrupt.
Int_2:	move.w	#$2600,SR
	move.w	#$00FF,$60001A		; acknowledge Int2
Int_3:	rte				; Int 3 is USB device for Titanium.
	
; Link Auto-Int is in Tib.asm since it may be installed in RAM
; during TIB receive.

; Auto-Ints which allows the system timers.
Int_5:
	movem.l	d0-d7/a0-a6,-(sp)	
	lea	(TIMER_TABLE).w,a5				; Timer table
	moveq	#TIMER_NUMBER-1,d7			; Number of timers
\timer_loop:
		move.b	TIMER_TYPE(a5),d6		; Get type of timer
		beq.s	\next				; If type ==0, this timer was freed.
		move.l	TIMER_CUR_VAL(a5),d0		; Get timer value
		beq.s	\next				; If =0, stop.
			subq.l	#1,d0			; Decremente timer
			move.l	d0,TIMER_CUR_VAL(a5)	; and save the new value
			bne.s	\next			; Check the end of the timer 
			subq.b	#TIMER_TYPE_COUNT,d6	; Check if callback timer
			beq.s	\next		
				move.l	TIMER_RESET_VAL(a5),TIMER_CUR_VAL(a5)	; Reset timer
				move.l	TIMER_CALLBACK(a5),a0			; Call the callback.
				jsr	(a0)
\next:		lea	TIMER_SIZE(a5),a5		; Next timer
		dbf	d7,\timer_loop			
	addq.l	#1,(Tick).w                             ; Increment FiftyMSecTick
	movem.l	(sp)+,d0-d7/a0-a6		
	rte

; ON Int.
;	2ND / DIAMOND : Off
;	ESC : Reset
Int_6:
	movem.l	d0/a0/a2,-(sp)		; Save d0/a0
	lea	$600018,a2		; IO port
	move.w	(a2),-(a7)		; Save Mask Port
	btst.b	#1,($1A-$18)(a2)	; Test if ON key if effectively pressed
	bne.s	\end			; ON key is not pressed
					; Test if ESC is pressed
	lea	User_str(Pc),a0		; Abort by user
	move.w	#KEY_ESC_ROW,(a2)	; Write mask (int1 & 5 can't be called ;)
	moveq	#$58,d0			; $58
		dbra	d0,*		; (Waits)
	btst	#KEY_ESC_COL,$1B-$18(a2) ; Read Key Matrix (ESC key)
	beq	FATAL_ERROR		; Yes => Crash handler

	move.w	(KEY_STATUS).w,d0	; Check 2nd or diamond
	cmp.w	#KEY_2ND,d0
	beq.s	\Off
	cmp.w	#KEY_DIAMOND,d0
	bne.s	\NoOff
\Off		clr.w	(KEY_STATUS).w	; Erase 2nd/diamond flag
		clr.b	(KEY_MAJ).w	; Clear Majusucule Key
		clr.w	-(a7)
		jsr	ST_modKey
		addq.l	#2,a7
		trap	#4
		bra.s	\end
\NoOff:	
	; Break Flag
	tst.b	(ENABLE_BREAK_KEY).w
	beq.s	\no_set
		tst.b	(BREAK_KEY).w
		bne.s	\no_set
			st.b	($1A-$18)(a2)		; acknowledge [ON] key interrupt (6)
			st.b	(BREAK_KEY).w
\LoopOn			btst.b	#1,($1A-$18)(a2)	; Test if ON key if effectively pressed
			beq.s	\LoopOn			; ON key is still pressed
\no_set:

\end:	st.b	($1A-$18)(a2)		; acknowledge [ON] key interrupt (6)
	move.w	(a7)+,(a2)		; Restore Mask Port
	movem.l	(a7)+,d0/a0/a2
	rte

Int_7:
	lea	ReadError_str(Pc),a0
	bra	FATAL_ERROR
		
; SUB FUNCTIONS
; Check the batteries level.	
NEW_BATTERY_CODE    EQU	      1
	ifeq	NEW_BATTERY_CODE
CheckBatt:
	movem.l	d1-d7/a0-a6,-(a7)
	move.w	#$2500,SR

	; Setup Ptr
	lea	$600018,a0
	lea	$70001C,a3
	lea	BattTable_HW2(Pc),a2
	cmpi.b	#1,HW_VERSION
	beq.s	\ok
		lea	BattTable_HW1(Pc),a2
\ok	
	; Start Checking
	move.w	#$F,(A3)			; Set HW2 Ports for Batt Check
	moveq	#2,d2				; 3 times
\loop0
		bsr.s	\CheckBattIO		; Loop
		move.w	d2,d0
		add.w	d0,d0
		move.w	0(a2,d0.w),(a0)
		moveq	#$6E,d0
\loop8		btst.b	#2,-$18(a0)
		dbeq	d0,\loop8
		bne.s	\stop
		dbf	d2,\loop0	
\stop:	
	addq.w	#1,d2
	move.w	#7,(a3)				; Unable Batt Check 1 for HW2 (FIXME: Why ?)
	bsr.s	\CheckBattIO			; ie restore the standard waiting
	move.w	#6,(a3)				; Unable Batt Check 2 for HW2

	st.b	d0				; Flash Rom & Ram Wait States
	cmpi.b	#1,(HW_VERSION).w		; Are only modified on HW1
	bne.s	\end
		move.b	BattWaitStateLevel(Pc,d2.w),d0
\end:	move.b	d0,($3-$18)(a0)			; Set new Wait States
	move.w	d2,d0
	move.b	d0,(BATT_LEVEL).w
	movem.l	(a7)+,d1-d7/a0-a6
	rts

; Battery voltage level is below the trig level if 600000.2=0
\CheckBattIO:
	move.w	#$380,(a0)		; Setup the minimum trig level
	moveq	#$52,d0			; Wait Hardware Answer
\loop3		btst.b	#2,-$18(a0)
		dbne	d0,\loop3
	rts

BattWaitStateLevel	dc.b	$CD,$DE,$EF,$FF
BattTable_HW1		dc.w	$0200,$0180,$0100
BattTable_HW2		dc.w	$0200,$0100,$0000
	endif

	ifne	NEW_BATTERY_CODE
CheckBatt:
	movem.l	d1-d7/a0-a6,-(a7)
	move.w	SR,d7					; Save SR
	move.w	#$2500,SR				; Stop interrupts
	lea	$600000,a0				; Battery checker ptr
	lea	$18(a0),a1				; Battery level ptr
	lea	$70001D,a2				; HW2 Battery checker enabler

	ori.b	 #9,(a2)				; Enable Battery checker for HW2 and HW3 - does nothing on HW1
	moveq	#6,d4
\loop:		bsr.s	\reinit				; Reinit the battery checker
		move.w	d4,d1				
		lsl.w	#7,d1				; Compute the trigger level
		move.w	d1,(a1)				; Set the Trigger level
		moveq	#$6E,d1
\wait_test:		btst.b	#2,(a0)			; Wait for Hardware to stabilize
			dbeq	d1,\wait_test		
		beq.s	\quit				; Ok if set
		dbf	d4,\loop
\quit:	subq.w	#6,d4
	neg.w	d4					; Convert value
	lsr.w	#1,d4					; 7->0 to 3->0
	move.b	d4,BATT_LEVEL
	andi.b	#$F7,(a2)	
	bsr.s	\reinit					; Disable battery checker for HW2 and HW3
	andi.b	#$F6,(a2)				; Reset the trigger level to the lowest one.
	st.b	d3					; Setup max wait states
	jsr	FL_getHardwareParmBlock			; Get the Hardware Parm Block
	move.w	(a0),d1					; Read size
	cmpi.w	#$16,d1					; Gate Array field to
	bls.s	\Hw1					; see which hardware it is.
	move.l	$16(a0),d1				; Read HW_VERSION
	cmpi.w	#1,d1
	bne.s	\end
\Hw1:		move.b	BattWaitStateLevel(Pc,d4.w),d3
\end:	move.b	d3,($3-$18)(a1)				; Set new Wait States
	move.w	d4,d0					; Return value
	move.w  d7,SR
	movem.l (a7)+,d1-d7/a0-a6
        rts

\reinit:    move.w	#$380,(a1)
	    moveq	#$52,d1
\wait:			btst.b	#2,(a0)
			dbeq	d1,\wait
	    rts
BattWaitStateLevel	dc.b	$CD,$DE,$EF,$FF

	endif
	
_WaitKeyBoard:
	moveq	#$58,d0
	dbf	d0,*
	rts

; In: 
;	Nothing
; Out:
;	d4.w = Key
; Destroy:
;	All!
KeyScan:
	lea	$600018,a0
	lea	$1B-$18(a0),a1
	lea	(KEY_MASK).w,a2
	
	; Check if a Key is pressed
	clr.w	(a0)			; Read All Keys
	bsr.s	_WaitKeyBoard
	move.b	(a1),d0
	not.b	d0
	beq.s	\NoKey

	; A key is pressed. Check for it.
	; Check which key is pressed. Check for STATUS key before the others.
	clr.w	d4				; Key Row
	moveq	#KEY_NBR_ROW-1,d1
	move.w	#$FFFE,d2			; Initial Mask
\key_loop:
		move.w	d2,(a0)			; Select Row
		bsr.s	_WaitKeyBoard
		move.b	(a1),d3			; Read which Keys is pressed
		move.b	d3,d0			; add the Key Mask
		or.b	(a2),d3			; Clear Some Keys according to the mask
		not.b	d0			; UpDate the mask 
		and.b	d0,(a2)+		; Save new mask
		not.b	d3			; Negate key
		beq.s	\next			; A key has been pressed is this group of 8 keys!
			moveq	#7,d0		; Check which key is..
\bit_loop:			btst	d0,d3
				dbne	d0,\bit_loop
			move.w	d2,(KEY_CUR_ROW).w	; Memorize which key is currently pressed
			move.w	d0,(KEY_CUR_COL).w
			bset	d0,-1(a2)	; Update Mask so that this key won't be add once more
			add.w	d0,d4		; Add Col index
			add.w	d4,d4		; x2
			move.w	Translate_Key_Table(Pc,d4.w),d4
			move.w	d4,(KEY_PREVIOUS).w
			move.w	(KEY_ORG_START_CPT).w,(KEY_CPT).w	; Start Delay before repeat it
			bra.s	\end		; End of scan
\next:		rol.w	#1,d2			; Next Row
		addq.w	#8,d4			; Next row
		dbf	d1,\key_loop		

	; Auto Repeat Feature: one key is pressed, but the anti-repeat mask has disabled it.
	move.w  (KEY_PREVIOUS).w,d0
	beq.s   \none
	cmp.w	#$1000,d0			; No repeat feature for status keys
	bcc.s	\none
		; Check if the previous key is still pressed.
		move.w	(KEY_CUR_ROW).w,(a0)	; Select Row
		bsr.s	_WaitKeyBoard
		move.b	(a1),d3			; Read which Keys is pressed
		move.w	(KEY_CUR_COL).w,d0
		btst	d0,d3			; Previous Key is not pressed
		bne.s	\ResetStatutKeys
			subq.w	#1,(KEY_CPT).w	; Dec cpt.
			bne.s	\none
				move.w	(KEY_ORG_REPEAT_CPT).w,(KEY_CPT).w
				move.w	(KEY_PREVIOUS).w,d4
				ori.w	#KEY_AUTO_REPEAT,d4
				bra.s	\end
\NoKey:	
	clr.l	(a2)+		; Reset KEY_MASK
	clr.l	(a2)+
	clr.w	(a2)+
	clr.w	(KEY_PREVIOUS).w
	tst.b	(KEY_AUTO_STATUS).w
	beq.s	\none
		clr.w	(KEY_STATUS).w
		clr.b	(KEY_AUTO_STATUS).w
\none:	clr.w	d4		; Return 0 KEY code
\end:	move.w	#$380,(a0)	; Reset to standard Key Reading.
	rts
\ResetStatutKeys:
		and.b	#RESET_KEY_STATUS_MASK,(KEY_MASK).w 	; Clear Mask for status keys
		clr.w	(KEY_STATUS).w
		clr.w	(KEY_PREVIOUS).w				; No more Repeat feature
		bra	KeyScan
	
	ifd	PEDROM_92		; For TI-92+ and V200
Translate_Key_Table:
	dc.w	KEY_2ND,KEY_DIAMOND,KEY_SHIFT,KEY_HAND,KEY_LEFT,KEY_UP,KEY_RIGHT,KEY_DOWN
	dc.w	KEY_VOID,'z','s','w',KEY_F8,'1','2','3'
	dc.w	KEY_VOID,'x','d','e',KEY_F3,'4','5','6'
	dc.w	KEY_STO,'c','f','r',KEY_F7,'7','8','9'
	dc.w	' ','v','g','t',KEY_F2,'(',')',','
	dc.w	'/','b','h','y',KEY_F6,KEY_SIN,KEY_COS,KEY_TAN
	dc.w	'^','n','j','u',KEY_F1,KEY_LN,KEY_ENTER,'p'
	dc.w	'=','m','k','i',KEY_F5,KEY_CLEAR,KEY_APPS,'*'
	dc.w	KEY_BACK,KEY_THETA,'l','o','+',KEY_MODE,KEY_ESC,KEY_VOID
	dc.w	'-',KEY_ENTER,'a','q',KEY_F4,'0','.',KEY_SIGN
	endif
	ifd	PEDROM_89		; For TI-89
Translate_Key_Table:
	dc.w	KEY_UP,KEY_LEFT,KEY_DOWN,KEY_RIGHT,KEY_2ND,KEY_SHIFT,KEY_DIAMOND,KEY_ALPHA
	dc.w	KEY_ENTER,'+','-','*','/','^',KEY_CLEAR,KEY_F5
	dc.w	KEY_SIGN,'3','6','9',',','t',KEY_BACK,KEY_F4
	dc.w	'.','2','5','8',')','z',KEY_CATALOG,KEY_F3
	dc.w	'0','1','4','7','(','y',KEY_MODE,KEY_F2
	dc.w	KEY_APPS,KEY_STO,KEY_EE,KEY_OR,'=','x',KEY_HOME,KEY_F1
	dc.w	KEY_ESC,KEY_VOID,KEY_VOID,KEY_VOID,KEY_VOID,KEY_VOID,KEY_VOID,KEY_VOID	
	endif
	
; UpDate the Key buffer (FIFO Buffer)
; Must not destroy d4 
UpDateKeyBuffer:
	move.w	(KEY_CUR_POS).w,d3
	beq.s	\no_read_of_current_key		; No Key in Buffer
	tst.w	(TEST_PRESSED_FLAG).w		; Key has not been readen by apps.
	bne.s	\no_read_of_current_key
		; Move Key Buffer : remove the last Key
		clr.w	d0
		lea	(GETKEY_CODE).w,a3
		subq.w	#1,d3			; Remove a key from Buffer
		move.w	d3,(KEY_CUR_POS).w		; Save new value
		beq.s	\D			; = 0 ?
			moveq	#2,d0		; No, so a key is in the buffer
\D:		move.w	d0,(TEST_PRESSED_FLAG).w	; 2 so that OSdqueue(kbd_queue) works fine.
\loop:			move.w	2(a3),(a3)+
			dbf	d3,\loop
\no_read_of_current_key:
	rts
	
; Add a key in the keyboard FIFO buffer.
;	KEY_2ND, KEY_SHIFT, KEY_DIAMOND and KEY_ALPHA are treated in a special way.
; In:
;	In d4.w = key code (<> 0 !)
; This code MUST work :
;	tst.w	KEY_PRESSED_FLAG	; has a key been pressed?
;	beq	wait_idle
;	move.w	GETKEY_CODE,d0
;	clr.w	KEY_PRESSED_FLAG	; clear key buffer
AddKey:
	; Handle status keys.
	move.w	(KEY_STATUS).w,d3		; Read Current Status
	cmp.w	#$1000,d4		; Is it a normal key or a status key?
	bcs.s	\normal_key
		; The behavior on 89 is a little more complicated. 
		ifd	PEDROM_89
		moveq	#0,d1
		cmp.w	#KEY_ALPHA,d4
		bne.s	\NoAlphaStatKey
			; Check if KEY_MAJ is already set: if so, it disables previous behavior
			tst.b	(KEY_MAJ).w
			bne.s	\ClearKeyAndDone
\CheckExtraCombos	; Check Alpha-Alpha Combo 
			cmp.w	#KEY_ALPHA,d3
			bne.s	\NoAlphaAlphaCombo
				moveq	#2,d1
				clr.w	d4
\NoAlphaAlphaCombo	; Check Shift-Alpha Combo 
			cmp.w	#KEY_SHIFT,d3
			bne.s	\NoShiftAlphaCombo
				moveq	#1,d1
				clr.w	d4				
\NoShiftAlphaCombo:	; Check 2nd+alpha combo 
			cmp.w	#KEY_2ND,d3
			bne.s	\AlphaStatKeyDone
				moveq	#2,d1
\ClearKeyAndDone:		clr.w	d4
\AlphaStatKeyDone	move.b	d1,(KEY_MAJ).w
\NoAlphaStatKey
		endif
		cmp.w	d3,d4		; Option Key: update the status.
		bne.s	\Ok
			clr.w	d4	; Erase the status if we pressed twice the same option key.
\Ok:		move.w	d4,(KEY_STATUS).w	; Re KeyScan ?
		rts

\normal_key:
	; Check if previous key was a status
	cmpi.w	#KEY_2ND,d3		; 2nd Key
	beq.s	\2nd
	cmpi.w	#KEY_SHIFT,d3		; Shift Key
	beq	\shift	
	cmpi.w	#KEY_DIAMOND,d3		; Diamond Key
	beq.s	\diamond
	ifd	PEDROM_89
	cmpi.w	#KEY_ALPHA,d3		; Alpha Keys
	beq	\alpha	
	endif

	; Check if we have a register a special compotement:
	;  either put in UPPER case (92)
	;  either put in alpha case (89)
	;  either put in UPPER alpha case (89)
	move.b	(KEY_MAJ).w,d1		
	beq.s	\add_key
	ifd	PEDROM_89
		bsr.s	TranslateAlphaKey
		subq.b	#2,d1		; if KEY_MAJ==2, just do alpha convertion.
		beq.s	\add_key	; if KEY_MAJ==1, go to upper case too.
	endif

	; Add a UPPER case key
\MAJ:	
	cmpi.w	#'a',d4
	bcs.s	\add_key
	cmpi.w	#'z',d4
	bhi.s	\add_key
	addi.w	#'A'-'a',d4

	; Add a key to the buffer.
\add_key:
	bsr.s	AddKeyToFIFOKeyBuffer	
\end:	clr.w	(KEY_STATUS).w				; Clear status
	and.b	#RESET_KEY_STATUS_MASK,(KEY_MASK).w	; Clear status mask
	st.b	(KEY_AUTO_STATUS).w
	rts

	; Handle 2nd + KEY 
\2nd:
	ifd	PEDROM_92
	cmpi.w	#'z',d4			; 2nd + Z only alvailable on 92+/v200
	bne.s	\no_exg
		not.b	(KEY_MAJ).w		; 2nd + Z
		bra.s	\end
\no_exg	
	endif
	lea	Translate_2nd(pc),a0	; Translate 2nd Keys
\Loop2nd	move.w	(a0),d0		;  Loop convertion table
		beq.s	\extended
		addq.l	#4,a0
		cmp.w	d0,d4
		bne.s	\Loop2nd
	move.w	-(a0),d4		; Read translated key 
	bra.s	\add_key		; Add key in buffer

	; Handle DIAMOND + key 
\diamond:
	; Test '+' / '-'
	cmpi.w	#'+',d4
	bne.s	\NoContrastUp	
		jsr	OSContrastUp
		bra.s	\end
\NoContrastUp
	cmpi.w	#'-',d4
	bne.s	\3rdCont
		jsr	OSContrastDn
		bra.s	\end
\3rdCont
	ifd	PEDROM_89
	lea	Translate_3rd(pc),a0	; Translate 3rd Keys
\Loop3rd	move.w	(a0)+,d0
		beq.s	\extended
		addq.l	#2,a0
		cmp.w	d0,d4
		bne.s	\Loop3rd
	move.w	-(a0),d4
	bra.s	\add_key
	endif
\extended				; Only or KEY_STATUS and KEY
	or.w	d3,d4
	bra.s	\add_key

	; Handle SHIFT + key 
\shift:					; SHIFT called
	ifd	PEDROM_89
	jsr	TranslateAlphaKey	; Translate alpha Key
	endif
	cmpi.w	#127,d4			; Check if range Ok.
	bhi.s	\extended		; No so extended
	bra.s	\MAJ			; Go to upper case

 	ifd	PEDROM_89
\alpha	bsr.s	TranslateAlphaKey	; Translate Alpha Key
	bra.s	\add_key
	endif

		ifd	PEDROM_89
TranslateAlphaKey:
	lea	Translate_Alpha(pc),a0
\LoopAlpha	move.b	(a0)+,d0
		beq.s	\end
		addq.l	#1,a0
		cmp.b	d0,d4
		bne.s	\LoopAlpha
	clr.w	d4
	move.b	-(a0),d4
\end	rts
		endif

; In : d4.w	
AddKeyToFIFOKeyBuffer:
	move.w	(KEY_CUR_POS).w,d3				; Current position in Buffer
	cmpi.w	#KEY_MAX,d3				; Max size of buffer
	bcc.s	\overflow
		lea	(GETKEY_CODE).w,a3			; Ptr to buffer
		adda.w	d3,a3				; d3*2
		move.w	d4,0(a3,d3.w)			; Write it to buffer
		addq.w	#1,d3				; One more
		move.w	d3,(KEY_CUR_POS).w		; Save new position
		move.w	#2,(TEST_PRESSED_FLAG).w	; A key has been pressed
\overflow:
	rts
	
;	First Key is the source and then the new key
	ifd	PEDROM_92
Translate_2nd:
	dc.w	'q','?'
	dc.w	'w','!'
	dc.w	'e','é'
	dc.w	'r','@'
	dc.w	't','#'
	dc.w	'y',26
	dc.w	'u',252
	dc.w	'i',151
	dc.w	'o',212
	dc.w	'p','_'
	dc.w	'a','à'
	dc.w	's',129
	dc.w	'd',176
	dc.w	'f',159
	dc.w	'g',128
	dc.w	'h','&'
	dc.w	'j',190
	dc.w	'k','|'
	dc.w	'l','"'
	dc.w	'x',169
	dc.w	'c',199
	dc.w	'v',157
	dc.w	'b',39
	dc.w	'n',241
	dc.w	'm',';'
	dc.w	'=','\'
	dc.w	KEY_THETA,':'
	dc.w	'(','{'
	dc.w	')','}'
	dc.w	',','['
	dc.w	'/',']'
	dc.w	'^',140
	dc.w	'7',189
	dc.w	'8',188
	dc.w	'9',180
	dc.w	'*',168
	dc.w	'4',142
	dc.w	'5',KEY_MATH	;171
	dc.w	'6',KEY_MEM	;187
	dc.w	'-',KEY_VARLINK	;143
	dc.w	'1',KEY_EE	;149
	dc.w	'2',KEY_CATALOG	;130
	dc.w	'3',KEY_CUSTOM	;131
	dc.w	'+',KEY_CHAR	;132
	dc.w	'0','<'
	dc.w	'.','>'
	dc.w	KEY_SIGN,KEY_ANS	;170
	dc.w	KEY_BACK,KEY_INS
	dc.w	KEY_ENTER,KEY_ENTRY
	dc.w	KEY_APPS,KEY_SWITCH
	dc.w	KEY_ESC,KEY_QUIT
	dc.w	KEY_STO,KEY_RCL
	dc.w	' ','$'
	dc.w	0
	endif
	ifd	PEDROM_89
Translate_2nd:
	dc.w	KEY_F1,KEY_F6
	dc.w	KEY_F2,KEY_F7
	dc.w	KEY_F3,KEY_F8
	dc.w	KEY_ESC,KEY_QUIT
	dc.w	KEY_APPS,KEY_SWITCH
	dc.w	KEY_HOME,KEY_CUSTOM
	dc.w	KEY_MODE,26
	dc.w	KEY_CATALOG,151
	dc.w	KEY_BACK,KEY_INS
	dc.w	'x',KEY_LN
	dc.w	'y',KEY_SIN
	dc.w	'z',KEY_COS
	dc.w	't',KEY_TAN
	dc.w	'^',128+12
	dc.w	'=',39
	dc.w	'(','{'
	dc.w	')','}'
	dc.w	',','['
	dc.w	'/',']'
	dc.w	'|',176
	dc.w	'7',176+13
	dc.w	'8',176+12
	dc.w	'9',';'
	dc.w	'*',168
	dc.w	KEY_EE,159
	dc.w	'4',':'
	dc.w	'5',KEY_MATH
	dc.w	'6',KEY_MEM
	dc.w	'-',KEY_VARLINK
	dc.w	KEY_STO,KEY_RCL
	dc.w	'1','"'
	dc.w	'2','\'
	dc.w	'3',KEY_UNITS
	dc.w	'+',KEY_CHAR
	dc.w	'0','<'	
	dc.w	'.','>'
	dc.w	KEY_SIGN,KEY_ANS
	dc.w	KEY_ENTER,KEY_ENTRY
	dc.w	KEY_CLEAR,'$'
	dc.w	0
Translate_3rd:
	dc.w	KEY_MODE,'_'
	dc.w	KEY_CATALOG,190
	;dc.w	'x',KEY_EXP	; Pb with side cut
	dc.w	'^',KEY_THETA
	dc.w	'=',KEY_DIFERENT
	dc.w	KEY_CLEAR,'%'
	dc.w	'/','!'
	dc.w	'*','&'
	dc.w	KEY_STO,'@'
	dc.w	'0',KEY_INFEQUAL
	dc.w	'.',KEY_SUPEQUAL
	dc.w	KEY_ENTER,KEY_ENTRY
	dc.w	'(','#'
	dc.w	')',18
	dc.w	',','?'
	dc.w	'|',191
	dc.w	'7',176
	dc.w	'8',159
	dc.w	'9',169
	dc.w	'4',128
	dc.w	'5',129
	dc.w	'6',130
	dc.w	'1',131
	dc.w	'2',132
	dc.w	'3',133
	dc.w	KEY_SIGN,96
	dc.w	0
Translate_Alpha:
	dc.b	'=','a'
	dc.b	'(','b'
	dc.b	')','c'
	dc.b	',','d'
	dc.b	'/','e'
	dc.b	'|','f'
	dc.b	'7','g'
	dc.b	'8','h'
	dc.b	'9','i'
	dc.b	'*','j'
	dc.b	KEY_EE,'k'
	dc.b	'4','l'
	dc.b	'5','m'
	dc.b	'6','n'
	dc.b	'-','o'
	dc.b	KEY_STO,'p'
	dc.b	'1','q'
	dc.b	'2','r'
	dc.b	'3','s'
	dc.b	'+','u'
	dc.b	'0','v'
	dc.b	'.','w'
	dc.b	KEY_SIGN,' '
	dc.b	'x','x'
	dc.b	'y','y'
	dc.b	'z','z'
	dc.b	't','t'	
	dc.b	0
	endif
	
	EVEN
	
