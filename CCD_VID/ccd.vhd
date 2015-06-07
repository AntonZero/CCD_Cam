library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pcg.all;


entity CCD is

port(
LEDR: out std_logic_vector(9 downto 0);
CLOCK_50: IN STD_LOGIC;
SW: IN STD_LOGIC_VECTOR(9 downto 0);
------------------TV-IN---------------------------
TD_CLK27: IN STD_LOGIC;
TD_DATA: IN STD_LOGIC_VECTOR(7 downto 0);
TD_HS,TD_VS: IN STD_LOGIC;
TD_RESET_N: OUT STD_LOGIC;
KEY: IN STD_LOGIC_VECTOR(3 downto 0);
----------------VGA-Interface---------------------
VGA_B,VGA_G,VGA_R : OUT STD_LOGIC_VECTOR(7 downto 0);
VGA_CLK,VGA_BLANK_N,VGA_HS,VGA_VS,VGA_SYNC_N: OUT STD_LOGIC;
------------------SDRAM---------------------------
DRAM_ADDR: OUT STD_LOGIC_VECTOR(12 downto 0);
DRAM_BA: OUT STD_LOGIC_VECTOR(1 downto 0);
DRAM_CAS_N: OUT STD_LOGIC;
DRAM_CKE: OUT STD_LOGIC;
DRAM_CLK: OUT STD_LOGIC;
DRAM_CS_N: OUT STD_LOGIC;
DRAM_DQ: INOUT STD_LOGIC_VECTOR(15 downto 0);
DRAM_RAS_N: OUT STD_LOGIC;
DRAM_WE_N: OUT STD_LOGIC;
DRAM_LDQM,DRAM_UDQM: OUT STD_LOGIC
);


end CCD;


architecture  main of CCD is
TYPE STAGES IS (ST0,ST1,ST2);
TYPE GETCOLOR IS (GETCR,GETCB,GETY);
SIGNAL COLOR_CTRL : GETCOLOR:=GETCB;
SIGNAL BUFF_CTRL: STAGES:=ST0;
---------------------------test signals----------------------------
signal counter : integer range 0 to 1000;
signal test: std_logic:='0';
signal testdata: std_logic_vector(7 downto 0):="00000000";
signal Xpos,Ypos: integer range 0 to 799:=0;
--------------------------YCrCb_to_RGB----------------------
signal Comp_B,Comp_R,Comp_G: std_logic_vector(7 downto 0);
signal Comp_Cb,Comp_Cr,Comp_Y: std_logic_vector(7 downto 0);
signal validin,validout: std_logic;
signal STATE_FLAG:STD_LOGIC:='0';
signal init: std_logic:='1';
--------------------------BT656-----------------------------
signal BT656_ACTVID,BT656_BEGINFRAME,BT656_ENABLE: std_logic;
signal BT656_DATA: std_logic_vector(7 downto 0);
SIGNAL BT656_ENDFRAME: std_logic_vector(2 downto 0):="000";

---------------------------sync-----------------------------
signal BUFF_WAIT: std_logic:='0';
signal VGAFLAG: std_logic_vector(2 downto 0);
------------------------TV_BUFF------------------------------
signal TVADDR1,TVADDR2: integer range 0 to 511:=0;
signal TVIN1,TVIN2,TVOUT1,TVOUT2: std_logic_vector(7 downto 0);
SIGNAL TVWE1,TVWE2: std_logic:='0';
signal TVADDR1GR_sync0,TVADDR1GR_sync1,TVADDR1GR,TVADDR1_bin: std_logic_vector(8 downto 0);
SIGNAL TV_FLAG: std_logic_vector(2 downto 0):="000";
-------------------------ram/gray----------------------------
signal RAMFULL_POINTER:integer range 0 to 511:=0;
signal RAMRESTART_POINTER: integer range 0 to 511:=0;
signal RAMADDR1GR,RAMADDR2GR: std_logic_vector(8 downto 0):=(others=>'0');
signal RAMADDR1GR_sync0,RAMADDR1GR_sync1,RAMADDR1GR_sync2,RAMADDR1_bin: std_logic_vector(8 downto 0);
signal RAMADDR2GR_sync0,RAMADDR2GR_sync1,RAMADDR2GR_sync2,RAMADDR2_bin: std_logic_vector(8 downto 0);
-------------------------dual ram ----------------------------------
signal RAMIN1,RAMIN2,RAMOUT1,RAMOUT2: std_logic_vector(7 downto 0);
signal RAMWE1,RAMWE2: std_logic:='0';
signal RAMADDR1,RAMADDR2: integer range 0 to 511:=0;
------------------vga----------------------------------
signal NEXTFRAME: std_logic_vector(2 downto 0):="000";
signal FRAMEEND,FRAMESTART: std_logic:='0';
signal ACTVIDEO: std_logic:='0';
signal VGABEGIN: std_logic:='0';
signal RED,GREEN,BLUE: STD_LOGIC_VECTOR(7 downto 0);
signal offset: integer range 0 to 400000:=0;
------------------clock--------------------------------
SIGNAL CLK143,CLK143_2,CLK49_5: STD_LOGIC;
------------------sdram--------------------------------
signal pixcount: integer range 0 to 1000:=0;
signal ODD: std_logic:='0';
SIGNAL SDRAM_ADDR,SDRAM_ADDR1,SDRAM_ADDR2: STD_LOGIC_VECTOR(24 downto 0);
SIGNAL SDRAM_BE_N: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL SDRAM_CS: STD_LOGIC;
SIGNAL SDRAM_RDVAL,SDRAM_WAIT:STD_LOGIC;
SIGNAL SDRAM_RE_N,SDRAM_WE_N: STD_LOGIC;
SIGNAL SDRAM_READDATA,SDRAM_WRITEDATA: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL DRAM_DQM : STD_LOGIC_VECTOR(1 downto 0);

