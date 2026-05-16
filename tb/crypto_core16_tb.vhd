library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity tb_crypto is
end entity;

architecture behavior of tb_crypto is

    signal clock, reset : std_logic := '0';
    signal CTRL, Ra, Rb, Rd : std_logic_vector(3 downto 0);	 

begin

    DUT: entity work.crypto_core16
        port map(
            clock => clock,
            reset => reset,
            CTRL => CTRL,
            Ra => Ra,
            Rb => Rb,
            Rd => Rd
        );

    -- Clock generation (10 ns period)
    clock_process : process
    begin
        while true loop
            clock <= '0';
            wait for 5 ns;
            clock <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus
    stimulus_process : process
     begin
      wait for 15 ns;
	  -- to cover all tests
      for i in 0 to 15 loop
        CTRL <= std_logic_vector(to_unsigned(i, 4));
        Ra <= "0001";
        Rb <= "0010";
        Rd <= "0011";
        wait for 10 ns;
      end loop;
	  
	  reset <= '1';
	  wait for 10 ns;

      wait;
    end process;
   
end architecture;
