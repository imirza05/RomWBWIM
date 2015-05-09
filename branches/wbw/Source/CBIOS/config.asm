;
; CBIOS BUILD CONFIGURATION OPTIONS
;
CLRRAMDISK	.EQU	CLR_AUTO	; CLR_ALWAYS, CLR_NEVER, CLR_AUTO (CLEAR IF INVALID DIR AREA)
WRTCACHE	.EQU	TRUE		; ENABLE WRITE CACHING IN CBIOS (DE)BLOCKING ALGORITHM
DSKTRACE	.EQU	FALSE		; ENABLE TRACING OF CBIOS DISK FUNCTION CALLS
;
#DEFINE		AUTOCMD	""		; AUTO STARTUP COMMAND FOR CP/M
;
CPM_LOC		.EQU	$D000		; LOCATION OF START OF CCP
;
#IFDEF PLTWBW
CPM_END		.EQU	$FE00		; ROMWBW OCCUPIES TOP 2 PAGES OF MEMORY
#ENDIF
;
#IFDEF PLTUNA
CPM_END		.EQU	$FF00		; UNA OCCUPIES TOP 1 PAGE OF MEMORY
#ENDIF
