//=================================================================================================
// File Name	: TouchProbe_User.asm
// Description	: Touch Probe setting
// Written by	: Ray Cheng
// Last modified date:
//                2014/11/05
// Note: 
//=================================================================================================


//***************************************************************************************
// Header File Included Area
//***************************************************************************************
.include GPCE36_CE5.inc

//***************************************************************************************
// Constant Definition Area
//***************************************************************************************
.define	C_PadNumber					13            // Max. = 24

.define C_SPI_IOA_Port	0
.define C_SPI_IOB_Port	1
.define C_SPI_Port_Sel	C_SPI_IOB_Port			// Select SPI1 or SPI2, Multi-IO only for SPI1

.IF C_SPI_Port_Sel								// IOB Port
	.define PP_SPI_Dir 			P_IOB_Dir
	.define PP_SPI_Attrib 		P_IOB_Attrib
	.define PP_SPI_Buffer 		P_IOB_Buffer
	
	.define PP_SPI_Ctrl 		P_SPI2_Ctrl
	.define PP_SPI_TX_Status 	P_SPI2_TX_Status
	.define PP_SPI_TX_Data 		P_SPI2_TX_Data
	.define PP_SPI_RX_Status 	P_SPI2_RX_Status
	.define PP_SPI_RX_Data 		P_SPI2_RX_Data
	.define PP_SPI_Misc 		P_SPI2_Misc
.ELSE											// IOA Port
	.define PP_SPI_Dir 			P_IOA_Dir
	.define PP_SPI_Attrib 		P_IOA_Attrib
	.define PP_SPI_Buffer 		P_IOA_Buffer
	
	.define PP_SPI_Ctrl 		P_SPI_Ctrl
	.define PP_SPI_TX_Status 	P_SPI_TX_Status
	.define PP_SPI_TX_Data 		P_SPI_TX_Data
	.define PP_SPI_RX_Status 	P_SPI_RX_Status
	.define PP_SPI_RX_Data 		P_SPI_RX_Data
	.define PP_SPI_Misc 		P_SPI_Misc
.ENDIF

//.define C_SPI_SI_Bit	0x8000	// In 4I/O Mode, SIO0
//.define C_SPI_DO_Bit	0x4000	// In 4I/O Mode, SIO1
//.define C_SPI_SCK_Bit	0x2000
//.define C_SPI_CS_Bit	0x1000
//
//.define C_SPI_CS_IO		12		//IOB[12] as SPI CS pin Software Control

.define C_SPI_SI_Bit	0x0000	// 
.define C_SPI_DO_Bit	0x0080	// B7
.define C_SPI_SCK_Bit	0x0040  // B6
.define C_SPI_CS_Bit	0x0020  // B5

.define C_SPI_CS_IO		5		//IOB[5] as SPI CS pin Software Control


//for TP Library (Don't Modify)
//.define C_Delay_AfterCSLow		15	//unit:us
//.define C_Delay_BeforeCSHigh	5	//unit:us
//.define C_Delay_AfterCSHigh		15	//unit:us

.define C_Delay_AfterCSLow		50	//30	//unit:us
.define C_Delay_BeforeCSHigh	5	//1	//unit:us
.define C_Delay_AfterCSHigh		50	//25	//unit:us

//***************************************************************************************
// Variable Publication Area
//***************************************************************************************
.public R_TP_Buffer


//***************************************************************************************
// Table Publication Area
//***************************************************************************************
.public T_TPDelay


//***************************************************************************************
// Function Call Publication Area
//***************************************************************************************
.public F_TP_HW_Init				// Touch Probe Hardware Initial Function Call Back by Touch Prboe Library

.public F_TP_SendAByte
.public F_TP_SendAWord
.public F_TP_ReadAByte
.public F_TP_ReadAWord

.public F_TP_SetCSHigh
.public F_TP_SetCSLow

.public F_TP_Delay_1us

//***************************************************************************************
// External Function Definition Area
//***************************************************************************************
.external F_TP_ServiceLoop


