//**************************************************************************
// Header File Included Area
//**************************************************************************
.include 	GPCE36_CE5.inc

//**************************************************************************
// External Variable Declaration
//**************************************************************************
.EXTERNAL	_BREAK
.EXTERNAL	_FIQ
.EXTERNAL	_IRQ0
.EXTERNAL	_IRQ1
.EXTERNAL	_IRQ2
.EXTERNAL	_IRQ3
.EXTERNAL	_IRQ4
.EXTERNAL	_IRQ5
.EXTERNAL	_IRQ6
.EXTERNAL	_IRQ7

.external 	R_RDSR23
.external 	R_WRSR23
.external 	R_QEbit

//**************************************************************************
// External Function Declaration
//**************************************************************************
.external 	F_Cache_Enable

//**************************************************************************
// User Defintion Area
//**************************************************************************
.define 	C_SPI_4byteMode				0

//**************************************************************************
// Contant Defintion Area
//**************************************************************************
.define 	C_SPI_MOSI_Bit				0x0010	// In 4I/O Mode, SIO0
.define 	C_SPI_MISO_Bit				0x0040	// In 4I/O Mode, SIO1
.define 	C_SPI_SCK_Bit				0x0008
.define 	C_SPI_CS_Bit				0x0020
.define 	C_SPI_WRB_Bit				0x0080	// In 4I/O Mode, SIO2
.define 	C_SPI_HOLDB_Bit				0x0004	// In 4I/O Mode, SIO3

.define 	C_SPI_CS_IO					5		//IOA[12] as SPI CS pin Software Control

.define 	C_SPI1_1IO_Mode				0
.define 	C_SPI1_2IO_Mode				1
.define 	C_SPI1_4IO_SPI_Mode			2
//----------- Flash Operation Command Definition -------
.define 	C_SPI_Flash_Read_CMD		0x03
.define 	C_SPI_Flash_Block_Erase		0xD8
.define 	C_SPI_Flash_Sector_Erase	0x20
.define 	C_SPI_Flash_Chip_Erase		0xC7
.define 	C_SPI_Flash_Page_Program	0x02
.define 	C_SPI_Flash_Read_Status		0x05
.define 	C_SPI_Flash_Write_Status	0x01
.define 	C_SPI_Flash_Write_Enable	0x06
.define 	C_SPI_Flash_Write_Disable	0x04
.define 	C_SPI_Flash_Read_ID			0x9F
.define 	C_SPI_Flash_Read_REMS		0x90
.define 	C_SPI_Flash_Fast_Read		0x0B
.define 	C_SPI_Flash_Power_Down		0xB9
.define 	C_SPI_Flash_Release_DP		0xAB
.define 	C_SPI_Flash_Enter_4K		0xA5
.define 	C_SPI_Flash_Exit_4K			0xB5
.define 	C_SPI_Flash_Read_ES			0xAB
.define 	C_SPI_Flash_Read_EMS		0x90
.define 	C_SPI_Flash_Parallel_Mode	0x55
.define 	C_SPI_Flash_EN4B_Mode		0xB7
.define 	C_SPI_Flash_EX4B_Mode		0xE9
.define 	C_SPI_Flash_Configuration	0x15
.define 	C_SPI_Flash_Read_Status2	0x35
.define 	C_SPI_Flash_Write_Status2	0x31
.define  	C_SPI_Flash_QPI_Enable		0x35
.define  	C_SPI_Flash_QPI_Disable		0xF5

.define  	C_SPI_Flash_Enhance_Data	0xA5
//----------- Flash Status Port Definition ----------
.define 	C_Flash_Busy				0x01
.define 	C_Flash_WEL					0x02		// Write Enable Latch
.define 	C_Flash_BP0					0x04
.define 	C_Flash_BP1					0x08
.define 	C_Flash_BP2					0x10
.define 	C_Flash_BP3					0x20		
.define 	C_Flash_PEE					0x40		// Program Erase Error
.define 	C_Flash_SRWP				0x80		// Status Register Write Protect

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.PUBLIC _RESET

//**************************************************************************
// External Function Declaration
//**************************************************************************
.EXTERNAL __sn_init_table, _main, __sn_sp_val


