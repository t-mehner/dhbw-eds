----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:36:43 11/17/2020 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    Port ( clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
           in_reg : in  STD_LOGIC_VECTOR (7 downto 0);
           out_reg : out  STD_LOGIC_VECTOR (7 downto 0));
end cpu;

architecture Behavioral of cpu is

	COMPONENT rom
	PORT (
		a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		spo : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) );
	END COMPONENT;

	signal program_counter : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal program_code : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
	
	signal clk_1m : STD_LOGIC := '0';

begin
	
	counter_0: entity work.counter
		generic map(
			freq_in => 50e6,
			freq_out => 1e6 )
		port map(
			clk_in => clk,
			rst => reset,
			clk_out => clk_1m );
			
	rom_0: rom
		port map(
			a => program_counter,
			spo => program_code );
			
	alu_0: entity work.alu
		port map(
			clk => clk_1m,
			reset => reset,
			in_reg => in_reg,
			out_reg => out_reg,
			program_counter => program_counter,
			program_code => program_code );

end Behavioral;

