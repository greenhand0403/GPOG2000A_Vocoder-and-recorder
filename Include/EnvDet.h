//==========================================================================
// File Name   : EnvDet.h
// Description : Envelope Detection API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2015/08/18
//==========================================================================
#ifndef __ENVDET_H__
#define __ENVDET_H__

extern void EnvDet_Initial (void);
extern void EnvDet_Start (void);
extern void EnvDet_Stop(void);
extern unsigned EnvDet_CheckStatus(void);
extern unsigned EnvDet_GetEnvelopeData(void);
extern void EnvDet_SetTrackDnSpeed(unsigned);
extern void EnvDet_SetAttackLevel(unsigned);
extern void EnvDet_SetReleaseLevel(unsigned);
extern void EnvDet_SetAttackTime(unsigned);
extern void EnvDet_SetReleaseTime(unsigned);

extern void EnvDet_OffsetCaliEnable(void);
extern void EnvDet_OffsetCaliDisable(void);
extern void EnvDet_VAD_Enable(void);
extern void EnvDet_VAD_Disable(void);

#endif
//========================================================================================        
// End of EnvDet.inc
//========================================================================================