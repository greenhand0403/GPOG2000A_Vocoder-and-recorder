//=================================================================================================
// File Name	: Touch_User.asm
// Description	: Touch setting
// Written by	: Ray Cheng
// Last modified date:
//                2012/10/24
// Note: 
//=================================================================================================
//***************************************************************************************
// Header File Included Area
//***************************************************************************************
.include GPCE36_CE5.inc
.include CTS_Sensor.inc
.include Touch_Probe.inc
.include TP_Command.inc

.define TouchProbe  0
.define C_ON	    1
.define C_OFF	    0      
//***************************************************************************************
// Constant Definition Area
//***************************************************************************************
//
// Touch sensor parameter. Be defined by user. ++
//
.define C_RefPad                 	C_OFF		  //ON C_PadNumber= C_TouchPadNum + 1
.define	C_TouchPadNum				2            // Max. = 24

.if C_RefPad == C_ON
.define	C_PadNumber					C_TouchPadNum+1 
.else
.define	C_PadNumber					C_TouchPadNum
.endif

//.define	C_ScanNo					60
.define	C_ScanNo_Type1				70  //100
//.define	C_ScanNo_Type2				200
.define	C_NumOfScans				1
.define	C_UpStep					20
.define	C_DnStep					40
.define	C_AbnorDetCntEn				1			//0:Disable, 1:Enable
.define	C_AbnorDetCnt				40
.define C_AutoReleaseEn				1			//0:Disable, 1:Enable
.define C_AutoReleaseCnt			2000
.define C_SchmittH1                 600
.define C_SchmittH2                 100
.define C_SchmittL1                 250
.define C_SchmittL2                 70


//-------------Get Flash Data-----------------------//
.define		C_GetFlashSchmitt			00			//00:Disable	01:Enable
//Modify by Gary 20160913
//.define		C_GetDataFlagAddr			0x1000		//DataFlag  Addr
//.define		C_GetHWParaAddr				C_GetDataFlagAddr+0x0012		//Hardware Parameter StartAddr, added by Gary,20160705
//.define		C_GetSchmittAddr			C_GetDataFlagAddr+0x0020		//DataStart Addr
.define		C_GetDataFlagAddr_L			0x0000		//DataFlag  Addr Low Byte
.define		C_GetDataFlagAddr_H			0x0000		//DataFlag  Addr High Byte
.define		C_GetHWParaAddrOffset		0x0012		//Hardware ParameterStart Offset Addr from DataFlag Addr, added by Gary,20160705
.define		C_GetSchmittAddrOffset		0x0020		//DataStart Offset Addr from DataFlag Addr
.define		C_StartData0Flag			0xAA55		//	Don't modify
.define		C_StartData1Flag			0x55AA		//	Don't modify


//
// CTS pin definition
//
.define CTS_Pad1                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX8
.define CTS_Pad2                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX9
.define CTS_Pad3                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX10
.define CTS_Pad4                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX11
.define CTS_Pad5                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX12
.define CTS_Pad6                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX13
.define CTS_Pad7                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX14
.define CTS_Pad8                  C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX15
.define CTS_Pad9                  C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX0
.define CTS_Pad10                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX1
.define CTS_Pad11                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX2
.define CTS_Pad12                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX3
.define CTS_Pad13                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX4
.define CTS_Pad14                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX5
.define CTS_Pad15                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX6
.define CTS_Pad16                 C_CTS_GPIO_Port_Sel_IOA | C_CTS_GPIO_CH_Sel_IOX7
.define CTS_Pad17                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX8
.define CTS_Pad18                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX9
.define CTS_Pad19                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX10
.define CTS_Pad20                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX11
.define CTS_Pad21                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX12
.define CTS_Pad22                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX13
.define CTS_Pad23                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX14
.define CTS_Pad24                 C_CTS_GPIO_Port_Sel_IOB | C_CTS_GPIO_CH_Sel_IOX15


//
// SchmittH_1
//
.define C_Pad1_SchmittH_1           C_SchmittH1
.define C_Pad2_SchmittH_1           C_SchmittH1
.define C_Pad3_SchmittH_1           C_SchmittH1
.define C_Pad4_SchmittH_1           C_SchmittH1
.define C_Pad5_SchmittH_1           C_SchmittH1
.define C_Pad6_SchmittH_1           C_SchmittH1
.define C_Pad7_SchmittH_1           C_SchmittH1
.define C_Pad8_SchmittH_1           C_SchmittH1
.define C_Pad9_SchmittH_1           C_SchmittH1
.define C_Pad10_SchmittH_1          C_SchmittH1
.define C_Pad11_SchmittH_1          C_SchmittH1
.define C_Pad12_SchmittH_1          C_SchmittH1
.define C_Pad13_SchmittH_1          C_SchmittH1
.define C_Pad14_SchmittH_1          C_SchmittH1
.define C_Pad15_SchmittH_1          C_SchmittH1
.define C_Pad16_SchmittH_1          C_SchmittH1
.define C_Pad17_SchmittH_1          C_SchmittH1
.define C_Pad18_SchmittH_1          C_SchmittH1
.define C_Pad19_SchmittH_1          C_SchmittH1
.define C_Pad20_SchmittH_1          C_SchmittH1
.define C_Pad21_SchmittH_1          C_SchmittH1
.define C_Pad22_SchmittH_1          C_SchmittH1
.define C_Pad23_SchmittH_1          C_SchmittH1
.define C_Pad24_SchmittH_1          C_SchmittH1


