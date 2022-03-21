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
        xdef FindSymInPath
        xdef PathInit
        xdef PathNext
        xdef Match
        xdef TranslateArgs
        xdef CheckRedirection
        xdef PushArgs
        xdef ShellRestartAPD
        xdef ShellExecuteCommand
        xdef ShellExecuteSimpleCommand
        xdef ReplaceVars
        xdef LocalPushParseText
        xdef system
        xdef HomeExecute
        xdef HomeExecute_reg


;******************************************************************
;***                                                            ***
;***            	Shell System Command			***
;***                                                            ***
;******************************************************************
	

; Find a file in the path.
; In:
;	a4 -> File Name (ANSI) (Shell string)
; Out:
;	a0.l -> SYM_ENTRY or NULL if not found.
FindSymInPath:
	; Search in the current or given folder.
	move.l	a4,a0
\cvt:		tst.b	(a0)+
		bne.s	\cvt
	clr.w	-(a7)			; Current Folder
	pea	-1(a0)			; Push filename
	jsr	SymFindPtr		; Search for it
	move.l	a0,d0			; Success finding it ?
	bne.s	\Find
	bsr.s	PathInit		
\PathLoop	
		bsr.s	PathNext
		move.l	a0,(a7)			; Save Path Ptr and check if NULL
		beq.s	\Find
		move.w	#FOLDER_LIST_HANDLE,a0	; Folder List
		jsr	FindSymEntry		; Find Folder
		move.l	a0,d0
		beq.s	\Next
			move.w	SYM_ENTRY.hVal(a0),a0
			move.l	a4,a1		
			jsr	FindSymEntry	; Search file in this folder
			move.l	a0,d0		; Success ?
			bne.s	\Find
\Next		move.l	(a7),a0			; Reload Path Ptr
		bra.s	\PathLoop
\Find:	addq.l	#6,a7
	rts

	;;  Init the path system (uses a0)
PathInit:
	; Search path variable
	pea	Path_sym			; Push filename
	jsr	SymFindPtr			; Search Path variable.
	addq.l	#4,a7
	move.l	a0,d0
	beq.s	PathEnd
	move.w	SYM_ENTRY.hVal(a0),a0		; Read Handle
	jsr	HToESI_reg			; Get Var Tag Ptr
	cmpi.b	#$D9,(a0)			; Check if var is a list.
	bne.s	PathEnd
	; Search in the path.
	subq.l	#1,a0				; Skip List Tag
	rts
PathEnd	suba.l	a0,a0
	rts
	;; Next entry in the path or NULL (uses a0)
PathNext:
	cmpi.b	#$2D,(a0)			; Check String Tag (if NULL, (a0) != $2D!)
	bne.s	PathEnd
	jsr	next_expression_index_reg	; Next Expression
	lea	2(a0),a1			; Folder name
	rts

; Match if the 2 strings may be identical !
; In :
;	a0 -> String 1
;	a1 -> String 2
; Out:
;	d0.b = 0 if there are identical
; Note: 
;	String2 may allow wildcars '*' and '?'
Match:
	move.b	(a1)+,d1
	beq.s	\End
	cmpi.b	#'*',d1
	beq.s	\DoMany
	cmpi.b	#'?',d1
	beq.s	\Skip
	move.b	(a0)+,d0
	beq.s	\Error
	cmp.b	d0,d1
	beq.s	Match
\Error	moveq	#1,d0
	rts
\Skip	addq.l	#1,a0		; Skip this character
	bra.s	Match
\End:	move.b	(a0),d0		; If a0 is null, we succeed, else we failed
	rts
\Error2	move.b	d1,d0		; Is is the joker was '0'
	rts			; Yes, so it isn't an error, we succeed !
\DoMany	move.b	(a1)+,d1	; Stop char
\Loop		move.b	(a0)+,d0	; We loop until we found
		beq.s	\Error2		; Else the end of the string 1
		cmp.b	d0,d1		; else the stop character
		bne.s	\Loop
	movem.l	d1/a0/a1,-(a7)	; We scan recursevly from this position 
	jsr	Match		; to check the motif
	movem.l	(a7)+,d1/a0/a1	
	tst.b	d0		; If it failed, we go back, and skip this one.
	bne.s	\Loop
	rts

