library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity CPU_tb is
end CPU_tb;

architecture Behavioral of CPU_tb is
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';


begin

    clk <= not clk after 5ns;  -- 100MHz clock

    CPU : entity work.CPU(Behavioral)
        port map(
            rst => rst,
            clk => clk
        );
        
        
    process
    begin
    
        wait for 12ns;
        rst <= '0';
        wait for 1ms;
        rst <= '1';
        wait;
        
    end process;


end Behavioral;
