library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pcg  is
function gray_to_bin (gray : std_logic_vector)return std_logic_vector;
function bin_to_gray (binary: std_logic_vector) return std_logic_vector;
end pcg;



package body pcg is 
   function bin_to_gray (binary: std_logic_vector)return  std_logic_vector is
	variable gray : std_logic_vector(8 downto 0);
begin
	gray(8):=binary(8);
	gray(7):=binary(8)XOR binary(7);
	gray(6):=binary(7)XOR binary(6); 
	gray(5):=binary(6)XOR binary(5); 
	gray(4):=binary(5)XOR binary(4); 
	gray(3):=binary(4)XOR binary(3); 
	gray(2):=binary(3)XOR binary(2); 
	gray(1):=binary(2)XOR binary(1);
	gray(0):=binary(1)XOR binary(0); 
	return gray;
end function bin_to_gray;


function gray_to_bin (gray : std_logic_vector)return std_logic_vector is
    variable  binary : std_logic_vector(8 downto 0);
	 begin
	 binary(8) := gray(8);
    binary(7) := gray(8) xor gray(7);
    binary(6) := gray(8) xor gray(7) xor gray(6);
    binary(5) := gray(8) xor gray(7) xor gray(6) xor gray(5);
	 binary(4) := gray(8) xor gray(7) xor gray(6) xor gray(5) xor gray(4);
	 binary(3) := gray(8) xor gray(7) xor gray(6) xor gray(5) xor gray(4) xor gray(3);
	 binary(2) := gray(8) xor gray(7) xor gray(6) xor gray(5) xor gray(4) xor gray(3) xor gray(2);
	 binary(1) := gray(8) xor gray(7) xor gray(6) xor gray(5) xor gray(4) xor gray(3) xor gray(2) xor gray(1);
	 binary(0) := gray(8) xor gray(7) xor gray(6) xor gray(5) xor gray(4) xor gray(3) xor gray(2) xor gray(1) xor gray(0);
	 return binary;

end function gray_to_bin;

end pcg;