transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib RAMSYS
vmap RAMSYS RAMSYS
vlog -vlog01compat -work RAMSYS +incdir+c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys {c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/ramsys.v}
vlog -vlog01compat -work RAMSYS +incdir+c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules {c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules/ramsys_new_sdram_controller_0.v}
vlog -vlog01compat -work RAMSYS +incdir+c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules {c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules/ramsys_pll_0.v}
vlog -vlog01compat -work RAMSYS +incdir+c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules {c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules/altera_reset_controller.v}
vlog -vlog01compat -work RAMSYS +incdir+c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules {c:/users/antonio/desktop/fpga-soc/ccd_vid/db/ip/ramsys/submodules/altera_reset_synchronizer.v}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/YCrCb_to_RGB.vhd}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/BT656.vhd}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/vga.vhd}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/RAM.vhd}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/my.vhd}
vcom -93 -work work {C:/Users/Antonio/Desktop/FPGA-SOC/CCD_VID/ccd.vhd}

