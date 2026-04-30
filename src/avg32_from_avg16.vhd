library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity avg32_from_avg16 is
    Port (
        CLK      : in  STD_LOGIC;
        RESET    : in  STD_LOGIC;
        DATA_RDY : in  STD_LOGIC;
        X_IN     : in  STD_LOGIC_VECTOR(11 downto 0);
        Y_IN     : in  STD_LOGIC_VECTOR(11 downto 0);
        Z_IN     : in  STD_LOGIC_VECTOR(11 downto 0);
        X_OUT    : out STD_LOGIC_VECTOR(11 downto 0);
        Y_OUT    : out STD_LOGIC_VECTOR(11 downto 0);
        Z_OUT    : out STD_LOGIC_VECTOR(11 downto 0)
    );
end avg32_from_avg16;

architecture Behavioral of avg32_from_avg16 is
    signal drdy_d   : STD_LOGIC := '0';
    signal first_x  : signed(11 downto 0) := (others => '0');
    signal first_y  : signed(11 downto 0) := (others => '0');
    signal first_z  : signed(11 downto 0) := (others => '0');
    signal have_one : STD_LOGIC := '0';

    signal x_reg    : signed(11 downto 0) := (others => '0');
    signal y_reg    : signed(11 downto 0) := (others => '0');
    signal z_reg    : signed(11 downto 0) := (others => '0');
begin
    process(CLK)
        variable sx : signed(12 downto 0);
        variable sy : signed(12 downto 0);
        variable sz : signed(12 downto 0);
    begin
        if rising_edge(CLK) then
            drdy_d <= DATA_RDY;

            if RESET = '1' then
                first_x  <= (others => '0');
                first_y  <= (others => '0');
                first_z  <= (others => '0');
                x_reg    <= (others => '0');
                y_reg    <= (others => '0');
                z_reg    <= (others => '0');
                have_one <= '0';
            elsif (DATA_RDY = '1' and drdy_d = '0') then
                if have_one = '0' then
                    first_x  <= signed(X_IN);
                    first_y  <= signed(Y_IN);
                    first_z  <= signed(Z_IN);
                    have_one <= '1';
                else
                    sx := resize(first_x, 13) + resize(signed(X_IN), 13);
                    sy := resize(first_y, 13) + resize(signed(Y_IN), 13);
                    sz := resize(first_z, 13) + resize(signed(Z_IN), 13);

                    x_reg <= resize(shift_right(sx, 1), 12);
                    y_reg <= resize(shift_right(sy, 1), 12);
                    z_reg <= resize(shift_right(sz, 1), 12);

                    have_one <= '0';
                end if;
            end if;
        end if;
    end process;

    X_OUT <= std_logic_vector(x_reg);
    Y_OUT <= std_logic_vector(y_reg);
    Z_OUT <= std_logic_vector(z_reg);
end Behavioral;
