;
;==================================================================================================
;   FLOPPY DISK DRIVER
;==================================================================================================
;
; TODO:
;
;
; PORTS
;
#IF ((FDMODE == FDMODE_DIO) | (FDMODE == FDMODE_ZETA) | (FDMODE == FDMODE_DIO3))
FDC_MSR:	.EQU	036H		; 8272 MAIN STATUS REGISTER
FDC_DATA:	.EQU	037H		; 8272 DATA PORT
FDC_DIR:	.EQU	038H		; DATA INPUT REGISTER
FDC_DOR:	.EQU	03AH		; DIGITAL OUTPUT REGISTER (LATCH)
FDC_DMA:	.EQU	03CH		; PSEUDO DMA DATA PORT
#ENDIF
#IF (FDMODE == FDMODE_DIDE)
FDC_BID:	.EQU	00100000B		; IO RANGE 20H-3FH
FDC_MSR:	.EQU	FDC_BID | 01010B	; 8272 MAIN STATUS REGISTER
FDC_DATA:	.EQU	FDC_BID | 01011B	; 8272 DATA PORT
FDC_DOR:	.EQU	FDC_BID | 01100B	; DOR
FDC_DCR:	.EQU	FDC_BID | 01101B	; DCR
FDC_DACK:	.EQU	FDC_BID | 11100B	; DACK
FDC_TC		.EQU	FDC_BID | 11101B	; TERMINAL COUNT (W/ DACK)
FDC_DMA:	.EQU	03CH			; NOT USED BY DIDE
#ENDIF
#IF (FDMODE == FDMODE_N8)
FDC_MSR:	.EQU	08CH	; 8272 MAIN STATUS REGISTER
FDC_DATA:	.EQU	08DH	; 8272 DATA PORT
FDC_DOR:	.EQU	092H	; DOR
FDC_DCR:	.EQU	091H	; DCR
FDC_DACK:	.EQU	090H	; DACK
FDC_TC		.EQU	093H	; TERMINAL COUNT (W/ DACK)
FDC_DMA:	.EQU	03CH	; NOT USED BY N8
#ENDIF
;
; FDC RESULT CODES
;
FRC_OK		.EQU	0		; 00
FRC_NOTIMPL	.EQU	-01H		; FF
FRC_CMDERR	.EQU	-02H		; FE
FRC_ERROR	.EQU	-03H		; FD
FRC_ABORT	.EQU	-04H		; FC
FRC_BUFMAX	.EQU	-05H		; FB
FRC_ABTERM	.EQU	-08H		; F8	
FRC_INVCMD	.EQU	-09H		; F7
FRC_DSKCHG	.EQU	-0AH		; F6
FRC_ENDCYL	.EQU	-0BH		; F5
FRC_DATAERR	.EQU	-0CH		; F4
FRC_OVERRUN	.EQU	-0DH		; F3
FRC_NODATA	.EQU	-0EH		; F2
FRC_NOTWRIT	.EQU	-0FH		; F1
FRC_MISADR	.EQU	-10H		; F0
FRC_TOFDCRDY	.EQU	-11H		; EF
FRC_TOSNDCMD	.EQU	-12H		; EE
FRC_TOGETRES	.EQU	-13H		; ED
FRC_TOEXEC	.EQU	-14H		; EC
FRC_TOSEEKWT	.EQU	-15H		; EB
;
#IF (FDTRACE > 0)
;
; FDC STATUS CODE STRINGS
;
FSS_OK		.TEXT	"OK$"
FSS_NOTIMPL	.TEXT	"NOT IMPLEMENTED$"
FSS_CMDERR	.TEXT	"COMMAND ERROR$"
FSS_ERROR	.TEXT	"ERROR$"
FSS_ABORT	.TEXT	"ABORT$"
FSS_BUFMAX	.TEXT	"BUFFER EXCEEDED$"
FSS_ABTERM	.TEXT	"ABNORMAL TERMINATION$"
FSS_INVCMD	.TEXT	"INVALID COMMAND$"
FSS_DSKCHG	.TEXT	"DISK CHANGE$"
FSS_ENDCYL	.TEXT	"END OF CYLINDER$"
FSS_DATAERR	.TEXT	"DATA ERROR$"
FSS_OVERRUN	.TEXT	"OVERRUN$"
FSS_NODATA	.TEXT	"NO DATA$"
FSS_NOTWRIT	.TEXT	"NOT WRITABLE$"
FSS_MISADR	.TEXT	"MISSING ADDRESS MARK$"
FSS_TOFDCRDY	.TEXT	"FDC READY TIMEOUT$"
FSS_TOSNDCMD	.TEXT	"SENDCMD TIMEOUT$"
FSS_TOGETRES	.TEXT	"GET RESULTS TIMEOUT$"
FSS_TOEXEC	.TEXT	"EXEC TIMEOUT$"
FSS_TOSEEKWT	.TEXT	"SEEK WAIT TIMEOUT$"
;
; FDC STATUS STRING TABLE
;
FSST:		.DB 	FRC_OK \ 	.DW	FSS_OK
FSST_ENTSIZ	.EQU	$ - FSST
		.DB 	FRC_NOTIMPL \	.DW	FSS_NOTIMPL
		.DB	FRC_CMDERR \	.DW	FSS_CMDERR
		.DB	FRC_ERROR \	.DW	FSS_ERROR
		.DB	FRC_ABORT \	.DW	FSS_ABORT
		.DB	FRC_BUFMAX \	.DW	FSS_BUFMAX
		.DB	FRC_ABTERM \	.DW	FSS_ABTERM
		.DB	FRC_INVCMD \	.DW	FSS_INVCMD
		.DB	FRC_DSKCHG \	.DW	FSS_DSKCHG
		.DB	FRC_ENDCYL \	.DW	FSS_ENDCYL
		.DB	FRC_DATAERR \	.DW	FSS_DATAERR
		.DB	FRC_OVERRUN \	.DW	FSS_OVERRUN
		.DB	FRC_NODATA \	.DW	FSS_NODATA
		.DB	FRC_NOTWRIT \	.DW	FSS_NOTWRIT
		.DB	FRC_MISADR \	.DW	FSS_MISADR
		.DB	FRC_TOFDCRDY \	.DW	FSS_TOFDCRDY
		.DB	FRC_TOSNDCMD \	.DW	FSS_TOSNDCMD
		.DB	FRC_TOGETRES \	.DW	FSS_TOGETRES
		.DB	FRC_TOEXEC \	.DW	FSS_TOEXEC
		.DB	FRC_TOSEEKWT \	.DW	FSS_TOSEEKWT
FSST_COUNT	.EQU	(($ - FSST) / FSST_ENTSIZ)	; # ENTRIES IN TABLE
#ENDIF
;
; FDC COMMANDS
;
CMD_READ	.EQU	00000110B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,DTL --> ST0,ST1,ST2,C,H,R,N
CMD_READDEL	.EQU	00001100B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,DTL --> ST0,ST1,ST2,C,H,R,N
CMD_WRITE	.EQU	00000101B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,DTL --> ST0,ST1,ST2,C,H,R,N
CMD_WRITEDEL	.EQU	00001001B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,DTL --> ST0,ST1,ST2,C,H,R,N
CMD_READTRK	.EQU	00000010B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,DTL --> ST0,ST1,ST2,C,H,R,N
CMD_READID	.EQU	00001010B	; CMD,HDS/DS --> ST0,ST1,ST2,C,H,R,N
CMD_FMTTRK	.EQU	00001101B	; CMD,HDS/DS,N,SC,GPL,D --> ST0,ST1,ST2,C,H,R,N
CMD_SCANEQ	.EQU	00010001B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,STP --> ST0,ST1,ST2,C,H,R,N
CMD_SCANLOEQ	.EQU	00011001B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,STP --> ST0,ST1,ST2,C,H,R,N
CMD_SCANHIEQ	.EQU	00011101B	; CMD,HDS/DS,C,H,R,N,EOT,GPL,STP --> ST0,ST1,ST2,C,H,R,N
CMD_RECAL	.EQU	00000111B	; CMD,DS --> <EMPTY>
CMD_SENSEINT	.EQU	00001000B	; CMD --> ST0,PCN
CMD_SPECIFY	.EQU	00000011B	; CMD,SRT/HUT,HLT/ND --> <EMPTY>
CMD_DRVSTAT	.EQU	00000100B	; CMD,HDS/DS --> ST3
CMD_SEEK	.EQU	00001111B	; CMD,HDS/DS --> <EMPTY>
CMD_VERSION	.EQU	00010000B	; CMD --> ST0
;
; STATIC CONFIGURATION, NEVER CHANGES (PRIVATE)
;
FCD_MT		.EQU	000H		; MULTI-TRACK, WE DON'T USE, SET TO 0
FCD_MFM		.EQU	001H		; MFM, 0=FM, 1=MFM, WE USE MFM ALWAYS
FCD_SK		.EQU	000H		; SKIP MODE, WE DON'T USE, SET TO 0
FCD_N		.EQU	002H		; SECTOR SIZE, N=2 FOR 512 BYTES
FCD_DTL		.EQU	0FFH		; DATA LENGTH (WHEN N=0, SET TO FF OTHERWISE)
FCD_STP		.EQU	001H		; SECTOR SCAN TYPE, 1=CONTIG, 2=ALTERNATING
;
FCD_PC720	.DB	050H		; NUMBER OF CYLINDERS
		.DB	002H		; NUMBER OF HEADS
		.DB	009H		; NUMBER OF SECTORS
		.DB	001H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
		.DB	009H		; SECTOR COUNT
		.DW	200H		; SECTOR SIZE IN BYTES
		.DB	02AH		; GAP LENGTH (R/W)
		.DB	050H		; GAP LENGTH (FORMAT)
		.DB	0DFH		; SRT/HUT: STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
		.DB	005H		; HLT/ND: HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
		.DB	DOR_BR250	; DOR
		.DB	DCR_BR250	; DCR
		.IF	(($ - FCD_PC720) != FCD_LEN)
		.ECHO	"*** FCD_PC720 SIZE ERROR!!! ***\n"
		.ENDIF