//
// SchmittH_2
//
.define C_Pad1_SchmittH_2           C_SchmittH2
.define C_Pad2_SchmittH_2           C_SchmittH2
.define C_Pad3_SchmittH_2           C_SchmittH2
.define C_Pad4_SchmittH_2           C_SchmittH2
.define C_Pad5_SchmittH_2           C_SchmittH2
.define C_Pad6_SchmittH_2           C_SchmittH2
.define C_Pad7_SchmittH_2           C_SchmittH2
.define C_Pad8_SchmittH_2           C_SchmittH2
.define C_Pad9_SchmittH_2           C_SchmittH2
.define C_Pad10_SchmittH_2          C_SchmittH2
.define C_Pad11_SchmittH_2          C_SchmittH2
.define C_Pad12_SchmittH_2          C_SchmittH2
.define C_Pad13_SchmittH_2          C_SchmittH2
.define C_Pad14_SchmittH_2          C_SchmittH2
.define C_Pad15_SchmittH_2          C_SchmittH2
.define C_Pad16_SchmittH_2          C_SchmittH2
.define C_Pad17_SchmittH_2          C_SchmittH2
.define C_Pad18_SchmittH_2          C_SchmittH2
.define C_Pad19_SchmittH_2          C_SchmittH2
.define C_Pad20_SchmittH_2          C_SchmittH2
.define C_Pad21_SchmittH_2          C_SchmittH2
.define C_Pad22_SchmittH_2          C_SchmittH2
.define C_Pad23_SchmittH_2          C_SchmittH2
.define C_Pad24_SchmittH_2          C_SchmittH2


//
// SchmittL_1
//
.define C_Pad1_SchmittL_1           C_SchmittL1
.define C_Pad2_SchmittL_1           C_SchmittL1
.define C_Pad3_SchmittL_1           C_SchmittL1
.define C_Pad4_SchmittL_1           C_SchmittL1
.define C_Pad5_SchmittL_1           C_SchmittL1
.define C_Pad6_SchmittL_1           C_SchmittL1
.define C_Pad7_SchmittL_1           C_SchmittL1
.define C_Pad8_SchmittL_1           C_SchmittL1
.define C_Pad9_SchmittL_1           C_SchmittL1
.define C_Pad10_SchmittL_1          C_SchmittL1
.define C_Pad11_SchmittL_1          C_SchmittL1
.define C_Pad12_SchmittL_1          C_SchmittL1
.define C_Pad13_SchmittL_1          C_SchmittL1
.define C_Pad14_SchmittL_1          C_SchmittL1
.define C_Pad15_SchmittL_1          C_SchmittL1
.define C_Pad16_SchmittL_1          C_SchmittL1
.define C_Pad17_SchmittL_1          C_SchmittL1
.define C_Pad18_SchmittL_1          C_SchmittL1
.define C_Pad19_SchmittL_1          C_SchmittL1
.define C_Pad20_SchmittL_1          C_SchmittL1
.define C_Pad21_SchmittL_1          C_SchmittL1
.define C_Pad22_SchmittL_1          C_SchmittL1
.define C_Pad23_SchmittL_1          C_SchmittL1
.define C_Pad24_SchmittL_1          C_SchmittL1


//
// SchmittL_2
//
.define C_Pad1_SchmittL_2           C_SchmittL2
.define C_Pad2_SchmittL_2           C_SchmittL2
.define C_Pad3_SchmittL_2           C_SchmittL2
.define C_Pad4_SchmittL_2           C_SchmittL2
.define C_Pad5_SchmittL_2           C_SchmittL2
.define C_Pad6_SchmittL_2           C_SchmittL2
.define C_Pad7_SchmittL_2           C_SchmittL2
.define C_Pad8_SchmittL_2           C_SchmittL2
.define C_Pad9_SchmittL_2           C_SchmittL2
.define C_Pad10_SchmittL_2          C_SchmittL2
.define C_Pad11_SchmittL_2          C_SchmittL2
.define C_Pad12_SchmittL_2          C_SchmittL2
.define C_Pad13_SchmittL_2          C_SchmittL2
.define C_Pad14_SchmittL_2          C_SchmittL2
.define C_Pad15_SchmittL_2          C_SchmittL2
.define C_Pad16_SchmittL_2          C_SchmittL2
.define C_Pad17_SchmittL_2          C_SchmittL2
.define C_Pad18_SchmittL_2          C_SchmittL2
.define C_Pad19_SchmittL_2          C_SchmittL2
.define C_Pad20_SchmittL_2          C_SchmittL2
.define C_Pad21_SchmittL_2          C_SchmittL2
.define C_Pad22_SchmittL_2          C_SchmittL2
.define C_Pad23_SchmittL_2          C_SchmittL2
.define C_Pad24_SchmittL_2          C_SchmittL2


//
// ScanNo
//
.define C_Pad1_ScanNo           C_ScanNo_Type1
.define C_Pad2_ScanNo           C_ScanNo_Type1
.define C_Pad3_ScanNo           C_ScanNo_Type1
.define C_Pad4_ScanNo           C_ScanNo_Type1
.define C_Pad5_ScanNo           C_ScanNo_Type1
.define C_Pad6_ScanNo           C_ScanNo_Type1
.define C_Pad7_ScanNo           C_ScanNo_Type1
.define C_Pad8_ScanNo           C_ScanNo_Type1
.define C_Pad9_ScanNo           C_ScanNo_Type1
.define C_Pad10_ScanNo          C_ScanNo_Type1
.define C_Pad11_ScanNo          C_ScanNo_Type1
.define C_Pad12_ScanNo          C_ScanNo_Type1
.define C_Pad13_ScanNo          C_ScanNo_Type1
.define C_Pad14_ScanNo          C_ScanNo_Type1
.define C_Pad15_ScanNo          C_ScanNo_Type1
.define C_Pad16_ScanNo          C_ScanNo_Type1
.define C_Pad17_ScanNo          C_ScanNo_Type1
.define C_Pad18_ScanNo          C_ScanNo_Type1
.define C_Pad19_ScanNo          C_ScanNo_Type1
.define C_Pad20_ScanNo          C_ScanNo_Type1
.define C_Pad21_ScanNo          C_ScanNo_Type1
.define C_Pad22_ScanNo          C_ScanNo_Type1
.define C_Pad23_ScanNo          C_ScanNo_Type1
.define C_Pad24_ScanNo          C_ScanNo_Type1


