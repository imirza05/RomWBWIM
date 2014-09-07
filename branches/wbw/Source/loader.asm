;
;==================================================================================================
;   LOADER
;==================================================================================================
;
; INCLUDE GENERIC STUFF
;
#INCLUDE "std.asm"
;
	.ORG	$8400
;
	; SETUP OUR STACK
	LD	SP,BL_STACK	; SET UP LOADER STACK

	; TEST FOR UNA, CONFIG INVOCATION VECTOR IF FOUND
	CALL	UNACHK

	; BANNER
	CALL	NEWLINE
	LD	DE,STR_BANNER
	CALL	WRITESTR

	; RUN THE BOOT LOADER MENU
	JP	DOBOOTMENU
;
;__DOBOOT________________________________________________________________________________________________________________________ 
;
; PERFORM BOOT FRONT PANEL ACTION
;________________________________________________________________________________________________________________________________
;
DOBOOTMENU:
	CALL	NEWLINE
	CALL	NEWLINE

	LD	DE,STR_BOOTMENU
	CALL	WRITESTR
	
#IF (DSKYENABLE)
	LD	HL,BOOT			; POINT TO BOOT MESSAGE	
	CALL 	SEGDISPLAY		; DISPLAY MESSAGE
#ENDIF

#IF (BOOTTYPE == BT_AUTO)
	LD	BC,1000 * BOOT_TIMEOUT
	LD	(BL_TIMEOUT),BC
#ENDIF

DB_BOOTLOOP:
;
; CHECK FOR CONSOLE BOOT KEYPRESS
;
	CALL	CST
	OR	A
	JP	Z,DB_CONEND
	CALL	CINUC
	CP	'M'			; MONITOR
	JP	Z,GOMON
	CP	'R'			; ROM BOOT
	JP	Z,GOROM
	CP	'L'			; LIST DRIVES
	JP	Z,GOLIST
	CP	'A'			; A-P, DISK BOOT
	JP	C,DB_INVALID
	CP	'P' + 1			; HMMM... 'M' DRIVE CONFLICTS WITH MONITOR SELECTION
	JP	NC,DB_INVALID
	SUB	'A'
	JP	GOBOOTDISK
DB_CONEND:
;
; CHECK FOR DSKY BOOT KEYPRESS
;
#IF (DSKYENABLE)
	CALL	KY_STAT			; GET KEY FROM KB INTO A
	OR	A
	JP	Z,DB_DSKYEND
	CALL	KY_GET
	CP	KY_GO			; GO = MONITOR
	JP	Z,GOMONDSKY 
	CP	KY_BO			; BO = BOOT ROM
	JP	Z,GOROM
	CP	0AH			; A-F, DISK BOOT
	JP	C,DB_INVALID
	CP	0FH + 1
	JP	NC,DB_INVALID
	SUB	0AH
	JP	GOBOOTDISK
;	LD	HL,BOOT			; POINT TO BOOT MESSAGE
;	LD	A,00H			; BLANK OUT SELECTION,IT WAS INVALID
;	LD	(HL),A			; STORE IT IN DISPLAY BUFFER
;	CALL	SEGDISPLAY		; DISPLAY THE BUFFER
DB_DSKYEND:
#ENDIF
;
; IF CONFIGURED, CHECK FOR AUTOBOOT TIMEOUT
;
#IF (BOOTTYPE == BT_AUTO)
	
	; DELAY FOR 1MS TO MAKE TIMEOUT CALC EASY
	LD	DE,40
	CALL	VDELAY

	; CHECK/INCREMENT TIMEOUT
	LD	BC,(BL_TIMEOUT)
	DEC	BC
	LD	(BL_TIMEOUT),BC
	LD	A,B
	OR	C
	JP	NZ,DB_BOOTLOOP

	; TIMEOUT EXPIRED, PERFORM DEFAULT BOOT ACTION
	LD	A,BOOT_DEFAULT
	CP	'M'			; MONITOR
	JP	Z,GOMON
	CP	'R'			; ROM BOOT
	JP	Z,GOROM
	CP	'A'			; A-P, DISK BOOT
	JP	C,DB_INVALID
	CP	'P' + 1			; HMMM... DRIVE M CONFLICTS WITH "MONITOR" SELECTION
	JP	NC,DB_INVALID
	SUB	'A'
	JP	GOBOOTDISK
#ENDIF

	JP	DB_BOOTLOOP
;
; BOOT OPTION PROCESSING
;
DB_INVALID:
	LD	DE,STR_INVALID
	CALL	WRITESTR
	JP	DOBOOTMENU
;
GOMON:
	LD	DE,STR_BOOTMON
	CALL	WRITESTR
	JP	MON_SERIAL
;
GOMONDSKY:
	LD	DE,STR_BOOTMON
	CALL	WRITESTR
	JP	MON_DSKY
