library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package text_types_pkg is
  -- a string of characters
  type text_array_t is array (natural range <>) of std_logic_vector(6 downto 0);
end package;
