//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE36_CE5.inc

.define C_DebounceCnt			0x0080
.define C_SACM_RAMP_DELAY   	80
.define C_MuteCnt	80	// timer * Cnt
.define C_NormalCnt	20	// timer * Cnt




//**************************************************************************
// Contant Defintion Area
//**************************************************************************

//**************************************************************************
// External Variable Declaration
//**************************************************************************
.public  _System_Initial
.public F_System_Initial
.public  _SP_SwitchChannel
.public F_SP_SwitchChannel
.public  _WatchdogClear
.public F_WatchdogClear
.public  _System_ServiceLoop
.public F_System_ServiceLoop
.public  _SP_GetCh
.public F_SP_GetCh
.public  _SP_RampUpDAC1
.public F_SP_RampUpDAC1
.public  _SP_RampDnDAC1
.public F_SP_RampDnDAC1
.public  _SP_RampUpDAC2
.public F_SP_RampUpDAC2
.public  _SP_RampDnDAC2
.public F_SP_RampDnDAC2
.public F_SACM_Delay
.public  _GotoSleep
.public F_GotoSleep

.public  _Cache_Enable
.public F_Cache_Enable
.public  _Cache_Disable
.public F_Cache_Disable
.public  _AutoModeReadNWords
.public F_AutoModeReadNWords
.public  _AutoModeReadAWords
.public F_AutoModeReadAWords
.public  _Enable_IOA7_DigitalKey
.public F_Enable_IOA7_DigitalKey
.public  _Disable_IOA7_DigitalKey
.public F_Disable_IOA7_DigitalKey
//**************************************************************************
// External Function Declaration
//**************************************************************************
.external _PWMorCUR_Flg

//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_DebounceReg
.var R_DebounceCnt
.var R_KeyBuf
.var R_KeyStrobe
.var R_MuteCnt
.var R_AUDIO_CH1_Data_Pre
.var R_AUDIO_CH2_Data_Pre
.var R_IOA7_DigitalKeyEnable

//**************************************************************************
// CODE Definition Area
//**************************************************************************
.code
//****************************************************************
// Function    : F_System_Initial
// Description : System initial setting
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _System_Initial: .proc
F_System_Initial:
	int off;
	fir_mov off;
//	nop;	
	R1 = C_SYSCLK_81920KHz | C_Sleep_IOSC32K_SLP_Off | C_IOSC8192M_Trim_from_Fuse;
	[P_System_Clock] = R1;

	R1 = 0x0000;
	[P_IO_Ctrl] = R1;
	
	R1 = 0x0000;
	[P_INT_Ctrl] = R1;
	[P_INT2_Ctrl] = R1;
	[P_FIQ_Sel] = R1;
	[P_FIQ2_Sel] = R1;

	R1 = 0xffff;
	[P_INT_Status] = R1;
	[P_INT2_Status] = R1;

	R1 = C_TimeBase_Clear;
	[P_TimeBase_Clear] = R1;
	
	R1 = 0x0000;
	[P_IOA_Attrib] = R1;
	[P_IOA_Dir] = R1;
	R1 = 0x0000;
	[P_IOA_Buffer] = R1;
	
	R1 = 0x000F;            //Output low
	[P_IOB_Attrib] = R1;
	[P_IOB_Dir] = R1;
	R1 = 0x0000;
	[P_IOB_Buffer] = R1;

	R1 = 0x0000
	[R_IOA7_DigitalKeyEnable] = R1

	retf;
	.endp

//****************************************************************
// Function    : F_SP_SwitchChannel
// Description : 
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_SwitchChannel:	.proc
F_SP_SwitchChannel:

	retf;
	.endp
	
//****************************************************************
// Function    : F_WatchdogClear
// Description : Clear watchdog register
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
_WatchdogClear:	.proc
F_WatchdogClear:

	R1 = C_Watchdog_Clear;
	[P_Watchdog_Clear] = R1;

	retf;
	.endp
	
//****************************************************************
// Function    : F_SACM_Delay
// Description : Provide delay for Ramp up/down 
//               The delay time is adjustable by adjusting C_SACM_RAMP_DELAY
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_Delay: .proc
	push R2 to [SP]
	R2 = C_SACM_RAMP_DELAY; // Ramp Up/Dn delay per step
?_Loop_0:
	R2 -= 0x0001;
	jnz ?_Loop_0;
	pop R2 from [SP]
	retf;
	.endp