//
// ScanNo Timer Setting
//
.define C_Pad1_CtsTimerSetting			(65536-C_Pad1_ScanNo)
.define C_Pad2_CtsTimerSetting          (65536-C_Pad2_ScanNo)
.define C_Pad3_CtsTimerSetting          (65536-C_Pad3_ScanNo)
.define C_Pad4_CtsTimerSetting          (65536-C_Pad4_ScanNo)
.define C_Pad5_CtsTimerSetting          (65536-C_Pad5_ScanNo)
.define C_Pad6_CtsTimerSetting          (65536-C_Pad6_ScanNo)
.define C_Pad7_CtsTimerSetting          (65536-C_Pad7_ScanNo)
.define C_Pad8_CtsTimerSetting          (65536-C_Pad8_ScanNo)
.define C_Pad9_CtsTimerSetting          (65536-C_Pad9_ScanNo)
.define C_Pad10_CtsTimerSetting         (65536-C_Pad10_ScanNo)
.define C_Pad11_CtsTimerSetting         (65536-C_Pad11_ScanNo)
.define C_Pad12_CtsTimerSetting         (65536-C_Pad12_ScanNo)
.define C_Pad13_CtsTimerSetting         (65536-C_Pad13_ScanNo)
.define C_Pad14_CtsTimerSetting         (65536-C_Pad14_ScanNo)
.define C_Pad15_CtsTimerSetting         (65536-C_Pad15_ScanNo)
.define C_Pad16_CtsTimerSetting         (65536-C_Pad16_ScanNo)
.define C_Pad17_CtsTimerSetting         (65536-C_Pad17_ScanNo)
.define C_Pad18_CtsTimerSetting         (65536-C_Pad18_ScanNo)
.define C_Pad19_CtsTimerSetting         (65536-C_Pad19_ScanNo)
.define C_Pad20_CtsTimerSetting         (65536-C_Pad20_ScanNo)
.define C_Pad21_CtsTimerSetting         (65536-C_Pad21_ScanNo)
.define C_Pad22_CtsTimerSetting         (65536-C_Pad22_ScanNo)
.define C_Pad23_CtsTimerSetting         (65536-C_Pad23_ScanNo)
.define C_Pad24_CtsTimerSetting         (65536-C_Pad24_ScanNo)

////
// Touch sensor parameter. Be defined by user. --
//


//.define C_ScanNumforCtsTimerSetting (65536 - C_ScanNo)

//***************************************************************************************
// Variable Publication Area
//***************************************************************************************
.public R_CTS_Sum
.public R_CTS_Reference
.public R_CTS_ReferenceL
.public R_CTS_RefScale
.public R_CTS_ScanTime
//.public R_TP_Buffer

//.if C_GetFlashSchmitt
.public R_CTS_ScanNo      	//Add
.public R_CTS_Schmitt_H	  	//Add by Gary 20160705
.public R_CTS_Schmitt_L	  	//Add by Gary 20160705
//.endif
//***************************************************************************************
// Table Publication Area
//***************************************************************************************
.public T_CTS_TouchInfo
.public T_CTS_SchmittH
.public T_CTS_SchmittL

.public	T_TouchInfo
.public R_Sum
.public R_Reference
.public R_ScanNo
.public R_Schmitt_H
.public R_Schmitt_L
//***************************************************************************************
// Function Call Publication Area
//***************************************************************************************
.public F_CTS_User_Init
.public  _CTS_CH_Sel
.public F_CTS_CH_Sel
.public  _CTS_Start
.public F_CTS_Start
.public F_CTS_ScanOneRound
.public	F_CTS_Get_SchmittH
.public	F_CTS_Get_SchmittL
.public F_CTS_GetScanTime

//***************************************************************************************
// External Function Definition Area
//***************************************************************************************
.external F_SPI_ReadAWord

//*******************************************************************
// External Variable Declaration
//*******************************************************************
.external R_CTS_UpStep
.external R_CTS_DnStep
.external R_CTS_AbnorDetCnt
.external R_CTS_AutoReleaseCnt

//***************************************************************************************
// Table Definition Area (be used by Touch Library)
//***************************************************************************************
.code
T_TouchInfo:
T_CTS_TouchInfo:
.DW C_PadNumber
.DW C_ScanNo_Type1
.DW C_UpStep
.DW C_DnStep
.DW C_AbnorDetCnt
.DW C_NumOfScans
.DW	C_AbnorDetCntEn
.DW C_AutoReleaseEn
.DW C_AutoReleaseCnt
.DW C_RefPad

T_CTS_SchmittH:
.DW T_SchmittH_1
.DW T_SchmittH_2

T_CTS_SchmittL:
.DW T_SchmittL_1
.DW T_SchmittL_2

T_SchmittH_1:
    .DW     C_Pad1_SchmittH_1,  C_Pad2_SchmittH_1,  C_Pad3_SchmittH_1,  C_Pad4_SchmittH_1
    .DW     C_Pad5_SchmittH_1,  C_Pad6_SchmittH_1,  C_Pad7_SchmittH_1,  C_Pad8_SchmittH_1
    .DW     C_Pad9_SchmittH_1,  C_Pad10_SchmittH_1, C_Pad11_SchmittH_1, C_Pad12_SchmittH_1
    .DW     C_Pad13_SchmittH_1, C_Pad14_SchmittH_1, C_Pad15_SchmittH_1, C_Pad16_SchmittH_1
    .DW     C_Pad17_SchmittH_1, C_Pad18_SchmittH_1, C_Pad19_SchmittH_1, C_Pad20_SchmittH_1
    .DW     C_Pad21_SchmittH_1, C_Pad22_SchmittH_1, C_Pad23_SchmittH_1, C_Pad24_SchmittH_1

T_SchmittH_2:
	.DW     C_Pad1_SchmittH_2,  C_Pad2_SchmittH_2,  C_Pad3_SchmittH_2,  C_Pad4_SchmittH_2
    .DW     C_Pad5_SchmittH_2,  C_Pad6_SchmittH_2,  C_Pad7_SchmittH_2,  C_Pad8_SchmittH_2
    .DW     C_Pad9_SchmittH_2,  C_Pad10_SchmittH_2, C_Pad11_SchmittH_2, C_Pad12_SchmittH_2
    .DW     C_Pad13_SchmittH_2, C_Pad14_SchmittH_2, C_Pad15_SchmittH_2, C_Pad16_SchmittH_2
    .DW     C_Pad17_SchmittH_2, C_Pad18_SchmittH_2, C_Pad19_SchmittH_2, C_Pad20_SchmittH_2
    .DW     C_Pad21_SchmittH_2, C_Pad22_SchmittH_2, C_Pad23_SchmittH_2, C_Pad24_SchmittH_2

