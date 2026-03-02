-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 24, 2025
-- File         : hazard_control_unit.vhd
-- Description  : Detects and handles data and control hazards in the pipeline.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity hazard_control_unit is
    port (
        rst         : in std_logic;
        rs1_sel_d   : in std_logic_vector(4 downto 0);
        rs2_sel_d   : in std_logic_vector(4 downto 0);
        rs1_sel_e   : in std_logic_vector(4 downto 0);
        rs2_sel_e   : in std_logic_vector(4 downto 0);
        rd_sel_e    : in std_logic_vector(4 downto 0);
        write_rd_e  : in std_logic;
        rd_src_e    : in RD_DATA_SOURCE_t;            
        next_pc_sel : in PC_NEXT_SRC_t;
        rd_sel_m    : in std_logic_vector(4 downto 0);
        write_rd_m  : in std_logic;
        rd_src_m    : in RD_DATA_SOURCE_t;
        rd_sel_wb   : in std_logic_vector(4 downto 0);
        write_rd_wb : in std_logic;
        
        stall_pc    : out std_logic;
        stall_f     : out std_logic;
        flush_f     : out std_logic;
        flush_d     : out std_logic;
        
        op1_sel     : out ALU_OP_SRC_t;
        op2_sel     : out ALU_OP_SRC_t
    );
end hazard_control_unit;



architecture Behavioral of hazard_control_unit is
        signal op_sel_signal : ALU_OP_SRC_t;
        signal stall_load    : std_logic;
        signal stall_jump    : std_logic;
            
begin

    with rd_src_m select
        op_sel_signal <=        ALU_OP_SRC_PC_IMM   when RD_DATA_SOURCE_PC_IMM,
                                ALU_OP_SRC_PC_4     when RD_DATA_SOURCE_PC_4,
                                ALU_OP_SRC_IMM      when RD_DATA_SOURCE_IMM,
                                ALU_OP_SRC_ALU_RES  when others;
                                
    op1_sel <=  op_sel_signal       when (write_rd_m = '1') and (rd_sel_m = rs1_sel_e) and (rd_sel_m /= "00000")    else
                ALU_OP_SRC_RD_DATA  when (write_rd_wb = '1') and (rd_sel_wb = rs1_sel_e) and (rd_sel_wb /= "00000") else
                ALU_OP_SRC_REG;
                
    op2_sel <=  op_sel_signal       when (write_rd_m = '1') and (rd_sel_m = rs2_sel_e) and (rd_sel_m /= "00000")    else
                ALU_OP_SRC_RD_DATA  when (write_rd_wb = '1') and (rd_sel_wb = rs2_sel_e) and (rd_sel_wb /= "00000") else
                ALU_OP_SRC_REG;
                
                                  
    stall_load <= '1' when (rd_src_e = RD_DATA_SOURCE_MEM_DATA_OUT) and (write_rd_e = '1') and (rd_sel_e /= "00000")
                            and ((rd_sel_e = rs1_sel_d) or (rd_sel_e = rs2_sel_d))
                      else '0';
                            
    stall_jump <= '1' when next_pc_sel /= PC_NEXT_SRC_PC_4 else '0';          
  
    
    stall_pc <= not rst and stall_load;
    stall_f  <= not rst and stall_load;
    flush_f  <= not rst and (not stall_load and stall_jump);
    flush_d  <= not rst and (stall_load or stall_jump);


end Behavioral;
