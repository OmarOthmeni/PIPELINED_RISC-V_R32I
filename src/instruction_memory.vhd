-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 20, 2025
-- File         : instruction_memory.vhd

-- Description  :   Read-only memory containing the program instructions.
--                  Asynchronous module (no clock signal), outputs the 32-bit instruction stored at the given 32-bit input address.
--                  This memory uses little-endian storing. It is byte-addressable, however instructions must be aligned to 32-bit boundaries. 
--
--                  The memory is mapped from address 0x00000000 to address (INSTRUCTION_MEMORY_SIZE_BYTES-1), both included.
--                  In case of an out-of-range or unaligned access, the output reads 0xffffffff.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.memory_package.all;


entity instruction_memory is
    port(
        addr        : in std_logic_vector(31 downto 0);
        
        instr       : out std_logic_vector(31 downto 0)
    );
end instruction_memory;


architecture Behavioral of instruction_memory is
    signal memory           : INSTRUCTION_MEMORY_ARRAY_t := INSTRUCTION_MEMORY_CONTENT;
    signal word_index       : integer := 0;

begin
    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    
    instr <= 
        -- forbidding unaligned access
        (others => '1') when word_index >= INSTRUCTION_MEMORY_SIZE_WORDS or addr(1 downto 0) /= "00" else
        memory(word_index);
        
end Behavioral;