--------------------------------------------------------
   component YCrCb_to_RGB is
		 port(
		 YCLK: IN STD_LOGIC;
		 Y,CR,Cb: IN std_logic_vector(7 downto 0);
		 R,G,B: OUT std_logic_vector(7 downto 0);
		 enablein: in std_logic;
		 enableout: out std_logic
		 );
   end component  YCrCb_to_RGB;

   component  BT656 is
		port
		(
		clkin: in std_logic;
		datain: in std_logic_vector(7 downto 0);
		dataout: out std_logic_vector(7 downto 0);
		endfrm: buffer std_logic;
		venable: out std_logic;
		beginfrm: out std_logic
		);
   end component BT656; 
	component true_dual_port_ram_dual_clock is
		port 
		(
			clk_a	: in std_logic;
			clk_b	: in std_logic;
			addr_a	: in natural range 0 to 511;
			addr_b	: in natural range 0 to 511;
			data_a	: in std_logic_vector(7 downto 0);
			data_b	: in std_logic_vector(7 downto 0);
			we_a	: in std_logic := '1';
			we_b	: in std_logic := '1';
			q_a		: out std_logic_vector(7 downto 0);
			q_b		: out std_logic_vector(7 downto 0)
		);
	end component true_dual_port_ram_dual_clock;
	
   component  vga is
	port(
		CLK: in std_logic;
		R_OUT,G_OUT,B_OUT: OUT std_logic_vector(7 downto 0);
		R_IN,G_IN,B_IN: IN std_logic_vector(7 downto 0);
		VGAHS, VGAVS:OUT std_logic;
	   ACTVID: OUT std_logic;
		VGA_FRAMESTART: out std_logic;
		VGA_FRAMEEND: out std_logic
	);
end component vga;


component ramsys is
        port (
            clk_clk             : in    std_logic                     := 'X';             -- clk
            reset_reset_n       : in    std_logic                     := 'X';             -- reset_n
            clk143_shift_clk    : out   std_logic;                                        -- clk
            clk143_clk          : out   std_logic;                                        -- clk
            clk49_5_clk         : out   std_logic;                                        -- clk
            wire_addr           : out   std_logic_vector(12 downto 0);                    -- addr
            wire_ba             : out   std_logic_vector(1 downto 0);                     -- ba
            wire_cas_n          : out   std_logic;                                        -- cas_n
            wire_cke            : out   std_logic;                                        -- cke
            wire_cs_n           : out   std_logic;                                        -- cs_n
            wire_dq             : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            wire_dqm            : out   std_logic_vector(1 downto 0);                     -- dqm
            wire_ras_n          : out   std_logic;                                        -- ras_n
            wire_we_n           : out   std_logic;                                        -- we_n
            sdram_address       : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
            sdram_byteenable_n  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable_n
            sdram_chipselect    : in    std_logic                     := 'X';             -- chipselect
            sdram_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
            sdram_read_n        : in    std_logic                     := 'X';             -- read_n
            sdram_write_n       : in    std_logic                     := 'X';             -- write_n
            sdram_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
            sdram_readdatavalid : out   std_logic;                                        -- readdatavalid
            sdram_waitrequest   : out   std_logic                                         -- waitrequest
        );
    end component ramsys;