BootCode_SEC:		.section		.CODE
	.dw 0xFFFF	// 0
	.dw 0xFFFF	// 1
	.dw 0xFFFF	// 2
	.dw 0xFFFF	// 3
	.dw 0xFFFF	// 4
	.dw _BREAK	// 5
	.dw _FIQ	// 6
	.dw _RESET	// 7
	.dw _IRQ0	// 8
	.dw _IRQ1	// 9
	.dw _IRQ2	// 10
	.dw _IRQ3	// 11
	.dw _IRQ4	// 12
	.dw _IRQ5	// 13
	.dw _IRQ6	// 14
	.dw _IRQ7	// 15


 _RESET:
 _BootCode_User:	.proc	
	R1 = C_SYSCLK_81920KHz | C_Sleep_IOSC32K_SLP_Off | C_IOSC8192M_Trim_from_Fuse;
	[P_System_Clock] = R1;
	 
 	call F_IntBootCodeChecksumCheck
	
//	R3 = C_SPI1_1IO_Mode
// 	R3 = C_SPI1_2IO_Mode
 	R3 = C_SPI1_4IO_SPI_Mode
 	call F_SPI1_Flash_AutoMode_Initial
L_CalibrationnLoop?: 	
 	call F_SPI1_Calibration
 	cmp R1, 0xFFFF
 	jne L_I32KCalibration?

 	R1 = [P_SPI_Ctrl]
 	R2 = R1 & C_SPI1_SCK_SEL
 	R1 &= ~C_SPI1_SCK_SEL
 	R2 += 1
 	cmp R2, 0x0008
 	jne L_KeepCalibration?
 	R2 = 0
L_KeepCalibration?: 	
 	R1 |= R2
 	[P_SPI_Ctrl] = R1
 	goto L_CalibrationnLoop?
L_I32KCalibration?:
	R1 = 0x097B
	[P_IOSC32K_Cal_LB] = R1
	R1 = 0x0A11
	[P_IOSC32K_Cal_HB] = R1
	R1 = [P_System_Clock]
	R1 |= C_IOSC32K_Cal_Enable
	[P_System_Clock] = R1
L_I32KCaliLoop?:	
	R1 = [P_System_Clock]
	R1 &= C_IOSC32K_Cal_Ready
	je L_I32KCaliLoop?
	R1 = [P_System_Clock]
	R1 &= C_IOSC32K_Cal_Pass
	je L_I32KCalibration?
	R8 = [R_BootRDSR23]
	R9 = [R_BootWRSR23]
	R10 = [R_BootQEbit]
 	goto _unSP_StartUp
 	.endp
 	
//****************************************************************
// Function    : F_SPI1_Calibration
// Description : 
// Destory     : R1, R2, R3
// Parameter   : R3 = Multi IO Mode Select
// Return      : None
// Note        : None
//**************************************************************** 	
F_SPI1_Calibration:
	R1 = C_Cache_Disable;
	[P_Cache_Ctrl] = R1;
	NOP;
	NOP;
	NOP;
	NOP;
	NOP;
	
	R1 = 0
	[R_LowerBond] = R1
	[R_UpperBond] = R1
	R2 = [P_SPI_Auto_Setting]
	R2 &= ~C_SPI_RX_Delay_Time
	[P_SPI_Auto_Setting] = R2
L_CheckLowerBond?:	
	call F_TableCheck
	cmp R1, 0x0000
	je L_CheckUpperBond?
	
	R2 = [P_SPI_Auto_Setting]
	R1 = R2
	R1 &= C_SPI_RX_Delay_Time
	R2 &= ~C_SPI_RX_Delay_Time
	R1 += C_SPI_RX_Delay_1Unit
	cmp R1, 0x1000
	je L_CaliFail?
	R2 |= R1
	[P_SPI_Auto_Setting] = R2
	
	jmp L_CheckLowerBond?
L_CaliFail?:
	R1 = [P_SPI_Auto_Ctrl]
	R2 = 0
	[P_SPI_Auto_Ctrl] = R2
	R3 = [P_SPI_Ctrl]
	R3 |= C_SPI_Reset
	[P_SPI_Ctrl] = R3
L_WaitResetDone?:	
	R3 = [P_SPI_Ctrl]
	R3 &= C_SPI_Reset
	jne L_WaitResetDone?
	[P_SPI_Auto_Ctrl] = R1
	R1 = 0xFFFF
	retf	
