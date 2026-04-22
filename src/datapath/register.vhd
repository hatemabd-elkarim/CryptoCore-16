library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- =========================================================
-- Register File (16 x 16-bit registers)
-- Supports:
--   - Synchronous write
--   - Asynchronous read (No latency)
--   - Reset output to zero
-- =========================================================

entity register_file is
port ( 
   clock: in std_logic;  
   reset: in std_logic; 
   RdWEn: in std_logic; 
   RES : in std_logic_vector(15 downto 0); 
   Ra,Rb,Rd: in std_logic_vector(3 downto 0); 
   SRCa,SRCb: out std_logic_vector(15 downto 0) 
  );
end register_file;


architecture Behavioral of register_file is	

-- 16 registers, each 16-bit wide
type mem_type is array(0 to 15) of std_logic_vector(15 downto 0);

-- Register file memory with initial values (for simulation only)
signal REG_FILE: mem_type :=( 
  0 => x"0001", 
  1 => x"c505",
  2 => x"3c07",
  3 => x"4d05",
  4 => x"1186",
  5 => x"f407",
  6 => x"1086",
  7 => x"4706",
  8 => x"6808",
  9 => x"baa0",
  10 => x"c902",
  11 => x"100b",
  12 => x"c000",
  13 => x"c902",
  14 => x"100b",
  15 => x"B000",
  others => (others => '0')
  );
begin	   
	
-- =========================================================
-- WRITE OPERATION :  
-- Writes data into register Rd on rising edge of clock
-- when write enable is active
-- =========================================================
   write_operation: process(clock)
	begin
    if rising_edge(clock) then
        if reset = '1' then	-- syncronous reset, with higher priority
            REG_FILE <= (others => x"0000");
        elsif RdWEn = '1' then
            REG_FILE(to_integer(unsigned(Rd))) <= RES;
        end if;
    end if;
	end process;

-- =========================================================
-- READ OPERATION :
-- Reads two registers (Ra, Rb) Asynchronously (zero latency for cpu pipeline)
-- ========================================================= 
	SRCa <= REG_FILE(to_integer(unsigned(Ra)));
		
	SRCb <= REG_FILE(to_integer(unsigned(Rb)));
   
end Behavioral;