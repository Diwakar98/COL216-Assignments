----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2020 19:38:32
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
    Port (
        clk : in std_logic;
        mode: in std_logic;
        cathodes : out std_logic_vector(0 to 6);
        anodes : out std_logic_VECTOR(3 DOWNTO 0)
    );
end main;

architecture Behavioral of main is
    signal refresh_clk : std_logic := '0';
    signal show : std_logic_vector(15 downto 0);
    signal display : std_logic_vector(15 downto 0);
    signal clock_display : std_logic_vector(15 downto 0);
    signal cathodes_sig : std_logic_vector(0 to 6);
    signal anodes_sig : std_logic_VECTOR(3 DOWNTO 0); 
begin
    refresh_clk_instance : entity work.freq_divider(Behavioral)
		port map(clk, "00000000000000001100001101010000", refresh_clk);
		
	processor_instance : entity work.Processor(Behavioral)
	   port map(clk,display,clock_display);
	   
    ssd_instance : entity work.ssd(Behavioral)
        port map(refresh_clk,show,cathodes_sig,anodes_sig);
	   
	with mode select show <= display when '0', clock_display when others;
	
	cathodes <= cathodes_sig;
	anodes <= anodes_sig;

    

end Behavioral;