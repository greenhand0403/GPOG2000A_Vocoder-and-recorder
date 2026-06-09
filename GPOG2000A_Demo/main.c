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
#define C_Volume_Control_Enable			0x01
#define C_Volume_Control_Disable		0x00
// 上拉按键时自动监听模式的状态定义
#define AUTO_IDLE           0   // 上拉模式，未启动自动监听
#define AUTO_WAIT_ATTACK    1   // 上拉模式，等待声音触发
#define AUTO_RECORDING      2   // 上拉模式，正在录音
#define AUTO_WAIT_REC_END   3   // 上拉模式，等待录音真正结束
#define AUTO_PLAYING        4   // 上拉模式，正在播放刚才录音
// IOA7 ADC 按键状态定义
#define ADC_KEY_NONE       0
#define ADC_KEY_HIGH_PRESS 1   // 上拉连接：按下约 2.7V
#define ADC_KEY_LOW_PRESS  2   // 下拉连接：按下约 0.5V
// 为ADC下拉按键自动录音并播放设计的四种状态
#define KEYDOWN_LOW_IDLE              0 // 未知上拉还是下拉 未按下任何按键 空闲
#define KEYDOWN_LOW_RECORDING     1   // 下拉模式，正在录音
#define KEYDOWN_LOW_PLAYING       2		// 下拉模式，正在播放刚才录音
#define KEYDOWN_HIGH_MODE    3  // 下拉模式切换为上拉模式，退出ADC按键模式，变成数字按键上拉按键
#define KEYDOWN_LOW_StartPlayRecorded    4  // 下拉模式，手动按键触发播放刚才录音
#define KEYDOWN_HIGH_WAIT_RELEASE 5  // 进入上拉模式，等待松开按键时才触发进入上拉高音调变调模式

#define KEYDOWN_REC_TIME (64*7)  // 下拉按键自动录音的固定持续时间

#define ADC_LOW_KEY_LONG_TICKS       64      // 下拉按键的长按约 1 秒
#define ADC_LOW_KEY_SHORT_MIN_TICKS  3       // 下拉按键小于这个认为是按键抖动

#define LOW_KEY_ACTION_NONE    0  // 下拉按键的空闲状态
#define LOW_KEY_ACTION_SHORT   1  // 下拉按键的短按状态
#define LOW_KEY_ACTION_LONG    2  // 下拉按键的长按状态
#define LOW_KEY_ACTION_BOUNCE  3  // 下拉按键的抖动状态
// 正常ADC值1104左右，上拉模式按下时变为2514，下拉模式按下时变为484
#define IOA7_ADC_LOW_PRESS_TH      800  // ADC按键按下时小于此值，认为处于下拉模式且按下
#define IOA7_ADC_HIGH_PRESS_TH     1800 // ADC按键按下时大于此值，认为处于上拉模式且按下

#define MAX_SOUND_EFFECT 3  // 3种有效的变声模式高音调 低音调 机器人音调
#define DI_SOUND_TIMEOUT_COUNT   60000UL  // 下拉按键自动录音的超时时间，单位：微秒
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
// 分离 ADC按键功能和数字按键功能
extern void Enable_IOA7_DigitalKey(void);
extern void Disable_IOA7_DigitalKey(void);

extern void USER_Set_Audio_OUT(void);
extern void CMPADC_IOA7Key_Init(void);  // 初始化 IOA7 ADC 按键功能
// 上拉模式自动监听式变声器相关状态处理函数
void Auto_PrepareRecord(void);
void Auto_StartRecord(void);
void Auto_StartPlayRecorded(void);
void Auto_StopWorkMode(void);
void CMPADC_Stop(void);

// ADC按键读取、扫描、处理相关函数
unsigned Read_IOA7_ADC_Raw(void);
unsigned Scan_IOA7_ADC_Key(void);
void Handle_IOA7_ADC_Key(void);

void Do_IOA7_LowPress_RecorderAction(void);  // 下拉模式，长按 ADC 按键触发自动开启录音

void Update_ADC_LowKey_Action(unsigned adcKey);  // 下拉按键用于判断长按还是短按

extern unsigned DVR18_ExtMem_Low;  // 录音存储的地址低位
extern unsigned DVR18_ExtMem_High;  // 录音存储的地址高位
extern unsigned R_ADCKeyRaw;  // 测试，下拉按键的 ADC 值

//**************************************************************************
// Global Variable Defintion Area
//**************************************************************************