;
FCD_PC144	.DB	050H		; NUMBER OF CYLINDERS
		.DB	002H		; NUMBER OF HEADS
		.DB	012H		; NUMBER OF SECTORS
		.DB	001H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
		.DB	012H		; SECTOR COUNT
		.DW	200H		; SECTOR SIZE IN BYTES
		.DB	01BH		; GAP LENGTH (R/W)
		.DB	06CH		; GAP LENGTH (FORMAT)
		.DB	0DFH		; SRT/HUT: STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
		.DB	009H		; HLT/ND: HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
		.DB	DOR_BR500	; DOR
		.DB	DCR_BR500	; DCR
		.IF	(($ - FCD_PC144) != FCD_LEN)
		.ECHO	"*** FCD_PC144 SIZE ERROR!!! ***\n"
		.ENDIF
;
FCD_PC360	.DB	028H		; NUMBER OF CYLINDERS
		.DB	002H		; NUMBER OF HEADS
		.DB	009H		; NUMBER OF SECTORS
		.DB	001H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
		.DB	009H		; SECTOR COUNT
		.DW	200H		; SECTOR SIZE IN BYTES
		.DB	02AH		; GAP LENGTH (R/W)
		.DB	050H		; GAP LENGTH (FORMAT)
		.DB	0DFH		; SRT/HUT: STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
		.DB	005H		; HLT/ND: HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
		.DB	DOR_BR250	; DOR
		.DB	DCR_BR250	; DCR
		.IF	(($ - FCD_PC360) != FCD_LEN)
		.ECHO	"*** FCD_PC360 SIZE ERROR!!! ***\n"
		.ENDIF
;
FCD_PC120	.DB	050H		; NUMBER OF CYLINDERS
		.DB	002H		; NUMBER OF HEADS
		.DB	00FH		; NUMBER OF SECTORS
		.DB	001H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
		.DB	00FH		; SECTOR COUNT
		.DW	200H		; SECTOR SIZE IN BYTES
		.DB	01BH		; GAP LENGTH (R/W)
		.DB	054H		; GAP LENGTH (FORMAT)
		.DB	0DFH		; SRT/HUT: STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
		.DB	009H		; HLT/ND: HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
		.DB	DOR_BR500	; DOR
		.DB	DCR_BR500	; DCR
		.IF	(($ - FCD_PC120) != FCD_LEN)
		.ECHO	"*** FCD_PC120 SIZE ERROR!!! ***\n"
		.ENDIF
;
FCD_PC111	.DB	04AH		; NUMBER OF CYLINDERS
		.DB	002H		; NUMBER OF HEADS
		.DB	00FH		; NUMBER OF SECTORS
		.DB	001H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
		.DB	00FH		; SECTOR COUNT
		.DW	200H		; SECTOR SIZE IN BYTES
		.DB	01BH		; GAP LENGTH (R/W)
		.DB	054H		; GAP LENGTH (FORMAT)
		.DB	0DFH		; SRT/HUT: STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
		.DB	009H		; HLT/ND: HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
		.DB	DOR_BR500	; DOR
		.DB	DCR_BR500	; DCR
		.IF	(($ - FCD_PC111) != FCD_LEN)
		.ECHO	"*** FCD_PC111 SIZE ERROR!!! ***\n"
		.ENDIF
;
; FCD LOOKUP TABLE (CALLED TO SET HL TO ADDRESS OF MEDIA DATA ABOVE)
; ENTRIES BELOW MUST MATCH COUNT AND VALUES OF FDMXXX IN STD.ASM
;
FCD_TBL:
		LD	HL,FCD_PC720 \ RET	; FDM720 = 0
		LD	HL,FCD_PC144 \ RET	; FDM144 = 1
		LD	HL,FCD_PC360 \ RET	; FDM360 = 2
		LD	HL,FCD_PC120 \ RET	; FDM120 = 3
		LD	HL,FCD_PC111 \ RET	; FDM111 = 4
