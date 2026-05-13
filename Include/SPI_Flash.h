//==========================================================================
// File Name   : SPI_Flash.h
// Description : Access SPI Flash APIs declaration
// Written by  : Ray Cheng
// Last modified date:
//              2017/07/19
//==========================================================================
#ifndef	__SPI_FLASH_H__
#define	__SPI_FLASH_H__

//extern void SPI_Initial(void);
extern int SPI_Initial(void);
extern void SPI1_MultiIOMode_Initial(unsigned SPI_IOMode);
//extern  unsigned SPI_ReadAWord(unsigned AddrLow, unsigned AddrHigh);
extern  unsigned SPI_ReadAWord(unsigned long Addr);
//extern  void SPI_ReadNWords(unsigned BuuferPtr, unsigned DataLength, unsigned AddrLow, unsigned AddrHigh);
extern  void SPI_ReadNWords(unsigned BuuferPtr, unsigned DataLength, unsigned long Addr);
//extern  void SPI_SendAWord(unsigned AddrLow, unsigned AddrHigh, unsigned SendData);
extern  void SPI_SendAWord(unsigned long Addr, unsigned SendData);
//extern  void SPI_SendNWords(unsigned BuuferPtr, unsigned DataLength, unsigned AddrLow, unsigned AddrHigh);
extern  void SPI_SendNWords(unsigned BuuferPtr, unsigned DataLength, unsigned long Addr);
extern  unsigned int SPI_Read_Status_Register(void);
extern  unsigned char SPI_Read_Status_Register3(void);
extern  void SPI_Write_Status_Register(unsigned StatusData);
extern  void SPI_Write_Status_Register3(unsigned char StatusData3);
extern  void SPI_Flash_Block_Erase(unsigned BlockIndex);
extern  void SPI_Flash_Sector_Erase(unsigned SectorIndex);
extern  void SPI_Flash_Chip_Erase(void);
extern  unsigned long SPI_Read_Flash_ID(void);
extern  unsigned int SPI_Read_Flash_REMS(void);
extern  void SPI_DeepPowerDown(void);
extern  int SPI_ReleaseDeepPowerDown(void);

extern int SPI_Flash_Initial(void);
extern void SPI1_ManualMode(void);
extern void SPI1_AutoMode(unsigned Mode);
extern unsigned SPI_Flash_ReadAWord(unsigned long Addr);
extern void SPI_Flash_ReadNWords(unsigned *BuuferPtr, unsigned DataLength, unsigned long Addr);
extern void SPI_Flash_SendAWord(unsigned long Addr, unsigned SendData);
extern void SPI_Flash_SendNWords(unsigned *BuuferPtr, unsigned DataLength, unsigned long Addr);
extern unsigned int SPI_Flash_Read_Status_Register(void);
extern unsigned char SPI_Flash_Read_Status_Reg3(void);
extern void SPI_Flash_Write_Status_Register(unsigned StatusData);
extern void SPI_Flash_Write_Status_Reg3(unsigned char StatusData3);
extern void SPI_Flash_DeepPowerDown(void);
extern int SPI_Flash_ReleaseDeepPowerDown(void);
extern void SPI1_Flash_AutoMode_Initial(unsigned Mode);

#endif