;
GOROM:
	LD	DE,STR_BOOTROM
	CALL	WRITESTR
	JP	CPM_ENT
;
GOLIST:
	LD	DE,STR_LIST
	CALL	WRITESTR
	LD	DE,STR_DRVLIST
	CALL	WRITESTR
	CALL	PRTALL
	JP	DOBOOTMENU
;
GOBOOTDISK:
	LD	C,A
	LD	DE,STR_BOOTDISK
	CALL	WRITESTR
	JP	BOOTDISK
;
; CHECK FOR UNA, SETUP INVOCATION VECTOR IF FOUND
;
UNACHK:
	LD	A,($FFFD)	; FIXED LOCATION OF UNA API VECTOR
	CP	$C3		; JP INSTRUCTION?
	JR	NZ,UNACHKX	; IF NOT, NOT UNA
	LD	HL,($FFFE)	; GET JP ADDRESS
	LD	A,(HL)		; GET BYTE AT TARGET ADDRESS
	CP	$FD		; FIRST BYTE OF UNA PUSH IX INSTRUCTION
	JR	NZ,UNACHKX	; IF NOT, NOT UNA
	INC	HL		; NEXT BYTE
	LD	A,(HL)		; GET NEXT BYTE
	CP	$E5		; SECOND BYTE OF UNA PUSH IX INSTRUCTION
	JR	NZ,UNACHKX	; IF NOT, NOT UNA
	LD	HL,BL_UNAMOD	; POINT TO UNA MODE FLAG
	LD	(HL),$FF	; SET UNA MODE
	LD	A,$C3		; JP INSTRUCTION
	LD	(8),A		; STORE AT 0x0008
	LD	HL,($FFFE)	; UNA ENTRY VECTOR
	LD	(9),HL		; STORE AT 0x0009
;
UNACHKX:
	RET
;
; BOOT FROM DISK DRIVE
;
BOOTDISK:
	LD	DE,STR_BOOTDISK1	; DISK BOOT MESSAGE
	CALL	WRITESTR		; PRINT IT
	
	; CHECK FOR UNA
	LD	A,(BL_UNAMOD)		; GET UNA MODE
	OR	A			; SET FLAGS
	JP	NZ,BOOTUNA		; HANDLE UNA AS NEEDED
	
	; CHECK FOR VALID DRIVE LETTER
	LD	A,C			; GET BOOT DRIVE
	LD	HL,DRVMAP - 1		; POINT TO DRIVE COUNT
	CP	(HL)			; ... AND COMPARE
	JP	NC,DB_NODISK		; ERROR IF DRIVE ID >= COUNT

	; GET DEVICE/UNIT, SLICE
	ADD	A,A			; DRIVE MAP ENTRIES ARE 2 BYTES EACH
	LD	HL,DRVMAP		; POINT TO DRIVE MAP
	CALL	ADDHLA			; ... AND ADD DRIVE OFFSET
	LD	A,(HL)			; GET DEVICE/UNIT
	LD	(BL_DEVICE),A		; ... AND SAVE IT
	INC	HL			; NEXT BYTE IS SLICE
	LD	A,(HL)			; GET SLICE
	LD	(BL_LU),A		; ... AND SAVE IT

	; SENSE MEDIA
	LD	A,(BL_DEVICE)		; GET DEVICE/UNIT
	LD	C,A			; STORE IN C
	LD	B,BF_DIOMED		; DRIVER FUNCTION = DISK MEDIA
	RST	08			; CALL HBIOS
	OR	A			; SET FLAGS
	JP	Z,DB_ERR		; HANDLE ERROR
	
	; SET SPT BASED ON MEDIA DETECTED
	LD	C,18			; ASSUME 18 SPT
	CP	MID_FD144		; 3.5" 1.44M FLOPPY?
	JR	Z,BOOTDISK1		; YES, DONE

	LD	C,15			; ASSUME 15 SPT
	CP	MID_FD120		; 5.25" 1.2M FLOPPY?
	JR	Z,BOOTDISK1		; YES, DONE
	CP	MID_FD111		; 8" 1.11M FLOPPY?
	JR	Z,BOOTDISK1		; YES, DONE

	LD	C,9			; ASSUME 9 SPT
	CP	MID_FD720		; 3.5" 720K FLOPPY?
	JR	Z,BOOTDISK1		; YES, DONE
	CP	MID_FD360		; 5.25" 360k FLOPPY?
	JR	Z,BOOTDISK1		; YES, DONE

	LD	C,16			; EVERYTHING ELSE IS LBA (USE 16 SPT)

