//==========================================================================
// File Name   : A1800.inc
// Description : SACM A1800 API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
//==========================================================================
.ifndef __A1800_fptr_INC__
.define __A1800_fptr_INC__

.external F_SACM_A1800_fptr_Initial
.external F_SACM_A1800_fptr_Play
.external F_SACM_A1800_fptr_Stop
.external F_SACM_A1800_fptr_Volume
.external F_SACM_A1800_fptr_Pause
.external F_SACM_A1800_fptr_Resume
.external F_SACM_A1800_fptr_Status
.external F_SACM_A1800_fptr_ServiceLoop
.external F_ISR_Service_SACM_A1800_fptr

.external F_Event_CH2_Initial
.external F_Event_CH2_ServiceLoop
.external F_IO_Event_CH2_Enable
.external F_IO_Event_CH2_Disable
.external F_ISR_Event_CH2_Service

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_A18_DECODE_OUT_LENGTH		320

.endif
//========================================================================================        
// End of SACM_A1800.inc
//========================================================================================