L_CheckUpperBond?:	
	R1 = [P_SPI_Auto_Setting]
	R1 &= C_SPI_RX_Delay_Time
	[R_LowerBond] = R1
	[R_UpperBond] = R1
L_UpperCaliLoop?:
	R2 = [P_SPI_Auto_Setting]
	R1 = R2
	R1 &= C_SPI_RX_Delay_Time
	R2 &= ~C_SPI_RX_Delay_Time
	R1 += C_SPI_RX_Delay_1Unit
	cmp R1, 0x1000
	je L_CaliDone?
	R2 |= R1
	[P_SPI_Auto_Setting] = R2
	call F_TableCheck
	cmp R1, 0xFFFF
	je L_CaliDone?
	R1 = [P_SPI_Auto_Setting]
	R1 &= C_SPI_RX_Delay_Time
	[R_UpperBond] = R1
	jmp L_UpperCaliLoop?
L_CaliDone?:	
	R1 = [R_LowerBond]
	R2 = [R_UpperBond]
	R3 = R2
	R3 -= R1
	cmp R3, 0x0300
	jae L_CaliPass?
	goto L_CaliFail?
L_CaliPass?:	
	R1 += R2
	R1 += 0x0100
	R1 = R1 lsr 1
	R1 &= C_SPI_RX_Delay_Time
	R2 = [P_SPI_Auto_Setting]
	R2 &= ~C_SPI_RX_Delay_Time
	R1 |= R2
	[P_SPI_Auto_Setting] = R1
	retf
	
F_TableCheck:
	R1 = R_Calibration
	R2 = 0x0008
	R3 = OFFSET T_Calibration
	R4 = SEG16 T_Calibration
?L_ReadLoop:
	DS = R4;
	R5 = D:[R3++];
	[R1++] = R5;
	R2 -= 1;
	jnz ?L_ReadLoop;
	
	R1 = R_Calibration
	R2 = T_Calibration_Golden
L_CmpLoop?:	
	R3 = [R1++]
	R4 = [R2++]
	cmp R3, R4
	jne L_ReadFail?
	cmp R1, R_Calibration + 0x0008
	jne L_CmpLoop?
	R1 = 0x0000
	retf
L_ReadFail?:
	R1 = 0xFFFF
	retf	

R_Calibration:    .dw    8    dup(?) 
R_LowerBond:	  .dw 	 1  
R_UpperBond:	  .dw 	 1   
 	
T_Calibration_Golden:
	.DW 0xFFFF
	.DW 0x0000
	.DW 0xAA55
	.DW 0x55AA	
	.DW 0xFF00
	.DW 0x00FF
	.DW 0x0FF0
	.DW 0xF00F 	
 	
//****************************************************************
// Function    : F_SPI1_MultiIOMode_Initial
// Description : SPI1 Flash Control Multi-IO Mode Initial
// Destory     : R1, R2, R3
// Parameter   : R3 = Multi IO Mode Select
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Flash_AutoMode_Initial: .proc
	call F_SPI1_ChangeStatusTo4IOMode;
		
	R1 = [P_SPI_Auto_Setting]
	R1 |= C_SPI_High_Driving_12mA | C_SPI_CS_KeepLow;
	[P_SPI_Auto_Setting] = R1
	
F_SPI1_AutoMode:
	R1 = C_SPI_Enable | C_SPI_Auto_Enable | C_SPI_CS_SPI | C_MasterMode | C_SPI1_SCK_SYSCLK_Div_2;
	R1 |= C_SPI_Clock_Phase_Normal | C_SPI_Clock_Pol_Normal;

?L_Setup_1IO:
	cmp R3, C_SPI1_1IO_Mode;
	jne ?L_Setup_2IO
	R1 |= C_SPI_MultiIO_Sel_1IO;
	R2 = C_SPI_AddrMode_MultiIO | C_SPI_Auto_Enhancement_Disable;
	R2 |= C_SPI_Auto_Dummy_Cycle_0 | C_SPI_Read_CMD_1IO;
	.if C_SPI_4byteMode	
	R2 |= C_SPI_Addr_Len_Mode_4Bytes;
	.else
	R2 |= C_SPI_Addr_Len_Mode_3Bytes;
	.endif
