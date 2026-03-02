-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 24, 2025
-- File         : decode_pipeline_register.vhd

-- Description  :   Pipeline register for the Decode stage output.
--                  The reset is asynchronous, the flush is synchronous.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity decode_pipeline_register is
    port(
        rst                 : in std_logic;
        clk                 : in std_logic;
        flush               : in std_logic;
        rs1_sel_in          : in std_logic_vector(4 downto 0);
        rs2_sel_in          : in std_logic_vector(4 downto 0);
        rs1_in              : in std_logic_vector(31 downto 0);
        rs2_in              : in std_logic_vector(31 downto 0);
        imm_in              : in std_logic_vector(31 downto 0);
        alu_use_imm_in      : in std_logic;
        alu_op_type_in      : in ALU_OP_TYPE_t;
        jump_in             : in std_logic;
        branch_in           : in BRANCH_TYPE_t;
        mem_access_width_in : in MEM_ACCESS_WIDTH_t;
        mem_write_enable_in : in std_logic;
        opcode_in           : in std_logic_vector(6 downto 0);
        funct3_in           : in std_logic_vector(2 downto 0);
        rd_data_src_in      : in RD_DATA_SOURCE_t;
        rd_select_in        : in std_logic_vector(4 downto 0);
        write_rd_in         : in std_logic;                          
        pc_in               : in std_logic_vector(31 downto 0);
        pc_4_in             : in std_logic_vector(31 downto 0);


        rs1_sel_out          : out std_logic_vector(4 downto 0);
        rs2_sel_out          : out std_logic_vector(4 downto 0);
        rs1_out              : out std_logic_vector(31 downto 0);
        rs2_out              : out std_logic_vector(31 downto 0);
        imm_out              : out std_logic_vector(31 downto 0);
        alu_use_imm_out      : out std_logic;
        alu_op_type_out      : out ALU_OP_TYPE_t;
        jump_out             : out std_logic;
        branch_out           : out BRANCH_TYPE_t;
        mem_access_width_out : out MEM_ACCESS_WIDTH_t;
        mem_write_enable_out : out std_logic;
        opcode_out           : out std_logic_vector(6 downto 0);
        funct3_out           : out std_logic_vector(2 downto 0);
        rd_data_src_out      : out RD_DATA_SOURCE_t;
        rd_select_out        : out std_logic_vector(4 downto 0);
        write_rd_out         : out std_logic;                          
        pc_out               : out std_logic_vector(31 downto 0);
        pc_4_out             : out std_logic_vector(31 downto 0)

    );
end decode_pipeline_register;

architecture Behavioral of decode_pipeline_register is

begin

    process(clk, rst)
    begin
    
        if rst = '1' then
        
            jump_out                <= '0';
            branch_out              <= BRANCH_TYPE_NONE;
            mem_write_enable_out    <= '0';
            write_rd_out            <= '0';
            
        elsif rising_edge(clk) then
        
            if flush = '1' then
                jump_out                <= '0';
                branch_out              <= BRANCH_TYPE_NONE;
                mem_write_enable_out    <= '0';
                write_rd_out            <= '0';
            else
                rs1_sel_out             <= rs1_sel_in;
                rs2_sel_out             <= rs2_sel_in;
                rs1_out                 <= rs1_in;
                rs2_out                 <= rs2_in;
                imm_out                 <= imm_in;
                alu_use_imm_out         <= alu_use_imm_in;
                alu_op_type_out         <= alu_op_type_in;
                jump_out                <= jump_in;
                branch_out              <= branch_in;
                mem_access_width_out    <= mem_access_width_in;
                mem_write_enable_out    <= mem_write_enable_in;
                opcode_out              <= opcode_in;
                funct3_out              <= funct3_in;
                rd_data_src_out         <= rd_data_src_in;
                rd_select_out           <= rd_select_in;
                write_rd_out            <= write_rd_in;
                pc_out                  <= pc_in;
                pc_4_out                <= pc_4_in;
            end if;
            
        end if;
        
    end process;


end Behavioral;
