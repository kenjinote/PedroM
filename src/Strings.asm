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
        xdef STRINGS
        xdef Pedrom_str
        xdef Author_str
        xdef HeapCorrupted_str
        xdef InitError_str
        xdef Boot_str
        xdef TIBInstallError_str
        xdef WrongCalc_str
        xdef Error_str
        xdef UnkwowError_str
        xdef ArgumentError_str
        xdef ArgumentNameError_str
        xdef BreakError_str
        xdef FolderError_str
        xdef MemoryError_str
        xdef SyntaxError_str
        xdef TooFewError_str
        xdef TooManyError_str
        xdef DuplicateError_str
        xdef Variable8Error_str
        xdef LinkTransmission_str
        xdef TimeOut_str
        xdef MIDError_str
        xdef VARError_str
        xdef CIDError_str
        xdef LFormatError_str
        xdef LinkReset_str
        xdef LinkBufferFull_str
        xdef LinkProgress_str
        xdef UndefinedVariable_str
        xdef CircularDefinition_str
        xdef InvalidVariable_str
        xdef InvalidCommand_str
        xdef NonRealResult_str
        xdef VarInUse_str
        xdef KernelMessageError
        xdef errortext
        xdef CommandNotFound_str
        xdef StartScript_sym
        xdef StdLib_sym
        xdef ScriptArgs_sym
        xdef Path_sym
        xdef FKeyFormat_str
        xdef APD_str
	xdef FONT_str
        xdef Confirmation_str
        xdef Dir1_str
        xdef Main_str
        xdef Home_str
        xdef SystemFolder_str
        xdef Dir2_str
        xdef LsLong1_str
        xdef LsLong2_str
        xdef CommandDisp_str
        xdef Shell_str
        xdef Return_str
        xdef MemDisplay_str
        xdef ON_str
        xdef OFF_str
        xdef PID_status
        xdef PID_string
        xdef PID_KillProcess
        xdef ShellInput_str
        xdef FlagsDisplay_str
        xdef Stdin_str
        xdef Arg1_str
        xdef Arg2_str
        xdef Failed_str
        xdef ArgNumber_str
        xdef TempFolder_str
        xdef SerrNo_str
        xdef FloatFormat_str
        xdef LongFormat_str
        xdef String_str
        xdef All_str
        xdef ProductID_str
        xdef HexFormat_str
        xdef ByteFormat_str
        xdef CleanFreeHandle_str
        xdef ST_refDsp_str
        xdef ST_StrA
        xdef AppsDialogTitle
        xdef AppsText
        xdef HelpKeyTitle
        xdef HelpKeysText
        xdef HelpKeysText
        xdef Ln_XRstr
        xdef Exp_XRstr
        xdef Sin_XRstr
        xdef Cos_XRstr
        xdef Tan_XRstr
        xdef ASin_XRstr
        xdef ACos_XRstr
        xdef ATan_XRstr
        xdef Sqrt_XRstr
        xdef Int_XRstr
        xdef Der_XRstr
        xdef Sigma_XRstr
        xdef Inv_XRstr
        xdef Ans_XRstr
        xdef ReleaseVersion
        xdef ReleaseDate
        xdef ST_busy_str
        xdef ST_pause_str
        xdef ST_batt_str
        xdef ST_none_str
        xdef ST_2nd_str
        xdef ST_shift_str
        xdef ST_diamond_str
        xdef ST_alpha_str
        xdef ST_alphaLock_str
        xdef ST_SalphaLock_str

STRINGS:

Pedrom_str:	dc.b	"PedroM v"
		dc.l	PEDROM_STR_VERSION
		include "version.h"
		dc.b	0
Author_str:	dc.b	10,169," 2003-2009 Patrick Pélissier",10,0

HeapCorrupted_str:	dc.b	"Corrupted Heap",0
InitError_str:	dC.b	"Booting error",0
Boot_str:	dc.b	"Boot missing",0
TIBInstallError_str:	dc.b	"INSTALL FAILED",0
WrongCalc_str:	dc.b	"WRONG CALCULATOR",0

