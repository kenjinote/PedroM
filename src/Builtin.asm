;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003-2009 Patrick Pelissier
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
        xdef BuiltinCommandTable

;******************************************************************
;***                                                            ***
;***            	Shell BuiltIn commands			***
;***                                                            ***
;******************************************************************

ADD_COMMAND	MACRO
	dc.w	\1_str-BuiltinCommandTable,\1_cmd-BuiltinCommandTable
		ENDM

BuiltinCommandTable:
	ADD_COMMAND	Arc
	ADD_COMMAND	Cat
	ADD_COMMAND	Cd
	ADD_COMMAND	Clean
	ADD_COMMAND	Cls
	ADD_COMMAND	Cp
	ADD_COMMAND	Echo
	ADD_COMMAND	Exit
	ADD_COMMAND	Flags
	ADD_COMMAND	Get
	ADD_COMMAND	Grep
	ADD_COMMAND	Help
	ADD_COMMAND	HexDump
	ADD_COMMAND	InstallFormat
	ADD_COMMAND	InstallProductCode
	ADD_COMMAND	InstallTIB
	ADD_COMMAND	Kill
	ADD_COMMAND	Ls
	ADD_COMMAND	Mem
	ADD_COMMAND	Menu
	ADD_COMMAND	MkDir
	ADD_COMMAND	More
	ADD_COMMAND	Mv
	ADD_COMMAND	Ps
	ADD_COMMAND	Read
	ADD_COMMAND	Reset
	ADD_COMMAND	RmArc
	ADD_COMMAND	RmDir
	ADD_COMMAND	Rm
	ADD_COMMAND	SendCalc
	ADD_COMMAND	Side
	ADD_COMMAND	UnArc
	ADD_COMMAND	UnPPG
	ifd	USE_MAIN_PROGRAM
	ADD_COMMAND	Zs
	endif
	dc.w	0

; ************************************
; ******	COMMANDS !	******
; ************************************

	;; Format the archive section : Erase everything in archive
	;; No argument
InstallFormat_cmd:
	jsr	Confirm
	tst.w	d0
	beq.s	DoRet
	FLASH_FUNC_ON				; Allow use of FlashErase
	lea	START_ARCHIVE+1000,a2
\Loop:		jsr	FlashErase
		adda.l	#$10000,a2		; Next Sector
		cmp.l	#END_ARCHIVE,a2
		bls.s	\Loop
DoReset	trap	#2

	
	;; RESET the calculator
	;; No argument.
Reset_cmd:
	jsr	Confirm
	tst.w	d0
	bne.s	DoReset
DoRet	rts

	
	;; Install a new OS using the builtin receiver code.
	;; No argument
InstallTIB_cmd:
	jsr	Confirm
	tst.w	d0
	bne	TIB_Install
	rts

	
	;; Install a new OS using the boot code
	;; No argument
InstallProductCode_cmd
	jsr	Confirm
	tst.w	d0
	bne	FL_download
	rts


	;; List the files of the current directory
	;; Argument:
	;;  -h: List the pseudo Home directory
	;;  -l: Long format
Ls_cmd:
	move.l	a6,-(a7)
	move.l	a7,a6
	; Translate args
	lea	CommandDisp_str(pc),a2
	cmpi.w	#2,ARGC
	blt.s	\Std
		move.l	ARGV+4,a0
		cmpi.b	#'-',(a0)+
		bne.s	\Std
		cmpi.b	#'h',(a0)
		beq	\Folders
		cmpi.b	#'l',(a0)
		bne.s	\Std
		lea	LsLong2_str(pc),a2
		pea	LsLong1_str(pc)
		jsr	printf
\Std:	; Display Intro String
	pea	CUR_FOLDER_STR
	pea	Dir1_str(pc)
	jsr	printf
	move.w	#1,(a7)
	clr.b	NULL_CHAR
	; Start Displaying the files
	lea	CUR_FOLDER_STR,a0
\cvt		tst.b	(a0)+
		bne.s	\cvt
	pea	-1(a0)
	jsr	SymFindFirst
	moveq	#0,d3
\loop		move.l	a0,d0
		beq.s	\end
		addq.w	#1,d3		; One more file
		move.l	a0,a3		; Save SYM_ENTRY
		move.w	SYM_ENTRY.hVal(a0),d0
		bne.s	\NoHNull
			clr.l	-(a7)	; No Ptr
			clr.w	-(a7)	; No type
			clr.w	-(a7)	; No flags
			clr.w	-(a7)	; No size
			bra.s	\Cont
