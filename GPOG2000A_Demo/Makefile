#####################################################################
#																	 
#	Created by u'nSP IDE V4.1.1		17:20:51	06/04/26
#
#####################################################################




COMPILEDATE = %date:~0,4%%date:~5,2%%date:~8,2%

COMPILEDATE_ = %date:~0,4%-%date:~5,2%-%date:~8,2%

COMPILETIME = %time:~0,2%%time:~3,2%%time:~6,2%

PRJDIR	= D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo

APPDIR	= D:\zwc\app\unSPIDE

USERDIR	= C:\Users\Admin\AppData\Roaming\Generalplus\unSPIDE

OUTDIR	= .\Debug

MK	= $(APPDIR)\make

CC	= "$(APPDIR)\toolchain\udocc"

AS	= "$(APPDIR)\toolchain\xasm16"

LD	= "$(APPDIR)\toolchain\xlink16_GPCE3"

LDIRAM0	= "$(APPDIR)\toolchain\xlink16_GPCE3_IRAM0"

AR	= "$(APPDIR)\toolchain\xlib16"

RESC	= "$(APPDIR)\toolchain\resc"

RM	= del	/F	1>NUL	2>NUL

STRIP	= "$(APPDIR)\toolchain\stripper"

S37STRIP	= "$(APPDIR)\toolchain\BinaryFileStripper"

RD	= rd /S /Q

GETCHKSUM	= "$(APPDIR)\toolchain\GetChecksum"

HDBPACKER	= "$(APPDIR)\toolchain\HDBPacker"

BOOTPACKER	= "$(APPDIR)\toolchain\BootPacker" 

LIKMODIFIER	= "$(APPDIR)\toolchain\unSP_LIKModifier" 

INCLUDES	= -I"D:/zwc/app/unSPIDE/Example/DemoCode/GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28/GPOG2000A_Demo" -I"D:/zwc/app/unSPIDE/library/include" -I"D:/zwc/app/unSPIDE/library/include/sys" -I"../Include" -I"../Library"

BODY	= -body GPOG2000A -nobdy -bfile "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\GPOG2000A_Demo.bdy"

BODYFILE	= "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\GPOG2000A_Demo.bdy" 

BINFILE	= "$(OUTDIR)\GPOG2000A_Demo.TSK"

PRJNAME = GPOG2000A_Demo

BODYNAME = GPOG2000A

SWTOOLID = 0x0008

IDEBUILDVER = 0x04010100

BINFILENOEXT	= $(OUTDIR)\GPOG2000A_Demo

ARYFILE	= "$(OUTDIR)\GPOG2000A_Demo.ary"

SBMFILE	= "$(OUTDIR)\GPOG2000A_Demo.sbm"

PKINFOFILE	= "$(BINFILENOEXT).pki"

OPT	= -S -gstabs -Wall -mnonb_data -mglobal-var-ram -mISA=2.0

ASFLAGS	= -t4 -d -sr -Wno-A2013

CASFLAGS	= -t4 -sr -Wno-A2013 -wpop

CFLAGS	= $(OPT) -B$(APPDIR)\toolchain\ $(INCLUDES) 

BINTYPE	= -at

LDFLAGS	= -Wno-L0062 -Wno-L0064 -Wno-L0066 -blank 0x00 -initdata -infblk "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\GPOG2000A_Demo.inb" -conf "D:\zwc\app\unSPIDE\Body\GPCE5\Checksum\GPCE5.cks"

EXTRAFLAGS	= 


OBJFILES	= \
	"$(OUTDIR)\didi_a18.res" \
	"$(OUTDIR)\Resource.obj" \
	"$(OUTDIR)\main.obj" \
	"$(OUTDIR)\isr.obj" \
	"$(OUTDIR)\system.obj" \
	"$(OUTDIR)\BootCode_User.obj" \
	"$(OUTDIR)\SACM_DVR1800_User.obj" \
	"$(OUTDIR)\SPI_Flash.obj" \
	"$(OUTDIR)\SACM_A1800_fptr_User.obj" \
	"$(OUTDIR)\VolCompress_User.obj" \
	"$(OUTDIR)\ORAM_Arrangement.obj" \
	"$(OUTDIR)\ComparatorADC.obj" \
	"$(OUTDIR)\CTS_User.obj" \
	"$(OUTDIR)\TouchProbe_User.obj" \
	"$(OUTDIR)\EnvDet_User.obj" \
	"$(OUTDIR)\SACM_VC4_User.obj" 

"$(OUTDIR)\didi_a18.res": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\voice\didi.a18"
	$(RESC) "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\voice\didi.a18" "$(OUTDIR)\didi_a18.res" RES_DIDI_A18 

