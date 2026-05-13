//==========================================================================
// File Name   : SPI_Flash.asm
// Description : SPI initilaization and send/read data to/from SPI interface
// Programmer : Benjamin Xu
// Last modified date: 20200212
// Version: 1.0.5.4
// Note: 
//      1. IOA15:DO/SIO0, IOA14:DI/SIO1, IOA13:SCK,   IOA12:CS, IOA11:WRB/SIO2, IOA10:HOLDB/SIO3
//      2. IOB15:DO,      IOB14:DI,      IOA13:SCK,   IOA12:CS
//		
// Notice:
// (a) Needs pull high resistance on WRB & HOLDB pin when using EN25Qxxx series, XM25QH64A and XM25QH128A
// (b) How to add a new SPI flash 
//     1. Add REMS in table "T_SPIFlash_REMS".
//     2. Combine command "RDSR2" & "RDSR3" then add in table "T_SPIFlash_REMS"
//     3. Combine command "WRSR2" & "RRSR3" then add in table "T_SPIFlash_REMS"
//     4. Add QE bit information in table "T_SPIFlash_REMS"
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
.include 	GPCE36_CE5.inc

//**************************************************************************
// Contant Defintion Area (do not modified)
//**************************************************************************
.define C_SPI_IOC_Port	0
.define C_SPI_IOB_Port	1


//**************************************************************************
// User Defintion Area
//**************************************************************************
.define C_SPI_Port_Sel	C_SPI_IOC_Port			// Select SPI1 or SPI2, Multi-IO only for SPI1
.define C_SPI_4byteMode	0
.define C_FarPointer 	1

//**************************************************************************
// Contant Defintion Area (do not modified)
//**************************************************************************
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
	.define PP_SPI_Dir 			P_IOC_Dir
	.define PP_SPI_Attrib 		P_IOC_Attrib
	.define PP_SPI_Buffer 		P_IOC_Buffer
	
	.define PP_SPI_Ctrl 		P_SPI_Ctrl
	.define PP_SPI_TX_Status 	P_SPI_TX_Status
	.define PP_SPI_TX_Data 		P_SPI_TX_Data
	.define PP_SPI_RX_Status 	P_SPI_RX_Status
	.define PP_SPI_RX_Data 		P_SPI_RX_Data
	.define PP_SPI_Misc 		P_SPI_Misc
.ENDIF

.define 	C_SPI_MOSI_Bit		0x0010	// In 4I/O Mode, SIO0
.define 	C_SPI_MISO_Bit		0x0040	// In 4I/O Mode, SIO1
.define 	C_SPI_SCK_Bit		0x0008
.define 	C_SPI_CS_Bit		0x0020
.define 	C_SPI_WRB_Bit		0x0080	// In 4I/O Mode, SIO2
.define 	C_SPI_HOLDB_Bit		0x0004	// In 4I/O Mode, SIO3

.define 	C_SPI_CS_IO			5		// IOC[5] as SPI CS pin Software Control	

.define C_SPI1_1IO_Mode			0
.define C_SPI1_2IO_Mode			1
.define C_SPI1_4IO_Mode			2

//----------- Flash Operation Command Definition -------
.define C_SPI_Flash_Read_CMD		0x03
.define C_SPI_Flash_Block_Erase		0xD8
.define C_SPI_Flash_Sector_Erase	0x20
.define C_SPI_Flash_Chip_Erase		0xC7
.define C_SPI_Flash_Page_Program	0x02
.define C_SPI_Flash_Read_Status		0x05
.define C_SPI_Flash_Write_Status	0x01
.define C_SPI_Flash_Write_Enable	0x06
.define C_SPI_Flash_Write_Disable	0x04
.define C_SPI_Flash_Read_ID			0x9F
.define C_SPI_Flash_Read_REMS		0x90
.define C_SPI_Flash_Fast_Read		0x0B
.define C_SPI_Flash_Power_Down		0xB9
.define C_SPI_Flash_Release_DP		0xAB
.define C_SPI_Flash_Enter_4K		0xA5
.define C_SPI_Flash_Exit_4K			0xB5
.define C_SPI_Flash_Read_ES			0xAB
.define C_SPI_Flash_Read_EMS		0x90
.define C_SPI_Flash_Parallel_Mode	0x55
.define C_SPI_Flash_EN4B_Mode		0xB7
.define C_SPI_Flash_EX4B_Mode		0xE9
.define C_SPI_Flash_Configuration	0x15
.define C_SPI_Flash_Read_Status2	0x35
.define C_SPI_Flash_Write_Status2	0x31
.define C_SPI_Flash_RUID			0x4B

//----------- Flash Status Port Definition ----------
.define C_Flash_Busy				0x01
.define C_Flash_WEL					0x02		// Write Enable Latch
.define C_Flash_BP0					0x04
.define C_Flash_BP1					0x08
.define C_Flash_BP2					0x10
.define C_Flash_BP3					0x20		
.define C_Flash_PEE					0x40		// Program Erase Error
.define C_Flash_SRWP				0x80		// Status Register Write Protect

