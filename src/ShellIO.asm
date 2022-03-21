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
        xdef DispReturn
        xdef DispArg2Files
        xdef DispArgFileName
        xdef DispArgNumber
        xdef DispAddqReturn
        xdef Confirm
        xdef GetCursorKey
        xdef DisplayString
        xdef InputString
        xdef Completion
        xdef CompletionFolderSearch
        xdef CompletionCmp
        xdef ShellCommand
        xdef ShellCommandLoop


;******************************************************************
;***                                                            ***
;***            	Shell Input Output Interface		***
;***                                                            ***
;******************************************************************

; Display a return
DispReturn:
	pea	Return_str(pc)
	jsr	printf
	bra.s	DispAddqReturn

; Display '2 args' error
DispArg2Files:
	pea	Arg2_str(pc)
	bra.s	DispErrorPrintf

; Display 'arg: FileName' error
DispArgFileName:
	pea	Arg1_str(pc)
	bra.s	DispErrorPrintf

; Display 'Error: Argument number'
DispArgNumber:
	pea	ArgNumber_str(pc)
DispErrorPrintf
	jsr	errorPrintf
DispAddqReturn:
	addq.l	#4,a7
	rts	

; Get a key using GetKey.
; Enable the cursor during the waiting of the key.
; Destroy/Return: 
;	d0.w = Key
GetCursorKey:
	jsr	CU_start
	jsr	GetKey
	move.w	d0,-(a7)
	jsr	CU_stop
	move.w	(a7)+,d0
	rts
	

; Display 'Confirm' and input a string from he user.
; Is the string is 'yes', it returns -1 else 0
; Out: d0.b
Confirm:
	pea	Confirmation_str(pc)
	jsr	printf				; Print 'Confirmation'
	subq.l	#4,a7
	jsr	GKeyFlush			; Flush Key Buffer
	move.l	a7,a0
	moveq	#4,d3
	bsr.s	InputString
	clr.w	d0
	cmp.b	#'y',(a0)+
	bne.s	\exit
	cmp.b	#'e',(a0)+
	bne.s	\exit
	cmp.b	#'s',(a0)+
	bne.s	\exit
	tst.b	(a0)+
	seq.b	d0
\exit	addq.l	#8,a7
	rts

; Put a string on the screen
; In:
;	a0 -> String
;	d0.w = x
;	d1.w = y
;	d7.w = Offset to start in the string 
; Out :
;	nothing
; Destroy:
;	nothing
DisplayString:
	movem.l	d0-d2/a0-a1,-(a7)
	subq.l	#4,a7				; Frame 
	move.l	a7,a0				; Pointer to frame
	move.b	d0,(a0)+			; x1 = x
	move.b	d1,(a0)+			; y1 = y
	move.b	#SCR_WIDTH-1,(a0)+		; x2 = max
	move.b	CURRENT_FONT,d0
	add.b	d0,d0
	addq.b	#6,d0				; = Size of the current font = current_font*2+6
	add.b	d0,d1
	move.b	d1,(a0)				; y2 = y + size of the current font
	move.w	#A_REVERSE,-(a7)
	pea	ScrRect(pc)
	pea	-3(a0)
	jsr	ScrRectFill			; Fill with white
	lea	14(a7),a7
	movem.l (a7),d0-d2/a0-a1
	move.w	#4,-(a7)
	pea	0(a0,d7.w)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	jsr	DrawStr				; Draw string
	lea     10(a7),a7
	movem.l	(a7)+,d0-d2/a0-a1
	rts


; Input a string
; Support FunctionKey / History Command / Cursor / Completion / HelpKeys / Switching
; In :
;	d3.w = maxchar
;	a0.l -> String to fill (maxchar+1 bytes)
; Out:
;	d0.w = string lenght
; Destroy :
;	d0
InputString:
	movem.l	d1-d7/a0-a3,-(a7)
	moveq	#-1,d5				; History Index
	move.l	a0,a1				; a1 -> Current char
	clr.b	(a0)				; Null string
	clr.w	d4				; 0 character
	move.w	CURRENT_POINT_X,d6
	clr.w	d7				; Offset
	;; a1 -> Current pointed character
	;; a0 -> The string
	;; d3.w: Max number of characters in buffer
	;; d4.w: Number of characters in the string
	;; d5.w: History index
	;; d6.w: Original X position
	;; d7.W: Offset from the string