?L_Setup_2IO:
	cmp R3, C_SPI1_2IO_Mode;
	jne ?L_Setup_4IO_SPI
	R1 |= C_SPI_MultiIO_Sel_2IO;
	R2 = C_SPI_AddrMode_1IO | C_SPI_Auto_Enhancement_Disable;
	R2 |= C_SPI_Auto_Dummy_Cycle_2 | C_SPI_Read_CMD_2IO;
	.if C_SPI_4byteMode	
	R2 |= C_SPI_Addr_Len_Mode_4Bytes;
	.else
	R2 |= C_SPI_Addr_Len_Mode_3Bytes;
	.endif

?L_Setup_4IO_SPI:
	cmp R3, C_SPI1_4IO_SPI_Mode;
	jne ?L_Setup_End;
	R1 |= C_SPI_MultiIO_Sel_4IO;
	
	R2 = [P_SPI_Auto_Setting]
	R2 |= C_SPI_Auto_SIO2SIO3_OutputHigh;
	[P_SPI_Auto_Setting] = R2
	
	R2 = C_SPI_Flash_Enhance_Data;
	[P_SPI_Enhance_Data] = R2;
	
	R2 = C_SPI_CmdMode_1IO | C_SPI_AddrMode_MultiIO | C_SPI_Auto_Enhancement_Enable;
	R2 |= C_SPI_Auto_Dummy_Cycle_2 | C_SPI_Read_CMD_4IOM;
		
	.if C_SPI_4byteMode	
	R2 |= C_SPI_Addr_Len_Mode_4Bytes;
	.else
	R2 |= C_SPI_Addr_Len_Mode_3Bytes;
	.endif
	
?L_Setup_End:
	[P_SPI_Ctrl] = R1;
	[P_SPI_Auto_Ctrl] = R2;

	retf;
	.endp; 	
 	
//****************************************************************
// Function    : F_SPI1_ChangeStatusTo4IOMode
// Description : Change SPI Flash Mode to 4I/O Mode ( For SPI1 )
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_ChangeStatusTo4IOMode:	.proc
	push R1, R4 to [SP];
	call F_SPI_Flash_Initial
	
	R1 = 300;
L_Delay?:
	R1 -= 1;
	jne L_Delay?
	
	R2 = [R_BootQEbit]
	jpl L_Exit?
	R2 &= 0x000F
    call F_SPI1_Read_Status_Register;
	tstb R1, R2
	jnz L_Exit?
	setb R1, R2
	call F_SPI1_Write_Status_Register;
L_Exit?:

	pop R1, R4 from [SP];
	retf;
	.endp; 	
 	
//****************************************************************
// Function    : F_SPI_Initial
// Description : Initial SPI interface
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI_Flash_Initial:	.proc
	push R2, R3 to [SP];

	R1 = [P_IOC_Attrib];
	R1 |= C_SPI_MOSI_Bit | C_SPI_SCK_Bit | C_SPI_CS_Bit;
	R1 &= ~C_SPI_MISO_Bit
	[P_IOC_Attrib] = R1;
	
	R1 = [P_IOC_Buffer];
	R1 &= ~(C_SPI_MOSI_Bit | C_SPI_MISO_Bit | C_SPI_SCK_Bit );
	R1 |= C_SPI_CS_Bit;
	[P_IOC_Buffer] = R1;

	R1 = [P_IOC_Dir];
	R1 &= ~C_SPI_MISO_Bit;
	R1 |= C_SPI_MOSI_Bit | C_SPI_SCK_Bit | C_SPI_CS_Bit;
	[P_IOC_Dir] = R1;
	
	////////////////////////////////////////////////////////////////////////// when using 4 I/O mode
	R1 = [P_IOC_Attrib];	
	R1 |= C_SPI_HOLDB_Bit | C_SPI_WRB_Bit;
	[P_IOC_Attrib] = R1;
	R1 = [P_IOC_Buffer];		
	R1 |= C_SPI_HOLDB_Bit | C_SPI_WRB_Bit;
	[P_IOC_Buffer] = R1;
	R1 = [P_IOC_Dir];			
	R1 |= C_SPI_HOLDB_Bit | C_SPI_WRB_Bit;	// Change IOA[10](SPI_HOLDB) and IOA[11](SPI_WRB) as Output High, when SPI in 1 I/O Mode, avoid SPI HLOD and Protect.
	[P_IOC_Dir] = R1;			
	//////////////////////////////////////////////////////////////////////////
	
	R1 = C_SPI_Enable | C_MasterMode | C_SPI_CS_GPIO | C_SPI1_SCK_SYSCLK_Div_16 | C_SPI_Auto_Disable | C_SPI_Clock_Phase_Normal | C_SPI_Clock_Pol_Normal;
	[P_SPI_Ctrl] = R1;
	R1 = C_SPI_TX_INT_Flag | C_SPI_TX_INT_DIS | C_SPI_TX_FIFO_Level_0;
	[P_SPI_TX_Status] = R1;
	R1 = C_SPI_RX_INT_Flag | C_SPI_RX_INT_DIS | C_SPI_RX_FIFO_Level_1;
	[P_SPI_RX_Status] = R1;
	
	call F_SPI_Read_Flash_REMS
	R2 = [T_SPIFlash_NoOfID]
