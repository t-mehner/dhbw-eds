-- Topmodul fr PONG
-- runder Ball in Bewegung
library ieee;
use ieee.std_logic_1164.all;
entity PONG_STAT is
   port (
      CLK,RESET: in std_logic;	  
	  BUTTON_1, BUTTON_2: in std_logic;
      HSYNC, VSYNC: out  std_logic;
      RGB: out std_logic_vector(2 downto 0);
	  LED: out std_logic_vector(2 downto 0)
   );
end PONG_STAT;

architecture arch of PONG_STAT is
   signal PIXEL_X, PIXEL_Y: std_logic_vector (9 downto 0);
   signal VIDEO_ON, PIXEL_TICK: std_logic;
   signal RGB_REG, RGB_NEXT: std_logic_vector(2 downto 0);
   signal VSYNC_sig : std_logic;
begin
   -- instantiate VGA sync
   VGA_UNIT: entity work.VGA_SYNC
      port map(CLK=>CLK, RESET=>RESET,
               VIDEO_ON=>VIDEO_ON, p_tick=>PIXEL_TICK,
               HSYNC=>HSYNC, VSYNC=>VSYNC_sig,
               PIXEL_X=>PIXEL_X, PIXEL_Y=>PIXEL_Y);
   -- instantiate graphic 
   PONG_UNIT: entity work.PONG1
      port map (VIDEO_ON=>VIDEO_ON,
                PIXEL_X=>PIXEL_X, PIXEL_Y=>PIXEL_Y,
				BUTTON_1=>BUTTON_1, BUTTON_2=>BUTTON_2,
				CLK => VSYNC_sig,
                GRAPH_RGB=>RGB_NEXT,
				LED=>LED);
   -- RGB buffer
   process (CLK)
   begin
      if (CLK'event and CLK='1') then
         if (PIXEL_TICK='1') then
            RGB_REG <= RGB_NEXT;
         end if;
      end if;
   end process;
   RGB <= RGB_REG;
   VSYNC <= VSYNC_sig;
end arch;