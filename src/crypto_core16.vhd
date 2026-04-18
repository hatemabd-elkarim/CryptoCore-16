library	ieee;
use ieee.std_logic_1164.all;

entity crypto_core16 is
	port(
		clock, reset : in std_logic;
	    CTRL, Ra, Rb, Rd : in std_logic_vector(3 downto 0)
	);
end entity;

architecture struct of crypto_core16 is
signal RdWEn : std_logic;
signal ctrl_tmp, Rd_tmp : std_logic_vector(3 downto 0);
signal ABUS, BBUS, RESULT : std_logic_vector(15 downto 0);
begin
	Register_file : entity work.register_file
		port map(
			clock => clock,
			reset => reset,
			RdWEn => RdWEn,
			RES => RESULT,
			Ra => Ra,
			Rb => Rb,
			Rd => Rd_tmp,
			SRCa => ABUS,
			SRCb => BBUS
		);
		
	Combinational_logic : entity work.structural_combinational_logic_block
		port map(
			ABUS => ABUS,
			BBUS => BBUS,
			CTRL => ctrl_tmp,
			RES => RESULT
		);
		
	Process_control : process(clock, reset)
	begin
		if(rising_edge(clock)) then
			if(reset = '1') then
				ctrl_tmp <= x"0";
  				Rd_tmp <= x"0";
			else
				ctrl_tmp <= CTRL;
				Rd_tmp <= Rd;
				if(ctrl_tmp = "0111") then
					RdWEn <= '0';
				else
					RdWEn <= '1';
				end if;
			end if;
		end if;
	end process;	
end architecture;