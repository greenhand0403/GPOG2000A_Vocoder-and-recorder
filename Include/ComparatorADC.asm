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

//**************************************************************************
// Variable Publication Area
//**************************************************************************
.public R_ADCValue
.public R_ADCKeyRaw
.public _R_ADCKeyRaw

//**************************************************************************
// Function Call Publication Area
//**************************************************************************
.public  _CMPADC_Init
.public F_CMPADC_Init
.public  _ISR_Service_CMPADC_ADC
.public F_ISR_Service_CMPADC_ADC
.public  _ISR_Service_CMPADC_TMR
.public F_ISR_Service_CMPADC_TMR
.public _CMPADC_IOA7Key_Init
.public F_CMPADC_IOA7Key_Init
//**************************************************************************
// RAM Definition Area
//**************************************************************************
.RAM
.var R_ADCValue
.var R_DCValue
.var R_LPValue
.var R_BackUpINTAddr
.var R_BackUpINTBank
.var R_Count
.var R_ADCKeyRaw

.define _R_ADCKeyRaw R_ADCKeyRaw
//**************************************************************************
// CODE Definition Area
//**************************************************************************
.CODE

//****************************************************************
// Function    : F_CMPADC_Init
// Description : Hardware initilazation for Comparator ADC
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _CMPADC_Init:	.proc
F_CMPADC_Init:
	IRQ OFF;
	
	//CMPADC - Manual mode
	R1 = C_CMPADC_INN_PGAO | C_CMPADC_Discharge_Enable | C_CMPADC_SH_8us | C_CMPADC_Hysteresis_Enable | C_CMPADC_IBIAS_70uA | C_CMPADC_Enable;
	[P_CMPADC_Ctrl0] = R1;
	R1 = C_CMPADC_Auto_Enable | C_CMPADC_CMPO_None | C_CMPADC_TMA | C_CMPADC_Start;
	[P_CMPADC_Ctrl1] = R1;
	R1 = C_CMPADC_INT_Flag;
	[P_CMPADC_Status] = R1;
	R1 = C_PGA_Enable | C_PGAO_None | C_PGA_SH_Enable | C_PGA_42dB;
	[P_PGA_Ctrl] = R1;
   
   	R1 = [P_INT_Ctrl]
    R1 |= C_IRQ3_ADC | C_IRQ0_TMA;
	[P_INT_Ctrl] = R1;
	
	R1 = [P_FIQ_Sel];
	R1 |= C_IRQ0_TMA;
	[P_FIQ_Sel] = R1;
	
	R1 = 0x8000;
	[R_DCValue] = R1;
	
	call F_Move_CMPADC_ISR_ToRAM;
	
	IRQ ON;
	FIQ ON;
	retf;
	.endp
//****************************************************************
// Function    : F_CMPADC_IOA7Key_Init
// Description : Init CMPADC for IOA7 ADC key, raw DC voltage reading
// Destroy     : R1
// Parameter   : None
// Return      : None
//****************************************************************
_CMPADC_IOA7Key_Init: .proc
F_CMPADC_IOA7Key_Init:
	IRQ OFF;
	// CMPADC 使用 TimerA 触发采样，这里参考 EnvDet_HW_Init_ 的 TimerA 配置
	R1 = C_Timer_Setting_16K;
	[P_TimerA_Data] = R1;

	R1 = [P_Timer_Ctrl];
	R1 |= C_TimerA_SYSCLK;
	[P_Timer_Ctrl] = R1;

	[P_TimerA_CNTR] = R1;
	// IOA7 = CMPADC INN4
	// 注意：如果 C_CMPADC_INN4 名字编译不过，需要去 GPCE36_CE5.inc 查真实宏名
	R1 = C_CMPADC_INN_IOA7 | C_CMPADC_Discharge_Enable | C_CMPADC_SH_8us | C_CMPADC_Hysteresis_Enable | C_CMPADC_IBIAS_70uA | C_CMPADC_Enable;
	[P_CMPADC_Ctrl0] = R1;

	R1 = C_CMPADC_Auto_Enable | C_CMPADC_CMPO_None | C_CMPADC_TMA | C_CMPADC_Start;
	[P_CMPADC_Ctrl1] = R1;

	R1 = C_CMPADC_INT_Flag;
	[P_CMPADC_Status] = R1;

	// IOA7 ADC 按键不需要 PGA，先关闭 PGA，避免麦克风链路影响
	// R1 = 0x0000;
	// [P_PGA_Ctrl] = R1;

	R1 = [P_INT_Ctrl];
	R1 |= C_IRQ3_ADC | C_IRQ0_TMA;
	[P_INT_Ctrl] = R1;

	R1 = [P_FIQ_Sel];
	R1 |= C_IRQ0_TMA;
	[P_FIQ_Sel] = R1;

	// 保持原有 ISR 搬运逻辑
	call F_Move_CMPADC_ISR_ToRAM;

	IRQ ON;
	FIQ ON;
	retf;
	.endp