//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_RDSR23
.public R_WRSR23
.public R_QEbit

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.IF C_SPI_Port_Sel
.public  _SPI2_Flash_Initial
.public F_SPI2_Flash_Initial
.public  _SPI2_Flash_ReadAWord
.public F_SPI2_Flash_ReadAWord
.public  _SPI2_Flash_ReadNWords
.public F_SPI2_Flash_ReadNWords
.public  _SPI2_Flash_SendAWord
.public F_SPI2_Flash_SendAWord
.public  _SPI2_Flash_SendNWords
.public F_SPI2_Flash_SendNWords
.public  _SPI2_Flash_Read_Status_Register
.public F_SPI2_Flash_Read_Status_Register
.public  _SPI2_Flash_Read_Status_Reg3
.public F_SPI2_Flash_Read_Status_Reg3
.public  _SPI2_Flash_Write_Status_Register
.public F_SPI2_Flash_Write_Status_Register
.public  _SPI2_Flash_Write_Status_Reg3
.public F_SPI2_Flash_Write_Status_Reg3
.public  _SPI2_Flash_Read_Configuration_Register
.public F_SPI2_Flash_Read_Configuration_Register
.public  _SPI2_Flash_DeepPowerDown	
.public F_SPI2_Flash_DeepPowerDown
.public  _SPI2_Flash_ReleaseDeepPowerDown	
.public F_SPI2_Flash_ReleaseDeepPowerDown
.public  _SPI2_Flash_Read_UniqueID
.public F_SPI2_Flash_Read_UniqueID
.ELSE
.public  _SPI_Flash_ReadAWord
.public F_SPI_Flash_ReadAWord
.public  _SPI_Flash_ReadNWords
.public F_SPI_Flash_ReadNWords
.public  _SPI_Flash_SendAWord
.public F_SPI_Flash_SendAWord
.public  _SPI_Flash_SendNWords
.public F_SPI_Flash_SendNWords
.public  _SPI_Flash_Read_Status_Register
.public F_SPI_Flash_Read_Status_Register
.public  _SPI_Flash_Read_Status_Reg3
.public F_SPI_Flash_Read_Status_Reg3
.public  _SPI_Flash_Write_Status_Register
.public F_SPI_Flash_Write_Status_Register
.public  _SPI_Flash_Write_Status_Reg3
.public F_SPI_Flash_Write_Status_Reg3
.public  _SPI_Flash_Read_Configuration_Register
.public F_SPI_Flash_Read_Configuration_Register
.public  _SPI_Flash_Block_Erase
.public F_SPI_Flash_Block_Erase
.public  _SPI_Flash_Read_UniqueID
.public F_SPI_Flash_Read_UniqueID
.PUBLIC  _MoveSPIDriverToRAM_0
.PUBLIC F_MoveSPIDriverToRAM_0
.PUBLIC  _MoveSPIDriverToRAM_1
.PUBLIC F_MoveSPIDriverToRAM_1
.PUBLIC  _MoveSPIDriverToRAM_2
.PUBLIC F_MoveSPIDriverToRAM_2
.ENDIF
//**************************************************************************
// External Function Declaration
//**************************************************************************

//**************************************************************************
// External Table Declaration
//**************************************************************************

//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
//.var R_FlashIDIdx
.var R_RDSR23
.var R_WRSR23
.var R_QEbit
//*****************************************************************************
// Table Definition Area
//*****************************************************************************
.CODE

//**************************************************************************
// Do not removed and modified
//**************************************************************************	
 .DW 0x5067, 0x4174, 0x0147		
 .DW 0x0B1A, 0x0100				
 .DW 0x0504, 0x0100				
 .DW 0x01E4, 0x0000			

//****************************************************************
// Function    : 
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _MoveSPIDriverToRAM_0:	.proc
F_MoveSPIDriverToRAM_0:	
	push R1, R4 to [SP]
	R1 = 0x0010
	R2 = L_RAMCodeEnd_0 - L_RAMCodeStr_0
	R3 = 0x0001
	R4 = 0x2100
	
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
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _MoveSPIDriverToRAM_1:	.proc
F_MoveSPIDriverToRAM_1:	
	push R1, R4 to [SP]
	R1 = 0x0066
	R2 = L_RAMCodeEnd_1 - L_RAMCodeStr_1
	R3 = 0x0001
	R4 = 0x2200
	
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
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _MoveSPIDriverToRAM_2:	.proc
F_MoveSPIDriverToRAM_2:	
	push R1, R4 to [SP]
	R1 = 0x0066
	R2 = L_RAMCodeEnd_2 - L_RAMCodeStr_2
	R3 = 0x0001
	R4 = 0x2380
	
	DS = R3
L_MoveCodeLoop?:	
	R3 = D:[R4++]
	[R1++] = R3
	R2 -= 1
	jne L_MoveCodeLoop?
	pop R1, R4 from [SP]
	retf
	.endp		