L_IDCheck?:	
	R2 -= 1
	R3 = T_SPIFlash_REMS
	R3 += R2
	cmp R1, [R3] 
	je L_IDCheckDone?
	cmp R2, 0x0000
	jne L_IDCheck?
	R1 = 0xFFFF
L_IDCheckDone?:	
	R3 = T_SPIFlash_RDSR23
	R3 += R2
	R3 = [R3]
	[R_BootRDSR23] = R3
	R3 = T_SPIFlash_WRSR23
	R3 += R2
	R3 = [R3]
	[R_BootWRSR23] = R3
	R3 = T_SPIFlash_QEbit
	R3 += R2
	R3 = [R3]
	[R_BootQEbit] = R3
	
	.if C_SPI_4byteMode
	call F_SPI1_Flash_EN4B;
	.endif	
	
	pop R2, R3 from [SP];
	retf;
	.endp 	
 	
//****************************************************************
// Function    : F_SPI_Read_Flash_REMS
// Description : Read flash manufactory ID and device ID
// Destory     : None
// Parameter   : None
// Return      : R1[15:8] = device ID, R1[7:0] = manufactory ID  
// Note        : None
//****************************************************************
 _SPI_Read_Flash_REMS:	.proc
F_SPI_Read_Flash_REMS:
	push R2, R4 to [SP];
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R4 = C_SPI_Flash_Read_REMS;
	[P_SPI_TX_Data] = R4;
		
	R1 = 0x00;					// Read One Byte Data dummy clock
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];		// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;	// disable SPI Flash

	R1 = [P_SPI_RX_Data];		// Clear Dummy Data in RX FIFO at Read Cmd transmitted   
	R1 = [P_SPI_RX_Data];		// Clear Dummy Data in RX FIFO at Read Cmd transmitted   
	R1 = [P_SPI_RX_Data];		// Clear Dummy Data in RX FIFO at Read Cmd transmitted   
	R1 = [P_SPI_RX_Data];		// Clear Dummy Data in RX FIFO at Read Cmd transmitted   
	R2 = [P_SPI_RX_Data];		// Read Manufacturer ID
	R3 = [P_SPI_RX_Data];		// Read device ID
	R1 = R3 LSL 4;
	R1 = R1 LSL 4;
	R1 |= R2;
	
	pop R2, R4 from [SP];
	retf;
	.endp 	
 	
//****************************************************************
// Function    : F_SPI1_Flash_EN4B
// Description : 
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _SPI1_Flash_EN4B:	.proc
F_SPI1_Flash_EN4B:
	push r1 to [sp];
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_EN4B_Mode;
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;

	nop;
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	pop r1 from [sp];
	retf;
	.endp	 	
	
//****************************************************************
// Function    : F_SPI1_Read_Status_Register
// Description : Read status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Read_Status_Register:	.proc
	push R2 to [sp]
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Read_Status;
	[P_SPI_TX_Data] = R1;
	
	R1 = 0x00;								// Read Status Reigster dummy clock
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;

	R1 = [P_SPI_RX_Data];					// Received Dummy Data at Cmd transmitted
	R2 = [P_SPI_RX_Data];					// Received Status Register Data
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash

	//second byte
	R1 = [R_BootRDSR23]
	R1 &= 0x00FF
	jne L_SecondByteStatus?
	R1 = R2 
	jmp L_Exit?
L_SecondByteStatus?:	
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Read_Status2;
	[P_SPI_TX_Data] = R1;
	
	R1 = 0x00;								// Read Status Reigster dummy clock
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF_2:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_2;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_2;

	R1 = [P_SPI_RX_Data];					// Received Dummy Data at Cmd transmitted
	R1 = [P_SPI_RX_Data];					// Received Status Register Data
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	
	R1 = R1 lsl 4
	R1 = R1 lsl 4
	R1 |= R2
