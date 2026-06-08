//==========================================================================
// File Name   : main.c
// Description : 
// Programmer : 
// Last modified date: 2026/06/08
// Version: 
// Note: 最小实现版变声器，缺少按键触发的判断逻辑，必须自然的按键并松开才不会出错，长按会触发多次按键，导致系统状态未知
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
#include "GPCE36_CE5.h"
#include "Resource.h"
#include "SACM.h"
#include "System.h"
#include "SPI_Flash.h"
#include "EnvDet.h"
#include "VC4.h"

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
// 上拉按键时自动监听模式的状态定义
#define AUTO_IDLE           0   // 未启动自动监听
#define AUTO_WAIT_ATTACK    1   // 等待声音触发
#define AUTO_RECORDING      2   // 正在录音
#define AUTO_WAIT_REC_END   3   // 等待录音真正结束
#define AUTO_PLAYING        4   // 正在播放刚才录音
// IOA7 ADC 按键状态定义
#define ADC_KEY_NONE       0
#define ADC_KEY_HIGH_PRESS 1   // 上拉型：按下约 2.7V
#define ADC_KEY_LOW_PRESS  2   // 下拉型：按下约 0.5V
// 为ADC按键 下拉按键自动录音并播放设计的四种状态，对应 未按下时空闲、按下后自动录音、录音正在播放中、退出ADC按键模式变成数字按键上拉按键、手动按键触发播放录音）
#define KEYDOWN_LOW_IDLE              0
#define KEYDOWN_LOW_RECORDING     1
#define KEYDOWN_LOW_PLAYING       2
#define KEYDOWN_HIGH_MODE    3
#define KEYDOWN_LOW_StartPlayRecorded    4
// 下拉按键自动录音的固定持续时间
#define KEYDOWN_REC_TIME (64*7)
// 下拉按键的长按和短按
#define ADC_LOW_KEY_LONG_TICKS       64      // 约 1 秒
#define ADC_LOW_KEY_SHORT_MIN_TICKS  3       // 小于这个认为是抖动
// 下拉按键的长按和短按状态定义
#define LOW_KEY_ACTION_NONE    0
#define LOW_KEY_ACTION_SHORT   1
#define LOW_KEY_ACTION_LONG    2
#define LOW_KEY_ACTION_BOUNCE  3

#define IOA7_ADC_LOW_PRESS_TH      800
#define IOA7_ADC_HIGH_PRESS_TH     1800

#define MAX_SOUND_EFFECT 3// 3种有效的变声模式高音调 低音调 机器人音调
#define DI_SOUND_TIMEOUT_COUNT   60000UL
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
extern void CMPADC_IOA7Key_Init(void);// 初始化IOA7 ADC 按键检测模式

void Auto_PrepareRecord(void);
void Auto_StartRecord(void);
void Auto_StartPlayRecorded(void);
void Auto_StopWorkMode(void);
void CMPADC_Stop(void);

// ADC按键相关函数
unsigned Read_IOA7_ADC_Raw(void);
unsigned Scan_IOA7_ADC_Key(void);
void Handle_IOA7_ADC_Key(void);

// 正在做的自动录音10秒
void Do_IOA7_LowPress_RecorderAction(void);

void Update_ADC_LowKey_Action(unsigned adcKey);
//**************************************************************************
// Global Variable Defintion Area
//**************************************************************************
extern unsigned R_ADCKeyRaw;

struct	VC4WorkingRamStruct VC4WorkRam __attribute__((section("OVERLAP_VC4_RAM: .section .ORAM")));

int VC_Mode;
int ShiftPitchIdx;
int ConstPitchIdx;
int EchoGainIdx;
int ADC_FIR_Type;
int DAC_FIR_Type;
unsigned A1800_Idx = 0;
unsigned long Block_Addr = 0; 
int chk_MIC_voice_flag = 0;
unsigned Temp;
unsigned Key;

// C_PGA_29dB
unsigned EnvDet_AttackLevel = 0x0610;  //音量增大门槛值0610 0600
unsigned EnvDet_AttackTime = 15;   //音量增大到门槛值后持续时间15 64
unsigned EnvDet_ReleaseLevel = 0x0300; //音量减小门槛值
unsigned EnvDet_ReleaseTime = 2700;  //音量减小到门槛值后持续时间2700 640

unsigned PWMorCUR_Flg = 0; // 0:CUR DACOut ,1:PWM Out

unsigned R_REC_block = 6;   // 16M Max31;  32M Max63; 64M  Max127    //0x38000 ///29 =>>  0xF0000
unsigned char EffectMode = 0;   // 0:高音 1:低音 2:机器人

