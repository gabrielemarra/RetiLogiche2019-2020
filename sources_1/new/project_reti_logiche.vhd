----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2020 16:46:39
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
use IEEE.NUMERIC_STD.ALL;

use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_start : in std_logic;
		i_rst : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_address : out std_logic_vector(15 downto 0);
		o_done : out std_logic;
		o_en : out std_logic;
		o_we : out std_logic;
		o_data : out std_logic_vector (7 downto 0)
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (START_STATE, WAITING_ADDRESS, READING_ADDRESS, WAITING_STATE, WZ_ANALYSIS, FOUND, NOT_FOUND, FINISHED);

signal state : state_type;

signal address_read : std_logic_vector(7 downto 0);
signal counterVector : std_logic_vector(3 downto 0);
signal counter : integer;
signal address_to_code : std_logic_vector(7 downto 0);
signal offset : std_logic_vector(3 downto 0);

 -- SIGNALS --
begin
	
	process(i_clk, i_rst)
	 -- Process variable --
	begin
		if i_rst = '1' then
			state <= START_STATE;
			o_done <= '0';
			counterVector <= "0000";
			counter <= 0;
		elsif rising_edge(i_clk) then
			case state is
				when START_STATE =>
					if(i_start='1') then
						o_en <= '1';
						o_we <= '0';
						o_address <= (0 =>'0',1 =>'0',2 =>'0',3 =>'1', others => '0');
						state <= WAITING_ADDRESS;
					end if;
				when WAITING_ADDRESS =>
					o_en <= '1';
					o_we <= '0';
					o_address <= (others => '0');
					state <= READING_ADDRESS;
				when READING_ADDRESS =>
					address_to_code <= i_data;
					o_en <= '0';
					o_we <= '0';
					state <= WZ_ANALYSIS;
				when WAITING_STATE =>
					o_en <= '0';
					o_we <= '0';
					state <= WZ_ANALYSIS;
				when WZ_ANALYSIS =>
					if(i_data = address_to_code) then
						offset <= "0001";
						state <= FOUND;
					elsif ( i_data+1 = address_to_code) then
						offset <= "0010";
						state <= FOUND;
					elsif ( i_data+2 = address_to_code) then
						offset <= "0100";
						state <= FOUND;
					elsif ( i_data+3 = address_to_code) then
						offset <= "1000";
						state <= FOUND;
					elsif (counter > 6) then
						state <= NOT_FOUND;
					else 
						counter <= counter + 1; 
						o_en <= '1';
						o_we <= '0';
						o_address <= std_logic_vector(to_unsigned(counter+1,o_address'length));
						state <= WAITING_STATE;
					end if;
				when FOUND =>
					o_en <= '1';
					o_we <= '1';
					o_address <= (0 =>'1',1 =>'0',2 =>'0',3 =>'1', others => '0');
					o_data <= '1' & std_logic_vector(to_unsigned(counter,3)) & offset;
					o_done <= '1';
					state <= FINISHED;
				when NOT_FOUND =>
					o_en <= '1';
					o_we <= '1';
					o_address <= (0 =>'1',1 =>'0',2 =>'0',3 =>'1', others => '0');
					o_data <= address_to_code;
					o_done <= '1';
					state <= FINISHED;
				when FINISHED =>
					if(i_start = '0') then
						state <= START_STATE;
						o_done <= '0';
						counterVector <= "0000";
						counter <= 0;
					end if;
			end case;
		end if;
	end process;


end Behavioral;
