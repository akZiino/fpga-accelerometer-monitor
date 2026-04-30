library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DAnC is
    Port (
        digit_sel : in  STD_LOGIC_VECTOR(2 downto 0);
        AN        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end DAnC;

architecture Behavioral of DAnC is
begin
    process(digit_sel)
    begin
        case digit_sel is
            when "000" => AN <= "11111110"; -- rightmost digit
            when "001" => AN <= "11111101";
            when "010" => AN <= "11111011";
            when "011" => AN <= "11110111";
            when "100" => AN <= "11101111"; -- sign digit
            when others => AN <= "11111111";
        end case;
    end process;
end Behavioral;
