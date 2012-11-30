;
;==================================================================================================
;   PPIDE DISK DRIVER - DATA
;==================================================================================================
;
PPIDE_SLICETRKS	.EQU	65				; TRACKS PER SLICE
PPIDE_TRKSIZE	.EQU	128				; SIZE OF TRACK (IN KB)
PPIDE_SLICESIZE	.EQU	((PPIDE_SLICETRKS * PPIDE_TRKSIZE) + 1023) / 1024 ; SIZE OF EACH SLICE (IN MB)
PPIDE_NUMSLICES	.EQU	PPIDECAPACITY / PPIDE_SLICESIZE	 ; TOTAL SLICES IN DEVICE
PPIDE0_SLICEDEF	.EQU	0				; DEFAULT SLICE FOR UNIT 0
PPIDE1_SLICEDEF	.EQU	1				; DEFAULT SLICE FOR UNIT 1
PPIDE2_SLICEDEF	.EQU	2				; DEFAULT SLICE FOR UNIT 0
PPIDE3_SLICEDEF	.EQU	3				; DEFAULT SLICE FOR UNIT 1
;
		.DB	DIODEV_PPIDE + 0
PPIDEDPH0 	.DW 	0000,0000
		.DW 	0000,0000
		.DW 	DIRBF,DPB_HD
		.DW 	PPIDECSV0,PPIDEALV0
		.DB	"LU"				; LOGICAL UNIT ENHANCEMENT SIGNATURE
PPIDE0_SLICE	.DW	PPIDE0_SLICEDEF			; CURRENTLY ACTIVE SLICE
		.DW	PPIDE_NUMSLICES			; NUMBER OF SLICES AVAILABLE
;
		.DB	DIODEV_PPIDE + 0
PPIDEDPH1 	.DW 	0000,0000
		.DW 	0000,0000
		.DW 	DIRBF,0FFFFH
		.DW 	PPIDECSV1,PPIDEALV1
		.DB	"LU"				; LOGICAL UNIT ENHANCEMENT SIGNATURE
PPIDE1_SLICE	.DW	PPIDE1_SLICEDEF			; CURRENTLY ACTIVE SLICE
		.DW	PPIDE_NUMSLICES			; NUMBER OF SLICES AVAILABLE
;
		.DB	DIODEV_PPIDE + 0
PPIDEDPH2 	.DW 	0000,0000
		.DW 	0000,0000
		.DW 	DIRBF,0FFFFH
		.DW 	PPIDECSV2,PPIDEALV2
		.DB	"LU"				; LOGICAL UNIT ENHANCEMENT SIGNATURE
PPIDE2_SLICE	.DW	PPIDE2_SLICEDEF			; CURRENTLY ACTIVE SLICE
		.DW	PPIDE_NUMSLICES			; NUMBER OF SLICES AVAILABLE
;
		.DB	DIODEV_PPIDE + 0
PPIDEDPH3 	.DW 	0000,0000
		.DW 	0000,0000
		.DW 	DIRBF,0FFFFH
		.DW 	PPIDECSV3,PPIDEALV3
		.DB	"LU"				; LOGICAL UNIT ENHANCEMENT SIGNATURE
PPIDE3_SLICE	.DW	PPIDE3_SLICEDEF			; CURRENTLY ACTIVE SLICE
		.DW	PPIDE_NUMSLICES			; NUMBER OF SLICES AVAILABLE
;
PPIDECKS	.EQU	0				; CKS: 0 FOR NON-REMOVABLE MEDIA
PPIDEALS	.EQU	256				; ALS: BLKS / 8 = 2048 / 8 = 256 (ROUNDED UP)
;
PPIDECSV0:	.FILL	PPIDECKS			; NO DIRECTORY CHECKSUM, NON-REMOVABLE DRIVE
PPIDEALV0:	.FILL	PPIDEALS			; MAX OF 2048 DATA BLOCKS
PPIDECSV1:	.FILL	PPIDECKS			; NO DIRECTORY CHECKSUM, NON-REMOVABLE DRIVE
PPIDEALV1:	.FILL	PPIDEALS			; MAX OF 2048 DATA BLOCKS
PPIDECSV2:	.FILL	PPIDECKS			; NO DIRECTORY CHECKSUM, NON-REMOVABLE DRIVE
PPIDEALV2:	.FILL	PPIDEALS			; MAX OF 2048 DATA BLOCKS
PPIDECSV3:	.FILL	PPIDECKS			; NO DIRECTORY CHECKSUM, NON-REMOVABLE DRIVE
PPIDEALV3:	.FILL	PPIDEALS			; MAX OF 2048 DATA BLOCKS