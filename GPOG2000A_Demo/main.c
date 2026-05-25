//==========================================================================
// File Name   : main.c
// Description : 
// Programmer : Jerry Hsu
// Last modified date: 2023/12/13
// Version: 
// Note: 原厂的变声器程程序demo，已验证可以， 我做了客制化音效的修改并删除了触摸按键相关
// IO0 1 2 录音/停止/播放 IO3 4 播放/停止预置音频 IO4 5 6 环境音量事件检测 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
#include "GPCE36_CE5.h"
#include "Resource.h"
#include "SACM.h"
#include "System.h"
#include "SPI_Flash.h"
#include "CTS_Sensor.h"
#include "EnvDet.h"
#include "VC4.h"

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
//#define	FUNC_CTS_Touch_EN
//#define TouchProbe_EN

#define C_Volume_Control_Enable			0x01
#define C_Volume_Control_Disable		0x00

#define C_PlayPrerecordData		0x0000
#define C_RecordData			0x0001
#define C_PlayRecordedData		0x0002

//
// High pass filter type
//
#define HPF_TYPE0                      0
#define HPF_TYPE1                      1

//
// RTVC mode definition
//
#define VC4_SHIFT_PITCH_MODE            0
#define VC4_CONST_PITCH_MODE	        1
#define VC4_ECHO_MODE		            2
#define VC4_RobotEffect1 				3
#define VC4_RobotEffect2 				4
#define VC4_StrangeTone 				5
#define VC4_DJEffect 					6
#define VC4_Vibration 					7
#define VC4_JetPlaneEffect 				8
#define VC4_USER_DEFINE_MODE1           9

//
// Parameter limit definition
//
#define MAX_VC4_SHIFT_PITCH_LIMIT	   12
#define MIN_VC4_SHIFT_PITCH_LIMIT	  -12
#define	MAX_VC4_CONST_PITCH_LIMIT      12
#define	MIN_VC4_CONST_PITCH_LIMIT     -12
#define MAX_VC4_ECHO_GAIN_LIMIT 	   12
#define MIN_VC4_ECHO_GAIN_LIMIT	      -12

//
// Envelope detection definition
//
#define C_EnvDet_Running				0x0001
#define C_EnvDet_AttackActive			0x0002
#define C_EnvDet_ReleaseActive			0x0004

//Record_Flow
#define C_Record_Flow_WaitEnv			0x01
#define C_Record_Flow_Recording			0x02
#define C_Record_Flow_WaitPlay			0x03
#define C_Record_Flow_Playing			0x04

////block 14, addr 0xE0000;  =>>  0xe0000 /2 = 0x70000; then add+ 0x8000  = 0x78000) //在Memory window 里 0x78000 可以看到该地址 的值
//#define C_REC_block          14 //29      // 16M Max31;  32M Max63; 64M  Max127    /////29 =>>  0xF0000

//**************************************************************************
// External Function Declaration
//**************************************************************************
extern void VolCompressInitial(void);
extern void SetVolCompressLevel(unsigned CompLev);
extern void CMPADC_Init(void);

extern void MoveSPIDriverToRAM_0(void);
extern void MoveSPIDriverToRAM_1(void);
extern void MoveSPIDriverToRAM_2(void);

extern unsigned DVR18_ExtMem_Low;
extern unsigned DVR18_ExtMem_High;

extern void USER_Set_Audio_OUT(void);
//**************************************************************************
// Global Variable Defintion Area
//**************************************************************************
struct	VC4WorkingRamStruct VC4WorkRam __attribute__((section("OVERLAP_VC4_RAM: .section .ORAM")));

int VC_Mode;
int ShiftPitchIdx;
int ConstPitchIdx;
int EchoGainIdx;
unsigned int VcVolIdx;
int ADC_FIR_Type;
int DAC_FIR_Type;
unsigned A1800_Idx = 0;
unsigned long Block_Addr = 0; 
int chk_MIC_voice_flag = 0;
unsigned Temp;
unsigned Key;
unsigned Record_Flow;

unsigned EnvDet_AttackLevel = 0x0600;  //音量增大门槛值
unsigned EnvDet_AttackTime = 0x40;   //音量增大到门槛值后持续时间
unsigned EnvDet_ReleaseLevel = 0x0300; //音量减小门槛值
unsigned EnvDet_ReleaseTime = 0x0280;  //音量减小到门槛值后持续时间

unsigned PWMorCUR_Flg = 0; // 0:CUR DACOut ,1:PWM Out

