; TIB Install
; Copyright (C) 2000-2004 Julien Muchembled
; Adaptation for PedroM 
; Copyright (C) 2003, 2005-2009 Patrick Pelissier
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
        xdef TIBReceiv
        xdef Int_4
        xdef RTE
        xdef TIBReceivEnd
	xdef TIBMessageToDisplay
	
; Install a TIB. RAM Code
TIBReceiv:
	; Install RAM interrupts
	lea	GHOST_SPACE+$70,a0
	lea	Int_4(pc),a1				; Reinstall Int4 so that its code is in RAM!
	move.l	a1,(a0)+				; Install New Int4 (can't use global)
	lea	RTE(pc),a1				; 
	move.l	a1,(a0)+				; Install New Int5 (Void Handler)
	lea	Abort(pc),a1				; Using Break Key Abort the installation
	move.l	a1,(a0)+				; Install New Int 6 (Break)
	move.w	#$2300,SR				; Set Interrupt Mask
	lea	(SSP_INIT-16).w,sp			; Restore Supervisor Stack and create a stack frame.

	;;  Display the help for the displayed Icons
	lea	LCD_MEM+30*6*2+0,a4
	bsr	DrawBarReceiving
	lea	LCD_MEM+30*6*2+10,a4
	bsr	DrawBarDone
	lea	LCD_MEM+30*6*2+30*10+0,a4
	bsr	DrawBarWriting
	lea	LCD_MEM+30*6*2+30*10+10,a4
	bsr	DrawBarWritingDone
	
	lea	LCD_MEM+30*6*6+0,a4			; Pointer used to display the different sprite during the installation.
	
	; Start receiving
	move.l	a7,a6					; a6 -> Buffer of 4 bytes
	move.w	#4,-(a7)				; Push Size to receive
	move.l	a6,-(a7)				; Push address where to receive
	bsr	DrawBarReceiving
	bra.s	\WaitForReady

	; Loop until we don't get a PACKET "TI is ready?"
\WaitForReadyLoop:
		bsr	SendMsgOk			; Prepare Msg OK
\WaitForReady:	bsr	LinkReceive			; Receive New Header (4 bytes)
		tst.b	(a6)				; 
		bpl.s	\DontCheckSender
			eor.b	#DEVICE_LINK_ID,(a6)	; Check if it is 
			btst	#4,(a6)			; a Message for 89/92+?
			bne	DeadEnd			; No?
\DontCheckSender:
		move.w	(a6),d0				; d0.b = Msg Id
		cmp.b	#CID_RDY,d0			; Check if Msg="Test if ready"
		beq.s	\WaitForReadyLoop		; Yes => Send OK, and receive again

	bsr	DrawBarDone

	cmp.b	#CID_RTS,d0				; Check if Msg="Request to Send Variable"
	beq.b	\ReadPacket				; Send by PC
		cmp.b	#CID_VAR,d0			; Check if Msg="Variable Header"
		bne	DeadEnd				; Send by calc
\ReadPacket:
	
	move.l	(a6),d0					; Read DEVICE.b,MSG.b,size.w: SIZE
	moveq	#8,d4					; For convertion from BigEndian to LittleEndian
	rol.w	d4,d0					; From BigEndian to LittleEndian
	
	ifne	PEDROM_89_92				; Only for TI89 and TI92PLUS
	moveq	#6,d3					; Check if expected size is the same
	cmp.w	d3,d0					; as the received size. We should have 6 bytes for RTS and 7 bytes for VAR
	beq.s	\SizeOk					; But some programs may send 7 bytes for RTS (All? versions of TILP)
	moveq	#7,d3					; There is no name for OS update, and we shouldn't count the empty null char
	cmp.w	d3,d0					; as one character as they do. 
	bne	DeadEnd					; Anyway it doesn't change anything for us. So let's accept them both.
\SizeOk:						
	endif
	
	ifeq	PEDROM_89_92				; Only for V200 & TI89 Titanium
	moveq	#9,d3					; V200 & Titanium need a RTS paquet of 9 bytes
	cmp.w	d3,d0					; 
	bne	DeadEnd					; 
	endif
	
	bsr	LinkReceive				; Receive size of OS (4 bytes)
	neg.w	-(a6)					; Hack: -2(a6) is the size to receive. Now it is -4
	add.w	d3,(a6)+				; New size = -4+6/7 / Restore a6 ptr to Header Buffer
	move.l	(a6),d3					; Read size of OS
	rol.w	d4,d3					; LowWord From BigEndian to LittleEndian
	swap	d3					; Long From BigEndian to LittleEndian
	rol.w	d4,d3					; HighWord From BigEndian to LittleEndian
	cmp.l	#$590000-$412000,d3			; Check size of ROM. Even for V200 and Titanium, we 
	bhi	DeadEnd					; won't accept a bigger ROM size
							; d3.l = SIZE OF OS
	move.w	d0,d4					; LinkReceive sends in d0 the checksum of what it received. Save it in d4.w
	bsr	LinkReceive				; Receive the rest of the packet
	move.w	#4,-2(a6)				; Restore the header size of a packet
	add.w	d4,d0					; d0.w = the expected checksum = previous + new
	bsr	LinkChkSum				; Receive and check the checksum
	cmp.b	#$23,(a6)				; Check if it is an OS update
	bne	DeadEnd

	lea	TIB_SMALL,a2				; Buffer of $4000 bytes = what it has to be installed
							; before pLarge (= rest of the previous packet which
							; couldn't be installed in the previous segment)
							; Note: it is composed of two sub-buffer of $2000 bytes
	lea	TIB_LARGE,a3				; Buffer of $E000 bytes

	; Copy the certificates in the last remaining bytes of previous packet area
	; so that they are copied before the OS.
	lea	ROM_BASE+$10000,a5			; Beginning of OS
	move.l	a5,a0					; Certificates pointer
	move.w	#$7FF,d0				; Size of certificates/4 - 1 
\CopyCert:	move.l	(a0)+,(a2)+
		dbf	d0,\CopyCert
	move.w	d0,-$1FFE(a2)				; Beginning of certificate = $FFFF = OS not installed
	move.w	#$2000,d6				; Size of remaning buffer

	; LOOP: Receiving OS
ReceiveOSLoop:
		bsr	SendMsgOk			; Prepare Ok Msg and send it
		eor.w	#$5F,(a6)			; Send MsgId = $56^$5F = 9 = "Wait Data/Continue"
		bsr	LinkSend			; Send Msg
		; Wait for a new useful packet
ReceiveOSWait:		bsr	DrawBarReceiving
			bsr	LinkReceive		; Receive Header
			move.w	(a6),d0			; Read MsgId
			cmp.b	#CID_CON,d0		; Check if Msg="Continue" => send OK and continue
			beq.s	ReceiveOSLoop		;
			cmp.b	#CID_ACK,d0		; Check if Msg="Ok" => Wait next message
			beq.s	ReceiveOSWait
	
		cmp.b	#CID_XDP,d0			; Check if Msg="Data part"
		bne	DeadEnd				; No, so abort receiving

		bsr	DrawBarDone
		bsr	DrawBarReceiving

		clr.w	(a6)				; Clear Device.b|Msg.b field
		move.l	(a6),d4				; Read Size of receive packet
		rol.w	#8,d4				; From BigEndian to LittleEndian
		bne.b	\NotFullSeg			; If it is not 0, it is ok
			moveq	#1,d4			; Length = 0 => we have to receive 65536 bytes 
			swap	d4			;
\NotFullSeg:	move.l	d4,(a6)				; Save Length of packet to Read

		; Copy the last remaining bytes of previous packet from Remaining Buffer 1
		; to remaining Buffer 2.
		move.l	a2,a0
		move.w	d6,d0				; d6.w = #of bytes in remaining buffer 1
		bra.s	\Center
\CopyEnd:		move.b	-$2000(a0),(a0)+	; Copy
\Center:		dbf	d0,\CopyEnd

		move.l	#$00002000,d0			; Size of remaining Buffer 2
		sub.w	d6,d0				; - Size of remaining Buffer 1 = what we have to receive to fill remaining Buffer 2
		sub.l	d0,d4				; Remove this from Packet Length
		bcc.b	\SegEnd1			; Check if overflow
			add.w	d4,d0			; Overflow! Reduce size of remaining buffer 2
			moveq	#0,d4			; Update packet length to 0
\SegEnd1:	add.w	d0,d6				; d6.w = MIN ($2000, PacketLength)
		move.w	d0,-(a7)			; size to receive
		pea	(a0)				; Push where to receive = inside Remaining Buffer 2
		bsr	LinkReceive			; Receive d0.w bytes in a0
		addq.l	#4,a7				; Pop adress
		move.w	d0,d5				; Sace checkSum in d5

		move.w	#$E000,d0			; Size of LargeBuffer (d0.uw = 0)
		sub.l	d0,d4				; Remove this from Packet Length
		bcc.s	\SegEnd2			; Check for overflow
			add.w	d4,d0			; Overflow! Reduce size of # of bytes to read
			moveq	#0,d4			; Update packet length. FIXME: Why?
\SegEnd2:	move.w	d0,(a7)				; Push size
		move.l	a3,-(a7)			; Push Pointer (Large Buffer)
		bsr	LinkReceive			; Receive d0.w bytes to a3
		add.w	d0,d5				; Update checksum.

		move.w	d4,(a7)				; d4.w = Remaining bytes in packet length
		pea	-$2000(a2)			; Remaining Buffer 1
		bsr	LinkReceive			; Receive them in Remaining Buffer 1
		add.w	d5,d0				; Update Checksum
		addq.l	#8,a7				; Update stack ptr
		
		bsr	LinkChkSum			; Receive CheckSum and check it
	
		bsr	DrawBarDone
		bsr	DrawBarWriting

		; Check if we have to save the certificates inside the "Save Certificate Segment"
		; It must be in the archive sections of the memory!
		cmp.l	#ROM_BASE+$10000,a5		; Check if we are writting the first segment
		bne.s	\NoSaveCerts			; 
			lea	RTE(pc),a0		; 
			move.l	a0,GHOST_SPACE+$78	; ON key can't break anymore
			lea	ROM_BASE+ROM_SIZE-$10000,a1	; "SaveCertificateSegmen" = Last Segment of ROM
			cmpi.w	#$FFFF,(a1)		; Check if sector is cleaned
			beq.s	\NoCLeanForSaveCerts
				move.l	a1,a0		; Erase this sector
				bsr	Erase		; Clean it
\NoCLeanForSaveCerts:	move.l	a5,a0			; a0 = Source = ROM_BASE+$1000 (=First segment)
			move.w	#$2000,d0		; d0.w = Length = $2000 bytes
			bsr	Write			; Write the certificates inside the SaveSegment
\NoSaveCerts:
		; Fill with $FFFF the segment to write
		move.l	a5,a0				; a0 = a5 = Current segment to fill
		bsr	Erase				; Fill it with $FFFF
		; Write the segment in two steps
		move.w	d6,d0				; Length = Size of remaining packet 2
		move.w	d4,d6				; Update size of remaining packet 1
		move.l	a2,a0				; a0 = Source = remaining packet 2
		move.l	a5,a1				; a1 = a5 = Destination
		bsr	Write				; Fill the segment
		adda.w	d0,a1				; Advance destination
		move.w	(a7)+,d0			; Read size of Large Buffer 
		move.l	a3,a0				; Source = pLarge
		bsr	Write				; Fill the segment
	
		moveq	#1,d0
		swap	d0				; d0.l = 65536
		add.l	d0,a5				; Advance Segment ptr
	
		bsr	DrawBarWritingDone

		move.l	(a6),d5				; Read size of what has been received
		bsr	SendMsgOk			; Prepare OK
		sub.l	d5,d3				; Update OS_SIZE
		bhi	ReceiveOSWait			; Continue receiving
	
	; All the OS has been written
	move.w	d6,d0					; Check if it remains something
	beq.s	\NothingInLastSeg
		move.l	a5,a0				; 
		bsr	Erase				; Erase the next segment
		lea	-$2000(a2),a0			; Pointer to data (Remaining Buffer 1)
		move.l	a5,a1				; Destination
		bsr	Write				; Write last segment
		bsr	DrawBarWritingDone
\NothingInLastSeg

	; Validate the installation of an OS for the boot code
	clr.w	-(a7)					; Clear a buffer of 2 bytes
	move.l	a7,a0					; Source -> 0
	lea	ROM_BASE+$10002,a1			; ROM_BASE+$10002 = a1 = destination
	moveq	#2,d0					; Write 2 bytes
	bsr	Write					; Validate installation
	
	bsr	SendMsgOk				; Prepare OK

	; Wait ~10s before rebooting so that the OS message is really send to the PC
	move.l	#1000000,d0
\Stop_		subq.l	#1,d0
		bne.s	\Stop_

	; Boot the new installed OS
Abort:	move.w	#$2700,sr				; SR = $2700
	lea	ROM_BASE,a2				; Boot code
	move.l	(a2)+,sp				; Read stack ptr
	move.l	(a2)+,a0				; Read start code
	jmp	(a0)					; Jump to Boot Code

; Erase a segment pointed by a0.l
; Doesn't destroy any registers
Erase:
	move.l	d0,-(a7)
	move.w	#$2700,sr
	move.w	#$5050,(a0)
	move.w	#$2020,(a0)
	move.w	#$D0D0,(a0)
\wait:		move.w (a0),d0
		btst	#7,d0
		beq.s	\wait
	move.w	#$5050,(a0)
	move.w	#$FFFF,(a0)
	move.w	#$2300,SR				;  Reallow interrupt 4
	move.l	(a7)+,d0
	rts

; Write d0.w bytes from a0.l (in RAM) to a1.l (in FlashROM)
; FIXME: Is it really needed to support odd copy?
; Doesn't destroy any registers
Write: 
	movem.l	d0-d2/a0/a2,-(a7)
	move.w	#$2700,sr		; Disable Interrupt
	move.l	a1,a2
	neg.w	d0
	cmp.w	a1,d0			; FIXME: unclear?
	bcs.s	\error

	moveq	#0,d1			; d1.l = Number of bytes
	sub.w	d0,d1			;
	beq.s	\full			; if d0.w = 0, fill all the segment
		move.b	-1(a1,d1.l),d2	; Final char after writing segment should not be destroyed
		move.w	#$5050,(a1)	; Prepare writing -- Factorize this?
		lsr.w	#1,d1		; Word counter
		bra.s	\start
\full:	move.w #$7FFF,d1		; Number of word loops
	move.w #$5050,(a1)		; Prepare writing

\flash:
		move.w	(a0)+,d0	; Read word to write
		move.w	#$1010,(a2)	; Request writing -- CHANGE a1 to a2
		move.w	d0,(a2)+	; Write it
\wait:			move.w (a1),d0	; Wait for ok
			btst	#7,d0	;
			beq.s	\wait	;
\start:		dbf	d1,\flash	; Continue for all words

;	btst	#0,3(a7)		; Check if length was odd
;	beq.s	\ret			; No
;		move.w	(a0)+,d0	; Read last word (But in fast, we are interested by last byte)
;		move.b	d2,d0		; Write previous char
;		move.w	#$1010,(a1)	; Request writing
;		move.w	d0,(a2)		; Write it
;\w2:			move.w	(a1),d0	; Wait for ok
;			btst	#7,d0	; Check
;			beq.s	\w2	; cont
\ret:					; 
	move.w	#$5050,(a1)	
	move.w	#$FFFF,(a1)	 
\error
	move.w	#$2300,SR		; Reallow interrupt 4
	movem.l (a7)+,d0-d2/a0/a2
	rts

SendMsgOk:
	move.l	#(DEVICE_LINK_ID<<24)|$560000,(a6)

LinkSend:
	move.w	#$2700,SR			; Disable Interrupt
	lea	LINK_SEND_QUEUE,a1
	move.w	QUEUE.used(a1),d1		; Number of bytes in transmit buffer
	addq.w	#4,d1				; We send 4 bytes
	cmp.w	QUEUE.size(a1),d1		; Compare to max size transmit buffer
	bge	DeadEnd				; Not enought space! 
	bset	#1,($60000C)			; Trig Int4 if transmit Buffer empty
	move.w	d1,QUEUE.used(a1)		; Set New number of bytes in send buffer
	move.w	QUEUE.tail(a1),d2
	move.l	a6,a0				; Send Buffer is a6
	moveq	#4-1,d0				; We send 4 bytes
\loop:		move.b	(a0)+,QUEUE.data(a1,d2.w)	; Add it to transmit buffer
		addq.w	#1,d2			; Advance tail (QUEUE is a circular buffer).
		cmp.w	QUEUE.size(a1),d2	; Modulo of the Transmit QUEUE size
		blt.s	\NoZero
			clr.w	d2		; Return to begin
\NoZero:	dbf	d0,\loop
	move.w	d2,QUEUE.tail(a1)		; Save new value of tail
\Error:	move.w	#$2300,SR			; Allow interrupts
	rts

LinkChkSum:
	move.l	d0,-(a7)		; Push d0 and create stack buffer
	move.w	#2,-(a7)		; Size=2=size of the check sum
	pea	2(a7)			; Push address of created buffer
	bsr.s	LinkReceive		; Receive 2 bytes (the checksum)
	addq.l	#6,a7			; Pop args of call
	move.w	(a7)+,d0		; Read what has been received
	rol.w	#8,d0			; From Big Endian to Little Endian
	sub.w	(a7)+,d0		; Return d0.w if checksum=expected checksum
	bne	DeadEnd			; Abort if wrong CheckSum
	rts

LinkReceive:
	move.l	d3,-(a7)
	moveq	#0,d0					; CheckSum
	movea.l	4+4(a7),a0				; Get adress of Buffer to fill
	move.w	4+8(a7),d3				; Get number of bytes in buffer
	beq.s	\Exit
	clr.w	d2					; Clear d2.w to read properly Byte to word
	lea	LINK_RECEIVE_QUEUE,a1			; Link Queue
\MainLoop:		move.w	#$2300,SR		; Allow Interrupts
			tst.w	QUEUE.used(a1)		; Check if there is some bytes in QUEUE
			beq.s	\MainLoop		; No so continue the waiting loop
		move.w	#$2700,SR			; Stop the interrupts
\loop		move.w	QUEUE.tail(a1),d1		; Read Tail Index
		move.b	QUEUE.data(a1,d1.w),d2		; Read byte from QUEUE
		move.b	d2,(a0)+			; Copy data from queue to buffer
		add.w	d2,d0				; Update CheckSum
		addq.w	#1,d1				; Advance read index in queue
		cmp.w	QUEUE.size(a1),d1		; Check Overflow (Queue is a circular buffer).
		blt.s	\NoZero
			clr.w	d1			; Restart from 0
\NoZero:	move.w	d1,QUEUE.tail(a1)		; Save New tail.
		subq.w	#1,QUEUE.used(a1)		; Dec # of remaining bytes in queue
		subq.w	#1,d3				; Dec # of bytes to read				
		bne.s	\MainLoop
\Exit	move.l	(a7)+,d3
	move.w	#$2300,SR				; Enable interrupts
	rts

; Link Auto-Int is in Tib.asm since it may be installed in RAM
; during TIB receive.
Int_4:
	move.w	#$2600,SR
	movem.l	d0-d2/a0-a2,-(a7)
	lea	$60000C,a1			; DBus Configuration Register
	lea	$F-$C(a1),a2			; Link Byte Buffer
	; Check if there is enough space in receive buffer before reading any link registers.
	lea	LINK_RECEIVE_QUEUE,a0
	move.w	QUEUE.used(a0),d1		; Check if we have enought space left
	cmp.w	QUEUE.size(a0),d1		; To insert a new byte. Otherwise we do nothing (Do not read the byte to avoid forgetting it).
	blt.s	\NoOverflow			; FIXME: Maybe we can still send data ?
		st.b	LINK_RECEIVE_OVERFLOW	; Modify OSReadLinkBlock too 
		bra	\Exit			; Do not read flags (Fixme: is it right ?)
\NoOverflow	
	move.w	(a1),d2				; Read Status
	btst	#3,d2				; Internal Activity ? ( Autostart ?)
	bne	\Exit
	; Check Link Error...
	btst	#7,d2				; Link Error ?
	beq.s	\NoResetLink
\ResetLink	move.b	#$E0,(a1)		; Reset link: AutoStart Enable, Link Disable, Link TimeOut Disable
		move.b	#$8D,(a1)		; Trigger int4 if Control Link Error, Control Autostart, Byte in Receive Buffer. AutoStart enable, Link Enable, Link TimeOut Enable
		st.b	LINK_RESET		; Link is reseted (FIXME: purging Buffer ?)
		bra.s	\Exit
\NoResetLink:
	; Check Receive Buffer...
	btst	#5,d2				; Byte in receive Buffer ?
	beq.s	\NoReceiveByte
		move.b	(a2),d0			; Read Byte from Receieve Buffer
		addq.w	#1,QUEUE.used(a0)	; One more Byte in QUEUE
		move.w	QUEUE.head(a0),d1	; Read current writting offset
		move.b	d0,QUEUE.data(a0,d1.w)	; Write Byte
		addq.w	#1,d1			; Next current writting offset
		cmp.w	QUEUE.size(a0),d1	; Check from Max
		blt	\NoZero
			clr.w	d1
\NoZero		move.w	d1,QUEUE.head(a0)
		bra.s	\Exit
\NoReceiveByte:
	btst	#9,d2				; Check if the int is triggered if Transmit Buffer is empty
	beq.s	\Exit
		lea	LINK_SEND_QUEUE,a0
\SendByte:
		tst.w	QUEUE.used(a0)		; Have we sent all the bytes ?
		beq.s	\DoNotTriggerIntForSend	; Yes so stop sending bytes
		move.w	(a1),d2
		btst	#6,d2			; Is tramsit buffer empty ?
		beq.s	\Exit			; No so exit
		move.w	QUEUE.head(a0),d1
		move.b	QUEUE.data(a0,d1.w),d0	; Read data
;\Wait			move.w	(a1),d2
;			btst	#7,d2
;			bne.s	\ResetLink	; Check if we reset link
;			btst	#6,d2		; Transmit Buffer empty ?
;			beq.s	\Wait
		move.b	d0,(a2)			; Write byte in transmit buffer
		subq.w	#1,QUEUE.used(a0)	; One byte sent
		addq.w	#1,d1			; Next Offset
		cmp.w	QUEUE.size(a0),d1
		blt	\NoZero2
			clr.w	d1
\NoZero2	move.w	d1,QUEUE.head(a0)	; Save new offset
		bra.s	\SendByte
\DoNotTriggerIntForSend
	bclr	#1,(a1)				; Do not triggered Int4 if Send Buffer is empty
\Exit	movem.l	(a7)+,d0-d2/a0-a2
RTE:	rte	


	;; Calls when a Fatal Error while receiving the TIB.
DeadEnd:
	bsr.s	\DrawChar			; Draw "Death"
	bra.s	*				; Loop forever / the user may break using ON key
\DrawChar
	move.l	d0,-(a7)
	moveq	#DeathEndSprite-ReceivingTibSprite,d0
	bra.s	DrawTibChar

	;;  Draw Bar stuff (a4 -> Position in LCD_MEM).
	;; Can't destroy registers.
DrawBarReceiving:	
	move.l	d0,-(a7)
	moveq	#ReceivingTibSprite-ReceivingTibSprite,d0
	bra.s	DrawTibChar
DrawBarWriting:
	move.l	d0,-(a7)
	moveq	#WritingTibSprite-ReceivingTibSprite,d0
	bra.s	DrawTibChar
DrawBarDone:
	move.l	d0,-(a7)
	moveq	#DoneTibSprite-ReceivingTibSprite,d0
	bra.s	DrawTibChar
DrawBarWritingDone:
	move.l	d0,-(a7)
	moveq	#DoneWritingTibSprite-ReceivingTibSprite,d0
DrawTibChar:
	movem.l a0-a1,-(a7)

	; a0 -> Source a1 -> Dest
	lea	ReceivingTibSprite(pc,d0.w),a0		; Sprite Source
	move.l	a4,a1					; Destination (LCD_MEM)
	moveq	#7,d0					; Sprite are 8 bytes long
\loop:	
		move.b	(a0)+,(a1)
		lea	30(a1),a1
		dbf	d0,\loop
	tst.b	-(a0)		; Check if it was a "Done Sprite", ie with a 0 as the last byte
	bne.s	\NoDoneSprite	; No so return
		;; advance dest for next char
		addq.l	#1,a4
		lea	Counter(pc),a0
		subq.b	#1,(a0)
		bne.s	\NoDoneSprite
			lea	(30*7+30-20)(a4),a4
			move.b	#20,(a0)
\NoDoneSprite:	
	movem.l (a7)+,a0-a1
	move.l	(a7)+,d0
	rts
Counter:	dc.b	20,0

ReceivingTibSprite:
	dc.b	%00111100
	dc.b	%01100110
	dc.b	%11000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
WritingTibSprite:	
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
DoneTibSprite:
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00111100
	dc.b	%01100110
	dc.b	%01100110
	dc.b	%00111100
	dc.b	%00011000
	dc.b	%00000000
DoneWritingTibSprite:
	dc.b	%11000011
	dc.b	%01100110
	dc.b	%00111100
	dc.b	%00011000
	dc.b	%00111100
	dc.b	%01100110
	dc.b	%11000011
	dc.b	%00000000
DeathEndSprite:
	dc.b	%10000001
	dc.b	%01000010
	dc.b	%00111100
	dc.b	%01011010
	dc.b	%01111110
	dc.b	%00100100
	dc.b	%01011010
	dc.b	%10000001

TIBReceivEnd:

TIBMessageToDisplay:	
	dc.b "Receiving a TIB...",13
	dc.b "ON to cancel BEFORE receiving.",13
	dc.b "     Waiting for receive       Done",13,13
	dc.b "     Writing in Flash              Done",13,0
	even