BOOTDISK1:
	LD	A,C
	LD	(BL_SPT),A		; SAVE SPT
	
	; DETERMINE STARTING TRACK FOR LU
	LD	A,(BL_LU)		; GET LU SPECIFIED
	LD	E,A			; LU INDEX
	LD	H,65			; 65 TRACKS PER SLICE
	CALL	MULT8			; HL := H * E
	LD	(BL_LUTRK),HL		; SAVE IT

	; READ BOOT INFO SECTOR
	LD	HL,0			; INITIAL TRACK (RELATIVE TO LU)
	LD	(BL_CURTRK),HL		; SAVE AS CURRENT TRACK
	LD	A,2			; BOOT INFO IS IN SECTOR 2
	LD	(BL_CURSEC),A		; SAVE AS CURRENT SECTOR
	LD	HL,BL_INFOSEC		; WHERE TO PUT INFO SECTOR
	LD	(BL_CURDMA),HL		; ... AND SAVE IT
	CALL	DB_READSEC		; READ CURRENT SECTOR
	JP	NZ,DB_ERR		; HANDLE ERROR
	
	; CHECK SIGNATURE
	LD	BC,(BB_SIG)
	LD	A,$A5
	CP	B
	JP	NZ,DB_NOBOOT
	LD	A,$5A
	CP	C
	JP	NZ,DB_NOBOOT

	; PRINT CPMLOC VALUE
	CALL	NEWLINE
	LD	DE,STR_CPMLOC
	CALL	WRITESTR
	LD	BC,(BB_CPMLOC)
	CALL	PRTHEXWORD

	; PRINT CPMEND VALUE
	CALL	PC_SPACE
	LD	DE,STR_CPMEND
	CALL	WRITESTR
	LD	BC,(BB_CPMEND)
	CALL	PRTHEXWORD
	
	; PRINT CPMENT VALUE
	CALL	PC_SPACE
	LD	DE,STR_CPMENT
	CALL	WRITESTR
	LD	BC,(BB_CPMENT)
	CALL	PRTHEXWORD
	CALL	PC_SPACE

	; PRINT DISK LABEL
	LD	DE,STR_LABEL
	CALL	WRITESTR
	LD	DE,BB_LABEL 		; if it is there, then a printable
	LD	A,(BB_TERM)		; Display Disk Label if Present
	CP	'$'			; (dwg 2/7/2012)
	CALL	Z,WRITESTR		; label is there as well even if spaces.

	; COMPUTE NUMBER OF SECTORS TO LOAD
	LD	HL,(BB_CPMEND)		; HL := END
	LD	DE,(BB_CPMLOC)		; DE := START 
	OR	A			; CLEAR CARRY
	SBC	HL,DE			; HL := LENGTH TO LOAD
	LD	A,H			; DETERMINE 512 BYTE SECTOR COUNT
	RRCA				; ... BY DIVIDING MSB BY TWO
	LD	(BL_COUNT),A		; ... AND SAVE IT

	; LOADING MESSAGE
	CALL	NEWLINE
	LD	DE,STR_LOADING
	CALL	WRITESTR
	
	; SETUP FOR DATA LOAD
	LD	HL,(BB_CPMLOC)		; GET TARGET LOAD LOCATION
	LD	(BL_CURDMA),HL		; ... AND SAVE IT

DB_LOOP:
	CALL	DB_NXTSEC		; BUMP TO NEXT SECTOR
	CALL	DB_READSEC		; READ SECTOR
	JP	NZ,DB_ERR		; HANDLE ERRORS
	CALL	PC_PERIOD		; SHOW PROGRESS
	LD	HL,(BL_CURDMA)		; GET LOAD LOC
	LD	DE,512			; 512 BYTES PER SECTOR
	ADD	HL,DE			; INCREMENT MEM POINTER
	LD	(BL_CURDMA),HL		; ... AND SAVE IT
	LD	HL,BL_COUNT		; POINT TO COUNTER
	DEC	(HL)			; ... AND DECREMENT IT
	JR	NZ,DB_LOOP		; LOOP IF NEEDED
	CALL	NEWLINE			; FORMATTING

	; JUMP TO COLD BOOT ENTRY
	LD	HL,(BB_CPMENT)
	JP	(HL)

;
; BOOT FROM UNA DISK DRIVE
;
BOOTUNA:
	LD	B,C			; MOVE UNIT CODE TO B

	; LOAD SECTOR 2 (BOOT INFO)
	LD	C,$41			; UNA FUNC: SET LBA
	LD	DE,0			; HI WORD OF LBA IS ALWAYS ZERO
	LD	HL,2			; LOAD STARTING INFO SECTOR 2
	RST	08			; SET LBA
	JP	NZ,DB_ERR		; HANDLE ERROR
	CALL	PC_PERIOD		; MARK PROGRESS
;
	LD	C,$42			; UNA FUNC: READ SECTORS
	LD	DE,BL_INFOSEC		; DEST OF CPM IMAGE
	LD	L,1			; SECTORS TO READ
	RST	08			; DO READ
	JP	NZ,DB_ERR		; HANDLE ERROR
	CALL	PC_PERIOD		; MARK PROGRESS
