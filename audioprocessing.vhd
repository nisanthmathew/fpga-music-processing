library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity audioprocessing is port (
		reset : in std_logic;
		audioClock : in std_logic; -- 18.432 MHz sample clock
		adcLRSelect1 : in std_logic;
		dataSelect1 : in std_logic;
		adcDataLeftChannelRegister2 : in std_logic_vector(15 downto 0);
		adcDataRightChannelRegister2 : in std_logic_vector(15 downto 0);
		dacDataLeftChannelRegister2: out std_logic_vector(15 downto 0);
		dacDataRightChannelRegister2 : out std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0);
		mute : in std_logic;
		volumeupkey: in std_logic;
		volumedown : in std_logic

);
end audioprocessing;
architecture behavioral of audioprocessing is	
		
		signal internalLRSelect1 : std_logic := '0';	
		signal adcDataLeftChannelRegister3, adcDataRightChannelRegister3 :  std_logic_vector(15 downto 0);
		signal dacDataLeftChannelRegister3, dacDataRightChannelRegister3:  std_logic_vector(15 downto 0);
		
		signal state1, state2 : std_logic := '0';
		signal meter,count : integer range 0 to 68000;
		signal prescaler : unsigned(23 downto 0);
		signal ledmeter,temp1,temp2 : unsigned(15 downto 0);
		signal clk_2Hz: std_logic:='0';	
begin
	
	internalLRSelect1 <= adcLRSelect1;
	
	-- sample adc data
	process(reset,internalLRSelect1)
	begin
		if reset = '0' then
			adcDataLeftChannelRegister3 <= X"0000";
			adcDataRightChannelRegister3 <= X"0000";
			
		else
			
				if falling_edge(internalLRselect1) then
				--if internalLRSelect1 = '1' then
					adcDataLeftChannelRegister3(15 downto 0) <= adcDataLeftChannelRegister2(15 downto 0);
					
				elsif rising_edge(internalLRselect1) then
				--else
				   adcDataRightChannelRegister3(15 downto 0) <= adcDataRightChannelRegister2(15 downto 0);
					
				end if;
				
				
		end if;
	

end process;


	-- dac data output
process(reset,internalLRSelect1,audioClock,mute,volumeupkey,volumedown)
		
variable volumelevel: integer range 0 to 32000 := 0;
variable volumelevel1: integer range 0 to 32000 := 0;		
		
begin

if mute = '1' then
	dacDataLeftChannelRegister2<= X"0000";
	dacDataRightChannelRegister2<= X"0000";
	
