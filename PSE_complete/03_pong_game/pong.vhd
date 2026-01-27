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
        GRAPH_RGB: out std_logic_vector(11 downto 0);
        LIVES: out std_logic_vector(2 downto 0);
        POINTS: out UNSIGNED(11 downto 0) );
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
   signal   BALL_X_L_NEXT, BALL_X_L_REG : unsigned(9 downto 0) := to_unsigned(300, 10);
   signal   BALL_X_R_NEXT, BALL_X_R_REG : unsigned(9 downto 0) := to_unsigned(308, 10);
   signal   BALL_Y_O_NEXT, BALL_Y_O_REG : unsigned(9 downto 0) := to_unsigned(200, 10);
   signal   BALL_Y_U_NEXT, BALL_Y_U_REG : unsigned(9 downto 0) := to_unsigned(208, 10);
   signal   BALL_RGB:  std_logic_vector(11 downto 0):= "111100000000"; -- Ballfarbe: Rot
   signal   BALL_ON:   std_logic;
   signal   BALL_UP_NEXT, BALL_UP_REG : std_logic := '1';
   signal   BALL_LEFT_NEXT, BALL_LEFT_REG : std_logic := '1';
   constant BALL_SPEED : integer := 2;

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
-- Game State Machine
----------------------------------------------
   type state_type is (TITLE_1, TITLE_2, LIVES_3, LIVES_2, LIVES_1, GAME_OVER_1, GAME_OVER_2);
   signal STATE_REG, STATE_NEXT : state_type := TITLE_1;
	
   signal sig_POINTS : unsigned (11 downto 0) := to_unsigned(0,12); 
----------------------------------------------
-- hier geht es los
----------------------------------------------   
 begin
 
 ---------------------------------------------
-- Spiellogik
----------------------------------------------
state_transition : process( BTN_U, BTN_D, BALL_X_L_REG )
begin
    case STATE_REG is
        when TITLE_1 =>
            if BTN_U = '0' and BTN_D = '0' then
                STATE_NEXT <= TITLE_2;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when TITLE_2 =>
            if BTN_U = '1' or BTN_D = '1' then
                STATE_NEXT <= LIVES_3;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when LIVES_3 =>
            if BALL_X_L_REG >= MAX_X and BALL_X_L_REG <= MAX_X+BALL_SPEED then
                STATE_NEXT <= LIVES_2;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when LIVES_2 =>
            if BALL_X_L_REG >= MAX_X and BALL_X_L_REG <= MAX_X+BALL_SPEED then
                STATE_NEXT <= LIVES_1;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when LIVES_1 =>
            if BALL_X_L_REG >= MAX_X and BALL_X_L_REG <= MAX_X+BALL_SPEED then
                STATE_NEXT <= GAME_OVER_1;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when GAME_OVER_1 =>
            if BTN_U = '0' and BTN_D = '0' then
                STATE_NEXT <= GAME_OVER_2;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when GAME_OVER_2 =>
            if BTN_U = '1' or BTN_D = '1' then
                STATE_NEXT <= TITLE_1;
            else
                STATE_NEXT <= STATE_REG;
            end if;
        when others =>
            STATE_NEXT <= TITLE_1;
    end case;                            
end process state_transition;

proc_points: process(STATE_REG, BALL_LEFT_REG)
begin
    if STATE_REG = TITLE_1 then
        sig_POINTS <= to_unsigned(0,12);
    elsif rising_edge(BALL_LEFT_REG) then
        sig_POINTS <= sig_POINTS + 1;
    end if;
end process proc_points;

POINTS <= sig_POINTS;

proc_lives: process(STATE_REG)
begin
    case STATE_REG is
        when TITLE_1 =>
            LIVES <= "111";
        when TITLE_2 =>
            LIVES <= "111";
        when LIVES_3 =>
            LIVES <= "111";
        when LIVES_2 =>
            LIVES <= "011";
        when LIVES_1 =>
            LIVES <= "001";
        when GAME_OVER_1 =>
            LIVES <= "000";
        when GAME_OVER_2 =>
            LIVES <= "000";
        when others =>
            LIVES <= "010";
    end case;        