begin


	u0 : component ramsys
        port map (
            clk_clk             => CLOCK_50,             --          clk.clk
            reset_reset_n       => '1',       --        reset.reset_n
            clk143_shift_clk    => CLK143_2,    -- clk143_shift.clk
            clk143_clk          => CLK143,          --       clk143.clk
            clk49_5_clk         => CLK49_5,         --      clk49_5.clk
            wire_addr           => DRAM_ADDR,           --         wire.addr
            wire_ba             => DRAM_BA,             --             .ba
            wire_cas_n          => DRAM_CAS_N,          --             .cas_n
            wire_cke            => DRAM_CKE,            --             .cke
            wire_cs_n           => DRAM_CS_N,           --             .cs_n
            wire_dq             => DRAM_DQ,             --             .dq
            wire_dqm            => DRAM_DQM,            --             .dqm
            wire_ras_n          => DRAM_RAS_N,          --             .ras_n
            wire_we_n           => DRAM_WE_N,           --             .we_n
            sdram_address       => SDRAM_ADDR,       --        sdram.address
            sdram_byteenable_n  => SDRAM_BE_N,  --             .byteenable_n
            sdram_chipselect    => SDRAM_CS,    --             .chipselect
            sdram_writedata     => SDRAM_WRITEDATA,     --             .writedata
            sdram_read_n        => SDRAM_RE_N,        --             .read_n
            sdram_write_n       => SDRAM_WE_N,       --             .write_n
            sdram_readdata      => SDRAM_READDATA,      --             .readdata
            sdram_readdatavalid => SDRAM_RDVAL, --             .readdatavalid
            sdram_waitrequest   => SDRAM_WAIT    --             .waitrequest
        );

      u1 : component vga 
			port map(
					CLK=>CLK49_5,
					R_OUT=>VGA_R,
					G_OUT=>VGA_G,
					B_OUT=>VGA_B,
					R_IN=>RED,
					G_IN=>GREEN,
					B_IN=>BLUE,
					VGAHS=>VGA_HS,
					VGAVS=>VGA_VS,
				   ACTVID=>ACTVIDEO,
					VGA_FRAMESTART=>FRAMESTART,
					VGA_FRAMEEND=>FRAMEEND
					);
      u2: component YCrCb_to_RGB
		   port map (
			YCLK=>TD_CLK27,
			Y=>Comp_Y,
			Cr=>Comp_Cr,
			Cb=>Comp_Cb,
			R=>Comp_R,
			G=>Comp_G,
			B=>Comp_B,
			enablein=>validin,
			enableout=>validout
			);
      u3 : component BT656
			port map (
			clkin=>TD_CLK27,
			datain=>TD_DATA,
			dataout=>BT656_DATA,
			endfrm=>BT656_ENDFRAME(0),
			venable=>BT656_ACTVID,
			beginfrm=>BT656_BEGINFRAME
			);
		u4: component true_dual_port_ram_dual_clock
		   port map  (
			clk_a=>CLK143,
			clk_b=>clk49_5,
			addr_a=>RAMADDR1,
			addr_b=>RAMADDR2,
			data_a=>RAMIN1,
			data_b=>RAMIN2,
			we_a=>RAMWE1,
			we_b=>RAMWE2,
			q_a=>RAMOUT1,
			q_b=>RAMOUT2			
			);
		u5: component true_dual_port_ram_dual_clock
		   port map  (
			clk_a=>TD_CLK27,
			clk_b=>clk143,
			addr_a=>TVADDR1,
			addr_b=>TVADDR2,
			data_a=>TVIN1,
			data_b=>TVIN2,
			we_a=>TVWE1,
			we_b=>TVWE2,
			q_a=>TVOUT1,
			q_b=>TVOUT2			
			);




TD_RESET_N<= KEY(0);
DRAM_LDQM<=DRAM_DQM(0);
DRAM_UDQM<=DRAM_DQM(1);
DRAM_CLK<=CLK143_2;
VGA_CLK<=not CLK49_5;
SDRAM_CS<='1';
SDRAM_BE_N<="00";
VGA_BLANK_N<='1';
VGA_SYNC_N<='0';
process(TD_CLK27)
begin
if rising_edge(TD_CLK27)then

TVADDR1GR<=bin_to_gray(std_logic_vector(to_unsigned(TVADDR1,9)));

end if;
end process;

