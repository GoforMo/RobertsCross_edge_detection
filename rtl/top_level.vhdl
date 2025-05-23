----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Mowly K
-- 
-- Create Date: 07/05/2024 12:07:06 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
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

entity top_level is
Port (
    CLK : in std_logic;
    Data_in_H : IN std_logic_vector (7 downto 0);
    Data_in_L : IN std_logic_vector (7 downto 0);
    Enable : IN std_logic;
    Vsync : IN std_logic;
    Reg_Z1 : OUT std_logic;
    Reset_n : IN std_logic
    );
end top_level;

architecture Behavioral of top_level is

    Component Data_Load_Block
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
    End Component;
    
    Component Data_Execution_Block
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
    End Component;
    
    signal Reg_P1_int: std_logic_vector (7 downto 0);
    signal Reg_P2_int: std_logic_vector (7 downto 0);
    signal Reg_P3_int: std_logic_vector (7 downto 0);
    signal Reg_P4_int: std_logic_vector (7 downto 0);
begin

    Data_Load_Block_inst: Data_Load_Block
        PORT MAP(
            CLK => CLK,
            Data_in_H => Data_in_H,
            Data_in_L => Data_in_L,
            Enable => Enable,
            Vsync => Vsync,
            Reg_P1 => Reg_P1_int,
            Reg_P2 => Reg_P2_int,
            Reg_P3 => Reg_P3_int,
            Reg_P4 => Reg_P4_int,
            Reset_n => Reset_n);

    Data_Execution_Block_inst: Data_Execution_Block
        port map (
            CLK => CLK,
            Data_in_P1 => Reg_P1_int,
            Data_in_P2 => Reg_P2_int,
            Data_in_P3 => Reg_P3_int,
            Data_in_P4 => Reg_P4_int,
            Enable => Enable,
            Vsync => Vsync,
            Reg_Z1 => Reg_Z1,
            Reset_n => Reset_n);
            
end Behavioral;
