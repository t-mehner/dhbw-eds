----------------------------------------------
-- Statisches Pong 
-- rechteckiger Ball
----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity PONG1 is
   port(VIDEO_ON: in std_logic;
        PIX_X,PIX_Y: in UNSIGNED(9 downto 0);
        GRAPH_RGB: out std_logic_vector(11 downto 0) );
end PONG1;

architecture arch of PONG1 is
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
----------------------------------------------
-- langer senkrechter Strich als Wand
----------------------------------------------
   constant WALL_X_L: integer:=32;
   constant WALL_X_R: integer:=35;
	constant WALL_RGB:  std_logic_vector(11 downto 0):= "000000001111"; -- Wandfarbe: Blau
	signal   WALL_ON:   std_logic;
	
----------------------------------------------
-- Bar
----------------------------------------------

----------------------------------------------
-- Ball
----------------------------------------------
	
----------------------------------------------
-- hier geht es los
----------------------------------------------   
 begin
----------------------------------------------
-- Wand
----------------------------------------------
-- PIXEL innerhalb der WAND?
   WALL_ON <=
      '1' when (WALL_X_L<=PIX_X) and (PIX_X<=WALL_X_R) else
      '0';

----------------------------------------------
-- Bar
----------------------------------------------

		
----------------------------------------------
-- Ball
----------------------------------------------

----------------------------------------------
-- Anzeigeprozess
----------------------------------------------
   process(VIDEO_ON,WALL_ON)
   begin
      if VIDEO_ON='0' then
          GRAPH_RGB <= "000000000000"; 			-- schwarzer Rahmen
      else
		if WALL_ON='1' then
			GRAPH_RGB <= WALL_RGB;
        else
            GRAPH_RGB <= "111111110000"; 	   -- Hintergrund: Gelb
         end if;
      end if;
   end process;
end arch;