\NoHNull	move.w	d0,a0
		trap	#3		; Deref file
		pea	(a0)		; Push File Ptr
		moveq	#0,d2		
		move.w	(a0)+,d2	; Read size
		clr.w	d0		
		move.b	-1(a0,d2.l),d0	; Read type
		move.w	d0,-(a7)	; and push it
		move.w	SYM_ENTRY.flags(a3),-(a7)	; Push Flags
		move.w	d2,-(a7)	; Püsh Size
\Cont		pea	(a3)		; Push Name
		pea	(a2)		; Push Format string
		jsr	printf		; Print it
		lea	18(a7),a7	; Pop args
		jsr	SymFindNext
		bra.s	\loop
\end:	move.w	d3,(a7)
	pea	Dir2_str(pc)
	jsr	printf
	move.l	a6,a7
	move.l	(a7)+,a6
	rts

\Folders
	pea	Home_str(pc)
	pea	Dir1_str(pc)
	jsr	printf
	clr.w	-(a7)
	clr.l	-(a7)
	jsr	SymFindFirst
	moveq	#0,d3
\loop2		move.l	a0,d0
		beq.s	\end
		addq.w	#1,d3		; One more file
		pea	(a0)		; Push Name
		pea	CommandDisp_str(pc)		; Push Format string
		jsr	printf		; Print it
		addq.l	#8,a7		; Pop args
		jsr	SymFindNext
		bra.s	\loop2


	;; Display the available builtin commands
	;; No argument
Help_cmd:
	lea	BuiltinCommandTable(Pc),a2
\loop		move.w	(a2),d0
		beq.s	\end
		lea	BuiltinCommandTable(Pc),a0
		pea	0(a0,d0.w)
		pea	CommandDisp_str(pc)
		jsr	printf
		addq.l	#8,a7
		addq.l	#4,a2
		bra.s	\loop
\end	bra	DispReturn


	;; Display the memory usage
	;; No argument
Mem_cmd:
	jsr	HeapCompress	; Compress the Heap
	subq.l	#8,a7
	clr.l	-(a7)		; all Execpt Base code
	clr.l	-(a7)		; bad sectors
	clr.l	-(a7)		; unused sectors
	pea	16(a7)		; Free
	pea	16(a7)		; FreeAfter GC
	clr.l	-(a7)		; InUse
	jsr	EM_survey
	lea	24(a7),a7
	move.l	(a7)+,d0
	add.l	d0,(a7)		; Free + FreeAfterGc
	jsr	HeapAvail
	move.l	d0,-(a7)
	pea	MemDisplay_str(pc)
	jsr	printf
	lea	12(a7),a7
	rts


	;; Clear the screen
	;; No argument
Cls_cmd:
	jmp	clrscr		; May be > 32K ?


	;; Change the current directory
	;; Argument:
	;;  directory name
	;; If no argument, assume the directory is 'main'
Cd_cmd:	lea	FolderCur(pc),a0
	cmpi.w	#2,ARGC
	blt.s	\Main
	move.l	ARGV+4,a1		; First Arg ptr
\Loop		move.b	(a1)+,d0	; Loop to delete last '\'
		beq.s	\Done		; in cd main\ for example.
		cmpi.b	#'\',d0
		bne.s	\Loop
	clr.b	-(a1)			;  Previous char was a '\'
\Done	bra.s	CommunOneFile	
\Main	move.l	#Main_str,ARGV+4
	move.w	#2,ARGC
	bra.s	CommunOneFile	
	
	;; Remove a file in the archive section
	;; Argument:
	;;  file
RmArc_cmd:
	lea	EM_delSym(pc),a0
	bra.s	CommunOneFile
Get_cmd:
	lea	cmd_getcalc(pc),a0
	bra.s	CommunOneFile
SendCalc_cmd:
	lea	cmd_sendcalc(pc),a0
	bra.s	CommunOneFile
UnArc_cmd:
	lea	EM_moveSymFromExtMem(pc),a0
	bra.s	CommunOneFile
Rm_cmd:	lea	SymDel(pc),a0
	bra.s	CommunOneFile
MkDir_cmd:
	lea	FolderAdd(pc),a0
	bra.s	CommunOneFile
RmDir_cmd:
	lea	FolderDel(pc),a0
	bra.s	CommunOneFile
