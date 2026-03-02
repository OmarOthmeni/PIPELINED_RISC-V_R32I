-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 24, 2025
-- File         : fetch_pipeline_register.vhd

-- Description  :   Pipeline register for the Fetch stage output.
--                  The reset is asynchronous, the flush is synchronous.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity fetch_pipeline_register is
    port(
        rst            : in std_logic;
        clk            : in std_logic;
        stall          : in std_logic;
        flush          : in std_logic;
        instr_in       : in std_logic_vector(31 downto 0);
        pc_in          : in std_logic_vector(31 downto 0);
        pc_4_in        : in std_logic_vector(31 downto 0);
        
        instr_out       : out std_logic_vector(31 downto 0);
        pc_out          : out std_logic_vector(31 downto 0);
        pc_4_out        : out std_logic_vector(31 downto 0)
    );
end fetch_pipeline_register;



architecture Behavioral of fetch_pipeline_register is
begin

    process(clk, rst)
    begin
    
        if rst = '1' then
            instr_out <= INSTR_NOP;
        elsif rising_edge(clk) then
            if flush = '1' then
                instr_out <= INSTR_NOP;
            elsif stall = '0' then
                instr_out   <= instr_in;
                pc_out      <= pc_in;
                pc_4_out    <= pc_4_in;
            end if;
            
        end if;
        
    end process;



end Behavioral;
