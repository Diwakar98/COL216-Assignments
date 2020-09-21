----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2020 14:17:38
-- Design Name: 
-- Module Name: ssd - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ssd is
--Takes what needs to be displayed in the 4-digit SSD and a clock for refreshing (at refresh rate:1/4 of the clock frequency)
--Gives outputs for anodes and cathodes of the board
--Ideal frequency of clock: 250 Hz - 4 KHz
    Port (
        clk : IN std_logic;
        display: IN std_logic_vector(15 downto 0);
        cathodes : out std_logic_vector(0 to 6);
        anodes : out std_logic_VECTOR(3 DOWNTO 0)
        );
end ssd;

architecture Behavioral of ssd is
    signal show : std_logic_vector(3 downto 0) := "0000";
    signal anode : std_logic_VECTOR(3 DOWNTO 0) := "1110";
begin
       
    anodes <= anode;
    process(clk)
    begin
        if (rising_edge(clk)) then
            case  anode is
                when "1110" =>
                    anode <= "1101";
                when "1101" =>
                    anode <= "1011";
                when "1011" =>
                    anode <= "0111";
                when "0111" =>
                    anode <= "1110";
                when others =>
                    anode <= "1110";                   
            end case;
        end if;
    end process;
    
    with anode select show <= display(3 downto 0) when "1110",
                              display(7 downto 4) when "1101",
                              display(11 downto 8) when "1011",
                              display(15 downto 12) when others; 
    
    
    --SSD
    process(show)
    begin
        case show is 
            when "0000" => cathodes <= "0000001";
            when "0001" => cathodes <= "1001111";
            when "0010" => cathodes <= "0010010";
            when "0011" => cathodes <= "0000110";
            when "0100" => cathodes <= "1001100";
            when "0101" => cathodes <= "0100100";
            when "0110" => cathodes <= "0100000";
            when "0111" => cathodes <= "0001111";
            when "1000" => cathodes <= "0000000";
            when "1001" => cathodes <= "0000100";
            when "1010" => cathodes <= "0001000";
            when "1011" => cathodes <= "1100000";
            when "1100" => cathodes <= "0110001";
            when "1101" => cathodes <= "1000010";
            when "1110" => cathodes <= "0110000";
            when "1111" => cathodes <= "0111000"; 
            when others => cathodes <= "1111110";
        end case;                   
    end process;

end Behavioral;