struct	VC4WorkingRamStruct VC4WorkRam __attribute__((section("OVERLAP_VC4_RAM: .section .ORAM")));

int VC_Mode;
int ShiftPitchIdx;
int ConstPitchIdx;
int EchoGainIdx;
int ADC_FIR_Type;
int DAC_FIR_Type;
// unsigned A1800_Idx = 0;
unsigned long Block_Addr = 0; 
int chk_MIC_voice_flag = 0;  // TODO: 测试，判断需要检测麦克风输入
unsigned Temp;
unsigned Key;  // SP_GetCh 返回的数字按键的值

// C_PGA_29dB
unsigned EnvDet_AttackLevel = 0x0600;  //音量增大门槛值0610 0600
unsigned EnvDet_AttackTime = 64;   //音量增大到门槛值后持续时间15 64
unsigned EnvDet_ReleaseLevel = 0x0300; //音量减小门槛值0300
unsigned EnvDet_ReleaseTime = 2500;  //音量减小到门槛值后持续时间2500 640

unsigned PWMorCUR_Flg = 0; // 0:CUR DACOut ,1:PWM Out

unsigned R_REC_block = 6;   // 16M Max31;  32M Max63; 64M  Max127    //0x38000 ///29 =>>  0xF0000
unsigned char EffectMode = 0;   // 0:高音 1:低音 2:机器人
// 测试，上拉模式，记录麦克风检测大声时自动触发录音、静音时自动触发播放
volatile unsigned Dbg_AttackCount;
volatile unsigned Dbg_ReleaseCount;
unsigned AutoState = AUTO_IDLE;  // 上拉模式，自动监听式变声器需要的状态变量
unsigned LastAttackCount = 0;
unsigned LastReleaseCount = 0;
// 上拉模式：按第1次先进入工作模式，默认是高音调模式；按第2次，还是在工作模式，但是切换低音调；按第3次，还是在工作模式，但是机器人音效；按第4次还是播放一次滴声，然后退出工作模式
unsigned char KeyCount = 0;
// 上拉按键 1表示忙，正在处理
volatile unsigned char KeyBusy = 0;
// 上拉模式 1表示忙，正在做录音准备，0表示空闲，处于前面三种变声自动监听状态，需要去处理状态机逻辑
volatile unsigned char AutoBusy = 0;
// TODO: 仅供测试使用，查看按键 AD 值
volatile unsigned Dbg_IOA7_ADC_Raw = 0;
volatile unsigned Dbg_IOA7_ADC_Key = ADC_KEY_NONE;
// 上一次 ADC 按键状态
unsigned Last_IOA7_ADC_Key = ADC_KEY_NONE;
// 下拉模式，ADC 按键状态变量
unsigned keydown_rec = KEYDOWN_LOW_IDLE;
// 定时器时间变量，用于记录下拉自动录音时长，达到固定时间后，自动停止录音
volatile unsigned g_tmaDiv = 0;
volatile unsigned g_tma64Ticks = 0;

