library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- ADXL362Ctrl is instantiated directly instead of using ACC_XYZ
-- so that the Data_Ready signal can be used to form an external 32-sample average.
entity display is
    Port (
        CLK100MHZ : in  STD_LOGIC;
        SW        : in  STD_LOGIC_VECTOR(15 downto 0);
        ACL_MISO  : in  STD_LOGIC;
        ACL_MOSI  : out STD_LOGIC;
        ACL_SCLK  : out STD_LOGIC;
        ACL_CSN   : out STD_LOGIC;
        LED16_R   : out STD_LOGIC;
        LED16_G   : out STD_LOGIC;
        LED16_B   : out STD_LOGIC;
        CA        : out STD_LOGIC;
        CB        : out STD_LOGIC;
        CC        : out STD_LOGIC;
        CD        : out STD_LOGIC;
        CE        : out STD_LOGIC;
        CF        : out STD_LOGIC;
        CG        : out STD_LOGIC;
        DP        : out STD_LOGIC;
        AN        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end display;

architecture Structural of display is

    component input_select is
        Port (
            sw15      : in  STD_LOGIC;
            sw_value  : in  STD_LOGIC_VECTOR(11 downto 0);
            acc_value : in  STD_LOGIC_VECTOR(11 downto 0);
            data_out  : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

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

    component bin2seg is
        Port (
            x   : in  STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component clock is
        Port (
            clk_in   : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            tick_4ms : out STD_LOGIC
        );
    end component;

    component counter is
        Port (
            clk_tick  : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            digit_sel : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    component mux is
        Port (
            digit_sel : in  STD_LOGIC_VECTOR(2 downto 0);
            sign_in   : in  STD_LOGIC;
            thousands : in  STD_LOGIC_VECTOR(3 downto 0);
            hundreds  : in  STD_LOGIC_VECTOR(3 downto 0);
            tens      : in  STD_LOGIC_VECTOR(3 downto 0);
            ones      : in  STD_LOGIC_VECTOR(3 downto 0);
            mux_out   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component DAnC is
        Port (
            digit_sel : in  STD_LOGIC_VECTOR(2 downto 0);
            AN        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component ADXL362Ctrl is
        generic (
            SYSCLK_FREQUENCY_HZ : integer := 100000000;
            SCLK_FREQUENCY_HZ   : integer := 1000000;
            NUM_READS_AVG       : integer := 16;
            UPDATE_FREQUENCY_HZ : integer := 1000
        );
        port (
            SYSCLK     : in  STD_LOGIC;
            RESET      : in  STD_LOGIC;
            ACCEL_X    : out STD_LOGIC_VECTOR(11 downto 0);
            ACCEL_Y    : out STD_LOGIC_VECTOR(11 downto 0);
            ACCEL_Z    : out STD_LOGIC_VECTOR(11 downto 0);
            ACCEL_TMP  : out STD_LOGIC_VECTOR(11 downto 0);
            Data_Ready : out STD_LOGIC;
            SCLK       : out STD_LOGIC;
            MOSI       : out STD_LOGIC;
            MISO       : in  STD_LOGIC;
            SS         : out STD_LOGIC
        );
    end component;

    component avg32_from_avg16 is
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
    end component;

    signal reset_sig       : STD_LOGIC := '0';
    signal tick_4ms        : STD_LOGIC;
    signal digit_sel       : STD_LOGIC_VECTOR(2 downto 0);
    signal digit_value     : STD_LOGIC_VECTOR(3 downto 0);
    signal seg_int         : STD_LOGIC_VECTOR(6 downto 0);

    signal sign_bit        : STD_LOGIC;
    signal thousands_bcd   : STD_LOGIC_VECTOR(3 downto 0);
    signal hundreds_bcd    : STD_LOGIC_VECTOR(3 downto 0);
    signal tens_bcd        : STD_LOGIC_VECTOR(3 downto 0);
    signal ones_bcd        : STD_LOGIC_VECTOR(3 downto 0);

    signal accel16_x       : STD_LOGIC_VECTOR(11 downto 0);
    signal accel16_y       : STD_LOGIC_VECTOR(11 downto 0);
    signal accel16_z       : STD_LOGIC_VECTOR(11 downto 0);
    signal accel16_tmp     : STD_LOGIC_VECTOR(11 downto 0);
    signal data_ready      : STD_LOGIC;

    signal accel_x         : STD_LOGIC_VECTOR(11 downto 0);
    signal accel_y         : STD_LOGIC_VECTOR(11 downto 0);
    signal accel_z         : STD_LOGIC_VECTOR(11 downto 0);

    signal accel_x_mg      : STD_LOGIC_VECTOR(11 downto 0);
    signal accel_y_mg      : STD_LOGIC_VECTOR(11 downto 0);
    signal accel_z_mg      : STD_LOGIC_VECTOR(11 downto 0);

    signal selected_acc_mg : STD_LOGIC_VECTOR(11 downto 0);
    signal selected_value  : STD_LOGIC_VECTOR(11 downto 0);

    signal x_s, y_s, z_s   : signed(11 downto 0);
    signal ax, ay, az      : integer;

    constant ACC_RESET_PERIOD_US : integer := 10;
    constant ACC_RESET_IDLE_CLOCKS : integer :=
        ((ACC_RESET_PERIOD_US*1000)/(1000000000/100000000));
    signal cnt_acc_reset : integer range 0 to (ACC_RESET_IDLE_CLOCKS - 1) := 0;
    signal reset_acc     : STD_LOGIC := '1';

begin
    DP <= '1';

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if cnt_acc_reset = (ACC_RESET_IDLE_CLOCKS - 1) then
                cnt_acc_reset <= (ACC_RESET_IDLE_CLOCKS - 1);
                reset_acc <= '0';
            else
                cnt_acc_reset <= cnt_acc_reset + 1;
                reset_acc <= '1';
            end if;
        end if;
    end process;

    ACCEL_BLOCK: ADXL362Ctrl
        generic map (
            SYSCLK_FREQUENCY_HZ => 100000000,
            SCLK_FREQUENCY_HZ   => 1000000,
            NUM_READS_AVG       => 16,
            UPDATE_FREQUENCY_HZ => 100
        )
        port map (
            SYSCLK     => CLK100MHZ,
            RESET      => reset_acc,
            ACCEL_X    => accel16_x,
            ACCEL_Y    => accel16_y,
            ACCEL_Z    => accel16_z,
            ACCEL_TMP  => accel16_tmp,
            Data_Ready => data_ready,
            SCLK       => ACL_SCLK,
            MOSI       => ACL_MOSI,
            MISO       => ACL_MISO,
            SS         => ACL_CSN
        );

    AVG32_BLOCK: avg32_from_avg16
        port map (
            CLK      => CLK100MHZ,
            RESET    => reset_acc,
            DATA_RDY => data_ready,
            X_IN     => accel16_x,
            Y_IN     => accel16_y,
            Z_IN     => accel16_z,
            X_OUT    => accel_x,
            Y_OUT    => accel_y,
            Z_OUT    => accel_z
        );

    -- ADXL362 is used in the ±2g range, so 1 LSB = 1 mg.
    -- Therefore the averaged acceleration values can be used directly as mg values.
    accel_x_mg <= accel_x;
    accel_y_mg <= accel_y;
    accel_z_mg <= accel_z;

    -- SW14:SW13 select which averaged acceleration, expressed in mg, is displayed.
    process(SW, accel_x_mg, accel_y_mg, accel_z_mg)
    begin
        case SW(14 downto 13) is
            when "00" => selected_acc_mg <= accel_x_mg;
            when "01" => selected_acc_mg <= accel_y_mg;
            when "10" => selected_acc_mg <= accel_z_mg;
            when others => selected_acc_mg <= accel_x_mg; -- unused selector state defaults to X
        end case;
    end process;

    -- In accelerometer mode (SW15='0'), the displayed value is the selected averaged acceleration in mg.
    SELECTOR: input_select
        port map (
            sw15      => SW(15),
            sw_value  => SW(11 downto 0),
            acc_value => selected_acc_mg,
            data_out  => selected_value
        );

    BCD_CONV: bin2BCD
        port map (
            bin_in    => selected_value,
            sign_out  => sign_bit,
            thousands => thousands_bcd,
            hundreds  => hundreds_bcd,
            tens      => tens_bcd,
            ones      => ones_bcd
        );

    CLK_SCAN: clock
        port map (
            clk_in   => CLK100MHZ,
            reset    => reset_sig,
            tick_4ms => tick_4ms
        );

    DIGIT_COUNTER: counter
        port map (
            clk_tick  => tick_4ms,
            reset     => reset_sig,
            digit_sel => digit_sel
        );

    DIGIT_MUX: mux
        port map (
            digit_sel => digit_sel,
            sign_in   => sign_bit,
            thousands => thousands_bcd,
            hundreds  => hundreds_bcd,
            tens      => tens_bcd,
            ones      => ones_bcd,
            mux_out   => digit_value
        );

    SEG_DECODER: bin2seg
        port map (
            x   => digit_value,
            seg => seg_int
        );

    ANODE_CTRL: DAnC
        port map (
            digit_sel => digit_sel,
            AN        => AN
        );

    CA <= seg_int(6);
    CB <= seg_int(5);
    CC <= seg_int(4);
    CD <= seg_int(3);
    CE <= seg_int(2);
    CF <= seg_int(1);
    CG <= seg_int(0);

    x_s <= signed(accel_x);
    y_s <= signed(accel_y);
    z_s <= signed(accel_z);

    ax <= abs(to_integer(x_s));
    ay <= abs(to_integer(y_s));
    az <= abs(to_integer(z_s));

    process(x_s, y_s, z_s, ax, ay, az)
    begin
        LED16_R <= '0';
        LED16_G <= '0';
        LED16_B <= '0';

        if ax >= ay and ax >= az then
            if x_s >= 0 then
                LED16_R <= '1';
            else
                LED16_R <= '1';
                LED16_G <= '1';
            end if;
        elsif ay >= ax and ay >= az then
            if y_s >= 0 then
                LED16_G <= '1';
            else
                LED16_G <= '1';
                LED16_B <= '1';
            end if;
        else
            if z_s >= 0 then
                LED16_B <= '1';
            else
                LED16_R <= '1';
                LED16_B <= '1';
            end if;
        end if;
    end process;

end Structural;