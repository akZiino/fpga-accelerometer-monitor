library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    Port (
        digit_sel : in  STD_LOGIC_VECTOR(2 downto 0);
        sign_in   : in  STD_LOGIC;
        thousands : in  STD_LOGIC_VECTOR(3 downto 0);
        hundreds  : in  STD_LOGIC_VECTOR(3 downto 0);
        tens      : in  STD_LOGIC_VECTOR(3 downto 0);
        ones      : in  STD_LOGIC_VECTOR(3 downto 0);
        mux_out   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end mux;

architecture Behavioral of mux is
begin
    process(digit_sel, sign_in, thousands, hundreds, tens, ones)
    begin
        case digit_sel is
            when "000" => mux_out <= ones;
            when "001" => mux_out <= tens;
            when "010" => mux_out <= hundreds;
            when "011" => mux_out <= thousands;
            when "100" =>
                if sign_in = '1' then
                    mux_out <= "1010"; -- minus sign
                else
                    mux_out <= "1111"; -- blank
                end if;
            when others => mux_out <= "1111";
        end case;
    end process;
end Behavioral;
