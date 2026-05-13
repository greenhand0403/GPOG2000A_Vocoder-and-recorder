//==========================================================================
// File Name   : SACM_VC4_USER.asm
// Description : Users implement functions
// Written by  : Ray Cheng
// Last modified date:
//              2005/12/26
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include GPCE36_CE5.inc
.include VC4.inc

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_VC4_Timer_Setting_X1		C_Timer_Setting_16K
.define C_VC4_Timer_Setting_X2		C_Timer_Setting_32K
.define C_VC4_Timer_Setting_X4		C_Timer_Setting_64K

.define C_SpeechNumberLength		4

//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_First_Frame

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_VC4_SetStartAddr
.public F_USER_VC4_SetStartAddr
.public  _USER_VC4_SetStartAddr_Con
.public F_USER_VC4_SetStartAddr_Con

.public F_USER_VC4_GetData
.public F_USER_VC4_WriteData
.public  _USER_VC4_Volume
.public F_USER_VC4_Volume

.public F_SACM_VC4_SendDAC1
.public F_SACM_VC4_SendDAC2
.public F_SACM_VC4_StartPlay
.public F_SACM_VC4_GetADC
.public F_SACM_VC4_EndPlay
.public F_SACM_VC4_EndRecord
.public F_SACM_VC4_Init_
.public F_SACM_VC4_DAC_Timer_X1
.public F_SACM_VC4_DAC_Timer_X2
.public F_SACM_VC4_ADC_Timer_X1
.public F_SACM_VC4_ADC_Timer_X2
.public F_SACM_VC4_ADC_Timer_X4
.public F_SACM_VC4_GetStartAddr_Con

.public F_SACM_VC4_EffectProcess

//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SPI_Flash_SendAWord
.external F_SPI_Flash_SendNWords
.external F_AutoModeReadAWords
.external F_AutoModeReadNWords

.external _VC4_ShiftPitchProcess
.external _VC4_ConstPitchProcess
.external _VC4_EchoProcess
.external F_RobotEffect1_Process 
.external F_RobotEffect2_Process 
.external F_StrangeTone_Process 
.external F_DJEffect_Process 
.external F_Vibration_Process 
.external F_JetPlaneEffect_Process 

.external R_VC4_ALG_Mode
.external R_SACM_VC4_Decode_In_PTR
.external R_SACM_VC4_DAC_Out_PTR_Decode
.external _VC4WorkRam
.external _Mode

//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_ExtMem_Low_Con
.var R_ExtMem_High_Con
.var R_First_Frame

//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.CODE
//
// Voice Changer Mode Table
//
T_VC4_MODE_DEFINE:
.dw L_VC4_SHIFT_PITCH_MODE
.dw L_VC4_CONST_PITCH_MODE
.dw L_VC4_ECHO_MODE
.dw L_VC4_ROBOTEFFECT1
.dw L_VC4_ROBOTEFFECT2
.dw L_VC4_STRANGETONE
.dw L_VC4_DJEFFECT
.dw L_VC4_VIBRATION
.dw L_VC4_JETPLANEEFFECT
.dw L_VC4_USER_DEFINE_MODE1


// Volume Table
T_SACM_VC4_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500

//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE
//****************************************************************
// Function    : F_SACM_VC4_Init_
// Description : Hardware initilazation for PCM, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_Init_:	.proc
	FIR_MOV OFF;
		
	R1 = [P_Timer_Ctrl]
	R1 |= C_TimerA_SYSCLK;		// TimerA CKA=Fosc/2 CKB=1 Tout:off
	[P_Timer_Ctrl] = R1;
	R1= C_Timer_Setting_16K;	// TimerA setting
	[P_TimerA_Data] = R1;
	[P_TimerA_CNTR] = R1;

	R1 = [P_AUDIO_Ctrl2];
	R1 |= C_AUD_CH1_Up_Sample_Enable | C_AUD_CH1_TMR_Sel_TimerA | C_AUD_CH1_Half_Vol_Enable;
	[P_AUDIO_Ctrl2] = R1;

//	R1 = C_AUDIO_PWMIP_Enable | C_AUDIO_PWM_Enable | C_AUDIO_Gain_Sel | C_MuteControl_DATACHAGE;
//	[P_AUDIO_Ctrl1] = R1;
//
//	R1 = C_PWM_sData;
//	[P_AUDIO_Ctrl3] = R1;

	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ0_TMA;
	[P_INT_Ctrl] = R1;

	R1 = [P_FIQ_Sel];
	R1 |= C_IRQ0_TMA;
	[P_FIQ_Sel] = R1;
	
	FIQ on;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_VC4_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//****************************************************************
 _USER_VC4_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_VC4_Volume:
	R2 = SEG16 T_SACM_VC4_Volume_Level
	R1 += OFFSET T_SACM_VC4_Volume_Level;		// loop up volume table
	R2 += 0, CARRY
	DS = R2
	R1 = D:[R1];	
	
	call F_SACM_VC4_Volume;
	retf
	.endp

