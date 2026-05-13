//==========================================================================
// File Name   : System.h
// Description : system APIs declaration
// Written by  : Ray Cheng
// Last modified date:
//              2012/10/24
//==========================================================================
#ifndef	__SYSTEM_H__
#define	__SYSTEM_H__

extern void System_Initial(void);
extern void System_ServiceLoop(void);
extern void WatchdogClear(void);
extern unsigned SP_GetCh(void);
extern void SP_SwitchChannel(unsigned ADC_Channel);
extern void Cache_Enable(void);
extern void Cache_Disable(void);

extern void SP_RampUpDAC1(void);
extern void SP_RampDnDAC1(void);
extern void SP_RampUpDAC2(void);
extern void SP_RampDnDAC2(void);

#endif