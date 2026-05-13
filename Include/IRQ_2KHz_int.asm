//*****************************************************************************/
// File Name   : ComparatorADC.asm
// Description : 
// Written by  : Jerry Hsu
// Last modified date: 2024/04/10
//*****************************************************************************/
.include GPCE36_CE5.inc

//**************************************************************************
// Contant Defintion Area
//**************************************************************************


//**************************************************************************
// External Variable Declaration
//**************************************************************************


//**************************************************************************
// External Function Declaration
//**************************************************************************
.external _IRQ_2KHz_RAMCode

//**************************************************************************
// Variable Publication Area
//**************************************************************************
//.public R_ADCValue


//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _Move_IRQ_2KHz_ASMISR_ToRAM
.public F_Move_IRQ_2KHz_ASMISR_ToRAM



//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
//.var R_LPValue
//.var R_Count

//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE

////****************************************************************
//// Function    : F_IRQ_2KHz_Init
//// Description : Hardware initilazation for IRQ 2KHz
//// Destory     : R1
//// Parameter   : None
//// Return      : None
//// Note        : None
////****************************************************************
// _IRQ_2KHz_Init:	.proc
//F_IRQ_2KHz_Init:
//	IRQ OFF;	  	  		
//	
//	R1 = [P_INT2_Ctrl];
//	R1 |= C_IRQ6_2048Hz;  
//	[P_INT2_Ctrl] = R1;
//
//	call F_Move_IRQ_2KHz_ISR_ToRAM;
//	
//	IRQ ON;
//	
//	retf;
//	.endp

//****************************************************************
// Function    : Move_IRQ_2KHz_ISR_ToRAM
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Move_IRQ_2KHz_ASMISR_ToRAM:	.proc
F_Move_IRQ_2KHz_ASMISR_ToRAM:	
	push R1, R5 to [SP]
	R1 = 0x0C76
	R2 = L_IRQ_2KHz_ISR_RAMCode_End - L_IRQ_2KHz_ISR_RAMCode_Str
	R3 = 0x0001
	R4 = 0x029A
	
	DS = R3
L_MoveCodeLoop?:	
	R3 = D:[R4++]
	[R1++] = R3
	R2 -= 1
	jne L_MoveCodeLoop?
			
	pop R1, R5 from [SP]
	retf
	.endp


	
IRQ_2KHz_ISR_ASMRAMCode_SEC:	.SECTION 	.CODE	
L_IRQ_2KHz_ISR_RAMCode_Str:	
.public F_IRQ_2KHz_INT
F_IRQ_2KHz_INT:	.proc	
	push R1, R5 to [SP]
	
	call _IRQ_2KHz_RAMCode	
	
	R1 = C_IRQ6_2048Hz;
    [P_INT2_Status] = R1;		
	
	pop R1, R5 from [SP]
	reti
	.endp


L_IRQ_2KHz_ISR_RAMCode_End:

