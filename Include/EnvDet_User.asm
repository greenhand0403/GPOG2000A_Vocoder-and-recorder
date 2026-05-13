//==========================================================================
// File Name   : EnvDet_User.asm
// Description : Users implement functions
// Written by  : Ray Cheng
// Last modified date:
//              2009/10/19
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE36_CE5.inc


//**************************************************************************
// Contant Defintion Area
//**************************************************************************

//**************************************************************************
// Variable Publication Area
//**************************************************************************

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public F_EnvDet_HW_Init_
.public F_EnvDet_GetADC
.public F_EnvDet_AttackActive
.public F_EnvDet_ReleaseActive

//**************************************************************************
// External Function Declaration
//**************************************************************************

//**************************************************************************
// External Table Declaration
//**************************************************************************
//.external T_SACM_VC_SpeechTable

//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM

//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.TEXT

//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE
//****************************************************************
// Function    : F_EnvDet_HW_Init_
// Description : Hardware initilazation for envelope detection, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_EnvDet_HW_Init_:	.proc
	FIR_MOV OFF;
	
	R1 = C_Timer_Setting_16K;	
	[P_TimerA_Data] = R1;

	R1 = [P_Timer_Ctrl]
	R1 |= C_TimerA_SYSCLK;				
	[P_Timer_Ctrl] = R1;
	[P_TimerA_CNTR] = R1;
	
	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ0_TMA;
	[P_INT_Ctrl] = R1;

	R1 = [P_FIQ_Sel];
	R1 |= C_IRQ0_TMA;
	[P_FIQ_Sel] = R1;

	FIQ on;
	
	retf
	.endp

//****************************************************************
// Function    : F_EnvDet_GetADC
// Description : Get ADC data for envelope detection
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
.external R_ADCValue
F_EnvDet_GetADC:		.proc
	R1 = [R_ADCValue];		
	R1 ^= 0x8000;	
	retf;
	.endp

//****************************************************************
// Function    : F_EnvDet_AttackActive
// Description : 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_EnvDet_AttackActive:	.proc
//	R1 = 0xFFFF;
//	[P_IOB_Buffer] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_EnvDet_ReleaseActive
// Description : 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_EnvDet_ReleaseActive:	.proc
//	R1 = 0x0000;
//	[P_IOB_Buffer] = R1;
	retf;
	.endp

