-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 21, 2025
-- File         : program_counter.vhd

-- Description  :   Update the program counter on clock rising edges.
--                  The reset is asynchronous. The reset value (RESET_HANDLER_ADDRESS) is defined in memory_package.vhd
--
--                  The "unaligned" output signal gets set when the PC value is not aligned to a 4-byte boundary.
--                  It can be used to implement an instruction-misaligned interrupt.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.memory_package.all;


entity program_counter is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        stall       : in std_logic;
        pc_next     : in std_logic_vector(31 downto 0);
        
        pc          : out std_logic_vector(31 downto 0);
        unaligned   : out std_logic
    );
end program_counter;



architecture Behavioral of program_counter is
    signal pc_signal        : std_logic_vector(31 downto 0);
    
begin
    pc <= pc_signal;
    unaligned <= pc_signal(1) or pc_signal(0);      -- 4-byte boundary
    
    process(clk, rst)
    begin
        if rst = '1' then
            pc_signal <= std_logic_vector(to_unsigned(RESET_HANDLER_ADDRESS, pc_signal'length));
        elsif rising_edge(clk) and stall = '0' then
            pc_signal <= pc_next;
        end if;
    end process;
    
end Behavioral;
