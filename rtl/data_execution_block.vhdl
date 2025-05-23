----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Mowly K
-- 
-- Create Date: 07/04/2024 11:30:58 PM
-- Design Name: 
-- Module Name: data_execution_block - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_execution_block is
port (
    CLK : IN std_logic;
    Data_in_P1 : IN std_logic_vector (7 downto 0);
    Data_in_P2 : IN std_logic_vector (7 downto 0);
    Data_in_P3 : IN std_logic_vector (7 downto 0);
    Data_in_P4 : IN std_logic_vector (7 downto 0);
    Enable : IN std_logic;
    Vsync : IN std_logic;
    Reg_Z1 : OUT std_logic;
    Reset_n : IN std_logic
);
end data_execution_block;

architecture Behavioral of data_execution_block is
 
--declaration of signals for the Data-Load_Block component
signal State : std_logic := '0';
signal SP14 : std_logic_vector (7 downto 0);
signal SP23 : std_logic_vector (7 downto 0);
signal Reg_G : std_logic_vector (7 downto 0);
--signal Reg_Z : std_logic;
signal T : std_logic_vector (7 downto 0):="00011000"; --Threshold made to 24
Begin
    process (CLK, Reset_n)
    begin
        if (Reset_n = '0') then
            State <= '0';
        else
            if (clk'event and clk ='0') then
                if(State='1' and Enable='1' and Vsync ='1') then
                    SP14 <= std_logic_vector(abs(signed(Data_in_P1) - signed(Data_in_P4)));
                    SP23 <= std_logic_vector(abs(signed(Data_in_P2) - signed(Data_in_P3)));
                    State <= '0';
                elsif(State ='0' and Enable = '1' and Vsync = '1') then
                    Reg_G <= std_logic_vector(signed(SP14) + signed(SP23));
                    if (Reg_G >= T ) then
                        Reg_Z1 <= '1';
                    else
                        Reg_Z1 <= '0';
                    end if; 
                    State <= '1';                   
                end if;
            end if;
        end if;
    end process;
end Behavioral;
