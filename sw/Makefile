# Build a program for the RV32I core and turn it into src/memory_package.vhd.
#
#   make PROG=examples/main.c        # C program
#   make PROG=tests/isa_test.S       # assembly test
#
# Toolchain: any bare-metal RISC-V GCC. Override the prefix if yours differs:
#   make PROG=... RISCV_PREFIX=riscv64-unknown-elf-

RISCV_PREFIX ?= riscv-none-elf-
CC      = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump
PYTHON ?= python3

PROG   ?= examples/main.c
BUILD  ?= build
NAME    = $(basename $(notdir $(PROG)))

ARCH    = -march=rv32i -mabi=ilp32
CFLAGS  = $(ARCH) -O2 -ffreestanding -nostdlib -nostartfiles -mstrict-align -Wall
LDFLAGS = -T linker.ld -Wl,--gc-sections -lgcc

.PHONY: all clean

all: $(BUILD)/$(NAME).elf
	$(OBJCOPY) -O binary -j .text $< $(BUILD)/$(NAME).instr.bin
	$(OBJCOPY) -O binary -j .rodata -j .data $< $(BUILD)/$(NAME).rodata.bin
	$(OBJDUMP) -d -M no-aliases $< > $(BUILD)/$(NAME).dasm
	$(PYTHON) ../scripts/gen_memory_package.py \
		--instr $(BUILD)/$(NAME).instr.bin \
		--rodata $(BUILD)/$(NAME).rodata.bin \
		--out ../src/memory_package.vhd

$(BUILD)/$(NAME).elf: $(PROG) startup.S linker.ld
	mkdir -p $(BUILD)
	$(CC) $(CFLAGS) startup.S $(PROG) -o $@ $(LDFLAGS)

clean:
	rm -rf $(BUILD)
