/* RV32I instruction test for the pipelined core.
 *
 * Each TEST_* macro checks one instruction against a hand-computed result.
 * On the first mismatch the test number is written to `tohost` as
 * (n << 1) | 1 and the program stops; if everything passes, 1 is written.
 * The self-checking testbench (tb/tb_cpu_selfcheck.vhd) watches that store.
 */

#define TESTNUM gp_testnum

/* register-register:  rd = rs1 op rs2 */
#define TEST_RR(n, op, a, b, exp) \
    li  x31, n;        \
    li  x1, a;         \
    li  x2, b;         \
    op  x3, x1, x2;    \
    li  x4, exp;       \
    bne x3, x4, fail;

/* register-immediate: rd = rs1 op imm */
#define TEST_RI(n, op, a, imm, exp) \
    li  x31, n;        \
    li  x1, a;         \
    op  x3, x1, imm;   \
    li  x4, exp;       \
    bne x3, x4, fail;

/* branch: must be taken (taken=1) or not taken (taken=0) */
#define TEST_BR(n, op, a, b, taken) \
    li  x31, n;        \
    li  x1, a;         \
    li  x2, b;         \
    li  x5, 0;         \
    op  x1, x2, 1f;    \
    li  x5, 1;         \
1:  li  x4, (1 - taken); \
    bne x5, x4, fail;

    .text
    .globl main
main:
    /* ---------------- arithmetic ---------------- */
    TEST_RR( 1, add,  13, 29, 42)
    TEST_RR( 2, add,  0x7fffffff, 1, 0x80000000)          /* wrap-around */
    TEST_RR( 3, sub,  10, 25, -15)
    TEST_RI( 4, addi, -5, 7, 2)
    TEST_RI( 5, addi, 0, -2048, -2048)

    /* ---------------- logic ---------------- */
    TEST_RR( 6, and,  0xff00ff00, 0x0ff00ff0, 0x0f000f00)
    TEST_RR( 7, or,   0xff00ff00, 0x0ff00ff0, 0xfff0fff0)
    TEST_RR( 8, xor,  0xff00ff00, 0x0ff00ff0, 0xf0f0f0f0)
    TEST_RI( 9, andi, 0x12345678, 0x0ff, 0x78)
    TEST_RI(10, ori,  0x12345600, 0x0ab, 0x123456ab)
    TEST_RI(11, xori, 0x0000000f, -1, 0xfffffff0)

    /* ---------------- shifts ---------------- */
    TEST_RI(12, slli, 1, 31, 0x80000000)
    TEST_RI(13, srli, 0x80000000, 31, 1)
    TEST_RI(14, srai, 0x80000000, 31, -1)
    TEST_RR(15, sll,  1, 4, 16)
    TEST_RR(16, sll,  1, 33, 2)            /* only rs2[4:0] is used: 33 -> 1 */
    TEST_RR(17, srl,  0x80000000, 0xffffffe1, 0x40000000)  /* shamt = 1 */
    TEST_RR(18, sra,  -256, 4, -16)

    /* ---------------- compares ---------------- */
    TEST_RR(19, slt,  -1, 1, 1)
    TEST_RR(20, sltu, -1, 1, 0)            /* 0xffffffff > 1 unsigned */
    TEST_RI(21, slti, 5, 6, 1)
    TEST_RI(22, sltiu, 5, -1, 1)           /* imm sign-extends to 0xffffffff */

    /* ---------------- upper immediates ---------------- */
    li   x31, 23
    lui  x3, 0x12345
    li   x4, 0x12345000
    bne  x3, x4, fail

    li   x31, 24
1:  auipc x3, 0
    la   x4, 1b
    bne  x3, x4, fail

    /* ---------------- branches ---------------- */
    TEST_BR(25, beq,  7, 7, 1)
    TEST_BR(26, beq,  7, 8, 0)
    TEST_BR(27, bne,  7, 8, 1)
    TEST_BR(28, blt,  -3, 2, 1)
    TEST_BR(29, bge,  2, -3, 1)
    TEST_BR(30, bltu, 2, -3, 1)            /* -3 is huge unsigned */
    TEST_BR(31, bgeu, 2, -3, 0)

    /* ---------------- jumps ---------------- */
    li   x31, 32
    jal  x6, 2f
3:  j    fail                              /* must be skipped */
2:  la   x4, 3b
    bne  x6, x4, fail                      /* link register = pc + 4 */

    li   x31, 33
    la   x7, 4f
    jalr x6, 0(x7)
    j    fail
4:

    /* ---------------- loads / stores ---------------- */
    la   x10, scratch
    li   x1, 0x80f07f81
    sw   x1, 0(x10)

    li   x31, 34
    lw   x3, 0(x10)
    bne  x3, x1, fail
    li   x31, 35
    lb   x3, 0(x10)                        /* 0x81 -> sign-extended */
    li   x4, 0xffffff81
    bne  x3, x4, fail
    li   x31, 36
    lbu  x3, 0(x10)
    li   x4, 0x81
    bne  x3, x4, fail
    li   x31, 37
    lh   x3, 2(x10)                        /* 0x80f0 -> sign-extended */
    li   x4, 0xffff80f0
    bne  x3, x4, fail
    li   x31, 38
    lhu  x3, 2(x10)
    li   x4, 0x80f0
    bne  x3, x4, fail

    li   x31, 39
    li   x1, 0xaa
    sb   x1, 1(x10)                        /* byte store keeps the other bytes */
    lw   x3, 0(x10)
    li   x4, 0x80f0aa81
    bne  x3, x4, fail
    li   x31, 40
    li   x1, 0x1234
    sh   x1, 2(x10)
    lw   x3, 0(x10)
    li   x4, 0x1234aa81
    bne  x3, x4, fail

    /* ---------------- data hazards ---------------- */
    li   x31, 41                           /* back-to-back forwarding chain */
    li   x1, 1
    add  x2, x1, x1
    add  x3, x2, x2
    add  x3, x3, x2
    li   x4, 6
    bne  x3, x4, fail

    li   x31, 42                           /* load-use hazard (needs a stall) */
    li   x1, 1000
    sw   x1, 4(x10)
    lw   x2, 4(x10)
    addi x3, x2, 1
    li   x4, 1001
    bne  x3, x4, fail

    li   x31, 43                           /* store data forwarded from the previous instruction */
    li   x1, 77
    addi x1, x1, 1
    sw   x1, 8(x10)
    lw   x3, 8(x10)
    li   x4, 78
    bne  x3, x4, fail

    li   x31, 44                           /* x0 stays zero */
    li   x0, 123
    bne  x0, zero, fail

    /* ---------------- all passed ---------------- */
    li   x1, 1
    la   x2, tohost
    sw   x1, 0(x2)
pass_loop:
    j    pass_loop

fail:
    slli x1, x31, 1
    ori  x1, x1, 1
    la   x2, tohost
    sw   x1, 0(x2)
fail_loop:
    j    fail_loop

    .bss
    .align 2
scratch:
    .space 16