;
	PUSH	BC			; SAVE UNIT
;
	; CHECK SIGNATURE
	CALL	NEWLINE			; FORMATTING
	LD	DE,(BB_SIG)		; GET THE SIGNATURE
	LD	A,$A5			; FIRST BYTE SHOULD BE $A5
	CP	D			; COMPARE
	JP	NZ,DB_NOBOOT		; ERROR IF NOT EQUAL
	LD	A,$5A			; SECOND BYTE SHOULD BE $5A
	CP	E			; COMPARE
	JP	NZ,DB_NOBOOT		; ERROR IS NOT EQUAL

	; PRINT CPMLOC VALUE
	CALL	NEWLINE
	LD	DE,STR_CPMLOC
	CALL	WRITESTR
	LD	BC,(BB_CPMLOC)
	CALL	PRTHEXWORD

	; PRINT CPMEND VALUE
	CALL	PC_SPACE
	LD	DE,STR_CPMEND
	CALL	WRITESTR
	LD	BC,(BB_CPMEND)
	CALL	PRTHEXWORD
	
	; PRINT CPMENT VALUE
	CALL	PC_SPACE
	LD	DE,STR_CPMENT
	CALL	WRITESTR
	LD	BC,(BB_CPMENT)
	CALL	PRTHEXWORD
	CALL	PC_SPACE

	; PRINT DISK LABEL
	LD	DE,STR_LABEL
	CALL	WRITESTR
	LD	DE,BB_LABEL 		; if it is there, then a printable
	LD	A,(BB_TERM)		; Display Disk Label if Present
	CP	'$'			; (dwg 2/7/2012)
	CALL	Z,WRITESTR		; label is there as well even if spaces.
;
	LD	DE,STR_LOADING		; LOADING MESSAGE
	CALL	WRITESTR		; PRINT IT
;
	POP	BC			; RESTORE UNIT
;
	LD	C,$41			; UNA FUNC: SET LBA
	LD	DE,0			; HI WORD OF LBA IS ALWAYS ZERO
	LD	HL,3			; LOAD STARTING AT SECTOR 3
	RST	08			; SET LBA
	JP	NZ,DB_ERR		; HANDLE ERROR
	CALL	PC_PERIOD		; MARK PROGRESS
;
	LD	C,$42			; UNA FUNC: READ SECTORS
	LD	HL,(BB_CPMEND)		; HL := END
	LD	DE,(BB_CPMLOC)		; DE := START 
	OR	A			; CLEAR CARRY
	SBC	HL,DE			; HL := LENGTH TO LOAD
	LD	A,H			; DETERMINE 512 BYTE SECTOR COUNT
	RRCA				; ... BY DIVIDING MSB BY TWO
	LD	L,A			; SECTORS TO READ
	LD	DE,(BB_CPMLOC)		; DEST OF CPM IMAGE
	RST	08			; DO READ
	JP	NZ,DB_ERR		; HANDLE ERROR
	CALL	PC_PERIOD		; MARK PROGRESS
;
	; JUMP TO COLD BOOT ENTRY
	CALL	NEWLINE			; FORMATTING
	LD	HL,(BB_CPMENT)		; GET THE ENTRY POINT
	JP	(HL)			; ... AND GO

DB_NODISK:
	; SELDSK DID NOT LIKE DRIVE SELECTION
	LD	DE,STR_NODISK
	CALL	WRITESTR
	JP	DOBOOTMENU

DB_NOBOOT:
	; DISK IS NOT BOOTABLE
	LD	DE,STR_NOBOOT
	CALL	WRITESTR
	JP	DOBOOTMENU

DB_ERR:
	; I/O ERROR DURING BOOT ATTEMPT
	LD	DE,STR_BOOTERR
	CALL	WRITESTR
	JP	DOBOOTMENU
;
; INCREMENT TO NEXT SECTOR
;
DB_NXTSEC:
	LD	A,(BL_SPT)		; GET SECTORS PER TRACK
	LD	B,A			; ... AND SAVE IT IN B
	LD	HL,BL_CURSEC		; POINT TO CURRENT SECTOR
	INC	(HL)			; INCREMENT IT
	LD	A,(HL)			; GET CURRENT SECTOR TO A
	CP	B			; COMPARE TO SPT IN B
	RET	NZ			; IF WE HAVE NOT HIT SPT, DONE
	XOR	A			; PREPARE TO CLEAR CUR SECTOR
	LD	(HL),A			; ... AND DO IT
	LD	HL,(BL_CURTRK)		; LOAD CURRENT TRACK VALUE
	INC	HL			; ... AND INCREMENT IT
	LD	(BL_CURTRK),HL		; ... AND SAVE IT
	RET
;
; READ CURRENT SECTOR TO LOAD LOCATION
;
DB_READSEC:
	LD	HL,(BL_CURDMA)	; GET THE SECTOR DMA ADDRESS

