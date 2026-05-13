//==========================================================================
// File Name   : ORAM_Arrangement.asm
// Description : SACM kernel ORAM arrangement
// Written by  : Benjamin Xu
// Last modified date: 2019/10/16
//==========================================================================

//**************************************************************************
// RAM Definition Area 
//**************************************************************************


OVERLAP_A1800_fptr_API_BLOCK:		.section 		.ORAM 		,.addr = 0x10
R_OVERLAP_A1800_fptr_API_BLOCK:		.DW		0x03				DUP(?)
OVERLAP_A1800_fptr_RAM_BLOCK:		.section 		.ORAM 		,.addr = 0x10 + 0x03
R_OVERLAP_A1800_fptr_RAM_BLOCK:		.DW		0x3E				DUP(?)
OVERLAP_A1800_DM_BLOCK_Global:		.section 		.ORAM 		,.addr = 0x10 + 0x03 + 0x3E
R_OVERLAP_A1800_DM_BLOCK_Global:	.DW		 0xB5				DUP(?)
OVERLAP_A1800_DM_BLOCK_Local:		.section 		.ORAM 		,.addr = 0x10 + 0x03 + 0x3E + 0xB5
R_OVERLAP_A1800_DM_BLOCK_Local:		.DW		 0x14C				DUP(?)
OVERLAP_A1800_fptr_EVENT_BLOCK:		.section 		.ORAM 		,.addr = 0x10 + 0x03 + 0x3E + 0xB5 + 0x14C
R_OVERLAP_A1800_fptr_EVENT_BLOCK:	.DW		 0x05				DUP(?)

OVERLAP_DVR1800_RAM_BLOCK:			.section 		.ORAM 		,.addr = 0x188
R_OVERLAP_DVR1800_RAM_BLOCK:		.DW 	0x2BB				DUP(?)
OVERLAP_DVR1800_DM_BLOCK:			.section 		.ORAM 		,.addr = 0x188 + 0x2BB
R_OVERLAP_DVR1800_DM_BLOCK:			.DW 	0x32C				DUP(?)
OVERLAP_DVR1800_API_BLOCK:			.section 		.ORAM 		,.addr = 0x188 + 0x2BB + 0x32C
R_OVERLAP_DVR1800_API_BLOCK:		.DW 	0x1 				DUP(?)

DVR1800_ISR_RAMCode_SEC:			.section 		.ORAM 		,.addr = 0x770
R_DVR1800_ISR_RAMCode_SEC:			.DW 	0x80				DUP(?)		

CMPADC_ISR_RAMCode_SEC:				.section 		.ORAM 		,.addr = 0x800
R_CMPADC_ISR_RAMCode_SEC:			.DW 	0x40				DUP(?)




OVERLAP_VC4_RAM:					.section 		.ORAM 		,.addr = 0x257
R_OVERLAP_VC4_RAM:					.DW 	0x2B7				DUP(?)

OVERLAP_VC4_API_BLOCK:				.section 		.ORAM 		,.addr = 0x257 + 0x2B7
R_OVERLAP_VC4_API_BLOCK:			.DW 	0x3A				DUP(?)


OVERLAP_A18_DACOUT_RAM_BLOCK:		.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A
R_OVERLAP_A18_DACOUT_RAM_BLOCK:		.DW		0x280				DUP(?)

OVERLAP_VC4_BUFFER_RAM_BLOCK:		.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0x140
R_OVERLAP_VC4_BUFFER_RAM_BLOCK:		.DW		0x1E0				DUP(?)
//OVERLAP_VC4_BUFFER:					.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0xA0
//R_OVERLAP_VC4_BUFFER:				.DW		0x1E0				DUP(?)

EFFECT_VAD_ORAM_SECTION:			.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0x280 + 0xA0
R_EFFECT_VAD_ORAM_SECTION:			.DW		0x5				DUP(?)
OVERLAP_VC4_BUFFER:					.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0x280 + 0xA0 + 0x5
R_OVERLAP_VC4_BUFFER:				.DW		0x1E0				DUP(?)
OVERLAP_DM_RTVM:					.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0x280 + 0xA0 + 0x1E0 + 0x5
R_OVERLAP_DM_RTVM:					.DW		0x216				DUP(?)
OVERLAP_VC4_RAM_BLOCK:				.section		.ORAM		,.addr = 0x257 + 0x2B7 + 0x3A + 0x280 + 0xA0 + 0x1E0 + 0x5 + 0x216
R_OVERLAP_VC4_RAM_BLOCK:			.DW		0x13				DUP(?)