Arc_cmd:
	lea	EM_moveSymToExtMem(pc),a0

	;; Handle command with one arg is a SYM_ENTRY
CommunOneFile:
	cmpi.w	#2,ARGC
	blt	DispArgFileName
	lea	-100(a7),a7
	move.l	a7,a3			; Buffer
	move.l	a0,a2			; Function
\Loop		move.w	ARGC,d0		; ARGC is the loop counter
		subq.w	#1,d0
		beq.s	\Done		; last one is done
		move.w	d0,ARGC
		lsl.w	#2,d0		; Last argument
		lea	ARGV,a1
		move.l	0(a1,d0.w),a1	; Arg ptr
		move.l	a3,a0
		clr.b	(a0)+		; Convert Arg to Ti format
\cvt:			move.b	(a1)+,(a0)+
			bne.s	\cvt		
		clr.l	-(a7)
		pea	-1(a0)
		jsr	(a2)		; Call the function
		addq.l	#8,a7
		tst.w	d0
		bne.s	\Success
			pea	1(a3)
			pea	Failed_str(pc)
			jsr	errorPrintf
			addq.l	#8,a7
\Success	bra.s	\Loop
\Done	lea	100(a7),a7
	rts


	;; Clean the system.
	;; No argument
Clean_cmd:
	movem.l	d3-d7/a2-a6,-(a7)
	jsr	PID_clean		; Erase all the background process
	jsr	kernel__clean_up	; Clean the kernel files (Before the heap)/ Warning it may change the vector tables (Ex: GrayOn).
	jsr	KernelReinit		; Reinit the Kernel 
	jsr	CleanTwinFiles		; Clean the remaining twin files
	jsr	InstallVectors		; Reinstall the vectors
	jsr	EStackReInit		; Reset the EStack
	; Unlock all the files
	move.w	#2,-(a7)
	clr.l	-(a7)
	jsr	SymFindFirst		; Find all the vars
\loop3		move.w	SYM_ENTRY.hVal(a0),(a7)
		andi.w	#~SF_INVIEW,SYM_ENTRY.flags(a0)
		jsr	HeapUnlock
		jsr	SymFindNext
		move.l	a0,d0
		bne.s	\loop3
	; Erase unreferenced Handles
	lea	HEAP_TABLE+4,a2			; HEAP TABLE (We skip the first one)
	move.w	#HANDLE_MAX-2,d5		; d5 = number of handles - 1 - 1
	moveq	#1,d3				; d3 = handle number = 1
	moveq	#0,d4				; Erased Handle count
\loop2		tst.l	(a2)+
		beq.s	\NextHandle
		move.w	d3,d0			; d0.w = HANDLE #
		cmpi.w	#FOLDER_LIST_HANDLE,d0	; Do not delete Home directory!
		beq.s	\NextHandle
		cmpi.w	#ESTACK_HANDLE,d0	; Do not delete EStack!
		beq.s	\NextHandle
		cmp.w	LibTableHd,d0
		beq.s	\NextHandle
		jsr	kernel__Hd2Sym		; Check if handle is in VAT
		move.l	a0,d0			; Test if Null
		bne.s	\NextHandle
			addq.w	#1,d4		; One more Handle Erased
			move.w	d3,(a7)		; No ref to this handle: erase it.
			jsr	HeapFree
\NextHandle:	addq.w	#1,d3			; increase handle number
		dbf	d5,\loop2		; Next Handle
	jsr	HeapCheck			; Check the heap and 
	jsr	HeapCompress			; Compress it
	move.w	d4,(a7)
	beq.s	\Ret				; Display # of freed handles if any
		pea	CleanFreeHandle_str(pc)
		jsr	printf
		addq.l	#4,a7
\Ret	addq.l	#6,a7				; Pop the stack
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
Mv_cmd:
	cmpi.w	#3,ARGC
	bne	DispArg2Files
	; Convert to Ti format (FIXME: Buggy if use of wildcards)
	move.l	ARGV+4,a0		; SrcFileName
\cvt1		tst.b	(a0)+
		bne.s	\cvt1
	move.l	ARGV+8,a1		; Dest File Name
\cvt2		tst.b	(a1)+
		bne.s	\cvt2
	pea	-1(a1)			; Dest File Name
	pea	-1(a0)			; Src File Name
	jsr	SymMove
	addq.l	#8,a7
	tst.w	d0
	bne.s	\Ok2
		pea	ST_StrA(pc)
		pea	Failed_str(pc)
		jsr	errorPrintf
		addq.l	#8,a7