L_Exit?:	
	pop R2 from [sp]
	retf;
	.endp	
	
//****************************************************************
// Function    : F_SPI1_Write_Status_Register
// Description : Write data to status register in flash
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Write_Status_Register:	.proc
	push R1, R2 to [SP];
	call F_SPI1_Flash_Write_Enable			// Flash must be written enable firstly before it is programmed or erased.

	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R2 = C_SPI_Flash_Write_Status;
	[P_SPI_TX_Data] = R2;
	[P_SPI_TX_Data] = R1;					// Write data to status register in flash
	R2 = R1

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;
	
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
	R2 = R2 lsr 4
	R2 = R2 lsr 4
	
	R1 = [R_BootWRSR23]
	R1 &= 0x00FF
	jne L_SendDone?
	

	R1 = [R_BootQEbit]
	R1 &= 0x00FF
	cmp R1, 0x0008
	jl L_SendDone?
	
//	R2 = R2 lsr 4
//	R2 = R2 lsr 4
	[P_SPI_TX_Data] = R2;	
	
?L_Check_TXIF_2:
	R1 = [P_SPI_Misc];		// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_2;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_2;	
	
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
L_SendDone?:	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash

?L_Check_Busy:								// Wait untill sector has been erased successfully (about 1 to 3 seconds)
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	call F_SPI1_Read_Status_Register;
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy;
	
	R1 = [R_BootWRSR23]
	R1 &= 0x00FF
	je L_Exit?
L_SecondByteCmd?:
	call F_SPI1_Flash_Write_Enable			// Flash must be written enable firstly before it is programmed or erased.

	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	[P_SPI_TX_Data] = R1;
	[P_SPI_TX_Data] = R2;					// Write data to status register in flash

?L_Check_TXIF_3:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF_3;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF_3;	
	
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash

?L_Check_Busy_2:								// Wait untill sector has been erased successfully (about 1 to 3 seconds)
	R1 = C_Watchdog_Clear;
    [P_Watchdog_Clear] = R1;
	call F_SPI1_Read_Status_Register;
	test R1, C_Flash_Busy;
	jnz ?L_Check_Busy_2;	

L_Exit?:
	pop R1, R2 from [SP];
	retf;
	.endp	
	
//****************************************************************
// Function    : F_SPI1_Flash_Write_Enable
// Description : Enable flash to be written or erased
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Flash_Write_Enable:	.proc
	push r1 to [sp];
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_Write_Enable;
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;	

	nop;
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	pop r1 from [sp];
	retf;
	.endp	
		
//****************************************************************
// Function    : F_SPI1_Flash_QPI_Enable
// Description : Enable flash to QPI Mode
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Flash_QPI_Enable:	.proc
	push r1 to [sp];
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_QPI_Enable;
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;	

	nop;
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	pop r1 from [sp];
	retf;
	.endp

//****************************************************************
// Function    : F_SPI1_Flash_QPI_Disable
// Description : Disable flash to QPI Mode
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
F_SPI1_Flash_QPI_Disable:		.proc
	push r1 to [sp];
	clrb [P_IOC_Buffer], C_SPI_CS_IO;		// enable SPI Flash
	R1 = C_SPI_Flash_QPI_Disable;
	[P_SPI_TX_Data] = R1;

?L_Check_TXIF:
	R1 = [P_SPI_Misc];						// Wait untill command has been transmitted.
	test R1, C_SPI_Busy_Flag;
	jnz ?L_Check_TXIF;
	test R1, C_SPI_RX_NonEmpty_Flag
	jz ?L_Check_TXIF;	

	nop;
	R1 = [P_SPI_RX_Data];					// Clear dummy data in RX FIFO
	
	setb [P_IOC_Buffer], C_SPI_CS_IO;		// disable SPI Flash
	pop r1 from [sp];
	retf;
	.endp
	
//****************************************************************
// Function    : 
// Description : 
// Destory     : None
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************	
F_IntBootCodeChecksumCheck:	.proc
	R1 = 0
	R2 = 0x4400
	R3 = 0
	R4 = 0
L_ChecksumLoop?:
	R3 += [R2++]
	R4 += 0, CARRY
	cmp R2, 0x47F8
	jne L_ChecksumLoop?
	cmp R3, [0x47F8]	
	jne L_CheckSumFail?
	cmp R4, [0x47F9]	
L_CheckSumPass?:	
	jne L_CheckSumFail?
	R1 = 0x0001
L_CheckSumFail?:	
	RETF
	.endp

	
.var R_BootRDSR23
.var R_BootWRSR23
.var R_BootQEbit

T_SPIFlash_REMS:	// [Device ID[7:0]:Manufactory ID[7:0]]
	.DW 0x13C2		// GPR25L081B, GPR25L0805E, default
	.DW 0x13C8		// GD25Q80C
	.DW 0x135E		// XC25D80A
	.DW 0x131C 		// EN25Q80B
	.DW 0x1385 		// P25Q80H
	.DW 0x14C2		// GPR25L162B
	.DW 0x24C2		// GPR25L1603E
	.DW 0x14C8		// GD25Q16C
	.DW 0x145E		// XC25D16
	.DW 0x141C		// EN25QH16A
	.DW 0x140B		// XT25F16B
	.DW 0x15C2 		// GPR25L322B, GPR25L3203F
	.DW 0x15C8		// GD25Q32C
	.DW 0x1520		// XM25QH32B
	.DW 0x151C		// EN25QH32A
	.DW 0x16C2 		// GPR25L642B, GPR25L6403F
	.DW 0x16C8		// GD25Q64C
	.DW 0x1620		// XM25QH64A
	.DW 0x161C		// EN25QH64A
	.DW 0x17C2 		// GPR25L12805F, KH25L12833F
	.DW 0x17C8 		// GD25Q127C
	.DW 0x1720		// XM25QH128A
	.DW 0x171C		// EN25QH128A
	.DW 0x18C2		// GPR25L25605F
	.DW 0x18C8 		// GPR25L25606F
T_SPIFlash_NoOfID:
	.DW T_SPIFlash_NoOfID - T_SPIFlash_REMS
	
T_SPIFlash_RDSR23:	// [Cmd_RDSR3[7:0]:Cmd_RDSR2[7:0]]
	.DW 0x0000		// GPR25L081B, GPR25L0805E, default
	.DW 0x0035		// GD25Q80C
	.DW 0x0000		// XC25D80A
	.DW 0x0000 		// EN25Q80B
	.DW 0x0035 		// P25Q80H
	.DW 0x0000		// GPR25L162B
	.DW 0x0000		// GPR25L1603E
	.DW 0x0035		// GD25Q16C
	.DW 0x0000		// XC25D16
	.DW 0x0000		// EN25QH16A
	.DW 0x0035		// XT25F16B
	.DW 0x0000 		// GPR25L322B, GPR25L3203F
	.DW 0x1535		// GD25Q32C
	.DW 0x1535		// XM25QH32B
	.DW 0x0009		// EN25QH32A
	.DW 0x0000 		// GPR25L642B, GPR25L6403F
	.DW 0x1535		// GD25Q64C
	.DW 0x9509		// XM25QH64A
	.DW 0x9505		// EN25QH64A
	.DW 0x0000 		// GPR25L12805F, KH25L12833F
	.DW 0x1535 		// GD25Q127C
	.DW 0x9509		// XM25QH128A
	.DW 0x9509		// EN25QH128A 
	.DW 0x0000		// GPR25L25605F
	.DW 0x1535		// GPR25L25606F
	
T_SPIFlash_WRSR23: 	// [Cmd_WRSR3[7:0]:Cmd_WRSR2[7:0]]
	.DW 0x0000		// GPR25L081B, GPR25L0805E, default
	.DW 0x0000		// GD25Q80C
	.DW 0x0000		// XC25D80A
	.DW 0x0000 		// EN25Q80B
	.DW 0x0000 		// P25Q80H
	.DW 0x0000		// GPR25L162B
	.DW 0x0000		// GPR25L1603E
	.DW 0x0000		// GD25Q16C
	.DW 0x0000		// XC25D16
	.DW 0x0000		// EN25QH16A
	.DW 0x0000		// XT25F16B
	.DW 0x0000 		// GPR25L322B, GPR25L3203F
	.DW 0x1131		// GD25Q32C
	.DW 0x1131		// XM25QH32B
	.DW 0x0000		// EN25QH32A
	.DW 0x0000 		// GPR25L642B, GPR25L6403F
	.DW 0x1131		// GD25Q64C
	.DW 0xC000		// XM25QH64A
	.DW 0xC000		// EN25QH64A
	.DW 0x0000 		// GPR25L12805F, KH25L12833F
	.DW 0x1131 		// GD25Q127C
	.DW 0xC000		// XM25QH128A
	.DW 0xC000		// EN25QH128A 
	.DW 0x0000		// GPR25L25605F
	.DW 0x1131 		// GPR25L25606F
	
