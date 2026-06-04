//==========================================================================
// File Name   : SACM_A1800_USER.asm
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
.include A1800_fptr.inc
.include Resource.inc


//**************************************************************************
// Table Publication Area
//**************************************************************************
.public D_A1800_fptr_IO_EVENT_NUM 
.public D_A1800_fptr_SW_PWM_LEVEL
.public T_A1800_fptr_IO_Event

//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SACM_Delay
.external F_AutoModeReadNWords
.external F_AutoModeReadAWords


//***************************************************************************************
// User Definition Section for IO Event
//***************************************************************************************
.define C_IO_EVENT_NUM    	  0                      // IO number for IO_Event.
.define C_SW_PWM_FREQ         60                     // PWM frequency (Unit: Hz)
.define C_SW_PWM_LEVEL        128                    // PWM level selection (32/64/128/256)
.define C_PWM_FREQ            65536 - (SystemClock / (C_SW_PWM_FREQ * C_SW_PWM_LEVEL))      // for PWM Service Timer Setting

//.text 
.CODE
//
// IO Event Definition
// - Mapped to the number of Edit Event on G+ Eventor
//
T_A1800_fptr_IO_Event:
.DD    C_IOB8
.DD    C_IOB9
.DD    C_IOB10
.DD    C_IOB11
.DD    C_IOB12
.DD    C_IOB13
.DD    C_IOB14
.DD    C_IOB15

.DD    C_IOA4
.DD    C_IOA5
.DD    C_IOA6
.DD    C_IOA7
.DD    C_IOA8
.DD    C_IOA9
.DD    C_IOA10
.DD    C_IOA11
.DD    C_IOA12
.DD    C_IOA13
.DD    C_IOA14
.DD    C_IOA15


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_SpeechNumberLength		    2    // for skip song number, count by word
.define C_SpeechDataOffsetLow			0x0000
.define C_SpeechDataOffsetHigh			0x0021

.define C_ROM_Table						1
.define C_FilerMerger_Version1			0
.define C_SPEECH_Source_Type			C_ROM_Table     ////C_FilerMerger_Version1    //C_ROM_Table    //

//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_SACM_A1800_fptr_DAC_Out_Buffer
.public R_A1800_fptr_DutyArray
.public _DVR18_ExtMem_Low
.public _DVR18_ExtMem_High
.public R_A1800_Data

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_A1800_fptr_SetStartAddr
.public F_USER_A1800_fptr_SetStartAddr
.public  _USER_A1800_fptr_SetStartAddr_Con
.public F_USER_A1800_fptr_SetStartAddr_Con
.public F_USER_A1800_fptr_GetData
.public  _USER_A1800_fptr_Volume
.public F_USER_A1800_fptr_Volume
.public F_SACM_A1800_fptr_SendDAC1
.public F_SACM_A1800_fptr_SendDAC2
.public F_SACM_A1800_fptr_StartPlay
.public F_SACM_A1800_fptr_EndPlay
.public F_SACM_A1800_fptr_Init_
.public F_SACM_A1800_fptr_GetStartAddr_Con
.public F_A1800_fptr_Event_Init_
.public F_A1800_fptr_GetExtStartAddr
.public F_A1800_fptr_USER_GetEvtData
.public F_A1800_fptr_USER_IoEvtStart
.public F_A1800_fptr_USER_IoEvtEnd
.public F_A1800_fptr_USER_IoEvtProcess
.public F_A1800_fptr_USER_EvtProcess
.public F_A1800_fptr_USER_RampUpDAC1
.public F_A1800_fptr_USER_RampUpDAC2
.public F_A1800_fptr_USER_RampDnDAC1
.public F_A1800_fptr_USER_RampDnDAC2

//**************************************************************************
// External Function Declaration
//**************************************************************************


//**************************************************************************
// External Table Declaration
//**************************************************************************
.external T_SACM_A1800_fptr_SpeechTable;
.if C_SPEECH_Source_Type == C_FilerMerger_Version1
	.external _RES_FILEMERGER_ROM_BIN_SA;
.endif	
//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_ExtMem_Low_Con
.var R_ExtMem_High_Con
.var R_A1800_Data

.define _DVR18_ExtMem_Low	R_ExtMem_Low
.define _DVR18_ExtMem_High	R_ExtMem_High

R_A1800_fptr_DutyArray:    .dw    C_IO_EVENT_NUM    dup(?)  


//OVERLAP_A18_DACOUT_RAM_BLOCK:	.section	.ORAM
//R_SACM_A1800_fptr_DAC_Out_Buffer:
//.dw C_A18_DECODE_OUT_LENGTH dup(?)

OVERLAP_A18_DACOUT_RAM_BLOCK:	.section	.ORAM
R_SACM_A1800_fptr_DAC_Out_Buffer:
.dw 2 * C_A18_DECODE_OUT_LENGTH dup(?)


//*****************************************************************************
// Table Definition Area
//*****************************************************************************
//.TEXT
.CODE
// Volume Table
T_SACM_A1800_fptr_Volume_Level:
.dw 0x0000, 0x0250, 0x0500, 0x1000
.dw	0x1500, 0x2000, 0x2500, 0x3000
.dw 0x3500, 0x4000, 0x5000, 0x6500
.dw	0x7d00, 0x9c00, 0xc400, 0xf500

D_A1800_fptr_IO_EVENT_NUM:
.DW C_IO_EVENT_NUM

D_A1800_fptr_SW_PWM_LEVEL:
.DW C_SW_PWM_LEVEL


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE
//****************************************************************
// Function    : F_SACM_A1800_fptr_Init_
// Description : Hardware initilazation for A1800, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_Init_:	.proc

	FIR_MOV OFF;
	
	R1 = C_Timer_Setting_16K;	
	[P_TimerA_Data] = R1;

	R1 = [P_Timer_Ctrl]
	R1 |= C_TimerA_SYSCLK;				
	[P_Timer_Ctrl] = R1;
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
// Function    : F_USER_A1800_fptr_Volume
// Description : Set speech volume
// Destory     : R1
// Parameter   : R1: volume index
// Return      : None
// Note        : None
//****************************************************************
 _USER_A1800_fptr_Volume: .proc
	R1 = SP + 3;
	R1 = [R1];								// volume index
F_USER_A1800_fptr_Volume:
	R2 = SEG16 T_SACM_A1800_fptr_Volume_Level
	R1 += OFFSET T_SACM_A1800_fptr_Volume_Level;		// loop up volume table
	R2 += 0, CARRY
	DS = R2
	R1 = D:[R1];
	call F_SACM_A1800_fptr_Volume;
	retf
	.endp


//****************************************************************
// Function    : F_SACM_A1800_fptr_SendDAC1
// Description : Send data to DAC1, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_SendDAC1:	.proc
	//[P_AUDIO_CH1_Data] = R4;	
	[R_A1800_Data] = R4;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_A1800_fptr_SendDAC2
// Description : Send data to DAC2, called by library
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_SendDAC2:	.proc
    [P_AUDIO_CH2_Data] = R4;
	retf; 
	.endp

//****************************************************************
// Function    : F_SACM_A1800_fptr_StartPlay
// Description : This function called by library when Play function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_StartPlay:	.proc
	R1 = 0x8000
	[R_SACM_A1800_fptr_DAC_Out_Buffer + 1] = R1
	
	.external R_First_Frame
	R1 = 0x01;
	[R_First_Frame] = R1;
//	R1 = [P_AUDIO_Ctrl1]
//	R1 |= C_AUDIO_PWM_Enable		
//	[P_AUDIO_Ctrl1] = R1;		
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_A1800_fptr_EndPlay
// Description : This function called by library when speech play end
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_EndPlay:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_A1800_fptr_SetStartAddr
// Description : This API allows users to set the beginning address
//               to fetch data. This address can be either a ROM address
//               or a external storage address. User would have to modify
//               the function body based on the application's need.
// Destory     : None
// Parameter   : R1: Speech index
// Return      : None
// Note        : None
//****************************************************************
_USER_A1800_fptr_SetStartAddr:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_A1800_fptr_SetStartAddr:
.if C_SPEECH_Source_Type == C_ROM_Table	
	R1 += R1
	R2 = SEG16 T_SACM_A1800_fptr_SpeechTable
	R3 = OFFSET T_SACM_A1800_fptr_SpeechTable
	R3 += R1
	R2 += 0, CARRY
	DS = R2
	R4 = D:[R3++]
	[R_ExtMem_Low] = R4
	R4 = D:[R3]
	[R_ExtMem_High] = R4
.endif	
.if C_SPEECH_Source_Type == C_FilerMerger_Version1
	DS = SEG _RES_FILEMERGER_ROM_BIN_SA;
	R4 = OFFSET _RES_FILEMERGER_ROM_BIN_SA;
	R3 = D:[R4++];
	R4 = D:[R4];
	R2 = R4;
    R1 = R1 lsl 2;
	R1 += 0x4;
	R1 = R1 lsr 1;
	
	R1 += R3;
	R2 += 0,Carry;
	DS = R2;

	R2 = R1;
	R1 = D:[R2++];
				
	R2 = D:[R2];
	R2 = R2 LSR 1;
	R4 += R2;	

    R2 = R2 LSR 3;
    R1 = R1 ROR 1;
	R3 += R1;
	R4 +=0,Carry
	[R_ExtMem_Low] = R3
	[R_ExtMem_High] = R4
.endif	    		
	
	retf;	
	.endp

//****************************************************************
// Function    : F_USER_A1800_fptr_SetStartAddr_Con
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
_USER_A1800_fptr_SetStartAddr_Con:	.proc
	R1 = SP + 3;
	R1 = [R1];

F_USER_A1800_fptr_SetStartAddr_Con:
.if C_SPEECH_Source_Type == C_ROM_Table
	R1 += R1
	R2 = SEG16 T_SACM_A1800_fptr_SpeechTable
	R3 = OFFSET T_SACM_A1800_fptr_SpeechTable
	R3 += R1
	R2 += 0, CARRY
	DS = R2
	R4 = D:[R3++]
	[R_ExtMem_Low_Con] = R4
	R4 = D:[R3]
	[R_ExtMem_High_Con] = R4
.endif	
.if C_SPEECH_Source_Type==C_FilerMerger_Version1
	DS = SEG _RES_FILEMERGER_ROM_BIN_SA;
	R4 = OFFSET _RES_FILEMERGER_ROM_BIN_SA;
	R3 = D:[R4++];
	R4 = D:[R4];
	R2 = R4;
    R1 = R1 lsl 2;
	R1 += 0x4;
	R1 = R1 lsr 1;
	
	R1 += R3;
	R2 += 0,Carry;
	DS = R2;

	R2 = R1;
	R1 = D:[R2++];
				
	R2 = D:[R2];
	R2 = R2 LSR 1;
	R4 += R2;	

    R2 = R2 LSR 3;
    R1 = R1 ROR 1;
	R3 += R1;
	R4 +=0,Carry
	[R_ExtMem_Low_Con] = R3
	[R_ExtMem_High_Con] = R4
.endif
	
	retf;
	.endp	

//****************************************************************
// Function    : F_SACM_A1800_fptr_GetStartAddr_Con
// Description : 
// Destory     : None
// Parameter   : 
// Return      : None
// Note        : None
//****************************************************************
F_SACM_A1800_fptr_GetStartAddr_Con:	.proc
	R1 = [R_ExtMem_Low_Con];
	R2 = [R_ExtMem_High_Con];
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp

//****************************************************************
// Function    : F_USER_A1800_fptr_GetData
// Description : Get speech data from internal or external memory
//               and fill these data to buffer of library.
// Destory     : None
// Parameter   : R1: decode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
F_USER_A1800_fptr_GetData:	.proc
    R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	call F_AutoModeReadNWords
	R3 += R2
	R4 += 0, CARRY
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;	
	.endp

//*****************************************************************************
// Function    : F_Event_CH2_Init_
// Description : None
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//***************************************************************************** 
F_A1800_fptr_Event_Init_:    .proc
	push R1, BP to [sp];

	//
	// Initialize S/W PWM IO as output low
	// 	
	R1 = 0;  
	DS = SEG T_A1800_fptr_IO_Event
	R2 = OFFSET T_A1800_fptr_IO_Event; 	
?L_IOSettingLoop:   
	R3 = D:[R2++];
	R5 = D:[R2++];  
	R4 = [R5 + C_PORT_DIR_IDX];
	setb R4, R3;
	[R5 + C_PORT_DIR_IDX] = R4; 
	R4 = [R5 + C_PORT_ATT_IDX];
	setb R4, R3;     
	[R5 + C_PORT_ATT_IDX] = R4;   
	R4 = [R5 + C_PORT_BUF_IDX];
	clrb R4, R3;
	[R5 + C_PORT_BUF_IDX] = R4;  	
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 
	
	//
	// Initialize TimerC and enable IRQ2_TimerC interrupt
	//
	R1 = [P_Timer_Ctrl];
	R1 |= C_TimerC_SYSCLK;
	[P_Timer_Ctrl] = R1;
	R1 = C_PWM_FREQ;
	[P_TimerC_Data] = R1;
	[P_TimerC_CNTR] = R1;  
	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ2_TMC;
	[P_INT_Ctrl] = R1;  
	IRQ ON;  

?L_Event_Init_End:
	pop R1, BP from [sp];
	retf
	.endp

//*****************************************************************************
// Function    : F_A1800_fptr_GetExtStartAddr
// Description : In the manual mode, library call this function to get 
//               external speech start address.
// Destory     : None
// Parameter   :
// Return      : R1 = Low ward of sound data addr  (byte mode address)
//               R2 = High ward of sound data addr (byte mode address)
// Note        : None
//*****************************************************************************
F_A1800_fptr_GetExtStartAddr:	.proc	
    R1 = [R_ExtMem_Low];	
	R2 = [R_ExtMem_High];	
	R1 += R1
	R2 += R2, CARRY
	retf;	
	.endp

//*****************************************************************************
// Function    : F_USER_GetEvtData_CH2
// Description : In the manual mode, library call this function to get 
//               external event data. 
// Destory     : None
// Parameter   : R1 = Low ward of the event data addr  (byte mode address)  
//               R2 = High ward of the event data addr (byte mode address)  
// Return      : R1 = Event Data
// Note        : None
//*****************************************************************************
F_A1800_fptr_USER_GetEvtData:	.proc
    //call F_AutoModeReadAWords
    R2 = R2 lsr 1
	R3 = R3 lsr 3
	R1 = R1 ror 1    
	R3 = R3 rol 1
	DS = R2
    tstb R3, 0
    jne L_Odd?
L_Even?:
	R1 = D:[R1]
    retf
L_Odd?:
	R2 = D:[R1++]
	R1 = D:[R1]
	R1 = R1 lsl 4  
	R1 = R1 lsl 4
	R2 = R2 lsr 4 
	R2 = R2 lsr 4 
	R1 |= R2
    retf;	
	.endp

//*****************************************************************************
// Function    : F_USER_IoEvtStart_CH2
// Description : This function will be called by library when IO event start.
//               The state of IO pins can be set by user 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************    
F_A1800_fptr_USER_IoEvtStart:    .proc 
	push R1, BP to [sp];
	
	//
	// Set S/W PWM IO as output low
	//	
	R1 = 0;  
	DS = SEG T_A1800_fptr_IO_Event
	R2 = OFFSET T_A1800_fptr_IO_Event;  
?L_IOSettingLoop:   
	R3 = D:[R2++];
	R5 = D:[R2++];
	R4 = R5 + C_PORT_BUF_IDX
	clrb [R4], R3;   
	//R4 = R5 + C_PORT_DIR_IDX
	//setb [R4], R3;
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 

	pop R1, BP from [sp];
	retf
	.endp

//*****************************************************************************
// Function    : F_USER_IoEvtEnd_CH2
// Description : This function will be called by library when IO event ends.
//               The state of IO pins can be set by user 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//*****************************************************************************    
F_A1800_fptr_USER_IoEvtEnd:    .proc 
	push R1, BP to [sp];
	
	//
	// Set S/W PWM IO as output low
	//	
	R1 = 0;  
	DS = SEG T_A1800_fptr_IO_Event
	R2 = OFFSET T_A1800_fptr_IO_Event
