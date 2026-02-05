----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:59:31 10/08/2018 
-- Design Name: 
-- Module Name:    sseg - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sseg is
    Port ( clk : in  STD_LOGIC;
           num : in  UNSIGNED (11 downto 0);
		   rst : in  STD_LOGIC;
           an  : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end sseg;

architecture Behavioral of sseg is
	
	signal clk_100hz 	: std_logic;
	signal bcd_einer 	: std_logic_vector( 3 downto 0 );
	signal bcd_zehner 	: std_logic_vector( 3 downto 0 );
	signal bcd_hunderter: std_logic_vector( 3 downto 0 );
	signal bcd_tausender: std_logic_vector( 3 downto 0 );
	signal bcd_selected : std_logic_vector( 3 downto 0 );
	
begin

	counter_0: entity work.counter
	generic map(
		freq_in => 100e6,
		freq_out => 1000
	)
	port map(
		clk_in => clk,
		rst => rst,
		clk_out => clk_100hz
	);
	
	bin_bcd_0: entity work.bin_bcd
	port map(
		num => num,
		bcd_0 => bcd_einer,
		bcd_1 => bcd_zehner,
		bcd_2 => bcd_hunderter,
		bcd_3 => bcd_tausender
	);
		
	sseg_fsm_0: entity work.sseg_fsm
	port map(
		clk => clk_100hz,
		bcd_0 => bcd_einer,
		bcd_1 => bcd_zehner,
		bcd_2 => bcd_hunderter,
		bcd_3 => bcd_tausender,
		rst => rst,
		an => an,
		bcd_out => bcd_selected
	);
	
	bcd2seg_0: entity work.bcd2seg
	port map(
		bcd => bcd_selected,
		seg => seg
	);

end Behavioral;

