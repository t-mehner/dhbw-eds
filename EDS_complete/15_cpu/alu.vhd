----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:23:13 11/17/2020 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           in_reg : in  STD_LOGIC_VECTOR (7 downto 0);
           out_reg : out  STD_LOGIC_VECTOR (7 downto 0);
           program_counter : out  STD_LOGIC_VECTOR (5 downto 0);
           program_code : in  STD_LOGIC_VECTOR (11 downto 0));
end alu;

architecture Behavioral of alu is

	signal reg_A, reg_B, reg_C, reg_D : std_logic_vector(7 downto 0) := (others => '0');
	
	signal prog_counter : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
	signal prog_opcode : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal prog_data : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	signal flag_Z, flag_C : STD_LOGIC := '0';

begin

	prog_opcode <= program_code(11 downto 8);
	prog_data <= program_code(7 downto 0);
	
	clk_proc : process(clk, reset)
		variable temp : STD_LOGIC_VECTOR(8 downto 0);
	begin
		if( reset = '1' ) then
			reg_A <= (others => '0');
			reg_B <= (others => '0');
			reg_C <= (others => '0');
			reg_D <= (others => '0');
			
			prog_counter <= (others => '0');
			
			flag_z <= '0';
			flag_c <= '0';
		elsif( rising_edge(clk) ) then
			case prog_opcode is
				when "0000" => 
					prog_counter <= prog_counter + 1;
				when "0001" =>
					reg_A <= prog_data;
					prog_counter <= prog_counter + 1;
				when "0010" =>
					reg_B <= prog_data;
					prog_counter <= prog_counter + 1;
				when "0011" =>
					reg_C <= prog_data;
					prog_counter <= prog_counter + 1;
				when "0100" =>
					reg_D <= prog_data;
					prog_counter <= prog_counter + 1;
				when "0101" =>
					case prog_data(3 downto 0) is
						when "0000" => reg_A <= reg_B;
						when "0001" => reg_A <= reg_C;
						when "0010" => reg_A <= reg_D;
						when "0011" => reg_B <= reg_A;
						when "0100" => reg_B <= reg_C;
						when "0101" => reg_B <= reg_D;
						when "0110" => reg_C <= reg_A;
						when "0111" => reg_C <= reg_B;
						when "1000" => reg_C <= reg_D;
						when "1001" => reg_D <= reg_A;
						when "1010" => reg_D <= reg_B;
						when "1011" => reg_D <= reg_C;
						when "1100" => reg_A <= in_reg;
						when "1101" => reg_B <= in_reg;
						when "1110" => out_reg <= reg_A;
						when "1111" => out_reg <= reg_B;
						when others => reg_A <= reg_A;
					end case;
					prog_counter <= prog_counter + 1;
				when "0110" =>
					temp := ('0' & reg_A) + ('0' & reg_B);
					
					if( temp = "000000000" ) then
						flag_z <= '1';
					else
						flag_z <= '0';
					end if;
					
					flag_c <= temp(8);
					
					reg_A <= temp(7 downto 0);
					prog_counter <= prog_counter + 1;
				when "0111" =>
					temp := ('0' & reg_A) - ('0' & reg_B);
					
					if( temp = "000000000" ) then
						flag_z <= '1';
					else
						flag_z <= '0';
					end if;
					
					flag_c <= temp(8);
					
					reg_A <= temp(7 downto 0);
					prog_counter <= prog_counter + 1;
				when "1000" =>
					temp := ('0' & reg_A) - ('0' & reg_B);
					
					if( temp = "000000000" ) then
						flag_z <= '1';
					else
						flag_z <= '0';
					end if;
					
					flag_c <= temp(8);
					
					prog_counter <= prog_counter + 1;
				when "1001" =>
					case prog_data(2 downto 0) is
						when "000" => reg_A <= not reg_A;
						when "001" => reg_A <= reg_A(6 downto 0) & '0';
										  flag_C <= reg_A(7);
						when "010" => reg_A <= flag_C & reg_A(7 downto 1);
						when "011" => reg_A <= reg_A(6 downto 0) & reg_A(7);
						when "100" => reg_A <= reg_A(0) & reg_A(7 downto 1);
						when "101" => reg_A <= reg_A and reg_B;
						when "110" => reg_A <= reg_A or reg_B;
						when "111" => reg_A <= reg_A xor reg_B;
						when others => reg_A <= reg_A;
					end case;
					prog_counter <= prog_counter + 1;
				when "1010" =>
					reg_A <= (not reg_A) + 1;
					prog_counter <= prog_counter + 1;
				when "1011" =>
					reg_A <= reg_A - 1;
					if( reg_A = "00000001" ) then
						flag_z <= '1';
					else
						flag_z <= '0';
					end if;
					prog_counter <= prog_counter + 1;
				when "1100" =>
					prog_counter <= prog_counter + prog_data(5 downto 0);
				when "1101" =>
					if( flag_Z = prog_data(0) ) then
						prog_counter <= prog_counter + 2;
					else
						prog_counter <= prog_counter + 1;
					end if;				
				when "1110" =>
					if( flag_C = prog_data(0) ) then
						prog_counter <= prog_counter + 2;
					else
						prog_counter <= prog_counter + 1;
					end if;
				when "1111" =>
					flag_C <= '0';
					flag_Z <= '0';
					prog_counter <= prog_counter + 1;
				when others =>
					prog_counter <= prog_counter + 1;
			end case;
		end if;
	end process clk_proc;
	
	program_counter <= prog_counter;

end Behavioral;

