-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : January 19, 2025
-- File         : ALU.vhd
-- Description  : Arithmetic-Logic Unit.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_package.all;


entity ALU is
    port (
        op1         : in std_logic_vector(31 downto 0);
        op2         : in std_logic_vector(31 downto 0);
        op_type     : in ALU_OP_TYPE_t;
        
        res         : out std_logic_vector(31 downto 0);    -- result
        zero_flag   : out std_logic                         -- '1' if res=0 else '0'
    );
end ALU;



architecture Behavioral of ALU is
    signal res_signal : std_logic_vector(31 downto 0);
begin

        res <= res_signal;
        zero_flag <= '1' when res_signal = x"00000000" else '0';

        res_signal <=   std_logic_vector(unsigned(op1) + unsigned(op2))     when op_type = ALU_OP_TYPE_ADD else
                        std_logic_vector(unsigned(op1) - unsigned(op2))     when op_type = ALU_OP_TYPE_SUB else
                        
                        x"00000001"     when op_type = ALU_OP_TYPE_SLT and signed(op1) < signed(op2)        else
                        x"00000001"     when op_type = ALU_OP_TYPE_SLTU and unsigned(op1) < unsigned(op2)   else
                        
                        op1 and op2     when op_type = ALU_OP_TYPE_AND      else
                        op1 or op2      when op_type = ALU_OP_TYPE_OR       else
                        op1 xor op2     when op_type = ALU_OP_TYPE_XOR      else
                          
                        std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))))    when op_type = ALU_OP_TYPE_SLL   else 
                        std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))))   when op_type = ALU_OP_TYPE_SRL   else
                        std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0)))))     when op_type = ALU_OP_TYPE_SRA   else
                        
                        (others => '0');

end Behavioral;
