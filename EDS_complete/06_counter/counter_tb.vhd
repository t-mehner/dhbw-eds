----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2025 08:35:37 AM
-- Design Name: 
-- Module Name: counter_tb - Testbench
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_tb is
--  Port ( );
end counter_tb;

architecture Testbench of counter_tb is
    signal sig_CLK_IN, sig_CLK_OUT : STD_LOGIC := '0';
    signal sig_RST : STD_LOGIC := '0';
begin

    uut: entity work.counter
    generic map(
        FREQ_IN => 10,
        FREQ_OUT => 1)
    port map(
        CLK_IN => sig_CLK_IN,
        RST => sig_RST,
        CLK_OUT => sig_CLK_OUT );
        
    clk_proc: process
    begin
    
        sig_CLK_IN <= not sig_CLK_IN;
        wait for 5 ns;
        
    end process clk_proc;
    
    rst_proc: process
    begin
    
        sig_RST <= '1';
        
        wait for 50 ns;
        sig_RST <= '0';
        
        wait for 500 ns;
        sig_RST <= '1';
        
        wait;
    
    end process rst_proc;

end Testbench;
