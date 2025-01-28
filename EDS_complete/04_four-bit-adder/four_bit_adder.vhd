----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:10:55 10/02/2019 
-- Design Name: 
-- Module Name:    four_bit_adder - Behavioral 
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

entity four_bit_adder is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Q : out  STD_LOGIC_VECTOR (3 downto 0);
           C : out  STD_LOGIC);
end four_bit_adder;

architecture Behavioral of four_bit_adder is

	component fulladder
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           CIN : in  STD_LOGIC;
           Q : out  STD_LOGIC;
           COUT : out  STD_LOGIC);
	end component;
	
	signal sig_c0 : STD_LOGIC := '0';
	signal sig_c1 : STD_LOGIC := '0';
	signal sig_c2 : STD_LOGIC := '0';

begin

	fulladder_0 : fulladder
	port map(
		A => A(0),
		B => B(0),
		CIN => '0',
		Q => Q(0),
		COUT => sig_c0 );
		
	fulladder_1 : fulladder
	port map(
		A => A(1),
		B => B(1),
		CIN => sig_c0,
		Q => Q(1),
		COUT => sig_c1 );
		
	fulladder_2 : fulladder
	port map(
		A => A(2),
		B => B(2),
		CIN => sig_c1,
		Q => Q(2),
		COUT => sig_c2 );
		
	fulladder_3 : fulladder
	port map(
		A => A(3),
		B => B(3),
		CIN => sig_c2,
		Q => Q(3),
		COUT => C );

end Behavioral;

