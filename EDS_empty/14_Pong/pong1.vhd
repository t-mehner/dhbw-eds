----------------------------------------------
-- Statisches Pong 
-- rechteckiger Ball
----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PONG1 is
   port(VIDEO_ON: in std_logic;
        PIXEL_X,PIXEL_Y: in std_logic_vector(9 downto 0);
		BUTTON_1, BUTTON_2: in std_logic;
		CLK : in std_logic;
        GRAPH_RGB: out std_logic_vector(2 downto 0);
		LED: out std_logic_vector(2 downto 0) );
end PONG1;

architecture arch of PONG1 is
	signal PIX_X, PIX_Y: unsigned(9 downto 0); -- X Y Koordinaten (0,0)-> (639,479)
	constant MAX_X: integer:=640;
	constant MAX_Y: integer:=480;
----------------------------------------------
-- langer senkrechter Strich als Wand
----------------------------------------------
	constant WALL_X_L: integer:=32;
	constant WALL_X_R: integer:=39;
	constant WALL_RGB:  std_logic_vector(2 downto 0):= "001"; -- Wandfarbe: Blau
	signal   WALL_ON:   std_logic;
	
----------------------------------------------
-- Bar
----------------------------------------------
	constant BAR_X_L: integer:=600;
	constant BAR_X_R: integer:=607;
	signal 	 BAR_Y_O_REG, BAR_Y_O_NEXT : integer := 200;
	signal 	 BAR_Y_U: integer;
	constant BAR_H:	  integer := 72;
	constant BAR_RGB: std_logic_vector(2 downto 0):= "010"; -- Gruen
	signal   BAR_ON:  std_logic;
	
----------------------------------------------
-- Ball
----------------------------------------------
	signal BALL_X_L_REG, BALL_X_L_NEXT: unsigned(9 downto 0) := to_unsigned(300,10);
	signal BALL_X_R: unsigned(9 downto 0);
	signal BALL_Y_O_REG, BALL_Y_O_NEXT: unsigned(9 downto 0) := to_unsigned(200,10);
	signal BALL_Y_U: unsigned(9 downto 0);
	constant BALL_H: unsigned(9 downto 0) := to_unsigned(8,10);
	constant BALL_W: unsigned(9 downto 0) := to_unsigned(8,10);
	constant BALL_RGB: std_logic_vector(2 downto 0):= "100"; -- Rot
	signal BALL_ON:  std_logic;
	
	signal BALL_LEFT_NEXT, BALL_LEFT_REG: std_logic := '1';
	signal BALL_UP_NEXT, BALL_UP_REG: std_logic := '1';
	
	type MATRIX_8x8_TYPE is array (0 to 7) of std_logic_vector(7 downto 0);
	constant RUND_ARRAY : MATRIX_8x8_TYPE := 
		( "00111100",
		  "01111110",
		  "11111111",
		  "11111111",
		  "11111111",
		  "11111111",
		  "01111110",
		  "00111100" );

	signal RUND_X, RUND_Y : unsigned(2 downto 0);
	signal RUND_ON : STD_LOGIC := '0';

