//==========================================================================
// File Name   : EnvDet.inc
// Description : Envelope Detection API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2015/08/18
//==========================================================================
.ifndef __ENVDET_INC__
.define __ENVDET_INC__

.external F_EnvDet_Initial
.external F_EnvDet_Start
.external F_EnvDet_Stop
.external F_EnvDet_CheckStatus
.external F_EnvDet_GetEnvelopeData
.external F_EnvDet_SetTrackDnSpeed
.external F_EnvDet_SetAttackLevel
.external F_EnvDet_SetReleaseLevel
.external F_EnvDet_SetAttackTime
.external F_EnvDet_SetReleaseTime
.external F_EnvDet_ISR_Service
.external F_EnvDet_CheckEnvelope

.external EnvDet_OffsetCaliEnable
.external EnvDet_OffsetCaliDisable
.external EnvDet_VAD_Enable
.external EnvDet_VAD_Disable

.endif
//========================================================================================        
// End of EnvDet.inc
//========================================================================================