;
; DOR BITS (3AH)									
;
;	DISKIO			250KBPS		500KBPS
;	-------			-------		-------
;D7	/DC/RDY			1 (N/A)		1 (N/A)
;D6	/REDWC (DENSITY)	0 (DD)		1 (HD)
;D5	P0* (PRECOMP BIT 0)	1 \		0 \
;D4	P1* (PRECOMP BIT 1)	0 (125NS)	1 (125NS)
;D3	P2* (PRECOMP BIT 2)	0 /		0 /
;D2	MINI (BITRATE)		1 (250KBPS)	0 (500KBPS)
;D1	/MOTOR (ACTIVE LO)	1 (OFF)		1 (OFF)
;D0	TC (TERMINAL COUNT)	0 (OFF)		0 (OFF)
;
; *NOTE: FOR 9229 DATA SEPARATOR USED IN DISKIO, VALUE OF PRECOMP BITS CHANGES WITH MINI
; IF MINI=1 (250KBPS), USE 001 FOR 125NS PRECOMP, IF MINI=0, USE 010 FOR 125NS PRECOMP
;
#IF (FDMODE == FDMODE_DIO)
DOR_BR250	.EQU	10100100B	; 250KBPS W/ MOTOR ON
DOR_BR500	.EQU	11010000B	; 500KBPS W/ MOTOR ON
DOR_INIT	.EQU	11010010B	; INITIAL DEFAULT LATCH VALUE
#ENDIF
;
;	ZETA/DISKIO3		250KBPS		500KBPS
;	------------		-------		-------
;D7	/FDC_RST		1 (RUN)		1 (RUN)
;D6	DENSEL			1 (DD)		0 (HD)
;D5	P0 (PRECOMP BIT 0)	1 \		1 \
;D4	P1 (PRECOMP BIT 1)	0 (125NS)	0 (125NS)
;D3	P2 (PRECOMP BIT 2)	0 /		0 /
;D2	MINI (BITRATE)		1 (250KBPS)	0 (500KBPS)
;D1	MOTOR			0 (OFF)		0 (OFF)
;D0	TC			0 (OFF)		0 (OFF)
;
; MOTOR AND DENSITY SELECT ARE INVERTED ON ZETA/DISKIO3
;
#IF ((FDMODE == FDMODE_ZETA) | (FDMODE == FDMODE_DIO3))
DOR_BR250	.EQU	11100110B	; 250KBPS W/ MOTOR ON
DOR_BR500	.EQU	10100010B	; 500KBPS W/ MOTOR ON
DOR_INIT	.EQU	10100000B	; INITIAL DEFAULT LATCH VALUE
#ENDIF
;
; *** DIDE/N8 ***
;
#IF ((FDMODE == FDMODE_DIDE) | (FDMODE == FDMODE_N8))
DOR_INIT	.EQU	00001100B	; SOFT RESET INACTIVE, DMA ENABLED
DOR_BR250	.EQU	DOR_INIT
DOR_BR500	.EQU	DOR_INIT
#ENDIF
;
; DCR (ONLY APPLIES TO DIDE AND N8)
;
DCR_BR250	.EQU	01H		; 250KBPS
DCR_BR500	.EQU	00H		; 500KBPS
;
#IF (FDTRACE > 0)
;
; FDC COMMAND STRINGS
;
FCS_NOP:		.TEXT	"NOP$"
FCS_READ:		.TEXT	"READ$"
FCS_READDEL:		.TEXT	"READDEL$"
FCS_WRITE:		.TEXT	"WRITE$"
FCS_WRITEDEL:		.TEXT	"WRITEDEL$"
FCS_READTRK:		.TEXT	"READTRK$"
FCS_READID:		.TEXT	"READID$"
FCS_FMTTRK:		.TEXT	"FMTTRK$"
FCS_SCANEQ:		.TEXT	"SCANEQ$"
FCS_SCANLOEQ:		.TEXT	"SCANLOEQ$"
FCS_SCANHIEQ:		.TEXT	"SCANHIEQ$"
FCS_RECAL:		.TEXT	"RECAL$"
FCS_SENSEINT:		.TEXT	"SENSEINT$"
FCS_SPECIFY:		.TEXT	"SPECIFY$"
FCS_DRVSTAT:		.TEXT	"DRVSTAT$"
FCS_SEEK:		.TEXT	"SEEK$"
FCS_VERSION:		.TEXT	"VER$"
;
; FDC COMMAND TABLE
;
FCT		.DB 	CMD_READ \	.DW	FCS_READ
FCT_ENTSIZ	.EQU	$ - FCT
		.DB 	CMD_READDEL \	.DW	FCS_READDEL
		.DB 	CMD_WRITE \	.DW	FCS_WRITE
		.DB 	CMD_WRITEDEL \	.DW	FCS_WRITEDEL
		.DB 	CMD_READTRK \	.DW	FCS_READTRK
		.DB 	CMD_READID \	.DW	FCS_READID
		.DB 	CMD_FMTTRK \	.DW	FCS_FMTTRK
		.DB 	CMD_SCANEQ \	.DW	FCS_SCANEQ
		.DB 	CMD_SCANLOEQ \	.DW	FCS_SCANLOEQ
		.DB 	CMD_SCANHIEQ \	.DW	FCS_SCANHIEQ
		.DB 	CMD_RECAL \	.DW	FCS_RECAL
		.DB 	CMD_SENSEINT \	.DW	FCS_SENSEINT
		.DB 	CMD_SPECIFY \	.DW	FCS_SPECIFY
		.DB 	CMD_DRVSTAT \	.DW	FCS_DRVSTAT
		.DB 	CMD_SEEK \	.DW	FCS_SEEK
		.DB 	CMD_VERSION \	.DW	FCS_VERSION
FCT_COUNT	.EQU	(($ - FCT) / FCT_ENTSIZ)	; # ENTRIES IN TABLE
#ENDIF
;
;
;
FD_DISPATCH:
	LD	A,B		; GET REQUESTED FUNCTION
	AND	$0F
	JR	Z,FD_RD
	DEC	A
	JR	Z,FD_WR
	DEC	A
	JR	Z,FD_ST
	DEC	A
	JR	Z,FD_MED
	CALL	PANIC
;
FD_RD:
	JP	FD_READ
FD_WR:
	JP	FD_WRITE
FD_ST:
	JP	FD_STATUS
FD_MED:
	JP	FD_MEDIA
;
; FD_MEDIA
;
FD_MEDIA:
	CALL	FD_SELECTUNIT

#IF (FDMAUTO)
	; SETUP TO READ TRK 0, HD 0, SEC 0
	LD	A,C			; C STILL HAS REQUESTED DRIVE
	AND	0FH
	LD	(FCD_DS),A
	LD	A,0
	LD	(FCD_C),A
	LD	(FCD_H),A
	INC	A
	LD	(FCD_R),A
	LD	A,DOP_READID
	LD	(FCD_DOP),A

#IF (FDTRACE < 3)
	; SUPPRESS TRACING FOR MEDIA TESTS
	LD	A,0
	LD	(FCD_TRACE),A
#ENDIF

	LD	B,5

FD_MEDIARETRY:
	; TRY PRIMARY MEDIA CHOICE FIRST
	LD	A,FDMEDIA
	CALL	FD_TESTMEDIA
	JR	Z,FD_MEDIA3			; IF SUCCESS, WE ARE DONE
	
	; TRY ALTERNATE MEDIA CHOICE
	LD	A,FDMEDIAALT
	CALL	FD_TESTMEDIA
	JR	Z,FD_MEDIA3			; IF SUCCESS, WE ARE DONE
	
	DJNZ	FD_MEDIARETRY
	
	; NO JOY, RETURN WITH A=0 (NO MEDIA)
	XOR	A
	RET

FD_TESTMEDIA:
	LD	HL,(FDDS_MEDIAADR)
	LD	(HL),A
	PUSH	BC
	CALL	FD_START
	POP	BC
	RET
	
FD_MEDIA3:

#IF (FDTRACE < 3)
	; RESTORE TRACING FOR MEDIA TESTS
	LD	A,FDTRACE
	LD	(FCD_TRACE),A
#ENDIF
#ENDIF

#IF (FDTRACE >= 3)
	LD	DE,FDSTR_SELECT
	CALL	WRITESTR
	LD	BC,(FDDS_MEDIAADR)
	CALL	PRTHEXWORD
#ENDIF

	; LOAD THE MEDIA BYTE
	LD	HL,(FDDS_MEDIAADR)
	LD	A,(HL)
	ADD	A,MID_FD720		; ASSUMES MID_ VALUES ARE IN SAME ORDER AS FDM VALUES

#IF (FDTRACE >= 3)
	CALL	PC_SPACE
	CALL	PRTHEXBYTE
#ENDIF
	RET
;
; FD_INIT
;
FD_INIT:
	PRTS("FD: IO=0x$")
	LD	A,FDC_MSR
	CALL	PRTHEXBYTE
	PRTS(" UNITS=2$")
;
	LD	A,FDMEDIA
	LD	(FCD_U0MEDIA),A
	LD	(FCD_U1MEDIA),A
	LD	A,0FEH
	LD	(FCD_U0TRK),A
	LD	(FCD_U1TRK),A

	LD	A,FDTRACE
	LD	(FCD_TRACE),A

	LD	BC,0
	LD	(FCD_IDLECNT),BC

	LD	A,DOR_INIT
	LD	(FST_DOR),A

	CALL	FC_RESETFDC
	CALL	FD_CLRDSKCHG
	
	LD	A,TRUE
	LD	(FCD_FDCRDY),A

	RET
;
; FD_IDLE QUIESCES THE FLOPPY SUBSYSTEM (MOTOR OFF)
; AFTER BEING CALLED ENOUGH TIMES...
; SHOULD IT INVALIDATE THE BUFFER???
;
FD_IDLE:
	LD	BC,(FCD_IDLECNT)
	LD	A,B
	OR	C
	RET	Z			; COUNTER ALREADY FIRED
	
	DEC	BC			; DECREMENT COUNTER
	LD	(FCD_IDLECNT),BC	; SAVE IT
	LD	A,B
	OR	C
	RET	NZ			; STILL COUNTING DOWN, RETURN

	CALL	FC_MOTOROFF		; COUNTER JUST EXPIRED, SHUTDOWN MOTOR!
	RET
;
; FD_STATUS
;
FD_STATUS:
	CALL	FD_SELECTUNIT
	LD	HL,(FDDS_TRKADR)
	LD	A,(HL)			; A = CURRENT TRACK
	
	CP	0FFH			; IS CURRENT TRACK = $FF?
	JR	Z,FD_STATUS1		; IF SO, NOT READY
	
	XOR	A			; A = 0 = OK
	RET				; RETURN

FD_STATUS1:
	OR	A			; A ALREADY = $FF, JUST SET FLAGS
	RET
;
; FD_CLRDSKCHG
;
FD_CLRDSKCHG:
	; PROCESS ANY PENDING DISK CHANGE NOTIFICATIONS
	LD	B,5