Error_str:	dc.b	"Error",0
UnkwowError_str:	dc.b	"Unkwown error",0
ArgumentError_str:	dc.b	"Arg error",0
ArgumentNameError_str:	dc.b	"Arg must be a var-name",0
BreakError_str:	dc.b	"Break",0
FolderError_str:	dc.b	"Folder",0
MemoryError_str:	dc.b	"Memory",0
SyntaxError_str:	dc.b	"Syntax",0
TooFewError_str:	dc.b	"Too few args",0
TooManyError_str:	dc.b	"Too many args",0
DuplicateError_str:	dc.b	"Duplicate var-name",0
Variable8Error_str:	dc.b	"Var-name is invalid",0
LinkTransmission_str:	dc.b	"Link transmission",0
TimeOut_str:	dc.b	"Link: Time Out",0
MIDError_str:	dc.b	"Link: MID?",0
VARError_str:	dc.b	"Link: VAR?",0
CIDError_str:	dc.b	"Link: Command?",0
LFormatError_str:	dc.b	"Link: Format",0
LinkReset_str:	dc.b	"Link: Reset",0
LinkBufferFull_str:	dc.b	"Link: Buffer full",0
LinkProgress_str:	dc.b	"Link in progress...",0
UndefinedVariable_str:	dc.b	"Undefined var",0
CircularDefinition_str:	dc.b	"Circular Definition",0
InvalidVariable_str:	dc.b	"Invalid var",0
InvalidCommand_str:	dc.b	"Invalid Command",0
NonRealResult_str:	dc.b	"Non real result",0
VarInUse_str:	dc.b	"Var in use",0

KernelMessageError:
		dc.b	"Panick",0
errortext:	dc.b	"Crash intercepted",0
		dc.b	"Lib %s not found",0
		dc.b	"Wrong Lib %s",0
		dc.b	"Wrong Kernel",0
		dc.b	"Wrong Rom",0
		dc.b	"Corrupted program",0
		dc.b	"%s isn't a kernel lib",0
		dc.b	"Not a program",0
	
CommandNotFound_str:	dc.b	"Error (%s)",10,0

			dc.b	"system\start"
StartScript_sym:	dc.b	0
			dc.b	"system\stdlib"
StdLib_sym:	dc.b	0
			dc.b	"system\args"
ScriptArgs_sym:	dc.b	0
			dc.b	"system\path"
Path_sym:	dc.b	0

FKeyFormat_str:	dc.b	"fkey%d",0
APD_str:	dc.b	"apd",0
FONT_str:	dc.b	"font",0
	
Confirmation_str:	dc.b	"Are you sure?",10," Write 'yes' to confirm:",0
Dir1_str:	dc.b	"Directory of '%s'",10,0
Main_str:	dc.b	"main",0
Home_str:	dc.b	"home",0
SystemFolder_str:	dc.b	"system",0
Dir2_str:	dc.b	10," %d file(s)",10,0
LsLong1_str:	dc.b	" NAME",9,"SIZE",9,"FLAG TYPE",9,"Ptr",10,0
LsLong2_str:	dc.b	"%8.8s",9,"%5.5u",9,"%4.4X  %2.2X",9,"%p",10,0
CommandDisp_str:	dc.b	"%9.9s",9,0
Shell_str:	dc.b	":>",0
Return_str:	dc.b	10,0
MemDisplay_str:	dc.b	"RAM Free:",9,9,"%6.6ld",10
			dc.b	"Flash ROM Free:",9,"%7.7ld",10,0
ON_str:	dc.b	"ON",0
OFF_str:	dc.b	"OFF",0
PID_status:	dc.b	"%%=%u",10,"PID",9,"size",9,"name",10,0
PID_string:	dc.b	"%d",9,"%ld",9,"%s",10,0
PID_KillProcess:	dc.b	"Kill: %s",10,0
ShellInput_str:	dc.b	"Shell",0
FlagsDisplay_str:	dc.b	"%s ",9,"%s",10,0
Stdin_str:	dc.b	"stdin",0

