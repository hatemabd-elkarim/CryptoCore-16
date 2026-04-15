library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity ALU is
    port (
        ABUS    : in  std_logic_vector(15 downto 0);  
        BBUS    : in  std_logic_vector(15 downto 0);  
        CTRL    : in  std_logic_vector(3  downto 0);  
        ALU_OUT : out std_logic_vector(15 downto 0)   
    );
end entity ALU;
 
architecture rtl of ALU is
begin
 
    process(ABUS, BBUS, CTRL)
    begin
        case CTRL is
 
            when "0000" => ALU_OUT <= std_logic_vector(unsigned(ABUS) + unsigned(BBUS));
 
            when "0001" => ALU_OUT <= std_logic_vector(unsigned(ABUS) - unsigned(BBUS));
 
            when "0010" => ALU_OUT <= ABUS and BBUS;
 
            when "0011" => ALU_OUT <= ABUS or BBUS;
 
            when "0100" => ALU_OUT <= ABUS xor BBUS;
 
            when "0101" => ALU_OUT <= not ABUS;
 
            when "0110" => ALU_OUT <= ABUS;
 
            when "0111" => ALU_OUT <= (others => '0');
 
            when others => ALU_OUT <= (others => '0');
 
        end case;
    end process;
 
end architecture rtl;