SPIFC_RAMCode_SEC_0: .section .CODE	
L_RAMCodeStr_0:
//****************************************************************
// Function    : F_SPI_CheckDoneFlag
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI_CheckDoneFlag:	.proc
?L_Check_TXIF:					              // Wait untill command and address have been sent out
	tstb [PP_SPI_Misc], 4					  //test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	tstb [PP_SPI_Misc], 2					  //test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;
	retf
	.endp
		
//****************************************************************
// Function    : F_SPI_CheckStatusRegBusyFlag
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI_CheckStatusRegBusyFlag:	.proc
	push R1 to [sp]
?L_Check_Busy:						// Wait untill one word data has been written into flash successfully (about 3 to 12ms).
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Read_Status;
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;						// Read Status Reigster dummy clock
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];			// Received Dummy Data at Cmd transmitted
	R1 = [PP_SPI_RX_Data];			// Received Status Register Data
	
	tstb R1, 0						//test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;
	pop R1 from [sp]
	retf
	.endp
	
		

//****************************************************************
// Function    : F_SPI_ManualMode
// Description : 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_ManualMode: .proc
F_SPI_ManualMode:
	push R1 to [SP];
.IF C_SPI_Port_Sel
.ELSE	
	[P_SPI_Auto_Ctrl] = R1 - R1
.ENDIF	
	
	R1 = C_SPI_Enable | C_MasterMode | C_SPI_Reset | C_SPI_CS_GPIO | C_SPI_Clock_Phase_Normal | C_SPI_Clock_Pol_Normal;	
	[PP_SPI_Ctrl] = R1;	
L_SPIResetCheckLoop?:	
	R1 = [PP_SPI_Ctrl]
	test R1, C_SPI_Reset
	jne L_SPIResetCheckLoop?
.IF C_SPI_Port_Sel			// IOB (SPI2)
	R1 |= C_SPI_SCK_FPLL_Div_8
.ELSE						// IOA (SPI1)
	R1 |= C_SPI1_SCK_SYSCLK_Div_16	
.ENDIF
	[PP_SPI_Ctrl] = R1;			
	
	R1 = C_SPI_TX_INT_Flag | C_SPI_TX_INT_DIS | C_SPI_TX_FIFO_Level_0;
	[PP_SPI_TX_Status] = R1;
	
	R1 = C_SPI_RX_INT_Flag | C_SPI_RX_INT_DIS | C_SPI_RX_FIFO_Level_1;
	[PP_SPI_RX_Status] = R1;
	
	pop R1 from [SP];
	retf;
	.endp	
	
//****************************************************************
// Function    : F_Flash_Write_Enable
// Description : Enable flash to be written or erased
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Flash_Write_Enable:	.proc
F_Flash_Write_Enable:
	push r1 to [sp];

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Write_Enable;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	pop r1 from [sp];
	retf;
	.endp
	
//****************************************************************
// Function    : F_SPI_ReadAWord
// Description : Read a word data from flash
// Destory     : R1
// Parameter   : R1 = Address Low, R2 = Address High	
// Return      : R1 = one word of data read
// Note        : None
//****************************************************************
F_SPI_Flash_ExitEnhanceMode: 	.proc 	
	push R1 to [SP]
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;	// enable SPI Flash
		
	R1 = 0x00ff;
	[PP_SPI_TX_Data] = R1; 				//Exit SPI Flash enhance mode

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash
	
	R1 = [PP_SPI_RX_Data];
	pop R1 from [SP]
	retf
	.endp	
	
L_RAMCodeEnd_0:	
	
	
SPIFC_RAMCode_SEC_1: .section .CODE	
L_RAMCodeStr_1:	
//****************************************************************
// Function    : F_SPI_ReadAWord
// Description : Read a word data from flash
// Destory     : R1
// Parameter   : R1 = Address Low, R2 = Address High	
// Return      : R1 = one word of data read
// Note        : None
//****************************************************************
 _SPI_ReadAWord:	.proc
 _SPI_Flash_ReadAWord:
 _SPI2_Flash_ReadAWord:
	R2 = SP + 3;
	R1 = [R2++];
	R2 = [R2]; 
	
F_SPI_ReadAWord:
F_SPI_Flash_ReadAWord:
F_SPI2_Flash_ReadAWord:
	push r2, r5 to [sp];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	
	R4 = C_SPI_Flash_Read_CMD;
	[PP_SPI_TX_Data] = R4;
	
	.if C_SPI_4byteMode
	R4 = R2 lsr 4;				// Address High 4byte
	R4 = R4 lsr 4;
	[PP_SPI_TX_Data] = R4;
	.endif 

	R4 = R2 & 0xFF;					// Address High
	[PP_SPI_TX_Data] = R4;
	R4 = R1 lsr 4;
	R4 = R4 lsr 4;				// Address Middle
	[PP_SPI_TX_Data] = R4;
	R1 &= 0xFF;					// Address Low
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x55;					// Read One Word Data dummy clock
	[PP_SPI_TX_Data] = R1;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	.if C_SPI_4byteMode
	R1 = [PP_SPI_RX_Data];
	.endif

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Read Command transmitted   
	R2 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address High transmitted
	R3 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address Middle transmitted
	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address Low transmitted
	R2 = [PP_SPI_RX_Data];		// Received Valid Data High from slave SPI device
	R1 = [PP_SPI_RX_Data];		// Received Valid Data Low from slave SPI device
	R1 = R1 LSL 4;
	R1 = R1 LSL 4;
	R1 |= R2;					// Return one word data read from FLASH
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF
	
	pop R2, R5 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_ReadNWords
