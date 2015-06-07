library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga is
port(
CLK: in std_logic;
R_OUT,G_OUT,B_OUT: OUT std_logic_vector(7 downto 0);
R_IN,G_IN,B_IN: IN std_logic_vector(7 downto 0);
VGAHS, VGAVS:OUT std_logic;
VGA_FRAMESTART: out std_logic;
VGA_FRAMEEND: out std_logic;
ACTVID:OUT STD_logic
);
end vga;


architecture main of vga is
signal Xpos,Ypos : integer range 0 to 1100:=0;
begin
PROCESS (CLK) ---------------VGA OUTPUT
BEGIN
IF rising_edge(CLK) THEN
   IF(YPOS=624)THEN
	VGA_FRAMESTART<='1';
	ELSE
	VGA_FRAMESTART<='0';
	END IF;
	
	IF(YPOS=600)THEN
	VGA_FRAMEEND<='1';
	ELSE
	VGA_FRAMEEND<='0';
	END IF;
	IF(XPOS<1055)THEN
	XPOS<=XPOS+1;
	ELSIF(XPOS=1055)THEN  
	XPOS<=0;
	YPOS<=YPOS+1;
	END IF;
	
	IF(YPOS=624)THEN
	YPOS<=0;
	
	END IF;
	
   IF(XPOS>815 AND XPOS<895)THEN
	VGAHS<='0';
	ELSE
	VGAHS<='1';
	END IF;
	
	IF(YPOS>601 AND YPOS<605)THEN
	VGAVS<='0';
	ELSE
	VGAVS<='1';
	END IF;
	
	IF(XPOS>800 OR YPOS>600)THEN
		B_OUT<=(others=>'0');
		G_OUT<=(others=>'0');
		R_OUT<=(others=>'0'); 
	END IF;
	if(XPOS=1055)THEN
	ACTVID<='1';
	ELSIF(XPOS=719 OR YPOS>577)THEN
	ACTVID<='0';
	END IF;
	IF(XPOS<719 AND YPOS<577)THEN-----visible img  
  		B_OUT<=B_IN;
		R_OUT<=R_IN;
		G_OUT<=G_IN;		
		ELSE
		B_OUT<=(others=>'0');
		G_OUT<=(others=>'0');
		R_OUT<=(others=>'0'); 
   end if;
	
END IF;
END PROCESS;
end main;