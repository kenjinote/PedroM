;*
;* PedroM - Operating System for Ti-89/Ti-92+/V200.
;* Copyright (C) 2003, 2005-2008 Patrick Pelissier
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
        xdef NG_tokenize
        xdef push_parse_text
        xdef ParseRecur
        xdef ParseFinal
        xdef ParseInputFloat
        xdef ParseIsNumber
        xdef ParseIsVar
        xdef ParseIsPureVar
        xdef ParseIsPureVar2
        xdef NG_RPNToText
        xdef display_statements
        xdef Parse1DExpr
        xdef Display1DESI
        xdef Display1DError
        xdef Display1DVAR
        xdef Display1DSTRING
        xdef Display1DZERO
        xdef Display1DPLUS
        xdef Display1DMOINS
        xdef Display1DMULT
        xdef Display1DDIV
        xdef Display1DPOW
        xdef Display1D2ARGS
        xdef Display1DIndex
        xdef Display1DLIST
        xdef NG_graphESI
        xdef NG_approxESI
        xdef NG_rationalESI
        xdef NG_execute
        xdef EvalESIandPushResult
        xdef EvalESI
        xdef EvalUndef
        xdef EvalSTRING_LIST
        xdef EvalZERO
        xdef EvalBCD
        xdef EvalVAR
        xdef EvalPLUS
        xdef EvalMOINS
        xdef EvalMULT
        xdef EvalDIV
        xdef EvalPOW
        xdef Eval2ARGS
        xdef Eval2ARGS_strORfloat
        xdef EvalEqualString
        xdef EvalEqual
        xdef CopyFloatZero
        xdef EvalNotEqual
        xdef CopyFloatOne
        xdef EvalSupEqual
        xdef EvalSup
        xdef EvalInfEqual
        xdef EvalInf
        xdef EvalFUNC
        xdef EvalBASICFUNC
        xdef EvalASMFUNC
        xdef EvalSTORE
        xdef EvalIndex
        xdef are_expressions_identical
        xdef BCDTag
        xdef UndefTAG
        xdef all_tail
        xdef any_tail
        xdef last_element_index


; ***************************************************************
; 			Min EStack function (2)
; ***************************************************************

;short NG_tokenize (HANDLE hTEXT, unsigned short *ErrCode, unsigned short *ErrOffset);
NG_tokenize:
	movem.l	d3-d4/a2-a4,-(a7)
	lea	-$4C(a7),a7			; Stack frame for Error buffer.
	move.w	$64(a7),d3			; Handle of Text File
	move.l	$66(a7),a2			; Error Code ptr
	move.l	$6A(a7),a3			; Error Offset Ptr
	move.w	d3,(a7)
	jsr	HLock_redirect			; Lock Handle of file
	move.l	a0,a4				; And save ptr
	lea	4(a7),a0			; Alloc frame
	move.l	a0,(a7)				; Push addr of frame
	jsr	ER_catch			; Catch any error
	move.w	d0,d4
	bne.s	\Error
		move.l	a4,(a7)
		bsr.s	push_parse_text
		move.w	d0,(a2)
		moveq	#1,d4
		jsr	ER_success
		bra.s	\done
\Error	move.w	d4,(a2)
	move.l	error_estack,d0
	sub.w	a4,d0
	move.w	d0,(a3)
	moveq	#0,d4
\done
	move.w	d3,(a7)
	jsr	HeapUnlock_redirect
	move.w	d4,d0
	lea	$4c(a7),a7
	movem.l	(a7)+,d3-d4/a2-a4
	rts
	
;short push_parse_text (const char *str);
push_parse_text:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	44(a7),a2			; String
	move.l	top_estack,-(a7)		; Push top_estack
	bsr.s	ParseRecur			; Return in a2 the last character which can not be translated
	move.l	(a7)+,a0			; Pop top_estack
	tst.b	(a2)				; Check sucessfull
	beq.s	\Success			; If string current != 0, an error occured.
		move.l	a0,top_estack		; Fix top_estack
		ER_THROW SYNTAX_ERROR
\Success
	moveq	#0,d0
	movem.l	(a7)+,d3-d7/a2-a6
	rts

; Recursive Parse a string
; VALIDATE:
;	Input Float
;	Operator priority
;	Parenthese
;	Var
;	Function
;	List
; Bug:
;	. without anything is a 0.
; In:
;	a2 -> String
;	list[i]		-> E5 i list D5
ParseRecur:
	; Alloc Op Stack = Stack
	clr.w	-(a7)				; Stop the OP stack
ParseLoopNextInput
	moveq	#1,d3				; Last character was an operator 
ParseLoop
		move.b	(a2),d2
		jsr	ParseIsNumber
		tst.b	d0
		bne	ParseInputFloat
		jsr	ParseIsPureVar
		tst.b	d0
		bne	ParseInputVar
		addq.l	#1,a2			; One char
		cmpi.b	#' ',d2			; ' ' Skip Space
		beq.s	ParseLoop
		cmpi.b	#',',d2			; ','
		beq.s	ParseLoopNextInput
		cmpi.b	#'(',d2
		beq	ParseInputParent
		cmpi.b	#'{',d2
		beq	ParseInputList
		cmpi.b	#'"',d2
		beq	ParseInputString
		cmpi.b	#'[',d2
		beq	ParseInputIndex
		cmpi.b	#22,d2			; '->'
		beq.s	\PushStore
		cmpi.b	#'*',d2
		beq.s	\PushMult
		cmpi.b	#'+',d2
		beq.s	\PushAdd
		cmpi.b	#'-',d2
		beq.s	\PushMinus
		cmpi.b	#'/',d2
		beq.s	\PushDiv
		cmpi.b	#'^',d2
		beq.s	\PushPow
		cmpi.b	#'<',d2
		beq.s	\PushInf
		cmpi.b	#'=',d2
		beq.s	\PushEqual
		cmpi.b	#'>',d2
		beq.s	\PushSup
		cmpi.b	#156,d2
		beq.s	\PushInfEqual
		cmpi.b	#157,d2
		beq.s	\PushNotEqual
		cmpi.b	#158,d2
		beq.s	\PushSupEqual
		subq.l	#1,a2
		bra	ParseFinal