; Translate the args from the command line
; Warning : if the command contains some space, it may fail !
; It translate wildcards '*' & '?' in files.
; In:
;	a4 -> Line Buffer
; Destroy:
;	Nothing
TranslateArgs:
	movem.l	d0-d6/a0-a6,-(a7)		
	; Register Usage:
	;	d0-d2/a0-a1: Grab registers
	;	d1 IsWildCard	/ d3: Temp Save of Current Entry
	;	d4: Current Index in ARGV table / d5: Current Arg with wildcard
	;	d6: Current Ptr of Folder Separator
	;	a2 -> Input Ptr	/ a3 -> ARGV Ptr /
	;	a5 -> Extra Buffer Ptr
	move.l	a4,a2				; Line Buffer Ptr
	moveq	#0,d4
	lea	ARGV,a3				; ARGV Table
\ArgLoop:	; 1. Skip spaces
\SkipSpace		move.b	(a2)+,d0
			beq	\RealEndOfLine
			cmpi.b	#' ',d0
			beq.s	\SkipSpace
		subq.l	#1,a2

		; 2. Save command pointer
		move.l	a2,0(a3,d4.w)		; Save command (First arg)
		addq.w	#4,d4			; Next arg
		cmpi.w	#ARG_MAX*4,d4		; Check if overflow ?
		bge	\RealEndOfLine

		; 3. Read the next word.
		clr.b	d1			; No wildcards
		move.b	(a2),d0
		; Check if start with '"' (Select all the args)
		cmpi.b	#'"',d0			
		bne.s	\ReadNextWord
			; Next word is between " and "		
			addq.l	#1,-4(a3,d4.w)	; Inc previous ptr to skip '"'
			addq.l	#1,a2		; Skip first '"'
		\next2:		move.b	(a2)+,d0	; Read next Char 0
				beq	\RealEndOfLine	; Yes, so RealEndOfLine
				cmpi.b	#'"',d0		; Check if '"'
				bne.s	\next2
			bra.s	\NextArg
\SkipSpaceInsideWord2:
		addq.l	#1,a2		; Skip the 2 next chars '2>'
\SkipSpaceInsideWord:	
		addq.l	#1,a2		;  Skip the next char '>' or '<'
		cmpi.b	#'>',(a2)	;  Skip the next char '>'
		bne.s	\SkipSpaceInsideWordLoop
		addq.l	#1,a2		;  Skip the next char '>'
\SkipSpaceInsideWordLoop
			move.b	(a2)+,d0
			beq	\RealEndOfLine
			cmpi.b	#' ',d0
			beq.s	\SkipSpaceInsideWordLoop
			subq.l	#1,a2
			bra.s	\NextChar
\ReadNextWord:	; Check if there is a redirection, like '> toto', '< tutu' or '2> tata'
		cmpi.b	#'>',d0
		beq.s	\SkipSpaceInsideWord
		cmpi.b	#'<',d0
		beq.s	\SkipSpaceInsideWord
		cmpi.b	#'2',d0
		bne.s	\NextChar
		cmpi.b	#'>',1(a2)
		beq.s	\SkipSpaceInsideWord2
\NextChar:	move.b	(a2)+,d0		; Read next char
		beq	\EndOfLine		; End of line
		cmpi.b	#'*',d0			; Check if '*'
		bne.s	\NoStar
			st.b	d1		; Set wildcards	translation
\NoStar		cmpi.b	#'?',d0			; Check if '?'
		bne.s	\NoJoker
			st.b	d1		; Set wildcards	translation
\NoJoker	cmpi.b	#' ',d0			; Check if ' ' (Separation between args)
		bne.s	\NextChar		; No, => next char

		; 4. Translate of the last argument if there was any wildcards
\NextArg:	clr.b	-1(a2)			; Argument is a NULL string
		tst.b	d1			; No Wildcars, ok
		beq	\ArgLoop ;
\Wild			move.l	-4(a3,d4.w),d5	; d5 -> Current Arg with wildcards
			subq.w	#4,d4		; Remove this arg from the arg list
			clr.b	d7		; Flag: We haven't added any argument
			; Default folder : Current folder
			lea	CUR_FOLDER_STR,a1
