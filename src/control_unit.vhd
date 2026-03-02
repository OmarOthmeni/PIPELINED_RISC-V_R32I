-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 27, 2025
-- File         : control_unit.vhd
-- Description  : Based on the decode instruction fields, outputs the control signals.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity control_unit is
    port(
        opcode              : in std_logic_vector(6 downto 0);
        funct3              : in std_logic_vector(2 downto 0);
        funct7              : in std_logic_vector(6 downto 0);
        
        branch              : out BRANCH_TYPE_t;
        jump                : out std_logic;
        rd_data_src         : out RD_DATA_SOURCE_t;
        write_rd            : out std_logic;
        mem_access_width    : out MEM_ACCESS_WIDTH_t;
        mem_write_enable    : out std_logic;
        alu_op_type         : out ALU_OP_TYPE_t;
        alu_use_imm         : out std_logic
    );
end control_unit;



architecture Behavioral of control_unit is

begin

    branch <=   BRANCH_TYPE_BEQ    when opcode = INSTR_OPCODE_BRANCH and funct3 = INSTR_FUNCT3_BEQ                                  else
                BRANCH_TYPE_BNE    when opcode = INSTR_OPCODE_BRANCH and funct3 = INSTR_FUNCT3_BNE                                  else
                BRANCH_TYPE_BLT    when opcode = INSTR_OPCODE_BRANCH and (funct3 = INSTR_FUNCT3_BLT or funct3 = INSTR_FUNCT3_BLTU)  else
                BRANCH_TYPE_BGE    when opcode = INSTR_OPCODE_BRANCH and (funct3 = INSTR_FUNCT3_BGE or funct3 = INSTR_FUNCT3_BGEU)  else
                BRANCH_TYPE_NONE;
               
                   
    jump <= '1' when opcode = INSTR_OPCODE_JAL or opcode = INSTR_OPCODE_JALR else '0';
    
    
    rd_data_src <=  RD_DATA_SOURCE_PC_IMM       when opcode = INSTR_OPCODE_AUIPC                                else
                    RD_DATA_SOURCE_PC_4         when opcode = INSTR_OPCODE_JAL or opcode = INSTR_OPCODE_JALR    else
                    RD_DATA_SOURCE_IMM          when opcode = INSTR_OPCODE_LUI                                  else
                    RD_DATA_SOURCE_MEM_DATA_OUT when opcode = INSTR_OPCODE_LOAD                                 else
                    RD_DATA_SOURCE_ALU_RESULT;
    
    
    write_rd <= '0' when opcode = INSTR_OPCODE_BRANCH or opcode = INSTR_OPCODE_STORE or opcode = INSTR_OPCODE_FENCE or opcode = INSTR_OPCODE_SYSTEM else '1';
    
    
    mem_access_width <= MEM_ACCESS_WIDTH_32 when (opcode = INSTR_OPCODE_LOAD and funct3 = INSTR_FUNCT3_LW)
                                                or (opcode = INSTR_OPCODE_STORE and funct3 = INSTR_FUNCT3_SW) else
                        MEM_ACCESS_WIDTH_16 when (opcode = INSTR_OPCODE_LOAD and (funct3 = INSTR_FUNCT3_LH or funct3 = INSTR_FUNCT3_LHU))
                                                or (opcode = INSTR_OPCODE_STORE and funct3 = INSTR_FUNCT3_SH) else
                        MEM_ACCESS_WIDTH_8;
             
                        
    mem_write_enable <= '1' when opcode = INSTR_OPCODE_STORE else '0';
    
    
    alu_op_type <=  ALU_OP_TYPE_SUB     when (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SUB and funct7 = INSTR_FUNCT7_SUB)
                                             or (opcode = INSTR_OPCODE_BRANCH and (funct3 = INSTR_FUNCT3_BEQ or funct3 = INSTR_FUNCT3_BNE)) else
                    ALU_OP_TYPE_SLT     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_SLTI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SLT and funct7 = INSTR_FUNCT7_SLT)
                                             or (opcode = INSTR_OPCODE_BRANCH and (funct3 = INSTR_FUNCT3_BLT or funct3 = INSTR_FUNCT3_BGE)) else
                    ALU_OP_TYPE_SLTU    when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_SLTIU)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SLTU and funct7 = INSTR_FUNCT7_SLTU)
                                             or (opcode = INSTR_OPCODE_BRANCH and (funct3 = INSTR_FUNCT3_BLTU or funct3 = INSTR_FUNCT3_BGEU)) else
                    ALU_OP_TYPE_AND     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_ANDI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_AND and funct7 = INSTR_FUNCT7_AND) else
                    ALU_OP_TYPE_OR      when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_ORI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_OR and funct7 = INSTR_FUNCT7_OR) else
                    ALU_OP_TYPE_XOR     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_XORI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_XOR and funct7 = INSTR_FUNCT7_XOR) else
                    ALU_OP_TYPE_SLL     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_SLLI and funct7 = INSTR_FUNCT7_SLLI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SLL and funct7 = INSTR_FUNCT7_SLL) else
                    ALU_OP_TYPE_SRL     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_SRLI and funct7 = INSTR_FUNCT7_SRLI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SRL and funct7 = INSTR_FUNCT7_SRL) else
                    ALU_OP_TYPE_SRA     when (opcode = INSTR_OPCODE_REG_IMM and funct3 = INSTR_FUNCT3_SRAI and funct7 = INSTR_FUNCT7_SRAI)
                                             or (opcode = INSTR_OPCODE_REG_REG and funct3 = INSTR_FUNCT3_SRA and funct7 = INSTR_FUNCT7_SRA) else
                    ALU_OP_TYPE_ADD;

    
    alu_use_imm <= '1' when opcode = INSTR_OPCODE_REG_IMM or opcode = INSTR_OPCODE_JALR or opcode = INSTR_OPCODE_LOAD or opcode = INSTR_OPCODE_STORE else '0';

end Behavioral;
