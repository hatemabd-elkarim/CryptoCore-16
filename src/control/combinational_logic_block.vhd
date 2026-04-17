library ieee;
use ieee.std_logic_1164.all;

entity structural_combinational_logic_block is
port(
	ABUS: in std_logic_vector(15 downto 0);
	BBUS: in std_logic_vector(15 downto 0);
	CTRL: in std_logic_vector(3 downto 0);
	RES: out std_logic_vector(15 downto 0)
	
);	
end entity;


architecture behavioral of structural_combinational_logic_block is
signal ALU_OUT, SHIFT_OUT, LUT_OUT: std_logic_vector(15 downto 0);
signal LUT_OUT_LSB: std_logic_vector(7 downto 0);

begin 
-- Mapping of ALU
ALU_UNIT: entity work.ALU
	port map(ABUS => ABUS, BBUS => BBUS, CTRL => CTRL, ALU_OUT => ALU_OUT);

-- Mapping of shifter
SHIFTER_UNIT: entity work.SHIFTER
	port map(B_BUS => BBUS, CTRL_SHIFTER => CTRL, SHIFTER_RESULT => SHIFT_OUT);
	
-- Mapping of LUT
LUT_UNIT: entity work.LUT
	port map(LUT_IN => ABUS(7 downto 0), LUT_OUT => LUT_OUT_LSB);
	LUT_OUT <= ABUS(15 downto 8) & LUT_OUT_LSB;

	
-- CONTROL LOGIC MUX: All ALU operations ctrl(3) is 0, LUT operation ctrl(1 downto 0) is 11, others are shifter operations or undefined
CONTROL_MUX: process(CTRL, ALU_OUT, SHIFT_OUT, LUT_OUT)
begin
    if CTRL(3) = '0' then
        RES <= ALU_OUT;
    elsif CTRL(1 downto 0) = "11" then
        RES <= LUT_OUT;
    else
        RES <= SHIFT_OUT;
    end if;
end process;  
end architecture;
	