#IF 0
	CALL	NEWLINE
	PUSH	HL
	POP	BC
	CALL	PRTHEXWORD
#ENDIF
	LD	B,BF_DIOSETBUF	; HBIOS FUNC: SET BUF
	RST	08		; CALL HBIOS

	LD	A,(BL_DEVICE)	; GET ACTIVE DEVICE/UNIT BYTE
	AND	$F0		; ISOLATE DEVICE PORTION
	CP	DIODEV_FD	; FLOPPY?
	JR	NZ,DB_READSEC1	; NO, USE LBA HANDLING
	; SET HL=TRACK (ADD IN TRACK OFFSET)
	LD	DE,(BL_LUTRK)	; DE = TRACK OFFSET FOR LU SUPPORT
	LD	HL,(BL_CURTRK)	; HL = TRACK #
	ADD	HL,DE		; APPLY OFFSET FOR ACTIVE SLICE
	; SET DE=SECTOR
	LD	A,(BL_CURSEC)	; GET THE SECTOR INTO A
	LD	E,A		; MOVE IT TO LSB
	LD	D,0		; MSB IS ALWAYS ZERO
	; SET C = DEVICE/UNIT
	LD	B,BF_DIORD	; FUNCTION IN B
	LD	A,(BL_DEVICE)	; LOAD DEVICE/UNIT VALUE
	LD	C,A		; SAVE IN C
	JR	DB_READSEC3	; DISPATCH TO DRIVER
;
DB_READSEC1:
;
	; LBA STYLE ACCESS
	LD	DE,(BL_CURTRK)	; GET TRACK INTO HL
	LD	B,4		; PREPARE TO LEFT SHIFT BY 4 BITS
DB_READSEC2:
	SLA	E		; SHIFT DE LEFT BY 4 BITS
	RL	D
	DJNZ	DB_READSEC2	; LOOP TILL ALL BITS DONE
	LD	A,(BL_CURSEC)	; GET THE SECTOR INTO A
	AND	$0F		; GET RID OF TOP NIBBLE
	OR	E		; COMBINE WITH E
	LD	E,A		; BACK IN E
	LD	HL,0		; HL:DE NOW HAS SLICE RELATIVE LBA
	; APPLY LU OFFSET NOW
	; LU OFFSET IS EXPRESSED AS NUMBER OF BLOCKS * 256 TO LU OFFSET!
	LD	A,(BL_LUTRK)	; LSB OF LU TRACK TO A
	ADD	A,D		; ADD WITH D
	LD	D,A		; PUT IT BACK IN D
	LD	A,(BL_LUTRK+1)	; MSB OF LU TRACK TO A
	CALL	ADDHLA		; ADD LU OFFSET
	LD	B,BF_DIORD	; FUNCTION IN B
	LD	A,(BL_DEVICE)	; GET THE DEVICE/UNIT VALUE
	LD	C,A		; PUT IT IN C
;
DB_READSEC3:	
;
	; DISPATCH TO DRIVER
#IF 0
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	
	CALL	PC_PERIOD
	LD	A,C
	CALL	PRTHEXBYTE
	PUSH	BC
	PUSH	HL
	POP	BC
	CALL	PC_PERIOD
	CALL	PRTHEXWORD
	PUSH	DE
	POP	BC
	CALL	PC_COLON
	CALL	PRTHEXWORD
	CALL	NEWLINE
	POP	BC
	
	POP	HL
	POP	DE
	POP	BC
	POP	AF
#ENDIF
	RST	08
	OR	A		; SET FLAGS BASED ON RESULT
	RET
;
; PRINT LIST OF ALL DRIVES
;
PRTALL:
	LD	A,(BL_UNAMOD)	; GET UNA MODE FLAG
	OR	A		; SET FLAGS
	JP	NZ,UPRTALL	; HANDLE UNA MODE

	LD	HL,DRVMAP - 1	; POINT TO DRIVE COUNT
	LD	B,(HL)		; DRIVE COUNT TO B
	LD	C,0		; DRIVE INDEX
	INC	HL		; POINT TO FIRST ENTRY
;
PRTALL1:
	LD	DE,STR_PREFIX	; FORMATTING
	CALL	WRITESTR	; PRINT IT
	LD	A,C		; DRIVE INDEX
	ADD	A,'A'		; MAKE IS ALPHA
	CALL	COUT		; PRINT IT
	LD	A,':'		; DRIVE COLON
	CALL	COUT		; PRINT IT
	LD	A,'='		; SEPARATOR
	CALL	COUT		; PRINT IT
	LD	D,(HL)		; GET DEVICE/UNIT
	INC	HL		; BUMP TO LU
	LD	E,(HL)		; GET LU
	INC	HL		; MOVE TO NEXT DRIVE
	PUSH	BC		; PRESERVE LOOP CONTROL
	CALL	PRTDRV		; PRINT IT
	POP	BC		; RESTORE LOOP CONTROL
	INC	C		; NEXT DRIVE
	DJNZ	PRTALL1		; LOOP TILL DONE
	RET			; AND DONE