else	
	
	if reset = '0' then
			 dacDataLeftChannelRegister2<= X"0000";
			 dacDataRightChannelRegister2<= X"0000";
			 volumelevel := 0;
			 volumelevel1 := 0;
	
			 		 
	else
	
	---volume controlllllllllllll
	----checking state of key2 for increasing volume
					   if((volumeupkey = '1') and (state1 = '0')) then
								state1 <= '1';
							volumelevel := volumelevel + 1;
					   end if;
						  
						if((volumeupkey = '0') and (state1 = '1')) then
							state1 <='0';
						end if;
						
											
				--checking state of key1 for decreasing volume
						  if((volumedown = '1') and (state2 = '0')) then
    							state2 <= '1';
								if volumelevel >= volumelevel1 then
									volumelevel1 := volumelevel1 + 1;
								end if;
						  end if;
						  
						  if((volumedown = '0') and (state2 = '1')) then
								state2 <='0';
						  end if;	
							
							
							
			if falling_edge(internalLRselect1) then		
	        --if internalLRSelect1 = '1' then
				if dataSelect1 = '1' then
						
						case volumelevel - volumelevel1 is
							when 0 => dacDataLeftChannelRegister3 <= X"0000";	
										LEDG(7 downto 0) <= B"00000000";
    						when 1 => dacDataLeftChannelRegister3 <=  ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/200),16)));													
										LEDG(7 downto 0) <= B"00000001";
							when 2 => dacDataLeftChannelRegister3 <=   ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/125),16)));													
										LEDG(7 downto 0) <= B"00000001";
							when 3 => dacDataLeftChannelRegister3 <= 	 ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/70),16)));
										LEDG(7 downto 0) <= B"00000011";
							when 4 => dacDataLeftChannelRegister3 <= 	 ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/40),16)));
										LEDG(7 downto 0) <= B"00000011";
							when 5 => dacDataLeftChannelRegister3 <= 	 ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/25),16))) ;
										LEDG(7 downto 0) <= B"00000111";
							when 6 => dacDataLeftChannelRegister3 <= 	 (std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/13),16)));
										LEDG(7 downto 0) <= B"00000111";
							when 7 => dacDataLeftChannelRegister3 <= 	 ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/8),16)));
										LEDG(7 downto 0) <= B"00001111";
							when 8 => dacDataLeftChannelRegister3 <= 	 ( std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/4),16))) ;
										LEDG(7 downto 0) <= B"00011111";
							when 9 => dacDataLeftChannelRegister3 <= 	 (std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/3),16))) ;
										LEDG(7 downto 0) <= B"00111111";
							when 10 => dacDataLeftChannelRegister3 <=  (std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))/2),16))) ;
										LEDG(7 downto 0) <= B"01111111";
							when others  => dacDataLeftChannelRegister3 <= (std_logic_vector(to_signed(((to_integer(signed(adcDataLeftChannelRegister3(15 downto 0))))),16))) ;
										LEDG(7 downto 0) <= B"11111111";
						end case;													
						dacDataLeftChannelRegister2 <= (dacDataLeftChannelRegister3);
						
					end if;
			elsif rising_edge(internalLRselect1) then
			--else
				if dataSelect1 = '1' then
					case volumelevel - volumelevel1 is
						when 0 => dacDataRightChannelRegister3 <=  X"0000";																			
										count <= 0;
						when 1 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/200),16)));
										count <= 0;
						when 2 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/125),16)));
										count <= 0;
						when 3 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/70),16)));
										count <= 0;
						when 4 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/40),16)));
										count <= 0;
						when 5 => dacDataRightChannelRegister3 <=( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/25),16)));
										count <= 0;
						when 6 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/13),16)));
										count <= 0;
						when 7 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/8),16)));
										count <= 0;
						when 8 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/4),16)));
										count <= 0;
						when 9 => dacDataRightChannelRegister3 <=  ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/3),16)));
										count <= 0;
						when 10 => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))/2),16)));
										count <= 0;
						when others  => dacDataRightChannelRegister3 <= ( std_logic_vector(to_signed(((to_integer(signed(adcDataRightChannelRegister3(15 downto 0))))),16)));
										count <= 0;
					end case;
					dacDataRightChannelRegister2 <= (dacDataRightChannelRegister3);	
									
				end if;
			
			
			end if;
			----led meter clock calculation	    
     
							if (rising_edge(audioClock)) then   -- rising clock edge
									if (prescaler = X"2327FF") then     -- for 10 hz in hex
										prescaler   <= (others => '0');
										clk_2Hz   <= not clk_2Hz;
									else
										prescaler <= prescaler + "1";
									end if;
								end if;
							if rising_edge(clk_2Hz) then
						
								ledmeter(15 downto 0) <= unsigned(dacDataLeftChannelRegister3(15 downto 0));
								meter <= to_integer(ledmeter(15 downto 0));
							if count = 0 then
							case meter is
									when 0 to 3500 => LEDR(17 downto 0) <= 	  B"000000000111111111";
									when 3501 to 7000 => LEDR(17 downto 0) <=   B"000000001111111111";
									when 7001 to 10500 => LEDR(17 downto 0) <=  B"000000011111111111";
									when 10501 to 14000 => LEDR(17 downto 0) <= B"000000111111111111";
									when 14001 to 17500 => LEDR(17 downto 0) <= B"000001111111111111";
									when 17501 to 21000 => LEDR(17 downto 0) <= B"000011111111111111";
									when 21001 to 24500 => LEDR(17 downto 0) <= B"000111111111111111";
									when 24501 to 28000 => LEDR(17 downto 0) <= B"001111111111111111";
									when 28001 to 31500 => LEDR(17 downto 0) <= B"011111111111111111";
									when 31501 to 35000 => LEDR(17 downto 0) <= B"111111111111111111";
									when 35001 to 38500 => LEDR(17 downto 0) <= B"000000000111111111";
									when 38501 to 42000 => LEDR(17 downto 0) <= B"000000000011111111";
									when 42001 to 45500 => LEDR(17 downto 0) <= B"000000000001111111";
									when 45501 to 49000 => LEDR(17 downto 0) <= B"000000000000111111";
									when 49001 to 52500 => LEDR(17 downto 0) <= B"000000000000011111";
									when 52501 to 56000 => LEDR(17 downto 0) <= B"000000000000001111";
									when 56001 to 59500 => LEDR(17 downto 0) <= B"000000000000000111";
									when 59501 to 63500 => LEDR(17 downto 0) <= B"000000000000000011";
									when others => LEDR(17 downto 0) <= 		  B"000000000000000001";
							end case;
							elsif count = 1 then
							case meter is
									when 33791 to 33800 => LEDR(17 downto 0) <= B"000000000000000001";
									when 33801 to 34800 => LEDR(17 downto 0) <= B"000000000000000011";
									when 34801 to 35800 => LEDR(17 downto 0) <= B"000000000000000111";
									when 35801 to 36800 => LEDR(17 downto 0) <= B"000000000000001111";
									when 36801 to 37800 => LEDR(17 downto 0) <= B"000000000000011111";
									when 37801 to 38800 => LEDR(17 downto 0) <= B"000000000000111111";
									when 38801 to 39800 => LEDR(17 downto 0) <= B"000000000001111111";
									when 39801 to 40800 => LEDR(17 downto 0) <= B"000000000011111111";
									when 41801 to 42800 => LEDR(17 downto 0) <= B"000000000111111111";
									when 42801 to 43800 => LEDR(17 downto 0) <= B"000000001111111111";
									when 43801 to 44800 => LEDR(17 downto 0) <= B"000000011111111111";
									when 44801 to 45800 => LEDR(17 downto 0) <= B"000000111111111111";
									when 45801 to 46800 => LEDR(17 downto 0) <= B"000001111111111111";
									when 46801 to 47800 => LEDR(17 downto 0) <= B"000011111111111111";
									when 47801 to 49150 => LEDR(17 downto 0) <= B"000111111111111111";
									when others => LEDR(17 downto 0) <= B"000000000000001111";
							end case;
							elsif count = 2 then
							case meter is
									when 32500 to 34000 => LEDR(17 downto 0) <= B"000000000000000001";
									when 34001 to 35500 => LEDR(17 downto 0) <= B"000000000000000011";
									when 35501 to 37000 => LEDR(17 downto 0) <= B"000000000000000111";
									when 37001 to 38500 => LEDR(17 downto 0) <= B"000000000000001111";
									when 38501 to 40000 => LEDR(17 downto 0) <= B"000000000000011111";
									when 40001 to 41500 => LEDR(17 downto 0) <= B"000000000000111111";
									when 41501 to 43000 => LEDR(17 downto 0) <= B"000000000001111111";
									when 43001 to 44500 => LEDR(17 downto 0) <= B"000000000011111111";
									when 44501 to 46000 => LEDR(17 downto 0) <= B"000000000111111111";
									when 46001 to 47500 => LEDR(17 downto 0) <= B"000000001111111111";
									when 47501 to 49000 => LEDR(17 downto 0) <= B"000000011111111111";
									when 49001 to 50500 => LEDR(17 downto 0) <= B"000000111111111111";
									when 50501 to 52000 => LEDR(17 downto 0) <= B"000001111111111111";
									when 52001 to 53500 => LEDR(17 downto 0) <= B"000011111111111111";
									when 53501 to 55000 => LEDR(17 downto 0) <= B"000111111111111111";
									when 55001 to 56500 => LEDR(17 downto 0) <= B"001111111111111111";
									when 56501 to 60000 => LEDR(17 downto 0) <= B"011111111111111111";
									when others => LEDR(17 downto 0) <= B"000000000000001111";
							end case;
							end if;
						end if;
	end if;
end if;	
end process;
	
	
end behavioral;
