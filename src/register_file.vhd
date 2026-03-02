-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 21, 2025
-- File         : register_file.vhd

-- Description  :   RISC-V internal registers x0 to x31.
--                  The module contains two read ports and one write port.
--                  Readings are asynchronous: at any time the outputs follow the input selection indexes.
--                  The write port is synchronous: writings occur only on clock falling edges.
--                  Falling edges are chosen to avoid some data hazards in the pipeline.
--
--                  x0 is hardwired to 0, it will always read 0 and any writing to it is discarded.
--
--                  The reset signal rst is asynchronous and clears all the registers to 0.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_package.all;


entity register_file is
    port(
        rst          : in std_logic;
        clk          : in std_logic;
        rs1_select   : in std_logic_vector(4 downto 0);
        rs2_select   : in std_logic_vector(4 downto 0);
        rd_select    : in std_logic_vector(4 downto 0);
        rd_data      : in std_logic_vector(31 downto 0);
        write_rd     : in std_logic;
        
        rs1          : out std_logic_vector(31 downto 0);
        rs2          : out std_logic_vector(31 downto 0)
    );
end register_file;


architecture Behavioral of register_file is
    type REGISTER_ARRAY_t is array(0 to 31) of std_logic_vector(31 downto 0);
    signal registers : REGISTER_ARRAY_t;
    signal rs1_index : integer := 0;
    signal rs2_index : integer := 0;
    signal rd_index  : integer := 0;
    
begin

    rs1_index <= to_integer(unsigned(rs1_select));
    rs2_index <= to_integer(unsigned(rs2_select));
    rd_index  <= to_integer(unsigned(rd_select));
    
    rs1 <= (others => '0') when rs1_index = 0 else registers(rs1_index);
    rs2 <= (others => '0') when rs2_index = 0 else registers(rs2_index);
        
    
    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif falling_edge(clk) then
            if(write_rd = '1') and (rd_index /= 0) then
                registers(rd_index) <= rd_data;
            end if;
        end if;
    end process;

end Behavioral;