// Description : Get N words from external memory to buffer
// Destory     : R1
// Parameter   : R1 : buffer address
//               R2 : data length
//               R3 : external memory address low word
//               R4 : external memory address high word
// Return      : None
// Note        : None
//****************************************************************
 _SPI_ReadNWords:      .proc
 _SPI_Flash_ReadNWords:
 _SPI2_Flash_ReadNWords:
    R4 = SP + 3;
    R1 = [R4++];							// buffer address
.IF C_FarPointer
	R2 = [R4++];						//For FarPointer
.ENDIF    
    R2 = [R4++];							// data length
    R3 = [R4++];							// external memory address low byte
    R4 = [R4];							// external memory address high byte

F_SPI_ReadNWords:
F_SPI_Flash_ReadNWords:
F_SPI2_Flash_ReadNWords:
	push R1, R5 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	
	R5 = C_SPI_Flash_Read_CMD;
	[PP_SPI_TX_Data] = R5;

	.if C_SPI_4byteMode
	R5 = R4 lsr 4;				// Address High 4byte
	R5 = R5 lsr 4;
	[PP_SPI_TX_Data] = R5;
	.endif 

	R5 = R4 & 0xFF;				// Address High
	[PP_SPI_TX_Data] = R5;
	R4 = R3 lsr 4;
	R4 = R4 lsr 4;				// Address Middle
	[PP_SPI_TX_Data] = R4;
	R3 &= 0xFF;					// Address Low
	[PP_SPI_TX_Data] = R3;

	call F_SPI_CheckDoneFlag

	.if C_SPI_4byteMode
	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address High transmitted
	.endif

	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Read Command transmitted   
	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address High transmitted
	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address Middle transmitted
	R4 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO at Address Low transmitted

?L_GetNWordLoop:
	[PP_SPI_TX_Data] = R3;		// Read One Word Data dummy clock
	[PP_SPI_TX_Data] = R3;

	call F_SPI_CheckDoneFlag

	R3 = [PP_SPI_RX_Data];		// low byte data
	R4 = [PP_SPI_RX_Data];		// high byte data
	R4 = R4 lsl 4;
	R4 = R4 lsl 4;
	R4 |= R3;					// Return one word data read from FLASH
	[R1++] = R4;
	R2 -= 1;
	jnz ?L_GetNWordLoop;

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash
	
?_Finish_Last:
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF

	pop R1, R5 from [SP];

	retf;
	.endp

//****************************************************************
// Function    : F_SPI_SendAWord
// Description : Write a word data to flash
// Destory     : R1
// Parameter   : R1 = Address Low, R2 = Address High, R3 = one word of data
// Return      : None
// Note        : None
//****************************************************************
_SPI_SendAWord:	.proc
_SPI_Flash_SendAWord:
_SPI2_Flash_SendAWord:
	R3 = SP + 3;
	R1 = [R3++];
	R2 = [R3++];
	R3 = [R3];
	
F_SPI_SendAWord:
F_SPI_Flash_SendAWord:
F_SPI2_Flash_SendAWord:
	push R1, R5 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	call F_Flash_Write_Enable		// Flash must be written enable firstly before it is programmed or erased.

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash

	R4 = C_SPI_Flash_Page_Program;
	[PP_SPI_TX_Data] = R4;

	.if C_SPI_4byteMode
	R4 = R2 lsr 4;					// Address High 4 Byte
	R4 = R4 lsr 4;
	[PP_SPI_TX_Data] = R4;	
	.endif

	R4 = R2 & 0xFF;						// Address High
	[PP_SPI_TX_Data] = R4;
	R4 = R1 lsr 4;
	R4 = R4 lsr 4;					// Address Middle
	[PP_SPI_TX_Data] = R4;
	R1 &= 0xFF;						// Address Low
	[PP_SPI_TX_Data] = R1;
	
	[PP_SPI_TX_Data] = R3;			// Data Low Byte
	R3 = R3 lsr 4;
	R3 = R3 lsr 4;
	[PP_SPI_TX_Data] = R3;			// Data High Byte

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	.if C_SPI_4byteMode
	R1 =  [PP_SPI_RX_Data];;
	.endif

	R1 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R2 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R3 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R4 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R1 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R1 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	
	call F_SPI_CheckStatusRegBusyFlag
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF
	
	pop R1, R5 from [SP];
	retf;	
	.endp


