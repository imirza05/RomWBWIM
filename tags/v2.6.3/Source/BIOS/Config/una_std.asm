;
;==================================================================================================
;   ROMWBW 2.X CONFIGURATION FOR UNA
;==================================================================================================
;
; BUILD CONFIGURATION OPTIONS
;
CPUFREQ		.EQU	20		; IN MHZ, USED TO COMPUTE DELAY FACTORS
;
CLRRAMDISK	.EQU	CLR_AUTO	; CLR_ALWAYS, CLR_NEVER, CLR_AUTO (CLEAR IF INVALID DIR AREA)
;
DSKYENABLE	.EQU	FALSE		; TRUE FOR DSKY SUPPORT (DO NOT COMBINE WITH PPIDE)
;
DEFIOBYTE	.EQU	$00		; DEFAULT INITIAL VALUE FOR CP/M IOBYTE, $00=TTY, $01=CRT (MUST HAVE CRT HARDWARE)
WRTCACHE	.EQU	TRUE		; ENABLE WRITE CACHING IN CBIOS (DE)BLOCKING ALGORITHM
DSKTRACE	.EQU	FALSE		; ENABLE TRACING OF CBIOS DISK FUNCTION CALLS
;
BOOTTYPE	.EQU	BT_MENU		; BT_MENU (WAIT FOR KEYPRESS), BT_AUTO (BOOT_DEFAULT AFTER BOOT_TIMEOUT SECS)
BOOT_TIMEOUT	.EQU	21		; APPROX TIMEOUT IN SECONDS FOR AUTOBOOT, 0 FOR IMMEDIATE
BOOT_DEFAULT	.EQU	'Z'		; SELECTION TO INVOKE AT TIMEOUT
;
#DEFINE		AUTOCMD	""		; AUTO STARTUP COMMAND FOR CP/M