----------------------------------------------
-- FONT-ROM
----------------------------------------------
	constant TEXT_X_L: unsigned(9 downto 0) := to_unsigned(150,10);
	constant TEXT_X_R: unsigned(9 downto 0) := to_unsigned(150+88,10);
	constant TEXT_Y_O: unsigned(9 downto 0) := to_unsigned(10,10);
	constant TEXT_Y_U: unsigned(9 downto 0) := to_unsigned(10+16,10);

	type ROM_TYPE_LETTER is array (0 to 16*27-1)
		of std_Logic_vector(7 downto 0);

	constant CHAR_ROM: ROM_TYPE_LETTER :=
		  (
	   -- code x30
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "11000110", -- 4 **   **
	   "11001110", -- 5 **  ***
	   "11011110", -- 6 ** ****
	   "11110110", -- 7 **** **
	   "11100110", -- 8 ***  **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x31
	   "00000000", -- 0
	   "00000000", -- 1
	   "00011000", -- 2
	   "00111000", -- 3
	   "01111000", -- 4    **
	   "00011000", -- 5   ***
	   "00011000", -- 6  ****
	   "00011000", -- 7    **
	   "00011000", -- 8    **
	   "00011000", -- 9    **
	   "00011000", -- a    **
	   "01111110", -- b    **
	   "00000000", -- c    **
	   "00000000", -- d  ******
	   "00000000", -- e
	   "00000000", -- f
	   -- code x32
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "00000110", -- 4      **
	   "00001100", -- 5     **
	   "00011000", -- 6    **
	   "00110000", -- 7   **
	   "01100000", -- 8  **
	   "11000000", -- 9 **
	   "11000110", -- a **   **
	   "11111110", -- b *******
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x33
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "00000110", -- 4      **
	   "00000110", -- 5      **
	   "00111100", -- 6   ****
	   "00000110", -- 7      **
	   "00000110", -- 8      **
	   "00000110", -- 9      **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x34
	   "00000000", -- 0
	   "00000000", -- 1
	   "00001100", -- 2     **
	   "00011100", -- 3    ***
	   "00111100", -- 4   ****
	   "01101100", -- 5  ** **
	   "11001100", -- 6 **  **
	   "11111110", -- 7 *******
	   "00001100", -- 8     **
	   "00001100", -- 9     **
	   "00001100", -- a     **
	   "00011110", -- b    ****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x35
	   "00000000", -- 0
	   "00000000", -- 1
	   "11111110", -- 2 *******
	   "11000000", -- 3 **
	   "11000000", -- 4 **
	   "11000000", -- 5 **
	   "11111100", -- 6 ******
	   "00000110", -- 7      **
	   "00000110", -- 8      **
	   "00000110", -- 9      **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x36
	   "00000000", -- 0
	   "00000000", -- 1
	   "00111000", -- 2   ***
	   "01100000", -- 3  **
	   "11000000", -- 4 **
	   "11000000", -- 5 **
	   "11111100", -- 6 ******
	   "11000110", -- 7 **   **
	   "11000110", -- 8 **   **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x37
	   "00000000", -- 0
	   "00000000", -- 1
	   "11111110", -- 2 *******
	   "11000110", -- 3 **   **
	   "00000110", -- 4      **
	   "00000110", -- 5      **
	   "00001100", -- 6     **
	   "00011000", -- 7    **
	   "00110000", -- 8   **
	   "00110000", -- 9   **
	   "00110000", -- a   **
	   "00110000", -- b   **
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x38
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "11000110", -- 4 **   **
	   "11000110", -- 5 **   **
	   "01111100", -- 6  *****
	   "11000110", -- 7 **   **
	   "11000110", -- 8 **   **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x39
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "11000110", -- 4 **   **
	   "11000110", -- 5 **   **
	   "01111110", -- 6  ******
	   "00000110", -- 7      **
	   "00000110", -- 8      **
	   "00000110", -- 9      **
	   "00001100", -- a     **
	   "01111000", -- b  ****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	  -- code x53
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "11000110", -- 4 **   **
	   "01100000", -- 5  **
	   "00111000", -- 6   ***
	   "00001100", -- 7     **
	   "00000110", -- 8      **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x63
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "01111100", -- 5  *****
	   "11000110", -- 6 **   **
	   "11000000", -- 7 **
	   "11000000", -- 8 **
	   "11000000", -- 9 **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		-- code x6f
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "01111100", -- 5  *****
	   "11000110", -- 6 **   **
	   "11000110", -- 7 **   **
	   "11000110", -- 8 **   **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	  -- code x72
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "11011100", -- 5 ** ***
	   "01110110", -- 6  *** **
	   "01100110", -- 7  **  **
	   "01100000", -- 8  **
	   "01100000", -- 9  **
	   "01100000", -- a  **
	   "11110000", -- b ****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	  -- code x65
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "01111100", -- 5  *****
	   "11000110", -- 6 **   **
	   "11111110", -- 7 *******
	   "11000000", -- 8 **
	   "11000000", -- 9 **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	  -- code x3a
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00011000", -- 4    **
	   "00011000", -- 5    **
	   "00000000", -- 6
	   "00000000", -- 7
	   "00000000", -- 8
	   "00011000", -- 9    **
	   "00011000", -- a    **
	   "00000000", -- b
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		-- Leerzeichen
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "00000000", -- 5
	   "00000000", -- 6
	   "00000000", -- 7
	   "00000000", -- 8
	   "00000000", -- 9
	   "00000000", -- a
	   "00000000", -- b
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x42
	   "00000000", -- 0
	   "00000000", -- 1
	   "11111100", -- 2 ******
	   "01100110", -- 3  **  **
	   "01100110", -- 4  **  **
	   "01100110", -- 5  **  **
	   "01111100", -- 6  *****
	   "01100110", -- 7  **  **
	   "01100110", -- 8  **  **
	   "01100110", -- 9  **  **
	   "01100110", -- a  **  **
	   "11111100", -- b ******
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x61
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "01111000", -- 5  ****
	   "00001100", -- 6     **
	   "01111100", -- 7  *****
	   "11001100", -- 8 **  **
	   "11001100", -- 9 **  **
	   "11001100", -- a **  **
	   "01110110", -- b  *** **
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	   -- code x6c
	   "00000000", -- 0
	   "00000000", -- 1
	   "00111000", -- 2   ***
	   "00011000", -- 3    **
	   "00011000", -- 4    **
	   "00011000", -- 5    **
	   "00011000", -- 6    **
	   "00011000", -- 7    **
	   "00011000", -- 8    **
	   "00011000", -- 9    **
	   "00011000", -- a    **
	   "00111100", -- b   ****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		
		
		 -- code x50
	   "00000000", -- 0
	   "00000000", -- 1
	   "11111100", -- 2 ******
	   "01100110", -- 3  **  **
	   "01100110", -- 4  **  **
	   "01100110", -- 5  **  **
	   "01111100", -- 6  *****
	   "01100000", -- 7  **
	   "01100000", -- 8  **
	   "01100000", -- 9  **
	   "01100000", -- a  **
	   "11110000", -- b ****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		   -- code x6e
			
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "11011100", -- 5 ** ***
	   "01100110", -- 6  **  **
	   "01100110", -- 7  **  **
	   "01100110", -- 8  **  **
	   "01100110", -- 9  **  **
	   "01100110", -- a  **  **
	   "01100110", -- b  **  **
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
	 
		-- code x67
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "01110110", -- 5  *** **
	   "11001100", -- 6 **  **
	   "11001100", -- 7 **  **
	   "11001100", -- 8 **  **
	   "11001100", -- 9 **  **
	   "11001100", -- a **  **
	   "01111100", -- b  *****
	   "00001100", -- c     **
	   "11001100", -- d **  **
	   "01111000", -- e  ****
	   "00000000", -- f
	  -- code x47
	   "00000000", -- 0
	   "00000000", -- 1
	   "00111100", -- 2   ****
	   "01100110", -- 3  **  **
	   "11000010", -- 4 **    *
	   "11000000", -- 5 **
	   "11000000", -- 6 **
	   "11011110", -- 7 ** ****
	   "11000110", -- 8 **   **
	   "11000110", -- 9 **   **
	   "01100110", -- a  **  **
	   "00111010", -- b   *** *
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		-- code x6d
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "11100110", -- 5 ***  **
	   "11111111", -- 6 ********
	   "11011011", -- 7 ** ** **
	   "11011011", -- 8 ** ** **
	   "11011011", -- 9 ** ** **
	   "11011011", -- a ** ** **
	   "11011011", -- b ** ** **
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		  -- code x4f
	   "00000000", -- 0
	   "00000000", -- 1
	   "01111100", -- 2  *****
	   "11000110", -- 3 **   **
	   "11000110", -- 4 **   **
	   "11000110", -- 5 **   **
	   "11000110", -- 6 **   **
	   "11000110", -- 7 **   **
	   "11000110", -- 8 **   **
	   "11000110", -- 9 **   **
	   "11000110", -- a **   **
	   "01111100", -- b  *****
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000", -- f
		
		   -- code x76
	   "00000000", -- 0
	   "00000000", -- 1
	   "00000000", -- 2
	   "00000000", -- 3
	   "00000000", -- 4
	   "11000011", -- 5 **    **
	   "11000011", -- 6 **    **
	   "11000011", -- 7 **    **
	   "11000011", -- 8 **    **
	   "01100110", -- 9  **  **
	   "00111100", -- a   ****
	   "00011000", -- b    **
	   "00000000", -- c
	   "00000000", -- d
	   "00000000", -- e
	   "00000000" -- f
	 
	);
	
	signal TEXT_ON, LETTER_ON : std_logic := '0';
	signal TEXT_X : unsigned( 6 downto 0 ) := (others=>'0');
	signal TEXT_Y : unsigned( 3 downto 0 ) := (others=>'0');
	signal OFFSET : unsigned( 4 downto 0 ) := (others=>'0');
	signal ROM_Y  : unsigned( 8 downto 0 ) := (others=>'0');
	
	signal BCD_0, BCD_1, BCD_2, BCD_3 : std_logic_vector(3 downto 0);