Arg1_str:	dc.b	"Arg: filename(s)",10,0
Arg2_str:	dc.b	"Arg: SrcFile DestFile",10,0
Failed_str:	dc.b	" %s:failed",10,0
ArgNumber_str:	dc.b	"Arg: number",10,0

TempFolder_str:	dc.b	"%04d",0
SerrNo_str:	dc.b	"%08lX %02X ????",0
FloatFormat_str:	dc.b	"%f",0
LongFormat_str:	dc.b	"%ld",0
String_str:	dc.b	"%s",0
All_str:	dc.b	"all",0	


ProductID_str:	dc.b	"%02lX-%lX-%lX-%lX",0
HexFormat_str:	dc.b	"%06lX: %02X %02X %02X %02X %02X %02X %02X %02X",10,0
ByteFormat_str:	dc.b	"%02X ",0

CleanFreeHandle_str:	dc.b	"Free %d handle(s)",10,0

ST_refDsp_str:		dc.b	"USE LEFT, RIGHT, UP, DOWN, ENTER and CANCEL"
ST_StrA:	dc.b	0

AppsDialogTitle:	dc.b	"APPLICATIONS & MODE",0
AppsText:	dc.b	"APPS/MODE menu not implemented.",10,"Wait for next release.",0

HelpKeyTitle:	dc.b	"Help Keys",0
	ifd	PEDROM_92
HelpKeysText:	dc.b	"Q[?] W[!] E[é] R[@] T[#]",10
		dc.b	"Y[",18,"] U[",252,"] I[",151,"] O[",244,"] P[_]",10
		dc.b	"A[",224,"] S[",223,"] D[",176,"] F[",159,"] G[",128,"]",10
		dc.b	"H[&] J[",190,"] K[|] L[",34,"]",10
		dc.b	"Z[CAPS] X[",169,"] C[",231,"] V[",157,"]",10
		dc.b	"B['] N[~] M[;] ",136,"[:]",10
		dc.b	"' '[$]",0
	endif		
	ifd	PEDROM_89
HelpKeysText:	dc.b	"=[",157,"]",10
		dc.b	")[",169,"]",10
		dc.b	"/[!]",10
		dc.b	"*[&] ->[@]",0		
	endif
	; LN / EXP / SIN / COS/ TAN / ASIN / ACOS/ATAN / SQRT / INTEGRAL / DERIVATE / Sigma / -1 / ANS
Ln_XRstr:	dc.b	"ln(",0
Exp_XRstr:	dc.b	"exp(",0
Sin_XRstr:	dc.b	"sin(",0
Cos_XRstr:	dc.b	"cos(",0
Tan_XRstr:	dc.b	"tan(",0
ASin_XRstr:	dc.b	"sin",180,"(",0
ACos_XRstr:	dc.b	"cos",180,"(",0
ATan_XRstr:	dc.b	"tan",180,"(",0
Sqrt_XRstr:	dc.b	168,"(",0
Int_XRstr:	dc.b	189,"(",0
Der_XRstr:	dc.b	188,"(",0
Sigma_XRstr:	dc.b	142,"(",0
Inv_XRstr:	dc.b	"^-1",0
Ans_XRstr:	dc.b	"ans(1)",0

; Vti version number
		EVEN
ReleaseVersion:	dc.l	PEDROM_STR_VERSION
		dc.b	0
ReleaseDate:	dc.b	"06/14/2005",0

ST_busy_str:	dc.b	"BUSY",0
ST_pause_str:	dc.b	"STOP",0
ST_batt_str:	dc.b	"BATT",0
ST_none_str:	dc.b	"           ",0
ST_2nd_str:	dc.b	" 2ND   ",0
ST_shift_str:	dc.b	"SHIFT ",0
ST_diamond_str:	dc.b	" 3RD   ",0
ST_alpha_str:	dc.b	"ALPHA",0	
ST_alphaLock_str:	dc.b	"ALOCK",0
ST_SalphaLock_str:	dc.b	"SALCK",0

	EVEN
