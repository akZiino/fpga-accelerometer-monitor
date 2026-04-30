library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.ALL;
use IEEE.std_logic_textio.ALL;

entity bin2BCD_tb is
end bin2BCD_tb;

architecture Behavioral of bin2BCD_tb is
    component bin2BCD is
        Port (
            bin_in    : in  STD_LOGIC_VECTOR(11 downto 0);
            sign_out  : out STD_LOGIC;
            thousands : out STD_LOGIC_VECTOR(3 downto 0);
            hundreds  : out STD_LOGIC_VECTOR(3 downto 0);
            tens      : out STD_LOGIC_VECTOR(3 downto 0);
            ones      : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal bin_in    : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal sign_out  : STD_LOGIC;
    signal thousands : STD_LOGIC_VECTOR(3 downto 0);
    signal hundreds  : STD_LOGIC_VECTOR(3 downto 0);
    signal tens      : STD_LOGIC_VECTOR(3 downto 0);
    signal ones      : STD_LOGIC_VECTOR(3 downto 0);

begin
    UUT: bin2BCD
        port map (
            bin_in    => bin_in,
            sign_out  => sign_out,
            thousands => thousands,
            hundreds  => hundreds,
            tens      => tens,
            ones      => ones
        );

    stimulus: process
        variable current_line : line;
        variable signed_value : integer;
        variable magnitude    : integer;
        variable exp_sign     : STD_LOGIC;
        variable exp_thou     : integer;
        variable exp_hund     : integer;
        variable exp_tens     : integer;
        variable exp_ones     : integer;
    begin
        report "Starting comprehensive Stage 1b testbench for bin2BCD" severity note;

        for i in 0 to 4095 loop
            bin_in <= std_logic_vector(to_unsigned(i, 12));
            wait for 10 ns;

            signed_value := to_integer(signed(bin_in));
            if signed_value < 0 then
                exp_sign  := '1';
                magnitude := -signed_value;
            else
                exp_sign  := '0';
                magnitude := signed_value;
            end if;

            exp_thou := magnitude / 1000;
            exp_hund := (magnitude mod 1000) / 100;
            exp_tens := (magnitude mod 100) / 10;
            exp_ones := magnitude mod 10;

            assert sign_out = exp_sign
                report "Sign mismatch for input " & integer'image(signed_value)
                severity error;

            assert to_integer(unsigned(thousands)) = exp_thou
                report "Thousands mismatch for input " & integer'image(signed_value)
                severity error;

            assert to_integer(unsigned(hundreds)) = exp_hund
                report "Hundreds mismatch for input " & integer'image(signed_value)
                severity error;

            assert to_integer(unsigned(tens)) = exp_tens
                report "Tens mismatch for input " & integer'image(signed_value)
                severity error;

            assert to_integer(unsigned(ones)) = exp_ones
                report "Ones mismatch for input " & integer'image(signed_value)
                severity error;

            if (i mod 512) = 0 then
                write(current_line, string'("Checked input value: "));
                write(current_line, signed_value);
                writeline(output, current_line);
            end if;
        end loop;

        report "All 4096 test vectors completed successfully" severity note;
        wait;
    end process;
end Behavioral;
