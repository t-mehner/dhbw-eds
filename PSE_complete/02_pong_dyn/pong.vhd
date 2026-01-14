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
        BTN_U,BTN_D: in std_logic;
        RST, CLK: in std_logic;
        GRAPH_RGB: out std_logic_vector(11 downto 0) );
end PONG1;

architecture arch of PONG1 is
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
----------------------------------------------
-- langer senkrechter Strich als Wand
----------------------------------------------
   constant WALL_X_L: integer:=24;
   constant WALL_X_R: integer:=32;
   constant WALL_RGB:  std_logic_vector(11 downto 0):= "000000001111"; -- Wandfarbe: Blau
   signal   WALL_ON:   std_logic;
	
----------------------------------------------
-- Ball
----------------------------------------------
   signal   BALL_X_L: unsigned(9 downto 0) := to_unsigned(300, 10);
   signal   BALL_X_R: unsigned(9 downto 0) := to_unsigned(308, 10);
   signal   BALL_Y_O: unsigned(9 downto 0) := to_unsigned(200, 10);
   signal   BALL_Y_U: unsigned(9 downto 0) := to_unsigned(208, 10);
   signal   BALL_RGB:  std_logic_vector(11 downto 0):= "111100000000"; -- Ballfarbe: Rot
   signal   BALL_ON:   std_logic;

----------------------------------------------
-- Bar
----------------------------------------------
   constant BAR_X_L: integer := 600;
   constant BAR_X_R: integer := 608;
   signal   BAR_Y_O_NEXT, BAR_Y_O_REG: unsigned(9 downto 0) := to_unsigned(200, 10);
   signal   BAR_Y_U_NEXT, BAR_Y_U_REG: unsigned(9 downto 0) := to_unsigned(264, 10);
   signal   BAR_RGB:  std_logic_vector(11 downto 0):= "000011110000"; -- Barfarbe: Grün
   signal   BAR_ON:   std_logic;
   constant BAR_SPEED : integer := 2;
	
----------------------------------------------
-- hier geht es los
----------------------------------------------   
 begin
---------------------------------------------
-- Bewegung
----------------------------------------------
movement: process(RST, CLK) 
begin
    if RST = '1' then
        BAR_Y_O_REG <= to_unsigned(200, 10);
        BAR_Y_U_REG <= to_unsigned(264, 10);
    elsif rising_edge(CLK) then
        BAR_Y_O_REG <= BAR_Y_O_NEXT;
        BAR_Y_U_REG <= BAR_Y_U_NEXT; 
    end if; 
end process movement;

bar: process(BAR_Y_O_REG, BTN_U, BTN_D)
begin
    if BTN_U = '1' and BAR_Y_O_REG > BAR_SPEED then
        BAR_Y_O_NEXT <= BAR_Y_O_REG - BAR_SPEED;
        BAR_Y_U_NEXT <= BAR_Y_O_REG + 64 - BAR_SPEED;
    elsif BTN_D = '1' and BAR_Y_O_REG < 480-64-BAR_SPEED then
        BAR_Y_O_NEXT <= BAR_Y_O_REG + BAR_SPEED;
        BAR_Y_U_NEXT <= BAR_Y_O_REG + 64 + BAR_SPEED;
    else
        BAR_Y_O_NEXT <= BAR_Y_O_REG;
        BAR_Y_U_NEXT <= BAR_Y_O_REG + 64;
    end if;
end process bar;
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
    BAR_ON <=
        '1' when (PIX_X >= BAR_X_L) and (PIX_X < BAR_X_R) and
                 (PIX_Y >= BAR_Y_O_REG) and (PIX_Y < BAR_Y_U_REG) else
        '0';
		
----------------------------------------------
-- Ball
----------------------------------------------
    BALL_ON <=
        '1' when (PIX_X >= BALL_X_L) and (PIX_X < BALL_X_R) and
                 (PIX_Y >= BALL_Y_O) and (PIX_Y < BALL_Y_U) else
        '0';             
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
        elsif BALL_ON = '1' then
            GRAPH_RGB <= BALL_RGB;
        elsif BAR_ON = '1' then
            GRAPH_RGB <= BAR_RGB;      
        else
            GRAPH_RGB <= "111111110000"; 	   -- Hintergrund: Gelb
         end if;
      end if;
   end process;
end arch;
