//==========================================================================
// File Name   : VC4.h
// Description : External C functions and constants declaration
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
//==========================================================================
#ifndef	__VC4_H__
#define	__VC4_H__

#define C_BUFF_PITCH		1
#define C_BUFF_LEN			(C_MAX_PITCH *  C_BUFF_PITCH)
#define C_MIN_PITCH			32
#define C_MAX_PITCH			160
#define C_FILTER_ORDER		32

struct VC4WorkingRamStruct
{	
	unsigned int	u8BuffPitch;
	unsigned int	u16BuffLen;
	unsigned int	u8ChangeMode;
	unsigned int	au8ChangeIndex[4];
	unsigned int	u8bWeighting;
	unsigned int	u8bReading;
	unsigned int	u8StepPitch;
	unsigned int	u16OutLength;
	unsigned int	u16RspLength;
	unsigned int	u16HmmLength;
	unsigned int	u16ModuloL;
	unsigned int	u16ModuloM;
	int	ai16TmpData[C_FILTER_ORDER + C_MAX_PITCH * 4];
	int	*pi16OutData;	//   0 ~ 159
	int	*pi16InData;	// 160 ~ 479
	int	*pi16RspData;	// 480 ~ 671
	unsigned int *pVc4InputBuf;
};

extern int SACM_VC4_Initial(void);
extern void SACM_VC4_ServiceLoop(void);
extern void SACM_VC4_Rec(unsigned RecMonitor, unsigned ADC_Channel);
extern void SACM_VC4_Play(int,int,int);
extern void SACM_VC4_Play_Con(int,int,int);
extern void SACM_VC4_Stop(void);
extern void SACM_VC4_Pause(void);
extern void SACM_VC4_Resume(void);
extern void SACM_VC4_Volume(int);
extern void SACM_VC4_Volume_Control(int);
extern unsigned int SACM_VC4_Status(void);
extern void SACM_VC4_Mode(int, struct VC4WorkingRamStruct*);
extern void SACM_VC4_ShiftPitch(int, struct VC4WorkingRamStruct*);
extern void SACM_VC4_ConstPitch(int, struct VC4WorkingRamStruct*);
extern void SACM_VC4_EchoGain(int, struct VC4WorkingRamStruct*);
extern void SACM_VC4_DA_FIRType(int);
extern void SACM_VC4_AD_FIRType(int);
extern unsigned SACM_VC4_Check_Con(void);
extern void USER_VC4_Volume(int);
extern void USER_VC4_SetStartAddr(int,int);
extern void USER_VC4_SetStartAddr_Con(int,int);

#endif