T_SchmittL_1:
	.DW     C_Pad1_SchmittL_1,  C_Pad2_SchmittL_1,  C_Pad3_SchmittL_1,  C_Pad4_SchmittL_1
    .DW     C_Pad5_SchmittL_1,  C_Pad6_SchmittL_1,  C_Pad7_SchmittL_1,  C_Pad8_SchmittL_1
    .DW     C_Pad9_SchmittL_1,  C_Pad10_SchmittL_1, C_Pad11_SchmittL_1, C_Pad12_SchmittL_1
    .DW     C_Pad13_SchmittL_1, C_Pad14_SchmittL_1, C_Pad15_SchmittL_1, C_Pad16_SchmittL_1
    .DW     C_Pad17_SchmittL_1, C_Pad18_SchmittL_1, C_Pad19_SchmittL_1, C_Pad20_SchmittL_1
    .DW     C_Pad21_SchmittL_1, C_Pad22_SchmittL_1, C_Pad23_SchmittL_1, C_Pad24_SchmittL_1

T_SchmittL_2:
	.DW     C_Pad1_SchmittL_2,  C_Pad2_SchmittL_2,  C_Pad3_SchmittL_2,  C_Pad4_SchmittL_2
    .DW     C_Pad5_SchmittL_2,  C_Pad6_SchmittL_2,  C_Pad7_SchmittL_2,  C_Pad8_SchmittL_2
    .DW     C_Pad9_SchmittL_2,  C_Pad10_SchmittL_2, C_Pad11_SchmittL_2, C_Pad12_SchmittL_2
    .DW     C_Pad13_SchmittL_2, C_Pad14_SchmittL_2, C_Pad15_SchmittL_2, C_Pad16_SchmittL_2
    .DW     C_Pad17_SchmittL_2, C_Pad18_SchmittL_2, C_Pad19_SchmittL_2, C_Pad20_SchmittL_2
    .DW     C_Pad21_SchmittL_2, C_Pad22_SchmittL_2, C_Pad23_SchmittL_2, C_Pad24_SchmittL_2	
    
T_CTS_Interface:
    .DW     CTS_Pad1,  CTS_Pad2,  CTS_Pad3,  CTS_Pad4,  CTS_Pad5,  CTS_Pad6,  CTS_Pad7,  CTS_Pad8
    .DW     CTS_Pad9,  CTS_Pad10, CTS_Pad11, CTS_Pad12, CTS_Pad13, CTS_Pad14, CTS_Pad15, CTS_Pad16
    .DW     CTS_Pad17, CTS_Pad18, CTS_Pad19, CTS_Pad20, CTS_Pad21, CTS_Pad22, CTS_Pad23, CTS_Pad24

T_ScanNo:
	.DW		C_Pad1_ScanNo, C_Pad2_ScanNo, C_Pad3_ScanNo, C_Pad4_ScanNo, C_Pad5_ScanNo, C_Pad6_ScanNo, C_Pad7_ScanNo, C_Pad8_ScanNo
	.DW		C_Pad9_ScanNo, C_Pad10_ScanNo, C_Pad11_ScanNo, C_Pad12_ScanNo, C_Pad13_ScanNo, C_Pad14_ScanNo, C_Pad15_ScanNo, C_Pad16_ScanNo
	.DW		C_Pad17_ScanNo, C_Pad18_ScanNo, C_Pad19_ScanNo, C_Pad20_ScanNo, C_Pad21_ScanNo, C_Pad22_ScanNo, C_Pad23_ScanNo, C_Pad24_ScanNo

T_ScanNo_TimerSetting:
    .DW     C_Pad1_CtsTimerSetting,  C_Pad2_CtsTimerSetting,  C_Pad3_CtsTimerSetting,  C_Pad4_CtsTimerSetting,  C_Pad5_CtsTimerSetting,  C_Pad6_CtsTimerSetting,  C_Pad7_CtsTimerSetting,  C_Pad8_CtsTimerSetting
    .DW     C_Pad9_CtsTimerSetting,  C_Pad10_CtsTimerSetting, C_Pad11_CtsTimerSetting, C_Pad12_CtsTimerSetting, C_Pad13_CtsTimerSetting, C_Pad14_CtsTimerSetting, C_Pad15_CtsTimerSetting, C_Pad16_CtsTimerSetting
    .DW     C_Pad17_CtsTimerSetting, C_Pad18_CtsTimerSetting, C_Pad19_CtsTimerSetting, C_Pad20_CtsTimerSetting, C_Pad21_CtsTimerSetting, C_Pad22_CtsTimerSetting, C_Pad23_CtsTimerSetting, C_Pad24_CtsTimerSetting

//***************************************************************************************
// RAM Definition Area
//***************************************************************************************
.RAM 
R_CTS_Sum:				.dw		C_PadNumber	dup(?)
R_CTS_Reference:		.dw		C_PadNumber	dup(?)
R_CTS_ReferenceL:		.dw		C_PadNumber	dup(?)
R_CTS_RefScale:			.dw		C_PadNumber	dup(?)
R_CTS_ScanTime:			.dw		C_PadNumber	dup(?)
//R_TP_Buffer:		.dw 	C_PadNumber * 3 dup (?)	// For Touch Probe Used Only

//.if C_GetFlashSchmitt
//R_CTS_ScanNo:				.dw		C_PadNumber	dup(?)  //Marked by Gary 20160705
//R_Schmitt:			.dw		C_PadNumber	dup(?)  //Marked by Gary 20160705
//Modify by Gary 20160913
//R_CTS_ScanNo:			.dw		1			dup(?)		//Add by Gary 20160705
R_CTS_ScanNo:			.dw		C_PadNumber dup(?)		//Add by Gary 20160705
R_CTS_Schmitt_H:		.dw		C_PadNumber	dup(?)		//Add by Gary 20160705
R_CTS_Schmitt_L:		.dw		C_PadNumber	dup(?)		//Add by Gary 20160705
R_CTS_Ctrl0Para:		.dw		1			dup(?)		//Add by Gary 20160705
R_CTS_SendTP_Flag:		.dw		1			dup(?)	

