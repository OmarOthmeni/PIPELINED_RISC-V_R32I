-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 17, 2025
-- File         : branching_unit.vhd
-- Description  : Checks if a jump/branch must be performed.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity branching_unit is
    port(
        opcode          : in std_logic_vector(6 downto 0);
        jump            : in std_logic;
        branch          : in BRANCH_TYPE_t;
        alu_result      : in std_logic_vector(31 downto 0);
        alu_zero_flag   : in std_logic;
        
        next_pc_sel     : out PC_NEXT_SRC_t
    );
end branching_unit;

architecture Behavioral of branching_unit is
begin

    next_pc_sel <=  PC_NEXT_SRC_PC_ALU_RES      when    (jump = '1' and opcode = INSTR_OPCODE_JALR)                   else
                    PC_NEXT_SRC_PC_IMM          when    (jump = '1' and opcode = INSTR_OPCODE_JAL)
                                                        or (branch = BRANCH_TYPE_BEQ and alu_zero_flag = '1')
                                                        or (branch = BRANCH_TYPE_BNE and alu_zero_flag = '0')
                                                        or (branch = BRANCH_TYPE_BLT and alu_result = x"00000001")
                                                        or (branch = BRANCH_TYPE_BGE and alu_result = x"00000000")    else
                    PC_NEXT_SRC_PC_4;


end Behavioral;
