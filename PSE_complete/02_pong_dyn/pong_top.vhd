-- Top module for PONG
-- static
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PONG is
   port (
      CLK,RESET: in std_logic;
      BTN_U, BTN_D: in std_logic;
      HSYNC, VSYNC: out  std_logic;
      R, G, B: out std_logic_vector(3 downto 0)
   );
end PONG;

architecture arch of PONG is
   signal PIX_X, PIX_Y: UNSIGNED (9 downto 0);
   signal VIDEO_ON, PIXEL_CLK: std_logic;
   signal RGB_REG, RGB_NEXT: std_logic_vector(11 downto 0);
   signal VSYNC_sig : std_logic;
begin
   -- instantiate VGA sync
   VGA_UNIT: entity work.VGA_SYNC
      port map(CLK=>CLK, 
               RESET=>RESET,
               VIDEO_ON=>VIDEO_ON, 
               p_tick=>PIXEL_CLK,
               HSYNC=>HSYNC, 
               VSYNC=>VSYNC_sig,
               PIX_X=>PIX_X, 
               PIX_Y=>PIX_Y);
   VSYNC <= VSYNC_sig;
   
   -- instantiate graphic 
   PONG_UNIT: entity work.PONG1
      port map (VIDEO_ON=>VIDEO_ON,
                PIX_X=>PIX_X, 
                PIX_Y=>PIX_Y,
                BTN_U => BTN_U,
                BTN_D => BTN_D,
                RST => RESET,
                CLK => VSYNC_sig,
                GRAPH_RGB=>RGB_NEXT);
                
   -- RGB buffer
   process (PIXEL_CLK)
   begin
      if (rising_edge(PIXEL_CLK) ) then
        RGB_REG <= RGB_NEXT;
      end if;
   end process;
   
   R <= RGB_REG(11 downto 8);
   G <= RGB_REG(7 downto 4);
   B <= RGB_REG(3 downto 0);
end arch;