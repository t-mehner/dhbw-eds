On a Basys 3 you have a 100 MHz input clock and a Xilinx 7-series FPGA, so the “normal” way in Vivado is to let the Clocking Wizard generate an MMCM (or PLL) instance and then use its output as your 25 MHz clock.

1. Create the clocking IP

* In Vivado: IP Catalog → search “Clocking Wizard” → double click.
* Input clock: set to 100.000 MHz.
* Output clocks: enable one output, set it to 25.000 MHz.
* Leave “Reset” enabled (recommended).
* Let it use an MMCM (Vivado typically chooses MMCM; either is fine for 25 MHz).

