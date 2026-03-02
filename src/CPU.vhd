-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : August 18, 2025
-- File         : CPU.vhd
-- Description  : CPU top level.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_package.all;

entity CPU is
    port(
        rst         : in std_logic;
        clk         : in std_logic
    );
end CPU;


architecture Behavioral of CPU is
    signal pc_f         : std_logic_vector(31 downto 0);
    signal pc_4_f       : std_logic_vector(31 downto 0);
    signal pc_next      : std_logic_vector(31 downto 0);
    signal pc_alu       : std_logic_vector(31 downto 0);
    signal pc_imm_e     : std_logic_vector(31 downto 0);
    signal next_pc_sel  : PC_NEXT_SRC_t;
    signal instr_f      : std_logic_vector(31 downto 0);
    
    signal instr_d              : std_logic_vector(31 downto 0);
    signal funct3_d             : std_logic_vector(2 downto 0);
    signal funct7               : std_logic_vector(6 downto 0);
    signal opcode_d             : std_logic_vector(6 downto 0);
    signal rs1_sel_d            : std_logic_vector(4 downto 0);
    signal rs2_sel_d            : std_logic_vector(4 downto 0);
    signal rs1_d                : std_logic_vector(31 downto 0);
    signal rs2_d                : std_logic_vector(31 downto 0);
    signal imm_d                : std_logic_vector(31 downto 0);
    signal rd_sel_d             : std_logic_vector(4 downto 0);
    signal alu_use_imm_d        : std_logic;
    signal alu_op_type_d        : ALU_OP_TYPE_t;
    signal jump_d               : std_logic;
    signal branch_type_d        : BRANCH_TYPE_t;
    signal mem_write_d          : std_logic;
    signal mem_width_access_d   : MEM_ACCESS_WIDTH_t;
    signal rd_src_d             : RD_DATA_SOURCE_t;
    signal write_rd_d           : std_logic; 
    signal pc_4_d               : std_logic_vector(31 downto 0);
    signal pc_d                 : std_logic_vector(31 downto 0);
    signal rd_sel_wb            : std_logic_vector(4 downto 0);
    signal write_rd_wb          : std_logic;
    signal rd_data              : std_logic_vector(31 downto 0);
    
    signal rs1_sel_e            : std_logic_vector(4 downto 0);
    signal rs2_sel_e            : std_logic_vector(4 downto 0);
    signal rs1_e                : std_logic_vector(31 downto 0);
    signal rs2_e                : std_logic_vector(31 downto 0);
    signal imm_e                : std_logic_vector(31 downto 0);
    signal alu_use_imm_e        : std_logic;
    signal alu_op_type_e        : ALU_OP_TYPE_t;
    signal jump_e               : std_logic;
    signal branch_type_e        : BRANCH_TYPE_t;
    signal mem_write_e          : std_logic;
    signal mem_width_access_e   : MEM_ACCESS_WIDTH_t;
    signal rd_src_e             : RD_DATA_SOURCE_t;
    signal write_rd_e           : std_logic; 
    signal rd_sel_e             : std_logic_vector(4 downto 0);
    signal opcode_e             : std_logic_vector(6 downto 0);
    signal funct3_e             : std_logic_vector(2 downto 0);
    signal pc_4_e               : std_logic_vector(31 downto 0);
    signal pc_e                 : std_logic_vector(31 downto 0);
    
    signal op1                  : std_logic_vector(31 downto 0);
    signal op2                  : std_logic_vector(31 downto 0);
    signal t_mux                : std_logic_vector(31 downto 0);
    signal alu_result_e         : std_logic_vector(31 downto 0);
    signal alu_zero_flag        : std_logic;
    
    signal rs2_m                : std_logic_vector(31 downto 0);
    signal alu_result_m         : std_logic_vector(31 downto 0);
    signal imm_m                : std_logic_vector(31 downto 0);
    signal mem_write_m          : std_logic;
    signal mem_width_access_m   : MEM_ACCESS_WIDTH_t;
    signal opcode_m             : std_logic_vector(6 downto 0);
    signal funct3_m             : std_logic_vector(2 downto 0);
    signal rd_src_m             : RD_DATA_SOURCE_t;
    signal write_rd_m           : std_logic; 
    signal rd_sel_m             : std_logic_vector(4 downto 0);
    signal pc_imm_m             : std_logic_vector(31 downto 0);
    signal pc_4_m               : std_logic_vector(31 downto 0);   
    signal t_mem                : std_logic_vector(31 downto 0);
    signal mem_data_m           : std_logic_vector(31 downto 0);
    
    signal alu_result_wb         : std_logic_vector(31 downto 0);
    signal imm_wb                : std_logic_vector(31 downto 0);
    signal mem_data_wb           : std_logic_vector(31 downto 0);
    signal pc_imm_wb             : std_logic_vector(31 downto 0);
    signal pc_4_wb               : std_logic_vector(31 downto 0);
    signal rd_src_wb             : RD_DATA_SOURCE_t;
    
    signal op1_sel      : ALU_OP_SRC_t;
    signal t_op2_mux    : ALU_OP_SRC_t;
    signal t_rs2_mux    : std_logic;
    signal flush_d      : std_logic; 
    signal stall_f      : std_logic;
    signal flush_f      : std_logic;
    signal stall_pc     : std_logic;
    