process(TD_CLK27)
begin
if rising_edge(TD_CLK27)then

   if(BT656_BEGINFRAME='1')THEN-----start recording image on 143 DOmain
	 TV_FLAG(0)<='1';
    TVADDR1<=0;
    validin<='0';
	 STATE_FLAG<='0';
	 INIT<='1';
	test<='0';
	else
	 TV_FLAG(0)<='0';
	end if;
	
	if(BT656_ACTVID='1')then
     CASE COLOR_CTRL IS
		WHEN GETCB=>
		       validin<='0';
		       Comp_Cb<=BT656_DATA;
		       COLOR_CTRL<=GETY;
				 STATE_FLAG<='1';
		WHEN GETCR=>		 
             IF(INIT='0')THEN
				 validin<='1';
				 INIT<='1';
				 else
				 validin<='0';
				 END IF;
		       COLOR_CTRL<=GETY;
				 Comp_Cr<=BT656_DATA;
				 STATE_FLAG<='0';
	   WHEN GETY=>
				 IF(INIT='1')then
				 validin<='1';
				 end if;
				 Comp_Y<=BT656_DATA;
				 
		       IF(STATE_FLAG='1')THEN
				 COLOR_CTRL<=GETCR;
				 ELSE
				 COLOR_CTRL<=GETCB;
				 END IF;
		WHEN OTHERS=>NULL;
	   END CASE;	
   ELSE
	  validin<='0';
	  STATE_FLAG<='1';
	  COLOR_CTRL<=GETCB;
	end if;
	
   TVWE1<=validout;
	IF(validout='1')then----and buffer not full;
		TVIN1<=Comp_R;
		IF(TVADDR1<511)THEN
	   TVADDR1<=TVADDR1+1;
	   ELSE
		TVADDR1<=0;
		END IF;	
	end if;



end if;
end process;

------------------------------CLK143------------------------
PROCESS (CLK143)
begin
if rising_edge(clk143)then
------------49.5 Mhz  domain double flop sync----------------------
	RAMADDR2GR_sync0<=RAMADDR2GR;
	RAMADDR2GR_sync1<=RAMADDR2GR_sync0;
	RAMADDR2_bin<=gray_to_bin(RAMADDR2GR_sync1);
   NEXTFRAME(1)<=NEXTFRAME(0);
	NEXTFRAME(2)<=NEXTFRAME(1);
	RAMADDR1GR<=bin_to_gray(std_logic_vector(to_unsigned(RAMADDR1,9)));

