-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 4, 2025
-- File         : data_memory.vhd

-- Description  :   Data memory : wrapper for both the data ram and data rom memories.
--                  The input address is absolute (byte-address in the whole memory map).


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_package.all;
use work.memory_package.all;


entity data_memory is
    port(
        clk                 : in std_logic;
        addr                : in std_logic_vector(31 downto 0);
        mem_write_enable    : in std_logic;
        access_width        : in MEM_ACCESS_WIDTH_t;
        data_in             : in std_logic_vector(31 downto 0);
        
        data_out            : out std_logic_vector(31 downto 0)
    );
end data_memory;



architecture Behavioral of data_memory is
    signal data_out_ram_signal  : std_logic_vector(31 downto 0);
    signal data_out_rom_signal  : std_logic_vector(31 downto 0);
    signal addr_relative        : std_logic_vector(31 downto 0);

begin

    addr_relative <= std_logic_vector(unsigned(addr) - to_unsigned(DATA_RAM_BASE_ADDRESS, addr'length))
                        when unsigned(addr) >= to_unsigned(DATA_RAM_BASE_ADDRESS, addr'length)
                        else
                     std_logic_vector(unsigned(addr) - to_unsigned(DATA_MEMORY_BASE_ADDRESS, addr'length));

    data_ram : entity work.data_ram(Behavioral)
        port map(
            clk => clk,
            addr => addr_relative,
            access_width => access_width,
            write_enable => mem_write_enable,
            data_in => data_in,
            
            data_out => data_out_ram_signal
        );
        
        
    data_rom : entity work.data_rom(Behavioral)
        port map(
            addr => addr_relative,
            access_width => access_width,
            
            data => data_out_rom_signal
        );
        
        
    data_out <= data_out_ram_signal when unsigned(addr) >= to_unsigned(DATA_RAM_BASE_ADDRESS, addr'length) else data_out_rom_signal;


end Behavioral;