//****************************************************************
// Function    : Move_SACM_PCM_ISR_ToRAM
// Description : 
// Destory     : 
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _Move_CMPADC_ISR_ToRAM:	.proc
F_Move_CMPADC_ISR_ToRAM:	
	push R1, R5 to [SP]
	R1 = 0x0800
	R2 = L_CMPADC_ISR_RAMCode_End - L_CMPADC_ISR_RAMCode_Str
	R3 = 0x0001
	R4 = 0x2680
	
	DS = R3
L_MoveCodeLoop?:	
	R3 = D:[R4++]
	[R1++] = R3
	R2 -= 1
	jne L_MoveCodeLoop?
			
	pop R1, R5 from [SP]
	retf
	.endp
	
CMPADC_ISR_RAMCode_SEC:	.SECTION 	.CODE	
L_CMPADC_ISR_RAMCode_Str:	
.public F_CMPADC_INT
F_CMPADC_INT:	.proc	
	push R1, R5 to [SP]
	call F_ISR_Service_CMPADC_ADC
	
	R1 = C_CMPADC_INT_Flag | C_CMPADC_Timeout_Flag;
	[P_CMPADC_Status] = R1;		
	
	pop R1, R5 from [SP]
	reti
	.endp
	
//****************************************************************
// Function    : F_ISR_Service_CMPADC_ADC
// Description : 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _ISR_Service_CMPADC_ADC:	.proc
F_ISR_Service_CMPADC_ADC:
	push R1, R5 to [SP];
	tstb [P_CMPADC_Ctrl1], 7;				// P_CMPADC_Ctrl1[7] : CMPADC Auto Mode
	jnz ?L_AutoMode;
	setb [P_CMPADC_Ctrl0], 7;				// P_CMPADC_Ctrl0[7] : Discharge Enable
?L_AutoMode:

	R4 = [P_CMPADC_Data];	
	[R_ADCKeyRaw] = R4;        // 新增：保存 CMPADC 原始值，给 IOA7 ADC 按键使用
	R4 = R4 lsl 4;
		
	//DC = 15/16 * DC + 1/16 * Data		//alpha = 0.93
	R1 = [R_DCValue];
	R2 = R1 lsr 4;					
	R1 = R1 - R2;					//R1 = 15/16 * DC
	R3 = R4 lsr 4;					//R3 = 1/16 * Data
	
	R1 += R3;
	[R_DCValue] = R1;
	cmp R4, R1;
	jae ?L_Limit_Overflow;
?L_Limit_Underflow:
	R4 -= R1;
	jmi ?L_SignData;
	R4 = 0x8000;
	jmp ?L_SignData;
?L_Limit_Overflow:
	R4 -= R1;
	jpl ?L_SignData;
	R4 = 0x7FF0;	
?L_SignData:		
	[R_ADCValue] = R4;
	
	pop R1, R5 from [SP];
	retf;
	.endp

//****************************************************************
// Function    : F_ISR_Service_CMPADC_TMR
// Description : 
// Destory     : R1
// Parameter   : None
// Return      : None
// Note        : None
//****************************************************************
 _ISR_Service_CMPADC_TMR:	.proc
F_ISR_Service_CMPADC_TMR:
	tstb [P_CMPADC_Ctrl1], 7;				// P_CMPADC_Ctrl1[7] : CMPADC Auto Mode
	jnz ?L_AutoMode;
	clrb [P_CMPADC_Ctrl0], 7;				// P_CMPADC_Ctrl0[7] : Discharge Enable
?L_AutoMode:
	retf;
	.endp

L_CMPADC_ISR_RAMCode_End:

