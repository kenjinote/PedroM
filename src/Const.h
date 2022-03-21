;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003, 2004, 2005-2008, 2010 Patrick Pelissier
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
    ifnd PEDROM

PEDROM_VERSION		EQU	$0083
PEDROM_DEC_VERSION	EQU	(0*100+83)
PEDROM_STR_VERSION	EQU	'0.83'

DEBUG_ER_THROW		EQU	0

**********************************************************/
; Define it for conditionnal compilation with preos source code
PEDROM			     EQU	1			; PedroM Build
FLASH_CODE		     EQU	1			; Code resides in Flash
WANT_REENTRANT_UNRELOCATION  EQU	1			; We can mix unreloc/run/reloc in a random order
								; due to multiple process

**********************************************************/
	ifd	TI92P
PEDROM_92		EQU	1			; 92+ like (Screen and keys)
_ti92plus		xdef	_ti92plus		; Target is a 92+
CALC_BOOT_TYPE		EQU	1			; Value of calculator inside the bootcode
CALC_KERNEL_TYPE	EQU	1			; Value of calculator for the shared linker
CALC_FLAG               EQU     0                       ; BitFlag of Kernel Programs designed for calculator
DEVICE_LINK_ID		EQU	$88			; Value of calculator for the link device
ROM_BASE		EQU	$400000			; Rom Base
ROM_SIZE		EQU	$200000			; Rom Size
GHOST_SPACE		EQU	$40000			; Mirror of the RAM
PEDROM_89_92            EQU     1                       ; Defined for TI 89 and TI 92+
	endif
	ifd	TI89
PEDROM_89		EQU	1			; 89 like (Screen and keys)
_ti89			xdef	_ti89			; Target is a 89
CALC_BOOT_TYPE		EQU	3			; Value of calculator inside the bootcode
CALC_KERNEL_TYPE	EQU	0			; Value of calculator for the shared linker
CALC_FLAG               EQU     1                       ; BitFlag of Kernel Programs designed for calculator
DEVICE_LINK_ID		EQU	$98			; Value of calculator for the link device
ROM_BASE		EQU	$200000			; Rom Base
ROM_SIZE		EQU	$200000			; Rom size
GHOST_SPACE		EQU	$40000			; Mirror of the RAM
PEDROM_89_92            EQU     1                       ; Defined for TI 89 and TI 92+
	endif
	ifd	V200
PEDROM_92		EQU	1			; 92+ like
_v200			xdef	_v200			; Target is a V200
CALC_BOOT_TYPE		EQU	8			; Value of calculator inside the bootcode
CALC_KERNEL_TYPE	EQU	3			; Value of calculator for the shared linker
CALC_FLAG               EQU     5                       ; BitFlag of Kernel Programs designed for calculator
DEVICE_LINK_ID		EQU	$88			; Value of calculator for the link device
ROM_BASE		EQU	$200000			; Rom base
ROM_SIZE		EQU	$400000			; Rom size
GHOST_SPACE		EQU	$40000			; Mirror of the RAM
PEDROM_89_92            EQU     0                       ; Defined for TI 89 and TI 92+
	endif
	ifd	TI89TI
PEDROM_89		EQU	1			; 89 like
_ti89ti			xdef	_ti89ti			; Target is 89 Titanium
CALC_BOOT_TYPE		EQU	9			; Value of calculator inside the bootcode
CALC_KERNEL_TYPE	EQU	-1			; Value of calculator for the shared linker
CALC_FLAG               EQU     6                       ; BitFlag of Kernel Programs designed for calculator
DEVICE_LINK_ID          EQU     $98 			; Value of calculator for the link device
ROM_BASE		EQU	$800000			; Rom Base
ROM_SIZE		EQU	$400000			; Rom size
GHOST_SPACE		EQU	$200000			; Mirror of the RAM
PEDROM_89_92            EQU     0                       ; Defined for TI 89 and TI 92+
	endif


**********************************************************
	ifd	PEDROM_89
IS89_0_2		EQU	0
KEY_ESC_ROW		EQU	%0111111
KEY_ESC_COL		EQU	0
KEY_APPS_ROW		EQU	%1011111
KEY_APPS_COL		EQU	0
KEY_NBR_ROW		EQU	7	; 10 for 92+/v200, 7 for 89
KEY_INIT_MASK		EQU	$FFBF	; $FDFF for 92+/89 $FFBF for 89
RESET_KEY_STATUS_MASK	EQU	$0F
SCR_WIDTH		EQU	160
SCR_HEIGHT		EQU	100
USED_FONT		EQU	0	; Small Font for dialog
TAB_SIZE		EQU	40
	endif
	ifd	PEDROM_92
