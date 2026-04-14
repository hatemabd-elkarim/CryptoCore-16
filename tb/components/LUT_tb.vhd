library	ieee;
use ieee.std_logic_1164.all;
use	ieee.numeric_std.all;

entity LUT_tb is
end entity;

architecture sim of LUT_tb is
signal LUT_in, LUT_out : std_logic_vector(7 downto 0);
begin
	DUT : entity LUT port map(LUT_in, LUT_out);
	process is
	begin
		for i in 0 to 255 loop
			LUT_in <= std_logic_vector(to_unsigned(i, 8));
			wait for 50 ns;
		end loop;
		wait;
	end process;
end architecture;