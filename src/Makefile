# Run:
#  make GPL=1 to build a pure GPL version (without stdlib)
#  make CAS=1 to build with GMP/MPFR/MAY
# If you change the build options, don't forget to do a 'make clean' before
PREOS=../../preos/
PREOS_SRC=$(PREOS)/src
PREOS_STDLIB=$(PREOS)/stdlib.9xz
GPL=
CAS=
CHECK=
ASSERT=

##############################################################################

FLASH_OS_BSS_START=0x5B00

DEFS=
OPTIONAL_PACKAGES=
ifeq	($(GPL),1)
DEFS+= -WA,-vGPL
endif
ifeq	($(ASSERT),1)
DEFS+= -WA,-vWANT_ASSERT
endif
ifeq	($(CAS),1)
DEFS+= -WA,-vUSE_MAIN_PROGRAM -WA,-vUSE_GPL3
OPTIONAL_PACKAGES=lib/t-ihm.o lib/libmay.a lib/libmpfr.a lib/libgmp.a
endif
ifeq	($(CHECK),GMP)
DEFS+= -WA,-vUSE_MAIN_PROGRAM -WA,-vUSE_GPL3
OPTIONAL_PACKAGES=lib/test-gmp.o lib/libtests-gmp.a  lib/libmay.a lib/libmpfr.a lib/libgmp.a
endif
ifeq	($(CHECK),MPFR)
DEFS+= -WA,-vUSE_MAIN_PROGRAM -WA,-vINCREASE_STACK_SIZE  -WA,-vUSE_GPL3
OPTIONAL_PACKAGES=lib/test-mpfr.o lib/libtests-mpfr.a lib/libmay.a lib/libmpfr.a lib/libgmp.a
endif
ifeq	($(CHECK),IEEE754)
DEFS+= -WA,-vUSE_MAIN_PROGRAM  -WA,-vUSE_GPL3
OPTIONAL_PACKAGES=lib/tst-ieee754.o lib/libmay.a lib/libmpfr.a lib/libgmp.a
endif

##############################################################################

LDFLAGS=--cut-ranges --optimize-code --remove-unused --optimize-relocs --merge-constants
CFLAGS=-Os -fomit-frame-pointer -Wall -W -fno-builtin
INCLUDES=-I. -Ic

S2ASM=../bin/s2asm
CC=tigcc $(LDFLAGS)
AS=tigcc -c $(LDFLAGS) -WA,-ic -WA,-i$(PREOS_SRC) $(DEFS)
LD=../bin/ld-tigcc/ld-tigcc -v --flash-os --flash-os-bss-start=$(FLASH_OS_BSS_START) --outputbin $(LDFLAGS) ../bin/flashos/flashos.a
STRIP=../bin/strip
MV=mv -f
CP=cp -f

##############################################################################

# Define the source files
ST1_ASM=Boot.asm Flash.asm System.asm ShellIO.asm Builtin.asm Link.asm Strings.asm Vat.asm Memstr.asm Heap.asm Graph.asm Misc.asm
TEXT_ASM=Bcd.asm Estack2.asm Script.asm Estack.asm Ints.asm Long.asm Vectors.asm Cert.asm Kernel.asm Process.asm Window.asm Dialog.asm Library.asm  Misc2.asm RomVoid.asm Strings.asm Bss.asm unpack.asm
SOURCE_ASM=PedroM.asm PedroM2.asm Bss.asm
SOURCE_C=c/files.c c/printf.c c/clipline.c c/bitmap.c c/qsort.c c/md5.c c/float.c c/ellipse.c c/side.c

SOURCE=$(patsubst %.c,%.asm,$(SOURCE_C))

OBJ89=$(patsubst %.asm,%.89.o,$(SOURCE_ASM)) $(patsubst %.c,%.89.o,$(SOURCE_C))
OBJ9x=$(patsubst %.asm,%.9x.o,$(SOURCE_ASM)) $(patsubst %.c,%.9x.o,$(SOURCE_C))
OBJV2=$(patsubst %.asm,%.v2.o,$(SOURCE_ASM)) $(patsubst %.c,%.v2.o,$(SOURCE_C))
OBJ89T=$(patsubst %.asm,%.89t.o,$(SOURCE_ASM)) $(patsubst %.c,%.89t.o,$(SOURCE_C))

##############################################################################

# Rules to build for different calculator
%.89.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -DPEDROM -DTI89 -c $< -o $@
%.89.o: %.asm
	$(AS) -WA,-vTI89 $< -o $@
%.9x.o: %.asm
	$(AS) -WA,-vTI92P $< -o $@
%.9x.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -DPEDROM -DTI92P -c $< -o $@
%.v2.o: %.asm
	$(AS) -WA,-vV200 $< -o $@
%.v2.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -DPEDROM -DTI92P -c $< -o $@
%.89t.o: %.asm
	$(AS) -WA,-vTI89TI $< -o $@
%.89t.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -DPEDROM -DTI89  -c $< -o $@

##############################################################################

# Define the default targets.
all: pedrom-89 pedrom-9x pedrom-89t pedrom-v200

# Define the targets which are always to be done.
.PHONY: version.h clean lib/t-pika.o  lib/t-ihm.o $(OPTIONAL_PACKAGES) tools

# Define the tool rules
tools:
	cd ../bin && make

# Define the dependency of PedroM.asm / PedroM2.asm
PedroM.asm: version.h $(ST1_ASM)
	@touch $@
PedroM2.asm: stdlib.bin $(TEXT_ASM)
	@touch $@

# Generate stdlib.bin
ifeq	($(GPL),1)
stdlib.bin:
	touch stdlib.bin
else
$(PREOS_STDLIB): 
	cd $(PREOS) && make # Far from perfect
stdlib.bin: $(PREOS_STDLIB) tools
	$(STRIP) $(PREOS_STDLIB) stdlib.bin
endif

# Generate the current time into an assembly file
version.h:
	echo " dc.b" \"`date -u +"[%Y%m%d %k:%M]"`\" > version.h

# Recursive dependency (libgmp.a / libmpfr.a / libmay.a are also done via this build)
lib/t-pika.o:
	cd lib && make t-pika.o
lib/t-ihm.o:
	cd lib && make t-ihm.o
lib/test-gmp.o:
	cd lib && make test-gmp.o
lib/test-mpfr.o:
	cd lib && make test-mpfr.o

##############################################################################

# TIB rules
pedrom-89: $(OBJ89) $(OPTIONAL_PACKAGES) tools
	$(LD) $^ -o PedroM 
	$(MV) PedroM-89.tib ..
pedrom-9x: $(OBJ9x) $(OPTIONAL_PACKAGES) tools 
	$(LD) $^ -o PedroM
	$(MV) PedroM-9x.tib ..
pedrom-89t: $(OBJ89T) $(OPTIONAL_PACKAGES) tools 
	$(LD) $^ -o PedroM
	$(MV) PedroM-89ti.tib .. && $(RM) PedroM-89.tib
pedrom-v200: $(OBJV2) $(OPTIONAL_PACKAGES) tools 
	$(LD) $^ -o PedroM
	$(MV) PedroM-v2.tib ..

# Clean up
clean:
	$(RM) c/*.asm c/*~ c/*.o version.h *.o *~ *.tib *.lst
	$(RM) stdlib.bin
	cd lib && make clean
	cd ../bin && make clean
