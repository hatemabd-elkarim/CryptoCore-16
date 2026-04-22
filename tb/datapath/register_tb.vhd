library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_register_file is
end tb_register_file;

architecture Behavioral of tb_register_file is

    signal clock  : std_logic := '0';
    signal reset  : std_logic := '0';
    signal RdWEn  : std_logic := '0';

    signal RES    : std_logic_vector(15 downto 0) := (others => '0');
    signal Ra     : std_logic_vector(3 downto 0) := (others => '0');
    signal Rb     : std_logic_vector(3 downto 0) := (others => '0');
    signal Rd     : std_logic_vector(3 downto 0) := (others => '0');

    signal SRCa   : std_logic_vector(15 downto 0);
    signal SRCb   : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;

begin

    DUT: entity register_file
        port map (
            clock => clock,
            reset => reset,
            RdWEn => RdWEn,
            RES   => RES,
            Ra    => Ra,
            Rb    => Rb,
            Rd    => Rd,
            SRCa  => SRCa,
            SRCb  => SRCb
        );

    -- =========================================================
    -- Clock
    -- =========================================================
    clk_process : process
    begin
        while true loop
            clock <= '0';
            wait for clk_period/2;
            clock <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- =========================================================
    -- Stimulus
    -- =========================================================
    stim_proc : process
    begin

        -- =====================================================
        -- 1) TEST READ (Before reset: Initial values, After reset: x0000)
        -- =====================================================
        -- Reading REG[1] and REG[2]
        Ra <= "0001";  -- REG[1] = x"C505"
        Rb <= "0010";  -- REG[2] = x"3C07"

        wait for clk_period;

        -- Check results
        assert (SRCa = x"C505")
        report "Error in reading REG[1]" severity error;

        assert (SRCb = x"3C07")
        report "Error in reading REG[2]" severity error;
		

        -- Reset
        reset <= '1';
        wait for clk_period;
        reset <= '0';
		
		-- Check results
        assert (SRCa = x"0000")
        report "Error in reading REG[1]" severity error;

        assert (SRCb = x"0000")
        report "Error in reading REG[2]" severity error;
		
        -- =====================================================
        -- 2) TEST WRITE
        -- =====================================================
        -- Write x"AAAA" into REG[3]
        Rd    <= "0011";
        RES   <= x"AAAA";
        RdWEn <= '1';
		
		wait for clk_period;
		
		RES <= x"1234";
        RdWEn <= '0';
		wait for clk_period;
		
        -- =====================================================
        -- 3) VERIFY WRITE (Read after write)
        -- =====================================================
        Ra <= "0011";  -- Read REG[3]

        wait for clk_period;

        assert (SRCa = x"AAAA")	-- asyncronous read
        report "Write failed in REG[3]" severity error;

        -- =====================================================
        -- 4) TEST ANOTHER WRITE
        -- =====================================================
        -- Write x"1234" into REG[15]
        Rd    <= "1111";
        RES   <= x"1234";
        RdWEn <= '1';

        wait for clk_period; 
		
		RES <= x"AAAA";
        RdWEn <= '0';
		wait for clk_period;
		
        -- Read back REG[15]
        Ra <= "1111";

        wait for clk_period;

        assert (SRCa = x"1234")	-- asyncronous read
        report "Write failed in REG[15]" severity error;

        wait;
    end process;

end Behavioral;