//.ENDIF
//T_TouchInfo:		.dw		7
//
//
R_Sum:		.equ	 R_CTS_Sum
R_Reference: .equ     R_CTS_Reference
R_ScanNo:    .equ     R_CTS_ScanNo
R_Schmitt_H: .equ     R_CTS_Schmitt_H
R_Schmitt_L: .equ     R_CTS_Schmitt_L

.VAR R_CTS_SendTP_times
//***************************************************************************************
// CODE Definition Area
//***************************************************************************************
.CODE
//****************************************************************
// Function    : F_CTS_User_Init
// Description : Hardware initilazation for Touch, called by library
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_CTS_User_Init:	.proc 

	call F_GetTouch_FlashData_Init  //Initial From Flash, Add by Gary 20160705
	
	R1 = 0x05
	[P_CTS_HighTime] = R1;
	[P_CTS_DebTime] = R1;

    R1 = CTS_Pad1 | C_CTS_TMB_Dedicated_for_CTS | C_CTS_TMA_Dedicated_for_CTS | C_CTS_TMA_From_CTSModule | C_CTS_TMB_SYSCLK;
//    R1 = CTS_Pad1 | C_CTS_TMB_Dedicated_for_CTS | C_CTS_TMA_Dedicated_for_CTS | C_CTS_TMA_From_CTSModule | C_CTS_TMB_From_CTSRef;
    [P_CTS_Ctrl1] = R1;
    
    //Add by Gary 20160705
    .if C_GetFlashSchmitt
 	R1 = [R_CTS_Ctrl0Para];
 	R1 |= C_CTS_Enable | C_CTS_Auto_Mode;
 	[P_CTS_Ctrl0] = R1;
 	
    R1 = 65535;
    R2 = [R_CTS_ScanNo];
    R1 -= R2;
    R1 += 1;	
    [P_CTS_TMADATA] = R1;
    [P_CTS_TMACNT] = R1;
    //Add by Gary 20160705  end
    .else
//    R1 = C_CTS_Enable | C_CTS_Triangular_Mode_Enable | C_CTS_Double_Current_Disable | C_CTS_Auto_Mode; 
//    R1 |= C_CTS_Charge_Current_150uA | C_CTS_PH_PL_Duration_420ns | C_CTS_VolRef_SchmittW_U2D75_D0D25 | C_CTS_NoiseFilter_2MHz;
	
	R1 = C_CTS_Enable | C_CTS_Auto_Mode;
//	R1 = C_CTS_Enable | C_CTS_Auto_Mode | C_CTS_RefGPIO_CH_Sel_IOX4 | C_CTS_RefGPIO_Port_Sel_IOB | C_CTS_CTSRef_Enable;
    [P_CTS_Ctrl0] = R1;
    
    R1 = 0;    
    [P_CTS_TMBDATA] = R1;    
    [P_CTS_TMBCNT] = R1;    
    
    R1 = C_Pad1_CtsTimerSetting;    
    [P_CTS_TMADATA] = R1;    
    [P_CTS_TMACNT] = R1;
	.endif
	
	R1 = 0;
	[R_CTS_SendTP_Flag] = R1;
	[R_CTS_SendTP_times] = R1;
	
	R1 = [P_INT2_Ctrl]
    R1 |= C_IRQ6_CTSTMA;
    [P_INT2_Status] = R1;
    [P_INT2_Ctrl] = R1;    
//    [P_FIQ2_Sel] = R1;    
    
//==========Initial From Flash ======================//	
//	call	F_GetTouch_FlashData_Init	//Marked by Gary 20160705
    

//    FIQ ON;
	IRQ ON;
	retf;
	.endp
	
//****************************************************************
// Function    : F_CTS_CH_Sel
// Description : called by library to switch CTS channel
// Destroy     : R2, R3
// Parameter   : R1: CTS channel
// Return      : None
// Note        : None
//****************************************************************
_CTS_CH_Sel: .proc             
F_CTS_CH_Sel:
//	R2 = 0x20;
//	DS = R2;
	R3 = SEG T_ScanNo_TimerSetting
	R2 = T_ScanNo_TimerSetting;
    R2 += R1;
    R3 += 0, CARRY
    DS = R3
    R2 = D:[R2];
    [P_CTS_TMADATA] = R2;    
    [P_CTS_TMACNT] = R2;

	R3 = SEG T_CTS_Interface
    R2 = T_CTS_Interface
    R2 += R1;
    R3 += 0, CARRY
    DS = R3
    R2 = D:[R2];
    R3 = [P_CTS_Ctrl1];    
    R3 &= ~(C_CTS_GPIO_Port_Sel | C_CTS_GPIO_CH_Sel);
    R3 |= R2;
    [P_CTS_Ctrl1] = R3;    

    retf;
    .endp
    
//****************************************************************
// Function    : F_CTS_Start
// Description : called by library to start CTS
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_CTS_Start: .proc
F_CTS_Start:        
    R1 = [P_CTS_Ctrl1]
    R1 |= C_CTS_Start;
    [P_CTS_Ctrl1] = R1;    
    retf;
    .endp
    
//****************************************************************
// Function    : F_GetTouch_FlashData_Init
// Description : 
// Destory     : R1- R5
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_GetTouch_FlashData_Init:	.proc
	
.if C_GetFlashSchmitt
	push R1,R5 to [SP];
	//Modify by Gary 20160913
	//R1 = C_GetDataFlagAddr;
	R1 = C_GetDataFlagAddr_L;
	R2 = C_GetDataFlagAddr_H;
	push R1,R2 to [SP];
	//R2 = 0x0000;	
	call F_SPI_ReadAWord;
	CMP	R1,C_StartData0Flag;			// Check StartData0 Flag
	JNE	?L_GetFlashDataErr
	
	pop R1,R2 from [SP];
	R1 += 2;
	R2 += 0,carry;
	push R1,R2 to [SP];
	//r2 = 0x0000;
	call F_SPI_ReadAWord;
	CMP	R1,C_StartData1Flag;			// Check StartData1 Flag
	JNE	?L_GetFlashDataErr
	
	pop R1,R2 from [SP];
	call F_GetTouchSet					//Get UpStep,DnStep....

	call F_GetHWSet						//Get Hardware Parameter, Add by Gary 20160705
	
	call F_GetPerPadSet
	.comment @ //Modify by Gary 20160913
	//Change by Gary 20160705
	R1 = C_GetSchmittAddr;
	//R2 = 00;
	push R1,R2 to [SP];
	R2 = 0x0000;
	call F_SPI_ReadAWord;
	R3 = R1;
	pop R1,R2 from [SP];
	cmp R3,0;
	JE ?L_GetFlashDataErr1
	R4 = R_CTS_ScanNo;
	[R4] = R3;							//Get ScanNo
