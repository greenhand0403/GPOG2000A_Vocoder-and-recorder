//==========================================================================
// File Name   : main.c
// Description : 
// Programmer : Jerry Hsu
// Last modified date: 2023/12/13
// Version: 
// Note: 第二版变声器demo
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
// C_PGA_29dB
unsigned EnvDet_AttackLevel = 0x0600;  //音量增大门槛值
unsigned EnvDet_AttackTime = 10;   //音量增大到门槛值后持续时间
unsigned EnvDet_ReleaseLevel = 0x0300; //音量减小门槛值
unsigned EnvDet_ReleaseTime = 4000;  //音量减小到门槛值后持续时间

unsigned PWMorCUR_Flg = 0; // 0:CUR DACOut ,1:PWM Out

unsigned R_REC_block = 29;   // 16M Max31;  32M Max63; 64M  Max127    /////29 =>>  0xF0000
unsigned char EffectMode = 0;   // 0:高音 1:低音 2:机器人
//***************************************************************************************
// Main Function Area
//***************************************************************************************
#define AUTO_IDLE           0   // 未启动自动监听
#define AUTO_WAIT_ATTACK    1   // 等待声音触发
#define AUTO_RECORDING      2   // 正在录音
#define AUTO_WAIT_REC_END   3   // 等待录音真正结束
#define AUTO_PLAYING        4   // 正在播放刚才录音
volatile unsigned Dbg_AttackCount;
volatile unsigned Dbg_ReleaseCount;
unsigned AutoState;
unsigned LastAttackCount;
unsigned LastReleaseCount;
void Auto_PrepareRecord(void);
void Auto_StartRecord(void);
void Auto_StartPlayRecorded(void);
void Auto_StopWorkMode(void);
void CMPADC_ReInit(void);
void CMPADC_Stop(void);
unsigned char KeyCount = 0;// 按第1次先进入工作模式，默认是高音调模式；按第2次，还是在工作模式，但是切换低音调；按第3次，还是在工作模式，但是机器人音效；按第4次还是播放一次滴声，然后退出工作模式
#define DI_SOUND_TIMEOUT_COUNT   60000UL
volatile unsigned char KeyBusy = 0;
volatile unsigned char AutoBusy = 0;
#define ADC_KEY_NONE       0
#define ADC_KEY_HIGH_PRESS 1   // 上拉型：按下约 2.7V
#define ADC_KEY_LOW_PRESS  2   // 下拉型：按下约 0.5V

