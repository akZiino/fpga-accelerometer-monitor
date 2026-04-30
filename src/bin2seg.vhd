library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin2seg is
    Port (
        x   : in  STD_LOGIC_VECTOR(3 downto 0);
        seg : out STD_LOGIC_VECTOR(6 downto 0)
    );
end bin2seg;

architecture Behavioral of bin2seg is
begin
    -- Active-low 7-segment patterns, segment order CA..CG
    with x select
        seg <= "0000001" when "0000", -- 0
               "1001111" when "0001", -- 1
               "0010010" when "0010", -- 2
               "0000110" when "0011", -- 3
               "1001100" when "0100", -- 4
               "0100100" when "0101", -- 5
               "0100000" when "0110", -- 6
               "0001111" when "0111", -- 7
               "0000000" when "1000", -- 8
               "0000100" when "1001", -- 9
               "1111110" when "1010", -- minus sign
               "1111111" when others;  -- blank
end Behavioral;
