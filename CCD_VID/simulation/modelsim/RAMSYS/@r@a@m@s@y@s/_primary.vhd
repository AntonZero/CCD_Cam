library verilog;
use verilog.vl_types.all;
entity RAMSYS is
    port(
        clk_clk         : in     vl_logic;
        reset_reset_n   : in     vl_logic;
        clk143_shift_clk: out    vl_logic;
        clk143_clk      : out    vl_logic;
        clk49_5_clk     : out    vl_logic;
        wire_addr       : out    vl_logic_vector(12 downto 0);
        wire_ba         : out    vl_logic_vector(1 downto 0);
        wire_cas_n      : out    vl_logic;
        wire_cke        : out    vl_logic;
        wire_cs_n       : out    vl_logic;
        wire_dq         : inout  vl_logic_vector(15 downto 0);
        wire_dqm        : out    vl_logic_vector(1 downto 0);
        wire_ras_n      : out    vl_logic;
        wire_we_n       : out    vl_logic;
        sdram_address   : in     vl_logic_vector(24 downto 0);
        sdram_byteenable_n: in     vl_logic_vector(1 downto 0);
        sdram_chipselect: in     vl_logic;
        sdram_writedata : in     vl_logic_vector(15 downto 0);
        sdram_read_n    : in     vl_logic;
        sdram_write_n   : in     vl_logic;
        sdram_readdata  : out    vl_logic_vector(15 downto 0);
        sdram_readdatavalid: out    vl_logic;
        sdram_waitrequest: out    vl_logic
    );
end RAMSYS;
