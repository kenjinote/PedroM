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
        xdef License_str
	xdef MediumFont
	xdef ROMCALLS_TABLE
	ifnd	GPL
	xdef StdLib_FILE
	endif
	
;******************************************************************
;***                                                            ***
;***            	Main FILE				***
;***                                                            ***
;******************************************************************
	include	"Const.h"		; Constants and variables
	section ".text"
**********************************************************

	include "Estack.asm"		; EStack functions (1)
	include "Library.asm"		; Export API
	include "Kernel.asm"		; Kernel functions
	include "Window.asm"		; Window functions
	include "Dialog.asm"		; Dialog functions
	include "Estack2.asm"		; EStack functions (2)
	include "Bcd.asm"		; Float Functions (1)
	include	"unpack.asm"		; Unpack (PPG) functions
	include "Misc2.asm"		; Various functions (2)
	include "Script.asm"		; Script functions
	include	"Ints.asm"		; Auto Ints 
	include	"Vectors.asm"		; Vectors (Error, traps, ...)
	include	"Process.asm"		; Process Functions
	include	"Long.asm"		; Long Functions (32 bits / 32 bits, ...)
	include "Cert.asm"		; Certificate functions.
	include "Extra.asm"		; Extra AMS 2 functions
	include	"Tib.asm"		; RAM Install code
	include	"RomVoid.asm"		; All other rom_calls 

***********************************************************
***			DATA				***
***********************************************************
	CNOP	0,4		; Long Alignement for DB92
MediumFont	incbin	"Fontes.bin"	; Font Data
		EVEN
	ifnd	GPL
StdLib_FILE 	incbin	"stdlib.bin"	; Standard Libraries
	endif
		EVEN

		include	"RomCalls.h"	; Romcalls table ($C8)

License_str	dc.b	"(http://www.yaronet.com/t3)",10,10
		dc.b	"This program is free software; you can",10
		dc.b	"redistribute it and/or modify it under",10
		dc.b	"the terms of the GNU GPL as published by",10
	ifnd	USE_GPL3
		dc.b	"the Free Software Foundation (version 2,",10
	endif
	ifd	USE_GPL3
		dc.b	"the Free Software Foundation (version 3,",10
	endif
		dc.b	"or any later version).",10,10
		dc.b	"It is distributed WITHOUT ANY WARRANTY.",10,10
		dc.b	"See http://www.fsf.org for more details.",0

	END
	