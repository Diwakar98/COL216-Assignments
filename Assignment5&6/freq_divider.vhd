----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:37:35 09/05/2019 
-- Design Name: 
-- Module Name:    freq_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity freq_divider is
--Divides original clock by reducting factor (max: 2^32) to give reduced clock
    port (
        original_clk : in std_logic;
        reducing_factor : in std_logic_vector(31 downto 0);
        reduced_clk : out std_logic
    );
end entity freq_divider;

architecture Behavioral of freq_divider is
    signal x : std_logic := '0';
	 signal eoc : integer := to_integer(unsigned(reducing_factor));
    signal t : integer := 0;
begin
    process(original_clk)
    begin
        if(original_clk='1' and original_clk'event) then
            t <= t+1;
            if(t = eoc) then
                t <= 0;
                x <= not x;
            end if;
        end if;
    end process;

    reduced_clk <= x;
end architecture Behavioral;
