library ieee;
use ieee.std_logic_1164.all;

entity tb_shifter is
end entity;

architecture test of tb_shifter is
    
    signal B_Bus_tb          : std_logic_vector(15 downto 0) := (others => '0');
    signal CTRL_shifter_tb   : std_logic_vector(3 downto 0)  := (others => '0');
    signal shifter_result_tb : std_logic_vector(15 downto 0);

begin
	
    UUT: entity work.shifter
        port map (
            B_Bus          => B_Bus_tb,
            CTRL_shifter   => CTRL_shifter_tb,
            shifter_result => shifter_result_tb
        );

   
    test_proc: process
    begin
        
        B_Bus_tb <= x"1234"; 
        
        CTRL_shifter_tb <= "1000";
        wait for 10 ns;
        
        CTRL_shifter_tb <= "1001";
        wait for 10 ns;
        
        CTRL_shifter_tb <= "1010";
        wait for 10 ns;
        
        CTRL_shifter_tb <= "0000";
        wait for 10 ns;

        wait;
    end process;

end architecture;