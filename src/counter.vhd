library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Port (
        clk_tick  : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        digit_sel : out STD_LOGIC_VECTOR(2 downto 0)
    );
end counter;

architecture Behavioral of counter is
    signal count : unsigned(2 downto 0) := (others => '0');
begin
    process(clk_tick, reset)
    begin
        if reset = '1' then
            count <= (others => '0');
        elsif rising_edge(clk_tick) then
            if count = 4 then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    digit_sel <= std_logic_vector(count);
end Behavioral;
