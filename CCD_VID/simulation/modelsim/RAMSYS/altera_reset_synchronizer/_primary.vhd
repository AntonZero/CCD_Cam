library verilog;
use verilog.vl_types.all;
entity altera_reset_synchronizer is
    generic(
        ASYNC_RESET     : integer := 1;
        DEPTH           : integer := 2
    );
    port(
        reset_in        : in     vl_logic;
        clk             : in     vl_logic;
        reset_out       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ASYNC_RESET : constant is 1;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
end altera_reset_synchronizer;