IS89_0_2		EQU	2
KEY_ESC_ROW		EQU	%1011111111
KEY_ESC_COL		EQU	6
KEY_APPS_ROW		EQU	%1101111111
KEY_APPS_COL		EQU	6
KEY_NBR_ROW		EQU	10	; 10 for 92+/v200, 7 for 89
KEY_INIT_MASK		EQU	$FDFF	; $FDFF for 92+/89 $FFBF for 89
RESET_KEY_STATUS_MASK	EQU	$F0
SCR_WIDTH		EQU	240
SCR_HEIGHT		EQU	128
USED_FONT		EQU	1	; Normal Font for dialog
TAB_SIZE		EQU	60
	endif


**********************************************************
SSP_INIT		EQU	$4C00			; Initial Supervisor stack value
USP_INIT		EQU	$4400			; Initial User stack value

**********************************************************
MAX_PROCESS		EQU	32
PID_SAVE_LCD_MEM	EQU	1
PID_SAVE_AUTOINTS	EQU	2
PID_SAVE_VECTORS	EQU	4
PID_SAVE_IO		EQU	8

**********************************************************
LCD_MEM		EQU	$4C00

HugeFont	EQU	MediumFont+$E00
SmallFont	EQU	MediumFont+$800

A_REVERSE	EQU	0
A_NORMAL	EQU	1
A_XOR		EQU	2
A_AND		EQU	3	; A_SHADED
A_REPLACE	EQU	4
A_OR		EQU	5

ST_Y		EQU	SCR_HEIGHT-7
ST_FOLDER_X	EQU	0
ST_FOLDER_MOD	EQU	40
ST_FOLDER_STAT	EQU	SCR_WIDTH-21

WINDOW_WIDTH	EQU	150+USED_FONT*10
WINDOW_HEIGHT	EQU	70
WINDOW_X	EQU	(SCR_WIDTH-WINDOW_WIDTH)/2
WINDOW_Y	EQU	(SCR_HEIGHT-WINDOW_HEIGHT)/2
WINDOW_MAX_WIDTH	EQU	SCR_WIDTH-10

CURSOR_SIZE	EQU	1+USED_FONT*2

**********************************************************
; Timer struct
;	BYTE : Type equ Vector / CountDown / Free
;	BYTE : ??
;	LONG : Reset Value
;	LONG : Current Value
;	void*: CallBack
TIMER_TYPE	EQU	0
TIMER_RESET_VAL	EQU	2
TIMER_CUR_VAL	EQU	6
TIMER_CALLBACK	EQU	10
TIMER_SIZE	EQU	14

TIMER_NUMBER	EQU	6

TIMER_TYPE_COUNT	EQU	1
TIMER_TYPE_VECTOR	EQU	2

; Minimum and maximum values for APD (AutoPowerDown) in seconds.
APD_MIN		EQU	10
APD_MAX         EQU     1000
APD_DEFAULT     EQU     100

BATT_TIMER_ID   EQU     1
APD_TIMER_ID    EQU     2
LIO_TIMER_ID    EQU     3
CURSOR_TIMER_ID EQU     4

BATT_TIMER_VALUE EQU 5*20
LIO_TIMER_VALUE  EQU 6*20
CURSOR_TIMER_VALUE EQU 5

**********************************************************
KEY_MAX	EQU	20

	ifd	PEDROM_92
KEY_LEFT	EQU	337
KEY_UP		EQU	338
KEY_RIGHT	EQU	340
KEY_DOWN	EQU	344
KEY_CATALOG	EQU	4146
	endif
	ifd	PEDROM_89
KEY_LEFT	EQU	338
KEY_UP		EQU	337
KEY_RIGHT	EQU	344
KEY_DOWN	EQU	340
KEY_CATALOG	EQU	$116
	endif