\loop:
	; If a0+d7 > a1 ==> d7=a1-a0
	move.l	a1,d0
	sub.l	a0,d0
	cmp.w	d7,d0
	bhi.s	\OffsetLowLimitOk
		move.w	d0,d7
\OffsetLowLimitOk:
	adda.w	d7,a0				; Compute a0+offset of the display
	jsr	StrWidthFromTo			; Calculate the position of the cursor from the relative position of a1 in (a0+d7)
	suba.w	d7,a0				; Fix the original string
	add.w	d6,d0				; and X position
	move.w	d0,CURRENT_POINT_X		; Update CURSOR X position
	cmpi.w	#SCR_WIDTH-8,d0			;; Cursor position must be inside the screen
	bls.s	\OffsetHighLimitOk
		addq.w	#1,d7
		bra.s	\OffsetLowLimitOk
\OffsetHighLimitOk:
	move.w	d6,d0				; X pos
	move.w	CURRENT_POINT_Y,d1		; Y pos
	bsr	DisplayString			; Display string
	bsr	GetCursorKey
	cmp.w	#KEY_ENTER,d0			;Enter ?
	beq	\Enter
	cmp.w	#KEY_CLEAR,d0			;Clear ?
	beq	\Clear
	cmp.w	#KEY_BACK,d0
	beq.s	\Del
	cmp.w	#KEY_ESC,d0			;ESC ?
	beq.s	\Esc
	cmp.w	#KEY_UP,d0			;Up ?
	beq	\Up
	cmp.w	#KEY_DOWN,d0			;Down ?
	beq	\Dn
	cmp.w	#KEY_LEFT,d0			;Left ?
	beq	\Left
	cmp.w	#KEY_RIGHT,d0			;Right ?
	beq	\Right
	cmp.w	#KEY_LEFT+KEY_2ND,d0		;2nd+Left ?
	beq	\Left2
	cmp.w	#KEY_RIGHT+KEY_2ND,d0		;2nd+Right?
	beq	\Right2
	cmp.w	#HELPKEYS_KEY,d0
	beq	\DisplayHelpKeys
	cmpi.w	#KEY_ON,d0			; Break ?
	beq	\Completion
	cmpi.w	#KEY_F1,d0			; F1-F8 ?
	blt.s	\NoFKey
		cmpi.w	#KEY_F8,d0
		ble	\FKey
\NoFKey	cmp.w	#255,d0				;Charactère invalide ?
	bhi	\CheckSwitch
	bsr.s	\AddChar
	bra	\loop

	;; Delete the character before the pointed character
\Del:	cmp.l	a0,a1
	beq	\loop
	subq.w	#1,d4
	;memmove(a1+1, a1, until a1 = zero)
	; a1 -> x y z 0 t
	subq.l	#1,a1
	move.l	a1,a2
\DelCharLoop:	move.b	1(a2),(a2)+
		bne.s	\DelCharLoop
	bra	\loop

	;; Handle ESC
\Esc:	clr.w	d4		; No char
	clr.b	(a0)		; Void string

	;; Handle RETURN
\Enter:	tst.b	(a0)		; If there is no char, don't add it in the history
	beq.s	\Rts
	; Copy the given string to the history table.
	pea	((SHELL_MAX_LINE+1)).w				; Size
	pea	(a0)						; From
	pea	(SHELL_HISTORY_TAB).w				; To 
	pea	((SHELL_HISTORY-1)*(SHELL_MAX_LINE+2)).w	; Size
	pea	(SHELL_HISTORY_TAB).w				; From
	pea	(SHELL_HISTORY_TAB+SHELL_MAX_LINE+2).w		; To 
	jsr	memmove
	lea	(4*3)(a7),a7	
	jsr	memcpy
	lea	(4*3)(a7),a7
\Rts:	jsr	DispReturn	; Disp final return
	move.w	d4,d0		; Number of Char
	movem.l (a7)+,d1-d7/a0-a3
	rts
	
; Add a char in a1
\AddChar:
	pea	(a2)
	cmp.w	d3,d4				; NbrChar < Maxchar ?
	beq.s	\MaxCharRts
	addq.w	#1,d4				; NbrChar++
	;memmove(a1, a1+1, until a1 = zero)
	; a1 -> x y z 0 t
	move.l	a1,a2
\AddCharLoop1:	tst.b	(a2)+
		bne.s	\AddCharLoop1
	; a2 -> t
	subq.l	#1,a2
\AddCharLoop2	move.b	(a2),1(a2)
		subq.l	#1,a2
		cmp.l	a1,a2
		bge.s	\AddCharLoop2
	move.b	d0,(a1)+			; Save new char
