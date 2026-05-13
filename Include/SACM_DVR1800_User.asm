//==========================================================================
// File Name   : SACM_DVR1800_USER.asm
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
.include DVR1800.inc


//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define C_SpeechNumberLength			4	// for skip song number

//.define C_REC_block          14  //29 // 16M Max31  32M Max63 
//**************************************************************************
// Variable Publication Area
//**************************************************************************


//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _USER_DVR1800_SetStartAddr
.public F_USER_DVR1800_SetStartAddr
.public F_USER_DVR1800_WriteData
.public F_SACM_DVR1800_GetADC
.public F_SACM_DVR1800_StartRecord
.public F_SACM_DVR1800_EndRecord
.public F_SACM_DVR1800_Init_
.public F_ISR_Service_SACM_DVR1800
.public F_ISR_Service_SACM_DVR1800_RAM
.public F_DVR1800_SwitchINTtoRAM
.public F_DVR1800_SwitchINTtoEXT


//**************************************************************************
// External Variable Declaration
//**************************************************************************
.external _R_REC_block

//**************************************************************************
// External Function Declaration
//**************************************************************************
.external F_SPI_Flash_SendAWord
.external F_SPI_Flash_SendNWords


//**************************************************************************
// External Table Declaration
//**************************************************************************


//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ExtMem_Low
.var R_ExtMem_High
.var R_BackUpINTAddr
.var R_BackUpINTAddr_1

//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.CODE


//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE
//****************************************************************
// Function    : F_SACM_DVR1800_Init_
// Description : Hardware initilazation for DVR1800, called by library
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVR1800_Init_:	.proc
	FIR_MOV OFF;		
	// TimerA setting
	R1 = [P_Timer_Ctrl]
	R1 |= C_TimerA_SYSCLK;				// TimerA CKA=Fosc/2 CKB=1 Tout:off
	[P_Timer_Ctrl] = R1;
	R1= C_Timer_Setting_16K;		// TimerA setting
	[P_TimerA_Data] = R1;
	[P_TimerA_CNTR] = R1;

//	[P_AUDIO_Ctrl2] = R1 - R1;
//	[P_AUDIO_Ctrl1] = R1 - R1;
	
	call F_MoveDVR18ISRServiceToRAM
	
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
// Function    : F_SACM_DVR1800_StartRecord
// Description : This function called by library when Record function is callled
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVR1800_StartRecord:	.proc
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_SACM_DVR1800_EndRecord
// Description : Call back from kernel when bit stream encoding is done 
// Destory     : R1, R2, R3
// Parameter   : R1: Low byte of file length
//               R2: High byte of File length
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVR1800_EndRecord: .proc
	push R2 to [SP];
	push R1 to [SP];
	R1 = 0;
	//R2 = 0x20;
	//R2 = C_REC_block;
	R2 = [_R_REC_block];
	call F_DVR1800_SwitchINTtoRAM
	pop R3 from [SP];
	call F_SPI_Flash_SendAWord;
	R1 += 2;
	pop R3 from [SP];
	call F_SPI_Flash_SendAWord;
	call F_DVR1800_SwitchINTtoEXT
	
	R1 = [P_INT_Ctrl]
    R1 &= ~C_IRQ3_ADC;
	[P_INT_Ctrl] = R1;
	retf;
	.endp


//****************************************************************
// Function    : F_USER_DVDVR1800_SetStartAddr
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
 _USER_DVR1800_SetStartAddr:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2];
F_USER_DVR1800_SetStartAddr:
	[R_ExtMem_Low] = R1;
	[R_ExtMem_High] = R2;
	retf;
	.endp


//****************************************************************
// Function    : F_USER_DVR1800_WriteData
// Description : Get encoded speech data from buffer of library
//               and write to external memory.
// Destory     : None
// Parameter   : R1: encode buffer address of library
//               R2: data length
// Return      : None
// Note        : None
//****************************************************************
F_USER_DVR1800_WriteData:	.proc
	R3 = [R_ExtMem_Low];
	R4 = [R_ExtMem_High];
	
	call F_DVR1800_SwitchINTtoRAM
	call F_SPI_Flash_SendNWords;
	call F_DVR1800_SwitchINTtoEXT
	
	R3 += R2 lsl 1;
	R4 += 0, carry;
	[R_ExtMem_Low] = R3;
	[R_ExtMem_High] = R4;
	retf;
	.endp
	