//****************************************************************
// Function    : F_SPI_SendNWords
// Description : Send N words to external memory from internal buffer
// Destory     : None
// Parameter   : R1 : buffer address
//               R2 : data length
//               R3 : external memory address low word
//               R4 : external memory address high word
// Return      : None
// Note        : None
//****************************************************************
 _SPI_SendNWords:	.proc
 _SPI_Flash_SendNWords:
 _SPI2_Flash_SendNWords:
	R4 = SP + 3;
	R1 = [R4++];
.IF C_FarPointer
	R2 = [R4++];						//For FarPointer
.ENDIF 	
	R2 = [R4++];
	R3 = [R4++];
	R4 = [R4];
F_SPI_SendNWords:
F_SPI_Flash_SendNWords:
F_SPI2_Flash_SendNWords:
	push R1, R5 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	

?L_WriteData:
	
	call F_Flash_Write_Enable		// Flash must be written enable firstly before it is programmed or erased.

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash

	R5 = C_SPI_Flash_Page_Program;
	[PP_SPI_TX_Data] = R5;

	.if C_SPI_4byteMode
	R5 = R4 lsr 4;					// Address High 4 Byte
	R5 = R5 lsr 4;
	[PP_SPI_TX_Data] = R5;	
	.endif
	
	R5 = R4 & 0xFF;					//Address High
	[PP_SPI_TX_Data] = R5;
	R5 = R3 lsr 4;
	R5 = R5 lsr 4;					// Address Middle
	[PP_SPI_TX_Data] = R5;
	R5 = R3 & 0xFF;					// Address Low
	[PP_SPI_TX_Data] = R5;

	call F_SPI_CheckDoneFlag

	.if C_SPI_4byteMode
	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	.endif

	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 

?L_SendDataLoop:
	R5 = [R1++];
	[PP_SPI_TX_Data] = R5;			// Data Low Byte
	R5 = R5 lsr 4;
	R5 = R5 lsr 4;
	[PP_SPI_TX_Data] = R5;			// Data High Byte

	call F_SPI_CheckDoneFlag

	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO 
	R5 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO
	R2 -= 1;
	jz ?L_SendDataEnd;
	R3 += 2;
	test R3, 0x00FF;
	jnz ?L_SendDataLoop;
?L_JumpToNextPage:
	cmp R3, 0x0000;
	jne ?L_WriteCurrentPage;
	R4 += 1;
?L_WriteCurrentPage:
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash
	
	call F_SPI_CheckStatusRegBusyFlag

	pc = ?L_WriteData;

?L_SendDataEnd:
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	call F_SPI_CheckStatusRegBusyFlag

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF

	pop R1, R5 from [SP];
	retf;
	.endp	
	
L_RAMCodeEnd_1:	

SPIFC_RAMCode_SEC_2: .section .CODE	
L_RAMCodeStr_2:	
//****************************************************************
// Function    : F_Flash_Write_Disable
// Description : Disable flash to be written or erased
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Flash_Write_Disable:	.proc
F_Flash_Write_Disable:
	push r1 to [sp];
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Write_Disable;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash
	
	R1 = [PP_SPI_RX_Data];			// Clear dummy data in RX FIFO
	pop r1 from [sp];
	retf;
	.endp	


//****************************************************************
// Function    : F_SPI_Read_Status_Register
// Description : Read status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Read_Status_Register:	.proc
F_SPI_Read_Status_Register:
 _SPI_Flash_Read_Status_Register:
 _SPI2_Flash_Read_Status_Register:
F_SPI_Flash_Read_Status_Register:
F_SPI2_Flash_Read_Status_Register:
	push R2 to [sp]
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R2 = [P_SPI_Auto_Ctrl]
	push R2 to [SP]
	R2 = [PP_SPI_Ctrl]
	push R2 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Read_Status;
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;						// Read Status Reigster dummy clock
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];			// Received Dummy Data at Cmd transmitted
	R2 = [PP_SPI_RX_Data];			// Received Status Register Data
	
	//second byte
	//R1 = [R_FlashIDIdx]
	//R1 += T_SPIFlash_RDSR23
	//R1 = [R1]
	R1 = [R_RDSR23]
	R1 &= 0x00FF
	jne L_SecondByteStatus?
	R1 = R2 
	jmp L_Exit?
L_SecondByteStatus?:	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Read_Status2;
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;								// Read Status Reigster dummy clock
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;		// disable SPI Flash

	R1 = [PP_SPI_RX_Data];					// Received Dummy Data at Cmd transmitted
	R1 = [PP_SPI_RX_Data];					// Received Status Register Data
	
	R1 = R1 lsl 4
	R1 = R1 lsl 4
	R1 |= R2
L_Exit?:	

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R2 from [SP]
	[PP_SPI_Ctrl] = R2
	pop R2 from [SP]
	[P_SPI_Auto_Ctrl] = R2
.ENDIF

	pop R2 from [sp]
	
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Read_Status_Register3
// Description : Read status register3 in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Read_Status_Register3:	.proc
F_SPI_Read_Status_Register3:
 _SPI_Flash_Read_Status_Reg3:
 _SPI2_Flash_Read_Status_Reg3: 