//***************************************************************************************
// Table Definition Area (be used by Touch Library)
//***************************************************************************************
.code
T1_TPDelay:	//for TP Library (Don't Modify)
.DW C_Delay_AfterCSLow
.DW C_Delay_BeforeCSHigh
.DW C_Delay_AfterCSHigh


//***************************************************************************************
// RAM Definition Area
//***************************************************************************************
.RAM 
//R_TP_Buffer:		.dw 	C_PadNumber * 3 dup (?)	// For Touch Probe Used Only
R_TP_Buffer:		.dw 	C_PadNumber dup (?)	// For Touch Probe Used Only
T_TPDelay:			.dw		3 dup (?)

//***************************************************************************************
// CODE Definition Area
//***************************************************************************************
.CODE
//****************************************************************
// Function    : F_TP_HW_Init
// Description : Hardware initilazation for Touch Probe 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_TP_HW_Init:	.proc

//	call F_TP_SPI_Initial;
	push R1, R2 to [SP];
	R1 = C_Delay_AfterCSLow;
	[T_TPDelay] = R1;
	R1 = C_Delay_BeforeCSHigh;
	[T_TPDelay+1] = R1;
	R1 = C_Delay_AfterCSHigh;
	[T_TPDelay+2] = R1;
		
	R1 = [PP_SPI_Dir];
	R1 &= ~C_SPI_SI_Bit;
	R1 |= C_SPI_DO_Bit | C_SPI_SCK_Bit | C_SPI_CS_Bit;
	[PP_SPI_Dir] = R1;
	
	R1 = [PP_SPI_Attrib];
	R1 |= C_SPI_DO_Bit | C_SPI_SI_Bit | C_SPI_SCK_Bit | C_SPI_CS_Bit;
	[PP_SPI_Attrib] = R1;
	
	R1 = [PP_SPI_Buffer];
	R1 &= ~(C_SPI_DO_Bit | C_SPI_SI_Bit | C_SPI_SCK_Bit );
	R1 |= C_SPI_CS_Bit;
	[PP_SPI_Buffer] = R1;

//	R1 = C_SPI_Reset | C_SPI_CS_GPIO;
//	[PP_SPI_Ctrl] = R1;

//.IF C_SPI_Port_Sel			// IOB (SPI2)
//	R1 = C_SPI_Enable | C_MasterMode | C_SPI_CS_GPIO | C_SPI_SCK_FPLL_Div_128;
//	R1 |= C_SPI_LBM_Normal | C_SPI_Clock_Phase_Normal | C_SPI_Clock_Pol_Normal;	
//.ELSE						// IOA (SPI1)
//	R1 = C_SPI_Enable | C_MasterMode | C_SPI_CS_GPIO | C_SPI1_SCK_FPLL_Div_16;
//	R1 |= C_SPI_DTR_Disable | C_SPI_Auto_Disable | C_SPI_Clock_Phase_Normal | C_SPI_Clock_Pol_Normal;	
//.ENDIF
//	[PP_SPI_Ctrl] = R1;
//	
//	R1 = C_SPI_TX_INT_Flag | C_SPI_TX_INT_DIS | C_SPI_TX_FIFO_Level_0;
//	[PP_SPI_TX_Status] = R1;
//	
//	R1 = C_SPI_RX_INT_Flag | C_SPI_RX_INT_DIS | C_SPI_RX_FIFO_Level_1;
//	[PP_SPI_RX_Status] = R1;

	pop R1, R2 from [SP];

	retf; 
	.endp


//****************************************************************
// Function    : F_TP_SPI_SetCSHigh
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_TP_SPI_SetCSHigh:	.proc
	setb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SetCSHigh