\CurrentFolderOk:
			; Folder convertion
			\Cvt:	tst.b	(a1)+
				bne.s	\Cvt
			; Search in the VAT some files which may be like the wildcards
			move.w	#FO_SINGLE_FOLDER,-(a7)	; We search in the current folder
			pea	-1(a1)			; From ANSI to TI...
			jsr	SymFindFirst		; Go throught the current folder
			addq.l	#6,a7
			bra.s	\CmpGo
\CmpLoop			jsr	SymFindNext	; Next entry
\CmpGo				move.l	a0,d3		; No more entry ? Quit
				beq.s	\AddOrgAndArgLoop
				move.l	d5,a1
				jsr	Match		; Does theses str matches ?
				tst.b	d0
				bne.s	\CmpLoop	; No, next
					st.b	d7	; Flag: We have added & translated an argument
					move.l	d3,0(a3,d4.w)	; Save this arg
					addq.w	#4,d4
					cmpi.w	#ARG_MAX*4,d4
					blt.s	\CmpLoop
					bra.s	\RealEndOfLine
\AddOrgAndArgLoop:	tst.b	d7 			; Check if we have added something
			bne.s	\ArgLoopRedirect	;
				move.l	d5,0(a3,d4.w)	; No, so save the original arg
				addq.w	#4,d4		; We can't have an overflow
\ArgLoopRedirect	bra	\ArgLoop
	
	;; End of line, but translate the last argument.
\EndOfLine:
	subq.l	#1,a2
	tst.b	d1
	bne.s	\Wild
	;; End of line, but don't translate the last argument.
\RealEndOfLine
	bsr.s	CheckRedirection
	lsr.w	#2,d4
	move.w	d4,ARGC
	movem.l	(a7)+,d0-d6/a0-a6
	rts

; Shell redirection. Support of stdin/stdout/stderr
; WARNING: It is not a function! It is the natural sequel of TranslateArg!
; Only TranslateArg can call this!
; In:
;	d4.w = Num of arg*4
;	a3 -> argv
; out:
;	d4.w = New num of arg
CheckRedirection:
\RedirectLoop
		move.l	-4(a3,d4.w),a0		; Get last arg
		move.b	(a0)+,d0		; Check first char of last arg
		lea	stdin,a2		; default: stdin
		lea	ReadModeStr(pc),a1	; defautl: read
		cmpi.b	#'<',d0			; Check redirection of stdin
		beq.s	\Redirect		; Yes=> redirect it!
		addq.l	#2,a1			; default: write
		lea	stdout,a2		; default: stdout
		cmpi.b	#'>',d0			; Check redirection of stdout
		bne.s	\CheckStderr		; Yes=>redirect
		cmpi.b	#'>',(a0)		; Check '>>'
		bne.s	\Redirect
			addq.l	#1,a0		; Skip second char '>'
			addq.l	#2,a1		; mode: append
			bra.s	\Redirect
\CheckStderr
		lea	stderr,a2		; stderr	
		cmpi.b	#'2',d0			; stderr is 2>. First check 2
		bne.s	\EndRedirect		; No, so end of redirection
		move.b	(a0)+,d0		; Read next char
		cmpi.b	#'>',d0			; Check second char
		bne.s	\EndRedirect		; no
		; Does the redirection
\Redirect		cmpi.b	#' ',(a0)+
			beq.s	\Redirect
		tst.b	-(a0)		; Redirection: Check if there is at least a char
		beq.s	\EndRedirect
		jsr	freopen		; Reopen stream to a file
		move.l	a0,d0
		beq.s	\ResetRedirect	; Error: Reset to default
		subq.w	#4,d4
		bhi.s	\RedirectLoop
\ResetRedirect:
	jsr	InitTerminal
\EndRedirect
	rts
ReadModeStr	dc.b	'r',0
WriteModeStr	dc.b	'w',0
AppendModeStr	dc.b	'a',0
	EVEN

; Push the arg on the EStack for a program which is compatible with AMS.
; You must call TranslateArgs first
; If you call after push_LIST_tag and HS_popEstack, you can easilly create
; a var with all the args.
PushArgs:
	movem.l	d0-d3/a0-a2,-(a7)
	jsr	push_END_TAG
	move.w	ARGC,d3
	subq.w	#2,d3
	blt.s	\done
	lea	ARGV+8,a2
	adda.w	d3,a2
	adda.w	d3,a2
	adda.w	d3,a2
	adda.w	d3,a2
