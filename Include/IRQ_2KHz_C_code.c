//==========================================================================
// File Name   : IRQ_2KHz_C_code.c
// Description : 
// Written by  : 
// Last modified date:
//              2025/01/10
// Note: 
//==========================================================================
//**************************************************************************
// Header File Included Area
//**************************************************************************
#include "GPCE36_CE5.h"


//**************************************************************************
// Contant Defintion Area
//**************************************************************************



//**************************************************************************
// External Function Declaration
//**************************************************************************


//**************************************************************************
// Global Variable Defintion Area
//**************************************************************************
unsigned ms_tick = 0;
unsigned ms_counter = 100;

//****************************************************************
// Function    : IRQ_2KHz_Init
// Description : Hardware initilazation for IRQ 2KHz
// Note        : None
//****************************************************************
void IRQ_2KHz_Init(void)
{
	unsigned  I_Temp;
	
	__asm("IRQ OFF");
	I_Temp = *P_INT2_Ctrl;
	I_Temp |= C_IRQ6_2048Hz;
	*P_INT2_Ctrl = I_Temp;
	
	Move_IRQ_2KHz_ISRCcode_ToRAM();
	Move_IRQ_2KHz_ASMISR_ToRAM();
	
	__asm("IRQ ON");	
	
}

////****************************************************************
//// Function    : Move_IRQ_2KHz_ISRCcode_ToRAM
//// Description : 
//// Destory     : 
//// Parameter   : None
//// Return      : None
//// Note        : None
////****************************************************************
// IRQ_2KHz_RAM_ADDR and IRQ_2KHz_RAM_SIZE 
// Search for "IRQ_2KHz_RAMCode_SEC" and specify the RAM Startting Address, and size
// now manually set in the linker file, so this should be correct!
#define IRQ_2KHz_RAM_ADDR 0x1026E
#define IRQ_2KHz_RAM_SIZE 0x30 
#define IRQ_2KHz_RAM_DESTINATION (0xC86)

void Move_IRQ_2KHz_ISRCcode_ToRAM(void)
{
	unsigned *l_ROMptr,*l_RAMptr;
	unsigned i;
	
	l_ROMptr = (unsigned *)IRQ_2KHz_RAM_ADDR;
	l_RAMptr = (unsigned *)IRQ_2KHz_RAM_DESTINATION;
	for(i=0;i<IRQ_2KHz_RAM_SIZE;i++)
	{
		l_RAMptr[i] = l_ROMptr[i];
	}
	
	
}


/* IRQ_2KHz*/
// need a large chunk of RAM not containing application data that
// needs to survive the IRQ_2KHz
__asm__("IRQ_2KHz_RAMCode_SEC: .section .code");
void __attribute__((section(".IRQ_2KHz_RAMCode_SEC")))IRQ_2KHz_RAMCode(void)
{
	////user add ISR Service code here	
	////	
	__asm("invb [0x3005], 3");
	
	///tt user code
	ms_tick++;
	if (ms_tick >= 2)
	{
		
		ms_tick = 0;

		if(ms_counter)
		{
			ms_counter--;
		}

	}
}



////****************************************************************
//// Function    : ISR_Service_IRQ_2KHz
//// Description : 
//// Destory     : R1
//// Parameter   : None
//// Return      : None
//// Note        : None
////****************************************************************
void ISR_Service_IRQ_2KHz(void)
{
	////user add ISR Service code  here
	////
	__asm("invb [0x3005], 3");
	
	///tt user code
	ms_tick++;
	if (ms_tick >= 2)
	{
		
		ms_tick = 0;

		if(ms_counter)
		{
			ms_counter--;
		}

	}
		
}








