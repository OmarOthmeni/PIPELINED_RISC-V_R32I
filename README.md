# PIPELINED_RISC-V_RV32I
A simple but effective VHDL implementation of the RISC-V RV32I (Unprivileged) ISA.

The CPU is implemented in a Harvard architecture (separated instructions and data memories). It uses a 5-stage pipeline (fetch, decode, execute, memory access, write-back).

![cpu_diagram](image.png)

There is no branch-prediction unit, the CPU always assume that the branch will not be taken. If the branch is actually taken, the CPU flushes the pipeline.

Interrupts are not handled. FENCE, ECALL and EBREAK instructions are not implemented.

The CPU can detect unaligned/invalid/unimplemented instructions. This feature can be used to implement a generic invalid-instruction trap/interrupt.
However, the CPU does not handle these instructions. Such instructions will lead to undefined behavior.



The CPU has been tested in simulation.


Synthesis has not been tested, some adjustments may be required to make it synthesizable.


A startup file, a linker script and a Makefile are provided to compile code that can be run on this CPU. You can write your own code in the `main.c` file.
To use this code in simulation, set your toolchain path in the Makefile and compile:
```
make
```

Then, convert the binary output files to text files (Python required):
```
python convert_bin_to_txt.py
```

Finally, copy and paste the content of the two text files (`./compilation/bin/instr.txt` and `./compilation/bin/rodata.txt`) in `./src/memory_package.vhd`. These four values have to be configured:
- `INSTRUCTION_MEMORY_SIZE_BYTES`
- `INSTRUCTION_MEMORY_CONTENT`
- `DATA_ROM_MEMORY_SIZE_BYTES`
- `DATA_ROM_MEMORY_CONTENT`