\Ok2:	rts
	
Cp_cmd:
	cmpi.w	#3,ARGC
	bne	DispArg2Files
	; Convert to Ti format
	subq.l	#6,a7			; Stack Frame
	move.l	ARGV+4,a0		; SrcFileName
	jsr	ASymFindPtr
	move.l	a0,d0
	beq.s	\Fail
		move.w	SYM_ENTRY.hVal(a0),(a7)	; Push Handle
		move.w	(a7),a0
		trap	#3
		moveq	#0,d0
		move.w	(a0),d0			; Read file size
		addq.w	#3,d0			; + 3
		jsr	HeapAlloc_reg
		tst.w	d0
		beq.s	\Fail
			move.w	(a7),a0		; Reload Handle
			trap	#3
			move.w	(a0),d1		; Reload Size
			addq.w	#3,d1
			move.l	a0,a1		; Src = a1
			move.w	d0,(a7)		; Save Handle
			move.w	d0,a0		; Dest 
			trap	#3		; a0 = dest
\CpyLoop			move.b	(a1)+,(a0)+
				subq.w	#1,d1
				bne.s	\CpyLoop	
			move.l	ARGV+8,a0	; Dest File Name
			jsr	ASymAdd		; Add file in VAT
			tst.l	d0
			beq.s	\Fail2
				jsr	DerefSym_Reg
				move.w	(a7),SYM_ENTRY.hVal(a0)
				bra.s	\Ok2
\Fail2			jsr	HeapFree
\Fail	pea	ST_StrA(pc)
	pea	Failed_str(pc)
	jsr	errorPrintf
	addq.l	#8,a7
\Ok2:	addq.l	#6,a7
	rts

Side_cmd:
	moveq	#0,d0
	cmpi.w	#1,ARGC
	beq.s	\Go
		move.l	ARGV+4,d0
\Go	move.l	d0,filename
	jsr	run_side
	jmp	clrscr
	
Echo_cmd:
	move.w	ARGC,d3
	subq.w	#2,d3
	blt.s	\No
		lea	ARGV+4,a2
\Cont:		move.l	(a2)+,-(a7)
		pea	String_str(pc)
		jsr	printf
		addq.l	#8,a7
		subq.w	#1,d3
		blt	DispReturn
		bsr.s	\PushSpace
		dc.b	' ',0
\PushSpace	jsr	printf
		addq.l	#4,a7
		bra.s	\Cont
\No	rts
	
UnPPG_cmd:
	cmpi.w	#3,ARGC
	bne	DispArg2Files
	; Find Src Name
	move.l	ARGV+4,a0		; SrcFileName
	jsr	ASymFindPtr
	move.l	a0,d0
	bne.s	\Ok2
\Fail		move.l	ARGV+4,-(a7)
		pea	Failed_str(pc)
		jsr	errorPrintf
		addq.l	#4,a7
		bra.s	\done
\Ok2:	; Extract PPG
	move.w	SYM_ENTRY.hVal(a0),d4	; Source Handle
	jsr	ExtractPPG		; Extract PPG
	move.w	d0,d4
	beq.s	\Fail			; FIXME: Unlocked it !
	; Add new file
	move.l	ARGV+8,a0		; DestFileName
	jsr	ASymAdd
	jsr	DerefSym_Reg
	move.l	a0,d0
	bne.s	\Ok4
		move.w	d4,d0
		jsr	HeapFree_reg
		bra.s	\Fail
\Ok4	move.w	d4,SYM_ENTRY.hVal(a0)
\done:	rts

Read_cmd:
	cmpi.w	#2,ARGC				; Check Arg
	blt	DispArgFileName
	movem.l	d3-d7/a2-a6,-(a7)
	lea	(-4*ARG_MAX)(a7),a7		; Copy VARIABLE ARGS
	move.l	a7,a3
	move.l	a3,a1
	lea	ARGV+4,a0
	moveq	#ARG_MAX-2,d0
\CopyArg	move.l	(a0)+,(a1)+
		dbf	d0,\CopyArg
	lea	(-SHELL_MAX_LINE-6)(a7),a7
	move.l	a7,a4
	clr.b	(a4)+				; Clear first byte (<= Translate Arg)
	move.w	ARGC,d5				; Number of variable to read
	subq.w	#1,d5				; -1
