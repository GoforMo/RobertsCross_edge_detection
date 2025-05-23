----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Mowly K
-- 
-- Create Date: 07/04/2024 10:13:48 PM
-- Design Name: 
-- Module Name: data_load_block - Behavioral
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

entity data_load_block is
port (
    CLK : IN std_logic;
    Data_in_H : IN std_logic_vector (7 downto 0);
    Data_in_L : IN std_logic_vector (7 downto 0);
    Enable : IN std_logic;
    Vsync : IN std_logic;
    Reg_P1 : OUT std_logic_vector(7 downto 0);
    Reg_P2 : OUT std_logic_vector(7 downto 0);
    Reg_P3 : OUT std_logic_vector(7 downto 0);
    Reg_P4 : OUT std_logic_vector(7 downto 0);
    Reset_n : IN std_logic
);
end data_load_block;

architecture Behavioral of data_load_block is

--declaration of signals for the Data-Load_Block component
signal state : std_logic := '0';
signal ready : std_logic := '0';

begin
    process (CLK, Reset_n)
    begin
        if (Reset_n = '0') then
            state <= '0';
            ready <= '0';
        else
            if (clk'event and clk ='0') then 
                if(State='0' and Enable='1' and Vsync ='1') then
                    Reg_P1 <= Data_in_H;
                    Reg_P2 <= Data_in_L;
                    State <= '1';
                    Ready <= '0';
                elsif(State='1' and Enable='1' and Vsync ='1') then
                    Reg_P3 <= Data_in_H;
                    Reg_P4 <= Data_in_L;
                    State <= '0';
                    Ready <= '1';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
