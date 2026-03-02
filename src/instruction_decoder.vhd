-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 27, 2025
-- File         : instruction_decoder.vhd
-- Description  : Instruction decoder. Extract and output the different fields in an instruction.
--                The "invalid_instr" signal can be used to implement an invalid-instruction interrupt.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_package.all;


entity instruction_decoder is
    port (
        instr           : in std_logic_vector(31 downto 0);
        
        opcode          : out std_logic_vector(6 downto 0);
        funct3          : out std_logic_vector(2 downto 0);
        funct7          : out std_logic_vector(6 downto 0);
        rd              : out std_logic_vector(4 downto 0);
        rs1             : out std_logic_vector(4 downto 0);
        rs2             : out std_logic_vector(4 downto 0);     -- also 'shamt' for SLLI, SRLI and SRAI
        imm             : out std_logic_vector(31 downto 0);
        invalid_instr   : out std_logic    -- '1' if the instruction is invalid else '0'
    );
end instruction_decoder;



architecture Behavioral of instruction_decoder is
    signal opcode_signal : std_logic_vector(6 downto 0);
    signal funct3_signal : std_logic_vector(2 downto 0);
    signal funct7_signal : std_logic_vector(6 downto 0);
begin

    opcode_signal   <= instr(6 downto 0);
    funct3_signal   <= instr(14 downto 12);
    funct7_signal   <= instr(31 downto 25);
    rd              <= instr(11 downto 7);
    rs1             <= instr(19 downto 15);
    rs2             <= instr(24 downto 20);
    
    opcode          <= opcode_signal;
    funct3          <= funct3_signal;
    funct7          <= funct7_signal;

    
    
     -- check if the format of the instruction is valid
    invalid_instr <=    '0' when    
    
        opcode_signal = INSTR_OPCODE_LUI 
        or opcode_signal = INSTR_OPCODE_AUIPC
        or opcode_signal = INSTR_OPCODE_JAL
        or (opcode_signal = INSTR_OPCODE_JALR and funct3_signal = INSTR_FUNCT3_JALR)
        or (opcode_signal = INSTR_OPCODE_BRANCH and funct3_signal(2 downto 1) /= "01")
        or (opcode_signal = INSTR_OPCODE_LOAD and funct3_signal(2 downto 1) /= "11" and funct3_signal(1 downto 0) /= "11")
        or (opcode_signal = INSTR_OPCODE_STORE and funct3_signal(2) = '0' and funct3_signal(1 downto 0) /= "11")
        or (opcode_signal = INSTR_OPCODE_REG_IMM and funct3_signal(1 downto 0) /= "01")
        or (opcode_signal = INSTR_OPCODE_REG_IMM and ((funct3_signal = INSTR_FUNCT3_SLLI and funct7_signal = INSTR_FUNCT7_SLLI) or
            (funct3_signal = "101" and (funct7_signal = INSTR_FUNCT7_SRLI or funct7_signal = INSTR_FUNCT7_SRAI))))
        or (opcode_signal = INSTR_OPCODE_REG_REG and (funct7_signal = "0000000" or (funct7_signal = "0100000" and (funct3_signal = "000" or funct3_signal = "101"))))

        else '1';   -- invalid instruction format or not implemented instruction (currently: FENCE, ECALL, EBREAK)



    
    imm <=
                    -- LUI, AUIPC : U-type
                    instr(31 downto 12) & (11 downto 0 => '0') when opcode_signal = INSTR_OPCODE_LUI or opcode_signal = INSTR_OPCODE_AUIPC                      else
                    
                    -- JAL : J-type
                    (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0' when opcode_signal = INSTR_OPCODE_JAL             else            
                         
                    -- JALR, LB, LH, LW, LBU, LHU, ADDI, SLTI, SLTIU, XORI, ORI, ANDI : I-type
                    (31 downto 11 => instr(31)) & instr(30 downto 20) when opcode_signal = INSTR_OPCODE_JALR or opcode_signal = INSTR_OPCODE_LOAD or opcode_signal = INSTR_OPCODE_REG_IMM  else   
                                 
                    -- BEQ, BNE, BLT, BGE, BLTU, BGEU : B-type
                    (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0' when opcode_signal = INSTR_OPCODE_BRANCH                      else
                    
                    -- SB, SH, SW : S-type
                    (31 downto 11 => instr(31)) & instr(30 downto 25) & instr(11 downto 7) when opcode_signal = INSTR_OPCODE_STORE                                       else                    

                    (others => '0'); -- R-type instructions (no immediate) or invalid opcode or not implemented instruction (for now: FENCE, ECALL, EBREAK)
                 
end Behavioral;