begin

     pc_4_f       <= std_logic_vector(unsigned(pc_f) + 4);
     pc_alu       <= alu_result_e(31 downto 1) & '0';
     pc_imm_e     <= std_logic_vector(unsigned(pc_e) + unsigned(imm_e));
     
     
     pc_next <=     pc_alu      when next_pc_sel = PC_NEXT_SRC_PC_ALU_RES   else
                    pc_imm_e    when next_pc_sel = PC_NEXT_SRC_PC_IMM       else
                    pc_4_f;
     
     -- program counter PC
     program_counter : entity work.program_counter(Behavioral)
        port map(
            clk => clk,
            rst => rst,
            stall => stall_pc,
            pc_next => pc_next,
            
            pc => pc_f
        );
        
        
    -- instruction memory
    instruction_memory : entity work.instruction_memory(Behavioral)
        port map(
            addr => pc_f,
            instr => instr_f
        );
        
        
    -- fetch pipeline register
    fetch_pipeline_register : entity work.fetch_pipeline_register(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            stall => stall_f,
            flush => flush_f,
            instr_in => instr_f,
            pc_in => pc_f,
            pc_4_in => pc_4_f,
            
            instr_out => instr_d,
            pc_out => pc_d,
            pc_4_out => pc_4_d
        );
        
          
     -- instruction decoder
     instruction_decoder : entity work.instruction_decoder(Behavioral)
        port map(
            instr => instr_d,
            
            opcode => opcode_d,
            funct3 => funct3_d,
            funct7 => funct7,
            rd => rd_sel_d,
            rs1 => rs1_sel_d,
            rs2 => rs2_sel_d,
            imm => imm_d
        );
        
        
     -- Control Unit
     control_unit : entity work.control_unit(Behavioral)
        port map(
            opcode => opcode_d,
            funct3 => funct3_d,
            funct7 => funct7,
            
            branch => branch_type_d,
            jump        => jump_d,     
            rd_data_src => rd_src_d,
            write_rd    => write_rd_d,
            mem_access_width => mem_width_access_d,
            mem_write_enable => mem_write_d, 
            alu_op_type => alu_op_type_d,
            alu_use_imm => alu_use_imm_d
        );
        
        
   
     -- register file
     register_file : entity work.register_file(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            rs1_select => rs1_sel_d,
            rs2_select => rs2_sel_d,
            rd_select => rd_sel_wb,
            rd_data => rd_data,
            write_rd => write_rd_wb,
            
            rs1 => rs1_d,
            rs2 => rs2_d
        );
        
        
        
    -- decode pipeline register
    decode_pipeline_register : entity work.decode_pipeline_register(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            flush => flush_d,
            rs1_sel_in => rs1_sel_d,
            rs2_sel_in => rs2_sel_d,
            rs1_in => rs1_d,
            rs2_in => rs2_d,
            imm_in => imm_d,
            alu_use_imm_in => alu_use_imm_d,
            alu_op_type_in => alu_op_type_d,
            jump_in => jump_d,
            branch_in => branch_type_d,
            mem_access_width_in => mem_width_access_d,
            mem_write_enable_in => mem_write_d,
            opcode_in => opcode_d,
            funct3_in => funct3_d,
            rd_data_src_in => rd_src_d,
            write_rd_in => write_rd_d,
            rd_select_in => rd_sel_d,
            pc_in => pc_d,
            pc_4_in => pc_4_d,
            
            rs1_sel_out => rs1_sel_e,
            rs2_sel_out => rs2_sel_e,
            rs1_out => rs1_e,
            rs2_out => rs2_e,
            imm_out => imm_e,
            alu_use_imm_out => alu_use_imm_e,
            alu_op_type_out => alu_op_type_e,
            jump_out => jump_e,
            branch_out => branch_type_e,
            mem_access_width_out => mem_width_access_e,
            mem_write_enable_out => mem_write_e,
            opcode_out => opcode_e,
            funct3_out => funct3_e,
            rd_data_src_out => rd_src_e,
            rd_select_out => rd_sel_e,
            write_rd_out => write_rd_e,
            pc_out => pc_e,
            pc_4_out => pc_4_e
        );
        
        
    -- branching_unit
    branching_unit : entity work.branching_unit(Behavioral)
        port map(
            opcode => opcode_e,
            jump => jump_e,
            branch => branch_type_e,
            alu_result => alu_result_e,
            alu_zero_flag => alu_zero_flag,
            
            next_pc_sel => next_pc_sel
        );
        
        
        
     -- ALU
     ALU : entity work.ALU(Behavioral)
        port map(
            op1 => op1,
            op2 => op2,
            op_type => alu_op_type_e,
            
            res => alu_result_e,
            zero_flag => alu_zero_flag
        );
        
        
        op2 <= imm_e when alu_use_imm_e = '1' else t_mux;
        
        with t_op2_mux select
            t_mux <=    imm_m           when ALU_OP_SRC_IMM,
                        alu_result_m    when ALU_OP_SRC_ALU_RES,
                        rd_data         when ALU_OP_SRC_RD_DATA,
                        pc_imm_m        when ALU_OP_SRC_PC_IMM,
                        pc_4_m          when ALU_OP_SRC_PC_4,
                        rs2_e           when others;
        

        with op1_sel select
            op1 <=      imm_m           when ALU_OP_SRC_IMM,
                        alu_result_m    when ALU_OP_SRC_ALU_RES,
                        rd_data         when ALU_OP_SRC_RD_DATA,
                        pc_imm_m        when ALU_OP_SRC_PC_IMM,
                        pc_4_m          when ALU_OP_SRC_PC_4,
                        rs1_e           when others;
        
        


    -- execute pipeline register
    execute_pipeline_register : entity work.execute_pipeline_register(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            imm_in => imm_e,
            rs2_in => t_mux,
            alu_result_in => alu_result_e,
            mem_write_in => mem_write_e,
            mem_width_access_in => mem_width_access_e,
            opcode_in => opcode_e,
            funct3_in => funct3_e,
            rd_src_in => rd_src_e,
            write_rd_in => write_rd_e,
            rd_sel_in => rd_sel_e,
            pc_imm_in => pc_imm_e,
            pc_4_in => pc_4_e,
            
            imm_out => imm_m,
            alu_result_out => alu_result_m,
            rs2_out => rs2_m,
            mem_write_out => mem_write_m,
            mem_width_access_out => mem_width_access_m,
            opcode_out => opcode_m,
            funct3_out => funct3_m,
            rd_src_out => rd_src_m,
            write_rd_out => write_rd_m,
            rd_sel_out => rd_sel_m,
            pc_imm_out => pc_imm_m,
            pc_4_out => pc_4_m     
        );
        



    -- data memory
    data_memory : entity work.data_memory(Behavioral)
        port map(
            clk => clk,
            addr => alu_result_m,
            mem_write_enable => mem_write_m,
            access_width => mem_width_access_m,
            data_in => rs2_m,
            
            data_out => t_mem
        );
        
        
    -- extend_32 unit
    extend_32 : entity work.extend_32(Behavioral)
        port map(
            opcode => opcode_m,
            funct3 => funct3_m,
            mem_data_out => t_mem,
            
            mem_data_out_extended => mem_data_m
        );
        



    -- data memory pipeline register
    mem_pipeline_register : entity work.mem_pipeline_register(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            imm_in => imm_m,
            alu_result_in => alu_result_m,
            mem_data_in => mem_data_m,
            rd_src_in => rd_src_m,
            write_rd_in => write_rd_m,
            rd_sel_in => rd_sel_m,     
            pc_imm_in => pc_imm_m,
            pc_4_in => pc_4_m,
            
            imm_out => imm_wb,
            alu_result_out => alu_result_wb,
            mem_data_out => mem_data_wb,
            rd_sel_out => rd_sel_wb,
            write_rd_out => write_rd_wb,
            rd_src_out => rd_src_wb,
            pc_imm_out => pc_imm_wb,
            pc_4_out => pc_4_wb    
        );

     
    with rd_src_wb select
        rd_data <=  imm_wb              when RD_DATA_SOURCE_IMM,
                    mem_data_wb         when RD_DATA_SOURCE_MEM_DATA_OUT,
                    pc_4_wb             when RD_DATA_SOURCE_PC_4,
                    pc_imm_wb           when RD_DATA_SOURCE_PC_IMM,
                    alu_result_wb       when others;
                    
                    
                    
    -- Hazard Control Unit
    hazard_control_unit : entity work.hazard_control_unit(Behavioral)
        port map(
            rst => rst,
            rs1_sel_d => rs1_sel_d,
            rs2_sel_d => rs2_sel_d,
            rs1_sel_e => rs1_sel_e,
            rs2_sel_e => rs2_sel_e,
            rd_sel_e => rd_sel_e,
            write_rd_e => write_rd_e,
            rd_src_e => rd_src_e,
            next_pc_sel => next_pc_sel,
            rd_sel_m => rd_sel_m,
            write_rd_m => write_rd_m,
            rd_src_m => rd_src_m,
            rd_sel_wb => rd_sel_wb,
            write_rd_wb => write_rd_wb,
            
            stall_pc => stall_pc,
            stall_f => stall_f,
            flush_f => flush_f,
            flush_d => flush_d,
            
            op1_sel => op1_sel,
            op2_sel => t_op2_mux
        );
        


end Behavioral;