\VarLoop
	; Input a string
\Input		move.l	a4,a0
		moveq	#SHELL_MAX_LINE,d0
		lea	stdin,a1
		jsr	fgets
		move.l	a0,d0			; End of input?
		beq.s	\End
		tst.b	(a4)
		beq.s	\Input	
	; Delete final char if it is \n
\StrLoop	tst.b	(a0)+
		bne.s	\StrLoop
	cmpi.b	#10,-2(a0)
	bne.s	\SkipTranslateChar
		clr.b	-2(a0)
\SkipTranslateChar
	; Translate it
	jsr	TranslateArgs
	; Save the vars
	move.w	ARGC,d4
	lea	ARGV,a2
\VarSaveLoop		jsr	EStackReInit	; Reset EStack
			move.l	(a2)+,-(a7)
			jsr	push_zstr	; Push STRING
			move.l	top_estack,(a7)
			clr.w	-(a7)		; Size is useless
			move.w	#STOF_ESI,-(a7)
			move.l	(a3)+,a0	; Read VAR Name . Should be 0,NAME,0 where ptr is N
			\Cvt:	tst.b	(a0)+
				bne.s	\Cvt
			pea	-1(a0)
			jsr	VarStore
			lea	12(a7),a7
			subq.w	#1,d5
			beq.s	\End
			subq.w	#1,d4
			bne.s	\VarSaveLoop
	bra.s	\VarLoop
\End	lea	(SHELL_MAX_LINE+6+4*ARG_MAX)(a7),a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
Ps_cmd:
	move.w	CURRENT_PROCESS,-(a7)
	pea	PID_status(pc)
	jsr	printf
	addq.l	#6,a7
	lea	PROCESS_TABLE,a2
	moveq	#MAX_PROCESS-1,d3
	clr.w	d4
\loop		move.w	(a2)+,d0
		beq.s	\next
		move.w	d0,a0
		trap	#3
		pea	8(a0)		; Push String Name
		move.l	(a0),-(a7)	; Push Stack Size
		move.w	d4,-(a7)
		pea	PID_string(pc)
		jsr	printf
		lea	14(a7),a7
\next		addq.w	#1,d4
		dbf	d3,\loop
	rts	

; kill pid
Kill_cmd:
	cmp.w	#2,ARGC
	blt	DispArgNumber
	move.l	ARGV+4,a0		; Number
	jsr	atol		; Get number
	; Check Pid
	jsr	PID_Check
	tst.w	d1
	ble.s	\Fail
	; TODO: Call Kill function.
	; Free Process
	move.w	(a2),d0
	clr.w	(a2)
	jsr	HeapFree_reg
\Fail	rts

; exit pid
Exit_cmd:
	move.w	PREVIOUS_PROCESS,d2		; Load Previous Process if needed
	cmpi.w	#1,ARGC
	beq.s	\Continue
		move.l	ARGV+4,a0		; Number
		jsr	atol		; Get number
\Continue
	jmp	PID_Go

	;;  Flags command
Flags_cmd:
	lea	FlagsTable(pc),a2
	cmpi.w	#2,ARGC
	blt	\DispFlagsValue
\Loop	subq.w	#1,ARGC
	beq.s	\Done		; last one is done
		move.w	ARGC,d0
		lsl.w	#2,d0		; Last argument
		lea	ARGV,a1
		move.l	0(a1,d0.w),a3	; Arg ptr
		move.w	#'=',-(a7)
		pea	(a3)
		jsr	strchr		; Find '='
		addq.l	#6,a7
		move.l	a0,d0
		beq.s	\Loop		; Not found, skip
			clr.b	(a0)+
			cmpi.b	#'1',(a0)
			seq.b	d3
			moveq	#-1,d2			; Bit Flag
			\TableLoop:
			move.w	(a2)+,d0
			beq.s	\Loop
				addq.w	#1,d2		; Next Bit
				lea	0(a2,d0.w),a0	; Next Name
				move.l	a3,a1		; Arg
				jsr	strcmp_reg
				tst.w	d0
				bne.s	\TableLoop
			bclr.b	d2,SHELL_FLAGS
			tst.b	d3
			beq.s	\Loop
				bset.b	d2,SHELL_FLAGS
				bra.s	\Loop
\Done	rts
\DispFlagsValue
	moveq	#-1,d3