--------------27MHz Domain sync------------------------------------
BT656_ENDFRAME(1)<=BT656_ENDFRAME(0);
BT656_ENDFRAME(2)<=BT656_ENDFRAME(1);
TV_FLAG(1)<=TV_FLAG(0);
TV_FLAG(2)<=TV_FLAG(1);
TVADDR1GR_sync0<=TVADDR1GR;
TVADDR1GR_sync1<=TVADDR1GR_sync0;
TVADDR1_bin<=gray_to_bin(TVADDR1GR_sync1);
OFFSET<=207360;-------720*288
----------------------------------------------------
	case BUFF_CTRL is
	   when st0=>---------------wait start of new frame on CCD-Cam
		     if (TV_FLAG(2)='1')then
			  BUFF_CTRL<=ST1;
			  end if;
		when st1=>------------write image to  SDRAM 
         TVWE2<='0';	
			SDRAM_RE_N<='1';	  
	  IF(TVADDR2/=to_integer(unsigned(TVADDR1_bin)) )then --------not empty
     	 SDRAM_WE_N<='0';

		if (SDRAM_WAIT='0' and SDRAM_WE_N='0')then	

	     SDRAM_WRITEDATA(7 downto 0)<=TVOUT2; 
	       SDRAM_ADDR<=std_logic_vector(unsigned(SDRAM_ADDR)+1);
			 		IF(TVADDR2<511)THEN
						TVADDR2<=TVADDR2+1;
					ELSE
						TVADDR2<=0;
					END IF;
       end if;		
		else
	   	     	 SDRAM_WE_N<='1';

		end if;	
		
     if(BT656_ENDFRAME(2)='1' or KEY(1)='0')then-----end of image data
		   RAMADDR1<=0;
			BUFF_WAIT<='0';
			RAMFULL_POINTER<=10;----------min. value 2
			pixcount<=0;
			ODD<='0';
		   BUFF_CTRL<=st2;
			SDRAM_ADDR1<=(others=>'0');
			SDRAM_ADDR2<=std_logic_vector(to_unsigned(OFFSET,25));
			SDRAM_ADDR<=(others=>'0');
		end if;
		
		when st2=>-----------write from SDRAM to BUFFER
		      SDRAM_WE_N<='1';
            RAMWE1<=SDRAM_RDVAL;
			IF(BUFF_WAIT='0')then
					 SDRAM_RE_N<='0';
					   ------------if no wait request is issued and read enable------
		            IF(SDRAM_WAIT='0' and SDRAM_RE_N='0')THEN	
							IF(RAMFULL_POINTER<511)then-----move full pointer
								RAMFULL_POINTER<=RAMFULL_POINTER+1;
								else
								RAMFULL_POINTER<=0;
							end if;	
								IF(pixcount<719)then
									pixcount<=pixcount+1;
									else
									pixcount<=0;
									ODD<=NOT ODD;
								end if;

					      IF(ODD='0')THEN	
								SDRAM_ADDR1<=std_logic_vector(unsigned(SDRAM_ADDR1)+1);-----Odd lines
								SDRAM_ADDR<=SDRAM_ADDR1;
								ELSE
								SDRAM_ADDR2<=std_logic_vector(unsigned(SDRAM_ADDR2)+1);----Even lines
								SDRAM_ADDR<=SDRAM_ADDR2;
					      END IF;		
	               END IF;
						-------------check if the buffer is full----------------------
						IF(to_integer(unsigned(RAMADDR2_bin))=(RAMFULL_POINTER))then
								VGAFLAG(0)<='1';---------init displaying image
								SDRAM_RE_N<='1';
								BUFF_WAIT<='1';
								IF((RAMADDR2+63)<511)THEN
									RAMRESTART_POINTER<=to_integer(unsigned(RAMADDR2_bin))+63;
									ELSE
									RAMRESTART_POINTER<=to_integer(unsigned(RAMADDR2_bin))+63-511;
								END IF;
						end if;
			END IF;
			    	RAMIN1<=SDRAM_READDATA(7 downto 0);	
					------------while data is avalable, write to buffer RAM
					IF(SDRAM_RDVAL='1')then
						IF(RAMADDR1<511)then
						RAMADDR1<=RAMADDR1+1;
						else
						RAMADDR1<=0;
						end if;
					END IF;
					-------------------------------refill buffer------------------------
					     IF(to_integer(unsigned(RAMADDR2_bin))=RAMRESTART_POINTER and BUFF_WAIT='1')then
						  BUFF_WAIT<='0';		  
						  end if;
					-------------------------------end of frame--------------------------
 				        IF(NEXTFRAME(2)='1')THEN
							   BUFF_CTRL<=ST0;
								VGAFLAG(0)<='0';
								SDRAM_ADDR<=(others=>'0');
								TVADDR2<=0;
							END IF;
		when others=>NULL;
		END CASE;





end if;
end process;
PROCESS(CLK49_5)
begin
if rising_edge(CLK49_5)then
	 
RAMADDR2GR<=bin_to_gray(std_logic_vector(to_unsigned(RAMADDR2,9)));
-------------dual clock sync-------------------------
RAMADDR1GR_sync0<=RAMADDR1GR;
RAMADDR1GR_sync1<=RAMADDR1GR_sync0;
VGAFLAG(1)<=VGAFLAG(0);
VGAFLAG(2)<=VGAFLAG(1);

RAMADDR1_bin<=gray_to_bin(RAMADDR1GR_sync1);


    IF(VGAFLAG(2)='1' AND FRAMESTART='1' )THEN-------if buffer is rdy and  begin of new frame, start displaying image
	 VGABEGIN<='1';
	 end if;
	 
	 IF(FRAMEEND='1' AND VGABEGIN='1')THEN------end of frame
	 NEXTFRAME(0)<='1';
	 VGABEGIN<='0';
	 ELSE
	 NEXTFRAME(0)<='0';
	 END IF;

		IF(ACTVIDEO='1'AND to_integer(unsigned(RAMADDR1_bin))/=RAMADDR2  AND VGABEGIN='1')then----if buffer ia not empty
			IF(RAMADDR2<511)then
			RAMADDR2<=RAMADDR2+1;
			else
			RAMADDR2<=0;
			end if;
			RED<=RAMOUT2;
	      GREEN<=RAMOUT2;
		   BLUE<=RAMOUT2;
		ELSIF(VGABEGIN='0')THEN---------if buffer not ready
		red<=(others=>'0');
		green<=(others=>'0');
		blue<=(others=>'0');

	   RAMADDR2<=0;
		END IF;
end if;
end process;
end main;