F_SPI_Flash_Read_Status_Reg3:
F_SPI2_Flash_Read_Status_Reg3:
	push R2 to [SP]
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R2 = [P_SPI_Auto_Ctrl]
	push R2 to [SP]
	R2 = [PP_SPI_Ctrl]
	push R2 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	//R1 = [R_FlashIDIdx]
	//R1 += T_SPIFlash_RDSR23
	//R1 = [R1]
	R1 = [R_RDSR23]
	R1 = R1 lsr 4
	R1 = R1 lsr 4
	
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;						// Read Status Reigster dummy clock
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];			// Received Dummy Data at Cmd transmitted
	R1 = [PP_SPI_RX_Data];			// Received Status Register Data
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R2 from [SP]
	[PP_SPI_Ctrl] = R2
	pop R2 from [SP]
	[P_SPI_Auto_Ctrl] = R2
.ENDIF

	pop R2 from [sp]	
	
	retf;
	.endp	

//****************************************************************
// Function    : F_SPI_Write_Status_Register
// Description : Write data to status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Write_Status_Register:	.proc
 _SPI_Flash_Write_Status_Register:
 _SPI2_Flash_Write_Status_Register:
	R1 = SP + 3;
	R1 = [R1];
	
F_SPI_Write_Status_Register:
F_SPI_Flash_Write_Status_Register:
F_SPI2_Flash_Write_Status_Register:
	push R1, R2 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R2 = [P_SPI_Auto_Ctrl]
	push R2 to [SP]
	R2 = [PP_SPI_Ctrl]
	push R2 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF		
	
	call F_Flash_Write_Enable		// Flash must be written enable firstly before it is programmed or erased.

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R2 = C_SPI_Flash_Write_Status;
	[PP_SPI_TX_Data] = R2;
	[PP_SPI_TX_Data] = R1;		// Write data to status register in flash
	R2 = R1

	call F_SPI_CheckDoneFlag

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	
	R2 = R2 lsr 4
	R2 = R2 lsr 4
	
	//R1 = [R_FlashIDIdx]
	//R1 += T_SPIFlash_WRSR23
	//R1 = [R1]
	R1 = [R_WRSR23]
	R1 &= 0x00FF
	jne L_SendDone?
	
	//R1 = [R_FlashIDIdx]
	//R1 += T_SPIFlash_QEbit
	//R1 = [R1]
	R1 = [R_QEbit]
	R1 &= 0x00FF
	cmp R1, 0x0008
	jl L_SendDone?
	
//	R2 = R2 lsr 4
//	R2 = R2 lsr 4
	[PP_SPI_TX_Data] = R2;	
	
	call F_SPI_CheckDoneFlag
	
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	
L_SendDone?:	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	call F_SPI_CheckStatusRegBusyFlag
	
	//R1 = [R_FlashIDIdx]
	//R1 += T_SPIFlash_WRSR23
	//R1 = [R1]
	R1 = [R_WRSR23]
	R1 &= 0x00FF
	je L_Exit?
L_SecondByteCmd?:
	call F_Flash_Write_Enable			// Flash must be written enable firstly before it is programmed or erased.

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R2;					// Write data to status register in flash

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	
	R1 = [PP_SPI_RX_Data];					// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];					// Clear dummy data in RX FIFO

	call F_SPI_CheckStatusRegBusyFlag

L_Exit?:

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R2 from [SP]
	[PP_SPI_Ctrl] = R2
	pop R2 from [SP]
	[P_SPI_Auto_Ctrl] = R2
.ENDIF
	pop R1, R2 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Write_Status_Register3
// Description : Write data to status register3 in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Write_Status_Register3:	.proc
 _SPI_Flash_Write_Status_Reg3:
 _SPI2_Flash_Write_Status_Reg3: 
	R1 = SP + 3;
	R1 = [R1];
	
F_SPI_Write_Status_Register3:
F_SPI_Flash_Write_Status_Reg3:
F_SPI2_Flash_Write_Status_Reg3:
	push R1, R2 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R2 = [P_SPI_Auto_Ctrl]
	push R2 to [SP]
	R2 = [PP_SPI_Ctrl]
	push R2 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF			
	
	call F_Flash_Write_Enable		// Flash must be written enable firstly before it is programmed or erased.

	//R2 = [R_FlashIDIdx]
	//R2 += T_SPIFlash_WRSR23
	//R2 = [R2]
	R2 = [R_WRSR23]
	R2 = R2 lsr 4
	R2 = R2 lsr 4

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash

	[PP_SPI_TX_Data] = R2;
	[PP_SPI_TX_Data] = R1;		// Write data to status register in flash

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	
	call F_SPI_CheckStatusRegBusyFlag

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R2 from [SP]
	[PP_SPI_Ctrl] = R2
	pop R2 from [SP]
	[P_SPI_Auto_Ctrl] = R2