?L_IOSettingLoop:   
	R3 = D:[R2++];
	R5 = D:[R2++];
	R4 = R5 + C_PORT_BUF_IDX
	clrb [R4], R3; 
	//R4 = R5 + C_PORT_DIR_IDX
	//setb [R4], R3; 
	R1 += 1;
	cmp R1, C_IO_EVENT_NUM;
	jb ?L_IOSettingLoop 

	pop R1, BP from [sp];
	retf
	.endp
	
//*****************************************************************************
// Function    : F_USER_IoEvtProcess_CH2
// Description : This function will be called by library when IO event process.
//               The state of IO pins can be set by user 
// Destory     : 
// Parameter   : R1: IO Index
//				 R2: Duty
// Return      : None
// Note        : None
//*****************************************************************************    	
F_A1800_fptr_USER_IoEvtProcess:	.proc

	retf
	.endp	
	
//*****************************************************************************
// Function    : F_USER_EvtProcess_CH2
// Description : When a user event is decoded, F_USER_EvtProcess_CH2 will be executed.
//               User can process the user event in this function.
// Destory     : 
// Parameter   : R1 = SubIndex(8-bits):MainIndex(8-bits) 
// Return      : None
// Note        : None
//*****************************************************************************
F_A1800_fptr_USER_EvtProcess:    .proc  
	
	retf
	.endp

//*****************************************************************************
// Function    : F_A1800_fptr_USER_RampUpDAC1
// Description : 
// Destory     : 
// Parameter   : 
// Return      : 
// Note        : 
//*****************************************************************************			
F_A1800_fptr_USER_RampUpDAC1:	.proc
	R4 = [P_AUDIO_CH1_Data];
	R4 &= 0xFFC0;
	cmp R4, 0x0000;
	je ?_Branch_0;
	test R4, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	R4 -= 0x0040;
	[P_AUDIO_CH1_Data] = R4;
	jmp ?_Branch_0;
?_Loop_0:
	R4 += 0x0040;
	[P_AUDIO_CH1_Data] = R4;
?_Branch_0:
	retf
	.endp	
	
//*****************************************************************************
// Function    : F_A1800_fptr_USER_RampUpDAC2
// Description : 
// Destory     : 
// Parameter   : 
// Return      : 
// Note        : 
//*****************************************************************************			
F_A1800_fptr_USER_RampUpDAC2:	.proc
	R4 = [P_AUDIO_CH2_Data];
	R4 &= 0xFFC0;
	cmp R4, 0x0000;
	je ?_Branch_0;
	test R4, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	R4 -= 0x0040;
	[P_AUDIO_CH2_Data] = R4;
	jmp ?_Branch_0;
?_Loop_0:
	R4 += 0x0040;
	[P_AUDIO_CH2_Data] = R4;
?_Branch_0:
	retf
	.endp		
	
//*****************************************************************************
// Function    : F_A1800_fptr_USER_RampDnDAC1
// Description : 
// Destory     : 
// Parameter   : 
// Return      : 
// Note        : 
//*****************************************************************************			
F_A1800_fptr_USER_RampDnDAC1:	.proc
	R4 = [P_AUDIO_CH1_Data];
	R4 &= 0xFFC0;
	cmp R4, 0x0000;
	je ?_Branch_0;
	test R4, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	R4 -= 0x0040;
	[P_AUDIO_CH1_Data] = R4;
	jmp ?_Branch_0;
?_Loop_0:
	R4 += 0x0040;
	[P_AUDIO_CH1_Data] = R4;
?_Branch_0:
	retf
	.endp	
	
//*****************************************************************************
// Function    : F_A1800_fptr_USER_RampDnDAC2
// Description : 
// Destory     : 
// Parameter   : 
// Return      : 
// Note        : 
//*****************************************************************************			
F_A1800_fptr_USER_RampDnDAC2:	.proc
	R4 = [P_AUDIO_CH2_Data];
	R4 &= 0xFFC0;
	cmp R4, 0x0000;
	je ?_Branch_0;
	test R4, 0x8000;
	jnz ?_Loop_0;

?_Loop_1:
	R4 -= 0x0040;
	[P_AUDIO_CH2_Data] = R4;
	jmp ?_Branch_0;
?_Loop_0:
	R4 += 0x0040;
	[P_AUDIO_CH2_Data] = R4;
?_Branch_0:
	retf
	.endp		

