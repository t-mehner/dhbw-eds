----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:15 10/08/2018 
-- Design Name: 
-- Module Name:    sseg_fsm - Behavioral 
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

entity sseg_fsm is
    Port ( clk : in  STD_LOGIC;
           bcd_0 : in  STD_LOGIC_VECTOR (3 downto 0);
           bcd_1 : in  STD_LOGIC_VECTOR (3 downto 0);
           bcd_2 : in  STD_LOGIC_VECTOR (3 downto 0);
           bcd_3 : in  STD_LOGIC_VECTOR (3 downto 0);
		   rst : in STD_LOGIC;
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           bcd_out : out  STD_LOGIC_VECTOR (3 downto 0));
end sseg_fsm;

architecture mealy of sseg_fsm is
	type state_type is (einer, zehner, hunderter, tausender);
	signal state : state_type := einer;
begin

	transition : process( clk, rst )
	begin
		if( rst = '1' ) then
			state <= einer;
		elsif( rising_edge( clk ) ) then
			case state is
				when einer =>
					state <= zehner;
				when zehner =>
					state <= hunderter;
				when hunderter =>
					state <= tausender;
				when tausender =>
					state <= einer;
			end case;
		end if;
	end process transition;
	
	output_function : process( state, bcd_0, bcd_1, bcd_2, bcd_3 )
	begin
		case state is
			when einer =>
				bcd_out <= bcd_0;
				an <= "1110";
			when zehner =>
				bcd_out <= bcd_1;
				an <= "1101";
			when hunderter =>
				bcd_out <= bcd_2;
				an <= "1011";
			when tausender =>
				bcd_out <= bcd_3;
				an <= "0111";
		end case;
	end process output_function;

end mealy;