----------------------------------------------
-- Spiellogik
---------------------------------------------- 
	type state_type is (start_1, start_2, leben_3, leben_2, leben_1, ende_1, ende_2);
	signal STATE_REG, STATE_NEXT : state_type := start_1;
	
	signal PUNKTE : unsigned(9 downto 0) := to_unsigned(0,10);

----------------------------------------------
-- hier geht es los
----------------------------------------------   
 begin  
  
	process (CLK)
	begin
		if rising_edge(CLK)
		then
			BAR_Y_O_REG <= BAR_Y_O_NEXT;
			BALL_Y_O_REG <= BALL_Y_O_NEXT;
			BALL_X_L_REG <= BALL_X_L_NEXT;
			BALL_UP_REG <= BALL_UP_NEXT;
			BALL_LEFT_REG <= BALL_LEFT_NEXT;
			STATE_REG <= STATE_NEXT;
		end if;
	end process;
   
   PIX_X <= unsigned(PIXEL_X);
   PIX_Y <= unsigned(PIXEL_Y);
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
	BAR_Y_U <= BAR_Y_O_NEXT + BAR_H;
	
	BAR_ON <= 
		'1' when (BAR_X_L<=PIX_X) and (PIX_X<=BAR_X_R) and
				 (BAR_Y_O_NEXT<=PIX_Y) and (PIX_Y<=BAR_Y_U) else
		'0';
		
	bar_movement : process(BUTTON_1, BUTTON_2, BAR_Y_O_REG)
	begin
		if( (BUTTON_1 = '1') and (BAR_Y_O_REG < (480-BAR_H-1)) ) then
			BAR_Y_O_NEXT <= BAR_Y_O_REG + 2;
		elsif( (BUTTON_2 = '1') and (BAR_Y_O_REG > 1) ) then
			BAR_Y_O_NEXT <= BAR_Y_O_REG - 2;
		else
			BAR_Y_O_NEXT <= BAR_Y_O_REG;
		end if;
	end process bar_movement;
		
