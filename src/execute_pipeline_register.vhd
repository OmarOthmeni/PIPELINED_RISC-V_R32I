-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 24, 2025
-- File         : execute_pipeline_register.vhd

-- Description  :   Pipeline register for the Execute stage output.
--                  The reset is asynchronous.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity execute_pipeline_register is
    port(
        rst                 : in std_logic;
        clk                 : in std_logic;
        imm_in              : in std_logic_vector(31 downto 0);
        rs2_in              : in std_logic_vector(31 downto 0);
        alu_result_in       : in std_logic_vector(31 downto 0);
        mem_write_in        : in std_logic;
        mem_width_access_in : in MEM_ACCESS_WIDTH_t;
        opcode_in           : in std_logic_vector(6 downto 0);
        funct3_in           : in std_logic_vector(2 downto 0);
        rd_src_in           : in RD_DATA_SOURCE_t;
        write_rd_in         : in std_logic;
        rd_sel_in           : in std_logic_vector(4 downto 0);
        pc_imm_in           : in std_logic_vector(31 downto 0);
        pc_4_in             : in std_logic_vector(31 downto 0);
        
        imm_out              : out std_logic_vector(31 downto 0);
        rs2_out              : out std_logic_vector(31 downto 0);
        alu_result_out       : out std_logic_vector(31 downto 0);
        mem_write_out        : out std_logic;
        mem_width_access_out : out MEM_ACCESS_WIDTH_t;
        opcode_out           : out std_logic_vector(6 downto 0);
        funct3_out           : out std_logic_vector(2 downto 0);
        rd_src_out           : out RD_DATA_SOURCE_t;
        write_rd_out         : out std_logic;
        rd_sel_out           : out std_logic_vector(4 downto 0);
        pc_imm_out           : out std_logic_vector(31 downto 0);
        pc_4_out             : out std_logic_vector(31 downto 0)
    );
end execute_pipeline_register;

architecture Behavioral of execute_pipeline_register is

begin

    process(clk, rst)
    begin
    
        if rst = '1' then
        
            write_rd_out <= '0';
            mem_write_out <= '0';
            
        elsif rising_edge(clk) then

                imm_out                 <= imm_in;
                rs2_out                 <= rs2_in;
                alu_result_out          <= alu_result_in;
                mem_write_out           <= mem_write_in;
                mem_width_access_out    <= mem_width_access_in;
                opcode_out              <= opcode_in;
                funct3_out              <= funct3_in;
                rd_src_out              <= rd_src_in;
                write_rd_out            <= write_rd_in;
                rd_sel_out              <= rd_sel_in;
                pc_imm_out              <= pc_imm_in;
                pc_4_out                <= pc_4_in;
            
        end if;
        
    end process;


end Behavioral;
