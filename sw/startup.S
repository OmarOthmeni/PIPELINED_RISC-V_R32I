/* interrupt vectors table */
.section .iv_table
_iv_table:
    jal x0, Reset_Handler
    jal x0, Default_Handler


.section .text
    .globl Reset_Handler
    .type Reset_Handler, @function

Reset_Handler:

/* init the stack pointer sp and the global pointer gp */
.option push
.option norelax
    la sp, _StackTop
    la gp, _global_pointer_init
.option pop

/* init bss and sbss to 0 */
    la t0, _sbss
    la t1, _ebss

bss_loop:
    bge t0, t1, bss_init_ok
    sw x0, 0(t0)
    addi t0, t0, 4
    j bss_loop

bss_init_ok:
/* init data and sdata with their init values */
    la t0, _load_data
    la t1, _sdata
    la t2, _edata

data_loop:
    bge t1, t2, main_entry
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j data_loop


main_entry:
    call main


/* infinite loop if main ever returns */
spin:
    j spin

    ret



/* interrupt default handler : do nothing, just spin */
    .type Default_Handler, @function
Default_Handler:
    j Default_Handler
    ret
