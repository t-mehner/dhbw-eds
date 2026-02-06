----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/04/2026 04:49:51 PM
-- Design Name: 
-- Module Name: TEXT_DISPLAY - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.text_types_pkg.all;

entity TEXT_DISPLAY is
    Generic (
        X_L : integer := 0;
        Y_O : integer := 0;
        LENGTH : integer := 4;
        STRETCH : integer := 0 );
    Port ( PIX_X : in UNSIGNED(9 downto 0);
           PIX_Y : in UNSIGNED(9 downto 0);
           TEXT_IN : text_array_t(0 to LENGTH-1);
           ROM_INPUT : in STD_LOGIC_VECTOR( 7 downto 0 );
           ROM_ACCESS : out STD_LOGIC;
           ROM_ADDR : out STD_LOGIC_VECTOR(10 downto 0);
           TEXT_ON : out STD_LOGIC          
           );
end TEXT_DISPLAY;

architecture Behavioral of TEXT_DISPLAY is
    constant X_R : integer := X_L+LENGTH*8*(2**STRETCH)-(2**STRETCH);
    constant Y_U : integer := Y_O+15*(2**STRETCH);
begin

rom_access_proc : process(PIX_X, PIX_Y)
    variable dx : unsigned(9 downto 0);
    variable dy : unsigned(9 downto 0);
    variable char_idx : integer range 0 to LENGTH-1;
    variable row_in_char : unsigned(3 downto 0);
begin
    if (PIX_X+1 >= X_L) and (PIX_X+1 < X_R) and
       (PIX_Y >= Y_O) and (PIX_Y < Y_U) then
       
        dx := PIX_X+1 - X_L;
        dy := PIX_Y - Y_O;

        char_idx    := to_integer(dx(9 downto 3+STRETCH));  -- /8/STRETCH  weil Buchstabenbreite und Streckfaktor  
        row_in_char := dy(3+STRETCH downto STRETCH);        -- /STRETCH weil Streckfaktor

        -- Adresse = ASCII(7) & ROW(4) = 11 Bit
        ROM_ACCESS <= '1';
        ROM_ADDR <= TEXT_IN(char_idx) & std_logic_vector(row_in_char);
    else
        ROM_ACCESS <= '0';
        ROM_ADDR <= (others=>'0');
    end if;    
end process rom_access_proc;

text_on_proc : process(PIX_X, PIX_Y, ROM_INPUT)
    variable col_in_char_r : unsigned(2 downto 0);
begin
    -- Pong Title
    if (PIX_X >= X_L) and (PIX_X < X_R) and
       (PIX_Y >= Y_O) and (PIX_Y < Y_U) then
        col_in_char_r := PIX_X(2+STRETCH downto STRETCH) - to_unsigned(X_L,10)(2+STRETCH downto STRETCH);
        TEXT_ON <= ROM_INPUT(7 - to_integer(col_in_char_r));
    else
        TEXT_ON <= '0';
    end if;    
end process text_on_proc;

end Behavioral;