; Push an operator (on the operator Stack or on the EStack)
\PushStore	move.w	#$80,d2			; Store TAG
		bra.s	\PushCheck
\PushMult	move.w	#$8F,d2
		bra.s	\PushCheck
\PushAdd	move.w	#$8B,d2
		bra.s	\PushCheck
\PushMinus	move.w	#$8D,d2
		bra.s	\PushCheck
\PushDiv	move.w	#$91,d2
		bra.s	\PushCheck
\PushPow	move.w	#$93,d2
		bra.s	\PushCheck
\PushInf	move.w	#$85,d2
		bra.s	\PushCheck
\PushEqual	move.w	#$87,d2
		bra.s	\PushCheck
\PushSup	move.w	#$89,d2
		bra.s	\PushCheck
\PushInfEqual	move.w	#$86,d2
		bra.s	\PushCheck
\PushNotEqual	move.w	#$8A,d2
		bra.s	\PushCheck
\PushSupEqual	move.w	#$88,d2
\PushCheck	tst.b	d3
		bgt.s	\Ans
		bne.s	ParseFinal	; End of parsing
\ContOp		st.b	d3		; Last char is an Operator
\LoopOp		move.w	(a7),d0
		beq.s	\PushIt
			; Priority is (TAG+1)/4
			move.w	d2,d1
			addq.w	#1,d1
			lsr.w	#2,d1		; Priority of New op
			addq.w	#1,d0
			lsr.w	#2,d0		; Priority of Pushed Op
			cmp.w	d1,d0		; If New operator has an higher priority
			bcs.s	\PushIt		; Push op in Operator Stack
			jsr	push_quantum	; Else push Operator on EStack
			addq.l	#2,a7
			bra.s	\LoopOp
\PushIt		move.w	d2,-(a7)	; Push Operator
		bra	ParseLoop
\Ans:		; Push Last Calcul To ESTACk
		move.w	d2,-(a7)			; Temp Save of d2.w
		lea	FloatReg1,a0			; Last ANS should be in FReg1
		lea	FloatReg2+FLOAT.exponent,a1	
		jsr	FloatInternal2AMS
		lea	FloatReg2+FLOAT.exponent,a1
		jsr	push_Float_reg			; Push it
		move.w	(a7)+,d2			; Reload current op
		bra.s	\ContOp

; End of parsing
; Push all remaining Operator on the stack
; Check if d3=-1 ???? 2+
ParseFinal:
		move.w	(a7)+,d0
		beq.s	\End
		jsr	push_quantum_reg
		bra.s	ParseFinal
\End	rts



; Parse the string to push a string : search for '"'
ParseInputString				; Clearly not optimize since we call push_quantum, again & again !
		clr.b	d3			; Last Thing was a STRING
		clr.w	d0			; 0
		jsr	push_quantum_reg	; d2 = '"'
		bra.s	\Start
\Loop			jsr	push_quantum_reg
\Start			move.b	(a2)+,d0
			beq	ParseFinal	; End of string : ERROR " not found
			cmp.b	d2,d0		; Find '"'
			bne.s	\Loop
		clr.w	d0			; 0
		jsr	push_quantum_reg
		move.w	#$2D,d0			; STR_TAG
		jsr	push_quantum_reg
		bra	ParseLoop


; Parse recursevely to find a ')'					
ParseInputParent
		clr.b	d3			; Last Thing was a ( ) bloc
		pea	-1(a2)			; Push Beginning
		jsr	ParseRecur		; Parse inside and stop 
		move.l	(a7)+,a0		; Read beginning
		move.b	(a2)+,d2		; Read stopped char
		cmpi.b	#')',d2			; If it is ')', it is ok ! continue
		beq	ParseLoop		; Else an error occured.
		move.l	a0,a2			; Return
		bra	ParseFinal		; the beginning of the expression
		
; Input a List
ParseInputList
		jsr	push_END_TAG		; END of LIST
		pea	-1(a2)			; Push Beginning
		jsr	ParseRecur		; Parse inside and stop 
		; List is now in reverse Order. Reverse it.
		move.l	top_estack,a0		; Get Last Element
		jsr	next_expression_index_reg	; Previous One E5 el1 el2 el3
\loop:			cmpi.b	#$E5,(a0)		; Check End of List
			beq.s	\end
			pea	(a0)			; Push el3 ESI
			jsr	next_expression_index
			pea	(a0)			; Push el2 ESI 
			jsr	push_between		; Push El2 on the Estack
			jsr	delete_between		; Delete old version of El2: $E5 El1 El3 El2
			move.l	(a7)+,a0		; Reload Ptr to El2 (Now it is a ptr to El3)
			addq.l	#4,a7			; Pop old ESI
			bra.s	\loop			; Next Element
\end		jsr	push_LIST_TAG		; Push LIST tag
		move.l	(a7)+,a0		; Read beginning
		move.b	(a2)+,d2		; Read stopped char
		clr.b	d3			; Last Thing was a LIST
		cmpi.b	#'}',d2			; If it is '}', it is ok ! continue
		beq	ParseLoop		; Else an error occured.
		move.l	a0,a2			; Return
		bra	ParseFinal		; the beginning of the list