KEY_VOID	EQU	0
KEY_ENTER	EQU	13
KEY_THETA	EQU	136
KEY_SIGN	EQU	173
KEY_BACK	EQU	257
KEY_STO		EQU	22	; Original Key code is 258
KEY_COS		EQU	260
KEY_TAN		EQU	261
KEY_LN		EQU	262
KEY_CLEAR	EQU	263
KEY_ESC		EQU	264
KEY_APPS	EQU	265
KEY_MODE	EQU	266
KEY_F1		EQU	268
KEY_F2		EQU	269
KEY_F3		EQU	270
KEY_F4		EQU	271
KEY_F5		EQU	272
KEY_F6		EQU	273
KEY_F7		EQU	274
KEY_F8		EQU	275
KEY_SIN		EQU	259
KEY_INS		EQU	4353
KEY_ON		EQU	267
KEY_OFF		EQU	4363
KEY_OFF2	EQU	16651
KEY_QUIT	EQU	4360
KEY_SWITCH	EQU	4361
KEY_VARLINK	EQU	4141
KEY_CHAR	EQU	4139
KEY_ENTRY	EQU	4109
KEY_RCL		EQU	4354
KEY_MATH	EQU	4149
KEY_MEM		EQU	4150
KEY_ANS		EQU	4372
KEY_CUSTOM	EQU	4147
KEY_UNITS	EQU	4400
KEY_2ND		EQU	$1000
KEY_DIAMOND	EQU	$2000
KEY_SHIFT	EQU	$4000
KEY_HAND	EQU	$8000
KEY_ALPHA	EQU	$8000

KEY_INFEQUAL	EQU	156
KEY_DIFERENT	EQU	157
KEY_SUPEQUAL	EQU	158

KEY_EE		EQU	149
KEY_HOME	EQU	$115
KEY_OR		EQU	124

KEY_AUTO_REPEAT	EQU	$0800

	ifd	PEDROM_89
HELPKEYS_KEY		EQU	KEY_DIAMOND|KEY_EE
	endif
	ifd	PEDROM_92
HELPKEYS_KEY		EQU	KEY_DIAMOND|'k'
	endif

LINE_FEED	EQU	13

KEY_INIT_BETWEEN_KEY_DELAY EQU 24
KEY_INIT_KEY_INIT_DELAY EQU 130


**********************************************************
HANDLE_MAX	EQU	2000

**********************************************************
SYM_ENTRY.name equ 0
SYM_ENTRY.compat equ 8
SYM_ENTRY.flags equ 10
SYM_ENTRY.hVal equ 12
SYM_ENTRY.sizeof equ 14

SF_GREF1 equ $0001
SF_GREF2 equ $0002 
SF_STATVAR equ $0004 
SF_LOCKED equ $0008 
SF_HIDDEN equ $0010 
SF_OPEN equ $0010 
SF_CHECKED equ $0020 
SF_OVERWRITTEN equ $0040 
SF_FOLDER equ $0080 
SF_INVIEW equ $0100 
SF_ARCHIVED equ $0200 
SF_TWIN equ $0400 
SF_COLLAPSED equ $0800 
SF_LOCAL equ $4000 
SF_BUSY equ $8000

FOLDER_LIST_HANDLE	EQU	8		; To be compatible with AMS 1.0x
MAIN_LIST_HANDLE	EQU	9		; To be compatible with AMS 1.0x

FO_SINGLE_FOLDER	EQU	$01
FO_RECURSE 		EQU	$02
FO_SKIP_TEMPS		EQU	$04
FO_RETURN_TWINS 	EQU	$08
FO_RETURN_FOLDER 	EQU	$10
FO_SKIP_COLLAPSE 	EQU	$20

STOF_ESI		EQU	$4000
STOF_ELEMENT		EQU	$4001
STOF_NONE		EQU	$4002
STOF_HESI		EQU	$4003

**********************************************************
ESTACK_SIZE		EQU	700			; Fixed size of the EStack
ESTACK_HANDLE		EQU	1			; Handle of the EStack

**********************************************************
END_ARCHIVE		EQU	ROM_BASE+ROM_SIZE	; End of the archive memory

; Description of an archive entry in the archive memory.
ARC_ENTRY.status	EQU	-20			; Status (ARC_ST type)
ARC_ENTRY.folder	EQU	-18			; Folder name (8 bytes)
ARC_ENTRY.name		EQU	-10			; Entry name (8 bytes)
ARC_ENTRY.checksum	EQU	-2			; Checksum of the entry
ARC_ENTRY.file		EQU	0			; The file itself
ARC_ENTRY.HeaderSize	EQU	20			; Size of the header of an entry

ARC_ST_VOID		EQU	$FFFF			; Unused entry
ARC_ST_WRITTING         EQU     $FFFE                   ; Entry currently written
ARC_ST_INUSE		EQU	$FFFC			; Used entry
ARC_ST_DELETED		EQU	$FFF8			; Deleted entry

APP_UNUSED_BSS_SIZE	EQU	4

ARG_MAX			EQU	35

