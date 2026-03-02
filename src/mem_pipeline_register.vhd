-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 24, 2025
-- File         : mem_pipeline_register.vhd

-- Description  :   Pipeline register for the Memory stage output.
--                  The reset is asynchronous.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity mem_pipeline_register is
    port(
        rst            : in std_logic;
        clk            : in std_logic;
        pc_imm_in      : in std_logic_vector(31 downto 0);
        pc_4_in        : in std_logic_vector(31 downto 0);
        rd_src_in      : in RD_DATA_SOURCE_t;
        write_rd_in    : in std_logic;
        rd_sel_in      : in std_logic_vector(4 downto 0);
        mem_data_in    : in std_logic_vector(31 downto 0);
        alu_result_in  : in std_logic_vector(31 downto 0);
        imm_in         : in std_logic_vector(31 downto 0);
        
        pc_imm_out      : out std_logic_vector(31 downto 0);
        pc_4_out        : out std_logic_vector(31 downto 0);
        rd_src_out      : out RD_DATA_SOURCE_t;
        write_rd_out    : out std_logic;
        rd_sel_out      : out std_logic_vector(4 downto 0);
        mem_data_out    : out std_logic_vector(31 downto 0);
        alu_result_out  : out std_logic_vector(31 downto 0);
        imm_out         : out std_logic_vector(31 downto 0)
    );
end mem_pipeline_register;



architecture Behavioral of mem_pipeline_register is
begin

    process(clk, rst)
    begin
    
        if rst = '1' then
            write_rd_out <= '0';
        elsif rising_edge(clk) then
            pc_imm_out      <= pc_imm_in;
            pc_4_out        <= pc_4_in;
            rd_src_out      <= rd_src_in;
            write_rd_out    <= write_rd_in;
            rd_sel_out      <= rd_sel_in;
            mem_data_out    <= mem_data_in;
            alu_result_out  <= alu_result_in;
            imm_out         <= imm_in;
        end if;
        
    end process;


end Behavioral;
