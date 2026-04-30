library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2BCD is
    Port (
        bin_in    : in  STD_LOGIC_VECTOR(11 downto 0);
        sign_out  : out STD_LOGIC;
        thousands : out STD_LOGIC_VECTOR(3 downto 0);
        hundreds  : out STD_LOGIC_VECTOR(3 downto 0);
        tens      : out STD_LOGIC_VECTOR(3 downto 0);
        ones      : out STD_LOGIC_VECTOR(3 downto 0)
    );
end bin2BCD;

architecture Behavioral of bin2BCD is
begin
    process(bin_in)
        variable mag    : unsigned(11 downto 0);
        variable bcd    : unsigned(15 downto 0);
        variable tmp_in : unsigned(11 downto 0);
    begin
        if bin_in(11) = '1' then
            sign_out <= '1';
            mag := unsigned(not bin_in) + 1;
        else
            sign_out <= '0';
            mag := unsigned(bin_in);
        end if;

        bcd := (others => '0');
        tmp_in := mag;

        for i in 0 to 11 loop
            if bcd(15 downto 12) > 4 then
                bcd(15 downto 12) := bcd(15 downto 12) + 3;
            end if;
            if bcd(11 downto 8) > 4 then
                bcd(11 downto 8) := bcd(11 downto 8) + 3;
            end if;
            if bcd(7 downto 4) > 4 then
                bcd(7 downto 4) := bcd(7 downto 4) + 3;
            end if;
            if bcd(3 downto 0) > 4 then
                bcd(3 downto 0) := bcd(3 downto 0) + 3;
            end if;

            bcd := bcd(14 downto 0) & tmp_in(11);
            tmp_in := tmp_in(10 downto 0) & '0';
        end loop;

        thousands <= std_logic_vector(bcd(15 downto 12));
        hundreds  <= std_logic_vector(bcd(11 downto 8));
        tens      <= std_logic_vector(bcd(7 downto 4));
        ones      <= std_logic_vector(bcd(3 downto 0));
    end process;
end Behavioral;
