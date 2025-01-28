----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:25:49 10/09/2019 
-- Design Name: 
-- Module Name:    ampel - Behavioral 
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

entity ampel is
    Port ( clk : in  STD_LOGIC;
		   rst : in STD_LOGIC;
           rot : out  STD_LOGIC;
           gelb : out  STD_LOGIC;
           gruen : out  STD_LOGIC);
end ampel;

architecture Behavioral of ampel is

	type state_type is (s_rot, s_rotgelb, s_gruen, s_gelb);
	signal state_reg, state_next : state_type := s_rot;

begin

	clock_process : process( clk, rst )
	begin
		if( rst = '1' ) then
			state_reg <= s_rot;
		elsif( rising_edge(clk) ) then
			state_reg <= state_next;
		end if;
	end process clock_process;
	

	state_transition : process( state_reg )
	begin
		case( state_reg ) is
			when s_rot =>
				state_next <= s_rotgelb;
			when s_rotgelb =>
				state_next <= s_gruen;
			when s_gruen =>
				state_next <= s_gelb;
			when s_gelb =>
				state_next <= s_rot;
			when others =>
				state_next <= s_rot;
		end case;
	end process state_transition;
	
	state_output : process( state_reg )
	begin
		case( state_reg ) is
			when s_rot =>
				rot   <= '1';
				gelb  <= '0';
				gruen <= '0';
			when s_rotgelb =>
				rot   <= '1';
				gelb  <= '1';
				gruen <= '0';
			when s_gruen =>
				rot   <= '0';
				gelb  <= '0';
				gruen <= '1';
			when s_gelb =>
				rot   <= '0';
				gelb  <= '1';
				gruen <= '0';
			when others =>
				rot   <= '1';
				gelb  <= '0';
				gruen <= '0';
		end case;
	end process state_output;

end Behavioral;

