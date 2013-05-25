;
;==================================================================================================
;   ROMWBW 2.X CONFIGURATION FOR SIMH EMULATOR
;==================================================================================================
;
; BUILD CONFIGURATION OPTIONS
;
CPUFREQ		.EQU	8		; IN MHZ, USED TO COMPUTE DELAY FACTORS
;
DEFCON		.EQU	CIODEV_UART	; DEFAULT CONSOLE DEVICE (LOADER AND MONITOR): CIODEV_UART, DIODEV_CRT, CIODEV_PRPCON, CIODEV_PPPCON
ALTCON		.EQU	DEFCON		; ALT CONSOLE DEVICE (USED WHEN CONFIG JUMPER SHORTED)
CONBAUD		.EQU	38400		; BAUDRATE FOR CONSOLE DURING HARDWARE INIT
DEFVDA		.EQU	VDADEV_NONE	; DEFAULT VDA DEVICE (VDADEV_NONE, VDADEV_VDU, VDADEV_CVDU, VDADEV_N8V, VDADEV_UPD7220)
DEFEMU		.EQU	EMUTYP_TTY	; DEFAULT VDA EMULATION (EMUTYP_TTY, EMUTYP_ANSI, ...)
TERMTYPE	.EQU	TERM_ANSI	; TERM_TTY=0, TERM_ANSI=1, TERM_WYSE=2
;
RAMSIZE		.EQU	512		; SIZE OF RAM IN KB, MUST MATCH YOUR HARDWARE!!!
CLRRAMDISK	.EQU	CLR_ALWAYS	; CLR_ALWAYS, CLR_NEVER, CLR_AUTO (CLEAR IF INVALID DIR AREA)
;
DSKMAP		.EQU	DM_RAM		; DM_ROM, DM_RAM, DM_FD, DM_IDE, DM_PPIDE, DM_SD, DM_PRPSD, DM_PPPSD
;
DSKYENABLE	.EQU	FALSE		; TRUE FOR DSKY SUPPORT (DO NOT COMBINE WITH PPIDE)
;
UARTENABLE	.EQU	TRUE		; TRUE FOR UART SUPPORT (ALMOST ALWAYS WANT THIS TO BE TRUE)
UARTCNT		.EQU	1		; NUMBER OF UARTS
UART0IOB	.EQU	$68		; UART0 IOBASE
UART0BAUD	.EQU	CONBAUD		; UART0 BAUDRATE
UART0FIFO	.EQU	FALSE		; UART0 TRUE ENABLES UART FIFO (16550 ASSUMED, N8VEM AND ZETA ONLY)
UART0AFC	.EQU	FALSE		; UART0 TRUE ENABLES AUTO FLOW CONTROL (YOUR TERMINAL/UART MUST SUPPORT RTS/CTS FLOW CONTROL!!!)
;
ASCIENABLE	.EQU	FALSE		; TRUE FOR Z180 ASCI SUPPORT
ASCI0BAUD	.EQU	38400		; ASCI0 BAUDRATE (IMPLEMENTED BY Z180_CNTLB0)
ASCI1BAUD	.EQU	38400		; ASCI1 BAUDRATE (IMPLEMENTED BY Z180_CNTLB1)
;
VDUENABLE	.EQU	FALSE		; TRUE FOR VDU BOARD SUPPORT
CVDUENABLE	.EQU	FALSE		; TRUE FOR CVDU BOARD SUPPORT
UPD7220ENABLE	.EQU	FALSE		; TRUE FOR uPD7220 BOARD SUPPORT
N8VENABLE	.EQU	FALSE		; TRUE FOR N8 (TMS9918) VIDEO/KBD SUPPORT
;
DEFIOBYTE	.EQU	$00		; DEFAULT INITIAL VALUE FOR CP/M IOBYTE, $00=TTY, $01=CRT (MUST HAVE CRT HARDWARE)
ALTIOBYTE	.EQU	DEFIOBYTE	; ALT INITIAL VALUE (USED WHEN CONFIG JUMPER SHORTED)
WRTCACHE	.EQU	TRUE		; ENABLE WRITE CACHING IN CBIOS (DE)BLOCKING ALGORITHM
DSKTRACE	.EQU	FALSE		; ENABLE TRACING OF CBIOS DISK FUNCTION CALLS
;
FDENABLE	.EQU	FALSE		; TRUE FOR FLOPPY SUPPORT
FDMODE		.EQU	FDMODE_DIO	; FDMODE_DIO, FDMODE_ZETA, FDMODE_DIDE, FDMODE_N8, FDMODE_DIO3
FDTRACE		.EQU	1		; 0=SILENT, 1=FATAL ERRORS, 2=ALL ERRORS, 3=EVERYTHING (ONLY RELEVANT IF FDENABLE = TRUE)
FDMEDIA		.EQU	FDM144		; FDM720, FDM144, FDM360, FDM120 (ONLY RELEVANT IF FDENABLE = TRUE)
FDMEDIAALT	.EQU	FDM720		; ALTERNATE MEDIA TO TRY, SAME CHOICES AS ABOVE (ONLY RELEVANT IF FDMAUTO = TRUE)
FDMAUTO		.EQU	TRUE		; SELECT BETWEEN MEDIA OPTS ABOVE AUTOMATICALLY
;
IDEENABLE	.EQU	FALSE		; TRUE FOR IDE SUPPORT
IDEMODE		.EQU	IDEMODE_DIO	; IDEMODE_DIO, IDEMODE_DIDE
IDETRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
IDE8BIT		.EQU	FALSE		; USE IDE 8BIT TRANSFERS (PROBABLY ONLY WORKS FOR CF CARDS!)
IDECAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
;
PPIDEENABLE	.EQU	FALSE		; TRUE FOR PPIDE SUPPORT (DO NOT COMBINE WITH DSKYENABLE)
PPIDEMODE	.EQU	PPIDEMODE_STD	; PPIDEMODE_STD, PPIDEMODE_DIO3
PPIDETRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPIDEENABLE = TRUE)
PPIDE8BIT	.EQU	FALSE		; USE IDE 8BIT TRANSFERS (PROBABLY ONLY WORKS FOR CF CARDS!)
PPIDECAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
PPIDESLOW	.EQU	FALSE		; ADD DELAYS TO HELP PROBLEMATIC HARDWARE (TRY THIS IF PPIDE IS UNRELIABLE)
;
SDENABLE	.EQU	FALSE		; TRUE FOR SD SUPPORT
SDMODE		.EQU	SDMODE_NONE	; SDMODE_JUHA, SDMODE_CSIO, SDMODE_UART, SDMODE_PPI, SDMODE_DSD
SDTRACE		.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
SDCAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
SDCSIOFAST	.EQU	FALSE		; TABLE-DRIVEN BIT INVERTER
;
PRPENABLE	.EQU	FALSE		; TRUE FOR PROPIO SD SUPPORT (FOR N8VEM PROPIO ONLY!)
PRPSDENABLE	.EQU	TRUE		; TRUE FOR PROPIO SD SUPPORT (FOR N8VEM PROPIO ONLY!)
PRPSDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PRPSDENABLE = TRUE)
PRPSDCAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
PRPCONENABLE	.EQU	TRUE		; TRUE FOR PROPIO CONSOLE SUPPORT (PS/2 KBD & VGA VIDEO)
;
PPPENABLE	.EQU	FALSE		; TRUE FOR PARPORTPROP SUPPORT
PPPSDENABLE	.EQU	TRUE		; TRUE FOR PROPIO SD SUPPORT (FOR N8VEM PROPIO ONLY!)
PPPSDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPPENABLE = TRUE)
PPPSDCAPACITY	.EQU	64		; CAPACITY OF PPP SD DEVICE (IN MB)
PPPCONENABLE	.EQU	TRUE		; TRUE FOR PROPIO CONSOLE SUPPORT (PS/2 KBD & VGA VIDEO)
;
HDSKENABLE	.EQU	TRUE		; TRUE FOR HDSK SUPPORT
HDSKTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
HDSKCAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
;
PPKENABLE	.EQU	FALSE		; TRUE FOR PARALLEL PORT KEYBOARD
PPKTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPKENABLE = TRUE)
KBDENABLE	.EQU	FALSE		; TRUE FOR PS/2 KEYBOARD ON I8242
KBDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF KBDENABLE = TRUE)
;
TTYENABLE	.EQU	FALSE		; INCLUDE TTY EMULATION SUPPORT
ANSIENABLE	.EQU	FALSE		; INCLUDE ANSI EMULATION SUPPORT
ANSITRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF ANSIENABLE = TRUE)
;
BOOTTYPE	.EQU	BT_MENU		; BT_MENU (WAIT FOR KEYPRESS), BT_AUTO (BOOT_DEFAULT AFTER BOOT_TIMEOUT SECS)
BOOT_TIMEOUT	.EQU	20		; APPROX TIMEOUT IN SECONDS FOR AUTOBOOT, 0 FOR IMMEDIATE
BOOT_DEFAULT	.EQU	'R'		; SELECTION TO INVOKE AT TIMEOUT