FD_CLRDSKCHG1:
	PUSH	BC
	CALL	FC_SENSEINT
	POP	BC
	LD	A,(FST_RC)
	CP	FRC_DSKCHG
	RET	NZ			; NO MORE DISK CHANGE NOTIFICATIONS
	DJNZ	FD_CLRDSKCHG1
;
; FD_WTSEEK
;	
; WAIT FOR PENDING SEEK OPERATION TO COMPLETE BY POLLING SENSEINT
; AND WAITING FOR ABTERM OR OK.
;
FD_WTSEEK:
	LD	BC,1000H

FD_WTSEEKLOOP:
	PUSH	BC
	CALL	FC_SENSEINT
	POP	BC
	
	LD	A,(FST_RC)		; CHECK RC
	CP	FRC_ABTERM		; ABTERM = DONE/FAILED
	JR	Z,FD_RETRC
	CP	FRC_OK			; OK = DONE/SUCCESS
	JR	Z,FD_RETRC
	
	DEC	BC			; CHECK LOOP COUNTER IN BC
	LD	A,B			; "
	OR	C			; "
	JR	NZ,FD_WTSEEKLOOP	; LOOP UNTIL COUNTER EXHAUSTED
	
FD_RETRC:
	LD	A,(FST_RC)
	OR	A
	RET				; TIMEOUT/FAILED
;	
; FD_FDCRESET
;
FD_FDCRESET:
	CALL	FC_RESETFDC

	CALL	FD_CLRDSKCHG
	
	LD	A,TRUE
	LD	(FCD_FDCRDY),A

	; MARK ALL DRIVES AS NEEDING RECALIBRATION
	; NOTE THAT IF THE VALUE IS CURRENT $FF, 
	; WE NEED TO LEAVE IT ALONE, SO WE 'OR' IN THE
	; $FE TO AVOID THIS SCENARIO.
	LD	A,(FCD_U0TRK)
	OR	0FEH
	LD	(FCD_U0TRK),A
	
	LD	A,(FCD_U1TRK)
	OR	0FEH
	LD	(FCD_U1TRK),A

	RET
;
; FD_DRIVERESET
;	
; ATTEMPT TO FULLY RESET FLOPPY DRIVE, PRIMARILY RECALIBRATE
;
FD_DRIVERESET:
	CALL	FC_SPECIFY
	RET	NZ			; ERROR, BAIL OUT
	
	CALL	FC_RECAL
	RET	NZ			; ERROR, BAIL OUT

	; FIRST RECAL MAY FAIL TO REACH TRACK 0
	; SO WE TRY ONCE MORE IN CASE OF A FAILURE
	CALL	FD_WTSEEK
	RET	Z

	; SECOND TRY, ONLY IF NEEDED
	CALL	FC_RECAL
	RET	NZ			; ERROR, BAIL OUT

	CALL	FD_WTSEEK
	RET
;
;
;
FD_SELECTUNIT:
	LD	A,C
	AND	0FH		; ISOLATE THE UNIT NIBBLE

	; GOOD PLACE FOR AN INTEGRITY CHECK
	CP	2
	CALL	NC,PANIC

	LD	HL,FCD_UNITS
	LD	D,0
	AND	0FH
	RLCA
	LD	E,A
	ADD	HL,DE

	LD	(FDDS_TRKADR),HL	; LOAD TRKADR
	INC	HL			; SKIP TRK
	LD	(FDDS_MEDIAADR),HL	; LOAD MEDIAADR

	RET
	
FD_READ:
	LD	A,DOP_READ
	JR	FD_RUN
;
FD_WRITE:
	LD	A,DOP_WRITE
	JR	FD_RUN
;
FD_RUN:
	LD	(FCD_DOP),A

	; UPDATE DRIVE SELECTION
	LD	A,(HSTDSK)		; GET THE NEW DRIVE SELECTION
	AND	0FH
	LD	(FCD_DS),A		; UPDATE FCD_DS TO NEW VALUE
	LD	C,A
	CALL	FD_SELECTUNIT
	
	; MAP HSTTRK TO FCD_H, FCD_C
	LD	BC,(HSTTRK)
	LD	A,C			; HEAD IS LOW ORDER BIT
	AND	1			; ISOLATE IT
	LD	(FCD_H),A		; SAVE IT
	LD	A,C			; LOAD TRACK IN A
	SRL	A			; DIVIDE BY 2 FOR PHYSICAL TRACK
	LD	(FCD_C),A		; SAVE IT

	; MAP HSTSEC TO FCD_R
	LD	BC,(HSTSEC)
	LD	A,C
	INC	A			; SWITCH FROM ZERO BASED TO ONE BASED
	LD	(FCD_R),A
	
	; SET RETRY COUNTER
	LD	B,5
FD_RETRY:
	PUSH	BC
	CALL	FD_START
	POP	BC

	LD	A,(FST_RC)		; CHECK RESULT
	OR	A
	RET	Z			; SUCCESS
	
	DJNZ	FD_RETRY		; RETRY TILL COUNTER EXHAUSTED
	
#IF (FDTRACE == 1)
	CALL	FC_PRTRESULTS
#ENDIF

	LD	A,(FST_RC)
	OR	A			; OTHERWISE SET FLAGS BASED ON RC (IN A)
	RET				; AND GIVE UP
;
;
;
FD_START:
	LD	A,(FCD_FDCRDY)
	CP	TRUE
	CALL	NZ,FD_FDCRESET

	; COPY MEDIA CONFIG INTO FCD
	; THIS IS HERE TO ACCOMMODATE DIFFERENT MEDIA
	; IN DIFFERENT FLOPPY UNITS.
	LD	HL,(FDDS_MEDIAADR)
	LD	A,(HL)		; A = MEDIA BYTE
	RLCA			; TABLE IS 4 BYTE ENTRIES
	RLCA			; A = A * 4
	LD	HL,FCD_TBL	; HL = START OF TABLE
	LD	D,0		; SET DE TO TABLE OFFSET
	LD	E,A
	ADD	HL,DE		; OFFSET BASED ON DESIRED MEDIA
	CALL	JPHL		; CALL THE TABLE ENTRY (SEE FCD_TBL)
	LD	DE,FCD		; DE = DESTINATION
	LD	BC,FCD_LEN	; BC = BYTES TO COPY
	LDIR			; BYTES COPY FROM MDB TO FCD

	CALL	FC_MOTORON	; INCLUDES LATCH SETUP

	LD	HL,(FDDS_TRKADR)
	LD	A,(HL)
	CP	0FEH		; FF = DRIVE NEEDS TO BE RESET
	JR	C,FD_RUN0	; NO RESET NEEDED, BYPASS

	CALL	FD_DRIVERESET
	JR	NZ,FD_RUNERR
	
	; RECORD CURRENT TRACK POSITION
	LD	A,0
	LD	HL,(FDDS_TRKADR)
	LD	(HL),A

FD_RUN0:
	; COMPARE CURRENT TRACK WITH REQUESTED TRACK TO SEE IF SEEK NEEDED
	LD	HL,(FDDS_TRKADR)
	LD	A,(HL)
	LD	B,A
	LD	A,(FCD_C)
	CP	B
	JR	Z,FD_RUN1	; FDDS_TRKADR == FCD_C, SKIP SEEK
	
	; INITIATE SEEK TO NEW TRACK
	CALL	FC_SEEK
	JR	NZ,FD_RUNERR

	; WAIT FOR SEEK TO COMPLETE
	CALL	FD_WTSEEK
	JR	NZ,FD_RUNERR
	
	; RECORD NEW CURRENT TRACK
	LD	A,(FCD_C)
	LD	HL,(FDDS_TRKADR)
	LD	(HL),A
	
FD_RUN1:
	; GET THE REQUESTED OPERATION
	LD	A,(FCD_DOP)
	
	; SETUP RETURN ADDRESS
	LD	HL,FD_RUNCHK
	PUSH	HL

	; DISPATCH TO FUNCTION
	CP	DOP_READ
	JR	Z,FC_READ
	CP	DOP_WRITE
	JR	Z,FC_WRITE
	CP	DOP_READID
	JR	Z,FC_READID
	CALL	PANIC

FD_RUNCHK:
#IF (DSKYENABLE)
	CALL	FD_DSKY
#ENDIF

FD_RUNEXIT:
	LD	A,(FST_RC)
	OR	A
	RET	Z

