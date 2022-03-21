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

VECTORS_TABLE:
        dc.l	SSP_INIT		; Stack Ptr $00
        dc.l	CODE_START		; Start of Program
        dc.l	BUS_ERROR		; Bus Error
        dc.l	ADDRESS_ERROR		; Address Error
        dc.l	ILLEGAL_INSTR		; Illegal Instruction
        dc.l	ZERO_DIVIDE		; Divide by zero
        dc.l	CHK_INSTR		; CHK Instruction
        dc.l	I_TRAPV			; TRAPV
        dc.l	PRIVILEGE           ; Privilege Violation
        dc.l	TRACE               ; Trace
        dc.l	LINE_1010           ; Line 1010 Emulator
        dc.l	LINE_1111           ; Line 1011 Emultor
        dc.w	PEDROM_VERSION,$524F           ; Kernel Version / Kernel Name	$30
        dc.l	start_kernel_prgm   ; Kernel Exec 			$34
        dc.l	reloc               ; Reloc				$38
        dc.l	reloc2              ; Reloc2				$3C
        dc.l	unreloc             ; Unreloc				$40
        dc.l	unreloc2            ; Unreloc2                       	$44
        dc.l	$00                 ; KernelHandle			$48
        dc.l	$00                 ; KernelShiftOn			$4C
        dc.l	start_kernel_prgm   ; Extended Kernel Exec	$50
        dc.l	$00                 ; Unused                        	$54
        dc.l	$00                 ; Unused                        	$58
        dc.l	$00                 ; Unused                  	$5C
        dc.l	SPURIOUS            ; Spurious Interrupt      	$60
        dc.l	Int_1               ; $Auto-Int 1			$64
        dc.l	Int_2               ; $Auto-Int 2			$68
        dc.l	Int_3               ; $Auto-Int 3			$6C
        dc.l	Int_4               ; $Auto-Int 4			$70
        dc.l	Int_5               ; $Auto-Int 5			$74
        dc.l	Int_6               ; $Auto-Int 6			$78
        dc.l	Int_7               ; $Auto-Int 7			$7C
        dc.l	Trap_0              ;  *Trap 0				$80
        dc.l	Trap_1              ;  *Trap 1                  	$84
        dc.l	Trap_2              ;  *Trap 2                  	$88
        dc.l	Trap_3              ;  *Trap 3                  	$8C
        dc.l	Trap_4              ;  *Trap 4
        dc.l	Trap_5              ;  *Trap 5
        dc.l	Trap_6              ;  *Trap 6
        dc.l	Trap_7              ;  *Trap 7
        dc.l	Trap_8              ;  *Trap 8                  	$A0
        dc.l	Trap_9              ;  *Trap 9
        dc.l	Trap_10             ;  *Trap A
        dc.l	Trap_11             ;  *Trap B
        dc.l	Trap_12             ;  *Trap C                  	$B0
        dc.l	Trap_13             ;  *Trap D
        dc.l	Trap_14             ;  *Trap E
        dc.l	Trap_15             ;  *Trap F
        dc.l	$FF0055AA           ;  *SIGNATURE                   $C0
        dc.l	$1FFFFC             ;  *RAM_SIZE
        dc.l	ROMCALLS_TABLE 	    ;  *ROM_CALL_TABLE
        dc.l	$0,$0,$0,$0         ;  *Users Vectors               $CC
        dc.l	$0,$0,$0,$0         ;  *
        dc.l	$0,$0,$0,$0         ;  *
        dc.l	$0                  ;  *                        	$D8
End_Vectors_Table:
	
