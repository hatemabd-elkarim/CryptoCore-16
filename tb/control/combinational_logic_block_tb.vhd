library ieee;
use ieee.std_logic_1164.all;

entity structural_combinational_logic_block_tb is
end entity;

architecture sim of structural_combinational_logic_block_tb is
signal ABUS : std_logic_vector(15 downto 0);
signal BBUS : std_logic_vector(15 downto 0);
signal CTRL : std_logic_vector(3 downto 0);
signal RES  : std_logic_vector(15 downto 0);

begin
DUT: entity work.structural_combinational_logic_block
port map(
ABUS => ABUS,
BBUS => BBUS,
CTRL => CTRL,
RES  => RES
);

process	is
begin
	

-- Test 1: ALU path
-- CTRL(3) = 0

ABUS <= x"0005";
BBUS <= x"0003";
CTRL <= "0000";  -- ALU_SUM
wait for 10 ns;


-- Test 2: LUT path
-- CTRL(3)=1 and CTRL(1:0)="11"

ABUS <= x"00AA";
BBUS <= x"0000";
CTRL <= "1011";  -- LUT
wait for 10 ns;


-- Test 3: SHIFTER path
-- CTRL(3)=1 and not LUT

ABUS <= x"0000";
BBUS <= x"000F";
CTRL <= "1000";  -- ROR8
wait for 10 ns;


-- Test 4: Another ALU case

ABUS <= x"0010";
BBUS <= x"0004";
CTRL <= "0001";	-- ALU_SUB
wait for 10 ns;


-- Test 5: Another shifter case

ABUS <= x"1234";
BBUS <= x"12FF";
CTRL <= "1010"; -- SLL8
wait for 10 ns;


-- Test 6: Another ALU case

ABUS <= x"1234";
BBUS <= x"12FF";
CTRL <= "0111"; -- NOP
wait for 10 ns;	 


-- Test 7: Another ALU case

ABUS <= x"1234";
BBUS <= x"12FF";
CTRL <= "0100"; -- XOR
wait for 10 ns;	 

-- Test 8: Another shifter case

ABUS <= x"1234";
BBUS <= x"12FF";
CTRL <= "1001"; -- ROR4
wait for 10 ns;	  

wait;

end process;

end architecture;
