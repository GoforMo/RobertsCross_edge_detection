----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2024 10:26:11 PM
-- Design Name: 
-- Module Name: tb - Behavioral
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

use std.textio.all;
use std.env.finish;

entity tb is
--  Port ( );
end tb;

architecture sim of tb is

  type header_type is array (0 to 53) of character;

  type pixel_type is record
    red : std_logic_vector(7 downto 0);
    green : std_logic_vector(7 downto 0);
    blue : std_logic_vector(7 downto 0);
  end record;

  type row_type is array (integer range <>) of pixel_type;
  type row_pointer is access row_type;
  type image_type is array (integer range <>) of row_pointer;
  type image_pointer is access image_type;
  
  constant ClkPeriod : time := 10 ns;
  signal resetFlag : std_logic;

  -- DUT signals
  signal clk : std_logic := '0';
  signal reset_n : std_logic := '1';
  signal enable,Vsync : std_logic;
  signal data_H : std_logic_vector(7 downto 0);
  signal data_L : std_logic_vector(7 downto 0);
  signal Reg_Z1 : std_logic;
  constant inBmp	: string := "boeing_grayscale.bmp";
  constant outbmp 	: string := "outT128_" & inBmp;

begin

    clk_process : process --or can do clk <= not clk after Clkperiod/2;
    begin
        wait for 5 ns;
        clk <= not clk;
    end process;
    
    reset_process : process
    begin
        wait for clkperiod*2;
        reset_n <= '0';
        wait for clkperiod*10;
        reset_n <= '1';
        resetFlag <= '1';
        wait;
    end process;
    
    process
        type char_file is file of character;
        file bmp_file : char_file open read_mode is inBmp;
        file out_file : char_file open write_mode is outbmp;
        variable header : header_type;
        variable image_width : integer;
        variable image_height : integer;
        variable row : row_pointer;
        variable image : image_pointer;
        variable padding : integer;
        variable char : character;
    begin

    -- Read entire header
    for i in header_type'range loop
      read(bmp_file, header(i));
    end loop;

    -- Check ID field
    assert header(0) = 'B' and header(1) = 'M'
      report "First two bytes are not ""BM"". This is not a BMP file"
      severity failure;

    -- Check that the pixel array offset is as expected
    assert character'pos(header(10)) = 54 and
      character'pos(header(11)) = 0 and
      character'pos(header(12)) = 0 and
      character'pos(header(13)) = 0
      report "Pixel array offset in header is not 54 bytes"
      severity failure;

    -- Check that DIB header size is 40 bytes,
    -- meaning that the BMP is of type BITMAPINFOHEADER
    assert character'pos(header(14)) = 40 and
      character'pos(header(15)) = 0 and
      character'pos(header(16)) = 0 and
      character'pos(header(17)) = 0
      report "DIB headers size is not 40 bytes, is this a Windows BMP?"
      severity failure;

    -- Check that the number of color planes is 1
    assert character'pos(header(26)) = 1 and
      character'pos(header(27)) = 0
      report "Color planes is not 1" severity failure;

    -- Check that the number of bits per pixel is 24
    assert character'pos(header(28)) = 24 and
      character'pos(header(29)) = 0
      report "Bits per pixel is not 24" severity failure;

    -- Read image width
    image_width := character'pos(header(18)) +
      character'pos(header(19)) * 2**8 +
      character'pos(header(20)) * 2**16 +
      character'pos(header(21)) * 2**24;

    -- Read image height
    image_height := character'pos(header(22)) +
      character'pos(header(23)) * 2**8 +
      character'pos(header(24)) * 2**16 +
      character'pos(header(25)) * 2**24;

    report "image_width: " & integer'image(image_width) &
      ", image_height: " & integer'image(image_height);

    -- Number of bytes needed to pad each row to 32 bits
    padding := (4 - image_width*3 mod 4) mod 4;

    -- Create a new image type in dynamic memory
    image := new image_type(0 to image_height - 1);

    for row_i in 0 to image_height - 1 loop

      -- Create a new row type in dynamic memory
      row := new row_type(0 to image_width - 1);

      for col_i in 0 to image_width - 1 loop

        -- Read blue pixel
        read(bmp_file, char);
        row(col_i).blue :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

        -- Read green pixel
        read(bmp_file, char);
        row(col_i).green :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

        -- Read red pixel
        read(bmp_file, char);
        row(col_i).red :=
          std_logic_vector(to_unsigned(character'pos(char), 8));

      end loop;

      -- Read and discard padding
      for i in 1 to padding loop
        read(bmp_file, char);
      end loop;

      -- Assign the row pointer to the image vector of rows
      image(row_i) := row;

    end loop;
    
    -- Write header to output file
    for i in header_type'range loop
      write(out_file, header(i));
    end loop;

    -- DUT test
    wait until resetFlag = '1';
    enable <= '1';
    vsync <= '1';
    wait until rising_edge(clk);
    for row_i in 0 to image_height - 1 loop
      row := image(row_i);

      for col_i in 0 to image_width - 1 loop --sending in data as BGR not as RGB as in normal BMP file
        data_H <= row(col_i).blue;
        data_L <= row(col_i).green;
        wait until rising_edge(clk);
        data_H <= row(col_i).green;
        data_L <= row(col_i).red;
        wait until rising_edge(clk);
        -- Write edge detection pixel
        -- Convert std_logic to integer (0 or 1)
        if Reg_Z1 = '0' then
            write(out_file,character'val(0)); -- ASCII value of '0'
            write(out_file,character'val(0));
            write(out_file,character'val(0));
        elsif Reg_Z1 = '1' then
            write(out_file,character'val(255)); -- ASCII value of '1'
            write(out_file,character'val(255));
            write(out_file,character'val(255));
        else
            -- Handle invalid std_logic value if necessary
            write(out_file,character'val(0)); -- Default to '0'
            write(out_file,character'val(0));
            write(out_file,character'val(0));
        end if;        
      end loop;
      deallocate(row);
    end loop;

--    for row_i in 0 to image_height - 1 loop
--      row := image(row_i);

--      for col_i in 0 to image_width - 1 loop

--        -- Write blue pixel
--        write(out_file,
--          character'val(to_integer(unsigned(row(col_i).blue))));

--        -- Write green pixel
--        write(out_file,
--          character'val(to_integer(unsigned(row(col_i).green))));

--        -- Write red pixel
--        write(out_file,
--          character'val(to_integer(unsigned(row(col_i).red))));

--      end loop;

    deallocate(image);
    enable <= '0';
    vsync <= '0';
    file_close(bmp_file);
    file_close(out_file);
    
    report "Simulation done. Check " & outBmp &" image.";
    finish;
    end process;
    
    DUT : entity work.top_level(Behavioral)
      port map (
        CLK  => clk,
        Data_in_H => data_H,
        Data_in_L => data_L,
        Enable => enable,
        Vsync => Vsync,
        Reg_Z1 => Reg_Z1,
        Reset_n => Reset_n
      );
 end sim;