CertificateMemory	EQU	ROM_BASE+$10000
FlashMemoryEnd		EQU	END_ARCHIVE

**********************************************************
QUEUE.head		EQU	0
QUEUE.tail		EQU	2
QUEUE.size		EQU	4
QUEUE.used		EQU	6
QUEUE.data		EQU	8

LINK_QUEUE.sizeof	EQU	250
LINK_MAX_WAIT		EQU	10*20		; 10s max.

PACKET.mid		EQU	0
PACKET.cid		EQU	1
PACKET.len		EQU	2
PACKET.data		EQU	4

CID_VAR			EQU	$06 	; Includes a std variable header (used in receiving)
CID_CTS			EQU	$09 	; Used to signal OK to send a variable               |
CID_XDP			EQU	$15 	; Xmit Data Packet (pure data)                       |
CID_VER                 EQU     $2D     ; Getting OS & BIOS version                          |
CID_SKIP		EQU	$36 	; Skip/exit - used when duplicate name is found      |
CID_ACK			EQU	$56 	; Acknowledgment                                     |
CID_ERR			EQU	$5A	; Checksum error: send last packet again             |
CID_RDY			EQU	$68 	; Check whether TI is ready                          |
CID_SCR			EQU	$6D 	; Request screenshot                                 |
CID_CON                 EQU     $78     ; Continue something...                              |
CID_CMD			EQU	$87 	; direct CMD | Direct command (for remote control for instance)   |
CID_DEL                 EQU     $88     ; Variable delete command
CID_EOT			EQU	$92 	; EOT/DONE   | End Of Transmission: no more variables to send     |
CID_REQ			EQU	$A2 	; Request variable - includes a standard variable    |
CID_RTS			EQU	$C9	; Request to send - includes a padded variable header|

TY_NORMAL		EQU	$1D	;
TY_LOCKED		EQU	$26	;
TY_ARCHIVED		EQU	$27	;

FILE_SIZE		EQU	10	; sizeof(FILE)
MAX_FILES		EQU	10	; Must be changed in PedroM internal too!

**********************************************************
WINDOW.Flags		EQU	0	;/* Window flags */ 
WINDOW.CurFont		EQU	2	; unsigned char CurFont; /* Current font */ 
WINDOW.CurAttr		EQU	3	; unsigned char CurAttr; /* Current attribute */ 
WINDOW.Background	EQU	4	; unsigned char Background; /* Current background attribute */ 
WINDOW.TaskId		EQU	6	; short TaskId; /* Task ID of owner */ 
WINDOW.CurX		EQU	8	; short CurX
WINDOW.CurY		EQU	10	; short CurY; /* Current (x,y) position (relative coordinates) */ 
WINDOW.CursorX		EQU	12	; short CursorX
WINDOW.CursorY		EQU	14	; short CursorY; /* Cursor (x,y) position */ 
WINDOW.Client		EQU	16	; SCR_RECT Client; /* Client region of the window (excludes border) */ 
WINDOW.Window		EQU	20	; SCR_RECT Window; /* Entire window region including border */ 
WINDOW.Clip		EQU	24	; SCR_RECT Clip; /* Current clipping region */ 
WINDOW.Port		EQU	28	; SCR_RECT Port; /* Port region for duplicate screen */ 
WINDOW.DupScr		EQU	34	; unsigned short DupScr; /* Handle of the duplicated or saved screen area */ 
WINDOW.Next		EQU	36	; struct WindowStruct *Next; /* Pointer to the next window in the linked list */ 
WINDOW.Title		EQU	40	; char *Title; /* Pointer to the (optional) title */ 
WINDOW.savedScrState	EQU	44	; SCR_STATE savedScrState; /* Saved state of the graphics system */ 
WINDOW.Screen		EQU	48	; 

WF_SAVE_SCR		EQU	$10
WF_DUP_SCR		EQU	$20
WF_TTY			EQU	$40
WF_NOBOLD		EQU	$200
WF_NOBORDER		EQU	$100
WF_ROUNDEDBORDER	EQU	$8
WF_TITLE		EQU	$1000
WF_BLACK		EQU	$800

;WF_VIRTUAL		EQU	$800	; Not supported

WF_SYS_ALLOC EQU $0001
WF_STEAL_MEM EQU $0002
WF_DONT_REALLOC EQU $0004
WF_ACTIVE EQU $0080
WF_DUP_ON EQU $0400
WF_DIRTY EQU $2000
WF_TRY_SAVE_SCR EQU $4010
WF_VISIBLE EQU $8000