//****************************************************************
// Function    : F_System_ServiceLoop
// Description : Key scan and watchdog clear
// Destroy     : R1, R2
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _System_ServiceLoop: .proc
F_System_ServiceLoop:
	call F_Key_DebounceCnt_Down;		// debounce counter countdown
	call F_Key_Scan_ServiceLoop;		// key scan
	call F_WatchdogClear;				// clear watchdog register
	retf;
	.endp;
//****************************************************************
// Function    : F_Enable_IOA7_DigitalKey
// Description : Enable IOA7 digital key scan
// Destroy     : R1
//****************************************************************
_Enable_IOA7_DigitalKey: .proc
F_Enable_IOA7_DigitalKey:
    R1 = 0x0001
    [R_IOA7_DigitalKeyEnable] = R1

    // 清数字按键残留状态
    R1 = 0x0000
    [R_DebounceReg] = R1
    [R_DebounceCnt] = R1
    [R_KeyBuf] = R1
    [R_KeyStrobe] = R1

    retf
    .endp


//****************************************************************
// Function    : F_Disable_IOA7_DigitalKey
// Description : Disable IOA7 digital key scan
// Destroy     : R1
//****************************************************************
_Disable_IOA7_DigitalKey: .proc
F_Disable_IOA7_DigitalKey:
    R1 = 0x0000
    [R_IOA7_DigitalKeyEnable] = R1

    // 清数字按键残留状态
    [R_DebounceReg] = R1
    [R_DebounceCnt] = R1
    [R_KeyBuf] = R1
    [R_KeyStrobe] = R1

    retf
    .endp
//****************************************************************
// Function    : F_Key_DebounceCnt_Down
// Description : Debounce counter countdown
// Destroy     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_Key_DebounceCnt_Down:
	R1 = [R_DebounceCnt];
	jz	L_DebounceCntZero;
	R1 -= 0x0001;
	[R_DebounceCnt] = R1;
L_DebounceCntZero:
	retf;
	
//****************************************************************
// Function    : F_Key_Scan_ServiceLoop
// Description : Get Key code from key pad(8 x 1 key pad)
// Destory     : R1, R2
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_Key_Scan_ServiceLoop:	.proc
	R1 = [P_IOA_Data];				// get key data from IOA   
//	R1 = [P_IOB_Data];				// get key data from IOB

	//R1 &= 0x087F;					// 8Bits
	R1 &= 0xFFFF;					// 16Bits
	//R1 &= 0xFF7F; // 屏蔽 IOA7，IOA7 后面改用 ADC 判断，不再进入 SP_GetCh()
	R2 = [R_IOA7_DigitalKeyEnable]
	cmp R2, 0x0000
	jne ?L_IOA7_Digital_Enable

	// 禁用 IOA7 数字按键扫描，避免干扰 ADC 读取
	R1 &= 0x087F

	?L_IOA7_Digital_Enable:

	R2 = [R_DebounceReg];
	[R_DebounceReg] = R1;
	cmp R2, [R_DebounceReg];
	je ?L_KS_StableTwoSample;

	R1 = C_DebounceCnt;				// debounce counter reset
	[R_DebounceCnt] = R1;
	retf;

?L_KS_StableTwoSample:
	R1 = [R_DebounceCnt];
	jz ?L_KS_StableOverDebounce;
	retf;

?L_KS_StableOverDebounce:
	[R_DebounceCnt] = R1;
	R2 = [R_DebounceReg];
	R1 = [R_KeyBuf];
	[R_KeyBuf] = R2;
//	R1 ^= 0x00FF;
	R1 ^= 0xFFFF;
	R1 = R1 and [R_KeyBuf];
//	R1 &= 0x00FF;
	R1 &= 0xFFFF;
	R1 |= [R_KeyStrobe];
	[R_KeyStrobe] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SP_GetCh
// Description : Get Keycode
// Destory     : R1, R2
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_GetCh:	.proc
F_SP_GetCh:
	R1 = [R_KeyStrobe];				// Get Key code
	R2 = 0x0000;					// Clear KeyStrobe for next key
	[R_KeyStrobe] = R2;
	retf;
	.endp