\DisplayLoop	
	move.w	(a2)+,d0
	beq.s	\Done
		addq.w	#1,d3
		pea	ON_str(pc)
		btst.b	d3,SHELL_FLAGS
		bne.s	\Go
			addq.l	#3,(a7)
\Go		pea	0(a2,d0.w)
		pea	FlagsDisplay_str(pc)
		jsr	printf
		lea	12(a7),a7
		bra.s	\DisplayLoop

FlagsTable:	dc.w	AutoArchive_str-*-2
		dc.w	OffSwitch_str-*-2
		dc.w	GetKeySwitch_str-*-2
		dc.w	StatusError_str-*-2		
		dc.w	0

More_cmd:
	move.l	ARGV+4,a0
	cmpi.w	#1,ARGC
	beq.s	\Check
		lea	stdin,a2
		lea	ReadModeStr,a1
		jsr	freopen
\Check
	btst.b	#0,stdin
	bne.s	\Done
	clr.w	PRINTF_LINE_COUNTER
\Loop		pea	stdin
		bsr.s	LocalFgetc
		addq.l	#4,a7
		tst.w	d0
		blt.s	\Done
		bsr.s	\PutChar
		bra.s	\Loop
\Done	moveq	#10,d0
\PutChar
	pea	stdout
	move.w	d0,-(a7)
	bsr.s	LocalFputc
	addq.l	#6,a7
	rts

LocalFgetc	jmp	fgetc
LocalFputc	jmp	fputc
	
Cat_cmd:
	cmpi.w #1,ARGC
	ble.s \stdin
	lea  ARGV+4,a2
\LoopFilename:
	lea	ReadModeStr,a1
	move.l	(a2)+,a0
	cmpi.b	#'-',(a0)
	bne.s	\fopen
\stdin:
		lea	stdin,a0
		btst.b	#0,(a0)
		bne.s	\Return
		bra.s	\opened
\fopen:
	jsr	fopen
	move.l	a0,d0
	beq.s	\Return
\opened	pea	(a0)
\loop
		bsr.s	LocalFgetc
		tst.w	d0
		blt.s	\end
		pea	stdout
		move.w	d0,-(a7)
		jsr	LocalFputc
		addq.l	#6,a7
		bra.s	\loop
\end:	move.l	(a7)+,a0
	jsr	fclose
	subq.w	#1,ARGC
	bgt.s	\LoopFilename
\Return:
	rts

Grep_cmd:
	; argv[1] = seed
	subq.w	#2,ARGC				; File counter
	blt	\Return
	bgt.s	\OkFilename
		; Check if stdin is redirected
		btst.b	#0,stdin
		bne	\Return			; stdin is not terminal ?
		lea	\stdin_str+4(pc),a2	; stdin indirect name
		move.w	stdin+2,a0		; stdin Handle
		bra.s	\HandleEntry		; Deref it
\stdin_str	dc.l	Stdin_str
\OkFilename:
	lea	ARGV+8,a2			; Name indirect ptr
\LoopFile
		move.l	(a2)+,a0		; Read file name
		jsr	ASymFindPtr		; Find it
		move.l	a0,d0			; Not found ?
		beq.s	\NextFile
		move.w	SYM_ENTRY.hVal(a0),a0
\HandleEntry
		trap	#3
		moveq	#0,d0
		move.w	(a0)+,d0
		cmpi.b	#$E0,-1(a0,d0.l)
		bne.s	\NextFile	; Not a text file ?
			addq.l	#3,a0
			move.l	a0,a3
\Loop
				move.l	ARGV+4,-(a7)	; Push seed
				pea	(a0)		; Push text ptr
				jsr	strstr		; Search for it
				addq.l	#8,a7
				move.l	a0,d0		; Yes?
				beq.s	\NextFile	; No, so next file
				; An occurence found!
				; Find the beginning of the line
\BeginLine				cmp.l	a0,a3
					bge.s	\FoundBeginLine
					cmpi.b	#LINE_FEED,-(a0)
					bne.s	\BeginLine
				addq.l	#2,a0
\FoundBeginLine:
				pea 	(a0)			; Push string
				; Calculate string length
\LineLoop				move.b	(a0)+,d0			
					beq.s	\LineLoopEnd
					cmpi.b	#LINE_FEED,d0
					bne.s	\LineLoop
\LineLoopEnd			
				move.l	a0,d3
				sub.l	(a7),a0
				subq.w	#1,a0
				move.w	a0,-(a7)		; Push string precision
				move.l	-4(a2),-(a7)		; Push file name
				bsr.s	\printf
					dc.b	"%s: %.*s",10,0