\loop		move.l	-(a2),-(a7)
		jsr	push_zstr
		addq.l	#4,a7
		dbf	d3,\loop
\done	movem.l	(a7)+,d0-d3/a0-a2
	rts

; Restart APD timer by reading system\apd.
ShellRestartAPD:
	lea	APD_str(Pc),a2
	move.w	#APD_MIN,d1
	move.w	#APD_MAX,d2
	move.w	#APD_DEFAULT,d3
	jsr	getenv_si
	mulu.w	#20,d0		; x20 -> second
	move.l	d0,-(a7)	; Push ticks time
	move.w	#APD_TIMER_ID,-(a7)	; Push timer #
	jsr	OSFreeTimer	; Free APD timer
	jsr	OSRegisterTimer	; Set new value of APD
	addq.l	#6,a7		; Pop stack
	rts

; Execute a command (aka system).
; It prepares the call to ShellExecuteSingleCommand (Reinit terminal, restart APD, replace vars).
; It also decomposes in Single command, aka it translates pipe connection.
; In:
;	a4 -> Shell String
ShellExecuteCommand:
	jsr	InitTerminal			; Set stdin/stdout/stderr to the terminal
	bsr.s	ShellRestartAPD			; Restart Auto Power Down
	jsr	ReplaceVars			; Replace the Vars ($x and so on)
	; Scan string for | or "
\LoopPipe	
	move.l	a4,a0
\SearchPipe:	
		move.b	(a0)+,d0
		beq.s	\EndOfString
		cmpi.b	#'"',d0
		bne.s	\CheckPipe
\SkipString		move.b	(a0)+,d0
			beq.s	\EndOfString
			cmpi.b	#'"',d0
			bne.s	\SkipString
\CheckPipe	cmpi.b	#'|',d0
		bne.s	\SearchPipe

	;; We have found a pipe: performs the command decomposition.
	pea	(a0)		; Push String to keep ptr
	clr.b	-(a0)		; 0 string (Remove the '|' character to separate command)
	
	; Redirect stdin into what was stdout if stdout is a TMP file
	cmpi.w	#$0202,stdout		; If stdout is a written TMP file
	bne.s	\First			; we don't have to redirect which was stdout to stdin.
		clr.w	stdout		; Fast fclose(stdout) since we don't want to lose the temp file.
		lea	stdin+2,a0	; Reopen stdin using the handle used for stdout
		move.w	stdout+2,(a0)	; Copy handle
		move.w	#$0201,-(a0)	; Read Flag | TMP file
		jsr	rewind		; rewind (stdin)
\First	; Redirect stdout
	suba.l	a0,a0			; Name = NULL (Create a temp file)
	lea	WriteModeStr(pc),a1	; Write mode
	lea	stdout,a2		; FILE=stdout
	jsr	freopen			; freopen(NULL,"w",stdout) -> tmpfile;
	
	; Execute simple command
	bsr.s	\SingleCommand		; Execute this simple command.
	move.l	(a7)+,a4		; Pop next command to execute
	
	; Check stdin.flags.Terminal
	btst.b	#$0201,stdin		; If stdin was a redirect TMP file
	bne.s	\StdinTerminal		; to remove the handle and its allocated memory.
		lea	stdin,a0	; if stdin!=terminal,
		jsr	fclose		; fclose(stdin)
\StdinTerminal	
	bra	\LoopPipe

\EndOfString
	; Check if redirection is needed
	cmpi.w	#$0202,stdout		; If stdout=Terminal
	bne.s	\SingleCommand		; No need to redirect stdin/stdout

	;; We have redirected stdout to a tmpfile. We needs to copy what was in stdout to stdin
	clr.w	stdout			; Fast fclose(stdout) since we don't want to lose the temp file.
	lea	stdin+2,a0	
	move.w	stdout+2,(a0)		; Copy handle
	move.w	#$0201,-(a0)		; Read Flag | TMP file
	jsr	rewind			; rewind (stdin)
	; stdout = terminal
	move.w	#$0102,stdout
	; Execute simple command
	bsr.s	\SingleCommand
	; Close stdin
	lea	stdin,a0
	jmp	fclose			; fclose(stdin)
\SingleCommand