volatile unsigned Dbg_IOA7_ADC_Raw = 0;
volatile unsigned Dbg_IOA7_ADC_Key = ADC_KEY_NONE;
volatile unsigned Dbg_IOA7_ADC_Count = 0;
unsigned Read_IOA7_ADC_Raw(void);
unsigned Scan_IOA7_ADC_Key(void);
void Handle_IOA7_ADC_Key(void);
extern void CMPADC_IOA7Key_Init(void);
extern unsigned R_ADCKeyRaw;
#define IOA7_ADC_LOW_PRESS_TH      800
#define IOA7_ADC_HIGH_PRESS_TH     1800
unsigned Last_IOA7_ADC_Key = ADC_KEY_NONE;
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
	// 音量检测
	AutoState = AUTO_IDLE;
	LastAttackCount = 0;
	LastReleaseCount = 0;
	// 新增：开机后进入 IOA7 ADC 按键检测模式
	CMPADC_IOA7Key_Init();
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
				
						ShiftPitchIdx = -4;
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
	
			case 0x0080:    // IOA7 + Vcc
				// if (KeyBusy)
				// 	break;
			
				// KeyBusy = 1;
			
				// PlayDiSound();
			
				// EffectMode = KeyCount;
			
				// if (KeyCount < 3)
				// {
				// 	KeyCount++;
				// 	AutoState = AUTO_IDLE;
				// 	Auto_PrepareRecord();
				// 	AutoState = AUTO_WAIT_ATTACK;
				// }
				// else
				// {
				// 	PlayDiSound();
				// 	KeyCount = 0;
				// 	Auto_StopWorkMode();
				// }
			
				// KeyBusy = 0;
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
				// VolCompressInitial();
				// SetVolCompressLevel(12);
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
 		// 新增：IOA7 ADC 按键只在空闲态检测
		Handle_IOA7_ADC_Key();
		SACM_VC4_ServiceLoop();
		SACM_DVR1800_ServiceLoop();

		// 音量检测状态机
		if (AutoState != AUTO_IDLE)
		{
			if (!AutoBusy)
			{
				Auto_StateMachine();
			}
		}

		System_ServiceLoop();
		
		EnvDet_Playloop();
	}
	
	return 0;
}
void Auto_StateMachine(void)
{
	switch (AutoState)
	{
		case AUTO_IDLE:
			break;

		case AUTO_WAIT_ATTACK:
			if (Dbg_AttackCount != LastAttackCount)
			{
				LastAttackCount = Dbg_AttackCount;
				LastReleaseCount = Dbg_ReleaseCount;

				Auto_StartRecord();

				AutoState = AUTO_RECORDING;
			}
			break;

		case AUTO_RECORDING:
			if (Dbg_ReleaseCount != LastReleaseCount)
			{
				LastReleaseCount = Dbg_ReleaseCount;

				SACM_DVR1800_Stop();

				AutoState = AUTO_WAIT_REC_END;
			}
			break;

		case AUTO_WAIT_REC_END:
			SACM_DVR1800_ServiceLoop();

			if ((SACM_DVR1800_Status() & 0x01) == 0)
			{
				Auto_StartPlayRecorded();

				AutoState = AUTO_PLAYING;
			}
			break;

		case AUTO_PLAYING:
			// SACM_VC4_ServiceLoop();
			// 这个状态是VC4播放完毕,此时回到IDLE状态,等待下一个attack事件
			if ((SACM_VC4_Status() & 0x01) == 0)
			{
				Auto_PrepareRecord();
				AutoState = AUTO_WAIT_ATTACK;
			}
			break;

		default:
			break;
	}
}
void PlayDiSound(void)
{
    unsigned long timeout = DI_SOUND_TIMEOUT_COUNT;

    if(chk_MIC_voice_flag == 1)
        chk_MIC_voice_flag = 0;

    *P_INT_Ctrl &= ~C_IRQ3_ADC;

    SACM_A1800_fptr_Initial();
    USER_A1800_fptr_Volume(9);
    A1800_fptr_Event_Initial();
    A1800_fptr_IO_Event_Enable();

    SACM_A1800_fptr_Stop();

    A1800_Idx = 0;
    USER_A1800_fptr_SetStartAddr(A1800_Idx);
    SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);

    SACM_VC4_Initial();
    SACM_VC4_AD_FIRType(ADC_FIR_Type);
    SACM_VC4_DA_FIRType(DAC_FIR_Type);
    SACM_VC4_Volume(65535);

    VC_Mode = VC4_SHIFT_PITCH_MODE;
    SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
    SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);

    while ((SACM_VC4_Status() & 0x01) != 0)
    {
        SACM_VC4_ServiceLoop();
        SACM_DVR1800_ServiceLoop();
        System_ServiceLoop();

        if (--timeout == 0)
        {
            SACM_VC4_Stop();
            SACM_A1800_fptr_Stop();
            break;
        }
    }
}
void EnableEnvDet(void)
{
	CMPADC_Init();
	EnvDet_Initial();						//Envelope initial
	EnvDet_SetAttackLevel(EnvDet_AttackLevel);
	EnvDet_SetAttackTime(EnvDet_AttackTime);
	EnvDet_SetReleaseLevel(EnvDet_ReleaseLevel);
	EnvDet_SetReleaseTime(EnvDet_ReleaseTime);
	EnvDet_Start();
	chk_MIC_voice_flag = 1;   ////start MIC EnvDet

    Dbg_AttackCount = 0;
    Dbg_ReleaseCount = 0;
    LastAttackCount = 0;
    LastReleaseCount = 0;
}
void Auto_PrepareRecord(void)
{
	if (AutoBusy)
        return;

    AutoBusy = 1;
    // 先停止旧流程
    chk_MIC_voice_flag = 0;
    EnvDet_Stop();
    CMPADC_Stop();

    SACM_A1800_fptr_Stop();
    SACM_VC4_Stop();
    SACM_DVR1800_Stop();

    // 先擦除录音区
    __asm("INT OFF");

    MoveSPIDriverToRAM_0();
    MoveSPIDriverToRAM_2();
    SPI_Flash_Block_Erase(R_REC_block);
    SPI_Flash_Block_Erase(R_REC_block + 1);

    __asm("INT FIQ,IRQ");

    // 再初始化 DVR1800
    MoveSPIDriverToRAM_0();
    MoveSPIDriverToRAM_1();
    SACM_DVR1800_Initial();

    // 最后才启动麦克风音量检测
    EnableEnvDet();
	AutoBusy = 0;
}