// Description : 
// Destory     : 
// Parameter   : R1 : delay time (uS) after CS go LOW
// Return      : None
// Note        : None
//****************************************************************
F_TP_SetCSHigh:	.proc
	setb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	call F_TP_Delay_1us;						// delay R1 uS for touch probe process data
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SPI_SetCSLow
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_TP_SPI_SetCSLow:	.proc
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SetCSLow
// Description : 
// Destory     : 
// Parameter   : R1 : delay time (uS) after CS go LOW
// Return      : None
// Note        : None
//****************************************************************
F_TP_SetCSLow:	.proc
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	call F_TP_Delay_1us;						// delay R1 uS for touch probe process data
	retf;
	.endp


F_SPID_Write:	.proc   
 	push R2,R5 to [SP];	
	R2 = 07;
	R3 = [PP_SPI_Buffer];
L_SendLoop?:
	R3 &= ~(C_SPI_SCK_Bit+C_SPI_DO_Bit)		//SCK & MOSI = 0
	TSTB R1,R2;
	JZ	L_SDA_Send_Lo?
	R3 |= C_SPI_DO_Bit;
L_SDA_Send_Lo?:
    [PP_SPI_Buffer] = R3               //Data out & CLK = 0
    nop;
    nop;
    nop;
    nop;
    R3 |= C_SPI_SCK_Bit;
    [PP_SPI_Buffer] = R3              //CLK = 1
    R2 -= 1;

    JPL	L_SendLoop?
    R3 &= ~C_SPI_SCK_Bit              //CLK = 0
    [PP_SPI_Buffer] = R3 	
 	POP R2,R5 from [SP];
	retf;
	.endp
//****************************************************************
// Function    : F_TP_SPI_SendaByte
// Description : 
// Destory     : 
// Parameter   : R1 = SPI Data
// Return      : None
// Note        : None
//****************************************************************
F_TP_SPI_SendaByte:	.proc
//	[PP_SPI_TX_Data] = R1;
	call F_SPID_Write;
	nop;
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SPI_ReadaByte
// Description : 
// Destory     : 
// Parameter   : None
// Return      : R1 = SPI Data
// Note        : None
//****************************************************************
F_TP_SPI_ReadaByte:	.proc
//	R1 = [PP_SPI_RX_Data];
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SPI_CheckBusyFlag
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_TP_SPI_CheckBusyFlag:	.proc
?L_Check_TXIF:								// Wait until command and address have been sent out
//	R1 = [PP_SPI_Misc];	
//	test R1, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF
//
//	[PP_SPI_Misc] = R1;

	retf;
	.endp

//****************************************************************
// Function    : F_TP_Delay_1us
// Description : When CE4 Cache Eanble, delay about 1us
// Destory     : 
// Parameter   : R1 = Delay Count (Unit 1us) 
// Return      : None
// Note        : None
//****************************************************************
F_TP_Delay_1us: .proc
	push R1, R2 to [SP];
?L_Loop_0:
	R2 = 7;
?L_Loop_1:
	R2 -= 0x0001;
	jnz ?L_Loop_1
	R1 -= 1;
	jnz ?L_Loop_0
	pop R1, R2 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SendDataToTouchProbe
// Description : Send Data to Touch Probe
// Destory     : 
// Parameter   : R1 = Buffer Address, R2 = Data Length (bytes)
// Return      : R1 = new checksum
// Note        : None
//****************************************************************
.public  _TP_SendDataToTouchProbe
.public F_TP_SendDataToTouchProbe
 _TP_SendDataToTouchProbe:	.proc
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2]; 
F_TP_SendDataToTouchProbe:
	push R2, R5 to [sp];
	R3 = 0x0000;							// checksum

?L_SPI_SendData_Loop:
	R4 = [R1++];
	R5 = R4 & 0x00FF;						// get low byte data
//	[PP_SPI_TX_Data] = R5;					// send low byte data to SPI
	push R1 to [sp];
	R1 = R5;
	call F_SPID_Write;
	pop  R1 from [sp];
	R3 += R5;								// checksum
	R2 -= 1;
	jz ?L_OddByteData;
	
	R4 = R4 lsr 4;
	R4 = R4 lsr 4;							// get high byte data
	push R1 to [sp];
	R1 = R4;
	call F_SPID_Write;
	pop  R1 from [sp];
