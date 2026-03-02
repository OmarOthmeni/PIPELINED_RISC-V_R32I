-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 28, 2025
-- File         : data_ram.vhd

-- Description  :   RAM part of the data memory.
--
--                  This module provides 8-bit, 16-bit and 32-bit accesses for readings as well as for writings.
--                  Readings are asynchronous, writings are synchronous and occur on clock rising edges.
--                  This memory uses little-endian storing.
--                  It is byte-addressable, however accesses must be aligned to 16-bit boundaries for halfwords and to 32-bit boundaries
--                  for words.
--
--                  The memory is mapped from address DATA_RAM_BASE_ADDRESS to address (DATA_RAM_BASE_ADDRESS+DATA_RAM_MEMORY_SIZE_BYTES-1),
--                  both included.
--                  The input address (addr signal) is relative to the memory base address (DATA_RAM_BASE_ADDRESS).
--
--                  In case of an out-of range or unaligned access, the ouput reads 0xffffffff and any writing is discarded.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_package.all;
use work.memory_package.all;


entity data_ram is
    port(
        clk             : in std_logic;
        addr            : in std_logic_vector(31 downto 0);
        access_width    : in MEM_ACCESS_WIDTH_t;
        write_enable    : in std_logic;
        data_in         : in std_logic_vector(31 downto 0);
        
        data_out        : out std_logic_vector(31 downto 0)
    );
end data_ram;


architecture Behavioral of data_ram is
    signal memory           : DATA_RAM_MEMORY_ARRAY_t;
    signal word_index       : integer := 0;
    signal halfword_index   : integer := 0;
    signal byte_index       : integer := 0;

begin

    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    halfword_index  <= to_integer(unsigned(addr(1 downto 0) and "10"));
    byte_index      <= to_integer(unsigned(addr(1 downto 0)));
    
    
    -- reading
    data_out <= 
        -- forbidding unaligned access
        (others => '1') when word_index >= DATA_RAM_MEMORY_SIZE_WORDS 
                            or (access_width = MEM_ACCESS_WIDTH_16 and addr(0) = '1')
                            or (access_width = MEM_ACCESS_WIDTH_32 and addr(1 downto 0) /= "00") else
                            
        -- 16-bit
        (31 downto 16 => '0') & memory(word_index, halfword_index+1) & memory(word_index, halfword_index)
            when access_width = MEM_ACCESS_WIDTH_16 else

        -- 32-bit
        memory(word_index, 3) & memory(word_index, 2) & memory(word_index, 1) & memory(word_index, 0)
            when access_width = MEM_ACCESS_WIDTH_32 else
            
        -- 8-bit
        (31 downto 8 => '0') & memory(word_index, byte_index);
        
        
        
    -- writing
    process(clk)
    begin
        if rising_edge(clk) then
            if(word_index < DATA_RAM_MEMORY_SIZE_WORDS) then
                case access_width is
                    when MEM_ACCESS_WIDTH_16 =>    -- 16-bit
                        -- forbidding unaligned access
                        if addr(0) = '0' and write_enable = '1' then
                                memory(word_index, halfword_index) <= data_in(7 downto 0);
                                memory(word_index, halfword_index+1) <= data_in(15 downto 8);
                        end if;
                        
                    when MEM_ACCESS_WIDTH_32 =>  -- 32-bit
                        -- forbidding unaligned access
                        if addr(1 downto 0) = "00" and write_enable = '1' then
                                memory(word_index, 0) <= data_in(7 downto 0);
                                memory(word_index, 1) <= data_in(15 downto 8);
                                memory(word_index, 2) <= data_in(23 downto 16);
                                memory(word_index, 3) <= data_in(31 downto 24);
                        end if;
                        
                    when others =>  -- 8-bit
                        if(write_enable = '1') then
                            memory(word_index, byte_index) <= data_in(7 downto 0);
                        end if;
                end case;
            end if;
        end if;
        
    end process;


end Behavioral;