;
; PRINT THE DEVICE/UNIT/SLICE INFO
; ON INPUT D HAS DEVICE/UNIT, E HAS SLICE
; DESTROY NO REGISTERS OTHER THAN A
;
PRTDRV:
	PUSH	DE		; PRESERVE DE
	PUSH	HL		; PRESERVE HL
	LD	A,D		; LOAD DEVICE/UNIT
	RRCA			; ROTATE DEVICE
	RRCA			; ... BITS
	RRCA			; ... INTO
	RRCA			; ... LOWEST 4 BITS
	AND	$0F		; ISOLATE DEVICE BITS
	ADD	A,A		; MULTIPLE BY TWO FOR WORD TABLE
	LD	HL,DEVTBL	; POINT TO START OF DEVICE NAME TABLE
	CALL	ADDHLA		; ADD A TO HL TO POINT TO TABLE ENTRY
	LD	A,(HL)		; DEREFERENCE HL TO LOC OF DEVICE NAME STRING
	INC	HL		; ...
	LD	D,(HL)		; ...
	LD	E,A		; ...
	CALL	WRITESTR	; PRINT THE DEVICE NMEMONIC
	POP	HL		; RECOVER HL
	POP	DE		; RECOVER DE
	LD	A,D		; LOAD DEVICE/UNIT
	AND	$0F		; ISOLATE UNIT
	CALL	PRTDECB		; PRINT IT
	CALL	PC_COLON	; FORMATTING
	LD	A,E		; LOAD SLICE
	CALL	PRTDECB		; PRINT IT
	RET
;
DEVTBL:	; DEVICE TABLE
	.DW	DEV00, DEV01, DEV02, DEV03
	.DW	DEV04, DEV05, DEV06, DEV07
	.DW	DEV08, DEV09, DEV10, DEV11
	.DW	DEV12, DEV13, DEV14, DEV15
;
DEVUNK	.DB	"???$"
DEV00	.DB	"MD$"
DEV01	.DB	"FD$"
DEV02	.DB	"RAMF$"
DEV03	.DB	"IDE$"
DEV04	.DB	"ATAPI$"
DEV05	.DB	"PPIDE$"
DEV06	.DB	"SD$"
DEV07	.DB	"PRPSD$"
DEV08	.DB	"PPPSD$"
DEV09	.DB	"HDSK$"
DEV10	.EQU	DEVUNK
DEV11	.EQU	DEVUNK
DEV12	.EQU	DEVUNK
DEV13	.EQU	DEVUNK
DEV14	.EQU	DEVUNK
DEV15	.EQU	DEVUNK
;
; PRINT LIST OF ALL DRIVES UNDER UNA
;
UPRTALL:
	LD	B,0			; START WITH UNIT 0
;
UPRTALL1:	; LOOP THRU ALL UNITS AVAILABLE
	LD	C,$48			; UNA FUNC: GET DISK TYPE
	LD	L,0			; PRESET UNIT COUNT TO ZERO
	RST	08			; CALL UNA, B IS ASSUMED TO BE UNTOUCHED!!!
	LD	A,L			; UNIT COUNT TO A
	OR	A			; PAST END?
	RET	Z			; WE ARE DONE
	PUSH	BC			; SAVE UNIT
	CALL	UPRTDRV			; PROCESS THE UNIT
	POP	BC			; RESTORE UNIT
	INC	B			; NEXT UNIT
	JR	UPRTALL1		; LOOP
;
; PRINT THE UNA UNIT INFO
; ON INPUT B HAS UNIT
;
UPRTDRV:
	PUSH	BC			; SAVE UNIT
	PUSH	DE			; SAVE DISK TYPE
	LD	DE,STR_PREFIX		; NEWLINE AND SPACING
	CALL	WRITESTR		; PRINT IT
	LD	A,B			; DRIVE LETTER TO A
	ADD	A,'A'			; MAKE IT ALPHA
	CALL	COUT			; PRINT IT
	LD	A,':'			; DRIVE LETTER COLON
	CALL	COUT			; PRINT IT
	LD	A,'='			; SEPARATOR
	CALL	COUT			; PRINT IT
	POP	DE			; RECOVER DISK TYPE
	LD	A,D			; DISK TYPE TO A
	CP	$40			; RAM/ROM?
	JR	Z,UPRTDRV1		; HANDLE RAM/ROM
	LD	DE,UDEVIDE		; ASSUME IDE
	CP	$41			; IDE?
	JR	Z,UPRTDRV2		; PRINT IT
	LD	DE,UDEVSD		; ASSUME SD
	CP	$43			; SD?
	JR	Z,UPRTDRV2		; PRINT IT
	LD	DE,UDEVUNK		; OTHERWISE UNKNOWN
	JR	UPRTDRV2
