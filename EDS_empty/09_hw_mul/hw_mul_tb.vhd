--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:54:35 10/22/2018
-- Design Name:   
-- Module Name:   /home/torben/Documents/DHBW/EDS/Projekte/hw_mul/hw_mul_tb.vhd
-- Project Name:  hw_mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hw_mul
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY hw_mul_tb IS
END hw_mul_tb;
 
ARCHITECTURE behavior OF hw_mul_tb IS 
   --Inputs
   signal f1 : std_logic_vector(4 downto 0) := (others => '0');
   signal f2 : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal q : std_logic_vector(9 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.hw_mul 
   GENERIC MAP(
		N => 5,
		M => 5 )
   PORT MAP (
          f1 => f1,
          f2 => f2,
          q => q
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;

      for I in 0 to 31 loop
		for J in 0 to 31 loop
			f1 <= std_logic_vector(to_unsigned(I,5));
			f2 <= std_logic_vector(to_unsigned(J,5));
			
			wait for 50 ns;
		end loop;
	  end loop;

      wait;
   end process;

	check_proc: process(q)
		variable result : std_logic_vector(9 downto 0);
	begin
		
		result := std_logic_vector(unsigned(f1)*unsigned(f2));
	
		assert q=result
			report "unexpected value. i = " & integer'image(to_integer(unsigned(q)))
			severity warning;
	end process;

END;
