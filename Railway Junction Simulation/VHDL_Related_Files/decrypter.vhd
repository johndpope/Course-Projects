----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:26 01/23/2018 
-- Design Name: 
-- Module Name:    decrypter - Behavioral 
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

entity decrypter is
    Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           C : in  STD_LOGIC_VECTOR (31 downto 0);
           P : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
			  done : out STD_LOGIC:= '1';
           enable : in  STD_LOGIC);
end decrypter;

architecture Behavioral of decrypter is
signal T: std_logic_vector (3 downto 0):= (others => '0');

--32 bit vector formed by concatenating T eight times

--Additional signal that stores the value of P
signal temp: std_logic_vector (31 downto 0) := (others => '0');

--Additional signals that store the state of the circuit
signal initial: std_logic := '0';
signal initial2 : std_logic:= '0';

--Counter that terminates after 32 loops
signal count: integer range 0 to 32;

begin
	P <= temp;
	process(clock, reset, enable)
	 begin
		if (reset = '1') then
			T <= (others => '0');
			
			temp <= (others => '0');
			count <= 0;
			initial <= '0';
			initial2 <= '0';
			done <= '1';

		elsif (clock'event and clock = '1' and enable = '1') then
				--Initial step before the loop, executes only once
				if(initial = '0' and count < 32) then
					done <= '0';
					if(initial2 = '0')then
						temp <= C;
						initial2 <= '1';
						T(0) <= K(28) xor K(24) xor K(20) xor K(16) xor K(12) xor K(8) xor K(4) xor K(0);
						T(1) <= K(29) xor K(25) xor K(21) xor K(17) xor K(13) xor K(9) xor K(5) xor K(1);
						T(2) <= K(30) xor K(26) xor K(22) xor K(18) xor K(14) xor K(10) xor K(6) xor K(2);
						T(3) <= K(31) xor K(27) xor K(23) xor K(19) xor K(15) xor K(11) xor K(7) xor K(3);

					elsif(initial2 <= '1')then
						initial <= '1';
						T <= T +15;
						initial2 <= '1';
					end if;
				--	For loop begins here after initial steps
				elsif(initial = '1' and count < 32) then

					if ( K(count) = '0' ) then
							temp <= temp xor T & T & T & T & T & T & T & T;
							--Assigning temp to P, incrementing count by 1 and T by 15(and ignoring overflow bit)
							T <= T +15;
							count <= count + 1;
					elsif(K(count) = '1') then
						count <= count + 1;
					end if;
				elsif(initial = '1' and count = 32) then
					done <= '1';
				end if;
				-- write your code here 
		end if;

	 end process;
end Behavioral;