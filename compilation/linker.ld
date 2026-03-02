__stack_min_size    = 128; /* in bytes */

ENTRY(Reset_Handler)

MEMORY
{
    INSTR_MEMORY (rx) : ORIGIN = 0x00000000,                          LENGTH = 1024
    DATA_ROM     (r)  : ORIGIN = 0x00FC8000,                          LENGTH = 256
    DATA_RAM     (rw) : ORIGIN = ORIGIN(DATA_ROM)+LENGTH(DATA_ROM),   LENGTH = 512
}

SECTIONS
{
    .text :
    {
        _text = .;
        KEEP(*(.iv_table))
        . = _text + 8;    /* 2 interrupt handlers = 8 bytes */

        *(.text)
    } > INSTR_MEMORY
    
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)         /* .rodata section (constants, strings, etc.) */
        *(.srodata) 
        . = ALIGN(4);
    } > DATA_ROM


    .data :
    {
        . = ALIGN(4);
        _global_pointer_init = . + 0x800;
        _sdata = .;
        *(.data)
        *(.sdata)
        . = ALIGN(4);
        _edata = .;
    } > DATA_RAM AT > DATA_ROM
    _load_data = LOADADDR(.data);

    .bss (NOLOAD):
    {
        . = ALIGN(4);
        _sbss = .;
        *(.sbss)
        *(.bss)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > DATA_RAM


    _StackTop = ORIGIN(DATA_RAM) + LENGTH(DATA_RAM);
    _StackSize = _StackTop - _ebss;

    ASSERT(_StackSize >= __stack_min_size, "DATA_RAM overflowed with stack")
}
                        