?L_GetFlashSchmittLoop:
//	push R1,R2 to [SP];
//	R2 = 0x0000;
//	call F_SPI_ReadAWord;
//	R3 = R1 & 0xFF00;
//	pop R1,R2 from [SP];
	//Change by Gary end 20160705
//	R3 = R3 LSR 4;
//	R3 = R3 LSR 4;
//	JZ ?L_GetFlashDataErr1
//	R4 = R2 + R_CTS_ScanNo;
//	[R4] = R3;						//Get ScanNo 00XX
	R1 += 2	
	
	push R1,R2 to [SP];
	R2 = 0x0000;
	call F_SPI_ReadAWord;
	R3 = R1;
	pop R1,R2 from [SP];
	CMP R3,00;
	JE ?L_GetFlashDataErr1
	R1 += 2;
	//R4 = R2 + R_Schmitt;			//Marked by Gary 20160705
	R4 = R2 + R_CTS_Schmitt_H;			//Add by Gary 20160705
	[R4] = R3;						 //Get SchmittH

	//Add by Gary 20160705
	push R1,R2 to [SP];
	R2 = 0x0000;
	call F_SPI_ReadAWord;
	R3 = R1;
	pop R1,R2 from [SP];
	CMP R3,00;
	JE ?L_GetFlashDataErr1;
	R1 += 2;
	R4 = R2 + R_CTS_Schmitt_L;
	[R4] = R3;						//Get SchmittL
	//Add by Gary end 20160705	
	
	R2 += 1;
	CMP	R2,C_PadNumber;
	JB	?L_GetFlashSchmittLoop;		//R2<C_PadNumber
	//@
	cmp R1 , 1;
	je ?L_GetFlashDataErr1;
	JMP	?L_GetFlahEnd
?L_GetFlashDataErr:
	pop R1,R2 from [SP];
?L_GetFlashDataErr1:				//Read Data Err From Flash.
	//Add by Gary 20160705
    R1 = C_CTS_Triangular_Mode_Enable | C_CTS_Double_Current_Disable|C_CTS_Charge_Current_150uA | C_CTS_PH_PL_Duration_420ns | C_CTS_VolRef_SchmittW_U2D75_D0D25 | C_CTS_NoiseFilter_2MHz;
    [R_CTS_Ctrl0Para] = R1;
	//Add by Gary 20160705 end

	//Change by Gary, 20160704
	R1 = 0;
//	R2 = T_CTS_TouchInfo + 1;
//	R2 = [R2];
//	R3 = R_CTS_ScanNo;
//	[R3] = R2;						//Get ScanNo From T_ScanNo_1
?L_GetSchmittTableLoop:
	R2 = 0x20;
	DS = R2;
	//R2 = T_CTS_TouchInfo + 1;
	R2 = R1 + T_ScanNo;
	R2 = D:[R2];
	R3 = R1 + R_CTS_ScanNo;
	[R3] = R2;						//Get ScanNo From T_ScanNo_1

	R2 = R1 + T_SchmittH_1;
	//R2 = R1 + T_SchmittH_2;
	R2 = D:[R2];
	//R2 = R2 LSL	4;				//Marked by Gary 20160705
	//R2 = R2 LSL	4;				//Marked by Gary 20160705
	//R3 = R1 + R_Schmitt;			//Marked by Gary 20160705
	R3 = R1 + R_CTS_Schmitt_H;
	[R3] = R2;
	//R4 = R2;						//Get SchmittH From T_SchmittH_1, Marked by Gary 20160705
	
	R2 = R1 + T_SchmittL_1;
	//R2 = R1 + T_SchmittL_2;
	R2 = D:[R2];
	//R2 &= 0x00FF;					//Marked by Gary 20160705
	//R2 |= R4;						//Marked by Gary 20160705
	R3 = R1 + R_CTS_Schmitt_L;
	[R3] = R2;					  	//Get SchmittL From T_SchmittL_1
	
	R1 += 1;
	CMP	R1,C_PadNumber;
	JB	?L_GetSchmittTableLoop;	  	//R2<C_PadNumber	

?L_GetFlahEnd:
	pop R1,R5 from [SP]	

.else
	push R1,R5 to [SP];
	//Change by Gary 20160705
	R1 = 0;
//	R2 = T_CTS_TouchInfo + 1;
//	R2 = [R2];
//	R3 = R_CTS_ScanNo;
//	[R3] = R2;						//Get ScanNo From T_ScanNo_1
?L_GetTableLoop:
	//R2 = 0x20;
	R3 = SEG T_ScanNo
	//DS = R2;
	//R2 = T_CTS_TouchInfo + 1;
	R2 = R1 + T_ScanNo;
	R3 += 0, CARRY
	DS = R3
	R2 = D:[R2];
	R3 = R1 + R_CTS_ScanNo;
	[R3] = R2;						//Get ScanNo From T_ScanNo_1
	//Change by Gary end 20160705
	
	R3 = SEG T_SchmittH_1
	R2 = R1 + T_SchmittH_1;
	R3 += 0, CARRY
	DS = R3
	//R2 = R1 + T_SchmittH_2;
	R2 = D:[R2];
	//R2 = R2 LSL	4;				//Marked by Gary 20160705
	//R2 = R2 LSL	4;				//Marked by Gary 20160705
	R3 = R1 + R_CTS_Schmitt_H;
	[R3] = R2;
	
	R3 = SEG T_SchmittL_1
	R2 = R1 + T_SchmittL_1;
	R3 += 0, CARRY
	DS = R3
	//R2 = R1 + T_SchmittL_2;
	R2 = D:[R2];
	R3 = R1 + R_CTS_Schmitt_L;
	//R2 |= [R3];					//Marked by Gary 20160705	
	[R3] = R2;
	
	R1 += 1;
	CMP	R1,C_PadNumber;
	JB	?L_GetTableLoop;		//R2<C_PadNumber	
	pop R1,R5 from [SP]	
		