\printf				jsr	printf
				lea	14(a7),a7
				move.l	d3,a0
				tst.b	(a0)
				bne.s	\Loop
\NextFile		
		subq.w #1,ARGC
		bge.s \LoopFile 
\Return:
	rts

HexDump_cmd:
	cmpi.w	#2,ARGC
	bne	DispArgNumber
	movem.l	d3/a3,-(a7)
	move.l	ARGV+4,a0		; Number
	jsr	atol		; Get number
	move.l	d0,a3
	moveq	#8-1,d3
\loop2		moveq	#8-1,d1
		addq.l	#8,a3
\loop			clr.w	d0
			move.b	-(a3),d0
			move.w	d0,-(a7)
			dbf	d1,\loop
		pea	(a3)
		addq.l	#8,a3
		pea	HexFormat_str(pc)
		jsr	printf
		lea	(8*2+4+4)(a7),a7	
		dbf	d3,\loop2
	movem.l	(a7)+,d3/a3
	rts

Menu_cmd:
	move.w	ARGC,d3
	cmpi.w	#2,d3
	blt	DispReturn
	lea	ARGV+4,a3
	move.l	a7,a6
	;; Create a new menu
	clr.w	-(a7)
	clr.l	-(a7)
	jsr	PopupNew
	move.w	d0,d4
	beq	\MenuError
	;; Add texts
	moveq	#1,d5
\MenuLoopAddText:
		move.w	d5,-(a7)
		move.l	(a3)+,-(a7)
		clr.w	-(a7)
		move.w	d4,-(a7)
		jsr	PopupAddText
		tst.w	d0
		beq.s	\MenuError
		addq.w	#1,d5
		cmp.w	d3,d5
		bne.s	\MenuLoopAddText
	;; Performs loop
	clr.w	-(a7)
	move.l	#-1,-(a7)	;center
	move.w	d4,-(a7)
	jsr	PopupDo
	tst.w	d0
	beq.s	\MenuError
	;; Print the selection
	lsl.w	#2,d0
	lea	ARGV,a0
	adda.w	d0,a0
	move.l	(a0),-(a7)
	pea	String_str(pc)
	jsr	printf
\MenuError:
	move.w	d4,-(a7)
	jsr	HeapFree	; Contrary to AMS, PedroM checks for 0 before freing
	move.l	a6,a7
	bra	DispReturn

	
	ifd	USE_MAIN_PROGRAM
Zs_cmd	jmp	Zs_function_call
	endif
	
HexDump_str		dc.b	"hexdump",0
Grep_str		dc.b	"grep",0
Cat_str			dc.b	"cat",0
More_str		dc.b	"more",0
Flags_str		dc.b	"flags",0
InstallFormat_str	dc.b	"install format",0	
Ps_str			dc.b	"ps",0
Exit_str		dc.b	"exit",0
Kill_str		dc.b	"kill",0
Read_str		dc.b	"read",0
InstallTIB_str		dc.b	"install tib",0
UnPPG_str		dc.b	"unppg",0
Echo_str		dc.b	"echo",0
Side_str		dc.b	"side",0
Get_str			dc.b	"getcalc",0
Cp_str			dc.b	"cp",0
Mv_str			dc.b	"mv",0
Clean_str		dc.b	"clean",0
SendCalc_str		dc.b	"sendcalc",0
Cd_str			dc.b	"cd",0
RmDir_str		dc.b	"rmdir",0
MkDir_str		dc.b	"mkdir",0
Rm_str			dc.b	"rm",0
Cls_str			dc.b	"clear",0	
Arc_str			dc.b	"arc",0
UnArc_str		dc.b	"unarc",0
Mem_str			dc.b	"mem",0
InstallProductCode_str	dc.b	"install product code",0
Reset_str		dc.b	"reset",0
Help_str		dc.b	"help",0
Ls_str			dc.b	"ls",0
RmArc_str		dc.b	"rmarc",0
Menu_str		dc.b	"menu",0
	ifd	USE_MAIN_PROGRAM
Zs_str			dc.b	"zs",0
	endif
AutoArchive_str		dc.b	"AutoArc",0
OffSwitch_str		dc.b	"OffSwitch",0
GetKeySwitch_str	dc.b	"GetKeySwitch",0
StatusError_str		dc.b	"StatusError",0
	EVEN