**********************************************************
MAX_TASKID		EQU	1	; ??

CM_IDLE		EQU	$700
CM_INIT		EQU	$701
CM_STARTTASK	EQU	$702
CM_ACTIVATE	EQU	$703
CM_FOCUS	EQU	$704
CM_UNFOCUS	EQU	$705
CM_DEACTIVATE	EQU	$706
CM_ENDTASK	EQU	$707
CM_START_CURRENT	EQU	$708
CM_KEYPRESS	EQU	$710
CM_MENU_CUT	EQU	$720
CM_MENU_COPY	EQU	$721
CM_MENU_PASTE	EQU	$722
CM_STRING	EQU	$723
CM_HSTRING	EQU	$724
CM_DEL		EQU	$725
CM_CLEAR	EQU	$726
CM_MENU_CLEAR	EQU	$727
CM_MENU_FIND	EQU	$728
CM_INSERT	EQU	$730
CM_BLINK	EQU	$740
CM_STORE	EQU	$750
CM_RECALL	EQU	$751
CM_WPAINT	EQU	$760
CM_MENU_OPEN	EQU	$770
CM_MENU_SAVE_AS	EQU	$771
CM_MENU_NEW	EQU	$772
CM_MENU_FORMAT	EQU	$773
CM_MENU_ABOUT	EQU	$774
CM_MODE_CHANGE	EQU	$780
CM_SWITCH_GRAPH	EQU	$781
CM_GEOMETRY	EQU	$7C0

**********************************************************
FLOAT.sign	EQU	0
FLOAT.exponent	EQU	2 	; $2000 < expo < $6000
FLOAT.mantissa	EQU	4
FLOAT.sizeof	EQU	12

BCD.exponent	EQU	0
BCD.mantissa	EQU	2

**********************************************************
SHELL_MAX_LINE			EQU	60
SHELL_HISTORY			EQU	10
SHELL_MAX_PATH			EQU	30

SHELL_AUTO_CHAR			EQU	';'
SCRIPT_COMMENT_CHAR		EQU	'#'
SCRIPT_VARIABLE_CHAR		EQU	'$'
SCRIPT_RETURN_CHAR		EQU	13
SCRIPT_OPEN_BLOCK_CHAR		EQU	'<'
SCRIPT_CLOSE_BLOCK_CHAR		EQU	'>'

SHELL_AUTO_ARCHIVE_FILE_FLAG	EQU	0

PROGRAM_MAX_ATEXIT_FUNC		EQU	10

**********************************************************
DialogSigna			EQU	0	; 4
DialogCallBack			EQU	4	; void *
DialogMenu			EQU	8	; HANDLE
DialogButton			EQU	10	; BYTE / BYTE
DialogSize			EQU	12	; Start of Dialog Struct
DialogSignature			EQU	'DiAl'

POPUP_WIDTH			EQU	98
POPUP_HEIGHT			EQU	50
PMENU_HEIGHT			EQU	70

**********************************************************
ER_THROW	MACRO
	dc.w	$A000+\1
		ENDM
ER_throw	MACRO
	dc.w	$A000+\1
		ENDM

ARG_ERROR			EQU	40
ARG_NAME_ERROR			EQU	140
BREAK_ERROR			EQU	180
CIRCULAR_DEFINITION_ERROR	EQU	190
DUPLICATE_ERROR			EQU	270
FOLDER_ERROR			EQU	330
INVALID_COMMAND_ERROR		EQU	410
INVALID_VARIABLE_ERROR		EQU	620
LINK_TRANSMISSION_ERROR		EQU	650
MEMORY_ERROR			EQU	670
NON_REAL_RESULT_ERROR		EQU	800
SYNTAX_ERROR			EQU	910
TOO_FEW_ARGS_ERROR		EQU	930
TOO_MANY_ARGS_ERROR		EQU	940
UNDEFINED_VARIABLE_ERROR	EQU	960
VARIABLE_IN_USE_ERROR		EQU	970
VARIABLE_IS_8_LIMITED_ERROR	EQU	990

NO_ERROR			EQU	999

; Miss 980

**************************************************************
TIB_EXEC		EQU	$10000			; Where to copy the TIB install code in RAM
TIB_SMALL		EQU	$20000			; First used buffer in RAM by TIB installer
TIB_LARGE		EQU	$24004			; Second used buffer in RAM by TIB Installer

**************************************************************

**************************************************************
	include "Vars.h"		; Global vars
	include "kheader.h"		; Kernel Header (Preos source code)

    ENDIF
