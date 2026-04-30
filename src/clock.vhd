library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock is
    Port (
        clk_in  : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        tick_4ms: out STD_LOGIC
    );
end clock;

architecture Behavioral of clock is
    constant DIVISOR : integer := 400000; -- 100MHz * 4ms
    signal count     : integer range 0 to DIVISOR - 1 := 0;
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                count    <= 0;
                tick_4ms <= '0';
            elsif count = DIVISOR - 1 then
                count    <= 0;
                tick_4ms <= '1';
            else
                count    <= count + 1;
                tick_4ms <= '0';
            end if;
        end if;
    end process;
end Behavioral;