FD_RUNERR:
	; INDICATE THAT A CONTROLLER RESET IS DESIRED
	LD	A,FALSE
	LD	(FCD_FDCRDY),A

	; FLAG DRIVE IN ERROR STATUS BY SETTING TRKADR == FF
	LD	A,0FFH
	LD	HL,(FDDS_TRKADR)
	LD	(HL),A

	JP	FD_RETRC

#IF (DSKYENABLE)
FD_DSKY:
	LD	HL,DSKY_HEXBUF
	LD	A,(FCD_C)
	LD	(HL),A
	INC	HL
	LD	A,(FCD_R)
	LD	(HL),A
	INC	HL
	LD	A,(FRB_ST0)
	LD	(HL),A
	INC	HL
	LD	A,(FRB_ST1)
	LD	(HL),A
	CALL	DSKY_HEXOUT
	RET
#ENDIF
;
;===============================================================================
; FLOPPY DISK CONTROL SERVICES (PHYSICAL DEVICE CONTROL FOR FDC HARDWARE)
;===============================================================================
;
; ENTRY POINTS FOR FDC COMMANDS
;
FC_READ:
	LD	A,CMD_READ | 11100000B
	CALL	FC_SETUPIO
	JP	FOP

FC_WRITE:
	LD	A,CMD_WRITE | 11000000B
	CALL	FC_SETUPIO
	JP	FOP

FC_READID:
	LD	A,CMD_READID | 01000000B
	CALL	FC_SETUPCMD
	JP	FOP
	
FC_RECAL:
	LD	A,CMD_RECAL | 00000000B
	CALL	FC_SETUPCMD
	JP	FOP		; FIX: DO WE NEED TO REMOVE HDS BITS FROM SECOND BYTE?

FC_SENSEINT:
	LD	A,CMD_SENSEINT | 00000000B
	CALL	FC_SETUPCMD
	LD	A,1		; GENERIC COMMAND, BUT JUST FIRST COMMAND CODE
	LD	(FCP_LEN),A
	JP	FOP

FC_SPECIFY:
	LD	A,CMD_SPECIFY | 00000000B
	CALL	FC_SETUPSPECIFY
	JP	FOP

FC_DRVSTAT:
	LD	A,CMD_DRVSTAT | 00000000B
	CALL	FC_SETUPCMD
	JP	FOP

FC_SEEK:
	LD	A,CMD_SEEK | 00000000B
	CALL	FC_SETUPSEEK
	JP	FOP
;
; HELPER FUNCTIONS TO SETUP CMDBUF
;
FC_SETUPCMD:
	; TRICKY...  THE INCOMING BYTE IN A MUST CONTAIN THE COMMAND CODE ITSELF
	; IN THE LOW 5 BITS PLUS IT MUST SET WHICH OF THE DESIRED BITS IT WANTS
	; IN THE HIGH 3 BITS.  WE 'AND' THIS WITH THE TEMPATE BITS TO PRODUCE
	; THE CORRECT FINAL COMMAND BYTE
	LD	DE,FCP_BUF
	AND	5FH			; MT=0, MFM=1, SK=0, CMD=11111
	LD	(DE),A			; SAVE THE BYTE
	AND	00011111B		; ISOLATE JUST THE COMMAND BITS
	LD	(FCP_CMD),A		; SAVE IT FOR LATER
	INC	DE

	LD	A,(FCD_H)		; START WITH HDS	
	AND	01H			; MASK TO REMOVE IRRELEVANT BITS FOR SAFETY
	RLCA				; MAKE ROOM FOR DS BITS
	RLCA				; 
	LD	B,A			; SAVE WHAT WE HAVE SO FAR IN B
	LD	A,(FCD_DS)		; GET DS VALUE
	AND	03H			; MASK TO REMOVE IRRELEVANT BITS FOR SAFETY
	OR	B			; COMBINE WITH SAVED
	LD	(DE),A			; SAVE THE BYTE
	INC	DE
	
	LD	A,2			; LENGTH IS 2 BYTES AT THIS POINT
	LD	(FCP_LEN),A

	RET

FC_SETUPIO:
	CALL	FC_SETUPCMD

	LD	A,(FCD_C)
	LD	(DE),A
	INC	DE
	
	LD	A,(FCD_H)
	LD	(DE),A
	INC	DE
	
	LD	A,(FCD_R)
	LD	(DE),A
	INC	DE
	
	LD	A,FCD_N
	LD	(DE),A
	INC	DE
	
	LD	A,(FCD_EOT)
	LD	(DE),A
	INC	DE
	
	LD	A,(FCD_GPL)
	LD	(DE),A
	INC	DE
	
	LD	A,FCD_DTL
	LD	(DE),A
	INC	DE
	
	LD	A,9
	LD	(FCP_LEN),A

	RET
	
FC_SETUPSEEK:
	CALL 	FC_SETUPCMD	; START WITH GENERIC IO CMD
	
	LD	A,(FCD_C)
	LD	(DE),A
	INC	DE
	
	LD	A,3
	LD	(FCP_LEN),A

	RET

FC_SETUPSPECIFY:
	CALL	FC_SETUPCMD
	DEC	DE			; BACKUP 1 BYTE, WE ONLY WANT FIRST BYTE
	
	LD	A,(FCD_SRTHUT)
	LD	(DE),A			; SAVE THE BYTE
	INC	DE
	
	LD	A,(FCD_HLTND)
	LD	(DE),A			; SAVE THE BYTE
	INC	DE
	
	LD	A,3
	LD	(FCP_LEN),A

	RET
;
; SET FST_DOR
;
FC_SETDOR
	LD	(FST_DOR),A
	OUT	(FDC_DOR),A
#IF (FDTRACE >= 3)
	CALL	NEWLINE
	LD	DE,FDSTR_DOR
	CALL	WRITESTR
	LD	DE,FDSTR_ARROW
	CALL	WRITESTR
	CALL	PC_SPACE
	LD	A,(FST_DOR)
	CALL	PRTHEXBYTE
#ENDIF
	RET
;
; RESET FDC BY PULSING BIT 7 OF LATCH LOW
;
FC_RESETFDC:
#IF (FDTRACE >= 3)
	LD	DE,FDSTR_RESETFDC
	CALL	WRITESTR
#ENDIF
	LD	A,(FST_DOR)
	PUSH	AF

#IF ((FDMODE == FDMODE_ZETA) | (FDMODE == FDMODE_DIO3))
	RES	7,A
#ENDIF
#IF ((FDMODE == FDMODE_DIDE) | (FDMODE == FDMODE_N8))
	LD	A,0
#ENDIF
	CALL	FC_SETDOR
	CALL	DELAY
	POP	AF
	CALL	FC_SETDOR

	LD	DE,100			; DELAY: 25us * 100 = 2.5ms
	CALL	VDELAY
	RET
;
; PULSE TERMCT TO TERMINATE ANY ACTIVE EXECUTION PHASE
;
FC_PULSETC:
#IF ((FDMODE == FDMODE_DIDE) | (FDMODE == FDMODE_N8))
	IN	A,(FDC_TC)
#ELSE
	LD	A,(FST_DOR)
	SET	0,A
	OUT	(FDC_DOR),A
	RES	0,A
	OUT	(FDC_DOR),A
#ENDIF
	RET
;
; SET FST_DOR FOR MOTOR CONTROL ON
;
FC_MOTORON:
	LD	BC,300H
;	LD	BC,10H
	LD	(FCD_IDLECNT),BC
	
#IF (FDTRACE >= 3)	
	LD	DE,FDSTR_MOTON
	CALL	WRITESTR
#ENDIF
#IF ((FDMODE == FDMODE_DIO) | (FDMODE == FDMODE_ZETA) | (FDMODE == FDMODE_DIO3))
	LD	A,(FST_DOR)
	PUSH	AF

	LD	A,(FCD_DOR)	; GET NEW LATCH VALUE (W/ MOTOR ON)
	CALL	FC_SETDOR	; AND IMPLEMENT IT

	POP	AF
#IF ((FDMODE == FDMODE_ZETA) | (FDMODE == FDMODE_DIO3))
	XOR	00000010B	; MOTOR BIT INVERTED ON ZETA
#ENDIF
	BIT	1,A		; SET FLAGS SET BASED ON CURRENT MOTOR BIT
	RET	Z		; MOTOR WAS PREVIOUSLY ON, WE ARE DONE
