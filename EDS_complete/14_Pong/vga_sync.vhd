-- Listing 12.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity VGA_SYNC is
   port(
      CLK, RESET: in std_logic;
      HSYNC, VSYNC: out std_logic;
      VIDEO_ON, P_TICK: out std_logic;
      PIXEL_X, PIXEL_Y: out std_logic_vector (9 downto 0)
    );
end VGA_SYNC;

architecture arch of VGA_SYNC is
   -- VGA 640-by-480 sync parameters
   constant HD: integer:=640; --horizontal display area
   constant HF: integer:=16 ; --h. front porch
   constant HB: integer:=48 ; --h. back porch
   constant HR: integer:=96 ; --h. retrace
   constant VD: integer:=480; --vertical display area
   constant VF: integer:=10;  --v. front porch
   constant VB: integer:=33;  --v. back porch
   constant VR: integer:=2;   --v. retrace
   -- mod-2 counter
   signal MOD2_REG, MOD2_NEXT: std_logic;
   -- sync counters
   signal V_COUNT_REG, V_COUNT_NEXT: unsigned(9 downto 0);
   signal H_COUNT_REG, H_COUNT_NEXT: unsigned(9 downto 0);
   -- output buffer
   signal V_SYNC_REG, H_SYNC_REG: std_logic;
   signal V_SYNC_NEXT, H_SYNC_NEXT: std_logic;
   -- status signal
   signal H_END, V_END, PIXEL_TICK: std_logic;
begin
   -- registers
   process (CLK,RESET)
   begin
      if RESET='1' then
         MOD2_REG <= '0';
         V_COUNT_REG <= (others=>'0');
         H_COUNT_REG <= (others=>'0');
         V_SYNC_REG <= '0';
         H_SYNC_REG <= '0';
      elsif (CLK'event and CLK='1') then
         MOD2_REG <= MOD2_NEXT;
         V_COUNT_REG <= V_COUNT_NEXT;
         H_COUNT_REG <= H_COUNT_NEXT;
         V_SYNC_REG <= V_SYNC_NEXT;
         H_SYNC_REG <= H_SYNC_NEXT;
      end if;
   end process;
   -- mod-2 circuit to generate 25 MHz enable tick
   MOD2_NEXT <= not MOD2_REG;
   -- 25 MHz pixel tick
   PIXEL_TICK <= '1' when MOD2_REG='1' else '0';
   -- status
   H_END <=  -- end of horizontal counter
      '1' when H_COUNT_REG=(HD+HF+HB+HR-1) else --799
      '0';
   V_END <=  -- end of vertical counter
      '1' when V_COUNT_REG=(VD+VF+VB+VR-1) else --524
      '0';
   -- mod-800 horizontal sync counter
   process (H_COUNT_REG,H_END,PIXEL_TICK)
   begin
      if PIXEL_TICK='1' then  -- 25 MHz tick
         if H_END='1' then
            H_COUNT_NEXT <= (others=>'0');
         else
            H_COUNT_NEXT <= H_COUNT_REG + 1;
         end if;
      else
         H_COUNT_NEXT <= H_COUNT_REG;
      end if;
   end process;
   -- mod-525 vertical sync counter
   process (V_COUNT_REG,H_END,V_END,PIXEL_TICK)
   begin
      if PIXEL_TICK='1' and H_END='1' then
         if (V_END='1') then
            V_COUNT_NEXT <= (others=>'0');
         else
            V_COUNT_NEXT <= V_COUNT_REG + 1;
         end if;
      else
         V_COUNT_NEXT <= V_COUNT_REG;
      end if;
   end process;
   -- horizontal and vertical sync, buffered to avoid glitch
   H_SYNC_NEXT <=
      '1' when (H_COUNT_REG>=(HD+HF))           --656
           and (H_COUNT_REG<=(HD+HF+HR-1)) else --751
      '0';
   V_SYNC_NEXT <=
      '1' when (V_COUNT_REG>=(VD+VF))           --490
           and (V_COUNT_REG<=(VD+VF+VR-1)) else --491
      '0';
   -- video on/off
   VIDEO_ON <=
      '1' when (H_COUNT_REG<HD) and (V_COUNT_REG<VD) else
      '0';
   -- output signal
   HSYNC <= H_SYNC_REG;
   VSYNC <= V_SYNC_REG;
   PIXEL_X <= std_logic_vector(H_COUNT_REG);
   PIXEL_Y <= std_logic_vector(V_COUNT_REG);
   P_TICK <= PIXEL_TICK;
end arch;