;
UPRTDRV1:	; HANDLE RAM/ROM
	LD	C,$45			; UNA FUNC: GET DISK INFO
	LD	DE,$9000		; 512 BYTE BUFFER *** FIX!!! ***
	RST	08			; CALL UNA
	BIT	7,B			; TEST RAM DRIVE BIT
	LD	DE,UDEVROM		; ASSUME ROM
	JR	Z,UPRTDRV2		; IF SO, PRINT IT
	LD	DE,UDEVRAM		; OTHERWISE RAM
	JR	UPRTDRV2		; PRINT IT
;
UPRTDRV2:	; PRINT DEVICE
	POP	BC			; RECOVER UNIT
	CALL	WRITESTR		; PRINT DEVICE NAME
	LD	A,B			; UNIT TO A
	ADD	A,'0'			; MAKE IT PRINTABLE NUMERIC			
	CALL	COUT			; PRINT IT
	LD	A,':'			; DEVICE NAME COLON
	CALL	COUT			; PRINT IT
	RET				; DONE
;
UDEVRAM	.DB	"RAM$"
UDEVROM	.DB	"ROM$"
UDEVIDE	.DB	"IDE$"
UDEVSD	.DB	"SD$"
UDEVUNK	.DB	"UNK$"
;
#IF (DSKYENABLE)
;
;	
;__SEGDISPLAY________________________________________________________________________________________
;
;  DISPLAY CONTENTS OF DISPLAYBUF IN DECODED HEX BITS 0-3 ARE DISPLAYED DIG, BIT 7 IS DP     
;____________________________________________________________________________________________________
;
SEGDISPLAY:
	PUSH	AF			; STORE AF
	PUSH	BC			; STORE BC
	PUSH	HL			; STORE HL
	LD	BC,0007H	
	ADD	HL,BC
	LD	B,08H			; SET DIGIT COUNT
	LD	A,40H | 30H		; SET CONTROL PORT 7218 TO OFF
	OUT	(PPIC),A		; OUTPUT
	CALL 	DELAY			; WAIT
	LD	A,0F0H			; SET CONTROL TO 1111 (DATA COMING, HEX DECODE,NO DECODE, NORMAL)

SEGDISPLAY1:				;
	OUT	(PPIA),A		; OUTPUT TO PORT
	LD	A,80H | 30H		; STROBE WRITE PULSE WITH CONTROL=1
	OUT	(PPIC),A		; OUTPUT TO PORT
	CALL 	DELAY			; WAIT
	LD	A,40H | 30H		; SET CONTROL PORT 7218 TO OFF
	OUT	(PPIC),A		; OUTPUT

SEGDISPLAY_LP:		
	LD	A,(HL)			; GET DISPLAY DIGIT
	OUT	(PPIA),A		; OUT TO PPIA
	LD	A,00H | 30H		; SET WRITE STROBE
	OUT	(PPIC),A		; OUT TO PPIC
	CALL	DELAY			; DELAY
	LD	A,40H | 30H		; SET CONTROL PORT OFF
	OUT	(PPIC),A		; OUT TO PPIC
	CALL	DELAY			; WAIT
	DEC	HL			; INC POINTER
	DJNZ	SEGDISPLAY_LP		; LOOP FOR NEXT DIGIT
	POP	HL			; RESTORE HL
	POP	BC			; RESTORE BC
	POP	AF			; RESTORE AF
	RET
#ENDIF
;
;__TEXT_STRINGS_________________________________________________________________________________________________________________ 
;
;	STRINGS
;_____________________________________________________________________________________________________________________________
;
STR_BOOTDISK	.DB	"BOOT FROM DISK\r\n$"
STR_BOOTDISK1	.DB	"\r\nReading disk information...$"
STR_BOOTMON	.DB	"START MONITOR\r\n$"
STR_BOOTROM	.DB	"BOOT FROM ROM\r\n$"
STR_LIST	.DB	"LIST DRIVES\r\n$"
STR_INVALID	.DB	"INVALID SELECTION\r\n$"
STR_SETUP	.DB	"SYSTEM SETUP\r\n$"
STR_SIG		.DB	"SIGNATURE=$"
STR_CPMLOC	.DB	"LOC=$"
STR_CPMEND	.DB	"END=$"
STR_CPMENT	.DB	"ENT=$"
STR_LABEL	.DB	"LABEL=$"
STR_DRVLIST	.DB	"\r\nDrives:\r\n$"
STR_PREFIX	.DB	"\r\n   $"
STR_LOADING	.DB	"\r\nLoading$"
STR_NODISK	.DB	"\r\nNo disk!$"
STR_NOBOOT	.DB	"\r\nDisk not bootable!$"
STR_BOOTERR	.DB	"\r\nBoot failure!$"
;
STR_BANNER	.DB	"\r\n", PLATFORM_NAME, " Boot Loader$"
STR_BOOTMENU	.DB	"\r\nBoot: (M)onitor, (R)OM, (L)ist, or Drive Letter ===> $"
;
	.IF DSKYENABLE