end process proc_lives;
---------------------------------------------
-- Bewegung
----------------------------------------------
movement: process(RST, CLK) 
begin
    if RST = '1' then
        STATE_REG     <= TITLE_1;
    
        BAR_Y_O_REG   <= to_unsigned(200, 10);
        BAR_Y_U_REG   <= to_unsigned(264, 10);
        
        BALL_Y_O_REG  <= to_unsigned(200,10);
        BALL_Y_U_REG  <= to_unsigned(208,10);
        BALL_X_L_REG  <= to_unsigned(300,10);
        BALL_X_R_REG  <= to_unsigned(308,10);
        BALL_UP_REG   <= '1';
        BALL_LEFT_REG <= '1';
    elsif rising_edge(CLK) then
        STATE_REG     <= STATE_NEXT;
    
        BAR_Y_O_REG   <= BAR_Y_O_NEXT;
        BAR_Y_U_REG   <= BAR_Y_U_NEXT; 
        
        BALL_Y_O_REG  <= BALL_Y_O_NEXT;
        BALL_Y_U_REG  <= BALL_Y_U_NEXT;
        BALL_X_L_REG  <= BALL_X_L_NEXT;
        BALL_X_R_REG  <= BALL_X_R_NEXT;
        BALL_UP_REG   <= BALL_UP_NEXT;
        BALL_LEFT_REG <= BALL_LEFT_NEXT;
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

ball: process(BALL_Y_O_REG, BALL_X_L_REG, BALL_LEFT_REG, BALL_UP_REG)
begin
        if STATE_REG = LIVES_3 or 
           STATE_REG = LIVES_2 or 
           STATE_REG = LIVES_1 then
        if BALL_LEFT_REG = '1' then
            if BALL_X_L_REG > WALL_X_R + BALL_SPEED then
                BALL_X_L_NEXT <= BALL_X_L_REG - BALL_SPEED;
                BALL_X_R_NEXT <= BALL_X_L_REG - BALL_SPEED + 8;
                BALL_LEFT_NEXT <= '1';
            else
                BALL_X_L_NEXT <= to_unsigned(WALL_X_R + 1,10);
                BALL_X_R_NEXT <= to_unsigned(WALL_X_R + 9,10);
                BALL_LEFT_NEXT <= '0';
            end if;
        else
            if BALL_X_R_REG >= BAR_X_L and
               BALL_X_L_REG < BAR_X_R and
               BALL_Y_O_REG < BAR_Y_U_REG and 
               BALL_Y_U_REG > BAR_Y_O_REG then
                BALL_X_L_NEXT <= BALL_X_L_REG;
                BALL_X_R_NEXT <= BALL_X_L_REG+8;
                BALL_LEFT_NEXT <= '1';
            else
                BALL_X_L_NEXT <= BALL_X_L_REG + BALL_SPEED;
                BALL_X_R_NEXT <= BALL_X_L_REG + BALL_SPEED + 8;
                BALL_LEFT_NEXT <= '0';  
            end if;             
        end if;        
        
        if BALL_UP_REG = '1' then
            if BALL_Y_O_REG > BALL_SPEED then
                BALL_Y_O_NEXT <= BALL_Y_O_REG - BALL_SPEED;
                BALL_Y_U_NEXT <= BALL_Y_O_REG - BALL_SPEED + 8;
                BALL_UP_NEXT <= '1';
            else
                BALL_Y_O_NEXT <= BALL_Y_O_REG;
                BALL_Y_U_NEXT <= BALL_Y_O_REG+8;
                BALL_UP_NEXT <= '0';
            end if;
        else
            if BALL_Y_U_REG <= 480 - BALL_SPEED then
                BALL_Y_O_NEXT <= BALL_Y_O_REG + BALL_SPEED;
                BALL_Y_U_NEXT <= BALL_Y_O_REG + BALL_SPEED + 8;
                BALL_UP_NEXT <= '0';
            else
                BALL_Y_O_NEXT <= BALL_Y_O_REG;
                BALL_Y_U_NEXT <= BALL_Y_O_REG + 8;
                BALL_UP_NEXT <= '1';
            end if;             
        end if;
    else
        BALL_Y_O_NEXT  <= to_unsigned(200,10);
        BALL_Y_U_NEXT  <= to_unsigned(208,10);
        BALL_X_L_NEXT  <= to_unsigned(300,10);
        BALL_X_R_NEXT  <= to_unsigned(308,10);
        BALL_UP_NEXT   <= '1';
        BALL_LEFT_NEXT <= '1';
    end if;
end process ball;
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
        '1' when (PIX_X >= BALL_X_L_REG) and (PIX_X < BALL_X_R_REG) and
                 (PIX_Y >= BALL_Y_O_REG) and (PIX_Y < BALL_Y_U_REG) else
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