volatile unsigned Dbg_AttackCount;
volatile unsigned Dbg_ReleaseCount;
unsigned AutoState;
unsigned LastAttackCount;
unsigned LastReleaseCount;
// 按第1次先进入工作模式，默认是高音调模式；按第2次，还是在工作模式，但是切换低音调；按第3次，还是在工作模式，但是机器人音效；按第4次还是播放一次滴声，然后退出工作模式
unsigned char KeyCount = 0;
//上拉按键忙
volatile unsigned char KeyBusy = 0;
//处于前面三种变声自动监听状态，需要处理状态机
volatile unsigned char AutoBusy = 0;
// 仅供测试使用，查看按键 AD 值
volatile unsigned Dbg_IOA7_ADC_Raw = 0;
volatile unsigned Dbg_IOA7_ADC_Key = ADC_KEY_NONE;
// 判断长按还是短按
unsigned Last_IOA7_ADC_Key = ADC_KEY_NONE;
// ADC 按键状态机
unsigned keydown_rec = KEYDOWN_LOW_IDLE;
// 定时器，用于记录下拉自动录音时长达到固定时间后停止录音
volatile unsigned g_tmaDiv = 0;
volatile unsigned g_tma64Ticks = 0;

// void Wait_TMA64_Ticks(unsigned ticks);
// 下拉按键抖动相关状态变量
volatile unsigned LowKey_State = 0;          // 0=未按下, 1=按住中
volatile unsigned LowKey_DownTick = 0;       // 按下时刻
volatile unsigned LowKey_LastHoldTicks = 0;  // 最近一次按住时长
volatile unsigned LowKey_Action = LOW_KEY_ACTION_NONE;
volatile unsigned UpdateADCLongPressFlag = 0;
//***************************************************************************************
// Main Function Area
//***************************************************************************************
int main()
{
	Key = 0;
	
	System_Initial();			          	// System initial
	
	PWMorCUR_Flg = 1;        // 1:PWM DACOut;  0:CUR DACOut
	
	USER_Set_Audio_OUT();    //Set audio output is  CUR OUT
	VC_Mode = VC4_SHIFT_PITCH_MODE;
	ShiftPitchIdx = 0;
	ConstPitchIdx = 0;    
  	EchoGainIdx = 4;
	// 音量检测
	AutoState = AUTO_IDLE;
	LastAttackCount = 0;
	LastReleaseCount = 0;
	// ① 开机后进入 IOA7 ADC 按键检测模式
	CMPADC_IOA7Key_Init();
	// ② 开机进入上拉按键模式
	// keydown_rec = KEYDOWN_HIGH_MODE;
	while(1)
	{
		if (keydown_rec == KEYDOWN_LOW_IDLE)
		{
			// IOA7 ADC 按键只在空闲态检测
		   Handle_IOA7_ADC_Key();
		}
		else if (keydown_rec == KEYDOWN_HIGH_MODE)
		{
			Handle_Key();
		}
		// 变声器服务更新
		SACM_VC4_ServiceLoop();
		// 录音服务更新
		SACM_DVR1800_ServiceLoop();
		
		// 下拉按键模式的长按录音、短按播放的状态机
		if(keydown_rec == KEYDOWN_LOW_RECORDING)
		{
			// 正在录音状态，录满时间后自动停止
			if (g_tma64Ticks >= KEYDOWN_REC_TIME)
			{
				// 停止录音
				WatchdogClear();
				SACM_DVR1800_Stop();
				g_tmaDiv = 0;
        		g_tma64Ticks = 0;
				// 等待写入录音长度头
				SACM_DVR1800_ServiceLoop();
				System_ServiceLoop();
				while ((SACM_DVR1800_Status() & 0x01) != 0)
				{
					SACM_DVR1800_ServiceLoop();
					System_ServiceLoop();
				}
				// 再播放滴声提示，里面有自动判断等待播放完滴声提示
				PlayDiSound();
				// 回归 ADC 按键模式等待用户 长按重新录音或者短按播放
				keydown_rec = KEYDOWN_LOW_IDLE;
				CMPADC_IOA7Key_Init();
			}
		}
		else if (keydown_rec == KEYDOWN_LOW_StartPlayRecorded)
		{
			// 准备播放录音状态
			keydown_rec = KEYDOWN_LOW_PLAYING;
			// 初始化播放录音设置
			CMPADC_Stop();
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
			// SACM_VC4_AD_FIRType(ADC_FIR_Type);// 这里如果你启用这两句代码，会导致无法变调播放，我怀疑只需要initial一次，后续可以stop再暂停
    		// SACM_VC4_DA_FIRType(DAC_FIR_Type);
			SACM_VC4_Volume(65535);// 最大声

			SACM_VC4_Mode(VC_Mode, &VC4WorkRam);         
			SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);	// manual mode playback
			// 跑到后续的 loop 里面播放录音
		}
		else if (keydown_rec == KEYDOWN_LOW_PLAYING)
		{
			// 等待播放录音完毕，重新允许IOA7 ADC按键
			if ((SACM_VC4_Status() & 0x01) == 0)
			{
				keydown_rec = KEYDOWN_LOW_IDLE;
				CMPADC_IOA7Key_Init();
			}
		}
		else if (keydown_rec == KEYDOWN_HIGH_MODE)
		{
			// 上拉按键模式的音量检测状态机
			if (AutoState != AUTO_IDLE)
			{
				if (!AutoBusy)
				{
					Auto_StateMachine();
				}
			}
		}
		// 系统按键更新
		System_ServiceLoop();
		// 麦克风音量检测
		EnvDet_Playloop();
	}
	
	return 0;
}
void Handle_Key(void)
{
	Key = SP_GetCh();
	if(Key == 0x0080)
	{
		// 自动监听式变声器模式
		if (KeyBusy)
			return;
		KeyBusy = 1;
		PlayDiSound();
		EffectMode = KeyCount;
	
		if (KeyCount < MAX_SOUND_EFFECT)
		{
			KeyCount++;
			AutoState = AUTO_IDLE;
			Auto_PrepareRecord();
			AutoState = AUTO_WAIT_ATTACK;
		}
		else
		{
			PlayDiSound();
			KeyCount = 0;
			Auto_StopWorkMode();
			// 测试失败，从上拉4模式改硬件下拉，软件切到ADC按键模式
			// LowKey_State = 0;
			// LowKey_Action = LOW_KEY_ACTION_NONE;
			// UpdateADCLongPressFlag = 0;
			// Last_IOA7_ADC_Key = ADC_KEY_NONE;

			// keydown_rec = KEYDOWN_LOW_IDLE;
			// CMPADC_IOA7Key_Init();
		}
	
		KeyBusy = 0;
	}
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
	// VolCompressInitial();
	// SetVolCompressLevel(12);
    SACM_A1800_fptr_Stop();

    A1800_Idx = 0;
    USER_A1800_fptr_SetStartAddr(A1800_Idx);
    SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);

    SACM_VC4_Initial();
	// 很奇怪这两句话的作用是什么？注释掉的话，可以播放滴声，但是无法自动监听并回播录音了
    SACM_VC4_AD_FIRType(ADC_FIR_Type);
    SACM_VC4_DA_FIRType(DAC_FIR_Type);
    SACM_VC4_Volume(65535);

    VC_Mode = VC4_SHIFT_PITCH_MODE;
    SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
    SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);

    while ((SACM_VC4_Status() & 0x01) != 0)
    {
        SACM_VC4_ServiceLoop();
        // SACM_DVR1800_ServiceLoop();
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

	// 停止任何播放或录音的行为
    SACM_A1800_fptr_Stop();
    SACM_VC4_Stop();
    SACM_DVR1800_Stop();
}
void Auto_StartRecord(void)
{
    USER_DVR1800_SetStartAddr(0x4, R_REC_block);// skip 4 Bytes for length header
	SACM_DVR1800_Rec(RecMonitorOff, Mic, DVR1800_BIT_RATE_16K);
}
void Auto_StartPlayRecorded(void)
{
	if(chk_MIC_voice_flag == 1)
		chk_MIC_voice_flag = 0;	   ////stop MIC EnvDet

    CMPADC_Stop();
    SACM_A1800_fptr_Initial();
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

	switch(EffectMode)
	{
		case 0:     // 高音调
			VC_Mode = VC4_SHIFT_PITCH_MODE;
			ShiftPitchIdx = 8;
			break;
		case 1:     // 低音调
			VC_Mode = VC4_SHIFT_PITCH_MODE;
			ShiftPitchIdx = -3;
			break;
		case 2:     // 机器人音调
			VC_Mode = VC4_RobotEffect2;
			break;
		default:	// 不变调
			break;
	}
	SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
	SACM_VC4_ShiftPitch(ShiftPitchIdx, &VC4WorkRam);
	SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);
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
void Update_ADC_LowKey_Action(unsigned adcKey)
{
    unsigned now;
    unsigned hold;

    now = g_tma64Ticks;

    // 默认没有新动作
    LowKey_Action = LOW_KEY_ACTION_NONE;

    if (adcKey == ADC_KEY_LOW_PRESS)
    {
        if (LowKey_State == 0)
        {
            LowKey_State = 1;
            LowKey_DownTick = now;
        }
    }
    else
    {
        if (LowKey_State == 1)
        {
            LowKey_State = 0;

            hold = now - LowKey_DownTick;
            LowKey_LastHoldTicks = hold;

            if (hold >= ADC_LOW_KEY_LONG_TICKS)
            {
                LowKey_Action = LOW_KEY_ACTION_LONG;
            }
            else if (hold >= ADC_LOW_KEY_SHORT_MIN_TICKS)
            {
                LowKey_Action = LOW_KEY_ACTION_SHORT;
            }
            else
            {
                LowKey_Action = LOW_KEY_ACTION_BOUNCE;
            }
        }
    }
}
void Handle_IOA7_ADC_Key(void)
{
    unsigned adcKey;

	if (keydown_rec != KEYDOWN_LOW_IDLE)
		return;

    // 只在空闲态检测，避免和 EnvDet / 自动录音 / 自动播放抢 CMPADC
    if (AutoState != AUTO_IDLE)
        return;

    if (KeyBusy || AutoBusy)
        return;

	adcKey = Scan_IOA7_ADC_Key();

	if (UpdateADCLongPressFlag)
	{
		Update_ADC_LowKey_Action(adcKey);
		// 按键释放时才判定长按或短按
		if (adcKey == ADC_KEY_NONE)
		{
			if (LowKey_Action == LOW_KEY_ACTION_SHORT)
			{
				// 短按松开：播放已经录好的声音（此时是否应该禁用ADC按键？），播放结束后自动回到 ADC 按键模式
				keydown_rec = KEYDOWN_LOW_StartPlayRecorded;
				// 处理完一次短按，清除flag
				UpdateADCLongPressFlag = 0;
			}
			else if (LowKey_Action == LOW_KEY_ACTION_LONG)
			{
				// 长按松开：滴声 -> 擦除 -> 录音 5 秒 -> 停止 -> 回到 ADC 按键模式（在主循环状态机里面处理了）
				PlayDiSound();
				Do_IOA7_LowPress_RecorderAction();
				// 处理完一次长按，清除flag
				UpdateADCLongPressFlag = 0;
			}
		}
		Last_IOA7_ADC_Key = adcKey;
		return;
	}

    if ((Last_IOA7_ADC_Key == ADC_KEY_NONE) && (adcKey != ADC_KEY_NONE))
    {
        if (adcKey == ADC_KEY_LOW_PRESS)
        {
			if (UpdateADCLongPressFlag==0)
			{
				UpdateADCLongPressFlag = 1;
			}
			
        }else if (adcKey == ADC_KEY_HIGH_PRESS)
		{
			// 永久退出 IOA7 ADC 按键模式，将 CMPADC 交给麦克风静音检测使用

			keydown_rec = KEYDOWN_HIGH_MODE;

			KeyBusy = 1;

			PlayDiSound();

			EffectMode = KeyCount;

			if (KeyCount < MAX_SOUND_EFFECT)
			{
				KeyCount++;

				AutoState = AUTO_IDLE;
				Auto_PrepareRecord();
				AutoState = AUTO_WAIT_ATTACK;
			}
			// 这个分支为什么会影响上拉按键首次进入高音调模式？
			else 
			{
				PlayDiSound();
				KeyCount = 0;
				Auto_StopWorkMode();
			}

			KeyBusy = 0;
		}
		
    }
    Last_IOA7_ADC_Key = adcKey;
}
void Do_IOA7_LowPress_RecorderAction(void)
{
	// 擦除录音数据
	SACM_DVR1800_Stop();
	
	WatchdogClear();
	
	__asm("INT OFF");
	MoveSPIDriverToRAM_0();
	MoveSPIDriverToRAM_2();
	SPI_Flash_Block_Erase(R_REC_block);
	SPI_Flash_Block_Erase(R_REC_block + 1);
	__asm("INT FIQ,IRQ");
	// 初始化录音需要的 CMPADC
	CMPADC_Init();
	
	MoveSPIDriverToRAM_0();
	MoveSPIDriverToRAM_1();
	SACM_DVR1800_Initial();
	// 开始录音
	USER_DVR1800_SetStartAddr(0x4, R_REC_block);			// skip 4 Bytes for length header
	g_tmaDiv = 0;
    g_tma64Ticks = 0;
	
	SACM_DVR1800_Rec(RecMonitorOff, Mic, DVR1800_BIT_RATE_16K);
	keydown_rec = KEYDOWN_LOW_RECORDING;
}
// void Wait_TMA64_Ticks(unsigned ticks)
// {
//     g_tma64Ticks = 0;

//     while (g_tma64Ticks < ticks)
//     {
//         // SACM_DVR1800_ServiceLoop();
//         System_ServiceLoop();
//     }
// }