// void Wait_TMA64_Ticks(unsigned ticks);
// 下拉按键抖动相关状态变量
volatile unsigned LowKey_State = 0;          // 0=未按下, 1=按住中
volatile unsigned LowKey_DownTick = 0;       // 按下时刻
volatile unsigned LowKey_LastHoldTicks = 0;  // 最近一次按住时长
volatile unsigned LowKey_Action = LOW_KEY_ACTION_NONE;  // 下拉 ADC 按键最终要执行的操作
volatile unsigned UpdateADCLongPressFlag = 0;  // 下拉 ADC 按键模式，标记是否需要进入长按判断逻辑
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
	// TODO: 移除冗余代码，上拉按键需要的音量检测
	// AutoState = AUTO_IDLE;
	// LastAttackCount = 0;
	// LastReleaseCount = 0;
	// 开机后禁用数字 IO ，进入 IOA7 ADC 按键检测模式
	Disable_IOA7_DigitalKey();
	CMPADC_IOA7Key_Init();
	// 测试代码，开机进入上拉按键模式
	// keydown_rec = KEYDOWN_HIGH_MODE;
	while(1)
	{
		if (keydown_rec == KEYDOWN_LOW_IDLE)
		{
		   	Handle_IOA7_ADC_Key();
		}
		else if (keydown_rec == KEYDOWN_HIGH_MODE)
		{
			Handle_Key();
		}
		else if (keydown_rec == KEYDOWN_HIGH_WAIT_RELEASE)
		{
			Handle_HighWaitRelease();
		}

		// 变声器服务更新
		SACM_VC4_ServiceLoop();
		// 录音服务更新
		SACM_DVR1800_ServiceLoop();
		
		// 下拉按键模式的长按录音、短按播放的状态机
		if(keydown_rec == KEYDOWN_LOW_RECORDING)
		{
			// 下拉模式长按会进入正在录音状态，录满时间后自动停止
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
			// 下拉模式短按会进入准备播放录音状态
			keydown_rec = KEYDOWN_LOW_PLAYING;
			// 初始化播放录音设置
			CMPADC_Stop();
			SACM_A1800_fptr_Initial();                 // A1800 initial
			USER_A1800_fptr_Volume(9);
			A1800_fptr_Event_Initial();	
			A1800_fptr_IO_Event_Enable();
			// VolCompressInitial();// 作用未知？注释掉也不影响
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
			// SACM_VC4_Volume_Control(C_Volume_Control_Enable); // 这个代码也作用不明
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
		else if (keydown_rec == KEYDOWN_HIGH_MODE) // 上拉按键模式，自动监听式变声器
		{
			// 上拉按键模式的音量检测状态机
			if (AutoState != AUTO_IDLE)
			{
				// 如果不是忙状态，说明前面录音准备做好了，现在处理自动监听变声的状态机
				if (!AutoBusy)
				{
					Auto_StateMachine();
				}
			}
		}

		// 系统看门狗更新、按键更新等
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

    // A1800_Idx = 0;
    USER_A1800_fptr_SetStartAddr(0);
    SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);

    SACM_VC4_Initial();
	// 很奇怪这两句话的作用是什么？注释掉的话，可以播放滴声，但是无法自动监听并回播录音了
    SACM_VC4_AD_FIRType(ADC_FIR_Type);
    SACM_VC4_DA_FIRType(DAC_FIR_Type);
	// SACM_VC4_Volume_Control(C_Volume_Control_Enable);
    SACM_VC4_Volume(65535);

    VC_Mode = VC4_SHIFT_PITCH_MODE;
    SACM_VC4_Mode(VC_Mode, &VC4WorkRam);
    SACM_VC4_Play(Manual_Mode_Index, DAC1, Ramp_Up + Ramp_Dn);
	// TODO: 等待滴声播放完？好像不是必要代码？
    while ((SACM_VC4_Status() & 0x01) != 0)
    {
        SACM_VC4_ServiceLoop();
        // SACM_DVR1800_ServiceLoop(); // TODO: 播放滴声，就不需要dvr1800的状态更新？
        System_ServiceLoop();
		
        if (--timeout == 0)
        {
            SACM_VC4_Stop();
            SACM_A1800_fptr_Stop();
            break;
        }
    }
}
// 开启麦克风检测音量功能，注意，与 ADC 按键互斥
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
    SPI_Flash_Block_Erase(R_REC_block + 0);// 变声器使用 block 6
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
	// TODO: 停止麦克风音量检测功能
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
    USER_DVR1800_SetStartAddr(0x4, R_REC_block + 0);// skip 4 Bytes for length header 变声器使用 block 6
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

    Block_Addr = ((R_REC_block + 0) * 65536)/2;// 变声器使用 block 6
	Block_Addr = Block_Addr + 0x8000;
	DVR18_ExtMem_Low = Block_Addr & 0xffff;
	DVR18_ExtMem_High = Block_Addr >> 16;

	SACM_A1800_fptr_Play(Manual_Mode_Index, DAC1, 0);
	
	SACM_VC4_Initial();			// VC4 initial
	SACM_VC4_AD_FIRType(ADC_FIR_Type);  // TODO: 自动监听式变声播放也需要这个配置？不然没法播放
	SACM_VC4_DA_FIRType(DAC_FIR_Type);
	// SACM_VC4_Volume_Control(C_Volume_Control_Enable);
	SACM_VC4_Volume(65535);// 最大声

	switch(EffectMode)
	{
		case 0:     // 高音调
			VC_Mode = VC4_SHIFT_PITCH_MODE;
			ShiftPitchIdx = 8;
			break;
		case 1:     // 低音调
			VC_Mode = VC4_SHIFT_PITCH_MODE;
			ShiftPitchIdx = -2;
			break;
		case 2:     // 机器人音调
			VC_Mode = VC4_RobotEffect2;
			ShiftPitchIdx = 0;
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
// 首次按下时，判断用户是上拉还是下拉的硬件连接方式
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
	// 正常开机不动时ADC值在1100左右
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
		// 下拉按键按住时记录标志位
        if (LowKey_State == 0)
        {
            LowKey_State = 1;
            LowKey_DownTick = now;
        }
    }
    else if (adcKey == ADC_KEY_NONE)
    {
		// 下拉按键前面按住的话，再松开时，计算中间间隔的时间，判断是长按还是短按
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
// 上拉模式，检测到按下则切换为数字 IO 模式；下拉模式，按下则处理 IOA7 ADC 按键的长按和短按判断逻辑
void Handle_IOA7_ADC_Key(void)
{
    unsigned adcKey;

	if (keydown_rec != KEYDOWN_LOW_IDLE)
		return;

    // 如果是上拉按键模式的音量检测状态机，则不使用ADC按键功能，避免和 EnvDet / 自动录音 / 自动播放抢 CMPADC
    if (AutoState != AUTO_IDLE)
        return;

    // if (KeyBusy || AutoBusy)
    //     return;

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
			// 放这里？
		}
		Last_IOA7_ADC_Key = adcKey;// TODO: 下拉长按的这句话是不是应该放在括号里面？
		return;
	}
	// 用户首次按下 ADC 按键的情况
    if ((Last_IOA7_ADC_Key == ADC_KEY_NONE) && (adcKey != ADC_KEY_NONE))
    {
		// 判断如果是下拉连接方式，则需要给个标志位，再次判断是长按还是短按
        if (adcKey == ADC_KEY_LOW_PRESS)
        {
			if (UpdateADCLongPressFlag == 0)
			{
				UpdateADCLongPressFlag = 1;
			}
        }
		// 如果是上拉连接方式，则直接进入等待用户松手模式才会进入高音调模式同时退出ADC按键功能模式
		else if (adcKey == ADC_KEY_HIGH_PRESS)
		{
			// 无中间状态的情况。此时是永久退出 IOA7 ADC 按键模式，将 CMPADC 交给麦克风静音检测使用
			// keydown_rec = KEYDOWN_HIGH_MODE;

			// KeyBusy = 1;

			// PlayDiSound();

			// EffectMode = KeyCount;
			
			// if (KeyCount < MAX_SOUND_EFFECT)
			// {
			// 	KeyCount++;

			// 	AutoState = AUTO_IDLE;
			// 	Auto_PrepareRecord();
			// 	AutoState = AUTO_WAIT_ATTACK;
			// }
			// // 这个分支为什么会影响上拉按键首次进入高音调模式？
			// else
			// {
			// 	PlayDiSound();
			// 	KeyCount = 0;
			// 	Auto_StopWorkMode();
			// }

			// KeyBusy = 0;

			// 新增一个中间状态，避免上拉按键模式时用户长按跳到低音调模式
			keydown_rec = KEYDOWN_HIGH_WAIT_RELEASE;
	
			LowKey_State = 0;
			LowKey_Action = LOW_KEY_ACTION_NONE;
			UpdateADCLongPressFlag = 0;
			Last_IOA7_ADC_Key = adcKey;

			return;
		}
		
    }
	Last_IOA7_ADC_Key = adcKey;
}
// 前面在ADC按键模式检测到上拉连接，且按下，则需要等用户释放按键后，才进入高音调变声模式
void Handle_HighWaitRelease(void)
{
    unsigned adcKey;

	if (KeyBusy || AutoBusy)
		return;

    adcKey = Scan_IOA7_ADC_Key();

    if (adcKey == ADC_KEY_NONE)
    {
        // 松手确认
        Last_IOA7_ADC_Key = ADC_KEY_NONE;

		KeyBusy = 1;

        // 切换为数字 IOA7 模式
		Enable_IOA7_DigitalKey();

        // 进入上拉数字按键模式
        keydown_rec = KEYDOWN_HIGH_MODE;

        // 第一次松手后，正式进入高音模式
        PlayDiSound();

        EffectMode = KeyCount;

        if (KeyCount < MAX_SOUND_EFFECT)
        {
            KeyCount++;

            AutoState = AUTO_IDLE;

            // 清旧的 attack/release 计数，避免吃旧状态
            Dbg_AttackCount = 0;
            Dbg_ReleaseCount = 0;
            LastAttackCount = 0;
            LastReleaseCount = 0;

            Auto_PrepareRecord();
            AutoState = AUTO_WAIT_ATTACK;
        }
        // else
        // {
        //     PlayDiSound();
        //     KeyCount = 0;
        //     Auto_StopWorkMode();
        // }

        KeyBusy = 0;
    }
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