"$(OUTDIR)\Resource.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\Resource.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\Resource.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\Resource.asm" 

"$(OUTDIR)\main.asm": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\main.c" 
	set PATH="$(APPDIR)\toolchain\";%PATH% & \
	$(CC) $(CFLAGS) -o "$(OUTDIR)\main.asm" "D:/zwc/app/unSPIDE/Example/DemoCode/GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28/GPOG2000A_Demo/main.c" 

"$(OUTDIR)\main.obj": "$(OUTDIR)\main.asm"
	$(AS) $(CASFLAGS) $(INCLUDES) -o "$(OUTDIR)\main.obj" "$(OUTDIR)\main.asm" 

"$(OUTDIR)\isr.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\isr.asm" ".\GPCE36_CE5.inc" ".\GPCE36_CE5_Body.inc" "..\Include\EnvDet.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\isr.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\isr.asm" 

"$(OUTDIR)\system.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\system.asm" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\system.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\system.asm" 

"$(OUTDIR)\BootCode_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\BootCode_User.asm" ".\GPCE36_CE5.inc" ".\GPCE36_CE5_Body.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\BootCode_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\BootCode_User.asm" 

"$(OUTDIR)\SACM_DVR1800_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_DVR1800_User.asm" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\DVR1800.inc" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SACM_DVR1800_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_DVR1800_User.asm" 

"$(OUTDIR)\SPI_Flash.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\SPI_Flash.asm" ".\GPCE36_CE5.inc" ".\GPCE36_CE5_Body.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SPI_Flash.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\GPOG2000A_Demo\SPI_Flash.asm" 

"$(OUTDIR)\SACM_A1800_fptr_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_A1800_fptr_User.asm" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\A1800_fptr.inc" "GPCE36_CE5.inc" "Resource.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SACM_A1800_fptr_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_A1800_fptr_User.asm" 

"$(OUTDIR)\VolCompress_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\VolCompress_User.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\VolCompress_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\VolCompress_User.asm" 

"$(OUTDIR)\ORAM_Arrangement.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\ORAM_Arrangement.asm" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\ORAM_Arrangement.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\ORAM_Arrangement.asm" 

"$(OUTDIR)\ComparatorADC.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\ComparatorADC.asm" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\ComparatorADC.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\ComparatorADC.asm" 

"$(OUTDIR)\CTS_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\CTS_User.asm" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\CTS_Sensor.inc" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\Touch_Probe.inc" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\TP_Command.inc" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\CTS_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\CTS_User.asm" 

"$(OUTDIR)\TouchProbe_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\TouchProbe_User.asm" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\TouchProbe_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\TouchProbe_User.asm" 

"$(OUTDIR)\EnvDet_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\EnvDet_User.asm" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\EnvDet_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\EnvDet_User.asm" 

"$(OUTDIR)\SACM_VC4_User.obj": "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_VC4_User.asm" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\VC4.inc" "GPCE36_CE5.inc" 
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\SACM_VC4_User.obj" "D:\zwc\app\unSPIDE\Example\DemoCode\GPOG2000A_DVR1800_VC4_EnvDet_PWMorDACOut_2025.08.28\Include\SACM_VC4_User.asm" 


GEN_BOOTPACKER_INFO :
	@echo TagAlgorithm=0x0001 >> "$(OUTDIR)\BootpackerIni.ini"
	@echo BodyName="$(BODYNAME)" >> "$(OUTDIR)\BootpackerIni.ini"
	@echo SWToolID=$(SWTOOLID) >> "$(OUTDIR)\BootpackerIni.ini"
	@echo IDEVersion=$(IDEBUILDVER) >> "$(OUTDIR)\BootpackerIni.ini"
	@echo BuildDate="$(COMPILEDATE)" >> "$(OUTDIR)\BootpackerIni.ini"
	@echo BuildTime="$(COMPILETIME)" >> "$(OUTDIR)\BootpackerIni.ini"

GEN_HDB :
	@echo [Config] > $(PKINFOFILE)
	@echo IDEVersion=$(IDEBUILDVER) >> $(PKINFOFILE)
	@echo SWToolID=$(SWTOOLID) >> $(PKINFOFILE)
	@echo BodyName=$(BODYNAME) >> $(PKINFOFILE)
	@echo TSKFile=$(BINFILE) >> $(PKINFOFILE)
	@echo LODFile="$(BINFILENOEXT).lod" >> $(PKINFOFILE)
	@if exist "$(BINFILENOEXT)_SPI.bin" @echo SPIFile="$(BINFILENOEXT)_SPI.bin" >> $(PKINFOFILE)
	@echo HDBFile="$(BINFILENOEXT).hdb" >> $(PKINFOFILE)
	$(HDBPACKER) -p -conf $(PKINFOFILE)
	@if exist $(BINFILE) del $(BINFILE)