; Execute a simple command. Simple means that the command is unique.
; All the pipe stuff ( | ) and the replacing of vars $toto
; has been done by ShellExecuteCommand.
; It remains the redirection stuff which is done by Translate Args.
; In:
;	a4 -> String to execute (WARNING: it is modified !, and -1(a4)=0 !)
; Destroy a0-a3/d0-d4
; Various errors may be throw.
ShellExecuteSimpleCommand:
	jsr	EStackReInit			; Reinit EStack before parsing
	move.w	CURRENT_POINT_Y,SHELL_SAVE_Y_POS

	;1. Skip spaces at the beginning
\Spaces		cmpi.b	#' ',(a4)+
		beq.s	\Spaces
	subq.l	#1,a4

	; 2. Check if it a builtin Command?
	lea	BuiltinCommandTable(pc),a3
	move.l	a3,a2
\loop:		move.w	(a2)+,d0		; Check if end of table?
		beq.s	\InternalCommandNotFound
		lea	0(a3,d0.w),a1		;  Builtin command name
		move.l	a4,a0			;  Input command
\cmp:			tst.b	(a1)		; NULL str ?
			beq.s	\InternalCommand
			cmpm.b	(a1)+,(a0)+	; Cmp str
			beq.s	\cmp
\no:		addq.l	#2,a2			; Next command
		bra.s	\loop
\InternalCommand:
	move.b	(a0),d0				; Check if Command also ends with a 0
	beq.s	\ok
	cmpi.b	#' ',d0				; or a space.
	bne.s	\no
\ok:	jsr	TranslateArgs			; Translate the args
	move.w	(a2),d0
	jmp	0(a3,d0.w)			;  Jump to builtin Command

	; 3. Check if it an executable file?
\InternalCommandNotFound:
	move.l	a4,a0
	suba.l	a3,a3				; NULL
\Cvt:		move.b	(a0)+,d0		; Get a filename
		beq.s	\CvtDone
		cmpi.b	#' ',d0
		bne.s	\Cvt
		lea	-1(a0),a3		;  Nullify the filename
		clr.b	(a3)
\CvtDone
	jsr	FindSymInPath			; Find the filename in the path
	move.l	a3,d0				; Check if we have patched the string
	beq.s	\CheckSym
		move.b	#' ',(a3)		; Restore the ' ' char.
\CheckSym
	move.l	a0,d4				; Success finding it ?
	beq	\FileNameNotFound
		; Check if it an ASM file, a PPG file or a SCRIPT
		move.w	SYM_ENTRY.hVal(a0),-(a7)	; Push Handle
		jsr	HToESI				; Get TAG Pointer
		cmpi.b	#$F3,(a0)			; ASM ?
		beq.s	\RunASM
		cmpi.b	#$F8,(a0)			; PPG ?
		beq.s	\RunPPG
		cmpi.b	#$E0,(a0)			; Script ?
		beq.s	\RunScript
		addq.l	#2,a7				; Pop pushed Handle
		bra.s	\FileNameNotFound		; The file has been found but it isn't an executable file.

\RunASM		jsr	TranslateArgs		; Translate the args
		jsr	PushArgs		; Push on the EStack the args.
		move.w	(a7)+,d0		; HANDLE
\KernelExecThrow:
		clr.w	Error			; Clear Error code
		jsr	KernelExec_redirect	; Execute the file
		move.w	Error,d0		; Load error code
		bne.s	\Throw			; If error throw execption
		rts				; Otherwise returns
\Throw:		bra	ER_throwVar_reg		; Throw error code
		
\RunScript:	jsr	TranslateArgs		; Translate the args
		jsr	PushArgs		; Push on the EStack the args.
		move.w	(a7)+,d0		; HANDLE
		jmp	ScriptExec		; Execute the script
\RunPPG:	cmpi.b	#'p',-4(a0)		; Check for PPG
		bne.s	\FileNameNotFound	
		cmpi.b	#'p',-3(a0)
		bne.s	\FileNameNotFound
		cmpi.b	#'g',-2(a0)
		bne.s	\FileNameNotFound
		jsr	TranslateArgs		; Translate the args
		jsr	PushArgs		; Push on the EStack the args.
		move.w	(a7),d4			; Get Handle of FILE
		jsr	ExtractPPG		; Extract the PPG
		move.w	d0,(a7)			; Push HANDLE
		beq.s	\Fail			; Check if not fail
		jsr	KernelExec_redirect	; Exec the file.
		move.l	d0,d4			; Save return value
		move.w	(a7)+,d0		;  Reload Handle to free
		bra	HeapFree_reg		; Free the handle
