----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:20:37 10/22/2018 
-- Design Name: 
-- Module Name:    hw_mul_pipelined - Behavioral 
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

entity hw_mul_pipelined is
	Generic (
		   N : integer := 4;
		   M : integer := 4 );
    Port ( rst : in STD_LOGIC;
		   clk : in  STD_LOGIC;
           validin : in  STD_LOGIC;
           a : in  UNSIGNED (N-1 downto 0);
           b : in  UNSIGNED (M-1 downto 0);
           validout : out  STD_LOGIC;
           q : out  UNSIGNED (N+M-1 downto 0));
end hw_mul_pipelined;

architecture Behavioral of hw_mul_pipelined is
	type result_type is array (0 to M) of unsigned(N+M-1 downto 0);	
	type a_type  is array (0 to M) of unsigned(N-1 downto 0);
	type b_type  is array (0 to M) of unsigned(M-1 downto 0);	
	type valid_type is array (0 to M) of std_logic;
	
	signal results : result_type := (others=>(others=>'0'));
	signal as : a_type := (others=>(others=>'0'));
	signal bs : b_type := (others=>(others=>'0'));
	signal valids : valid_type := (others=>'0');
begin

	process( rst, clk )
		variable temp : unsigned(N+M-1 downto 0) := (others=>'0');
	begin
		if( rst = '1' ) then
			results <= (others=>(others=>'0'));
			valids <= (others=>'0');
			as <= (others=>(others=>'0'));
			bs <= (others=>(others=>'0'));
		elsif( rising_edge( clk ) ) then
		
			as(0) <= a;
			bs(0) <= b;
			valids(0) <= validin;
			results(0) <= (others=>'0');
		
			for I in 0 to M-1 loop
			
				-- speichere alles eins weiter
				as(I+1) <= as(I);
				bs(I+1) <= bs(I);
				valids(I+1) <= valids(I);
				
				-- setze temp auf 0
				temp := (others=>'0');
				
				-- wenn entsprechendes Bit in b gesetzt ist
				-- schreibe a an geschobene Stelle.
				if( bs(I)(I) = '1' ) then
					temp(I+N-1 downto I) := as(I);
				end if;
				
				-- speichere vorheriges Ergebnis + temp eins weiter
				results(I+1) <= results(I)+temp;
				
			end loop;
		end if;
	end process;
	
	validout <= valids(M);
	q <= results(M);

end Behavioral;