\MaxCharRts
	move.l	(a7)+,a2
	rts
	
; Function Key support (Or Fast Key ?)
\FKey:	sub.w	#KEY_F1-1,d0
	; Search for 'system\fkey[d0+1]'
	movem.l	d0-d2/a0-a1,-(a7)
	lea	-20(a7),a7		; Stack Frame
	move.w	d0,-(a7)
	pea	FKeyFormat_str(pc)
	pea	6(a7)
	jsr	sprintf_redirect	; 6(a7) = 'fkey1'
	lea	10(a7),a2
	jsr	getenv			; Get environement variable
	lea	30(a7),a7
	move.l	a0,a2
	movem.l	(a7)+,d0-d2/a0-a1
	move.l	a2,d0
	beq	\loop
	tst.b	(a2)
	beq	\loop
\FLoop		move.b	(a2)+,d0
		beq	\loop
		cmpi.b	#SHELL_AUTO_CHAR,d0
		beq	\Enter			; End of command
		jsr	\AddChar
		bra.s	\FLoop

\Left:	cmp.l	a0,a1
	beq	\loop
	subq.l	#1,a1
	bra	\loop
\Right:	tst.b	(a1)
	beq	\loop
	addq.l	#1,a1
	bra	\loop
\Left2:	cmp.l	a0,a1
	beq	\loop
	subq.l	#1,a1
	bra.s	\Left2
\Right2:
	tst.b	(a1)
	beq	\loop
	addq.l	#1,a1
	bra.s	\Right2

; Clear the entire Input Line
\Clear:
	tst.b	(a0)
	beq.s	\ClearCommand
\Clear2:
	moveq	#-1,d5			; Reset History index
	bsr.s	\Clean
	bra	\loop
\ClearCommand:
	move.l	a0,a1
	move.b	#'c',(a1)+
	move.b	#'l',(a1)+
	move.b	#'e',(a1)+
	move.b	#'a',(a1)+
	move.b	#'r',(a1)+
	clr.b	(a1)
	bra	\Enter
	
; Routine which clears the Input Line
\Clean	move.l	a0,a1			; Reset string ptr
	clr.b	(a0)
	clr.w	d4			; Reset length
	rts

; History
\Up:	cmpi.w	#SHELL_HISTORY,d5
	bge	\loop
	addq.w	#1,d5
	bra.s	\CopyHistory
\Dn:	tst.w	d5
	ble.s	\Clear2
	subq.w	#1,d5
\CopyHistory
	lea	SHELL_HISTORY_TAB,a3
	move.w	d5,d0
	mulu.w	#SHELL_MAX_LINE+2,d0
	adda.l	d0,a3					; Saved String
	tst.b	(a3)					; If no pasted string
	beq.s	\FixIndex				; Return
	bsr.s	\Clean
\PasteLoop	move.b	(a3)+,d0			; Read char
		beq.s	\Loop2				; Check if the string is finished
		jsr	\AddChar
		bra.s	\PasteLoop
\FixIndex
	subq.w	#1,d5					; Too high
\Loop2	bra	\loop

; Completion
\Completion:
	bsr.s	Completion
	bra	\loop

; Display HelpKeys
\DisplayHelpKeys
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	CURRENT_POINT_X,-(a7)
	jsr	HelpKeys
	move.l	(a7)+,CURRENT_POINT_X
	movem.l	(a7)+,d0-d7/a0-a6
	bra	\loop
	
; Switch Task
\CheckSwitch:
	movem.l	d0-d2/a0-a1,-(a7)
	lea	ShellInput_str(pc),a0
	jsr	PID_CheckSwitch
	movem.l	(a7)+,d0-d2/a0-a1
	bra	\loop

; Completion
; It is really written in 'Quick & Dirty' style.
; Not good, but nevertheless it works well...
; The chars are put inside the KeyBuffer, so there isn't any output.
; In:
;	a0 -> Start of string
;	a1 -> End of string
Completion:
	move.b	(a1),-(a7)				; Save Last Char (The buffer is in RAM)
	movem.l	d0-d7/a0-a6,-(a7)
	; Create a PopUp
	movem.l	a0/a1,-(a7)
	clr.w	-(a7)					; Auto-compute Height
	clr.l	-(a7)					; No title
	jsr	PopupNew				; New PopUp
	addq.l	#6,a7
	move.w	d0,a5					; a5 = HANDLE of Popup
	movem.l	(a7)+,a0/a1
	; Set vars
	suba.l	a6,a6					; Found Entry Ptr = NULL
	clr.b	(a1)					; Nullify the string
	clr.w	d4					; Length of the string
	clr.w	d6					; Number of successful entries

	; Search back ' ' or start of string