; Input an index (Org AMS format for list[indice]: $E5, 0, indice,0, 0,list,0, $D5)
ParseInputIndex
		pea	-1(a2)			; Push Beginning
		move.l	top_estack,-(a7)
		jsr	push_END_TAG		; END of LIST
		jsr	ParseRecur		; Parse inside and stop 
		; Current format is: 0,LIST,0 ,$E5,0,indice,0
		jsr	next_expression_index
		pea	(a0)			; A0-> ListName / a1-> EndOfListName
		jsr	push_between		; RePush ListName
		jsr	delete_between		; Delete ListName
		addq.l	#8,a7
		; Format is: $E5,0,indice,0,0,list,0
		move.w	#$D5,d0
		jsr	push_quantum_reg	; Push tag
		; Format is: $E5,0,indice,0,0,list,0,$D5
		move.l	(a7)+,a0		; Read beginning
		move.b	(a2)+,d2		; Read stopped char
		clr.b	d3			; Last Thing was an index
		cmpi.b	#']',d2			; If it is ']', it is ok ! continue
		beq	ParseLoop		; Else an error occured.
		move.l	a0,a2			; Return
		bra	ParseFinal		; the beginning of the index

; Input a VAR name or a function
ParseInputVar
		clr.b	d3			; Last Thing was a VAR
		moveq	#-1,d1			; If var len is 1, it will do 2 loops
		move.l	a2,a3			; Beginning of the var
\Loop0			move.b	(a2)+,d2	; Read char
			addq.w	#1,d1		; One more char
			jsr	ParseIsVar	; Check if it is a var name ?
			bne.s	\Loop0		; One more char
		cmpi.w	#17,d1			; Var Name is too long !
		bhi.s	\VarError		; d1 =
		subq.l	#1,a2			; Rego on the untranslated char
		cmpi.b	#'(',d2			; Check if it is a Function
		beq.s	\Function		; or a variable name
			; Var Name
			clr.w	d0		; VAR a-z are not pushed in a single tag way
			jsr	push_quantum_reg
			subq.w	#1,d1
\Loop1				move.b	(a3)+,d0
				jsr	push_quantum_reg
				dbf	d1,\Loop1
			clr.w	d0		; 0 = VAR_TAG
			jsr	push_quantum_reg
			bra	ParseLoop

\VarError:	move.l	a3,a2
		bra	ParseFinal

\Function	addq.l	#1,a2			; Skip '('
		jsr	push_END_TAG		; Push END tag
		pea	(a3)			; Preserve Beginning 
		move.w	d1,-(a7)		; Preserve len
		jsr	ParseRecur		; Parse all args 
		move.w	(a7)+,d1		; Get len
		move.l	(a7)+,a3		; Get ptr to the beginning of the function name
		move.b	(a2)+,d2		; Read stop char
		cmpi.b	#')',d2			; Check if ok ?
		bne.s	\VarError		; If it is ')', it is ok
		clr.w	d0			; Push now the function name
		jsr	push_quantum_reg	; 0
		subq.w	#1,d1			; -1 for dbf
\Loop2			move.b	(a3)+,d0	; Read char
			jsr	push_quantum_reg ; push it
			dbf	d1,\Loop2	; Loop
		clr.w	d0			; Push 0	
		jsr	push_quantum_reg	
		move.w	#$DA,d0			; & Push USER_FUNC
		jsr	push_quantum_reg
		clr.b	d3			; Last thing was a function
		bra	ParseLoop

; Parse an push a Float
ParseInputFloat:
		addq.l	#1,a2			; Advance String Ptr
		; Clean FloatReg1
		clr.l	FloatReg1
		clr.l	FloatReg1+4
		clr.l	FloatReg1+8
		; Check Sign
		cmpi.b	#KEY_SIGN,d2
		bne.s	\NotMinus
			move.w	#$FFFF,FloatReg1+FLOAT.sign
			move.b	(a2)+,d2	; Read next char
\NotMinus	lea	FloatReg1+FLOAT.mantissa,a3	; Mantisse Ptr
		moveq	#15,d7			; 16 fingers
		; Read mantisse
		moveq	#-1,d6			; Exponent
\Loop1			subi.b	#'0',d2
			bcs.s	\EndOfLoop1
			cmpi.b	#9,d2
			bhi.s	\EndOfLoop1
			addq.w	#1,d6		; Expo++
			btst.l	#0,d7
			beq.s	\Advance
				lsl.w	#4,d2
				move.b	d2,(a3)
				bra.s	\Cont
\Advance:			or.b	d2,(a3)+
\Cont:			move.b	(a2)+,d2	; Read next char
			dbf	d7,\Loop1	; Next Finger
			; No more finger left in mantisse.
			; Skip all the remaining fingers
\loop11				cmpi.b	#'.',d2
				beq.s	\loop22_e
				subi.b	#'0',d2
				bcs.s	\EndOfLoop2
				subi.b	#9,d2
				bhi.s	\EndOfLoop2
				addq.w	#1,d6		; Expo++
				move.b	(a2)+,d2
				bne.s	\loop11
				bra.s	\NoExponent
\EndOfLoop1:	; Check if '.'
		cmpi.b	#'.'-'0',d2
		bne.s	\NoPoint
			move.b	(a2)+,d2	; Read next char
\Loop2				subi.b	#'0',d2
				bcs.s	\EndOfLoop2
				cmpi.b	#9,d2
				bhi.s	\EndOfLoop2
				btst.l	#0,d7
				beq.s	\Advance2
					lsl.w	#4,d2
					move.b	d2,(a3)
					bra.s	\Cont2
\Advance2:				or.b	d2,(a3)+
\Cont2				move.b	(a2)+,d2	; Read next char
				dbf	d7,\Loop2	; Next Finger
			; No more finger left in mantisse.
			; Skip all the remaining fingers
\loop22				subi.b	#'0',d2
				bcs.s	\EndOfLoop2
				cmpi.b	#9,d2
				bhi.s	\EndOfLoop2
\loop22_e			move.b	(a2)+,d2
				bne.s	\loop22
				bra.s	\NoExponent