//****************************************************************
// Function    : 
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
.external F_CMPADC_INT
F_DVR1800_SwitchINTtoRAM:	.proc
	push R1 to [SP]
	INT OFF
	nop
	nop
	nop
	nop
	R1 = [0x6]
	[R_BackUpINTAddr] = R1
	R1 = [0xB]
	[R_BackUpINTAddr_1] = R1
	R1 = F_DVR1800_INT
	[0x6] = R1 
	R1 = F_CMPADC_INT
	[0xB] = R1
	nop
	nop
	nop
	nop
	INT FIQ,IRQ
	pop R1 from [SP]
	retf
	.endp	
	
	
//****************************************************************
// Function    : 
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_DVR1800_SwitchINTtoEXT:	.proc
	push R1 to [SP]
	INT OFF
	nop
	nop
	nop
	nop
	
	R1 = [R_BackUpINTAddr]
	[0x6] = R1
	R1 = [R_BackUpINTAddr_1]
	[0xB] = R1
	nop
	nop
	nop
	nop

	INT FIQ,IRQ
	pop R1 from [SP]
	retf
	.endp		
	
	
//****************************************************************
// Function    : 
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _MoveDVR18ISRServiceToRAM:	.proc
F_MoveDVR18ISRServiceToRAM:	
	push R1, R4 to [SP]
	R1 = 0x0770
	R2 = L_RAMCodeEnd - L_RAMCodeStr
	R3 = 0x0001
	R4 = 0x2600
	
	DS = R3
L_MoveCodeLoop?:	
	R3 = D:[R4++]
	[R1++] = R3
	R2 -= 1
	jne L_MoveCodeLoop?
	pop R1, R4 from [SP]
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
.define C_SACM_DVR1800_DECODE_WORK_Num			8
.define C_SACM_DVR1800_DECODE_END_Num			10
.define C_SACM_DVR1800_REC_Mon_ON_Num			11	
.define C_SACM_DVR1800_FIQ_SOUND_Num			12
.define	C_SACM_DVR1800_FIQ_EVEN_Num				13
.define C_SACM_DVR1800_STOP_Num					14
.define C_ENCODE_IN_LENGTH						320
.external R_SACM_DVR1800_Play_Flag
.external R_SACM_DVR1800_ADC_In_PTR_Rec
.external R_SACM_DVR1800_ADC_In_Buffer
.external F_ISR_Service_CMPADC_TMR
.CODE	
F_ISR_Service_SACM_DVR1800:
	tstb [R_SACM_DVR1800_Play_Flag], C_SACM_DVR1800_FIQ_SOUND_Num;	// check recording continue
	je ?L_Exit
	call F_ISR_Service_CMPADC_TMR
	call F_ISR_Service_SACM_DVR1800_RAM
?L_Exit:	
	retf

DVR1800_ISR_RAMCode_SEC:		.section		.CODE 

L_RAMCodeStr:
F_DVR1800_INT:	.proc	
	push R1, R5 to [SP]
	call F_ISR_Service_CMPADC_TMR
	call F_ISR_Service_SACM_DVR1800_RAM

	R1 = C_IRQ0_TMA;
	[P_INT_Status] = R1;
	pop R1, R5 from [SP]
	reti

F_ISR_Service_SACM_DVR1800_RAM:
	push R1,R5 to [SP];
	
	tstb [R_SACM_DVR1800_Play_Flag], C_SACM_DVR1800_FIQ_SOUND_Num;	// check recording continue
	je ?L_FIQ_Encode_End