//****************************************************************
// Function    : F_SACM_VC4_DAC_Timer_X1
// Description : Change timer setting for change DA filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC4_DAC_Timer_X1:	.proc
F_SACM_VC4_DAC_Timer_X1:
	R1 = C_VC4_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_DAC_Timer_X2
// Description : Set timer for PCM playback, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC4_DAC_Timer_X2:	.proc
F_SACM_VC4_DAC_Timer_X2:
	push R1 to [SP];
	R1 = C_VC4_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_ADC_Timer_X1
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC4_ADC_Timer_X1:	.proc
F_SACM_VC4_ADC_Timer_X1:
	R1 = C_VC4_Timer_Setting_X1;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_ADC_Timer_X2
// Description : Change timer setting for change AD filter, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC4_ADC_Timer_X2:	.proc
F_SACM_VC4_ADC_Timer_X2:
	R1 = C_VC4_Timer_Setting_X2;
	[P_TimerA_Data] = R1;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_ADC_Timer_X4
// Description : Set timer for PCM recording, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SACM_VC4_ADC_Timer_X4:	.proc
F_SACM_VC4_ADC_Timer_X4:
	push R1 to [SP];
	R1 = C_VC4_Timer_Setting_X4;
	[P_TimerA_Data] = R1;
	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_GetADC
// Description : Get ADC data for recording
// Destory     : R4
// Parameter   : None
// Return      : R4 = ADC data
// Note        : None
//****************************************************************
F_SACM_VC4_GetADC:	.proc
	R4 = [P_CMPADC_Data];
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_SendDAC1:	.proc
	[P_AUDIO_CH1_Data] = R4;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_SendDAC2:	.proc
	[P_AUDIO_CH2_Data] = R4;
	retf; 
	.endp
//****************************************************************
// Function    : F_SACM_DVR1800_StartPlay
// Description : This function called by library when Play function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_StartPlay:	.proc
//	R1 = [P_AUDIO_Ctrl1]
//	R1 |= C_AUDIO_PWM_Enable		
//	[P_AUDIO_Ctrl1] = R1;
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_EndPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_VC4_EndRecord
// Description : Call back from kernel when bit stream encoding is done 
// Destory     : R1, R2, R3
// Parameter   : R1: Low byte of file length
//               R2: High byte of File length
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_EndRecord: .proc
	push R2 to [SP];
	push R1 to [SP];
	R1 = 0;
	R2 = 0;
	pop R3 from [SP];
    call F_SPI_Flash_SendAWord
	R1 += 2;
	pop R3 from [SP];
	call F_SPI_Flash_SendAWord;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_VC4_SetStartAddr
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//****************************************************************
_USER_VC4_SetStartAddr:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_VC4_SetStartAddr:
//	R3 = [_Mode];
//	jz ?L_PlayPrerecordData;
//?L_PlayRecordedData:
//	[R_ExtMem_Low] = R1;
//	[R_ExtMem_High] = R2;
//	jmp ?L_SetAddr_End
//
//?L_PlayPrerecordData:
//	R1 = R1 lsl 2;
//	R1 += C_SpeechNumberLength;
//	push R1 to [SP];
//	R2 = 0x0000;	
//	call F_AutoModeReadAWords;
//	[R_ExtMem_Low] = R1;
//	pop R1 from [SP];
//	R1 += 2;
//	call F_AutoModeReadAWords;
//	[R_ExtMem_High] = R1;
//	
//?L_SetAddr_End:	
	retf;
	.endp
	
//****************************************************************
// Function    : F_USER_VC4_SetStartAddr_Con
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Low byte of start address
//               R2: High byte of start address
// Return      : None
// Note        : None
//****************************************************************
_USER_VC4_SetStartAddr_Con:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_VC4_SetStartAddr_Con:
	push R1, R3 to [SP];
//	R3 = [_Mode];
//	jz ?L_PlayPrerecordData;
//?L_PlayRecordedData:
//	[R_ExtMem_Low_Con] = R1;
//	[R_ExtMem_High_Con] = R2;
//	jmp ?L_SetAddr_End
//		
//?L_PlayPrerecordData:
//	R1 = R1 lsl 2;
//	R1 += C_SpeechNumberLength;
//	push R1 to [SP];
//	R2 = 0x0000;	
//	call F_AutoModeReadAWords;
//	[R_ExtMem_Low_Con] = R1;
//	pop R1 from [SP];
//	R1 += 2;	
//	call F_AutoModeReadAWords;
//	[R_ExtMem_High_Con] = R1;
?L_SetAddr_End:	
	pop R1, R3 from [SP];
	retf;
	.endp
	
//****************************************************************
// Function    : F_SACM_VC4_GetStartAddr_Con
// Description : 
// Destory     : None
// Parameter   : 
// Return      : None
// Note        : None
//****************************************************************
F_SACM_VC4_GetStartAddr_Con:	.proc
	R1 = [R_ExtMem_Low_Con];
	R2 = [R_ExtMem_High_Con];
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_VC4_GetData
// Description : Get speech data from internal or external memory
//               and fill these data to buffer of library.
// Destory     : None
// Parameter   : R1: decode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
F_USER_VC4_GetData:
//	R3 = [R_ExtMem_Low];
//	R4 = [R_ExtMem_High];
//	call F_AutoModeReadNWords
//	R3 += R2
//	R4 += 0, CARRY
//	[R_ExtMem_Low] = R3;
//	[R_ExtMem_High] = R4;	

	.external F_SACM_VC4_Stop
	.external R_SACM_A1800_fptr_DAC_Out_Buffer
	.external _SACM_A1800_fptr_ServiceLoop
	.external R_SACM_A1800_fptr_DAC_Out_PTR_Decode
	.external R_SACM_A1800_fptr_Play_Flag
	.define C_SACM_MIXER_DECODE_WORK_Num			8
	.define C_SACM_MIXER_DECODE_END_Num				10
	
	R3 = [R_First_Frame];
	jz ?L_Normal_Frame;
	R3 = R_SACM_A1800_fptr_DAC_Out_Buffer
	[R_SACM_A1800_fptr_DAC_Out_PTR_Decode] = R3
	R3 = 0xFFFF;
	[R1++] = R3;
	[R1++] = R3;									//File Length = 0xFFFF
	R2 -= 2;
	[R_First_Frame] = R1-R1;
?L_Normal_Frame:	
?L_A1800toVC4:
	R3 = [R_SACM_A1800_fptr_DAC_Out_PTR_Decode];
?L_MoveLoop:
	R4 = [R3++];
	[R1++] = R4;
	R2 -= 1;
	jnz ?L_MoveLoop;
	[R_SACM_A1800_fptr_DAC_Out_PTR_Decode] = R3;
	
	cmp R3, R_SACM_A1800_fptr_DAC_Out_Buffer + 320;	
	jb ?L_Exit;
?L_Decode:	
	R1 = R_SACM_A1800_fptr_DAC_Out_Buffer
	[R_SACM_A1800_fptr_DAC_Out_PTR_Decode] = R1
	setb [R_SACM_A1800_fptr_Play_Flag], C_SACM_MIXER_DECODE_WORK_Num
	call _SACM_A1800_fptr_ServiceLoop
	R1 = R_SACM_A1800_fptr_DAC_Out_Buffer
	[R_SACM_A1800_fptr_DAC_Out_PTR_Decode] = R1
	tstb [R_SACM_A1800_fptr_Play_Flag], C_SACM_MIXER_DECODE_END_Num
	je ?L_Exit;
	call F_SACM_VC4_Stop;
?L_Exit:
	retf;

//****************************************************************
// Function    : F_USER_VC4_WriteData
// Description : Get encoded speech data from buffer of library
//               and write to external memory.
// Destory     : None
// Parameter   : R1: encode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
F_USER_VC4_WriteData:
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_SPI_Flash_SendNWords;
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;

//****************************************************************
// Function    : F_SACM_VC4_EffectProcess
// Description : 
// Destory     : R1
// Parameter   :  
// Return      : None
// Note        : None
//****************************************************************    
_SACM_VC4_EffectProcess:    .proc
F_SACM_VC4_EffectProcess:
    R1 = T_VC4_MODE_DEFINE;
	R2 = [R_VC4_ALG_Mode];
	R1 += R2;
	R1 = [R1];
	PC = R1;
    
L_VC4_SHIFT_PITCH_MODE:      
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.	
	R3 = _VC4WorkRam;    	                     // VC4WorkRam address	
    push R1, R3 to [SP];
    call _VC4_ShiftPitchProcess;        
    pop R1, R3 from [SP];
    retf;

L_VC4_CONST_PITCH_MODE:
    R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	R3 = _VC4WorkRam;                            // VC4WorkRam address		
	push R1, R3 to [SP];
    call _VC4_ConstPitchProcess;
    pop R1, R3 from [SP];           
    retf;

L_VC4_ECHO_MODE:  
    R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	R3 = _VC4WorkRam;                            // VC4WorkRam address  	
	push R1, R3 to [SP];
    call _VC4_EchoProcess;
    pop R1, R3 from [SP];
    retf;
    
L_VC4_ROBOTEFFECT1:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_RobotEffect1_Process;
	pop R1, R3 from [SP];
	retf
	
L_VC4_ROBOTEFFECT2:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_RobotEffect2_Process;
	pop R1, R3 from [SP];
	retf
	
L_VC4_STRANGETONE:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_StrangeTone_Process;
	pop R1, R3 from [SP];
	retf
	
L_VC4_DJEFFECT:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_DJEffect_Process;
	pop R1, R3 from [SP];
	retf
	
L_VC4_VIBRATION:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_Vibration_Process;
	pop R1, R3 from [SP];
	retf			
	
L_VC4_JETPLANEEFFECT:
	R1 = [R_SACM_VC4_Decode_In_PTR];		 // InBuf addr.
	R2 = [R_SACM_VC4_DAC_Out_PTR_Decode];  		 // OutBuf addr.
	push R1, R3 to [SP];
	call F_JetPlaneEffect_Process;
	pop R1, R3 from [SP];
	retf	    
    
L_VC4_USER_DEFINE_MODE1:

    pop R1, R3 from [SP];
    retf;    
    .endp