//****************************************************************
// Function    : F_SP_RampDnDAC1
// Description : Ramp down after using DAC to avoid "bow" sound from speaker 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_RampDnDAC1: .proc
F_SP_RampDnDAC1:
	push R1, R2 to [SP];
	R1 = [P_AUDIO_CH1_Data];
	R1 &= 0xFFC0;
	cmp R1, 0x0000;
	je ?_Branch_0;
	test R1, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	call F_SACM_Delay;
	R1 -= 0x0040;
	[P_AUDIO_CH1_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_1;

	jmp ?_Branch_0;

?_Loop_0:
	call F_SACM_Delay;
	R1 += 0x0040;
	[P_AUDIO_CH1_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_0;

?_Branch_0:
	pop R1, R2 from [SP];
	retf;
	.endp

	
//****************************************************************
// Function    : F_SP_RampDnDAC2
// Description : Ramp down after using DAC to avoid "bow" sound from speaker 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_RampDnDAC2: .proc
F_SP_RampDnDAC2:
	push R1, R2 to [SP];
	R1 = [P_AUDIO_CH2_Data];
	R1 &= 0xFFC0;
	cmp R1, 0x0000;
	je ?_Branch_0;
	test R1, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	call F_SACM_Delay;
	R1 -= 0x0040;
	[P_AUDIO_CH2_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_1;

	jmp ?_Branch_0;

?_Loop_0:
	call F_SACM_Delay;
	R1 += 0x0040;
	[P_AUDIO_CH2_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_0;

?_Branch_0:
	pop R1, R2 from [SP];
	retf;
	.endp


//****************************************************************
// Function    : F_SP_RampUpDAC1
// Description : Ramp Up before using DAC to avoid "bow" sound from speaker 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_RampUpDAC1: .proc
F_SP_RampUpDAC1:
	push R1, R2 to [SP];

	R1 = [P_AUDIO_CH1_Data];
	R1 &= 0xFFC0;
	cmp R1, 0x0000;
	je ?_Branch_0;
	test R1, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	call F_SACM_Delay;
	R1 -= 0x0040;
	[P_AUDIO_CH1_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_1;

	jmp ?_Branch_0;

?_Loop_0:
	call F_SACM_Delay;
	R1 += 0x0040;
	[P_AUDIO_CH1_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_0;

?_Branch_0:
	pop R1, R2 from [SP];
	retf;
	.endp


//****************************************************************
// Function    : F_SP_RampUpDAC2
// Description : Ramp Up before using DAC to avoid "bow" sound from speaker 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SP_RampUpDAC2: .proc
F_SP_RampUpDAC2:
	push R1, R2 to [SP];

	R1 = [P_AUDIO_CH2_Data];
	R1 &= 0xFFC0;
	cmp R1, 0x0000;
	je ?_Branch_0;
	test R1, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	call F_SACM_Delay;
	R1 -= 0x0040;
	[P_AUDIO_CH2_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_1;
	jmp ?_Branch_0;

?_Loop_0:
	call F_SACM_Delay;
	R1 += 0x0040;
	[P_AUDIO_CH2_Data] = R1;
	cmp R1, 0x0000;
	jne ?_Loop_0;

?_Branch_0:
	pop R1, R2 from [SP];
	retf;
	.endp	

//****************************************************************
// Function    : F_USER_Set_Audio_OUT
// Description : Set audio output is PWM OUT or CUR OUT 
//               
// Destory     : R1,R2
// Parameter   : None
// Return      : R1    
// Note        : Function for GPCE100A
//****************************************************************
.public F_USER_Set_Audio_OUT
.public _USER_Set_Audio_OUT
 _USER_Set_Audio_OUT: .proc
F_USER_Set_Audio_OUT: 
///////// Judge AUDPWM or CUR 
	R1 = [_PWMorCUR_Flg];  //R1 0:CUR,1:PWM
	
	je L_CurrentDAC?	
	//// Setting AUDPWM
	R1 = C_AUDIO_PWMIP_Enable | C_AUDIO_PWM_Enable | C_AUDIO_Gain_Sel | C_MuteControl_DATACHAGE;
	[P_AUDIO_Ctrl1] = R1;

	R1 = C_PWM_sData;
	[P_AUDIO_Ctrl3] = R1;
	
	jmp L_Set_PWM_DAC_end?;		
	
L_CurrentDAC?:	
	//// Setting CUR
	//setb [P_IOB_Buffer], 8;  //Set DAC ����ʹ��IO�� IOB8����GPY0030 ����Ч
		
	R1 = C_AUDIO_PWMIP_Enable | C_AUDIO_PWM_Enable | C_AUDIO_Gain_Sel | C_MuteControl_DATACHAGE;
	[P_AUDIO_Ctrl1] = R1;
	
	R1 = C_PWM_sData | C_RDAC_Enable | C_PWM_Mute_50Duty | C_DRAC_Current;
	[P_AUDIO_Ctrl3] = R1;

L_Set_PWM_DAC_end?:	 // AUDPWM or CUR setting End	
/////////////////////////////////
	
	
	retf;
	.endp	
	

//****************************************************************
// Function    : _SPIFCHiDrivingCheck
// Description : 
// Destroy     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPIFCHiDrivingCheck:	.proc
F_SPIFCHiDrivingCheck:
	push R1, R2 to [SP]
	R1 = [P_Reset_LVD_Ctrl] 		//Backup user setting
	R1 &= C_LVD_Ctrl
	tstb [P_SPI_Auto_Setting], 15 
	je L_CheckEnable?
L_CheckDisable?:
	R2 = C_LVD_Ctrl_2D6V
	[P_Reset_LVD_Ctrl] = R2
	call L_DelayLoop
	tstb [P_Reset_LVD_Ctrl], 11	//check BVD flag	
	je L_ChangeSetting?
	jmp L_Exit?
L_CheckEnable?:	
	R2 = C_LVD_Ctrl_2D4V	
	[P_Reset_LVD_Ctrl] = R2
	call L_DelayLoop
	tstb [P_Reset_LVD_Ctrl], 11	//check BVD flag	
	je L_Exit?
L_ChangeSetting?:	
	invb [P_SPI_Auto_Setting], 15
L_Exit?:	
	[P_Reset_LVD_Ctrl] = R1
	call L_DelayLoop
	pop R1, R2 from [SP]
	retf
		
L_DelayLoop:
	R3 = 10
L_loop?:
	R3 -= 1
	jne L_loop?
	retf	
	
	.endp

//****************************************************************
// Function    : F_GotoSleep
// Description : Go to Sleep           
// Destroy     : None
// Parameter   : R1: 0 => Set RTC Off in Sleep mode 
//                   not zero => Set RTC On in Sleep mode ,Halt mode
// Return      : None
// Note        : None
//****************************************************************	
.CODE
 _GotoSleep: .proc
 	R1 = SP + 3
 	R1 = [R1]
F_GotoSleep:
	push R1, R4 to [SP] 

    cmp R1, 0;
    jz ?L_Set_RTC_Off_In_Sleep_Mode; 

?L_Set_RTC_On_In_Sleep_Mode:
	R1 = [P_System_Clock];             
	R1 |= C_Sleep_IOSC32K_SLP_Work;       // Set RTC Off in Sleep mode
	[P_System_Clock] = R1;
	jmp ?L_Disable_Interrupt;

?L_Set_RTC_Off_In_Sleep_Mode:
	R1 = [P_System_Clock];             
	R1 &= ~C_Sleep_IOSC32K_SLP_Work;       // Set RTC Off in Sleep mode
	[P_System_Clock] = R1;

?L_Disable_Interrupt:    
	INT OFF
	
   	R1 = 0
   	[P_SPI2_Ctrl] = R1;					  // Disable SPI2
   	
   	R1 = 0
	[P_IOA_Attrib] = R1;
	[P_IOA_Dir] = R1;	
	[P_IOA_Buffer] = R1;
	
	R1 = 0
	[P_IOB_Attrib] = R1;
	[P_IOB_Dir] = R1;
	[P_IOB_Buffer] = R1;

//	R1 = 0
//	[P_IOC_Attrib] = R1;
//	[P_IOC_Dir] = R1;
//	[P_IOC_Buffer] = R1;
    
	R1 = 0;
   	[P_CMPADC_Ctrl0] = R1;					
	[P_PGA_Ctrl] = R1;					// Disable ADC
	
	[P_UART_Ctrl] = R1;					//Disable UART
	[P_CTS_Ctrl0] = R1;					//Disable CTS
	
    call F_SP_RampDnDAC1;
    call F_SP_RampDnDAC2;
    
    R1 = [P_AUDIO_Ctrl1]
    R1 &= ~(C_AUDIO_PWMIP_Enable + C_AUDIO_PWM_Enable)
    [P_AUDIO_Ctrl1] = R1				//Disable PWM
	
	R1 = [P_AUDIO_Ctrl3];
	R1 &= ~C_RDAC_Enable;
	[P_AUDIO_Ctrl3] = R1;				//Disable RDAC
	
	R1 = 0;
	[P_SPU_Clock_Ctrl] = R1;
	[P_SPU_CH_Ctrl] = R1;
	
	call F_Cache_Disable
	R1 = 0x1000
	R2 = F_SleepCodeRAMEnd - F_SleepCodeRAMStr
	R3 = 0x0000
	R4 = 0x0001
	call F_AutoModeReadNWords
	call F_SleepCodeRAMStr
	call F_Cache_Enable
	// Wakeup
	nop;
	nop;
	nop;
	nop;
	R1 = C_SPU_Clock_Enable;
	[P_SPU_Clock_Ctrl] = R1;
	pop R1, R4 from [SP]
	retf
	.endp
SleepCode_RAMCode_SEC:		.section		.CODE 
F_SleepCodeRAMStr:	.proc		
	R1 = [P_SPI_Ctrl]
	R4 = R1
	R4 &= C_SPI_MultiIO_Sel 			  // Backup multi IO mode
	R1 &= ~(C_SPI_Auto_Enable + C_SPI_CS_SPI + C_SPI_MultiIO_Sel)
	R1 |= 0x0080;
	[P_SPI_Ctrl] = R1 					  // switch to manual mode
			
	clrb [P_SPI_Man_Ctrl], 1 				  // SPI1 CS Pin goes low
	R1 = 0xFF;							  // Exit SPI Enhance mode
	[P_SPI_TX_Data] = R1;	
	[P_SPI_TX_Data] = R1;				  
?L_Check_TXIF_1:					      // Wait untill command and address have been sent out
	R1 = [P_SPI_Misc];	
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_1;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_1;
	nop;
	R1 = [P_SPI_RX_Data];				  // Clear dummy data in RX FIFO
	R1 = [P_SPI_RX_Data];				  // Clear dummy data in RX FIFO
	setb [P_SPI_Man_Ctrl], 1				  // SPI1 CS Pin goes high
		
	clrb [P_SPI_Man_Ctrl], 1				  // SPI1 CS Pin goes low
	R1 = 0xB9;							  // Deep power down command
	[P_SPI_TX_Data] = R1;
?L_Check_TXIF_2:					      // Wait untill command and address have been sent out
	R1 = [P_SPI_Misc];	
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_2;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_2;
	nop;
	R1 = [P_SPI_RX_Data];				  // Clear dummy data in RX FIFO
	setb [P_SPI_Man_Ctrl], 1				  // SPI1 CS Pin goes high

//Disable SPI1 I/F
    R1 = [P_SPI_Ctrl]
   	R1 &= ~C_SPI_Enable;                  // Disable SPI
   	[P_SPI_Ctrl] = R1;	
  			
   	R1 = [P_IOA_Data];                    // Latch PortA
    R1 = [P_IOA_Attrib];                  // Latch PortA
    R1 = [P_IOB_Data];                    // Latch PortB
    R1 = [P_IOB_Attrib];                  // Latch PortB
    R1 = [P_IOC_Data];                    // Latch PortC
    R1 = [P_IOC_Attrib];                  // Latch PortC
	
	R1 = C_IRQ4_KEY;                      // enable IRQ4 as wakeup source
	[P_INT_Ctrl] = R1;
	R1 = 0x00;
	[P_INT2_Ctrl] = R1;
			
	R1 = 0xFF00;
	[P_IOA_WakeUp_Mask] = R1;			  
	R1 = 0xFFFF;
	[P_IOB_WakeUp_Mask] = R1;
	[P_IOC_WakeUp_Mask] = R1;
	
	nop;
	nop;
	
	R1 = 0xFFFF;	
	[P_INT_Status] = R1;
	[P_INT2_Status] = R1;	
          
    R1 = C_System_Sleep;
	[P_System_Sleep] = R1;               // go into sleep mode
	
	// Wakeup
	nop;
	nop;
	nop;
	nop;
	
	R1 = 0;                  
	[P_INT_Ctrl] = R1;	
	[P_INT2_Ctrl] = R1;	
	R1 = 0xFFFF;	
	[P_INT_Status] = R1;
	[P_INT2_Status] = R1;

	R1 = [P_SPI_Ctrl]
   	R1 |= (C_SPI_Enable + C_SPI_Reset);  // Enable SPI
   	[P_SPI_Ctrl] = R1;	
	
	clrb [P_SPI_Man_Ctrl], 1		   		 // SPI1 CS Pin goes low
	R1 = 0xAB;                           // Release deep power down command
	[P_SPI_TX_Data] = R1;
?L_Check_TXIF_Wakeup:					 // Wait untill command and address have been sent out
	R1 = [P_SPI_Misc];	
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_Wakeup;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_Wakeup;
	
	R1 = [P_SPI_RX_Data];		         // Clear dummy data in RX FIFO
	setb [P_SPI_Man_Ctrl], 1			     // SPI1 CS Pin goes high
	
	R1 = 4096;                           // delay ~200us
?_Loop_0:
	R1 -= 0x0001;
	jnz ?_Loop_0;	
											
	R1 = [P_SPI_Auto_Ctrl]
	R3 = 0
	[P_SPI_Auto_Ctrl] = R3
	R3 = [P_SPI_Ctrl]
	R3 |= (C_SPI_Auto_Enable + C_SPI_CS_SPI)
	R3 |= R4                            //R4 = Multi IO mode
	[P_SPI_Ctrl] = R3
	[P_SPI_Auto_Ctrl] = R1
	retf;
F_SleepCodeRAMEnd:	
	.endp
		
.CODE			
//****************************************************************
// Function    : F_Cache_Enable
// Description : Chche Enable
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Cache_Enable: .proc
F_Cache_Enable:

	call F_Cache_Disable 

	R1 = C_Cache_Clear;
	[P_Cache_Ctrl] = R1;

	NOP;
	NOP;
	NOP;
	NOP;
	NOP;
	
?L_WaitCacheClear:
	R1 =[P_Cache_Ctrl]
	R1 &= C_Cache_Clear
	jnz ?L_WaitCacheClear
	
	R1 = C_Cache_Enable;
	[P_Cache_Ctrl] = R1;
	
	retf;
	.endp;	
	
	
//****************************************************************
// Function    : F_Cache_Disable
// Description : Chche Enable
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Cache_Disable: .proc
F_Cache_Disable:
	R1 = C_Cache_Disable;
	[P_Cache_Ctrl] = R1;

	NOP;
	NOP;
	NOP;
	NOP;
	NOP;
	
	retf;
	.endp;	
	
	
//****************************************************************
// Function    : F_AutoModeReadAWords
// Description : Read a word data from via auto mode from flash
// Destory     : R1
// Parameter   : R1 = Address Low, R2 = Address High	
// Return      : R1 = one word of data read
// Note        : None
//****************************************************************
 _AutoModeReadAWords:	.proc	
 	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2]; 
F_AutoModeReadAWords:
	push R2, R4 to [SP]
	
	R3 = R2 lsr 4
	R4 = [P_SPI_Bank]	//Backup P_SPI_Bank
	[P_SPI_Bank] = R3
	
	R2 &= 0x0f;
	R2 += 0x30;					//Update High Address
	
	DS = R2
	R1 = D:[R1]
	
	pop R2, R4 from [SP]
	retf
	.endp	
	
	
//****************************************************************
// Function    : 
// Description :  
// Destory     : 
// Parameter   : 
// Return      : 
// Note        : 
//****************************************************************
 _AutoModeReadNWords:	.proc	
 	R4 = SP + 3;
    R1 = [R4++];							// buffer address
    R2 = [R4++];							// data length
    R3 = [R4++];							// external memory address low word
    R4 = [R4];								// external memory address high word
F_AutoModeReadNWords:
	push R1, R5 to [SP]

	R5 = [P_SPI_Bank]
	push R1 to [SP]
	R1 = R4 lsr 4
	[P_SPI_Bank] = R1
	R4 &= 0x0f;
	R4 += 0x30;					//Update High Address
	DS = R4
	pop R1 from [SP]
L_ReadDataLoop?:	
    R4 = D:[R3++]
    [R1++] = R4
    R2 -= 1
    jz L_ReadDataDone?
    cmp R3, 0x0000
    jne L_ReadDataLoop?
    R4 = DS
    R4 = R4
    jnz L_ReadDataLoop?
    R4 = [P_SPI_Bank]
    R4 += 1
    [P_SPI_Bank] = R4
    DS = 0x30
    jmp L_ReadDataLoop?
L_ReadDataDone?:    
	[P_SPI_Bank] = R5
	
	pop R1, R5 from [SP]
	retf
	.endp	
