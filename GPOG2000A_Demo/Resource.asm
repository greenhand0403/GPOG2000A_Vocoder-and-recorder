
// Resource Table
// Created by IDE, Do not modify this table

.CODE
.public _RES_Table;
.public _SPI_Resources_Folder_Table;
.external __RES_TAILOR3_16K_A18_sa
.public _RES_TAILOR3_16K_A18_SA;
.external __RES_TAILOR3_16K_A18_ea;
.public _RES_TAILOR3_16K_A18_EA;
.external __RES_TK6_A18_sa
.public _RES_TK6_A18_SA;
.external __RES_TK6_A18_ea;
.public _RES_TK6_A18_EA;
.external __RES_FILEMERGER_ROM_BIN_sa
.public _RES_FILEMERGER_ROM_BIN_SA;
.external __RES_FILEMERGER_ROM_BIN_ea;
.public _RES_FILEMERGER_ROM_BIN_EA;


_RES_Table:


_SPI_Resources_Folder_Table:

_RES_TAILOR3_16K_A18_SA:
	.DW offset __RES_TAILOR3_16K_A18_sa,seg16 __RES_TAILOR3_16K_A18_sa;
_RES_TAILOR3_16K_A18_EA:
	.DW offset __RES_TAILOR3_16K_A18_ea,seg16 __RES_TAILOR3_16K_A18_ea;

_RES_TK6_A18_SA:
	.DW offset __RES_TK6_A18_sa,seg16 __RES_TK6_A18_sa;
_RES_TK6_A18_EA:
	.DW offset __RES_TK6_A18_ea,seg16 __RES_TK6_A18_ea;

_RES_FILEMERGER_ROM_BIN_SA:
	.DW offset __RES_FILEMERGER_ROM_BIN_sa,seg16 __RES_FILEMERGER_ROM_BIN_sa;
_RES_FILEMERGER_ROM_BIN_EA:
	.DW offset __RES_FILEMERGER_ROM_BIN_ea,seg16 __RES_FILEMERGER_ROM_BIN_ea;


// End Table
.public T_SACM_A1800_fptr_SpeechTable
T_SACM_A1800_fptr_SpeechTable:
	.DW offset __RES_TAILOR3_16K_A18_sa,seg16 __RES_TAILOR3_16K_A18_sa;
	.DW offset __RES_TK6_A18_sa,seg16 __RES_TK6_A18_sa;
	
.public T_SACM_VC4_SpeechTable
T_SACM_VC4_SpeechTable:
