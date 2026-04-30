library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_select is
    Port (
        sw15      : in  STD_LOGIC;
        sw_value  : in  STD_LOGIC_VECTOR(11 downto 0);
        acc_value : in  STD_LOGIC_VECTOR(11 downto 0);
        data_out  : out STD_LOGIC_VECTOR(11 downto 0)
    );
end input_select;

architecture Behavioral of input_select is
begin
    data_out <= sw_value when sw15 = '1' else acc_value;
end Behavioral;