----------------------------------------------
-- Ball
----------------------------------------------
	BALL_X_R <= BALL_X_L_REG + BALL_W;
	BALL_Y_U <= BALL_Y_O_REG + BALL_H;
	
	ball_movement : process( BALL_UP_REG, BALL_LEFT_REG, BALL_X_L_REG, BALL_Y_O_REG, BAR_Y_O_REG, BAR_Y_U, BALL_Y_U )
	begin
		if( STATE_REG = LEBEN_3 or STATE_REG = LEBEN_2 or STATE_REG = LEBEN_1 ) then
			if( BALL_LEFT_REG = '1' ) then
				BALL_X_L_NEXT <= BALL_X_L_REG - 1;
			else
				BALL_X_L_NEXT <= BALL_X_L_REG + 1;
			end if;
			
			if( BALL_UP_REG = '1' ) then
				BALL_Y_O_NEXT <= BALL_Y_O_REG - 1;
			else
				BALL_Y_O_NEXT <= BALL_Y_O_REG + 1;
			end if;
		else
			BALL_X_L_NEXT <= BALL_X_L_REG;
			BALL_Y_O_NEXT <= BALL_Y_O_REG;
		end if;
		
		if( BALL_Y_O_REG = 1 ) then
			BALL_UP_NEXT <= '0';
		elsif( BALL_Y_O_REG = 471 ) then
			BALL_UP_NEXT <= '1';
		else
			BALL_UP_NEXT <= BALL_UP_REG;
		end if;
		
		if( BALL_X_L_REG = 41 ) then
			BALL_LEFT_NEXT <= '0';
		elsif( (BALL_X_L_REG = 591) and (BALL_Y_O_REG > BAR_Y_O_REG) and (BALL_Y_U < BAR_Y_U) ) then
			BALL_LEFT_NEXT <= '1';
		else
			BALL_LEFT_NEXT <= BALL_LEFT_REG;
		end if;
	end process ball_movement;
	
	BALL_ON <= 
		'1' when (BALL_X_L_REG<=PIX_X) and (PIX_X<BALL_X_R) and
				 (BALL_Y_O_REG<=PIX_Y) and (PIX_Y<BALL_Y_U) else
		'0';
		
	RUND_X <= PIX_X(2 downto 0) - BALL_X_L_REG(2 downto 0);
	RUND_Y <= PIX_Y(2 downto 0) - BALL_Y_O_REG(2 downto 0);
	
	RUND_ON <= RUND_ARRAY(to_integer(RUND_X))(to_integer(RUND_Y));
	