void Auto_StopWorkMode(void)
{
	AutoState = AUTO_IDLE;
	// 清掉计数，避免下次进入工作态时吃到旧 attack/release
    Dbg_AttackCount = 0;
    Dbg_ReleaseCount = 0;
    LastAttackCount = 0;
    LastReleaseCount = 0;
	// 停止麦克风音量检测功能
    // CMPADC_Silence_Disable();
    CMPADC_Stop();
	EnvDet_Stop();
	chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet

	// 停止任何播放录音的行为
    SACM_A1800_fptr_Stop();
    SACM_VC4_Stop();
    SACM_DVR1800_Stop();
}
void Auto_StartRecord(void)
{
	// 这里不能关闭mic，否则会导致后续无法触发麦克风安静时的release事件
	// if(chk_MIC_voice_flag == 1)
		// chk_MIC_voice_flag = 0;

    USER_DVR1800_SetStartAddr(0x4, R_REC_block);			// skip 4 Bytes for length header
	SACM_DVR1800_Rec(RecMonitorOff, Mic, DVR1800_BIT_RATE_16K);
}
void Auto_StartPlayRecorded(void)
{
    CMPADC_Stop();
	if(chk_MIC_voice_flag == 1)
		chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet
    SACM_A1800_fptr_Initial();
    USER_A1800_fptr_Volume(12);

    A1800_fptr_Event_Initial();
    A1800_fptr_IO_Event_Enable();
	// VolCompressInitial();
	// SetVolCompressLevel(9);
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
	
			ShiftPitchIdx = -2;
			SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);
			break;
	
		case 2:     // 机器人音调
			VC_Mode = VC4_RobotEffect1;
			SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
			break;
	
		default:
			break;
	}

	SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);	// manual mode playback
}
void CMPADC_Stop(void)
{
	*P_INT_Ctrl &= ~C_IRQ3_ADC;
	*P_INT_Status = C_IRQ3_ADC;
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

unsigned Read_IOA7_ADC_Raw(void)
{
    return R_ADCKeyRaw;
}
// 下拉接法：空闲 Dbg_IOA7_ADC_Key = 0，按下 = 2
// 上拉接法：空闲 Dbg_IOA7_ADC_Key = 0，按下 = 1
unsigned Scan_IOA7_ADC_Key(void)
{
    unsigned raw = Read_IOA7_ADC_Raw();
    unsigned key = ADC_KEY_NONE;

    Dbg_IOA7_ADC_Raw = raw;

    if (raw < IOA7_ADC_LOW_PRESS_TH)
    {
        key = ADC_KEY_LOW_PRESS;
    }
    else if (raw > IOA7_ADC_HIGH_PRESS_TH)
    {
        key = ADC_KEY_HIGH_PRESS;
    }
    else
    {
        key = ADC_KEY_NONE;
    }

    Dbg_IOA7_ADC_Key = key;
    return key;
}

void Handle_IOA7_ADC_Key(void)
{
    unsigned adcKey;

    // 只在空闲态检测，避免和 EnvDet / 录音 / 播放抢 CMPADC
    if (AutoState != AUTO_IDLE)
        return;

    if (KeyBusy || AutoBusy)
        return;

    adcKey = Scan_IOA7_ADC_Key();

    // 只有从 NONE -> PRESS 的瞬间触发一次
    if ((Last_IOA7_ADC_Key == ADC_KEY_NONE) && (adcKey != ADC_KEY_NONE))
    {
        Dbg_IOA7_ADC_Count++;

        // 这里先不要接正式业务，先只计数
        // 后面确认稳定后，再把原 case 0x0080 的逻辑搬进来
    }

    Last_IOA7_ADC_Key = adcKey;
}