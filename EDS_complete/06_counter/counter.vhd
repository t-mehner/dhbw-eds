----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:02:14 10/07/2019 
-- Design Name: 
-- Module Name:    counter - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
	Generic (
		FREQ_IN : INTEGER := 50000000;
		FREQ_OUT : INTEGER := 5 );
    Port ( 
		CLK_IN : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		CLK_OUT : out  STD_LOGIC);
end counter;

architecture Behavioral of counter is
	constant MAX : UNSIGNED(31 downto 0) := to_unsigned((FREQ_IN/FREQ_OUT/2)-1, 32);
	signal sig_CNT : UNSIGNED(31 downto 0) := (others=>'0');
	signal sig_CLK : STD_LOGIC := '0';
begin

	cnt_proc: process( CLK_IN, RST )
	begin
		if( RST = '1' ) then
			sig_CNT <= (others => '0');
			sig_CLK <= '0';
		elsif( rising_edge( CLK_IN ) ) then
			if( sig_CNT = MAX ) then
				sig_CNT <= (others => '0');
				sig_CLK <= not sig_CLK;
			else
				sig_CNT <= sig_CNT + 1;
			end if;
		end if;
	end process cnt_proc;
	
	out_proc: process( sig_CLK )
	begin
		CLK_OUT <= sig_CLK;
	end process out_proc;

end Behavioral;

