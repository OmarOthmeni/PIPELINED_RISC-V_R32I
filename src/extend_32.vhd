-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 10, 2025
-- File         : extend_32.vhd

-- Description  : Sign-extend the input to a 32-bit output (for LB and LH instructions only).


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity extend_32 is
    port(
        opcode                  : in std_logic_vector(6 downto 0);
        funct3                  : in std_logic_vector(2 downto 0);
        mem_data_out            : in std_logic_vector(31 downto 0);
        
        mem_data_out_extended   : out std_logic_vector(31 downto 0)
    );
end extend_32;

architecture Behavioral of extend_32 is
begin

    mem_data_out_extended <=
                             (31 downto 15 => mem_data_out(15)) & mem_data_out(14 downto 0)
                                    when opcode = INSTR_OPCODE_LOAD and funct3 = INSTR_FUNCT3_LH            else
                             (31 downto 7 => mem_data_out(7)) & mem_data_out(6 downto 0)
                                    when opcode = INSTR_OPCODE_LOAD and funct3 = INSTR_FUNCT3_LB            else
                             mem_data_out;

end Behavioral;
