;___SYSCFG_____________________________________________________________________________________________________________
;
; syscfg.asm 3/04/2012 2.0.0.0 dwg - added required configuration information
;
; INCLUDE STANDARD BIOS DEFINITIONS
;
#INCLUDE "std.asm"
;
#IF (PLATFORM != PLT_UNA)
;
	.ORG	0			; ALL ADDRESSES GENERATED WILL BE ZERO BASED
;
		.DW	$A33A		; MARKER TO VERIFY START OF CONFIG DATA
;
; Reserved for Configuration Information
;
		.DW	SC_CONFIG	; OFFSET OF CONFIG DATA
		.DW	SC_TIMESTAMP	; OFFSET OF TIMESTAMP STRING
		.DW	SC_BUILD	; OFFSET OF VARIANT STRING
;
; BIOS configuration data
;
SC_CONFIG:
;
; BIOS REVISION
;
		.DB	RMJ, RMN	; MAJOR, MINOR
		.DB	RUP, RTP	; UPDATE, PATCH
		.DW	REVISION	; SVN REVISION
;
; LOADER DATA
;
; THIS AREA IS FOR NOTES LEFT BY THE LOADER FROM WHEN THE CCP/BDOS/BIOS WERE 
; PLACED IN MEMORY AND KICKED OFF, THIS ALLOWS LOGGING ONTO THE BOOT DRIVE ON STARTUP
;
DISKBOOT	.DB	FALSE		; FALSE IF ROM BOOT, OTHERWISE TRUE
BOOTDEVICE	.DB	0		; IF NOT ROM BOOT, HAS DEV/UNIT OF BOOT DEVICE
BOOTLU		.DW	0		; LOGICAL UNIT ON DEV/UNIT FOR BOOT
BOOTTIME	.DB	0,0,0,0,0,0	; SYSTEM STARTUP TIME (YY,MM,DD,HH,MM,SS)
;
; BUILD CONFIGURATION OPTIONS
;
		.DB	PLATFORM
		.DB	CPUFREQ
		.DW	RAMSIZE
		.DW	ROMSIZE
		
#IF (PLATFORM == PLT_N8)
		.DB	Z180_CLKDIV
		.DB	Z180_MEMWAIT
		.DB	Z180_IOWAIT
		.DB	Z180_CNTLB0
		.DB	Z180_CNTLB1
#ELSE
		.FILL	5,$FF
#ENDIF

		.DB	BOOTTYPE
		.DB	BOOT_TIMEOUT
		.DB	BOOT_DEFAULT
		
		.DB	DEFCON
		.DB	ALTCON
		.DW	CONBAUD / 10
		.DB	DEFVDA
		.DB	DEFEMU
		.DB	TERMTYPE
		
		.DB	DEFIOBYTE
		.DB	ALTIOBYTE
		.DB	WRTCACHE
		.DB	DSKTRACE
		.DB	0		; DSKMAP
		.DB	CLRRAMDISK
		
		.DB	DSKYENABLE
		
		.DB	UARTENABLE
		.DB	UARTCNT
#IF (UARTENABLE & (UARTCNT >= 1))
		.DB	UART0IOB
		.DW	UART0BAUD / 10
		.DB	UART0FIFO
		.DB	UART0AFC
#ELSE
		.FILL	5,$FF
#ENDIF
#IF (UARTENABLE & (UARTCNT >= 2))
		.DB	UART1IOB
		.DW	UART1BAUD / 10
		.DB	UART1FIFO
		.DB	UART1AFC
#ELSE
		.FILL	5,$FF
#ENDIF
#IF (UARTENABLE & (UARTCNT >= 3))
		.DB	UART2IOB
		.DW	UART2BAUD / 10
		.DB	UART2FIFO
		.DB	UART2AFC
#ELSE
		.FILL	5,$FF
#ENDIF
#IF (UARTENABLE & (UARTCNT >= 4))
		.DB	UART3IOB
		.DW	UART3BAUD / 10
		.DB	UART3FIFO
		.DB	UART3AFC
#ELSE
		.FILL	5,$FF
#ENDIF
		
		.DB	ASCIENABLE
		.DW	ASCI0BAUD / 10
		.DW	ASCI1BAUD / 10
		
		.DB	VDUENABLE

		.DB	CVDUENABLE

		.DB	UPD7220ENABLE

		.DB	N8VENABLE
		
		.DB	FDENABLE
		.DB	FDMODE
		.DB	FDTRACE
		.DB	FDMEDIA
		.DB	FDMEDIAALT
		.DB	FDMAUTO
		
		.DB	IDEENABLE
		.DB	IDEMODE
		.DB	IDETRACE
		.DB	IDE8BIT
		.DW	IDECAPACITY

		.DB	PPIDEENABLE
		.DB	PPIDEIOB
		.DB	PPIDETRACE
		.DB	PPIDE8BIT
		.DW	PPIDECAPACITY
		.DB	PPIDESLOW
		
		.DB	SDENABLE
		.DB	SDMODE
		.DB	SDTRACE
		.DW	SDCAPACITY
		.DB	SDCSIOFAST
		
		.DB	PRPENABLE
		.DB	PRPSDENABLE
		.DB	PRPSDTRACE
		.DW	PRPSDCAPACITY
		.DB	PRPCONENABLE
		
		.DB	PPPENABLE
		.DB	PPPSDENABLE
		.DB	PPPSDTRACE
		.DW	PPPSDCAPACITY
		.DB	PPPCONENABLE
		
		.DB	HDSKENABLE
		.DB	HDSKTRACE
		.DW	HDSKCAPACITY
		
		.DB	PPKENABLE
		.DB	PPKTRACE
		
		.DB	KBDENABLE
		.DB	KBDTRACE
		
		.DB	TTYENABLE
		
		.DB	ANSIENABLE
		.DB	ANSITRACE

;
; BUILD INFORMATION STRINGS
;
SC_TIMESTAMP	.DB	TIMESTAMP, "$"
SC_BUILD	.DB	BIOSBLD, "$"
;
;	.EXPORT	DISKBOOT,BOOTDEVICE,BOOTLU
;
#ENDIF
;
	.FILL	$200-$,$FF
;
	.END
