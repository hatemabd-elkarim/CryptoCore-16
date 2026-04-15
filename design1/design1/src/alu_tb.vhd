library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end entity ALU_tb;

architecture sim of ALU_tb is

    signal ABUS    : std_logic_vector(15 downto 0);
    signal BBUS    : std_logic_vector(15 downto 0);
    signal CTRL    : std_logic_vector(3  downto 0);
    signal ALU_OUT : std_logic_vector(15 downto 0);

begin

    UUT : entity work.ALU
        port map (
            ABUS    => ABUS,
            BBUS    => BBUS,
            CTRL    => CTRL,
            ALU_OUT => ALU_OUT
        );

    process
    begin
        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0000"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0001"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0010"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0011"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0100"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"0000"; CTRL <= "0101"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"0000"; CTRL <= "0110"; wait for 10 ns;

        ABUS <= x"C505"; BBUS <= x"6808"; CTRL <= "0111"; wait for 10 ns;

        wait;
    end process;

end architecture sim;