.endif	

	retf;
	.endp		

.if C_GetFlashSchmitt		//Add by Gary 20160913
//****************************************************************
// Function    : F_NextReadSPIAWord
// Description : 
// Destory     : R1, R2
// Parameter   : R1: Flash Low Address
// Return      : R3: 1 word Data
// Note        : None
//****************************************************************
F_NextReadSPIAWord:
	R1 += 2;
	R2 += 0,carry;
	push R1,R2 to [SP];
	//R2 = 0x0000;			//Flash High Address //Modify by Gary 20160913 
	call F_SPI_ReadAWord;
	R3 = R1;
	pop R1,R2 from [SP];
	retf;	

//****************************************************************
// Function    : F_GetTouchSet
// Description : 
// Destory     : R1- R4
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************	
F_GetTouchSet:	.proc
	//Modify by Gary 20160913
	//R1 = C_GetDataFlagAddr;
	R1 = C_GetDataFlagAddr_L;
	R2 = C_GetDataFlagAddr_H;
	R1 += 4;
	R2 += 0,carry;
	push R1,R2 to [SP];
	//R2 = 0x0000;				//Flash High Address
	call F_SPI_ReadAWord;
	R3 = R1;	
	pop R1,R2 from [SP];	
	
	//[R_TouchSetFlag] = R2;	
	
	CALL F_NextReadSPIAWord	//R1 Addr	R2=Word Data

	//R3 = [R_TouchSetFlag];
	//R3 &= R2;
	
	//R2 = R3;
	//R2 = R2 LSR	4;
	//R2 = R2 LSR	4;
	//R3 = R3 LSL	4;
	//R3 = R3 LSL	4;
	//R3 |= R2;
	//[R_TouchSetFlag] = R3;	// TouchSetFlag :LLHH->HHLL
	
// C_GetDataFlagAddr:55AA,AA55,xxxx,xxxx,C_FlashUpStep,C_FlashDnStep,C_AbnorDetCnt,C_LowPassFilterHold,C_LowPassFilterRelease....
?L_TestUpStepFlag:
	CALL F_NextReadSPIAWord	//R1 Addr	R2=Word Data
	R4 = R3 & 0x00FF;
	[R_CTS_UpStep] = R4;			//Set UpStep
?L_TestDnStepFlag:
	R3 = R3 LSR	4;
	R3 = R3 LSR	4;
	[R_CTS_DnStep] = R3;			//Set DnStep

?L_TestAbnorDetFlag:
	CALL F_NextReadSPIAWord		//R1 Addr	R2=Word Data
	
	R4 = R3 & 0x00FF;
	[R_CTS_AbnorDetCnt] = R4;		//Set AbnorDetCnt	

?L_TestAutoReleaseFlag:
	R3 = R3 LSR 4;
	R3 = R3 LSR 4;
	R4 = R3;
	
	CALL F_NextReadSPIAWord		//R1 Addr	R2=Word Data
	R3 = R3 LSL 4;
	R3 = R3 LSL 4;
	R3 |= R4;
	[R_CTS_AutoReleaseCnt] = R3;	
?L_FlashSetEnd:
	retf;
	.endp

//Add by Gary 20160705
//****************************************************************
// Function    : F_GetHWSet
// Description : 
// Destory     : R1- R5
// Parameter   : R1: Flash Low Address
// Return      : None
// Note        : C_CTS_NoiseFilter,C_CTS_VolRef_SchmittWindow,C_CTS_PH_PL_Duration,C_CTS_Charge_Current,C_CTS_Double_Current,C_CTS_Triangular_Mode
//****************************************************************	
F_GetHWSet:	.proc
	push R1,R5 to [SP]
	//Modify by Gary 20160913
	//R1 = C_GetHWParaAddr;
	R1 = C_GetDataFlagAddr_L;
	R2 = C_GetDataFlagAddr_H;
	R1 += C_GetHWParaAddrOffset;
	R2 += 0,carry;
	R5 = 0;
	push R1,R2 to [SP];
	//R2 = 0x0000;				//Flash High Address
	call F_SPI_ReadAWord;
	R4 = R1;	
	pop R1,R2 from [SP];	
	R5 += 1;
?L_GetParaLoop:	
	CALL F_NextReadSPIAWord		//R1 Addr	R2=Word Data	
	R4 |= R3;
	R5 += 1;
	cmp R5 ,6;
	jb ?L_GetParaLoop;
	[R_CTS_Ctrl0Para] = R4;		//Set Hardware Parameter
	
	pop R1,R5 from [SP]
	retf;
	.endp
//Add by Gary end 20160705

//Add by Gary 20160705
//****************************************************************
// Function    : F_GetPerPadSet
// Description : 
// Destory     : R1- R5
// Parameter   : R1: Flash Low Address
// Return      : None
// Note        : C_CTS_NoiseFilter,C_CTS_VolRef_SchmittWindow,C_CTS_PH_PL_Duration,C_CTS_Charge_Current,C_CTS_Double_Current,C_CTS_Triangular_Mode
//****************************************************************	
F_GetPerPadSet: .proc
	push R1,R5 to [SP]
	//Modify by Gary 20160913
	//R1 = C_GetSchmittAddr;
	R1 = C_GetDataFlagAddr_L;
	R2 = C_GetDataFlagAddr_H;
	R1 += C_GetSchmittAddrOffset;
	R2 += 0,carry;
	R5 = 0;
	//R2 = 00;
	//push R1,R2 to [SP];
	//R2 = 0x0000;
	//call F_SPI_ReadAWord;
	//R4 = R1;
	//pop R1,R2 from [SP];
	//cmp R4,0;
	//JE ?L_GetError;
	//R5 = R_CTS_ScanNo;
	//[R5] = R4;							//Get ScanNo