.ENDIF

	pop R1, R2 from [SP];
	retf;
	.endp		


//****************************************************************
// Function    : F_SPI_Flash_Block_Erase
// Description : Erase one sector of flash 
// Destory     : None
// Parameter   : R1 = Sector Address Low, R2 = Sector Address High
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Flash_Block_Erase:	.proc
 _SPI2_Flash_Block_Erase:	
	R1 = SP + 3;
	R1 = [R1];
F_SPI_Flash_Block_Erase:
F_SPI2_Flash_Block_Erase:
	push R1, R5 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	call F_Flash_Write_Enable;	// Enable sector erase command 
		
.if 0		// for GPR25L005, GPR25L010, GPR25L020, GPR25L040, GPR25L080
	R2 = SECTOR_SIZE;
	MR = R1 * R2;
	R1 = R3;
	R2 = R4;
.endif

.if 1		// for GPR25L160, GPR25L320, GPR25L640
	R2 = R1;
	R1 = 0x0000;
.endif

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R3 = C_SPI_Flash_Block_Erase;
	[PP_SPI_TX_Data] = R3;

	.if C_SPI_4byteMode
	R4 = R2 lsr 4;					// Address High 4 Byte
	R4 = R4 lsr 4;
	[PP_SPI_TX_Data] = R4;
	.endif
	
	R2 &=0xff;	
	[PP_SPI_TX_Data] = R2;		// Sector index : Sector size = 64K bytes
	R3 = R1 lsr 4;			
	R3 = R3 lsr 4;
	[PP_SPI_TX_Data] = R3;
	R1 &= 0x00FF;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	.if C_SPI_4byteMode
	R1 = [PP_SPI_RX_Data];
	.endif	
	
	call F_SPI_CheckStatusRegBusyFlag
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF	
	
	pop R1, R5 from [SP];
	retf;
	.endp
	
//****************************************************************
// Function    : F_SPI_Flash_Sector_Erase
// Description : Erase one sector of flash 
// Destory     : None
// Parameter   : R1 = Sector Address Low, R2 = Sector Address High
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Flash_Sector_Erase:	.proc
 _SPI2_Flash_Sector_Erase:
	R1 = SP + 3;
	R1 = [R1];
F_SPI_Flash_Sector_Erase:
F_SPI2_Flash_Sector_Erase:
	push R1, R5 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	call F_Flash_Write_Enable;	// Enable sector erase command 
		
.if 1		// for GPR25L005, GPR25L010, GPR25L020, GPR25L040, GPR25L080
	//R2 = SECTOR_SIZE;
	R2 = 0x1000;
	MR = R1 * R2;
	R1 = R3;
	R2 = R4;
.endif

.if 0		// for GPR25L160, GPR25L320, GPR25L640
	R2 = R1;
	R1 = 0x0000;
.endif

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R3 = C_SPI_Flash_Sector_Erase;
	[PP_SPI_TX_Data] = R3;

	.if C_SPI_4byteMode
	R4 = R2 lsr 4;					// Address High 4 Byte
	R4 = R4 lsr 4;
	[PP_SPI_TX_Data] = R4;
	.endif

	R2 &=0xff	
	[PP_SPI_TX_Data] = R2;		// Sector index : Sector size = 64K bytes
	R3 = R1 lsr 4;			
	R3 = R3 lsr 4;
	[PP_SPI_TX_Data] = R3;
	R1 &= 0x00FF;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag

	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	R1 = [PP_SPI_RX_Data];		// Clear dummy data in RX FIFO
	.if C_SPI_4byteMode
    R1 = [PP_SPI_RX_Data]	
    .endif
	
	call F_SPI_CheckStatusRegBusyFlag
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF	
	
	pop R1, R5 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Flash_Chip_Erase
// Description : Erase hole chip of flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Flash_Chip_Erase:	.proc
 _SPI2_Flash_Chip_Erase:
F_SPI_Flash_Chip_Erase:
F_SPI2_Flash_Chip_Erase:
	push R1 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R1 = [P_SPI_Auto_Ctrl]
	push R1 to [SP]
	R1 = [PP_SPI_Ctrl]
	push R1 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF
	
	call F_Flash_Write_Enable;		// Enable chip erase command 
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Chip_Erase;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash
	R1 = [PP_SPI_RX_Data];

	call F_SPI_CheckStatusRegBusyFlag

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R1 from [SP]
	[PP_SPI_Ctrl] = R1
	pop R1 from [SP]
	[P_SPI_Auto_Ctrl] = R1
.ENDIF

	pop R1 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI_Read_Flash_ID
// Description : Read flash manufacturer,memory and individual device ID
// Destory     : None
// Parameter   : None
// Return      : R1 = Manufacturer and memory ID, R2 = Individual Device ID
// Note        : None
//****************************************************************
 _SPI_Read_Flash_ID:	.proc
 _SPI2_Read_Flash_ID: 