BOOT:
;		  .    .               t     o    o      b
	.DB 	00H, 00H, 80H, 80H, 094H, 09DH, 09DH, 09FH
	.ENDIF
;
#DEFINE CIOMODE_HBIOS
#DEFINE	DSKY_KBD
#INCLUDE "util.asm"
;
; READ A CONSOLE CHARACTER AND CONVERT TO UPPER CASE
;
CINUC:
	CALL	CIN
	AND	7FH			; STRIP HI BIT
	CP	'A'			; KEEP NUMBERS, CONTROLS
	RET	C			; AND UPPER CASE
	CP	7BH			; SEE IF NOT LOWER CASE
	RET	NC
	AND	5FH			; MAKE UPPER CASE
	RET
;
;==================================================================================================
;   WORKING DATA STORAGE
;==================================================================================================
;
BL_STACKSIZ	.EQU	40H
		.FILL	BL_STACKSIZ,0
BL_STACK	.EQU	$
;
BL_SPT		.DB	16		; SECTORS PER TRACK FOR LOAD DEVICE
BL_LUTRK	.DW	0		; STARTING TRACK FOR LU
BL_CURTRK	.DW	0		; CURRENT TRACK FOR LOAD
BL_CURSEC	.DB	0		; CURRENT SECTOR FOR LOAD
BL_CURDMA	.DW	0		; CURRENT MEM LOC BEING LOADED
BL_COUNT	.DB	0		; LOAD COUNTER
BL_TIMEOUT	.DW	0		; AUTOBOOT TIMEOUT COUNTDOWN COUNTER
BL_DEVICE	.DB	0		; DEVICE TO LOAD FROM
BL_LU		.DB	0		; LU TO LOAD FROM
BL_UNAMOD	.DB	0		; UNA MODE FLAG, NONZERO IS UNA
;
#IF (PLATFORM == PLT_UNA)
DRVMAP		.EQU	0		; MANAGED DYNAMICALLY FOR UNA
#ELSE
;
#DEFINE		DRVENT(DEV,UNIT,SLICE,DPHADR) \
#DEFCONT	.DB	DEV | UNIT \
#DEFCONT	.DB	SLICE
;
		.DB	DRVCNT
DRVMAP:		DRVLST
;
DRVCNT		.EQU	($ - DRVMAP) / 2
		.ECHO	DRVCNT
		.ECHO	" drive letters defined.\n"
;
#ENDIF
;
; BOOT INFO SECTOR IS READ INTO AREA BELOW
; THE THIRD SECTOR OF A DISK DEVICE IS RESERVED FOR BOOT INFO
;
BL_INFOSEC	.EQU	$
		.FILL	(512 - 128),0
BB_METABUF	.EQU	$
BB_SIG		.DW	0	; SIGNATURE (WILL BE 0A55AH IF SET)
BB_PLATFORM	.DB	0	; FORMATTING PLATFORM
BB_DEVICE	.DB	0	; FORMATTING DEVICE
BB_FORMATTER	.FILL	8,0	; FORMATTING PROGRAM
BB_DRIVE	.DB	0	; PHYSICAL DISK DRIVE #
BB_LU		.DW	0	; LOGICAL UNIT (SLICE)
		.FILL	(BB_METABUF + 128) - $ - 32,0
BB_PROTECT	.DB	0	; WRITE PROTECT BOOLEAN
BB_UPDATES	.DW	0	; UPDATE COUNTER
BB_RMJ		.DB	0	; RMJ MAJOR VERSION NUMBER
BB_RMN		.DB	0	; RMN MINOR VERSION NUMBER
BB_RUP		.DB	0	; RUP UPDATE NUMBER
BB_RTP		.DB	0	; RTP PATCH LEVEL
BB_LABEL	.FILL	16,0	; 16 CHARACTER DRIVE LABEL
BB_TERM		.DB	0	; LABEL TERMINATOR ('$')
BB_BILOC	.DW	0	; LOC TO PATCH BOOT DRIVE INFO TO (IF NOT ZERO)
BB_CPMLOC	.DW	0	; FINAL RAM DESTINATION FOR CPM/CBIOS
BB_CPMEND	.DW	0	; END ADDRESS FOR LOAD
BB_CPMENT	.DW	0	; CP/M ENTRY POINT (CBIOS COLD BOOT)
;
;==================================================================================================
;   FILL REMAINDER OF BANK
;==================================================================================================
;
SLACK:		.EQU	(9000H - $)
		.FILL	SLACK
;
		.ECHO	"LOADER space remaining: "
		.ECHO	SLACK
		.ECHO	" bytes.\n"
	.END