\Fail		ER_THROW 1			; Needs to fill the Error Table

	; 4. Interpret command using NG_approx
\FileNameNotFound:
	pea	(a4)
	jsr	LocalPushParseText			; Push Text
	move.l	top_estack,(a7)
	jsr	NG_approxESI				; Evaluate it
	tst.b	SHELL_NG_DISPLAY			; Check if we have to display
	beq.s	\DontDisplay				; the result of the evaluation
		move.l	top_estack,(a7)
		jsr	display_statements		; Retransform it to text
		move.w	d0,(a7)				; Push the handle
		move.w	d0,a0				; Get the Handle
		trap	#3				; Deref it
		pea	(a0)				; Push its address
		jsr	printf				; Display the text
		addq.l	#4,a7				; Pop its address
		jsr	DispReturn			; Display Return
		jsr	HeapFree			; Free the Text Handle 
\DontDisplay
	addq.l	#4,a7				; Fix stack Ptr
	rts

	
; Replace the vars in the command line.
; It replaces $x, or ${x} or ${x[1]} by its value (String int).
; It expands '>>' to ' >>', '>' to ' >', '<' to ' <' (but not '2>' !)
; The first word may be an alias, and will be translated
; In:
;	a4 -> Shell Buffer of Size SHELL_MAX_LINE
ReplaceVars:
	movem.l	d0-d7/a0-a6,-(a7)
	; Alloc Another Buffer on the stack
	moveq	#SHELL_MAX_LINE,d3
	suba.w	d3,a7
	move.l	a7,a3		; Create a new temp Shell Buffer
	pea	(a4)		; Save original Shell Buffer
	
	;  First word may be an alias
	move.l	a4,a2
\FirstW:	move.b	(a4)+,d7
		beq.s	\EndFirstW
		cmpi.b	#' ',d7
		bne.s	\FirstW
\EndFirstW:
	clr.b	-(a4)		; Nullify the string
	jsr	getenv		; Getenv
	move.b	d7,(a4)		; Restore final char
	move.l	a0,d0
	beq.s	\AliasFailed
\TranslateFirstWLoop:	
		move.b	(a0)+,d2
		beq.s	\AliasDone
		bsr.s	\AddChar
		bra.s	\TranslateFirstWLoop
\AliasFailed:	
	move.l	(a7),a4		; Failed: restart parsing.
\AliasDone:	

	; Copy translated version of OrgBuffer To StackBuffer
\CopyLoop
		move.b	(a4)+,d2			; Read Char
		beq.s	\Return
		cmpi.b	#SCRIPT_VARIABLE_CHAR,d2
		beq.s	\TranslateVar
		cmpi.b	#'>',d2
		beq.s	\CheckForSup
		cmpi.b	#'<',d2
		beq.s	\AddExtraSpace
\AddStandard	bsr.s	\AddChar
		bra.s	\CopyLoop

	;;  Deals with redirection stuff: put space before and after
\CheckForSup:
	;;  check for >>
	cmpi.b	#'>',(a4)
	bne.s	\NoExpandFileRedirection
		moveq	#' ',d2
		bsr.s	\AddChar
		moveq	#'>',d2
		bsr.s	\AddChar
		move.b	(a4)+,d2
		bra.s	\AddStandard	
\NoExpandFileRedirection
	;; Check for 2>
	cmpi.b	#'2',-2(a4)
	bne.s	\AddExtraSpace
	cmpi.b	#' ',-3(a4)
	beq.s	\AddStandard
\AddExtraSpace:
	;; Add space before for '>' and '<' so that it will be translated correctly
	moveq	#' ',d2
	bsr.s	\AddChar
	move.b	-1(a4),d2
	bra.s	\AddStandard

\Return
	clr.b	(a3)				; Nullify the string
	; Copy StackBuffer to OrgBuffer
	moveq	#SHELL_MAX_LINE,d0
	move.l	(a7)+,a0			; Org Buffer
	move.l	a7,a1				; Temp Buffer
	jsr	memcpy_reg
	; Pop Frame / Restore registers and Return
	lea	SHELL_MAX_LINE(a7),a7
	movem.l	(a7)+,d0-d7/a0-a6
	rts

