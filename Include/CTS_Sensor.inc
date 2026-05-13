//==========================================================================
// File Name   : CTS_Sensor.inc
// Description : Touch Sensor Library API declaration
// Written by  : Ray Cheng
// Last modified date:
//              2012/10/24
//==========================================================================
.ifndef __CTS_Sensor_INC__
.define __CTS_Sensor_INC__

.external  _CTS_Initial
.external F_CTS_Initial
.external  _CTS_Scan
.external F_CTS_Scan
.external  _CTS_ScanStop
.external F_CTS_ScanStop
.external  _CTS_SetSchmittHigh
.external F_CTS_SetSchmittHigh
.external  _CTS_SetSchmittLow
.external F_CTS_SetSchmittLow
.external  _CTS_ServiceLoop
.external F_CTS_ServiceLoop
.external  _ISR_Service_CTS
.external F_ISR_Service_CTS
.external  _CTS_GetResult
.external F_CTS_GetResult
.external  _CTS_FilterSetting
.external F_CTS_FilterSetting

.endif
//========================================================================================        
// End of Touch.inc
//========================================================================================