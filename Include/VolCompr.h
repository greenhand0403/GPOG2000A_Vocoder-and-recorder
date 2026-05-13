//==========================================================================
// File Name   : VolCompr.h
// Description : Volume compressor APIs declaration
// Written by  : Benjamin Xu
// Last modified date:
//              2021/03/23
//==========================================================================

extern void VolCompressInitial(void);
extern void SetVolCompressLevel(unsigned int ComprFactor);
int VolCompressProcess(int DACRawData);
