library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BT656 is
port(
clkin: in std_logic;
datain: in std_logic_vector(7 downto 0);
dataout: out std_logic_vector(7 downto 0);
endfrm: buffer std_logic;
venable: out std_logic;
beginfrm: out std_logic
);
end BT656;

architecture main of BT656 is
type fifo is array(4 downto 0) of std_logic_vector(7 downto 0);
signal tv_buff:fifo;
type state is (VS1,VS2,SAV1,EAV1,SAV2,EAV2,IMGDONE);
signal videostate :state:=VS1;
signal count: integer range 0 to 30;
signal delay: std_logic_vector(3 downto 0):="0000";
----------
begin

process(clkin)
begin
if rising_edge(clkin) then
	 for i in 0 to  3 loop
		tv_buff(i+1)<=tv_buff(i);
	 end loop;	  
	   tv_buff(0)<=datain;		
	   case videostate is
		  when VS1=>
		  ------------wait for  vertical sync of frame 1
		      venable<='0'; 
   	      if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="10101011")then
				  count<=count+1;
				  if(count>12)then
				  beginfrm<='1';
				  videostate<=SAV1;  
				  end if;	
				end if;

            if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="10000000")then
				  count<=0;
				end if;
        when SAV1=>
		      beginfrm<='0';
		      venable<='0';
				delay<="0000";
		  ---wait for start of active video
		      if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="10000000")then
				   videostate<=EAV1;
				end if;
	     when EAV1=>		
		     
			   delay(0)<='1';
			   delay(1)<=delay(0);
				delay(2)<=delay(1);
			   delay(3)<=delay(2);
			   if(delay(3)='1')then	

				dataout<=tv_buff(4);
				venable<='1';
				end if;
		   --------wait end active video, wait next line
	
		   if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="10011101")then
			   videostate<=SAV1;
			end if;
		  --------end field 1, next field2
			if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="10110110")then
            videostate<= VS2;
			end if;
	       when VS2=>
			    venable<='0';
			  ----wait for vertical sync of field2
			  if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="11110001")then
	             videostate<=SAV2;
		     end if;
		 
	      when SAV2=>
			    delay<="0000";

			    venable<='0';
			 if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="11000111")then-------- field 2 active video signal
             videostate<=EAV2;
			 end if;
			when EAV2=>
			   delay(0)<='1';
			   delay(1)<=delay(0);
			   delay(2)<=delay(1);
				delay(3)<=delay(2);
			   if(delay(3)='1')then	

				dataout<=tv_buff(4);
				venable<='1';
				end if;
				
				--------end active video, wait next line
				if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="11011010")then
					videostate<=SAV2;
				end if;
				--------end field 2, capture done
				if(tv_buff(3)="11111111" and tv_buff(2)="00000000" and tv_buff(1)="00000000" and tv_buff(0)="11110001")then
				 videostate<=IMGDONE;
				 endfrm<='1';

  				end if;
			when IMGDONE =>	
	           endfrm<='0';		
	      	  venable<='0';
				  count<=0;
				  videostate<=VS1;
	      when others=>NULL;
			END CASE;
end if;
end process;
end main;
