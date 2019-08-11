----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:12 01/23/2018 
-- Design Name: 
-- Module Name:    encrypter - Behavioral 
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encrypter is
    Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           P : in  STD_LOGIC_VECTOR (31 downto 0);
           C : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
			  done : out STD_LOGIC := '1';
           enable : in  STD_LOGIC);
end encrypter;

architecture Behavioral of encrypter is
signal T: std_logic_vector (3 downto 0);

--Additional signal that stores the value of C
signal temp: std_logic_vector (31 downto 0);

--Additional signals that store the state of the circuit
signal initial: std_logic;

--Counter that terminates after 32 loops
signal count: integer range 0 to 32;

begin
	C <= temp;
   process(clock, reset, enable)
	 begin
		if (reset = '1') then
			T <= (others => '0');
			
			temp <= (others => '0');
			count <= 0;
			initial <= '0';
			done <= '1';
		elsif (clock'event and clock = '1' and enable = '1') then
			
			--Initial step before the loop, executes only once	
			if(initial = '0' and count < 32) then
				temp <= P;

				T(0) <= K(28) xor K(24) xor K(20) xor K(16) xor K(12) xor K(8) xor K(4) xor K(0);
				T(1) <= K(29) xor K(25) xor K(21) xor K(17) xor K(13) xor K(9) xor K(5) xor K(1);
				T(2) <= K(30) xor K(26) xor K(22) xor K(18) xor K(14) xor K(10) xor K(6) xor K(2);
				T(3) <= K(31) xor K(27) xor K(23) xor K(19) xor K(15) xor K(11) xor K(7) xor K(3);
				initial <= '1';
				done <= '0';
			--	For loop begins here after initial steps
			elsif(initial = '1' and count < 32) then
				if ( K(count) = '1' ) then
					temp <= temp xor T & T & T & T & T & T & T & T;
				
					--Assigning temp to C, incrementing count and T by 1
					T <=T + 1;
					count <= count + 1;
						
				elsif(K(count) = '0') then
					count <= count + 1;
				end if;
			elsif(initial = '1' and count = 32) then
				done <= '1';
			end if;
			-- write your code here
		end if;
	 end process;

end Behavioral;