\AddChar
	subq.w	#1,d3		; Add one char: length--
	blt.s	\NoAdd		; Overflow: do nothing.
	move.b	d2,(a3)+
\NoAdd	rts


	; Find $. Translate var
\TranslateVar
	moveq	#0,d7
	move.l	a4,a2				; File Name
	cmpi.b	#'{',(a4)			; Check if "{"
	bne.s	\SingleVar
		; Form= ${toto}
		addq.l	#1,a2
		; Find '}'
\LoopSVar		move.b	(a4)+,d2
			beq.s	\Return		; if end of string, return
			cmpi.b	#'}',d2
			bne.s	\LoopSVar
		bra.s	\EvalVariable
\EndOfString
	moveq	#0,d7
	subq.l	#1,a4
	bra.s	\EvalVariable2
\SingleVar	; Form= $x
		moveq	#' ',d7		; Final character	
		; Find Space or End of string
\LoopVar	move.b	(a4)+,d2
		beq.s	\EndOfString
		cmpi.b	#' ',d2
		bne.s	\LoopVar
\EvalVariable
	clr.b	-1(a4)			; Clear it
\EvalVariable2
	; Eval Variable
	movem.l	d4-d7/a4-a6,-(a7)
	lea	-60(a7),a7		; Push Error Frame
	pea	(a7)
	jsr	ER_catch
	tst.w	d0
	bne.s	\Error
		jsr	EStackReInit		; ReInit EStack
		pea	(a2)
		bsr.s	LocalPushParseText		; Push parse text
		move.l	top_estack,(a7)
		jsr	NG_approxESI		; Eval It
		addq.l	#4,a7
		move.l	top_estack,a5		; Expression
		move.w	d3,d4			; Remaining chars
		move.l	a3,a4			; Output buffer
		moveq	#1,d5			; Do not add '"' for string
		jsr	Display1DESI		; Put in buffer
		move.w	d4,d3			; Update remaining chars
		move.l	a4,a3			; Update output buffer
		jsr	ER_success		; Ok!
\Error	lea	64(a7),a7		; Pop Error Frame
	movem.l	(a7)+,d4-d7/a4-a6
	move.b	d7,d2
	beq	\CopyLoop
		jsr	\AddChar	; Add final space.
		bra	\CopyLoop	;

LocalPushParseText:
	jmp	push_parse_text
	
; int system(const char *command asm("a0"))
system:
	movem.l	d3-d7/a2-a6,-(a7)
	pea	(a0)
	jsr	strlen		; Destroy a0 and read the length of the command
	move.l	(a7)+,a0	; so reload a0
	bsr.s	HomeExecute_reg	; Execute command
	jsr	Float2Int_redirect	; Convert FReg1 to int d0
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;void HomeExecute (const char *Command, unsigned short ComLen);
HomeExecute:
	move.l	4(a7),a0
	move.w	8(a7),d0
HomeExecute_reg:
	movem.l	d3-d7/a2-a6,-(a7)
	move.w	d0,d7			; Copy comamnd into created stack space
	addq.w	#3,d7			; +1 For 0 +2 For alignement
	andi.w	#$FFFE,d7		; Word alignement
	suba.w	d7,a7			; Create Stack Frame
	move.l	a7,a1			; dest Ptr
	clr.b	(a1)+			; *dest++ =0
	subq.w	#1,d0			; for(i = 0 ; i < ComLen ; i++) *dest++ = *src++
	blt.s	\End
\Loop		move.b	(a0)+,(a1)+
		dbf	d0,\Loop	
	clr.b	(a1)			; Null String
	lea	1(a7),a4		; Input Buffer in a4
	
	lea	-60(a7),a7		; Error Stack Frame
	pea	(a7)			; Push Stack Frame
	jsr	ER_catch		; Catch all errors.
	tst.w	d0
	bne.s	\Error
		jsr	ShellExecuteCommand	; Translate and execute Command
		jsr	ER_success
		bra.s	\Cont
\Error	move.w	d0,(a7)
	jsr	ERD_dialog_redirect
\Cont	lea	64(a7),a7
\End	adda.w	d7,a7			; Pop Frame
	movem.l	(a7)+,d3-d7/a2-a6
	rts