//	[PP_SPI_TX_Data] = R4;					// send high byte data to SPI
	R3 += R4;								// checksum
	nop;
	nop;

?L_Check_TXIF:								// Wait until command and address have been sent out
//	R4 = [PP_SPI_Misc];	
//	test R4, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF

//	[PP_SPI_Misc] = R4;

//	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO (Data Low Byte)
//	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO (Data High Byte)
//
	R2 -= 1;
	jnz ?L_SPI_SendData_Loop;
	jmp ?L_DataTxEnd;

?L_OddByteData:
//	R4 = [PP_SPI_Misc];	
//	test R4, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF

//	[PP_SPI_Misc] = R4;

//	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO (Data Low Byte)	
	
?L_DataTxEnd:
	R1 = R3;					// return checksum
	
	pop R2, R5 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_TP_SendAByte
// Description : 
// Destory     : 
// Parameter   : R1 = one byte data 
// Return      : None
// Note        : None
//****************************************************************
F_TP_SendAByte:	.proc
//	[PP_SPI_TX_Data] = R1;

	call F_SPID_Write;
	nop;
?L_Check_TXIF:								// Wait until command and address have been sent out
//	R1 = [PP_SPI_Misc];	
//	test R1, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF;

//	[PP_SPI_Misc] = R1;
//	R1 = [PP_SPI_RX_Data];

	retf;
	.endp

//****************************************************************
// Function    : F_TP_SendAWord
// Description : 
// Destory     : 
// Parameter   : R1 = one word data 
// Return      : None
// Note        : None
//****************************************************************
F_TP_SendAWord:	.proc
//	[PP_SPI_TX_Data] = R1;
	push R1 to [sp];
	call F_SPID_Write;
	pop  R1 from [sp];
	R1 = R1 lsr 4;
	R1 = R1 lsr 4;
//	[PP_SPI_TX_Data] = R1;
	call F_SPID_Write;
	nop;
	nop;
?L_Check_TXIF:								// Wait until command and address have been sent out
//	R1 = [PP_SPI_Misc];	
//	test R1, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF;

//	[PP_SPI_Misc] = R1;
//	R1 = [PP_SPI_RX_Data];
//	R1 = [PP_SPI_RX_Data];

	retf;
	.endp

//****************************************************************
// Function    : F_TP_ReadAByte
// Description : 
// Destory     : 
// Parameter   : None
// Return      : R1 = one byte data
// Note        : None
//****************************************************************
F_TP_ReadAByte:	.proc
	R1 = 0x0000;
//	[PP_SPI_TX_Data] = R1;
	nop;
?L_Check_TXIF:								// Wait until command and address have been sent out
//	R1 = [PP_SPI_Misc];	
//	test R1, C_SPI_Busy_Flag;
//	jnz ?L_Check_TXIF;
//
//	[PP_SPI_Misc] = R1;
//	R1 = [PP_SPI_RX_Data];
//
	retf;
	.endp

//****************************************************************
// Function    : F_TP_ReadAWord
// Description : 
// Destory     : 
// Parameter   : None
// Return      : R1 = one word data
// Note        : None
//****************************************************************
F_TP_ReadAWord:	.proc
	R1 = 0x0000;
//	[PP_SPI_TX_Data] = R1;
//	[PP_SPI_TX_Data] = R1;
//	nop;
//	nop;
//?L_Check_TXIF:								// Wait until command and address have been sent out
////	R1 = [PP_SPI_Misc];	
////	test R1, C_SPI_Busy_Flag;
////	jnz ?L_Check_TXIF;
////
////	[PP_SPI_Misc] = R1;
//	R1 = [PP_SPI_RX_Data];
//	R2 = [PP_SPI_RX_Data];
//	R2 = R2 lsl 4;
//	R2 = R2 lsl 4;
//	R1 |= R2;
	retf;
	.endp
