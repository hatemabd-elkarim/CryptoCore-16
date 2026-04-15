library ieee;
use ieee.std_logic_1164.all;

entity SHIFTER is
    port (	
	    -- inputs and outputs
        B_Bus          : in  std_logic_vector(15 downto 0);
        CTRL_shifter   : in  std_logic_vector(3 downto 0);
        shifter_result : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behaviour of SHIFTER is
begin 
    process(B_Bus, CTRL_shifter)
    begin
        case CTRL_shifter is   
			
			-- Rotate Right 8-bit
            when "1000" => 
			    shifter_result <= B_Bus(7 downto 0) & B_Bus(15 downto 8); 
			
			-- Rotate Right 4-bit
            when "1001" => 
			    shifter_result <= B_Bus(3 downto 0) & B_Bus(15 downto 4); 
			
			-- Shift Left 8-bit
            when "1010" => 
                shifter_result <= B_Bus(7 downto 0) & "00000000";         
            when others => 
                shifter_result <= (others => '0');
        end case;           
    end process;
end architecture;