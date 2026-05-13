//==========================================================================
// File Name   : SPI_Flash.inc
// Description : Access SPI Flash APIs declaration
// Written by  : Ray Cheng
// Last modified date:
//              2017/07/19
//==========================================================================
.ifndef __SPI_FLASH_INC__
.define __SPI_FLASH_INC__

.external  _SPI_Initial
.external F_SPI_Initial
.external  _SPI_ReadAWord
.external F_SPI_ReadAWord
.external  _SPI_ReadNWords
.external F_SPI_ReadNWords
.external  _SPI_SendAWord
.external F_SPI_SendAWord
.external  _SPI_SendNWords
.external F_SPI_SendNWords
.external  _SPI_Read_Status_Register
.external F_SPI_Read_Status_Register
.external  _SPI_Read_Status_Register3
.external F_SPI_Read_Status_Register3
.external  _SPI_Write_Status_Register
.external F_SPI_Write_Status_Register
.external  _SPI_Write_Status_Register3
.external F_SPI_Write_Status_Register3
.external  _SPI_Flash_Block_Erase
.external F_SPI_Flash_Block_Erase
.external  _SPI_Flash_Sector_Erase
.external F_SPI_Flash_Sector_Erase
.external  _SPI_Flash_Chip_Erase
.external F_SPI_Flash_Chip_Erase
.external  _SPI_Read_Flash_ID
.external F_SPI_Read_Flash_ID
.external  _SPI_Read_Flash_REMS
.external F_SPI_Read_Flash_REMS
.external _SPI_DeepPowerDown
.external F_SPI_DeepPowerDown
.external _SPI_ReleaseDeepPowerDown
.external F_SPI_ReleaseDeepPowerDown

.external   _SPI_Flash_Initial
.external  F_SPI_Flash_Initial
.external   _SPI1_ManualMode
.external  F_SPI1_ManualMode
.external 	_SPI1_AutoMode
.external  F_SPI1_AutoMode
.external  _SPI_Flash_ReadAWord
.external F_SPI_Flash_ReadAWord
.external  _SPI_Flash_ReadNWords
.external F_SPI_Flash_ReadNWords
.external  _SPI_Flash_Read_Status_Register
.external F_SPI_Flash_Read_Status_Register
.external  _SPI_Flash_Read_Status_Reg3
.external F_SPI_Flash_Read_Status_Reg3
.external  _SPI_Flash_Write_Status_Register
.external F_SPI_Flash_Write_Status_Register
.external  _SPI_Flash_Write_Status_Reg3
.external F_SPI_Flash_Write_Status_Reg3
.external  _SPI_Flash_Read_Configuration_Register
.external F_SPI_Flash_Read_Configuration_Register
.external  _SPI_Flash_DeepPowerDown	
.external F_SPI_Flash_DeepPowerDown
.external  _SPI_Flash_ReleaseDeepPowerDown	
.external F_SPI_Flash_ReleaseDeepPowerDown
.external  _SPI1_Flash_AutoMode_Initial
.external F_SPI1_Flash_AutoMode_Initial
.endif