?L_GetFlashSchmittLoop:
	push R1,R2 to [SP];
	//R2 = 0x0000;
	call F_SPI_ReadAWord;					//Get ScanNo
	R4 = R1;
	pop R1,R2 from [SP];
	cmp R4,0;
	JE ?L_GetError
	R3 = R5 + R_CTS_ScanNo;
	[R3] = R4;						//Get ScanNo 00XX
	
	//push R1,R2 to [SP];
	//R2 = 0x0000;
	//call F_SPI_ReadAWord;
	CALL F_NextReadSPIAWord		//R1 Addr	R2=Word Data		
	R4 = R3;
	//pop R1,R2 from [SP];
	CMP R4,0;
	JE ?L_GetError
	//R1 += 2;
	//R4 = R2 + R_Schmitt;			//Marked by Gary 20160705
	R3 = R5 + R_CTS_Schmitt_L;			//Add by Gary 20160705
	[R3] = R4;						 //Get SchmittL

	//Add by Gary 20160705
	//push R1,R2 to [SP];
	//R2 = 0x0000;
	//call F_SPI_ReadAWord;
	CALL F_NextReadSPIAWord;
	R4 = R3;
	//pop R1,R2 from [SP];
	CMP R4,0;
	JE ?L_GetError;
	//R1 += 2;
	R3 = R5 + R_CTS_Schmitt_H;
	[R3] = R4;						//Get SchmittH
	//Add by Gary end 20160705	
	
	R1 += 2	
	R2 += 0,carry;	
	R5 += 1;
	CMP	R5,C_PadNumber;
	JB	?L_GetFlashSchmittLoop;		//R2<C_PadNumber
	R1 = 0;
	jmp ?L_GetPerPad_End;
?L_GetError:
	R1 = -1;
?L_GetPerPad_End:
	
	pop R1,R5 from [SP]
	retf;
	.endp
.endif
	
//****************************************************************
// Function    : F_CTS_Get_SchmittH
// Description : Get ONThreshold for TouchSensor
// Destory     : None
// Parameter   : R1: Pad Index
// Return      : R2: Schmitt High
// Note        : None
//****************************************************************    
F_CTS_Get_SchmittH: .proc   
//Modify by Gary 20160913
.if C_GetFlashSchmitt	
	//R2 = R1 + R_Schmitt;// R1=Pad Index  ,Marked by Gary 20160705
	R2 = R1 + R_CTS_Schmitt_H;	// R1=Pad Index  ,Add by Gary 20160705
	R2 = [R2];
	//R2 = R2 LSR	4;		//Marked by Gary 20160705
	//R2 = R2 LSR	4;		// R_Schmitt = 0xHHLL,Marked by Gary 20160705
.else
	//R3 = 0x20;
	R3 = SEG T_CTS_SchmittH
	//DS = R3;		
	R2 += T_CTS_SchmittH;
	R3 += 0, CARRY
	DS = R3
	R2 = D:[R2];
	R2 += R1;
	R2 = D:[R2];
	R3 = R1 + R_CTS_Schmitt_H;
	[R3] = R2;
.endif
	retf
	.endp
	
//****************************************************************
// Function    : F_CTS_Get_SchmittL
// Description : Get OFFThreshold for TouchSensor
// Destory     : None
// Parameter   : R1: Pad Index
// Return      : R2: Schmitt Low
// Note        : None
//****************************************************************    
F_CTS_Get_SchmittL: .proc   
//Modify by Gary 20160913
.if C_GetFlashSchmitt
	//R2 = R1 + R_Schmitt; // R1=Pad Index, //Marked by Gary 20160705
	R2 = R1 + R_CTS_Schmitt_L; 	// R1=Pad Index
	R2 = [R2];
	//R2 &= 0x00FF;		// R_Schmitt = 0xHHLL, //Marked by Gary 20160705
.else
	//R3 = 0x20;
	R3 = SEG T_CTS_SchmittL
	//DS = R3;		
	R2 += T_CTS_SchmittL;
	R3 += 0, CARRY
	DS = R3
	R2 = D:[R2];
	R2 += R1;
	R2 = D:[R2];
	R3 = R1 + R_CTS_Schmitt_L;
	[R3] = R2;	
.endif
	retf
	.endp

//****************************************************************
// Function    : F_CTS_ScanOneRound
// Description : Touch sensor library will call this function when finish a round of touch pad scan
// Destory     : 
// Parameter   : R1 = Sensor Result
// Return      : None
// Note        : None
//****************************************************************
F_CTS_ScanOneRound:	.proc

.if TouchProbe
	push R2, R5 to [SP];
	// User Code
	
	R1=[R_CTS_SendTP_times]
	R1=R1+1;
   [R_CTS_SendTP_times]=R1;
	CMP R1,4;
	JBE ?End
	call F_TP_ServiceLoop;					// R1 = Sensor Result Address
	r1=0;
	[R_CTS_SendTP_times]=r1;
	
?End:	
	
//	R4 = R1;
//	R1 = [R_CTS_SendTP_Flag];
//	cmp R1, 0x00;
//	jnz ?L_Send_Para1;
//	
//?L_Send_Para0:
//	R1 += 1;
//	[R_CTS_SendTP_Flag] = R1;
//	R1 = C_TP_SendAllPAD_ScanNo_THH_THL;
//	R2 = 0x00;
//	R3 = 0x00;
//	call F_TP_ChangeCommand;
//	R1 = R4;
//	call F_TP_ServiceLoop;					// R1 = Sensor Result Address
//	
//	R1 = C_TP_SendAllPAD_SUM_REF;
//	R2 = 0x00;
//	R3 = 0x00;
//	call F_TP_ChangeCommand;
//	pop R2, R5 from [SP];
//	retf;
//	
//?L_Send_Para1:	
//	setb [R_CTS_SendTP_Flag], 0;
//
//	R1 = R4;
//	call F_TP_ServiceLoop;					// R1 = Sensor Result Address

	pop R2, R5 from [SP];
.endif	
	retf;
	.endp

//****************************************************************
// Function    : F_CTS_GetScanTime
// Description : Get total charge and discharge time when finishing the number of scans(C_ScanNo) per pad.
// Destory     : 
// Parameter   : None
// Return      : R4
// Note        : None
//****************************************************************
F_CTS_GetScanTime:	.proc
	R4 = [P_CTS_CAPTMB];            // Get charge & discharge total time
	retf;
	.endp



