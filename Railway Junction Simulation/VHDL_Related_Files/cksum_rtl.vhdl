--
-- Copyright (C) 2009-2012 Chris McClelland
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

architecture rtl of swled is
	-- Flags for display on the 7-seg decimal points
	signal flags                   : std_logic_vector(3 downto 0);

	-- Registers implementing the channels
	signal checksum, checksum_next : std_logic_vector(15 downto 0) := (others => '0');
	signal reg0, reg0_next         : std_logic_vector(7 downto 0)  := (others => '0');
	
	signal pos		       : std_logic_vector(7 downto 0) := "00100010";
	signal pos32		       : std_logic_vector(31 downto 0) := pos & pos & pos & pos;
	signal check_input_pos_32bits: std_logic_vector(31 downto 0) := (others => '0');
	signal pos_encrypted		: std_logic := '0';
	signal pos_ack2_decrypted	: std_logic := '0';

	signal posn_fed				: std_logic := '0';
	signal ciphertext_pos_out	: std_logic_vector(31 downto 0) := (others => '0');
	signal pos_ack2	: std_logic_vector(31 downto 0) := (others => '0');
	signal ack1	: std_logic_vector(31 downto 0) := "10101010101010101010101010101010";
	signal encrypted_ack1	: std_logic_vector(31 downto 0) := (others => '0');
	signal ack2	: std_logic_vector(31 downto 0) := "11001100110011001100110011001100";
	signal encrypted_ack2	: std_logic_vector(31 downto 0) := (others => '0');
	signal pos_ack2_decrypted_data	: std_logic_vector(31 downto 0) := (others => '0');
	signal full_data_ack2_decrypted_data	: std_logic_vector(31 downto 0) := (others => '0');
	signal full_data_ack2	: std_logic_vector(31 downto 0) := (others => '0');

	signal temp_pos		       : std_logic_vector(7 downto 0) := (others => '0');
	signal temp_input_encrypted_8_bits    : std_logic_vector(7 downto 0) := (others => '0');
	signal input_encrypted_8_bits    : std_logic_vector(7 downto 0) := (others => '0');
	signal temp_channel_read_input    : std_logic_vector(7 downto 0) := (others => '0');

	signal opposite_train_signal    : std_logic_vector(7 downto 0) := (others => '0');
	signal opposite_train_signal_fed : std_logic := '0';

	signal output_dir_vector : std_logic_vector(2 downto 0) := (others => '0');
	signal output_dir_integer	: integer range 0 to 8 := 0;

	signal uart_output_dir_vector : std_logic_vector(2 downto 0) := (others => '0');
	signal uart_output_dir_integer	: integer range 0 to 8 := 0;

	signal pos_slider_count : integer range 0 to 8 := 0;