\loop_char	cmp.l	a0,a1				; Check if the start of the string
		ble.s	\Done
		move.b	-(a1),d0			; Read next char
		cmpi.b	#' ',d0				; If ' ', then we have a word
		beq.s	\Done1
		cmpi.b	#SCRIPT_VARIABLE_CHAR,d0	; If '$', then we have a word.		
		beq.s	\Done1
		cmpi.b	#'{',d0				; If '{', then we have a word.		
		beq.s	\Done1		
		cmpi.b	#'\',d0				; If '\', then it is a folder\file completion
		beq	\Folder
		addq.w	#1,d4				; One more char
		bra.s	\loop_char			; Next char
\Done1:	addq.l	#1,a1					; *a1 == ' ', so skip again ' '
\Done	move.l	a1,a4					; Save the word to complete in a4

	; Search for a command which starts with a1 string
	tst.w	d4					; Is there at least one char?
	beq	\EndCompletion				; No char => No completion
	; 1. Search in the folder Table
	move.w	#FOLDER_LIST_HANDLE,a0
	jsr	CompletionFolderSearch
	moveq	#'\',d7					; Final char if we found inside the Folder Table
	; 2. Search in the internal commands
	lea	BuiltinCommandTable,a2
	move.l	a2,a3
\InternalSearchLoop:
		move.w	(a2),d0				; Read offset
		beq.s	\InternalSearchLoopEnd		; Check if zero
		lea	0(a3,d0.w),a0			; String Command Name
		jsr	CompletionCmp			; Check this command
		addq.l	#4,a2				; Next entry
		bra.s	\InternalSearchLoop
\InternalSearchLoopEnd
	; 3. Search in the files in the current folder
	move.w	CUR_FOLDER_HD,a0
	jsr	CompletionFolderSearch
	; 4. Search in the files of the PATH
	jsr	PathInit
\FolderLoop:	jsr	PathNext
		move.l	a0,d0
		beq.s	\resolve
		move.l	a0,a2			; Save Path Variable
		move.w	#FOLDER_LIST_HANDLE,a0
		jsr	FindSymEntry
		move.l	a0,d0
		beq.s	\NextFolder		; Folder not found, next folder
			move.w	SYM_ENTRY.hVal(a0),a0
			jsr	CompletionFolderSearch
\NextFolder	move.l	a2,a0
		bra.s	\FolderLoop

\Folder	; 5. Find inside the given folder if any
	tst.w	d4					; Is a char ?
	beq	\EndCompletion				; No char => No completion
	; a1 -> '\'
	lea	1(a1),a4				; File Ptr
	pea	(a1)					; Save ptr
	clr.b	(a1)					; Replace '\' by 0 (It is in RAM)
\Floop		cmp.l	a0,a1				; Search for the folder name
		ble.s	\FDone
		move.b	-(a1),d0			; Read char
		cmpi.b	#SCRIPT_VARIABLE_CHAR,d0	; If '$', then we have a word.		
		beq.s	\FDone1
		cmpi.b	#'{',d0				; If '{', then we have a word.		
		beq.s	\FDone1		
		cmpi.b	#' ',d0				; Cmp
		bne.s	\Floop				; Continue
\FDone1	addq.l	#1,a1
\FDone:		
	move.w	#FOLDER_LIST_HANDLE,a0			; Find folder (a1)
	jsr	FindSymEntry				; Find entry ?
	move.l	(a7)+,a1				; Reload ptr
	move.b	#'\',(a1)				; Restore string
	move.l	a0,d0					; Check success
	beq	\EndCompletion				; No => quit
	move.w	SYM_ENTRY.hVal(a0),a0			; Folder Handle
	jsr	CompletionFolderSearch			; Complete

\resolve

	; Now we have a list of all the entries which may success
	; d6 = Number of Found Entries
	; d5 = Max Len of char to put
	; d4 = Len of entry to complete
	; a6 -> A sucessfull entry
	; d7 = Final char ' ' or '\'
	subq.w	#1,d6					; = Number of success find
	blt.s	\EndCompletion
		; Now we have at least one entry
		lea	0(a6,d4.w),a1			; Ptr to entry (Remaining char).
		move.w	d5,d1				; d5 = Number of char to put
		sub.w	d4,d1				; - Number of chars already put
		subq.w	#1,d1				; -1 for dbf
		blt.s	\DisplayMenu			; If no char can be put, display the menu
