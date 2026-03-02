AS 			= ./xpack-riscv-none-elf-gcc-14.2.0-1/bin/riscv-none-elf-as.exe
LD 			= ./xpack-riscv-none-elf-gcc-14.2.0-1/bin/riscv-none-elf-ld.exe
GCC 		= ./xpack-riscv-none-elf-gcc-14.2.0-1/bin/riscv-none-elf-gcc.exe
OBJCOPY = ./xpack-riscv-none-elf-gcc-14.2.0-1/bin/riscv-none-elf-objcopy.exe
OBJDUMP = ./xpack-riscv-none-elf-gcc-14.2.0-1/bin/riscv-none-elf-objdump.exe

AFLAGS = -march=rv32i -mabi=ilp32
CFLAGS = -nostartfiles -nostdlib -nodefaultlibs -march=rv32i -mabi=ilp32 -mstrict-align
LFLAGS =

all : main.c startup.S
ifeq ($(wildcard ./bin),)
	mkdir -p ./bin
endif
	$(AS) startup.s -o ./bin/startup.o $(AFLAGS)
	$(GCC) -c main.c -o ./bin/main.o $(CFLAGS)
	$(LD) ./bin/main.o ./bin/startup.o -o ./bin/main.elf -T linker.ld $(LFLAGS)
	$(OBJCOPY) -O binary -j .text ./bin/main.elf ./bin/instr.bin
	$(OBJCOPY) -O binary -j .rodata -j .data ./bin/main.elf ./bin/rodata.bin
	$(OBJDUMP) -D -M no-aliases ./bin/main.elf > ./bin/main.dasm


clean:
	rm -rf ./bin
