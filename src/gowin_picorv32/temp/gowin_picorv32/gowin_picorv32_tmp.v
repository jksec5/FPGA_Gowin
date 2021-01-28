//Copyright (C)2014-2020 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.7Beta
//Part Number: GW2A-LV18PG484C8/I7
//Device: GW2A-18C
//Created Time: Tue Nov 10 16:08:16 2020

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_PicoRV32_Top your_instance_name(
		.ser_tx(ser_tx_o), //output ser_tx
		.ser_rx(ser_rx_i), //input ser_rx
		.wbuart_tx(wbuart_tx_o), //output wbuart_tx
		.wbuart_rx(wbuart_rx_i), //input wbuart_rx
		.gpio_io(gpio_io_io), //inout [31:0] gpio_io
		.slv_ext_stb_o(slv_ext_stb_o_o), //output slv_ext_stb_o
		.slv_ext_we_o(slv_ext_we_o_o), //output slv_ext_we_o
		.slv_ext_cyc_o(slv_ext_cyc_o_o), //output slv_ext_cyc_o
		.slv_ext_ack_i(slv_ext_ack_i_i), //input slv_ext_ack_i
		.slv_ext_adr_o(slv_ext_adr_o_o), //output [31:0] slv_ext_adr_o
		.slv_ext_wdata_o(slv_ext_wdata_o_o), //output [31:0] slv_ext_wdata_o
		.slv_ext_rdata_i(slv_ext_rdata_i_i), //input [31:0] slv_ext_rdata_i
		.slv_ext_sel_o(slv_ext_sel_o_o), //output [3:0] slv_ext_sel_o
		.io_spi_clk(io_spi_clk_io), //inout io_spi_clk
		.io_spi_csn(io_spi_csn_io), //inout io_spi_csn
		.io_spi_mosi(io_spi_mosi_io), //inout io_spi_mosi
		.io_spi_miso(io_spi_miso_io), //inout io_spi_miso
		.irq_in(irq_in_i), //input [31:20] irq_in
		.jtag_TDI(jtag_TDI_i), //input jtag_TDI
		.jtag_TDO(jtag_TDO_o), //output jtag_TDO
		.jtag_TCK(jtag_TCK_i), //input jtag_TCK
		.jtag_TMS(jtag_TMS_i), //input jtag_TMS
		.clk_in(clk_in_i), //input clk_in
		.resetn_in(resetn_in_i) //input resetn_in
	);

//--------Copy end-------------------