\PutKeyInBuffer:
		move.w	#$500,d0			; Stop interrupts while putting keys
		trap	#1
		jsr	UpDateKeyBuffer			; Remove unused old values (like ENTER ;) )
\PutLoop		clr.w	d4
			move.b	(a1)+,d4		; Read char
			bsr.s	\AddKeyToFIFOKeyBuffer	; Put char in Key Buffer
			dbf	d1,\PutLoop
		move.w	d7,d4				; Add final ' ' or '\' character
		beq.s	\EndPutKeyInBuffer
			bsr.s	\AddKeyToFIFOKeyBuffer	
\EndPutKeyInBuffer:
		clr.w	KEY_STATUS			; Clear status
		clr.w	d0
		trap	#1				; Restore interrupts
			
	; Free the menu and quit.
\EndCompletion
	move.w	a5,-(a7)
	jsr	HeapFree				; HeapFree(H_NULL) doesn't crash contrary to AMS.
	addq.l	#2,a7
	movem.l	(a7)+,d0-d7/a0-a6
	move.b	(a7)+,(a1)				; Restore Last Char (It is in RAM)
	rts
\AddKeyToFIFOKeyBuffer:
	jmp	AddKeyToFIFOKeyBuffer
\DisplayMenu:
	move.w	a5,d0					; Check if PopUp is created
	beq.s	\EndCompletion				; No so quit.
	clr.w	-(a7)					; Start ID
	moveq	#-1,d0		
	move.l	d0,-(a7)				; X & Y
	move.w	a5,-(a7)				; Handle
	jsr	PopupDo					; Display the menu
	addq.l	#8,a7
	tst.w	d0					; Memory Error or ESC ?
	beq.s	\EndCompletion				; => End completion
	move.w	d0,-(a7)
	move.w	a5,-(a7)
	jsr	PopupText				; Get the associated text
	addq.l	#4,a7
	move.l	a0,d0
	beq.s	\EndCompletion				; Error ? => Quit
	move.l	a0,a6
	jsr	strlen_reg				; d5.w = Length of the text
	move.w	d0,d1					; I hope it is > d4 ...
	moveq	#' ',d7					; Completion char (Error if folder.)
	lea	0(a6,d4.w),a1				; Ptr to entry (Remaining char).
	sub.w	d4,d1					; - Number of chars already put
	subq.w	#1,d1					; -1 for dbf
	blt.s	\EndCompletion
	bra.s	\PutKeyInBuffer
	
; Search in the given folder 
;	a0= FOLDER HANDLE
CompletionFolderSearch:
	trap	#3
	addq.w	#2,a0				; Skip Max
	move.w	(a0)+,d3			; Number of folders (at least one !)
	subq.w	#1,d3
	blt.s	\EndFolder
\Loop		bsr.s	CompletionCmp		; Compare and add to buffer
		lea	SYM_ENTRY.sizeof(a0),a0	; Next entry
		dbf	d3,\Loop	
\EndFolder
	rts
			
CompletionCmp:
	pea	(a0)
	move.l	a4,a1				; String Source
	move.w	d4,d2				; Length
	subq.w	#1,d2				; -1 for dbf
\IntCmp		cmpm.b	(a1)+,(a0)+		; Compare 
		dbne	d2,\IntCmp		; and decrement
	bne.s	\Ret
		; Add this string to the list of the possible completion
		move.l	a6,d2
		beq.s	\FirstEntry
			; Find the max length of all the possible commands 
			; so that we put as mush char as possible
			move.l	a6,a1		; Old string
			move.l	(a7),a0		; New string
			moveq	#-1,d0		; Length
			\StrCmp:	addq.w	#1,d0
					tst.b	(a1)
					beq.s	\StrDone
					cmpm.b	(a1)+,(a0)+	; Compare 
					beq.s	\StrCmp		; 
			\StrDone:
				clr.w	d7		; No final char!
				cmp.w	d0,d5		; Get the min between d5 and d0
				ble.s	\NewEntry
					move.w	d0,d5
					bra.s	\NewEntry
\FirstEntry	; First entry of the list: the number of char 
		; to put is the length of the string.
		jsr	strlen
		move.w	d0,d5			; Length of command
		move.l	(a7),a6			; Save found command
		moveq	#' ',d7			; d7 = Final Char
