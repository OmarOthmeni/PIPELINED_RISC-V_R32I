-- Project      : PIPELINED_RISC-V_RV32I
-- Author       : Omar Othmeni <https://github.com/OmarOthmeni>
-- File         : tb_cpu_selfcheck.vhd
-- Description  : Self-checking testbench. Runs the program currently in
--                memory_package.vhd and watches the CPU's memory-stage store
--                port. When the program stores to `tohost` (0x00FC8100):
--                  value 1             -> PASS
--                  value (n << 1) | 1  -> FAIL at test n
--                No store before TIMEOUT -> FAIL (timeout).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

entity tb_cpu_selfcheck is
    generic (TIMEOUT_CYCLES : natural := 200000);
end tb_cpu_selfcheck;

architecture sim of tb_cpu_selfcheck is
    constant CLK_PERIOD  : time := 10 ns;
    constant TOHOST_ADDR : std_logic_vector(31 downto 0) := x"00FC8100";

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin

    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.CPU(Behavioral)
        port map(rst => rst, clk => clk);

    monitor : process
        alias mem_write is << signal .tb_cpu_selfcheck.dut.mem_write_m  : std_logic >>;
        alias mem_addr  is << signal .tb_cpu_selfcheck.dut.alu_result_m : std_logic_vector(31 downto 0) >>;
        alias mem_data  is << signal .tb_cpu_selfcheck.dut.rs2_m        : std_logic_vector(31 downto 0) >>;
        variable cycles : natural := 0;
        variable value  : unsigned(31 downto 0);
    begin
        wait for 2 * CLK_PERIOD;
        wait until falling_edge(clk);
        rst <= '0';

        loop
            wait until rising_edge(clk);
            cycles := cycles + 1;

            if mem_write = '1' and mem_addr = TOHOST_ADDR then
                value := unsigned(mem_data);
                if value = 1 then
                    report "PASS after " & integer'image(cycles) & " cycles" severity note;
                    finish(0);
                else
                    report "FAIL at test " & integer'image(to_integer(value srl 1))
                        & " after " & integer'image(cycles) & " cycles" severity error;
                    finish(1);
                end if;
            end if;

            if cycles >= TIMEOUT_CYCLES then
                report "FAIL: timeout after " & integer'image(cycles) & " cycles" severity error;
                finish(2);
            end if;
        end loop;
    end process;

end sim;