.SUFFIXES : .c .asm .obj .s37 .tsk .res

all :	 BEFOREBUILD "$(OUTDIR)" GEN_BOOTPACKER_INFO $(BINFILE) GEN_HDB

BEFOREBUILD :

"$(OUTDIR)" :
	@if not exist "$(OUTDIR)\$(NULL)" mkdir "$(OUTDIR)"

$(BINFILE) : $(OBJFILES) 
	$(LD) $(BINTYPE) $(ARYFILE) "$(BINFILENOEXT)_SPI.bin" -tskMaxUsed $(LDFLAGS) $(BODY) $(EXTRAFLAGS) -exportvalues "$(OUTDIR)\BootpackerIni.ini" -bootrominfo "BootCode_SEC;0100;BootCode_SEC_EX" -undefined-opt __TgP190708CM -undefined-opt __TgP190708CL -undefined-opt __TgP190708M
	@copy "$(BINFILENOEXT)_SPI.bin" $(BINFILE) /A /Y > NUL
	$(BOOTPACKER) "$(OUTDIR)\BootpackerIni.ini"
	@if exist "$(BINFILENOEXT)_SPI.bin" del "$(BINFILENOEXT)_SPI.bin"
	@copy "$(BINFILENOEXT)_SPI.bintmp" "$(BINFILENOEXT)_SPI.bin" /A /Y > NUL
	@if exist "$(BINFILENOEXT)_SPI.bintmp" del "$(BINFILENOEXT)_SPI.bintmp"
	$(STRIP) "$(BINFILENOEXT)_SPI.bin" "$(BINFILENOEXT)_SPI.bin" 0x10000 0 1 

compile :	 $(OBJFILES)

CLEANFILES = \
	"$(OUTDIR)\didi_a18.res" \
	"$(OUTDIR)\Resource.obj" \
	"$(OUTDIR)\Resource.lst" \
	"$(OUTDIR)\main.obj" \
	"$(OUTDIR)\main.lst" \
	"$(OUTDIR)\main.asm" \
	"$(OUTDIR)\isr.obj" \
	"$(OUTDIR)\isr.lst" \
	"$(OUTDIR)\system.obj" \
	"$(OUTDIR)\system.lst" \
	"$(OUTDIR)\BootCode_User.obj" \
	"$(OUTDIR)\BootCode_User.lst" \
	"$(OUTDIR)\SACM_DVR1800_User.obj" \
	"$(OUTDIR)\SACM_DVR1800_User.lst" \
	"$(OUTDIR)\SPI_Flash.obj" \
	"$(OUTDIR)\SPI_Flash.lst" \
	"$(OUTDIR)\SACM_A1800_fptr_User.obj" \
	"$(OUTDIR)\SACM_A1800_fptr_User.lst" \
	"$(OUTDIR)\VolCompress_User.obj" \
	"$(OUTDIR)\VolCompress_User.lst" \
	"$(OUTDIR)\ORAM_Arrangement.obj" \
	"$(OUTDIR)\ORAM_Arrangement.lst" \
	"$(OUTDIR)\ComparatorADC.obj" \
	"$(OUTDIR)\ComparatorADC.lst" \
	"$(OUTDIR)\CTS_User.obj" \
	"$(OUTDIR)\CTS_User.lst" \
	"$(OUTDIR)\TouchProbe_User.obj" \
	"$(OUTDIR)\TouchProbe_User.lst" \
	"$(OUTDIR)\EnvDet_User.obj" \
	"$(OUTDIR)\EnvDet_User.lst" \
	"$(OUTDIR)\SACM_VC4_User.obj" \
	"$(OUTDIR)\SACM_VC4_User.lst" \
	"$(BINFILENOEXT).s37" \
	"$(BINFILENOEXT).tsk" \
	"$(BINFILENOEXT)_SPI.bin*" \
	"$(BINFILENOEXT).hdb" \
	"$(BINFILENOEXT).lod" \
	"$(BINFILENOEXT).map" \
	"$(BINFILENOEXT).sbm" \
	"$(BINFILENOEXT).sym" \
	"$(BINFILENOEXT).smy" \
	$(PKINFOFILE) \
	$(SBMFILE)

clean :
	$(RM) $(wordlist 1,44,$(CLEANFILES))

.c.asm:
	$(CC) $(CFLAGS) $(INCLUDES) -o "$(OUTDIR)\$@" $<

.asm.obj:
	$(AS) $(ASFLAGS) $(INCLUDES) -o "$(OUTDIR)\$@" $<