#ENDIF
#IF ((FDMODE == FDMODE_DIDE) | (FDMODE == FDMODE_N8))
	; SETUP DCR FOR DIDE HARDWARE
	LD	A,(FCD_DCR)
	OUT	(FDC_DCR),A

	LD	HL,FST_DOR		; POINT TO FDC_DOR
	LD	A,(HL)			; START WITH CURRENT DOR
	PUSH	AF
	AND	11111100B		; GET RID OF ANY ACTIVE DS BITS
	LD	C,A			; SAVE IT FOR NOW
	LD	A,(FCD_DS)		; NOW GET CURRENT DS
	LD	B,A			; PUT IN B FOR LATER
	OR	C			; COMBINE WITH SAVED DOR
	LD	C,A			; RE-SAVE IT
	INC	B			; SET UP B AS LOOP COUNTER (DS + 1)
	LD	A,00001000B		; STARTING BIT PATTERN FOR MOTOR
FC_MOTORON1:
	RLA				; SHIFT LEFT
	DJNZ	FC_MOTORON1		; DS TIMES
	OR	C			; COMBINE WITH SAVED
	LD	(HL),A			; COMMIT THE NEW VALUE TO FST_DOR
	CALL	FC_SETDOR		; OUTPUT TO CONTROLLER

	LD	C,A
	POP	AF
	CP	C
	RET	Z			; MOTOR WAS PREVIOUSLY ON
#ENDIF

#IF (FDTRACE >= 3)
	LD	DE,FDSTR_MOTDELAY
	CALL	WRITESTR
#ENDIF
	CALL	LDELAY			; DELAY FOR MOTOR SPINUP IF NOT PREVIOUSLY ON
	RET
;
; SET FST_DOR FOR MOTOR CONTROL OFF
;
FC_MOTOROFF:
	LD	A,(FCD_FDCRDY)
	CP	TRUE
	CALL	NZ,FD_FDCRESET
	
	LD	A,DOR_INIT
	CALL	FC_SETDOR		; OUTPUT TO CONTROLLER
	
#IF (FDTRACE >= 3)	
	LD	DE,FDSTR_MOTOFF
	CALL	WRITESTR
#ENDIF
	RET
;
;===============================================================================
; FDC OPERATIONS
;===============================================================================
;
FOP:
;
; INITIALIZATION
;
	LD	A,0
	LD	(FRB_LEN),A

	LD	A,FRC_OK
	LD	(FST_RC),A
;
; CLEAR FDC, DISCARD ANY PENDING BYTES (GARBAGE?)
;
	LD	B,0		; B IS LOOP COUNTER
FOP_CLR1:
	CALL	DELAY		; FDC MAY TAKE UP TO 12us TO UPDATE MSR
	IN	A,(FDC_MSR)	; GET STATUS
	AND	0C0H		; ISOLATE HIGH NIBBLE, RQM/DIO/NDM/CB
	CP	0C0H		; LOOKING FOR RQM=1, DIO=1, BYTES PENDING
	JR	NZ,FOP_CMD1	; NO BYTES PENDING, GO TO NEXT PHASE
	IN	A,(FDC_DATA)	; GET THE PENDING BYTE AND DISCARD
	DJNZ	FOP_CLR1
	JP	FOP_TOFDCRDY	; OTHERWISE, TIMEOUT
;
; SEND COMMAND
;
FOP_CMD1:
	LD	HL,FCP_BUF
	LD	A,(FCP_LEN)
	LD	D,A		; D = CMD BYTES TO SEND

FOP_CMD2:	; START OF LOOP TO SEND NEXT BYTE
	LD	B,0		; B IS LOOP COUNTER

FOP_CMD4:	; START OF STATUS LOOP, WAIT FOR FDC TO BE READY FOR BYTE	
	CALL	DELAY		; FDC MAY TAKE UP TO 12us TO UPDATE MSR
	IN	A,(FDC_MSR)	; READ MAIN STATUS REGISTER
	AND	0C0H		; ISOLATE RQM/DIO
	CP	080H		; LOOKING FOR RQM=1, DIO=0 (FDC READY FOR A BYTE)
	JR	Z,FOP_CMD6	; GOOD, GO TO SEND BYTE
	CP	0C0H		; HMMMM... RQM=1 & DIO=1, FDC WANTS TO SEND US DATA, UNEXPECTED
	JR	Z,FOP_RES	; GO IMMEDIATELY TO RESULTS???
	DJNZ	FOP_CMD4	; LOOP TILL COUNTER EXHAUSTED
	JR	FOP_TOSNDCMD	; COUNTER EXHAUSTED, TIMEOUT / EXIT

FOP_CMD6:	; SEND NEXT BYTE
	LD	A,(HL)		; POINT TO NEXT BYTE TO SEND
	OUT	(FDC_DATA),A	; PUSH IT TO FDC
	INC	HL		; INCREMENT POINTER FOR NEXT TIME
	DEC	D		; DECREMENT NUM BYTES LEFT TO SEND
	JR	NZ,FOP_CMD2	; DO NEXT BYTE
;
; EXECUTION PHASE
;
FOP_X1:
	LD	A,(FCP_CMD)
	
	LD	HL,FOP_RES
	PUSH	HL
	
	CP	CMD_READ
	JP	Z,FXR_READ
	CP	CMD_WRITE
	JP	Z,FXR_WRITE
	CP	CMD_READID
	JP	Z,FXR_NULL
	RET				; RET ACTUALLY JUST JUMPS RIGHT TO FOP_RES
;
; RESULTS PHASE
;
FOP_RES:
	LD	HL,FRB			; POINT TO RECEIVE BUFFER

FOP_RES0:
	LD	B,0			; B IS LOOP COUNTER

FOP_RES1:
	CALL	DELAY			; FDC MAY TAKE UP TO 12us TO UPDATE MSR
	IN	A,(FDC_MSR)		; READ MAIN STATUS REGISTER
	AND	0F0H			; ISOLATE RQM/DIO/EXEC/BUSY
	CP	0D0H			; LOOKING FOR RQM/DIO/BUSY
	JR	Z,FOP_RES2		; GOOD, GO TO RECEIVE BYTE
	CP	080H			; CHECK FOR RQM=1, DIO=0 (NOTHING LEFT)
	JR	Z,FOP_EVAL		; IF NOTHING LEFT, ALL DONE, GO TO EOD/EXIT
	DJNZ	FOP_RES1		; LOOP TILL COUNTER EXHAUSTED
	JR	FOP_TOGETRES		; OTHERWISE TIMEOUT ERROR

FOP_RES2:	; PROCESS NEXT PENDING BYTE
	LD	A,FRB_SIZ		; GET BUF SIZE
	CP	D			; REACHED MAX?
	JR	Z,FOP_BUFMAX		; HANDLE BUF MAX/EXIT
	IN	A,(FDC_DATA)		; GET THE BYTE
	LD	(HL),A			; SAVE VALUE
	INC	HL			; INCREMENT BUF POS
	INC	D			; INCREMENT BYTES RECEIVED
	PUSH	HL
	LD	HL,FRB_LEN		; POINT TO BUFFER LENGTH
	LD	(HL),D			; UPDATE NUMBER OF BYTES RECEIVED
	POP	HL
	JR	FOP_RES0		; CONTINUE READ LOOP
;
; EXIT POINTS
;
FOP_NOTIMPL:
	LD	A,FRC_NOTIMPL
	JR	FOP_ERR

FOP_CMDERR:
	LD	A,FRC_CMDERR
	JR	FOP_ERR

FOP_ERROR:
	LD	A,FRC_ERROR
	JR	FOP_ERR

FOP_ABORT:
	LD	A,FRC_ABORT
	JR	FOP_ERR

FOP_BUFMAX:
	LD	A,FRC_BUFMAX
	JR	FOP_ERR

FOP_TOFDCRDY:
	LD	A,FRC_TOFDCRDY
	JR	FOP_ERR

FOP_TOSNDCMD:
	LD	A,FRC_TOSNDCMD
	JR	FOP_ERR

FOP_TOGETRES:
	LD	A,FRC_TOGETRES
	JR	FOP_ERR

FOP_TOEXEC:
	LD	A,FRC_TOEXEC
	JR	FOP_ERR

FOP_ERR:
	LD	(FST_RC),A
	
FOP_EVAL:
	LD	A,(FCP_CMD)
	; DRVSTAT IS WEIRD, HAS ONLY ST3, NOTHING TO EVAL
	CP	CMD_DRVSTAT
	JR	Z,FOP_EXIT
	; DO WE HAVE ST0?
	LD	A,(FRB_LEN)
	CP	1
	JP	M,FOP_EXIT
	
FOP_EVALST0:
	LD	A,(FRB_ST0)
	AND	11000000B
	CP	01000000B	; ABTERM
	JR	Z,FOP_ABTERM
	CP	10000000B	; INVCMD
	JR	Z,FOP_INVCMD
	CP	11000000B	; DSKCHG
	JR	Z,FOP_DSKCHG
	JR	FOP_EXIT
	
FOP_ABTERM:
	; SENSEINT DOES NOT USE ST1
	LD	A,(FCP_CMD)
	CP	CMD_SENSEINT
	JR	Z,FOP_ABTERM1
	; DO WE HAVE ST1?
	LD	A,(FRB_LEN)
	CP	2
	JP	M,FOP_ABTERM1
	JR	FOP_EVALST1
FOP_ABTERM1:	; NO FURTHER DATA, SET FST TO ABTERM
	LD	C,FRC_ABTERM
	JR	FOP_SETFST

FOP_INVCMD:	
	LD	C,FRC_INVCMD
	JR	FOP_SETFST

FOP_DSKCHG:
	LD	C,FRC_DSKCHG
	JR	FOP_SETFST
	
FOP_EVALST1:
	LD	A,(FRB_ST1)

	LD	C,FRC_ENDCYL
	BIT	7,A
	JR	NZ,FOP_SETFST

	LD	C,FRC_DATAERR
	BIT	5,A
	JR	NZ,FOP_SETFST

	LD	C,FRC_OVERRUN
	BIT	4,A
	JR	NZ,FOP_SETFST

	LD	C,FRC_NODATA
	BIT	2,A
	JR	NZ,FOP_SETFST

	LD	C,FRC_NOTWRIT
	BIT	1,A
	JR	NZ,FOP_SETFST

	LD	C,FRC_MISADR
	BIT	0,A
	JR	NZ,FOP_SETFST

	JR	FOP_EXIT

FOP_SETFST:
	LD	A,C
	LD	(FST_RC),A

FOP_EXIT:
#IF (FDTRACE >= 2)
	CALL	FC_PRTRESULTS
#ENDIF
	JP	FD_RETRC
;
; EXECUTION ROUTINES
;
FXR_NOP:
	RET
;
; NULL EXECUTION, NO DATA TO READ/WRITE (USED BY READID)
;
FXR_NULL:
	LD	BC,1000H		; BC IS LOOP COUNTER, 4096 ITERATIONS
FXR_NULL1:
	CALL	DELAY
	IN	A,(FDC_MSR)		; GET MSR
	AND	0E0H			; ISOLATE RQM/DIO/NDM
	CP	0C0H			; WE WANT RQM=1,DIO=1,NDM=0 (READY TO READ A BYTE W/ EXEC INACTIVE)
	RET	Z			; GOT IT, EXIT CLEAN W/O PULSING TC
	DEC	BC			; DECREMENT COUNTER (16 BIT)
	LD	A,B			; CHECK FOR ZERO
	OR	C			; "
	JR	NZ,FXR_NULL1		; NOT ZERO YET, KEEP CHECKING
	JP	FXR_TO			; OTHERWISE, TIMEOUT ERROR
	RET
;
; READ DATA
;	
FXR_READ:
	LD	HL,(DIOBUF)		; POINT TO SECTOR BUFFER START
	LD	DE,(FCD_SECSZ)
	LD	A,(CPUFREQ + 3) / 4
	LD	(FCD_TO),A
FXRR1	LD	C,0			; OUTER LOOP TIMEOUT COUNTER
FXRR2:	LD	B,0			; SETUP FOR 256 ITERATIONS
FXRR3:	IN	A,(FDC_MSR)		; GET MSR
	CP	0F0H			; WE WANT RQM=1,DIO=1,NDM=1,BUSY=1 (READY TO RECEIVE A BYTE W/ EXEC ACTIVE)
	JR	Z,FXRR4			; GOT IT, DO BYTE READ
	DJNZ	FXRR3			; NOT READY, LOOP IF COUNTER NOT ZERO
	JR	FXRR5			; COUNTER ZERO, GO TO OUTER LOOP LOGIC

FXRR4:	IN	A,(FDC_DATA)		; GET PENDING BYTE
	LD	(HL),A			; STORE IT IN BUFFER
	INC	HL			; INCREMENT THE BUFFER POINTER
	DEC	DE			; DECREMENT BYTE COUNT
	LD	A,D	
	OR	E	
	JR	NZ,FXRR2		; IF NOT ZERO, REPEAT LOOP
	JR	FXR_END			; CLEAN EXIT

FXRR5:					; OUTER LOOP, REALLY ONLY HAPPENS WHEN WAITING FOR FIRST BYTE OR ABORTED
	CP	0C0H			; IF RQM=1, DIO=1, NDM=0 (EXECUTION ABORTED)
	JR	Z,FXR_ABORT		; BAIL OUT TO ERR ROUTINE, FIX: GO TO SPECIFIC ROUTINE FOR THIS???
	DEC	C
	JR	NZ,FXRR2		; IF NOT ZERO, LOOP SOME MORE
	LD	A,(FCD_TO)
	DEC	A
	LD	(FCD_TO),A
	JR	NZ,FXRR1
	JR	FXR_TO			; OTHERWISE, TIMEOUT ERROR
;
; WRITE DATA
;
FXR_WRITE:
	LD	HL,(DIOBUF)		; POINT TO SECTOR BUFFER START
	LD	DE,(FCD_SECSZ)
	LD	A,(CPUFREQ + 3) / 4
	LD	(FCD_TO),A
FXRW1	LD	C,0			; OUTER LOOP TIMEOUT COUNTER
FXRW2:	LD	B,0			; SETUP FOR 256 ITERATIONS
FXRW3:	IN	A,(FDC_MSR)		; GET MSR
	CP	0B0H			; WE WANT RQM=1,DIO=0,NDM=1,BUSY=1 (READY TO SEND A BYTE W/ EXEC ACTIVE)
	JR	Z,FXRW4			; GOT IT, DO BYTE WRITE
	DJNZ	FXRW3			; NOT READY, LOOP IF COUNTER NOT ZERO
	JR	FXRW5			; COUNTER ZERO, GO TO OUTER LOOP LOGIC
FXRW4:	LD	A,(HL)			; GET NEXT BYTE TO WRITE
	OUT	(FDC_DATA),A		; WRITE IT
	INC	HL			; INCREMENT THE BUFFER POINTER
	DEC	DE			; DECREMENT LOOP COUNTER
	LD	A,D	
	OR	E	
	JR	NZ,FXRW2		; IF NOT ZERO, REPEAT LOOP
	JR	FXR_END			; CLEAN EXIT
FXRW5:					; OUTER LOOP, REALLY ONLY HAPPENS WHEN WAITING FOR FIRST BYTE OR ABORTED
	CP	0C0H			; IF RQM=1, DIO=1, NDM=0 (EXECUTION ABORTED)
	JR	Z,FXR_ABORT		; BAIL OUT TO ERR ROUTINE
	DEC	C
	JR	NZ,FXRW2		; IF NOT ZERO, LOOP SOME MORE
	LD	A,(FCD_TO)
	DEC	A
	LD	(FCD_TO),A
	JR	NZ,FXRW1
	JR	FXR_TO			; OTHERWISE, TIMEOUT ERROR
;
FXR_TO:
	LD	A,FRC_TOEXEC
	JR	FXR_ERR

FXR_ABORT:
	LD	A,FRC_ABORT
	JR	FXR_ERR
;
; COMMON COMPLETION CODE FOR ALL EXECUTION ROUTINES
;
FXR_ERR:
	LD	(FST_RC),A
	RET

FXR_END:
	CALL	FC_PULSETC
	RET

#IF (FDTRACE > 0)
;
;===============================================================================
; COMMAND PROCESSING STATUS DISPLAY
;===============================================================================
;
; PRINT STATUS
;
FC_PRTFST:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,(FST_RC)		; A GETS FST_RC
	LD	B,FSST_COUNT		; B GETS TABLE ENTRY COUNT
	LD	HL,FSST
	LD	DE,FSST_ENTSIZ		; TABLE ENTRY LENGTH

FC_PRTFST0:	; START OF LOOP
	LD	C,(HL)
	CP	C
	JR	Z,FC_PRTFST1		; FOUND CODE
	
	ADD	HL,DE			; POINT TO NEXT ENTRY
	DJNZ	FC_PRTFST0		; CHECK NEXT ENTRY TILL COUNT IS ZERO

	; NO MATCHING ENTRY, PRINT THE HEX VALUE
	CALL	PC_SPACE
	CALL	PC_LBKT
	CALL	PRTHEXBYTE
	CALL	PC_RBKT
	JR	FC_PRTFSTX
	
FC_PRTFST1:	; ENTRY FOUND, PRINT IT
	CALL	PC_SPACE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	PC_LBKT
	CALL	WRITESTR
	CALL	PC_RBKT


FC_PRTFSTX:
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
; PRINT COMMAND
;
FC_PRTCMD:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,(FCP_CMD)		; A GETS THE COMMAND CODE
	LD	B,FCT_COUNT		; B GETS TABLE ENTRY COUNT
	LD	HL,FCT
	LD	DE,FCT_ENTSIZ		; TABLE ENTRY LENGTH

FCPC_LOOP:	; START OF LOOP
	LD	C,(HL)
	CP	C
	JR	Z,FCPC_MATCH		; FOUND CODE
	
	ADD	HL,DE			; POINT TO NEXT ENTRY
	DJNZ	FCPC_LOOP		; CHECK NEXT ENTRY TILL COUNT IS ZERO

		; NO MATCHING ENTRY, PRINT THE HEX VALUE
	CALL	PC_SPACE
	CALL	PC_LBKT
	CALL	PRTHEXBYTE
	CALL	PC_RBKT
	JR	FCPC_EXIT
	
FCPC_MATCH:	; ENTRY FOUND, PRINT IT
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	WRITESTR

FCPC_EXIT:
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
; PRINT RESULTS
;
FC_PRTRESULTS:
	; IF TRACE IS SET, FORCE PRINT RESULTS
	LD	A,(FCD_TRACE)
	OR	A
	RET	Z		; IF TRACE = 0, BE SILENT!
	
	CP	3		; IS TRACE >= 3 ?
	JR	NC,FCPR2	; YES, SO FORCE PRINT EVERYTHING!
	
	; IF RC=OK, GET OUT, NOTHING TO PRINT
	LD	A,(FST_RC)
	CP	FRC_OK
	RET	Z
	
	; SPECIAL CASE, DON'T PRINT IF SENSEINT & INVCMD/DSK CHG/ABTERM
	LD	A,(FCP_CMD)
	CP	CMD_SENSEINT
	JR	NZ,FCPR2
	
	LD	A,(FST_RC)
	CP	FRC_INVCMD
	JR	Z,FCPR_EXIT
	CP	FRC_DSKCHG
	JR	Z,FCPR_EXIT
	CP	FRC_ABTERM
	JR	Z,FCPR_EXIT
	JR	FCPR_EXIT
	
FCPR2:
	CALL	NEWLINE
	
	LD	DE,FDSTR_FD
	CALL	WRITESTR
	CALL	PC_COLON
	CALL	PC_SPACE

	CALL	FC_PRTCMD

	LD	A,(FCP_LEN)
	LD	DE,FCP_BUF
	CALL	PRTHEXBUF

	LD	DE,FDSTR_ARROW
	CALL	WRITESTR

	LD	A,(FRB_LEN)
	LD	DE,FRB
	CALL	PRTHEXBUF

	LD	A,(FST_RC)
	CALL	FC_PRTFST

FCPR_EXIT:
	RET
;
; STRING CONSTANTS
;
FDSTR_ARROW	.TEXT	" -->$"
FDSTR_NORESP	.TEXT	"DRIVE NOT RESPONDING$"
FDSTR_FD	.TEXT	"FD$"
#IF (FDTRACE >= 3)
FDSTR_MOTON	.TEXT	"\r\nMOTOR ON$"
FDSTR_MOTOFF	.TEXT	"\r\nMOTOR OFF$"
FDSTR_MOTDELAY	.TEXT	"\r\nMOTOR DELAY$"
FDSTR_DOR	.TEXT	"DOR$"
FDSTR_RESETFDC	.TEXT	"\r\nRESET FDC$"
FDSTR_SELECT	.TEXT	"\r\nSELECT: $"
#ENDIF		; (FDTRACE >= 3)
#ENDIF		; (FDTRACE > 0)
;
;
;==================================================================================================
;   FLOPPY DISK DRIVER - DATA
;==================================================================================================
;
; FDC COMMAND PHASE
;
FCP_CMD		.DB	000H
FCP_LEN		.DB	00H
FCP_BUF:
FCP_CMDX	.DB	0
FCP_HDSDS	.DB	0
FCP_C		.DB	0
FCP_H		.DB	0
FCP_R		.DB	0
FCP_N		.DB	0
FCP_EOT		.DB	0
FCP_GPL		.DB	0
FCP_DTL		.DB	0
FCP_BUFSIZ	.EQU	$-FCP_BUF
;
; FDC STATUS
;
FST_RC		.DB	00H
FST_DOR		.DB	00H
;
; FDC RESULTS BUFFER
;
FRB_LEN		.DB	00H
FRB
FRB_ST0
FRB_ST3		.DB	0
FRB_ST1
FRB_PCN		.DB	0
FRB_ST2		.DB	0
FRB_C		.DB	0
FRB_H		.DB	0
FRB_R		.DB	0
FRB_N		.DB	0
FRB_SIZ		.EQU	$-FRB
;
; FDC COMMAND DATA
;
FCD:		; FLOPPY CONFIGURATION DATA (PUBLIC) MANAGED AS A "BLOCK"
FCD_NUMCYL	.DB	000H		; NUMBER OF CYLINDERS
FCD_NUMHD	.DB	000H		; NUMBER OF HEADS
FCD_NUMSEC	.DB	000H		; NUMBER OF SECTORS
FCD_SOT		.DB	000H		; START OF TRACK (ID OF FIRST SECTOR, USUALLY 1)
FCD_EOT					; END OF TRACK SECTOR (SAME AS SC SINCE SOT ALWAYS 1)
FCD_SC		.DB	000H		; SECTOR COUNT
FCD_SECSZ	.DW	000H		; SECTOR SIZE IN BYTES
FCD_GPL		.DB	000H		; GAP LENGTH (R/W)
FCD_GPLF	.DB	000H		; GAP LENGTH (FORMAT)
FCD_SRTHUT	.DB	000H		; STEP RATE, IBM PS/2 CALLS FOR 3ms, 0DH = 3ms SRT, HEAD UNLOAD TIME
FCD_HLTND	.DB	000H		; HEAD LOAD TIME, IBM PS/2 CALLS FOR 15ms 08H = 16ms HUT
FCD_DOR		.DB	000H		; DOR VALUE
FCD_DCR		.DB	000H		; DCR VALUE
FCD_LEN		.EQU	$ - FCD
		; DYNAMICALLY MANAGED (PUBLIC)
FCD_DS		.DB	001H		; DRIVE SELECT (UNIT NUMBER 0-3)
FCD_C		.DB	000H		; CYLINDER
FCD_H		.DB	000H		; HEAD
FCD_R		.DB	001H		; RECORD
FCD_D		.DB	0E5H		; DATA FILL BYTE
		; STATUS MANAGEMENT
FCD_DOP		.DB	0FFH		; CURRENT OPERATION (SEE DOP_...)
FCD_IDLECNT	.DW	0		; IDLE COUNT
FCD_TRACE	.DB	0		; TRACE LEVEL
FCD_TO		.DB	0		; TIMEOUT COUNTDOWN TIMER
FCD_FDCRDY	.DB	0		; FALSE MEANS FDC RESET NEEDED
;
; FLOPPY UNIT DATA
;
FCD_UNITS:
FCD_U0TRK	.DB	0FFH		; CURRENT TRACK
FCD_U0MEDIA	.DB	FDMEDIA		; MEDIA BYTE
;		.DW	FDDPH0		; ADDRESS OF DPH
;
FCD_U1TRK	.DB	0FFH		; CURRENT TRACK
FCD_U1MEDIA	.DB	FDMEDIA		; MEDIA BYTE
;
; WORKING STORAGE (DERIVED FROM ABOVE FOR ACTIVE DRIVE UNIT)
;
FDDS_TRKADR	.DW	0	; POINTER TO FDCUXTRK ABOVE
FDDS_MEDIAADR	.DW	0	; POINTER TO FDCUXMEDIA ABOVE