unsigned R_REC_block = 29;   // 16M Max31;  32M Max63; 64M  Max127    /////29 =>>  0xF0000
unsigned char EffectMode = 0;   // 0:高音 1:低音 2:机器人
//***************************************************************************************
// Main Function Area
//***************************************************************************************
int main()
{				
	//add your code here	
	Key = 0;
	
	System_Initial();			          	// System initial
	
	PWMorCUR_Flg = 1;        // 1:PWM DACOut;  0:CUR DACOut
	
	USER_Set_Audio_OUT();    //Set audio output is  CUR OUT
	VC_Mode = VC4_SHIFT_PITCH_MODE;
	ShiftPitchIdx = 11;
	ConstPitchIdx = 0;    
  	EchoGainIdx = 4;  
  	VcVolIdx = 12;
  	Record_Flow = C_Record_Flow_WaitEnv;	
  	
	CMPADC_Init();
	EnvDet_Initial();										//Envelope initial
	EnvDet_SetAttackLevel(EnvDet_AttackLevel);  //音量增大门槛值
	EnvDet_SetAttackTime(EnvDet_AttackTime);   //音量增大到门槛值后持续时间
	EnvDet_SetReleaseLevel(EnvDet_ReleaseLevel); //音量减小门槛值
	EnvDet_SetReleaseTime(EnvDet_ReleaseTime);  //音量减小到门槛值后持续时间
	EnvDet_Start();
	chk_MIC_voice_flag = 1;   ////start MIC EnvDet
	
	while(1)
	{
		Key = SP_GetCh();
		switch(Key)
		{	
			case 0x0001:	// IOA0 + Vcc
				if(chk_MIC_voice_flag == 1)
					chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
				SACM_A1800_fptr_Stop();
				SACM_VC4_Stop();
				// 擦除录音数据
				__asm("INT OFF");
				MoveSPIDriverToRAM_0();
				MoveSPIDriverToRAM_2();
				SPI_Flash_Block_Erase(R_REC_block);
				SPI_Flash_Block_Erase(R_REC_block + 1);
				CMPADC_Init();
				*P_INT_Ctrl = C_IRQ0_TMA | C_IRQ3_ADC;			//Allow TMA, ADC interrupt only.
				__asm("INT FIQ,IRQ");
				
				MoveSPIDriverToRAM_0();
				MoveSPIDriverToRAM_1();
				SACM_DVR1800_Initial();
				USER_DVR1800_SetStartAddr(0x4, R_REC_block);			// skip 4 Bytes for length header
				SACM_DVR1800_Rec(RecMonitorOff, Mic, DVR1800_BIT_RATE_16K);
				break;
			
			case 0x0002:	// IOA1 + Vcc
				SACM_DVR1800_Stop();
				break;
	
			case 0x0004:	// IOA2 + Vcc
				if(chk_MIC_voice_flag == 1)
					chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
				SACM_A1800_fptr_Initial();                 // A1800 initial
				USER_A1800_fptr_Volume(9);
				A1800_fptr_Event_Initial();	
				A1800_fptr_IO_Event_Enable();
				// VolCompressInitial();
				// SetVolCompressLevel(12);
				SACM_A1800_fptr_Stop();

				Block_Addr = (R_REC_block * 65536)/2;
				Block_Addr = Block_Addr + 0x8000;
				DVR18_ExtMem_Low = Block_Addr & 0xffff;
				DVR18_ExtMem_High = Block_Addr >> 16;

				SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);
				
				SACM_VC4_Initial();			// VC4 initial
				SACM_VC4_AD_FIRType(ADC_FIR_Type);
				SACM_VC4_DA_FIRType(DAC_FIR_Type);
				SACM_VC4_Volume(65535);// 最大声

				// SACM_VC4_Volume_Control(C_Volume_Control_Enable);

				switch(EffectMode)
				{
					case 0:     // 高音调
						VC_Mode = VC4_SHIFT_PITCH_MODE;
						SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
				
						ShiftPitchIdx = 8;
						SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);
						break;
				
					case 1:     // 低音调
						VC_Mode = VC4_SHIFT_PITCH_MODE;
						SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
				
						ShiftPitchIdx = -8;
						SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);
						break;
				
					case 2:     // 机器人音调
						VC_Mode = VC4_RobotEffect1;
						SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
						break;
				
					default:
						EffectMode = 0;
						break;
				}
				
				EffectMode++;
				if(EffectMode >= 3)
				{
					EffectMode = 0;
				}

				// SACM_VC4_Mode(VC4_SHIFT_PITCH_MODE, &VC4WorkRam); 
				// SACM_VC4_ShiftPitch(0, &VC4WorkRam); 
				
				SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);	// manual mode playback
				break;
	
			case 0x0008:	// IOA3 + Vcc
				if(chk_MIC_voice_flag == 1)
					chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
				*P_INT_Ctrl &= ~C_IRQ3_ADC;			// ADC interrupt off,when VC4 Play;
				SACM_A1800_fptr_Initial();                 // A1800 initial
				USER_A1800_fptr_Volume(9);
				A1800_fptr_Event_Initial();	
				A1800_fptr_IO_Event_Enable();
				// VolCompressInitial();
				// SetVolCompressLevel(12);
				SACM_A1800_fptr_Stop();
				// A1800_Idx ++;
				// if((A1800_Idx < 0) || (A1800_Idx >= 12))    ////in fileMerger rom bin  0 ~ 11 is A1800_Idx
					A1800_Idx = 0;
				USER_A1800_fptr_SetStartAddr(A1800_Idx);    // Set index address
				SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);
				
				SACM_VC4_Initial();			// VC4 initial
				SACM_VC4_AD_FIRType(ADC_FIR_Type);
				SACM_VC4_DA_FIRType(DAC_FIR_Type);
				SACM_VC4_Volume(65535);// 播放时使用最大声

		        VC_Mode = VC4_SHIFT_PITCH_MODE; 
		        SACM_VC4_Mode(VC_Mode, &VC4WorkRam); 
		        // ShiftPitchIdx = -11;// 20260513测试了变调是有效的
		        // SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);  		                    
				SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);	// manual mode playback
				break;
				
			case 0x0010:	// IOA4 + Vcc	
				SACM_A1800_fptr_Stop();
				SACM_VC4_Stop();
				break;
				
			case 0x0020:	// IOA5 + Vcc
				chk_MIC_voice_flag = 1;   ////start MIC EnvDet
				CMPADC_Init();
				EnvDet_Initial();										//Envelope initial
				EnvDet_SetAttackLevel(EnvDet_AttackLevel);  //音量增大门槛值
				EnvDet_SetAttackTime(EnvDet_AttackTime);   //音量增大到门槛值后持续时间
				EnvDet_SetReleaseLevel(EnvDet_ReleaseLevel); //音量减小门槛值
				EnvDet_SetReleaseTime(EnvDet_ReleaseTime);  //音量减小到门槛值后持续时间
				EnvDet_Start();
				
				break;
				
			case 0x0040:	// IOA6 + Vcc		
				EnvDet_Stop();
				chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
				__asm("clrb [0x3005], 1");  //P_IOB_Buffer			0x3005	
				__asm("clrb [0x3001], 7");  //P_IOA_Buffer
				break;
				
			case 0x0800:	// IOA11 + Vcc		
				if(chk_MIC_voice_flag == 1)
					chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
				*P_INT_Ctrl &= ~C_IRQ3_ADC;			// ADC interrupt off,when VC4 Play;
				SACM_A1800_fptr_Initial();                 // A1800 initial
				USER_A1800_fptr_Volume(9);
				A1800_fptr_Event_Initial();	
				A1800_fptr_IO_Event_Enable();
				VolCompressInitial();
				SetVolCompressLevel(12);
				SACM_A1800_fptr_Stop();
				// A1800_Idx ++;
				// if((A1800_Idx < 0) || (A1800_Idx >= 12))    //in fileMerger rom bin  0 ~ 11 is A1800_Idx
					A1800_Idx = 0;
				USER_A1800_fptr_SetStartAddr(A1800_Idx);    // Set index address
				SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);
				
				SACM_VC4_Initial();			// VC4 initial
				SACM_VC4_AD_FIRType(ADC_FIR_Type);
				SACM_VC4_DA_FIRType(DAC_FIR_Type);
				SACM_VC4_Volume_Control(C_Volume_Control_Enable);       	
		        VC_Mode = VC4_SHIFT_PITCH_MODE; 
		        SACM_VC4_Mode(VC_Mode, &VC4WorkRam); 
		        ShiftPitchIdx = 0;
		        SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);  		                    
				SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);	// manual mode playback
				break;
				
			default:
				break;
		} // end of switch
 		
		SACM_VC4_ServiceLoop();
		SACM_DVR1800_ServiceLoop();
		System_ServiceLoop();
		
		EnvDet_Playloop();
	}
	
	return 0;
}

void EnvDet_Playloop(void)
{
	if(chk_MIC_voice_flag == 0)
		return;	
	// IO Show status	
	Temp = EnvDet_CheckStatus();
	if(Temp & C_EnvDet_AttackActive) //start record
	{
		__asm("setb [0x3005], 1");  //P_IOB_Buffer			0x3005		
		__asm("setb [0x3001], 7");  //P_IOA_Buffer
		
	}
	else if(Temp & C_EnvDet_ReleaseActive) //Play record
	{
		__asm("clrb [0x3005], 1");  //P_IOB_Buffer			0x3005
		__asm("clrb [0x3001], 7");  //P_IOA_Buffer
		
	}
}