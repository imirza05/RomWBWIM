;___BOOTROM____________________________________________________________________________________________________________
;
; ROM BOOT MANAGER
;
;   HARDWARE COLD START WILL JUMP HERE FOR INITIALIZATION
;   REFER TO BANKEDBIOS.TXT FOR MORE INFORMATION.
;______________________________________________________________________________________________________________________
;
;
#INCLUDE "std.asm"
;
	.ORG	0100H
;
	DI			; NO INTERRUPTS
	IM	1		; INTERRUPT MODE 1

;
; PERFORM MINIMAL Z180 SPECIFIC INITIALIZATION
;
#IF (PLATFORM == PLT_N8)
	; SET BASE FOR CPU IO REGISTERS
   	LD	A,CPU_IOBASE
	OUT0	(CPU_ICR),A
	
	; SET CPU CLOCK DIV
	LD	A,Z180_CLKDIV << 7
	OUT0	(CPU_CCR),A
	
	; SET WAIT STATES
	LD	A,0 + (Z180_MEMWAIT << 6) | (Z180_IOWAIT << 4)
	OUT0	(CPU_DCNTL),A

	; MMU SETUP
	LD	A,80H
	OUT0	(CPU_CBAR),A		; SETUP FOR 32K/32K BANK CONFIG
	XOR	A
	OUT0	(CPU_BBR),A		; BANK BASE = 0
	LD	A,(RAMSIZE - 64) >> 2
	OUT0	(CPU_CBR),A		; COMMON BASE = LAST (TOP) BANK
#ENDIF

;
; COPY ENTIRE CONTENTS OF ROM BANK 0 TO HI RAM
; THIS INCLUDES OURSELVES AND THE LOADER CODE
;   - HBIOS PROXY AT $FF00 IS OVERLAID, BUT WE DON'T CARE
;     BECAUSE IT WILL BE REFRESHED DURING HBIOS
;     INIT LATER.
;
	LD	HL,0000H	; COPY MEMORY FROM LOMEM (0000H)
	LD	DE,8000H	; TO HIMEM (8000H)
	LD	BC,8000H	; COPY ENTIRE BANK, 8000H BYTES
	LDIR
;
	JP	PHASE2		; JUMP TO PHASE 2 BOOT IN UPPER MEMORY
;
;______________________________________________________________________________________________________________________
;
; THIS IS THE PHASE 2 CODE THAT MUST EXECUTE IN UPPER MEMORY
;
	.ORG	$ + $8000	; WE ARE NOW EXECUTING IN UPPER MEMORY
;
PHASE2:
	LD	SP,9000H	; INIT BOOT STACK
;
; COPY ROMPG1 TO RAMPG1
;
	LD	HL,0000H	; HL = LOCATION IN LOMEM TO COPY FROM/TO
LOOP:
	LD	DE,09000H	; DE = BUFFER ADDRESS
	LD	BC,1000H	; BYTES TO COPY (4K CHUNKS)
	PUSH	BC		; SAVE COPY SIZE
	PUSH	DE		; SAVE COPY DEST
	PUSH	HL		; SAVE COPY SOURCE
	LD	A,1		; SELECT PAGE 1
	CALL	ROMPG		; OF ROM FOR COPY 
	LDIR			; COPY ROM -> BUFFER
	POP	DE		; RESTORE SOURCE AS NEW DESTINATION
	POP	HL		; RESTORE DESTINATION AS NEW SOURCE
	POP	BC		; RESTORE COPY SIZE
	LD	A,1		; SELECT PAGE 1
	CALL	RAMPG		; OF RAM FOR COPY
	LDIR			; COPY BUFFER -> RAM
	EX	DE,HL		; GET LOMEM POINTER BACK TO HL
	LD	A,H		; HIGH BYTE OF POINTER TO A
	CP	80H		; HIGH BYTE WILL BE 80H WHEN WE ARE DONE
	JP	NZ,LOOP		; IF NOT DONE, LOOP TO DO NEXT 4K CHUNK
;
; INITIALIZE HBIOS AND JUMP TO LOADER
;
	; CALL HBIOS HARDWARE INITIALIZATION
	LD	A,1		; SETUP TO SELECT PAGE 1
	CALL	RAMPG		; SELECT RAM PAGE 1 (WHICH IS NOW LOADED WITH BNK1 CODE)
	CALL	1000H		; CALL HBIOS INITIALIZATION
;
	; CALL HBIOS PROXY INITIALIZATION
	CALL	RAMPGZ		; MAKE SURE RAM PAGE ZERO IS MAPPED TO LOWER 32K
	CALL	0FF20H		; CALL HBIOS PROXY INITIALIZATION
;
	JP	8400H		; JUMP TO LOADER
;______________________________________________________________________________________________________________________
;
; NOTE THAT MEMORY MANAGER CODE IS IN UPPER MEMORY!
;
#INCLUDE "memmgr.asm"
;______________________________________________________________________________________________________________________
;
; PAD OUT REMAINDER OF PAGE
;
	.ORG	$ - $8000	; ORG BACK TO LOWER MEMORY
	.FILL	$0200 - $,$FF	; PAD OUT REMAINDER OF PAGE
;
	.END