T_SPIFlash_QEbit: 	// b[15] = 1 -> QE bit exist, b[7:0] = QE bit number
	.DW 0x8006		// GPR25L081B, GPR25L0805E, default
	.DW 0x8009		// GD25Q80C
	.DW 0x0000		// XC25D80A
	.DW 0x0000 		// EN25Q80B
	.DW 0x8009 		// P25Q80H
	.DW 0x0000		// GPR25L162B
	.DW 0x8006		// GPR25L1603E
	.DW 0x8009		// GD25Q16C
	.DW 0x0000		// XC25D16
	.DW 0x0000		// EN25QH16A
	.DW 0x8009		// XT25F16B
	.DW 0x8006 		// GPR25L322B, GPR25L3203F
	.DW 0x8009		// GD25Q32C
	.DW 0x8009		// XM25QH32B
	.DW 0x0000		// EN25QH32A
	.DW 0x8006 		// GPR25L642B, GPR25L6403F
	.DW 0x8009		// GD25Q64C
	.DW 0x0000		// XM25QH64A
	.DW 0x0000		// EN25QH64A
	.DW 0x8006 		// GPR25L12805F, KH25L12833F
	.DW 0x8009 		// GD25Q127C
	.DW 0x0000		// XM25QH128A
	.DW 0x0000		// EN25QH128A 
	.DW 0x8006		// GPR25L25605F
	.DW 0x8006 		// GPR25L25606F 
	

.CODE	
T_Calibration:
	.DW 0xFFFF
	.DW 0x0000
	.DW 0xAA55
	.DW 0x55AA	
	.DW 0xFF00
	.DW 0x00FF
	.DW 0x0FF0
	.DW 0xF00F	



_unSP_StartUp: .PROC
		//call F_Cache_Enable
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
		
		[R_RDSR23] = R8
		[R_WRSR23] = R9
		[R_QEbit] = R10
	
		ds = SEG __sn_init_table
        sp = OFFSET __sn_init_table
        r1 = D:[sp++]     // item count
        r5 = ds 
        r8 = r5 //backup __sn_init_table data section
        jmp __judge_itcount
__next_item:
		r5 = r8
		ds = r5
        r2 = D:[sp++]     // dest address (RAM)
        r5 = D:[sp++]     // DS of src address (ROM)
        r9 = r5	
        r3 = D:[sp++]     // src address (ROM)
        r4 = D:[sp++]     // block size
        r4 = r4 + r2
        r5 = ds
        r8 = r5
        r5 = r9
        ds = r5
        jmp __judge_bksize
__move_data:
        bp = DS:[r3++]
        [r2++] = bp
__judge_bksize:
        cmp r2, r4
        jne __move_data
        r1 = r1 - 1
__judge_itcount:
        cmp r1, 0
        jne __next_item
__no_item:
        sp = __sn_sp_val
        call _main
__sn_loop2:
        jmp __sn_loop2
__sn_loop: 
        reti


        .ENDP		


//-------------------------//
//---User Do not change----//
 .DW 0x5067, 0x4174, 0x0147//	
 .DW 0x1503, 0x0100		   //	
 .DW 0x0000, 0x0002		   //	
 .DW 0x01CF, 0x0000		   //	
 //------------------------//

.DEBUG
    .DW '.stabs "__sn_main:F15",36,0,0,', 0, 0
    .DW offset _main,seg _main
    .DW 0x0d,0x0a
.DEBUG
    .DW '.stabs "__sn_end:F15",36,0,0,', 0, 0
    .DW offset __sn_loop2,seg __sn_loop2
    .DW 0x0d,0x0a   
.DEBUG
    .DW '.stabs "__sn_exception:F15",36,0,0,', 0, 0
    .DW offset __sn_loop,seg __sn_loop
    .DW 0x0d,0x0a
.END

