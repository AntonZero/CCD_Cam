library verilog;
use verilog.vl_types.all;
entity RAMSYS_pll_0 is
    port(
        refclk          : in     vl_logic;
        rst             : in     vl_logic;
        outclk_0        : out    vl_logic;
        outclk_1        : out    vl_logic;
        outclk_2        : out    vl_logic;
        outclk_3        : out    vl_logic;
        locked          : out    vl_logic
    );
end RAMSYS_pll_0;
