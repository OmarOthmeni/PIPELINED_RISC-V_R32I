-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- Date         : July 28, 2025
-- File         : memory_package.vhd
-- Description  : Put the ROM binary content here (instructions + constant data).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package memory_package is

    type MEMORY_ACCESS_WIDTH_t is (MEMORY_ACCESS_WIDTH_BYTE, MEMORY_ACCESS_WIDTH_HALFWORD, MEMORY_ACCESS_WIDTH_WORD);
    type MEMORY_ACCESS_TYPE_t  is (MEMORY_ACCESS_TYPE_READ, MEMORY_ACCESS_TYPE_WRITE);

    constant DATA_MEMORY_BASE_ADDRESS : integer := 16#00FC8000#;
    
    
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------ Instruction memory -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
    constant RESET_HANDLER_ADDRESS          : integer := 16#00000000#;
    constant INSTRUCTION_MEMORY_SIZE_BYTES  : integer := 388;     -- in bytes, must be a multiple of 4 (32-bits instructions) and must contain at least 2 instructions
    constant INSTRUCTION_MEMORY_SIZE_WORDS  : integer := INSTRUCTION_MEMORY_SIZE_BYTES/4;     -- in 32-bit words

    type INSTRUCTION_MEMORY_ARRAY_t is array(0 to INSTRUCTION_MEMORY_SIZE_WORDS-1) of std_logic_vector(31 downto 0);
    
    -- put the program instruction content here, its size must fit INSTRUCTION_MEMORY_SIZE
    constant INSTRUCTION_MEMORY_CONTENT : INSTRUCTION_MEMORY_ARRAY_t := (
            x"1100006f",
            x"1780006f",
            x"fe010113",
            x"00112e23",
            x"00812c23",
            x"02010413",
            x"00050793",
            x"fef41723",
            x"00700793",
            x"fee45703",
            x"00e787b3",
            x"01079793",
            x"0107d793",
            x"00078513",
            x"01c12083",
            x"01812403",
            x"02010113",
            x"00008067",
            x"fe010113",
            x"00112e23",
            x"00812c23",
            x"00912a23",
            x"02010413",
            x"00050793",
            x"fef41723",
            x"fee45783",
            x"00078513",
            x"f9dff0ef",
            x"00050793",
            x"00078493",
            x"fee45783",
            x"00078513",
            x"f89ff0ef",
            x"00050793",
            x"00f487b3",
            x"01079793",
            x"0107d793",
            x"00078513",
            x"01c12083",
            x"01812403",
            x"01412483",
            x"02010113",
            x"00008067",
            x"fe010113",
            x"00112e23",
            x"00812c23",
            x"02010413",
            x"00200793",
            x"fef42223",
            x"fe042623",
            x"fe0405a3",
            x"fec42783",
            x"01079793",
            x"0107d793",
            x"00078513",
            x"f6dff0ef",
            x"00050793",
            x"00078713",
            x"00fc87b7",
            x"10e79023",
            x"fec42703",
            x"fe442783",
            x"00f707b3",
            x"fef42623",
            x"feb44783",
            x"00178793",
            x"fef405a3",
            x"fc1ff06f",
            x"00fc8117",
            x"1f010113",
            x"00fc8197",
            x"7e818193",
            x"00fc8297",
            x"fe428293",
            x"00fc8317",
            x"fdc30313",
            x"0062d863",
            x"0002a023",
            x"00428293",
            x"ff5ff06f",
            x"00fc8297",
            x"ec428293",
            x"00fc8317",
            x"fb830313",
            x"00fc8397",
            x"fb438393",
            x"00735c63",
            x"0002ae03",
            x"01c32023",
            x"00428293",
            x"00430313",
            x"fedff06f",
            x"f3dff0ef",
            x"0000006f",
            x"00008067",
            x"0000006f",
            x"00008067"
        );
        
        
        
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------------ Data ROM -----------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------  
    constant DATA_ROM_MEMORY_SIZE_BYTES     : integer := 8;     -- in bytes, must be a multiple of 4 and must be >= 8 (fill with 0s if needed)
    constant DATA_ROM_MEMORY_SIZE_WORDS     : integer := DATA_ROM_MEMORY_SIZE_BYTES/4;     -- in 32-bit words

    -- Memory organized as words, but byte addressable
    type DATA_ROM_MEMORY_ARRAY_t is array (0 to DATA_ROM_MEMORY_SIZE_WORDS-1, 3 downto 0) of std_logic_vector(7 downto 0);
    
    -- put the constant data content here, its size must fit DATA_ROM_MEMORY_SIZE_BYTES
    constant DATA_ROM_MEMORY_CONTENT : DATA_ROM_MEMORY_ARRAY_t := (
            (x"00", x"00", x"00", x"07"),
            (x"00", x"00", x"00", x"0b")
        );


---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------------ Data RAM ----------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
    constant DATA_RAM_BASE_ADDRESS        : integer := 16#00FC8100#;
    constant DATA_RAM_MEMORY_SIZE_BYTES   : integer := 512;     -- in bytes, must be a multiple of 4
    constant DATA_RAM_MEMORY_SIZE_WORDS   : integer := DATA_RAM_MEMORY_SIZE_BYTES/4;     -- in 32-bit words
    
    -- Memory organized as words, but byte addressable
    type DATA_RAM_MEMORY_ARRAY_t is array (0 to DATA_RAM_MEMORY_SIZE_WORDS-1, 3 downto 0) of std_logic_vector(7 downto 0);


end package memory_package;
