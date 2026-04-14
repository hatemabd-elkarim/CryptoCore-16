library ieee;
use ieee.std_logic_1164.all;

entity LUT is
	port(
		LUT_in : in	std_logic_vector(7 downto 0);
		LUT_out : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of LUT is
signal LHS_in, LHS_out, RHS_in, RHS_out : std_logic_vector(3 downto 0);
begin
	LHS_in <= LUT_in(7 downto 4);
	RHS_in <= LUT_in(3 downto 0);
	
	SBOX_1 : block is
	begin
		with LHS_in select
			LHS_out <= "0001" when "0000",
			           "1011" when "0001",
					   "1001" when "0010",
					   "1100" when "0011",
					   "1101" when "0100",
					   "0110" when "0101",
					   "1111" when "0110",
					   "0011" when "0111",
					   "1110" when "1000",
					   "1000" when "1001",
					   "0111" when "1010",
					   "0100" when "1011",
					   "1010" when "1100",
					   "0010" when "1101",
					   "0101" when "1110",
					   "0000" when "1111",
					   "XXXX" when others;
	end block;
	
	SBOX_2 : block is
	begin
		with RHS_in select
			RHS_out <= "1111" when "0000",
			           "0000" when "0001",
					   "1101" when "0010",
					   "0111" when "0011",
					   "1011" when "0100",
					   "1110" when "0101",
					   "0101" when "0110",
					   "1010" when "0111",
					   "1001" when "1000",
					   "0010" when "1001",
					   "1100" when "1010",
					   "0001" when "1011",
					   "0011" when "1100",
					   "0100" when "1101",
					   "1000" when "1110",
					   "0110" when "1111",
					   "XXXX" when others;
	end block;
	
	LUT_out <= LHS_out & RHS_out;
end architecture;
