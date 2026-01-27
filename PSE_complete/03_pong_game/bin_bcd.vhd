----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:11:30 10/01/2018 
-- Design Name: 
-- Module Name:    bin_bcd - Behavioral 
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

entity bin_bcd is
    Port ( NUM   : in   UNSIGNED (11 downto 0);
           BCD_0 : out  STD_LOGIC_VECTOR (3 downto 0);
           BCD_1 : out  STD_LOGIC_VECTOR (3 downto 0);
           BCD_2 : out  STD_LOGIC_VECTOR (3 downto 0);
           BCD_3 : out  STD_LOGIC_VECTOR (3 downto 0) );
end bin_bcd;

architecture Behavioral of bin_bcd is

	signal trunc_1000 : UNSIGNED( 11 downto 0 );
	signal trunc_100 : UNSIGNED( 11 downto 0 );
	signal trunc_10 : UNSIGNED( 11 downto 0 );

begin

	tausender : process( NUM )
	begin
	
	    if( NUM >= 4000 ) then
			trunc_1000 <= NUM -4000;
			BCD_3 <= "0100";
		elsif( NUM >= 3000 ) then
			trunc_1000 <= NUM -3000;
			BCD_3 <= "0011";
        elsif( NUM >= 2000 ) then
			trunc_1000 <= NUM -2000;
			BCD_3 <= "0010";
		elsif( NUM >= 1000 ) then
			trunc_1000 <= NUM -1000;
			BCD_3 <= "0001";
		else
			trunc_1000 <= NUM;
			BCD_3 <= "0000";
		end if;
	end process tausender;

	hunderter : process( trunc_1000 )
	begin
		if( trunc_1000 >= 900 ) then
			trunc_100 <= trunc_1000 - 900;
			BCD_2 <= "1001";
			
		elsif( trunc_1000 >= 800 ) then
			trunc_100 <= trunc_1000 - 800;
			BCD_2 <= "1000";
			
		elsif( trunc_1000 >= 700 ) then
			trunc_100 <= trunc_1000 - 700;
			BCD_2 <= "0111";
			
		elsif( trunc_1000 >= 600 ) then
			trunc_100 <= trunc_1000 - 600;
			BCD_2 <= "0110";
			
		elsif( trunc_1000 >= 500 ) then
			trunc_100 <= trunc_1000 - 500;
			BCD_2 <= "0101";
			
		elsif( trunc_1000 >= 400 ) then
			trunc_100 <= trunc_1000 - 400;
			BCD_2 <= "0100";
			
		elsif( trunc_1000 >= 300 ) then
			trunc_100 <= trunc_1000 - 300;
			BCD_2 <= "0011";
			
		elsif( trunc_1000 >= 200 ) then
			trunc_100 <= trunc_1000 - 200;
			BCD_2 <= "0010";
			
		elsif( trunc_1000 >= 100 ) then
			trunc_100 <= trunc_1000 - 100;
			BCD_2 <= "0001";
			
		else
			trunc_100 <= trunc_1000;
			BCD_2 <= "0000";
			
		end if;	
		
	end process hunderter;
	
	zehner : process( trunc_100 )
	begin
		
		if( trunc_100 >= 90 ) then
			trunc_10 <= trunc_100 - 90;
			BCD_1 <= "1001";
			
		elsif( trunc_100 >= 80 ) then
			trunc_10 <= trunc_100 - 80;
			BCD_1 <= "1000";
			
		elsif( trunc_100 >= 70 ) then
			trunc_10 <= trunc_100 - 70;
			BCD_1 <= "0111";
			
		elsif( trunc_100 >= 60 ) then
			trunc_10 <= trunc_100 - 60;
			BCD_1 <= "0110";
			
		elsif( trunc_100 >= 50 ) then
			trunc_10 <= trunc_100 - 50;
			BCD_1 <= "0101";
			
		elsif( trunc_100 >= 40 ) then
			trunc_10 <= trunc_100 - 40;
			BCD_1 <= "0100";
			
		elsif( trunc_100 >= 30 ) then
			trunc_10 <= trunc_100 - 30;
			BCD_1 <= "0011";
			
		elsif( trunc_100 >= 20 ) then
			trunc_10 <= trunc_100 - 20;
			BCD_1 <= "0010";
			
		elsif( trunc_100 >= 10 ) then
			trunc_10 <= trunc_100 - 10;
			BCD_1 <= "0001";
			
		else
			trunc_10 <= trunc_100;
			BCD_1 <= "0000";
		end if;
		
	end process zehner;
	
	einer : process( trunc_10 )
	begin
	
		if( trunc_10 = 9 ) then
			BCD_0 <= "1001";
		
		elsif( trunc_10 = 8 ) then
			BCD_0 <= "1000";
		
		elsif( trunc_10 = 7 ) then
			BCD_0 <= "0111";
		
		elsif( trunc_10 = 6 ) then
			BCD_0 <= "0110";
		
		elsif( trunc_10 = 5 ) then
			BCD_0 <= "0101";
		
		elsif( trunc_10 = 4 ) then
			BCD_0 <= "0100";
		
		elsif( trunc_10 = 3 ) then
			BCD_0 <= "0011";
		
		elsif( trunc_10 = 2 ) then
			BCD_0 <= "0010";
		
		elsif( trunc_10 = 1 ) then
			BCD_0 <= "0001";
		
		else
			BCD_0 <= "0000";
		end if;
	
	end process einer;

end Behavioral;

