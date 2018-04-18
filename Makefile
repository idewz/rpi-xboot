ARMGNU ?= arm-none-eabi

COPS = -Wall -O2 -nostartfiles -ffreestanding
LZFLAGS = -O2 -Wall -D_7ZIP_ST -nostartfiles -ffreestanding

gcc : uart.bin bootloader.bin

all : gcc

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.s

start_uart.o : start_uart.s
	$(ARMGNU)-as start_uart.s -o start_uart.o

uart.o : uart.c
	$(ARMGNU)-gcc $(COPS) -c uart.c

periph.o : periph.c
	$(ARMGNU)-gcc $(COPS) -c periph.c

uart.bin : uart.ld start_uart.o periph.o uart.o 
	$(ARMGNU)-ld start_uart.o periph.o uart.o -T uart.ld -o uart.elf
	$(ARMGNU)-objdump uart.elf -D > uart.list
	$(ARMGNU)-objcopy uart.elf -O binary uart.bin

OBJS = \
	start_bootloader.o \
	periph.o \
  Alloc.o \
  LzmaDec.o \
  7zFile.o \
  7zStream.o \
	lzma.o \
	xmodem.o \
	bootloader.o \

xmodem.o : xmodem.c
	$(ARMGNU)-gcc $(COPS) -c xmodem.c

# LZMA
lzma.o : lzma.c
	$(ARMGNU)-gcc $(COPS) -c lzma.c

7zFile.o: lib/lzma/7zFile.c
	$(ARMGNU)-gcc $(LZFLAGS) -c lib/lzma/7zFile.c

7zStream.o: lib/lzma/7zStream.c
	$(ARMGNU)-gcc $(LZFLAGS) -c lib/lzma/7zStream.c

Alloc.o: lib/lzma/Alloc.c
	$(ARMGNU)-gcc $(LZFLAGS) -c lib/lzma/Alloc.c

LzmaDec.o: lib/lzma/LzmaDec.c
	$(ARMGNU)-gcc $(LZFLAGS) -c lib/lzma/LzmaDec.c


# Boot loader
start_bootloader.o : start_bootloader.s
	$(ARMGNU)-as start_bootloader.s -o start_bootloader.o

bootloader.o : bootloader.c
	$(ARMGNU)-gcc $(COPS) -c bootloader.c

bootloader.bin : bootloader.ld $(OBJS)
	$(ARMGNU)-gcc $(COPS) -specs=nosys.specs -o bootloader.elf $(OBJS) #-Xlinker -T -Xlinker bootloader.ld
	# $(ARMGNU)-ld $(OBJS) -T bootloader.ld -o bootloader.elf
	$(ARMGNU)-objdump bootloader.elf -D > bootloader.list
	$(ARMGNU)-objcopy bootloader.elf -O binary bootloader.bin