?L_Branch_0:								
	
	call F_SACM_DVR1800_GetADC;				// get data from ADC
	R4 ^= 0x8000;							// change to signed data
	R1 = R_SACM_DVR1800_Play_Flag
	tstb [R1], C_SACM_DVR1800_REC_Mon_ON_Num 	//test R1, C_SACM_DVDVR1800_REC_Mon_ON;		// check monitor on
	jz ?L_REC_NoMon;
	call F_SACM_DVR1800_SendDAC1;				// send ADC data to DAC1
	call F_SACM_DVR1800_SendDAC2;				// send ADC data to DAC2
?L_REC_NoMon:	
	R4 -= R4 asr 3;
	//R4 -= R4 asr 2;
	//R4 -= R4 asr 1;					

?L_WriteDataToBuffer:
	R2 = [R_SACM_DVR1800_ADC_In_PTR_Rec];
	[R2++] = R4;							// write PCM data to ADC_In buffer

	R3 = R_SACM_DVR1800_ADC_In_Buffer + C_ENCODE_IN_LENGTH;
	R4 = R3;								// ADC_In buffer 1 start address
	tstb [R1], C_SACM_DVR1800_FIQ_EVEN_Num 	//test R1, C_SACM_DVR1800_FIQ_EVEN;		// check ADC_In buffer 0/1
	jnz ?L_CheckPointerEnd;
	R3 += C_ENCODE_IN_LENGTH;				// buffer 1 end address, EVEN = '0'
	R4 -= C_ENCODE_IN_LENGTH;				// buffer 0 start
?L_CheckPointerEnd:
	cmp R2, R3;								// check if ADC_In buffer pointer point to buffer end
	je ?L_Switch_DAC_Out_Buffer;
	[R_SACM_DVR1800_ADC_In_PTR_Rec] = R2;		// ADC_In buffer pointer does not point to buffer end
	jmp ?L_FIQ_Encode_End;

?L_Switch_DAC_Out_Buffer:					// switch ADC_In buffer
	tstb [R1], C_SACM_DVR1800_DECODE_END_Num	//test R1, C_SACM_DVR1800_DECODE_END;		// check encode end
	jnz ?L_Record_End;
	setb [R1], C_SACM_DVR1800_DECODE_WORK_Num	//R1 |= C_SACM_DVR1800_DECODE_WORK;		// encode does not finish, set DECODE_WORK flag
	invb [R1], C_SACM_DVR1800_FIQ_EVEN_Num 	//R1 ^= C_SACM_DVR1800_FIQ_EVEN;			// change ADC_In buffer
	[R_SACM_DVR1800_ADC_In_PTR_Rec] = R4;		// update ADC_In buffer pointer
	jmp ?L_FIQ_Encode_End;

?L_Record_End:								// encoding finish
	setb [R1], C_SACM_DVR1800_STOP_Num		//call F_SACM_DVR1800_Stop;				// stop
?L_FIQ_Encode_End:
	
	pop R1,R5 from [SP];
	retf;
	.endp

	
//****************************************************************
// Function    : F_SACM_DVR1800_GetADC
// Description : Get ADC data for recording
// Destory     : R4
// Parameter   : None
// Return      : R4 = ADC data
// Note        : None
//****************************************************************
.external R_ADCValue
F_SACM_DVR1800_GetADC:	.proc
	R4 = [R_ADCValue];	
	R4 ^= 0x8000;	
	retf;
	.endp
	

//****************************************************************
// Function    : F_SACM_DVR1800_SendDAC1
// Description : Send data to DAC1, called by F_ISR_Service_SACM_DVR1800
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVR1800_SendDAC1:	.proc
	[P_AUDIO_CH1_Data] = R4;
	retf;
	.endp


//****************************************************************
// Function    : F_SACM_DVR1800_SendDAC2
// Description : Send data to DAC2, called by F_ISR_Service_SACM_DVR1800
// Destory     : None
// Parameter   : R4: 16-bit signed PCM data
// Return      : None
// Note        : None
//****************************************************************
F_SACM_DVR1800_SendDAC2:	.proc
	[P_AUDIO_CH2_Data] = R4;
	retf; 
	.endp	

L_RAMCodeEnd:
