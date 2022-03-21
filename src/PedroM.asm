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
        xdef CODE_START
        xdef Trap_2


;******************************************************************
;***                                                            ***
;***            	Main FILE				***
;***                                                            ***
;******************************************************************

	include	"Const.h"		; Constants and variables

**********************************************************
	section	"_st1"
	include "Vectors.h"		; Vectors's table
CODE_START:
Trap_2:
        include	"Boot.asm"		; Boot Code (Set IO ports, clear RAM, unprotect, ...) and go to the Shell Command loop - MUST BE THE FIRST INCLUDE FILE -
	include	"Flash.asm"		; Flash Code (Write to Flash, ...) - MUST BE THE SECOND INCLUDE FILE -
	include	"System.asm"		; System exec command  
	include "ShellIO.asm"		; Shell IO
	include	"Builtin.asm"		; Builtin command functions
	include "Link.asm"		; Link functions.
	include	"Strings.asm"		; String character
	include "Vat.asm"		; VAT functions.
	include "Memstr.asm"		; memcpy/strcmp/... functions
	include	"Heap.asm"		; Heap functions
	include "Graph.asm"		; Graph functions
	include	"Misc.asm"		; Various functions (1)
BASE1_END:				; End of first Base of code : MUST BE <$418000

	
***********************************************************
***							***
***  $418000-$419FFF       8K      [read protected]	***
***							***
***********************************************************
	
	END
