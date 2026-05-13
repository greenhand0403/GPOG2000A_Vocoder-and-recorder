//==========================================================================
// File Name   : TP_Command.h
// Description : Touch Probe Command definition
// Written by  : Ray Cheng
// Last modified date:
//              2014/11/05
//==========================================================================
#ifndef __TP_COMMAND_H__
#define __TP_COMMAND_H__

//Touch Probe----------------------------------------------------------------------
#define C_TP_Header						0xF0

//Send Data to Touch Probe---------------------------------------------------------
#define C_TP_SendAllPAD_SUM				0xC0	// Par1=None 		, Par2 = None
#define C_TP_SendAllPAD_SUM_REF			0xC1	// Par1=None 		, Par2 = None
#define C_TP_SendAllPAD_ScanNo_THH_THL	0xC2	// Par1=None 		, Par2 = None
#define C_TP_SendAPAD_SUM				0xC8	// Par1=PAD Index 	, Par2 = None
#define C_TP_SendAPAD_SUM_REF			0xC9	// Par1=PAD Index 	, Par2 = None
#define C_TP_SendAPAD_ScanNo_THH_THL	0xCA	// Par1=PAD Index 	, Par2 = None
#define C_TP_SendAPort_SUM				0xD0	// Par1=PORT Index 	, Par2 = Enable PAD
#define C_TP_SendAPort_SUM_REF			0xD1	// Par1=PORT Index 	, Par2 = Enable PAD
#define C_TP_SendAPort_ScanNo_THH_THL	0xD2	// Par1=PORT Index 	, Par2 = Enable PAD

#define C_TP_SendSelfCapSum_X				0xE0
#define C_TP_SendSelfCapSum_Y				0xE1
#define C_TP_SendMutualCap_Delta			0xE2
#define C_TP_SendMutualCap_Dynamic			0xE3
#define C_TP_SendMutualCap_StaticMean		0xE4
#define C_TP_SendMutualCap_6SNR				0xE5
#define C_TP_SendMutualCap_Signal			0xE6
#define C_TP_SendMutualCap_Noise			0xE7
#define C_TP_SendMutualCap_Raw				0xE8
#define C_TP_SendMutualCap_RawCompress		0xE9
#define C_TP_SendMutualCap_StatusShape		0xEA
#define C_TP_SendMutualCap_StatusFilter		0xEB
#define C_TP_SendMutualCap_StatusHybride	0xEC
#define C_TP_SendMutualCap_StatusDebug		0xED

#define C_TP_GetFirmwareVersion				0xEE
#define C_TP_GetFrameRate					0xEF

//Get Information from Touch Probe-------------------------------------------------
#define C_TP_PollingPCRequest					0xF1
#define C_TP_Restart							0xF8
//#define C_TP_PC_Request							0x01

#define C_TP_PCReq_SendAllPAD_SUM				0xC0
#define C_TP_PCReq_SendAllPAD_SUM_REF			0xC1
#define C_TP_PCReq_SendAllPAD_ScanNo_THH_THL	0xC2
#define C_TP_PCReq_SendAPAD_SUM					0xC8
#define C_TP_PCReq_SendAPAD_SUM_REF				0xC9
#define C_TP_PCReq_SendAPAD_ScanNo_THH_THL		0xCA
#define C_TP_PCReq_SendAPort_SUM				0xD0
#define C_TP_PCReq_SendAPort_SUM_REF			0xD1
#define C_TP_PCReq_SendAPort_ScanNo_THH_THL	0xD2

#define C_TP_PCReq_Set_ScanNub					0xD8

#define C_TP_PCReq_SetAllPAD_ScanNo_THH_THL		0xD9
#define C_TP_PCReq_SetaPAD_ScanNo_THH_THL		0xDA
#define C_TP_PCReq_SetaPort_ScanNo_THH_THL		0xDB

#endif
//========================================================================================        
// End of Touch.h
//========================================================================================