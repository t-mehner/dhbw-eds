----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:46:26 10/02/2019 
-- Design Name: 
-- Module Name:    fulladder - Behavioral 
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

entity fulladder is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           CIN : in  STD_LOGIC;
           Q : out  STD_LOGIC;
           COUT : out  STD_LOGIC);
end fulladder;

architecture Behavioral of fulladder is

begin

Q_proc : process( A, B, CIN )
begin
	Q <= (A xor B) xor CIN;
end process Q_proc;

C_proc : process( A, B, CIN )
begin
	if( A = '1' and B = '1' ) then
		COUT <= '1';
	elsif( A = '1' and CIN = '1' ) then
		COUT <= '1';
	elsif( B = '1' and CIN = '1' ) then
		COUT <= '1';
	else
		COUT <= '0';
	end if;
end process C_proc;

end Behavioral;