\EndOfLoop2:
\NoPoint	; Check if 'E'
		cmpi.b	#149-'0',d2
		bne.s	\NoExponent
			; Read decimal exponent.
			move.b	(a2)+,d2
			cmpi.b	#KEY_SIGN,d2
			sne.b	d4
			bne.s	\NoExpoSign
				move.b	(a2)+,d2
\NoExpoSign		; Decimal
			moveq	#0,d5
			moveq	#3,d7
\Loop3				subi.b	#'0',d2
				bcs.s	\EndOfLoop3
				cmpi.b	#9,d2
				bhi.s	\EndOfLoop3
				ext.w	d2
				mulu.w	#10,d5
				add.w	d2,d5
				move.b	(a2)+,d2	; Read next char
				dbf	d7,\Loop3	; Next Finger
\EndOfLoop3		tst.b	d4
			bne.s	\NoNeg
				neg.w	d5					
\NoNeg			add.w	d5,d6
\NoExponent	
		add.w	#$4000,d6			; Average
		move.w	d6,FloatReg1+FLOAT.exponent	; Save Exponent
		jsr	FloatAdjust			; Adjust Float
		; Push Float To ESTACk
		lea	FloatReg1,a0
		lea	FloatReg2+FLOAT.exponent,a1
		jsr	FloatInternal2AMS
		lea	FloatReg2+FLOAT.exponent,a1
		jsr	push_Float_reg
		clr.b	d3				; Last Thing was a FLOAT
		subq.l	#1,a2				; Back a2
		bra	ParseLoop

; Say if d2 may be a number.
ParseIsNumber:
	tst.b	d3		; Last thing must be an operator
	sne.b	d0
	beq.s	\Ret
	cmpi.b	#'0'-1,d2	
	bls.s	\CheckPoint
	cmpi.b	#'9',d2
	bhi.s	\CheckEMinus
\IsNumber	moveq	#1,d0
\Ret		rts
\CheckPoint:
	cmpi.b	#46,d2
	seq	d0
	rts
\CheckEMinus:
	cmpi.b	#KEY_SIGN,d2
	beq.s	\IsNumber
	cmpi.b	#149,d2
	seq	d0
	rts

; Say if d2 may be a variable
ParseIsVar:
	cmpi.b	#'\',d2
	beq.s	\Ok
	cmpi.b	#'0'-1,d2
	bls.s	ParseIsPureVar2
	cmpi.b	#'9',d2
	bhi.s	ParseIsPureVar2
\Ok		moveq	#1,d0
ParseIsVarRet	rts

; Say if d2 may be the beginning of a var
ParseIsPureVar:
	tst.b	d3		; Last thing must be an operator
	sne.b	d0
	beq.s	ParseIsVarRet
ParseIsPureVar2:
	cmpi.b	#'A'-1,d2
	bls.s	\End
	cmpi.b	#'Z',d2
	bhi.s	\Next
	addi.b	#'a'-'A',d2	
\Ok	moveq	#1,d0
	rts
\Next	cmpi.b	#'_',d2
	beq.s	\Ok
	cmpi.b	#'a'-1,d2
	bls.s	\End
	cmpi.b	#'z',d2
	bls.s	\Ok
	; 128 -> 155 / 	178-> 182 / 188->255
	cmpi.b	#128-1,d2
	bls.s	\End
	cmpi.b	#155,d2
	bls.s	\Ok
	cmpi.b	#178-1,d2
	bls.s	\End
	cmpi.b	#182,d2
	bls.s	\Ok
	cmpi.b	#188-1,d2
	bhi.s	\Ok
\End	moveq	#0,d0
	rts
		

;HANDLE NG_RPNToText (HANDLE hRPN, unsigned short NewLines, unsigned short FullPrec); 
NG_RPNToText:
	move.w	4(a7),-(a7)
	jsr	HeapLock_redirect
	jsr	HToESI
	pea	(a0)
	bsr.s	display_statements
	jsr	HeapUnlock_redirect
	addq.l	#6,a7
	rts

;HANDLE display_statements (CESI ptr, unsigned short Newlines, unsigned short FullPrec);
;HANDLE Parse1DExpr (CESI ptr, unsigned short FullPrec, unsigned short width); 
; We don't care about the extra-parameters
display_statements:
Parse1DExpr:
	move.l	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	a0,a5
	pea	($101).w
	jsr	HeapAlloc_redirect
	move.w	d0,(a7)
	beq.s	\Error
		jsr	HLock_redirect
		move.l	a0,a4		; Ptr
		move.w	#$100,d4	; Remaining len
		moveq	#0,d5		; Flags
		bsr.s	Display1DESI
		clr.b	(a4)		
		jsr	HeapUnlock_redirect
\Error:	move.w	(a7),d0
	addq.l	#4,a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
