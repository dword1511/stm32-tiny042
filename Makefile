# Makefile for stm32-tiny042
# * Override toochain: make CROSS=/path/to/arm-none-eabi
# * Add additional CFLAGS, such as pre-processor macros: make EXTRA_CFLAGS=-DSOME_SWITCH

###############################################################################

PROGRAM     = stm32-tiny042-blinky
CROSS      ?= arm-none-eabi
OBJS        = blinky.o

###############################################################################

CC          = $(CROSS)-gcc
LD          = $(CROSS)-ld
OBJCOPY     = $(CROSS)-objcopy
OBJDUMP     = $(CROSS)-objdump
SIZE        = $(CROSS)-size

ELF         = $(PROGRAM).elf
BIN         = $(PROGRAM).bin
HEX         = $(PROGRAM).hex
MAP         = $(PROGRAM).map
DMP         = $(PROGRAM).out

ARCH_FLAGS  = -DSTM32F0 -mthumb -mcpu=cortex-m0 -msoft-float
LDSCRIPT    = libopencm3/lib/stm32/f0/stm32f04xz6.ld
LIBOPENCM3  = libopencm3/lib/libopencm3_stm32f0.a
OPENCM3_MK  = lib/stm32/f0

CFLAGS     += -O3 -Wall -g
CFLAGS     += -fno-common -ffunction-sections -fdata-sections
CFLAGS     += $(ARCH_FLAGS) -Ilibopencm3/include/ $(EXTRA_CFLAGS)

LIBM        = $(shell $(CC) $(CFLAGS) --print-file-name=libm.a)
LIBC        = $(shell $(CC) $(CFLAGS) --print-file-name=libc.a)
LIBNOSYS    = $(shell $(CC) $(CFLAGS) --print-file-name=libnosys.a)
LIBGCC      = $(shell $(CC) $(CFLAGS) --print-libgcc-file-name)

# LDPATH is required for libopencm3 ld scripts to work.
LDPATH      = libopencm3/lib/
LDFLAGS    += -L$(LDPATH) -T$(LDSCRIPT) -Map $(MAP) --gc-sections
LDLIBS     += $(LIBOPENCM3) $(LIBC) $(LIBNOSYS) $(LIBGCC)

all: $(LIBOPENCM3) $(BIN) $(HEX) $(DMP) size

$(ELF): $(LDSCRIPT) $(OBJS)
	$(LD) -o $@ $(LDFLAGS) $(OBJS) $(LDLIBS)

$(DMP): $(ELF)
	$(OBJDUMP) -d $< > $@

%.hex: %.elf
	$(OBJCOPY) -S -O ihex   $< $@

%.bin: %.elf
	$(OBJCOPY) -S -O binary $< $@

%.o: %.c board.h
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBOPENCM3):
	git submodule init
	git submodule update --remote
	CFLAGS="$(CFLAGS)" make -C libopencm3 $(OPENCM3_MK) V=1

dfu-util/Makefile:
	git submodule init
	git submodule update --remote
	cd dfu-util; ./autogen.sh && ./configure; cd ..

dfu-util/src/dfu-util: dfu-util/Makefile
	make -C dfu-util


.PHONY: clean distclean flash size

clean:
	rm -f $(OBJS) $(DOCS) $(ELF) $(HEX) $(BIN) $(MAP) $(DMP) board.h

distclean: clean
	make -C libopencm3 clean
	rm -f *~ *.swp *.hex

flash: $(BIN) dfu-util/src/dfu-util
	dfu-util/src/dfu-util -a 0 -d 0483:df11 -s 0x08000000:leave -D $(BIN)

size: $(PROGRAM).elf
	@echo ""
	@$(SIZE) $(PROGRAM).elf
	@echo ""
