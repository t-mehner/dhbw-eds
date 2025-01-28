----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:09:12 11/05/2019 
-- Design Name: 
-- Module Name:    vga_output - Behavioral 
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

entity vga_schachbrett is
    Port ( CLK : in  STD_LOGIC;
           RGB_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC);
end vga_schachbrett;

architecture Behavioral of vga_schachbrett is

	signal CLK_VGA : STD_LOGIC := '0';
	
	signal RGB_ON_REG, RGB_ON_NEXT : STD_LOGIC := '0';
	
	signal X_PIX_REG, X_PIX_NEXT : UNSIGNED( 9 downto 0 ) := to_unsigned(0, 10);
	signal Y_PIX_REG, Y_PIX_NEXT : UNSIGNED( 9 downto 0 ) := to_unsigned(0, 10);
	
	signal RGB_INT_REG, RGB_INT_NEXT : STD_LOGIC_VECTOR( 2 downto 0 );
	
	signal X_MUSTER, Y_MUSTER : STD_LOGIC_VECTOR(2 downto 0);

begin

	clk_div: process( CLK )
	begin
		if( rising_edge(CLK) ) then
			CLK_VGA <= not CLK_VGA;
		end if;
	end process clk_div;
	
	pixel_clk : process( CLK_VGA )
	begin
		if( rising_edge( CLK_VGA ) ) then
			RGB_ON_REG <= RGB_ON_NEXT;
			
			X_PIX_REG <= X_PIX_NEXT;
			Y_PIX_REG <= Y_PIX_NEXT;
			
			RGB_INT_REG <= RGB_INT_NEXT;
		end if;
	end process;
	
	pixel_count : process( X_PIX_REG, Y_PIX_REG )
	begin
		if( X_PIX_REG = 800 ) then
			X_PIX_NEXT <= to_unsigned(0,10);
			if( Y_PIX_REG = 525 ) then
				Y_PIX_NEXT <= TO_UNSIGNED(0,10);
			else
				Y_PIX_NEXT <= Y_PIX_REG + 1;
			end if;
		else
			X_PIX_NEXT <= X_PIX_REG + 1;
			Y_PIX_NEXT <= Y_PIX_REG;
		end if;
	end process pixel_count;
	
	h_sync_gen : process( X_PIX_REG )
	begin
		if( X_PIX_REG >= 660 ) and ( X_PIX_REG <= 756 ) then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end process h_sync_gen;
	
	v_sync_gen : process( Y_PIX_REG )
	begin
		if( Y_PIX_REG >= 494 ) and ( Y_PIX_REG <= 495 ) then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end process v_sync_gen;
	
	rgb_on_gen : process( X_PIX_REG, Y_PIX_REG )
	begin
		if( X_PIX_REG < 640 ) and (Y_PIX_REG < 480) then
			RGB_ON_NEXT <= '1';
		else
			RGB_ON_NEXT <= '0';
		end if;
	end process rgb_on_gen;
	
	rgb_out_gen : process( RGB_ON_REG, RGB_INT_REG )
	begin
		if( RGB_ON_REG = '1' ) then
			RGB_OUT(0) <= RGB_INT_REG(0);
			RGB_OUT(1) <= RGB_INT_REG(0);
			RGB_OUT(2) <= RGB_INT_REG(0);
			RGB_OUT(3) <= RGB_INT_REG(1);
			RGB_OUT(4) <= RGB_INT_REG(1);
			RGB_OUT(5) <= RGB_INT_REG(1);
			RGB_OUT(6) <= RGB_INT_REG(2);
			RGB_OUT(7) <= RGB_INT_REG(2);
		else
			RGB_OUT <= (others=>'0');
		end if;
	end process;
	
	x_muster_gen : process( X_PIX_REG )
	begin
		if( X_PIX_REG < 80 ) then
			X_MUSTER <= "000";
		elsif( X_PIX_REG < 160 ) then
			X_MUSTER <= "111";
		elsif( X_PIX_REG < 240 ) then
			X_MUSTER <= "000";
		elsif( X_PIX_REG < 320 ) then
			X_MUSTER <= "111";
		elsif( X_PIX_REG < 400 ) then
			X_MUSTER <= "000";
		elsif( X_PIX_REG < 480 ) then
			X_MUSTER <= "111";
		elsif( X_PIX_REG < 560 ) then
			X_MUSTER <= "000";
		else
			X_MUSTER <= "111";
		end if;
	end process;
	
	y_muster_gen : process( Y_PIX_REG )
	begin
		if( Y_PIX_REG < 80 ) then
			Y_MUSTER <= "000";
		elsif( Y_PIX_REG < 160 ) then
			Y_MUSTER <= "111";
		elsif( Y_PIX_REG < 240 ) then
			Y_MUSTER <= "000";
		elsif( Y_PIX_REG < 320 ) then
			Y_MUSTER <= "111";
		elsif( Y_PIX_REG < 400 ) then
			Y_MUSTER <= "000";
		else
			Y_MUSTER <= "111";
		end if;
	end process;
	
	RGB_INT_NEXT <= X_MUSTER xor Y_MUSTER;

end Behavioral;