; In:
;	a5 -> Expression
;	a4 -> String Ptr
;	d4.w = Remaining bytes in string
;	d5.l = Flags (0: Do not add " for string)
Display1DESI:
	move.b	(a5),d0			; Read TAB
	subq.l	#1,a5
	tst.b	d0
	beq	Display1DVAR
	cmpi.b	#$23,d0
	beq	Display1DBCD
	cmpi.b	#$8B,d0
	beq	Display1DPLUS
	cmpi.b	#$8D,d0
	beq	Display1DMOINS
	cmpi.b	#$8F,d0
	beq	Display1DMULT
	cmpi.b	#$91,d0
	beq	Display1DDIV
	cmpi.b	#$93,d0
	beq	Display1DPOW	
	cmpi.b	#$DA,d0
	beq	Display1DFUNC
	cmpi.b	#$D9,d0			; List
	beq	Display1DLIST
	cmpi.b	#$2D,d0			; String
	beq	Display1DSTRING
	cmpi.b	#$E5,d0			; End
	beq	Display1DZERO
	cmpi.b	#$D5,d0
	beq	Display1DIndex
	cmpi.b	#$2A,d0
	beq.s	Display1DUndef
	ER_THROW INVALID_COMMAND_ERROR

Display1DError:
	ER_THROW MEMORY_ERROR

Display1DUndef
	subq.w	#5,d4
	blt.s	Display1DError
	move.b	#'u',(a4)+
	move.b	#'n',(a4)+
	move.b	#'d',(a4)+
	move.b	#'e',(a4)+
	move.b	#'f',(a4)+
	rts
	
Display1DVAR:
\loop1		tst.b	-(a5)
		bne.s	\loop1
	lea	1(a5),a0
\loop2		subq.w	#1,d4
		beq	Display1DError
		move.b	(a0)+,(a4)+
		bne.s	\loop2
	subq.l	#1,a4
	addq.w	#1,d4
	rts

Display1DSTRING:
	btst.l	#0,d5
	bne.s	Display1DVAR
	subq.w	#2,d4
	bls	Display1DError
	move.b	#'"',(a4)+
	bsr.s	Display1DVAR
	move.b	#'"',(a4)+
	rts
	
Display1DZERO:
	subq.w	#1,d4
	beq	Display1DError
	move.b	#'0',(a4)+
	rts
	
Display1DBCD: ; HERE
	sub.w	#1+1+1+15+1+3,d4
	bls	Display1DError
	lea	1(a5),a0
	moveq	#5-1,d1
\loop		move.b	-1(a0),d0
		lsl.w	#8,d0
		move.b	(a0),d0
		move.w	d0,-(a7)
		subq.l	#2,a0
		dbf	d1,\loop
	clr.b	9(a7)
	pea	FloatFormat_str
	pea	(a4)
	jsr	sprintf
	lea	(10+4+4)(a7),a7
	add.w	d0,a4
	sub.w	#1+1+1+15+1+3,d0
	sub.w	d0,d4
	rts

Display1DPLUS:
	move.b	#'+',d3
	bra.s	Display1D2ARGS
	
Display1DMOINS:
	move.b	#'-',d3
	bra.s	Display1D2ARGS

Display1DMULT:
	move.b	#'*',d3
	bra.s	Display1D2ARGS

Display1DDIV:
	move.b	#'/',d3
	bra.s	Display1D2ARGS

Display1DPOW:
	move.b	#'/',d3

Display1D2ARGS:
	pea	(a5)
	jsr	next_expression_index
	move.l	a0,a5
	jsr	Display1DESI
	subq.w	#1,d4
	beq	Display1DError
	move.b	d3,(a4)+
	move.l	(a7),a5
	jsr	Display1DESI
	move.l	(a7)+,a5
	rts

Display1DIndex:
	move.b	#'[',d3
	bsr.s	Display1D2ARGS
	subq.w	#1,d4
	beq	Display1DError
	move.b	#']',(a4)+
	rts
		
Display1DFUNC	
	jsr	Display1DVAR		; Display Func Name
	subq.l	#1,a5
	subq.w	#1,d4
	beq	Display1DError
	move.b	#'(',(a4)+
	cmpi.b	#$E5,(a5)
	bne.s	\loop			; No argument
		subq.w	#1,d4
		beq	Display1DError
		move.b	#')',(a4)+
		rts		
\loop		cmpi.b	#$E5,(a5)
		beq.s	\End
		pea	(a5)
		jsr	Display1DESI		; Display Arg1 (Error, it is the last arg !)
		jsr	next_expression_index	; Next argument
		addq.l	#4,a7
		move.l	a0,a5
		subq.w	#1,d4
		beq	Display1DError
		move.b	#',',(a4)+
		bra.s	\loop
\End	move.b	#')',-1(a4)
	rts
	
Display1DLIST:
	subq.w	#1,d4
	beq	Display1DError			; Remove one char in buffer
	move.b	#'{',(a4)+			; Put new char 
	cmpi.b	#$E5,(a5)			; Check if there is no argument
	bne.s	\loop				; No argument
		subq.w	#1,d4
		beq	Display1DError
		move.b	#'}',(a4)+
		rts		
\loop		cmpi.b	#$E5,(a5)		; Check if LIST END
		beq.s	\End
		pea	(a5)
		jsr	Display1DESI		; Display Arg1.
		jsr	next_expression_index	; Next argument.
		addq.l	#4,a7
		move.l	a0,a5
		subq.w	#1,d4
		beq	Display1DError
		move.b	#',',(a4)+
		bra.s	\loop
\End	move.b	#'}',-1(a4)
	rts

;void NG_graphESI (CESI ptr, HANDLE Handle);	// Unused Handle
NG_graphESI:
	move.l	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	bsr.s	EvalESIandPushResult
	cmpi.b	#$23,(a6)
	beq.s	\Ok
		ER_THROW NON_REAL_RESULT_ERROR
\Ok	movem.l	(a7)+,d3-d7/a2-a6
	rts

;void NG_approxESI (CESI ptr);
;void NG_rationalESI (CESI ptr);
NG_approxESI:
NG_rationalESI:
	move.l	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	bsr.s	EvalESIandPushResult
	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
;void NG_execute (HANDLE Handle, short approx_flag); 
NG_execute:
	move.w	4(a7),d0
	movem.l	d3-d7/a2-a6,-(a7)
	move.w	d0,-(a7)
	jsr	HeapLock_redirect
	jsr	HToESI
	bsr.s	EvalESIandPushResult
	jsr	HeapUnlock_redirect
	addq.l	#2,a7
	movem.l	(a7)+,d3-d7/a2-a6
	rts

; In:
;	a0 -> ESI
EvalESIandPushResult:
	; Eval it
	move.l	a0,a5
	lea	BCDTag(Pc),a6
	bsr.s	EvalESI		; Evaluate it
	cmpi.b	#$23,(a6)
	beq.s	\PushFloat
		move.l	a6,a1
		bra	push_expr_quantun_sub
\PushFloat
	lea	FloatReg1,a0
	lea	FloatReg2+FLOAT.exponent,a1
	jsr	FloatInternal2AMS
	lea	FloatReg2+FLOAT.exponent,a1
	bra	push_Float_reg

; Evaluate an ESI.
; In:
;	a5 -> ESI
; Out:
;	a6 -> Ptr to Expr
;	if (a6).b = $23, FReg1 = The result
; Destroy:
;	All
; Note:
;	May thrown Various Error	
EvalESI:
	move.b	(a5),d0			; Read TAB
	subq.l	#1,a5
	; TODO: Make a real Jump Table ?
	tst.b	d0
	beq	EvalVAR
	cmpi.b	#$23,d0
	beq	EvalBCD
	cmpi.b	#$8B,d0
	beq	EvalPLUS
	cmpi.b	#$8D,d0
	beq	EvalMOINS
	cmpi.b	#$8F,d0
	beq	EvalMULT
	cmpi.b	#$91,d0
	beq	EvalDIV
	cmpi.b	#$93,d0
	beq	EvalPOW	
	cmpi.b	#$DA,d0
	beq	EvalFUNC
	cmpi.b	#$D9,d0			; List
	beq	EvalSTRING_LIST
	cmpi.b	#$2D,d0			; String
	beq	EvalSTRING_LIST
	cmpi.b	#$E5,d0			; End
	beq	EvalZERO
	cmpi.b	#$80,d0
	beq	EvalSTORE
	cmpi.b	#$85,d0
	beq	EvalInf
	cmpi.b	#$86,d0
	beq	EvalInfEqual
	cmpi.b	#$87,d0
	beq	EvalEqual
	cmpi.b	#$88,d0
	beq	EvalSupEqual
	cmpi.b	#$89,d0
	beq	EvalSup
	cmpi.b	#$8A,d0
	beq	EvalNotEqual
	cmpi.b	#$D5,d0
	beq	EvalIndex
	ER_THROW INVALID_COMMAND_ERROR

EvalUndef:
	lea	UndefTAG(pc),a6
	rts
	
EvalSTRING_LIST:
	lea	1(a5),a6
	rts
	
EvalZERO:
	lea	BCDTag(pc),a6
	lea	FloatZero(pc),a0
	lea	FloatReg1,a1		; FReg1 = Result
	bra	FloatAMS2Internal

EvalBCD:
	lea	BCDTag(pc),a6
	lea	-8(a5),a0		; AMS Float (May be unaligned)
	lea	FloatReg3,a1
	moveq	#9-1,d0
\loop		move.b	(a0)+,(a1)+
		dbf	d0,\loop
	clr.b	(a1)
	lea	FloatReg3,a0
	lea	FloatReg1,a1		; FReg1 = Result
	bra	FloatAMS2Internal
	
EvalVAR:
	; Check if it is Pi or E ?
	tst.b	-1(a5)
	bne.s	\NoSingleVar
		move.b	(a5),d0
		lea	FloatPi(pc),a0
		cmpi.b	#140,d0
		beq.s	\CopyVar
		lea	FloatE(Pc),a0
		cmpi.b	#150,d0
		bne.s	\NoSingleVar
\CopyVar		lea	BCDTag(pc),a6
			movem.l	(a0),d1-d3
			movem.l	d1-d3,FloatReg1
			rts
\NoSingleVar
	pea	1(a5)
	jsr	SymFindPtr_redirect
	move.l	a0,d0
	bne.s	\Ok
		ER_THROW UNDEFINED_VARIABLE_ERROR
\Ok:	
	move.w	SYM_ENTRY.hVal(a0),-(a7)
	jsr	HeapGetLock_redirect
	tst.w	d0
	beq.s	\Ok3
		ER_THROW CIRCULAR_DEFINITION_ERROR ; Fosco255:	 Bug here!!
\Ok3	jsr	HeapLock_redirect	; Lock variable
	jsr	HToESI			; Deref it
	cmpi.b	#$DC,(a0)		; Check if it is not a USER FUNC.
	beq.s	\Error
	cmpi.b	#$F3,(a0)		; Check if it is not an ASM FUNC.
	bne.s	\Ok2
\Error		ER_THROW INVALID_VARIABLE_ERROR
\Ok2	move.l	a0,a5			; We will
	jsr	EvalESI			; Evaluate ESI
	jsr	HeapUnlock_redirect
	addq.l	#2,a7
	move.l	(a7)+,a5
	rts

EvalPLUS:
	bsr.s	Eval2ARGS
	bra	FloatAdd
	
EvalMOINS:
	bsr.s	Eval2ARGS
	bra	FloatSub

EvalMULT:
	bsr.s	Eval2ARGS
	movem.l	FloatReg1,d0-d2/d3-d5
	movem.l	d0-d2/d3-d5,FloatReg3
	bra	FloatMult

EvalDIV:
	bsr.s	Eval2ARGS
	movem.l	FloatReg1,d0-d2/d3-d5
	movem.l	d3-d5,FloatReg3
	movem.l	d0-d2,FloatReg4
	bra	FloatDivide

EvalPOW:
	bsr.s	Eval2ARGS
	jmp	FloatPow

; Evaluate 2 argument
;	1st, result in FloatReg1
;	2nd, result in FloatReg2
Eval2ARGS:
	pea	(a5)
	jsr	EvalESI			; Eval 1st arg
	move.l	(a7)+,a5
	cmpi.b	#$23,(a6)		; Check if BCD
	beq.s	Eval2ARGSFloat
Eval2ArgsThrow		ER_THROW ARG_ERROR
Eval2ARGSFloat
	movem.l	FloatReg1,d0-d2
	movem.l	d0-d2,-(a7)		; Push FloatReg1
	pea	(a5)
	jsr	next_expression_index	; 2nd argument
	move.l	a0,a5
	jsr	EvalESI			; Eval 2nd argument
	move.l	(a7)+,a5
	cmpi.b	#$23,(a6)		; Check if BCD
	bne.s	Eval2ArgsThrow
	movem.l	(a7)+,d0-d2
	movem.l	d0-d2,FloatReg2		; Eval of 2nd arg in FloatReg2
	rts
	
; Evaluate 2 argument
;	1st, result in FloatReg1
;	2nd, result in FloatReg2
Eval2ARGS_strORfloat:
	pea	(a5)
	jsr	EvalESI			; Eval 1st arg
	move.l	(a7)+,a5
	cmpi.b	#$23,(a6)		; Check if BCD
	beq.s	Eval2ARGSFloat
	cmpi.b	#$2D,(a6)
	bne.s	Eval2ArgsThrow
	pea	(a6)
	pea	(a5)
	jsr	next_expression_index	; 2nd argument
	move.l	a0,a5
	jsr	EvalESI			; Eval 2nd argument
	move.l	(a7)+,a5
	cmpi.b	#$2D,(a6)		; Check if BCD
	bne.s	Eval2ArgsThrow
	move.l	(a7)+,a0
	move.l	a6,a1
	rts

EvalEqualString:
	subq.l	#1,a0
	subq.l	#1,a1
\Loop		move.b	-(a0),d0
		beq.s	\Done
		cmp.b	-(a1),d0
		beq.s	\Loop
	bra.s	CopyFloatZero
\Done	tst.b	-(a1)
	beq.s	CopyFloatOne
	bra.s	CopyFloatZero
		
EvalEqual:
	bsr.s	Eval2ARGS_strORfloat
	cmpi.b	#$2D,(a6)
	beq.s	EvalEqualString
	jsr	FloatCmp
	tst.b	d0
	beq.s	CopyFloatOne

CopyFloatZero:
	lea	FloatZero(pc),a0
	bra.s	CopyFloat
EvalNotEqual:
	bsr.s	EvalEqual
	cmpi.w	#$2000,FloatReg1+FLOAT.exponent
	bne.s	CopyFloatZero
CopyFloatOne:	
	lea	FloatOne(pc),a0
CopyFloat
	lea	FloatReg1,a1		; FReg1 = Result
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	BCDTag(pc),a6
	rts

EvalSupEqual:
	jsr	Eval2ARGS
	jsr	FloatCmp
	tst.b	d0
	bge.s	CopyFloatOne
	bra.s	CopyFloatZero
	
EvalSup:
	jsr	Eval2ARGS
	jsr	FloatCmp
	tst.b	d0
	bgt.s	CopyFloatOne
	bra.s	CopyFloatZero

EvalInfEqual:
	jsr	Eval2ARGS
	jsr	FloatCmp
	tst.b	d0
	ble.s	CopyFloatOne
	bra.s	CopyFloatZero
	
EvalInf:
	jsr	Eval2ARGS
	jsr	FloatCmp
	tst.b	d0
	blt.s	CopyFloatOne
	bra.s	CopyFloatZero

EvalFUNC:
	pea	(a5)
	jsr	SymFindPtr_redirect
	move.l	a0,d0
	bne.s	\Ok
		; Check if it is a built-in function
		\Cvt:	tst.b	-(a5)
			bne.s	\Cvt
		addq.l	#1,a5
		lea	InternalBcdFunctions,a2
		move.w	#InternalBcdFunctions_END-InternalBcdFunctions,d3
		moveq	#0,d0
		\LoopTable:
			pea	(a5)
			move.w	(a2),d0
			pea	0(a2,d0.l)
			jsr	strcmp
			addq.l	#8,a7
			tst.w	d0
			beq.s	\FindIt
			addq.l	#4,a2
			subq.l	#4,d3
			bgt.s	\LoopTable
		ER_THROW UNDEFINED_VARIABLE_ERROR
\FindIt		subq.l	#2,a5
		pea	(a2)
		jsr	EvalESI			; Eval 1st arg
		move.l	(a7)+,a2
		move.w	2(a2),d0
		jsr	0(a2,d0.w)
		move.l	(a7)+,a5
		lea	BCDTag(pc),a6			; All Built-In functions returns a BCD
		rts
\Ok:	; Skip var name
\loop		tst.b	-(a5)
		bne.s	\loop
	subq.l	#1,a5
	move.w	SYM_ENTRY.hVal(a0),-(a7)
	jsr	HeapLock_redirect	; Lock variable
	jsr	HToESI			; Deref it
;	cmpi.b	#$DA,(a0)		; Check if it is not a USER FUNC.
;	beq.s	EvalBASICFUNC
	cmpi.b	#$F3,(a0)
	beq.s	EvalASMFUNC

EvalBASICFUNC:
	ER_THROW INVALID_COMMAND_ERROR
	
EvalASMFUNC:
	move.l	top_estack,a4
	; Push the args on the EStack
	jsr	push_END_TAG
\PushLoop	cmpi.b	#$E5,(a5)
		beq.s	\Done
		cmpi.b	#$2D,(a5)
		beq.s	\PushString
			pea	(a5)
			jsr	EvalESI			; Eval 1st arg
			lea	FloatReg1,a0
			lea	FloatReg1+2,a1
			jsr	FloatInternal2AMS
			lea	FloatReg1+2,a1
			jsr	push_Float_reg		; Push Float on EStack
			jsr	next_expression_index	; 2nd argument
			addq.l	#4,a7
			move.l	a0,a5
			bra.s	\PushLoop	
\PushString:	subq.l	#1,a5
		moveq	#2,d0
\len			addq.w	#1,d0
			tst.b	-(a5)
			bne.s	\len	
		move.w	d0,-(a7)
		jsr	check_estack_size
		move.w	(a7)+,d0
		subq.w	#1,d0
		move.l	top_estack,a1
		addq.l	#1,a1
		move.l	a5,a0
\CpyLoop		move.b	(a0)+,(a1)+
			dbf	d0,\CpyLoop
		subq.l	#1,a1
		move.l	a1,top_estack
		subq.l	#1,a5
		bra.s	\PushLoop
\Done	; Appeller avec kernel__exec
	jsr	HeapUnlock_redirect
	move.w	(a7)+,d0
	jsr	KernelExec_redirect
	; Poppe la valeur de retour
	move.l	top_estack,a0
	cmpi.b	#$23,(a0)
	bne.s	\NoFloat
		lea	-9(a0),a0
		lea	FloatReg1,a1
		jsr	FloatAMS2Internal
		clr.b	FloatReg1+FLOAT.sizeof-1
		lea	BCDTag(pc),a6
\NoFloat	
	; Restaure l'EStack
	move.l	a4,top_estack
	move.l	(a7)+,a5
	rts
		
EvalSTORE:
	; Check if Arg2 is a VAR_NAME
	tst.b	(a5)
	beq.s	\Ok
		ER_THROW ARG_NAME_ERROR
\Ok	pea	(a5)
	jsr	next_expression_index
	move.l	a0,a5
	jsr	EvalESIandPushResult
	move.l	(a7),a5
	move.l	top_estack,-(a7)	; ESI 
	clr.w	-(a7)			; Size (Not used...)
	move.w	#STOF_ESI,-(a7)		; Flag
	pea	(a5)			; Var Name
	jsr	VarStore		; Store Val
	lea	12(a7),a7
	move.l	(a7)+,a5
	rts

EvalIndex:
	; Format is: $E5,0,indice,0,0,list,0,$D5
	tst.b	(a5)			; Check if ListName is a VAR_NAME
	beq.s	\Ok
		ER_THROW ARG_NAME_ERROR
\Ok	pea	(a5)
	jsr	SymFindPtr_redirect		; Search ListName
	move.l	a0,d0
	bne.s	\Ok2
		ER_THROW UNDEFINED_VARIABLE_ERROR
\Ok2	move.w	SYM_ENTRY.hVal(a0),(a7)
	jsr	HeapLock_redirect
	jsr	HToESI			; Deref it
	cmpi.b	#$D9,(a0)		; Check if it is a list
	beq.s	\loop
		ER_THROW ARG_ERROR
\loop		tst.b	-(a5)		; Skip var name to get indice
		bne.s	\loop
	pea	-1(a0)			; Push 1st element of List ESI
	subq.l	#1,a5
	jsr	EvalESI			; Eval Indice
	cmpi.b	#$23,(a6)		; Check if BCD
	beq.s	\Ok4
		ER_THROW NON_REAL_RESULT_ERROR
\Ok4	jsr	Float2Int		; Eval Int
	move.l	(a7)+,a0		; Pop List ESI
	move.w	d0,d3			; Get element d3 of the List
\SkipLoop	cmpi.b	#$E5,(a0)	; End Tag ?
		beq.s	\end
		subq.w	#1,d3
		beq.s	\end
		jsr	next_expression_index_reg
		bra.s	\SkipLoop
\end	move.l	a0,a5
	jsr	EvalESI
	jsr	HeapUnlock_redirect
	addq.l	#4,a7
	rts
	
;short are_expressions_identical (CESI ptr1, CESI ptr2); 
are_expressions_identical:
	move.l	8(a7),a0
	jsr	next_expression_index_reg
	move.l	a0,d0
	sub.l	8(a7),d0		; Size
	pea	(a0)			; Push a0
	move.l	8(a7),a0
	jsr	next_expression_index_reg	
	move.l	(a7)+,a1		; Reload old ptr
	move.l	a0,d1
	sub.l	4(a7),d1		; Size
	cmp.l	d0,d1
	bne.s	\Different
		jsr	memcmp_reg
		tst.w	d0
\Different
	seq.b	d0
	ext.w	d0
	rts
		
BCDTag:		dc.b	$23
UndefTAG:	dc.b	$2A

; short all_tail (CESI_Callback_t f, ESI start_ptr);
all_tail:
	movem.l	a2-a3,-(a7)
	move.l	12(a7),a2	; Callback
	move.l	16(a7),a3	; Start
	bra.s	\check
\Loop		pea	(a3)
		jsr	(a2)	; Callback
		tst.w	d0
		beq.s	\Final
		jsr	next_expression_index
		addq.l	#4,a7
		move.l	a0,a3
\check		cmpi.b	#$E5,(a3)
		bne.s	\Loop
	moveq	#1,d0
\Final	movem.l	(a7)+,a2-a3
	rts

; short any_tail (CESI_Callback_t f, ESI start_ptr);
any_tail:
	movem.l	a2-a3,-(a7)
	move.l	12(a7),a2	; Callback
	move.l	16(a7),a3	; Start
	bra.s	\check
\Loop		pea	(a3)
		jsr	(a2)	; Callback
		tst.w	d0
		bne.s	\Final
		jsr	next_expression_index
		addq.l	#4,a7
		move.l	a0,a3
\check		cmpi.b	#$E5,(a3)
		bne.s	\Loop
	moveq	#0,d0
\Final	movem.l	(a7)+,a2-a3
	rts

;ESI last_element_index (CESI ptr);
last_element_index:
	pea	(a2)
	move.l	8(a7),a2
	cmpi.b	#$E5,(a2)
	beq.s	\Final
	move.l	a2,a0
\Loop		move.l	a0,a2
		jsr	next_expression_index_reg
		cmpi.b	#$E5,(a0)
		bne.s	\Loop
\Final	move.l	a2,a0
	move.l	(a7)+,a2
	rts