--	signal pos_slider_count2 : integer range 0 to 4 := 0;

	signal inc_check_pos_count: STD_LOGIC := '0';
	signal inc_ack_out_count: STD_LOGIC := '0';
	signal pos_matched: STD_LOGIC := '0';
	signal rec_half_data_ack: STD_LOGIC := '0';
	signal rec_half_data_ack_sent: STD_LOGIC := '0';
	signal inc_rec_half_data_ack_count: STD_LOGIC := '0';
	signal rec_full_data_ack: STD_LOGIC := '0';
	signal rec_full_data_ack_sent: STD_LOGIC := '0';
	signal inc_rec_full_data_ack_count: STD_LOGIC := '0';

	
	signal ticks			: integer range 0 to 200000000 := 0;
	signal out_count		: integer range 0 to 8 := 0;
	signal led_show_count		: integer range 0 to 8 := 0;
	signal fail_counter : integer range 0 to 5000 := 0;

	signal key				: std_logic_vector(31 downto 0) := "01011101010111000000111111110010";
	signal decrypted_64_bits_out	: std_logic_vector(63 downto 0) := (others => '0');
	signal input_encrypted_64bits		: std_logic_vector(63 downto 0) := (others => '0');
	signal enc64_fed: STD_LOGIC := '0';
	signal pos_ack2_fed: STD_LOGIC := '0';
	signal full_data_ack2_fed: STD_LOGIC := '0';
	signal encryption_over: STD_LOGIC := '0';
	signal ack1_encryption_over: STD_LOGIC := '0';
	signal ack2_encryption_over: STD_LOGIC := '0';

	signal decryption_over1: STD_LOGIC := '0';
	signal decryption_over2: STD_LOGIC := '0';
	signal pos_ack2_decryption_over1: STD_LOGIC := '0';
	signal pos_ack2_decryption_over2: STD_LOGIC := '0';
	signal full_data_ack2_decryption_over: STD_LOGIC := '0';

	signal data64_decrypted: STD_LOGIC := '0';
	signal full_data_ack2_decrypted: STD_LOGIC := '0';
	signal full_data_ack2_received: STD_LOGIC := '0';
	signal inc_enc_count: STD_LOGIC := '0';
	signal inc_pos_out_count: STD_LOGIC := '0';
	signal inc_pos_ack2_count: STD_LOGIC := '0';
	signal inc_full_data_ack2_count: STD_LOGIC := '0';
	signal pos_ack2_received: STD_LOGIC := '0';

	signal reset_enc: STD_LOGIC := '1';
	signal reset_dec: STD_LOGIC := '1';
	signal reset_dec_pos_ack2: STD_LOGIC := '1';
	signal reset_dec_full_data_ack2: STD_LOGIC := '1';
	signal enable: STD_LOGIC := '1';
	signal enc_count			: integer range 0 to 8 := 0;
	signal pos_out_count			: integer range 0 to 5 := 0;
	signal pos_ack2_count			: integer range 0 to 5 := 0;
	signal check_pos_count			: integer range 0 to 5 := 0;
	signal ack_out_count			: integer range 0 to 5 := 0;
	signal rec_half_data_ack_count	: integer range 0 to 5 := 0;
	signal rec_full_data_ack_count	: integer range 0 to 5 := 0;
	signal full_data_ack2_count	: integer range 0 to 5 := 0;

	signal show_led : std_logic := '0';
	signal state3 : std_logic := '0';
	signal state4 : std_logic := '0';
	signal state5 : std_logic := '0';
	signal state6 : std_logic := '0';
	signal state : std_logic := '0';
	signal temp : std_logic := '0';
	signal not_sending_fpga : std_logic := '0';
	signal not_sending_uart : std_logic := '0';

	signal datawritten : std_logic := '0';
	signal reset_slider_data : std_logic := '1';
	signal slider_data_encrypted : std_logic := '0';
--	signal slider_data_encrypted2 : std_logic := '0';
	signal slider_data : std_logic_vector(31 downto 0) := (others => '0');
	signal encrypted_slider_data : std_logic_vector(31 downto 0) := (others => '0');

	signal code_sent1 : std_logic := '0';
	signal increase_code_sent1 : std_logic := '0';
	signal code_sent2 : std_logic := '0';
	signal inc_slider_count1 : std_logic := '0';
	signal inc_slider_count2 : std_logic := '0';

	signal up_debounced: STD_LOGIC;
	signal left_debounced: STD_LOGIC;
	signal down_debounced: STD_LOGIC;
	signal right_debounced: STD_LOGIC;
	signal center_debounced: STD_LOGIC;

	signal rst : std_logic;
	signal sample : std_logic;
	signal rxdone : std_logic;
	signal txdone : std_logic;
	signal rxdata   : std_logic_vector(7 downto 0);
    signal txdata   : std_logic_vector(7 downto 0);

	signal enter_counter	: integer range 0 to 255 := 0;
	signal uart_read : std_logic:= '0';
	signal send_uart_data: std_logic := '0';
	signal increase_send_uart_data: std_logic := '0';
	signal write_into_channel: std_logic := '0';

	signal uart_data_sent : std_logic := '0';
	signal increase_uart_data_sent : std_logic := '0';

	signal uart_data : std_logic_vector(7 downto 0) := (others => '0');
	signal slider_data_fed : std_logic := '0';
	signal slider_reset_done : std_logic := '0';
    component encrypter
        port( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           P : in  STD_LOGIC_VECTOR (31 downto 0);
           C : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
           done : out STD_LOGIC;
           enable : in  STD_LOGIC);
    end component;

    component decrypter
        port( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           C : in  STD_LOGIC_VECTOR (31 downto 0);
           P : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
           done : out STD_LOGIC;
           enable : in  STD_LOGIC);
    end component;

    component debouncer
        port(clk: in STD_LOGIC;
            button: in STD_LOGIC;
            button_deb: out STD_LOGIC);
    end component;

	--component uart is
	--port (clk 	 : in std_logic;
	--		rst 	 : in std_logic;
	--		rx	 	 : in std_logic;
	--		switches : in std_logic_vector(7 downto 0);
	--		up_debounced: in STD_LOGIC;
	--		left_debounced: in STD_LOGIC;
	--		down_debounced: in STD_LOGIC;
	--		right_debounced: in STD_LOGIC;
	--		center_debounced: in STD_LOGIC;
	--		tx	 	 : out std_logic;
	--		--Signals pulled on Atlys LEDs for debugging
	--		Bwr_en  : out std_logic; --20102016
	--		Brd_en  : out std_logic; --20102016
	--		Bfull   : out std_logic; --20102016
	--	--	led_out_vec : out std_logic_vector(7 downto 0);
	--		Bempty  : out std_logic); --20102016
	--end component uart;

	component uart_rx is			
	port (clk	: in std_logic;
			rst	: in std_logic;
			rx		: in std_logic;
			sample: in STD_LOGIC;
			rxdone: out std_logic;
			rxdata: out std_logic_vector(7 downto 0));
	end component uart_rx;
	component uart_tx is			
	port (clk    : in std_logic;
			rst    : in std_logic;
			txstart: in std_logic;
			sample : in std_logic;
			txdata : in std_logic_vector(7 downto 0);
			txdone : out std_logic;
			tx	    : out std_logic);
	end component uart_tx;
	component baudrate_gen is
	port (clk	: in std_logic;
			rst	: in std_logic;
			sample: out std_logic);
	end component baudrate_gen;

begin                                                                     --BEGIN_SNIPPET(registers)
	-- Infer registers


	process(clk_in)
	begin
		if ( rising_edge(clk_in) ) then

			if(rxdone = '1')then
				uart_data <= rxdata;
				uart_read <= '1';
			end if;

--		
			--if(rxdone = '1')then
			--	enter_counter <= enter_counter +1;
			--end if;
			--led_out <= rxdata;

			if(f2hReady_in='1' and write_into_channel='0')then
				fail_counter <= fail_counter+1;
				--led_out <= std_logic_vector(to_unsigned(fail_counter,8));
			end if;


			if(fail_counter < 48)then
				temp_channel_read_input <= "00000000";
			else
				write_into_channel <= '1';
			end if;


			input_encrypted_8_bits <= temp_input_encrypted_8_bits;

			
			if(pos_encrypted = '0' and posn_fed = '0' and show_led = '0' and write_into_channel='1')then
				--f2hValid_out <= '0';
				--h2fReady_out <= '0';
			--	led_out <= "00000001";
				reset_enc <= '0';
				posn_fed <= '1';
			elsif (pos_encrypted = '0' and posn_fed = '1' and encryption_over='1' and ack1_encryption_over='1' and ack2_encryption_over='1') then
				pos_encrypted <= '1';
			end if;

			if(pos_out_count < 4 and pos_encrypted='1')then

			--	led_out <= "00000001";

				temp_channel_read_input <= ciphertext_pos_out(pos_out_count*8+7 downto pos_out_count*8);
				--f2hValid_out <= '0';
				if(f2hReady_in = '1' and inc_pos_out_count ='0')then
					--f2hValid_out <= '1';
					inc_pos_out_count <= '1';

				elsif(inc_pos_out_count = '1')then
					pos_out_count <= pos_out_count + 1;
					inc_pos_out_count <= '0';
					--f2hValid_out <= '0';
				end if;
			end if;


			if(pos_matched = '0' and check_pos_count < 4 and pos_out_count > 3)then

			--	led_out <= "00000011";
				--f2hValid_out <= '0';
				check_input_pos_32bits(8*check_pos_count+7 downto 8*check_pos_count) <= input_encrypted_8_bits;
				if(h2fValid_in = '1' and inc_check_pos_count ='0')then
					--h2fReady_out <= '1';
					inc_check_pos_count <= '1';
				elsif(inc_check_pos_count = '1')then
					check_pos_count <= check_pos_count +1;
					inc_check_pos_count <= '0';
					--h2fReady_out <= '0';
				end if;
			end if;

			if(pos_matched = '0' and check_pos_count > 3)then
				if(check_input_pos_32bits = ciphertext_pos_out)then
	--				led_out <= "00000100";
					pos_matched <= '1';
				end if;
			end if;

			if(pos_matched = '1' and ack_out_count < 4)then
				
	--			led_out <= "00000111";
				temp_channel_read_input <= encrypted_ack1(8*ack_out_count+7 downto 8*ack_out_count);
				if(f2hReady_in = '1' and inc_ack_out_count ='0')then
					inc_ack_out_count <= '1';
					--f2hValid_out <= '1';
				elsif(inc_ack_out_count = '1')then
					ack_out_count <= ack_out_count + 1;
					inc_ack_out_count <= '0';
					--f2hValid_out <= '0';
				end if;
			end if;

			if(ack_out_count > 3 and pos_ack2_count<4)then
				
	--			led_out <= "00001111";
				pos_ack2(8*pos_ack2_count+7 downto 8*pos_ack2_count) <= input_encrypted_8_bits;
				if(h2fValid_in = '1' and inc_pos_ack2_count = '0')then
					--h2fReady_out <= '1';
					inc_pos_ack2_count <= '1';
				elsif(inc_pos_ack2_count = '1')then
					--h2fReady_out <= '0';
					pos_ack2_count <= pos_ack2_count +1;
					inc_pos_ack2_count <= '0';
				end if;
			end if;

			if(pos_ack2_count>3 and pos_ack2_received = '0')then
		--		led_out <= pos_ack2(7 downto 0);

				if(pos_ack2 = encrypted_ack2) then
					pos_ack2_received <= '1';
				end if;
			end if;



			if(pos_ack2_received = '1' and enc_count<4)then
		--		led_out <= "00111111";
				input_encrypted_64bits(8*enc_count+7 downto 8*enc_count) <= input_encrypted_8_bits;
				if(h2fValid_in = '1' and inc_enc_count = '0')then
					--h2fReady_out <= '1';
					inc_enc_count <= '1';
				elsif(inc_enc_count = '1')then
					--h2fReady_out <= '0';
					enc_count <= enc_count +1;
					inc_enc_count <= '0';
				end if;
			end if;

			
			if(enc_count > 3 and rec_half_data_ack = '0')then
				rec_half_data_ack <= '1';
			end if;

			if(rec_half_data_ack = '1' and rec_half_data_ack_sent = '0')then
				--led_out <= "01111111";
				if(rec_half_data_ack_count < 4)then
					----f2hValid_out <= '1';
					temp_channel_read_input <= encrypted_ack1(8*rec_half_data_ack_count+7 downto 8*rec_half_data_ack_count);
					if(f2hReady_in = '1' and inc_rec_half_data_ack_count = '0')then
						inc_rec_half_data_ack_count <= '1';
						--f2hValid_out <= '1';
					elsif(inc_rec_half_data_ack_count = '1')then
						rec_half_data_ack_count <= rec_half_data_ack_count + 1;
						inc_rec_half_data_ack_count <= '0';
						--f2hValid_out <= '0';
					end if;
				elsif(rec_half_data_ack_count > 3)then
					rec_half_data_ack_sent <= '1';
					--f2hValid_out <= '0';
				end if;
			end if;


			if(rec_half_data_ack_sent = '1' and enc_count < 8)then
			--	led_out <= "01111110";
				input_encrypted_64bits(8*enc_count+7 downto 8*enc_count) <= input_encrypted_8_bits;
				if(h2fValid_in = '1' and inc_enc_count ='0')then
					inc_enc_count <= '1';
					--h2fReady_out <= '1';
				elsif(inc_enc_count = '1')then
					enc_count <= enc_count +1;
					inc_enc_count <= '0';
					--h2fReady_out <= '0';
				end if;
			end if;

			if(enc_count > 7 and rec_full_data_ack = '0')then
				rec_full_data_ack <= '1';
			end if;

			if(rec_full_data_ack = '1' and rec_full_data_ack_sent = '0')then
				--led_out <= "00111100";
				if(rec_full_data_ack_count < 4)then
					temp_channel_read_input <= encrypted_ack1(8*rec_full_data_ack_count+7 downto 8*rec_full_data_ack_count);
					if(f2hReady_in = '1' and inc_rec_full_data_ack_count ='0')then
						inc_rec_full_data_ack_count <= '1';
						--f2hValid_out <= '1';
					elsif(inc_rec_full_data_ack_count = '1')then
						rec_full_data_ack_count <= rec_full_data_ack_count + 1;
						inc_rec_full_data_ack_count <= '0';
						--f2hValid_out <= '0';
					end if;
				elsif(rec_full_data_ack_count > 3)then
					rec_full_data_ack_sent <= '1';
					--f2hValid_out <= '0';
				end if;

			end if;


			if(rec_full_data_ack_sent = '1' and full_data_ack2_count<4)then
				--led_out <= "00111000";
				full_data_ack2(8*full_data_ack2_count+7 downto 8*full_data_ack2_count) <= input_encrypted_8_bits;
				if(h2fValid_in = '1' and inc_full_data_ack2_count ='0')then
					----h2fReady_out <= '1';
					inc_full_data_ack2_count <= '1';
				elsif(inc_full_data_ack2_count = '1')then
					full_data_ack2_count <= full_data_ack2_count +1;
					inc_full_data_ack2_count <= '0';
					--h2fReady_out <= '0';
				end if;
			end if;

			if(full_data_ack2_count>3 and full_data_ack2_received = '0')then
				if(full_data_ack2 = encrypted_ack2)then
					full_data_ack2_received <='1';
				end if;
			end if;


			if(full_data_ack2_received = '1' and data64_decrypted = '0')then
				if(data64_decrypted = '0' and enc64_fed = '0')then
					reset_dec <= '0';
					enc64_fed <= '1';
				elsif (data64_decrypted = '0' and enc64_fed = '1' and decryption_over1='1' and decryption_over2 ='1') then
					data64_decrypted <= '1';
				end if;
			end if;

			if(data64_decrypted ='1' and opposite_train_signal_fed= '0')then
				opposite_train_signal <= sw_in;
				opposite_train_signal_fed <= '1';
			end if;

			if(data64_decrypted = '1' and opposite_train_signal_fed = '1')then
					output_dir_vector(2) <= decrypted_64_bits_out(8*led_show_count +5);
			 		output_dir_vector(1) <= decrypted_64_bits_out(8*led_show_count +4);
					output_dir_vector(0) <= decrypted_64_bits_out(8*led_show_count +3);
					output_dir_integer <= to_integer(unsigned(output_dir_vector));

			
				if(led_show_count < 8 )then

					if(ticks > 150000000) then
						ticks <= 0;
						led_show_count <= led_show_count+1;
					else
						ticks <= ticks+1;
						--led_out <= decrypted_64_bits_out(8*led_show_count+7  downto 8*led_show_count);
						if(decrypted_64_bits_out(8*led_show_count + 7)='0' or (decrypted_64_bits_out(8*led_show_count +7)='1' and decrypted_64_bits_out(8*led_show_count +6)='0')) then

							led_out(0) <= '1';
							led_out(1) <= '0';
							led_out(2) <= '0';

						elsif(uart_read = '1' and decrypted_64_bits_out(8*led_show_count+5 downto 8*led_show_count+3)=uart_data(5 downto 3))then
							uart_output_dir_vector(2) <= uart_data(5);
					 		uart_output_dir_vector(1) <= uart_data(4);
							uart_output_dir_vector(0) <= uart_data(3);
							uart_output_dir_integer <= to_integer(unsigned(uart_output_dir_vector));

							if(uart_data(6)='0')then
								led_out(0) <= '1';
								led_out(1) <= '0';
								led_out(2) <= '0';
							elsif(uart_data(2)='0' and uart_data(1)='0')then
								led_out(0) <= '0';
								led_out(1) <= '1';
								led_out(2) <= '0';
							elsif(opposite_train_signal(uart_output_dir_integer) = '1' and opposite_train_signal((uart_output_dir_integer+4) mod 8) = '0')then
								led_out(0) <= '0';
								led_out(1) <= '0';
								led_out(2) <= '1';
							elsif(opposite_train_signal(uart_output_dir_integer) = '1' and opposite_train_signal((uart_output_dir_integer+4) mod 8) = '1') then
								if(ticks<50000000)then
									led_out(0) <= '0';
									led_out(1) <= '0';
									led_out(2) <= '1';
								elsif (ticks < 100000000) then
									led_out(0) <= '0';
									led_out(1) <= '1';
									led_out(2) <= '0';
								elsif (ticks < 150000000) then
									led_out(0) <= '1';
									led_out(1) <= '0';
									led_out(2) <= '0';
								end if;
							end if;
						elsif(opposite_train_signal(output_dir_integer) = '0')then
								led_out(0) <= '1';
								led_out(1) <= '0';
								led_out(2) <= '0';

						elsif (decrypted_64_bits_out(8*led_show_count +2)='0' and decrypted_64_bits_out(8*led_show_count +1)='0' and opposite_train_signal(output_dir_integer)='1') then
							led_out(0) <= '0';
							led_out(1) <= '1';
							led_out(2) <= '0';
						elsif(opposite_train_signal(output_dir_integer) = '1' and opposite_train_signal((output_dir_integer+4) mod 8) = '0')then
							led_out(0) <= '0';
							led_out(1) <= '0';
							led_out(2) <= '1';
						elsif(opposite_train_signal(output_dir_integer) = '1' and opposite_train_signal((output_dir_integer+4) mod 8) = '1' and output_dir_integer > (output_dir_integer+4) mod 8) then
							if(ticks<50000000)then
								led_out(0) <= '0';
								led_out(1) <= '0';
								led_out(2) <= '1';
							elsif (ticks < 100000000) then
								led_out(0) <= '0';
								led_out(1) <= '1';
								led_out(2) <= '0';
							elsif (ticks < 150000000) then
								led_out(0) <= '1';
								led_out(1) <= '0';
								led_out(2) <= '0';
							end if;

						else
							led_out(0) <= '1';
							led_out(1) <= '0';
							led_out(2) <= '0';
						end if;
						
						led_out(7) <= decrypted_64_bits_out(8*led_show_count +5);
				 		led_out(6) <= decrypted_64_bits_out(8*led_show_count +4);
						led_out(5) <= decrypted_64_bits_out(8*led_show_count +3);
						led_out(3)<='0';
						led_out(4)<='0';

					end if;
				end if;

				if(led_show_count>7 and up_debounced = '1' and state3= '0' and state4 = '0' and state5 = '0') then
					state3<='1';
				elsif(led_show_count>7 and left_debounced = '1' and state3= '0' and state4 = '0' and state5 = '0')then
					temp_channel_read_input<="11111110";
					if(f2hReady_in = '1' and not_sending_fpga='0')then
						not_sending_fpga <= '1';
						state4<='1';
					--	led_out <= "10101010";
					end if;
				elsif(led_show_count>7 and state3='0' and state4='0' and state5 = '0')then
					temp_channel_read_input<="11111110";
					if(f2hReady_in = '1' and not_sending_fpga='0')then
						not_sending_fpga <= '1';
						state5<='1';
					--	led_out <= "10101010";
					end if;
				end if;

				if(state3 = '1' and state4='0' and state5='0')then
					if(down_debounced = '1')then
						--read switch values
						if(slider_data_fed = '0')then
							slider_data <= sw_in & sw_in & sw_in & sw_in;
							slider_data_fed <= '1';
						elsif (slider_data_fed = '1' and slider_reset_done = '0') then
							slider_reset_done <= '1';
							reset_slider_data <= '0';
						end if;
						--and write into the channel
						if(slider_data_encrypted = '1' and datawritten = '0' and slider_reset_done= '1')then
							if(pos_slider_count < 4)then
								if(code_sent1 = '0')then
								--	led_out <= "10101010";
									temp_channel_read_input <= "11111111";
									if(f2hReady_in = '1' and increase_code_sent1='0')then
										increase_code_sent1 <= '1';
									elsif(increase_code_sent1='1')then
										code_sent1<='1';
									end if;
								end if;
								if (code_sent1 = '1') then
								--	led_out <= encrypted_slider_data(7 downto 0);
									temp_channel_read_input <= encrypted_slider_data(pos_slider_count*4 + 7 downto pos_slider_count*4);
								end if;
								if(f2hReady_in = '1' and inc_slider_count1 ='0' and code_sent1 = '1')then
									--f2hValid_out <= '1';
								--	led_out <= "11111000";
									inc_slider_count1 <= '1';
								elsif(inc_slider_count1 = '1')then
									pos_slider_count <= pos_slider_count + 1;
									inc_slider_count1 <= '0';
								end if;

							elsif (pos_slider_count > 3) then
--								led_out <= "01010101";
								datawritten <= '1';
--								reset_slider_data <= '1';
							end if;

						end if;

						if(left_debounced = '1' and datawritten = '1')then
							state4 <= '1';
						elsif(datawritten = '1')then
							state5 <= '1';
						end if;
					end if;
				end if;

				if(state4 = '1')then

					if(state = '0' and right_debounced = '1')then 
						temp <= '1';
						state <= '1';
					elsif(state = '1' and right_debounced = '1')then 
						temp <= '0';
					elsif(state = '1' and right_debounced = '0')then
						state <= '0';
						state5 <='1';
					end if;
				end if;

				if(state5='1' and state6 = '0')then
--					led_out<="10101010";
					--if(uart_read ='1' and send_uart_data = '0')then
					--	temp_channel_read_input <= "00000000";
					--	if(f2hReady_in='1' and increase_send_uart_data='0')then
					--		increase_send_uart_data <= '1';
					--	end if;
					--	if(increase_send_uart_data='1')then
					--		send_uart_data <= '1';
					--	end if;
					--end if;

					--if(send_uart_data='1' and uart_data_sent='0')then
					--	temp_channel_read_input <= uart_data;
					--	if(f2hReady_in='1' and increase_uart_data_sent='0')then
					--		increase_uart_data_sent <= '1';
					--	end if;
					--	if(increase_uart_data_sent='1')then
					--		uart_data_sent <= '1';
					--	end if;
					--end if;
					--if(uart_data_sent='1')then
					--	state6<='1';
					--end if;

					--if(uart_read = '0')then
					--	led_out(0)<='0';
					--	led_out(1)<='1';
					--	led_out(2)<='0';
					--	led_out(5)<='0';
					--	led_out(6)<='1';
					--	led_out(7)<='0';

					temp_channel_read_input<= "00000001";
					if(f2hReady_in = '1' and not_sending_uart='0')then
						not_sending_uart <= '1';
					end if;
					if(not_sending_uart='1')then
						state6<='1';
					end if;
				end if;



				if(state6 = '1')then
					led_out <= "11111111";
					pos_encrypted <= '0';
					posn_fed <= '0';
					show_led <= '0';
					
					reset_enc <= '1';
					pos_out_count <= 0;
					pos_matched <= '0';
					check_pos_count <= 0;
					ack_out_count <= 0;
					pos_ack2_count <= 0;
					pos_ack2_received <= '0';
					reset_dec <= '1';
					enc_count <= 0;

					rec_half_data_ack <= '0';
					rec_half_data_ack_sent <= '0';
					rec_half_data_ack_count <= 0;
					rec_full_data_ack <= '0';
					rec_full_data_ack_sent <= '0';
					rec_full_data_ack_count <= 0;
					full_data_ack2_count <= 0;
					full_data_ack2_received <= '0';
					data64_decrypted <= '0';
					opposite_train_signal_fed <= '0';
					enc64_fed <= '0';
					led_show_count <= 0;
					ticks <= 0;
					not_sending_uart <= '0';
					not_sending_fpga <= '0';
					increase_uart_data_sent <= '0';
					increase_send_uart_data <= '0';
					datawritten <= '0';
					pos_slider_count <= 0;
					code_sent1 <= '0';
					slider_data_fed <= '0';
					slider_reset_done <= '0';

					reset_slider_data <= '1';
					increase_code_sent1 <= '0';
					inc_slider_count1 <= '0';
					state3 <= '0';
					state4 <= '0';
					state5 <= '0';
					state6 <= '0';
				end if;

			end if;

			if(center_debounced = '1') then
				temp_channel_read_input <= "00011000";
				if(f2hReady_in='1')then
					show_led <= '1';
					ticks <= 0;
				end if;
			end if;
			if(show_led = '1')then
				if(ticks < 150000000) then
					led_out <= "11111111";
					ticks <= ticks +1;
				else
					--led_out <= "11111111";
					pos_encrypted <= '0';
					posn_fed <= '0';
					reset_enc <= '1';

					pos_out_count <= 0;
					pos_matched <= '0';
					check_pos_count <= 0;
					ack_out_count <= 0;
					pos_ack2_count <= 0;
					pos_ack2_received <= '0';
					enc_count <= 0;
					reset_dec <= '1';

					rec_half_data_ack <= '0';
					rec_half_data_ack_sent <= '0';
					rec_half_data_ack_count <= 0;
					rec_full_data_ack <= '0';
					rec_full_data_ack_sent <= '0';
					rec_full_data_ack_count <= 0;
					full_data_ack2_count <= 0;
					full_data_ack2_received <= '0';
					data64_decrypted <= '0';
					opposite_train_signal_fed <= '0';
					enc64_fed <= '0';
					led_show_count <= 0;
					ticks <= 0;
					show_led <= '0';
					not_sending_uart <= '0';
					not_sending_fpga <= '0';
					increase_uart_data_sent <= '0';
					increase_send_uart_data <= '0';
					datawritten <= '0';
					slider_data_fed <= '0';
					reset_slider_data <= '1';

					slider_reset_done <= '0';
					pos_slider_count <= 0;
					code_sent1 <= '0';
					increase_code_sent1 <= '0';
					inc_slider_count1 <= '0';
					state3 <= '0';
					state4 <= '0';
					state5 <= '0';
					state6 <= '0';
				end if;
			end if;

		end if;
	end process;

	-- Drive register inputs for each channel when the host is writing

	rst <= not(reset_btn);

	temp_input_encrypted_8_bits <=
		h2fData_in when chanAddr_in = "0001001" and h2fValid_in = '1' 
		else input_encrypted_8_bits;	

	with chanAddr_in select f2hData_out <=
		sw_in                 when "0000101",
		temp_channel_read_input		when "0001000",
		x"00" when others;

	i_brg : baudrate_gen port map (clk => clk_in, rst => rst, sample => sample);
	
	i_rx : uart_rx port map( clk => clk_in, rst => rst,
                            rx => uart_rx1, sample => sample,
                            rxdone => rxdone, rxdata => rxdata);
									
	i_tx : uart_tx port map( clk => clk_in, rst => rst,
                            txstart => temp,
                            sample => sample, txdata => sw_in,
                            txdone => txdone, tx => uart_tx1);



	debouncer1: debouncer
	              port map (clk => clk_in,
	                        button => up,
	                        button_deb => up_debounced);

	debouncer2: debouncer
	              port map (clk => clk_in,
	                        button => left,
	                        button_deb => left_debounced);

	debouncer3: debouncer
	              port map (clk => clk_in,
	                        button => down,
	                        button_deb => down_debounced);

	debouncer4: debouncer
	              port map (clk => clk_in,
	                        button => right,
	                        button_deb => right_debounced);

	debouncer5: debouncer
	              port map (clk => clk_in,
	                        button => center,
	                        button_deb => center_debounced);



	encrypt: encrypter
	              port map (clock => clk_in,
	                        reset => reset_enc,
	                        P => pos32,
	                        enable => enable,
	                        C => ciphertext_pos_out,
	                        done => encryption_over,
	                        K => key);

	encrypt_ack1: encrypter
	              port map (clock => clk_in,
	                        reset => reset_enc,
	                        P => ack1,
	                        enable => enable,
	                        C => encrypted_ack1,
	                        done => ack1_encryption_over,
	                        K => key);

	encrypt_ack2: encrypter
	              port map (clock => clk_in,
	                        reset => reset_enc,
	                        P => ack2,
	                        enable => enable,
	                        C => encrypted_ack2,
	                        done => ack2_encryption_over,
	                        K => key);

	encrypt_slider_data: encrypter
	              port map (clock => clk_in,
	                        reset => reset_slider_data,
	                        P => slider_data,
	                        enable => enable,
	                        C => encrypted_slider_data,
	                        done => slider_data_encrypted,
	                        K => key);


	decrypt: decrypter
	              port map (clock => clk_in,
	                        reset => reset_dec,
	                        C => input_encrypted_64bits(31 downto 0),
	                        enable => enable,
	                        P => decrypted_64_bits_out(31 downto 0),
	                        done => decryption_over1,
	                        K => key);

	decrypt2: decrypter
	              port map (clock => clk_in,
	                        reset => reset_dec,
	                        C => input_encrypted_64bits(63 downto 32),
	                        enable => enable,
	                        P => decrypted_64_bits_out(63 downto 32),
	                        done => decryption_over2,
	                        K => key);




	-- Assert that there's always data for reading, and always room for writing
	f2hValid_out <= '1';
	h2fReady_out <= '1';   
	                                                  --END_SNIPPET(registers)

	-- LEDs and 7-seg display
	flags <= "00" & f2hReady_in & reset_in;
	seven_seg : entity work.seven_seg
		port map(
			clk_in     => clk_in,
			data_in    => checksum,
			dots_in    => flags,
			segs_out   => sseg_out,
			anodes_out => anode_out
		);
end architecture;
