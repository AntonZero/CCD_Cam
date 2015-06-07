-- Quartus II VHDL Template
-- True Dual-Port RAM with dual clock
--
-- Read-during-write on port A or B returns newly written data
-- 
-- Read-during-write on port A and B returns unknown data.

library ieee;
use ieee.std_logic_1164.all;

entity true_dual_port_ram_dual_clock is

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

end true_dual_port_ram_dual_clock;

architecture rtl of true_dual_port_ram_dual_clock is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array(511 downto 0) of word_t;

	-- Declare the RAM 
	shared variable ram : memory_t;

begin

	-- Port A
	process(clk_a)
	begin
	if(rising_edge(clk_a)) then 
		if(we_a = '1') then
			ram(addr_a) := data_a;
		end if;
		q_a <= ram(addr_a);
	end if;
	end process;

	-- Port B
	process(clk_b)
	begin
	if(rising_edge(clk_b)) then 
		if(we_b = '1') then
			ram(addr_b) := data_b;
		end if;
		q_b <= ram(addr_b);
	end if;
	end process;

end rtl;