F_SPI_Read_Flash_ID:
F_SPI2_Read_Flash_ID:
	push R3, R4 to [SP];
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R4 = [P_SPI_Auto_Ctrl]
	push R4 to [SP]
	R4 = [PP_SPI_Ctrl]
	push R4 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	
	
	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R4 = C_SPI_Flash_Read_ID;
	[PP_SPI_TX_Data] = R4;
		
	R1 = 0x00;					// Read One Byte Data dummy clock
	[PP_SPI_TX_Data] = R1;
	[PP_SPI_TX_Data] = R1;
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];		// Clear Dummy Data in RX FIFO at Read Cmd transmitted   
	R2 = [PP_SPI_RX_Data];		// Read Manufacturer ID
	R3 = [PP_SPI_RX_Data];		// Read Memory ID
	R4 = [PP_SPI_RX_Data];		// Read Individual Device ID
	R1 = R3 LSL 4;
	R1 = R1 LSL 4;
	R1 |= R2;
	R2 = R4;

.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R4 from [SP]
	[PP_SPI_Ctrl] = R4
	pop R4 from [SP]
	[P_SPI_Auto_Ctrl] = R4
.ENDIF

	pop R3, R4 from [SP];
	retf;
	.endp
	

//****************************************************************
// Function    : F_SPI_Read_Configuration_Register
// Description : Read status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Read_Configuration_Register:	.proc
F_SPI_Read_Configuration_Register:
 _SPI_Flash_Read_Configuration_Register:
 _SPI2_Flash_Read_Configuration_Register: 
F_SPI_Flash_Read_Configuration_Register:
F_SPI2_Flash_Read_Configuration_Register:
	push R2 to [SP]
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R2 = [P_SPI_Auto_Ctrl]
	push R2 to [SP]
	R2 = [PP_SPI_Ctrl]
	push R2 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Configuration;
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;						// Read Status Reigster dummy clock
	[PP_SPI_TX_Data] = R1;

	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [PP_SPI_RX_Data];			// Received Dummy Data at Cmd transmitted
	R1 = [PP_SPI_RX_Data];			// Received Status Register Data
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R2 from [SP]
	[PP_SPI_Ctrl] = R2
	pop R2 from [SP]
	[P_SPI_Auto_Ctrl] = R2
.ENDIF	
	pop R2 from [SP]
	
	retf;
	.endp	
	
	
//****************************************************************
// Function    : F_SPI_Read_Configuration_Register
// Description : Read status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI_Flash_Read_UniqueID: .proc
 _SPI2_Flash_Read_UniqueID: 
F_SPI_Flash_Read_UniqueID:
F_SPI2_Flash_Read_UniqueID:
	push R5 to [SP]
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	R5 = [P_SPI_Auto_Ctrl]
	push R5 to [SP]
	R5 = [PP_SPI_Ctrl]
	push R5 to [SP]
	call F_SPI_ManualMode
	call F_SPI_Flash_ExitEnhanceMode
.ENDIF	

	clrb [PP_SPI_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	
	R1 = C_SPI_Flash_RUID;
	[PP_SPI_TX_Data] = R1;
	
	R1 = 0x00;						
	[PP_SPI_TX_Data] = R1;					// 1st Dummy Clock
	[PP_SPI_TX_Data] = R1;					// 2nd Dummy Clock
	[PP_SPI_TX_Data] = R1;					// 3rd Dummy Clock
	[PP_SPI_TX_Data] = R1;					// 4th Dummy Clock

	call F_SPI_CheckDoneFlag
	
	R1 = [PP_SPI_RX_Data];
	R1 = [PP_SPI_RX_Data];
	R1 = [PP_SPI_RX_Data];
	R1 = [PP_SPI_RX_Data];
	R1 = [PP_SPI_RX_Data];
	
	R1 = 0x00
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	[PP_SPI_TX_Data] = R1;	
	
	call F_SPI_CheckDoneFlag
	
	setb [PP_SPI_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R4 = [PP_SPI_RX_Data]
	R5 = [PP_SPI_RX_Data]
	R4 = R4 LSL 4
	R4 = R4 LSL 4
	R4 |= R5
	
	R3 = [PP_SPI_RX_Data]
	R5 = [PP_SPI_RX_Data]
	R3 = R3 LSL 4
	R3 = R3 LSL 4
	R3 |= R5
	
	R2 = [PP_SPI_RX_Data]
	R5 = [PP_SPI_RX_Data]
	R2 = R2 LSL 4
	R2 = R2 LSL 4
	R2 |= R5
	
	R1 = [PP_SPI_RX_Data]
	R5 = [PP_SPI_RX_Data]
	R1 = R1 LSL 4
	R1 = R1 LSL 4
	R1 |= R5
	
.IF C_SPI_Port_Sel			// IOB (SPI2)
.ELSE						// IOA (SPI1)	
	pop R5 from [SP]
	[PP_SPI_Ctrl] = R5
	pop R5 from [SP]
	[P_SPI_Auto_Ctrl] = R5
.ENDIF	
	pop R5 from [SP]
	
	retf;
	.endp		
	
L_RAMCodeEnd_2: