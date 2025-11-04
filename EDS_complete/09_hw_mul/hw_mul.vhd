----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:37:33 10/15/2018 
-- Design Name: 
-- Module Name:    hw_mul - Behavioral 
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

entity hw_mul is
	Generic(
		N : integer := 4;
		M : integer := 4 );
    Port ( A : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B : in  STD_LOGIC_VECTOR (M-1 downto 0);
           Q : out  STD_LOGIC_VECTOR (M+N-1 downto 0));
end hw_mul;

architecture Behavioral of hw_mul is

begin

process( A, B )
	variable sum : unsigned( M+N-1 downto 0);
	variable temp : unsigned( M+N-1 downto 0);
begin
	sum := to_unsigned(0, M+N);
	
	for I in 0 to N-1 loop
	
		temp := (others => '0');
		if( A(I) = '1') then
			temp(I+M-1 downto I) := unsigned(B);
		end if;
		
		sum := sum + temp;
		
	end loop;
	
	Q <= std_logic_vector(sum);

end process;

end Behavioral;