----------------------------------------------
-- Text
---------------------------------------------- 
	TEXT_ON <= 
		'1' when (TEXT_X_L<=PIX_X) and (PIX_X<TEXT_X_R) and
				 (TEXT_Y_O<=PIX_Y) and (PIX_Y<TEXT_Y_U) else
		'0';
	
	TEXT_X <= PIX_X(6 downto 0) - TEXT_X_L(6 downto 0);
	TEXT_Y <= PIX_Y(3 downto 0) - TEXT_Y_O(3 downto 0);
	
	OFFSET <= 
		to_unsigned(10,5) when TEXT_X(6 downto 3) = "0000" else
		to_unsigned(11,5) when TEXT_X(6 downto 3) = "0001" else
		to_unsigned(12,5) when TEXT_X(6 downto 3) = "0010" else
		to_unsigned(13,5) when TEXT_X(6 downto 3) = "0011" else
		to_unsigned(14,5) when TEXT_X(6 downto 3) = "0100" else
		to_unsigned(15,5) when TEXT_X(6 downto 3) = "0101" else
		to_unsigned(16,5) when TEXT_X(6 downto 3) = "0110" else
		"0"&unsigned(BCD_3)	when TEXT_X(6 downto 3) = "0111" else
		"0"&unsigned(BCD_2)	when TEXT_X(6 downto 3) = "1000" else
		"0"&unsigned(BCD_1) when TEXT_X(6 downto 3) = "1001" else
		"0"&unsigned(BCD_0);
	
	ROM_Y <= OFFSET & TEXT_Y;
	
	LETTER_ON <= CHAR_ROM(to_integer(ROM_Y))(to_integer(not TEXT_X(2 downto 0)));
	
	bin_bcd_0 : entity work.bin_bcd
	port map(
		NUM => PUNKTE,
		BCD_0 => BCD_0,
		BCD_1 => BCD_1,
		BCD_2 => BCD_2,
		BCD_3 => BCD_3 );
	
----------------------------------------------
-- Zustandsautomat
---------------------------------------------- 

	state_transition : process( STATE_REG, BUTTON_1, BUTTON_2, BALL_X_L_REG )
	begin
		case STATE_REG is
			when start_1 =>
				if( BUTTON_1 = '0' and BUTTON_2 = '0' ) then
					STATE_NEXT <= start_2;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when start_2 =>
				if( BUTTON_1 = '1' or BUTTON_2 = '1' ) then
					STATE_NEXT <= leben_3;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when leben_3 =>
				if( BALL_X_L_REG = 640 ) then
					STATE_NEXT <= leben_2;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when leben_2 =>
				if( BALL_X_L_REG = 640 ) then
					STATE_NEXT <= leben_1;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when leben_1 =>
				if( BALL_X_L_REG = 640 ) then
					STATE_NEXT <= ende_1;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when ende_1 => 
				if( BUTTON_1 = '0' and BUTTON_2 = '0' ) then
					STATE_NEXT <= ende_2;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when ende_2 =>
				if( BUTTON_1 = '1' or BUTTON_2 = '1' ) then
					STATE_NEXT <= start_1;
				else
					STATE_NEXT <= STATE_REG;
				end if;
			when others =>
				STATE_NEXT <= start_1;
		end case;
	end process state_transition;
	
	punkte_process : process( state_reg, punkte, BALL_LEFT_REG )
	begin
		if( state_reg = start_1 ) then
			PUNKTE <= to_unsigned(0, 10);
		elsif( rising_edge( BALL_LEFT_REG ) ) then
			PUNKTE <= PUNKTE + 1;
		end if;
	end process punkte_process;
	
	state_output : process( state_reg )
	begin
		case state_reg is
		when start_1 =>
			LED <= "111";
		when start_2 =>
			LED <= "111";
		when leben_3 =>
			LED <= "111";
		when leben_2 =>
			LED <= "011";
		when leben_1 =>
			LED <= "001";
		when ende_1 =>
			LED <= "000";
		when ende_2 =>
			LED <= "000";
		when others =>
			LED <= "101";
		end case;
	end process state_output;

----------------------------------------------
-- Anzeigeprozess
----------------------------------------------
   process(VIDEO_ON,WALL_ON, BAR_ON, BALL_ON, RUND_ON, TEXT_ON, LETTER_ON)
   begin
      if VIDEO_ON='0' then
          GRAPH_RGB <= "000"; 			-- schwarzer Rahmen
      else
		if WALL_ON='1' then
			GRAPH_RGB <= WALL_RGB;
		elsif BAR_ON='1' then
			GRAPH_RGB <= BAR_RGB;
		elsif (BALL_ON='1') and (RUND_ON='1') then
			GRAPH_RGB <= BALL_RGB;
		elsif (TEXT_ON='1') and (LETTER_ON = '1') then
			GRAPH_RGB <= "101";
        else
            GRAPH_RGB <= "110"; 	   -- Hintergrund: Gelb
         end if;
      end if;
   end process;
end arch;