\NewEntry	addq.w	#1,d6
		; Add this entry in the Popup
		move.w	a5,d0			; Check if PopUp is created
		beq.s	\Ret			; no so quit
			clr.w	-(a7)		; No parent
			move.l	2(a7),-(a7)	; Push Text Ptr
			clr.w	-(a7)		; Auto-Id
			move.w	a5,-(a7)	; Push Handle
			jsr	PopupAddText	; Add Text in PopUp
			lea	10(a7),a7	; FIXME: Check success ?
\Ret	move.l	(a7)+,a0
	rts


;; **********************************************************
;; Main Loop of the SHELL interface
;; **********************************************************
ShellCommand:
	; Display first line
	move.b	#USED_FONT,CURRENT_FONT		; Set current font
	jsr	clrscr				; Clear Screen
	pea	Pedrom_str(pc)
	jsr	printf				; Print 'PedroM'
	pea	Author_str(pc)	
	jsr	printf				; Printf '(c) PpHd'
	jsr	DispReturn
	jsr	PID_Init			; Set the Process Number of this Shell Command

	; Run 'start' script?
	tst.b	RUN_START_SCRIPT
	beq.s	\NoRun
		pea	StartScript_sym(pc)
		jsr	SymFindPtr			; Search file 'start'
		addq.l	#4,a7
		move.l	a0,d0
		beq.s	\NoRun
		move.w	SYM_ENTRY.hVal(a0),d1
		beq.s	\NoRun
			jsr	push_END_TAG		; Must call push_END_TAG (Bad conception :(
			move.w	d1,d0			; Doesn't delete d1
			jsr	ScriptExec
\NoRun:	; Alloc Input Buffer
	lea	(14-SHELL_MAX_LINE-6)(a7),a7

ShellCommandLoop:	
	; Check Pen position
	move.w	SHELL_SAVE_Y_POS,d0		; The window modify the vertical position of the pen.
	cmp.w	CURRENT_POINT_Y,d0		; So we check if the current position is > than the previous.
	ble.s	\Continue			; By the way, clearscreen resets the previous value too.
		move.w	d0,CURRENT_POINT_Y	; If not, we set the current value to the previous saved one.
\Continue
	btst.b	#5,DeskTopWindow+WINDOW.Flags	; Check if an application has set the Dirty flag of the main window.
	bne.s	\ClrScr				; if so, clear the screen.
	cmpi.w	#SCR_HEIGHT-8,CURRENT_POINT_Y	; If the pen is outside the screen
	ble.s	\Continue2
\ClrScr		jsr	clrscr			; We clear the screen.
\Continue2		
	clr.w	(a7)
	jsr	ST_busy				; Idle mode
	jsr	ReInitGraphSystem		; Restore the normal way of rendering
	lea	FONT_str,a2			; Check if a FONT environnement file exists
	move.w	#0,d1				; Min 
	move.w	#2,d2				; Max
	move.w	#USED_FONT,d3			; Default
	jsr	getenv_si			; Translate font
	move.b	d0,CURRENT_FONT			; Set font
	jsr	InstallVectors			; Reinstall vectors (Bug ?)
	jsr	GKeyFlush			; Clear key buffer
	st.b	SHELL_NG_DISPLAY		; Display the result of ng_execute
	move.l	a7,a4				; Input Buffer
	clr.b	(a4)+				; First byte must be 0

	; Ask command to the user.
\WhileInput	pea	Shell_str(pc)
		jsr	printf			; Display ':>'
		addq.l	#4,a7
		move.l	a4,a0			; Input Buffer 
		moveq	#SHELL_MAX_LINE,d3	; Length of Buffer	
		jsr	InputString		; Input the string inside the buffer
		tst.b	(a4)			; Check if something is in the buffer?
		beq.s	\WhileInput		; No => continue the input

	lea	-60(a7),a7			; Error Stack Frame
	pea	(a7)				; Push Stack Frame
	jsr	ER_catch			; Catch all errors.
	tst.w	d0
	bne.s	\Error
		jsr	ShellExecuteCommand	; Translate and execute the Command
		jsr	ER_success
		bra.s	\Cont
\Error	jsr	find_error_message_reg
	pea	(a0)
	pea	CommandNotFound_str(pc)
	jsr	printf
	addq.l	#8,a7
\Cont	lea	64(a7),a7
	bra	ShellCommandLoop

