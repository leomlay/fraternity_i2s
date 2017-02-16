`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:58:16 02/01/2016 
// Design Name: 
// Module Name:    fraternity_i2s_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//`define SIM 1
`define JTAG 1 
module fraternity_i2s_top (

input clk, 

input [3:0] i2s_select,

// ADV7664 Main tile
input adv_0_mclk,
input adv_0_sclk,
input [4:0] adv_0_data,

// ADV7664 1rst tile
input adv_1_mclk,
input adv_1_sclk,
input [4:0] adv_1_data,

// ADV7664 2nd tile
input adv_2_mclk,
input adv_2_sclk,
input [4:0] adv_2_data,

// ADV7664 3rd tile
input adv_3_mclk,
input adv_3_sclk,
input [4:0] adv_3_data,

// i2s audio to DSP 
output pld_dsp_mclk,
output pld_dsp_sclk,
output [4:0] pld_dsp_data,

// i2s audio from DSP 
input dsp_pld_mclk,
input dsp_pld_sclk,
input [1:0] dsp_pld_data,

// ADV7664 Main tile
output pld2adv_0_mclk,
output pld2adv_0_sclk,
output [1:0] pld2adv_0_data,

// ADV7664 1rst tile
output pld2adv_1_mclk,
output pld2adv_1_sclk,
output [1:0] pld2adv_1_data,

// ADV7664 2nd tile
output pld2adv_2_mclk,
output pld2adv_2_sclk,
output [1:0] pld2adv_2_data,

// ADV7664 3rd tile
output pld2adv_3_mclk,
output pld2adv_3_sclk,
output [1:0] pld2adv_3_data,

//BCM7444 station master
input bcm_mdc,
inout bcm_mdio,

//IPQ4019 station master
input ipq4019_mdc,
inout ipq4019_mdio,

//QCA7550 station master
input qca7550_mdc,
inout qca7550_mdio,

//CNW8302 0 station master
input cav_0_mdc,
inout cav_0_mdio,

//CNW8302 1 station master
input cav_1_mdc,
inout cav_1_mdio,

//CNW8302 2 station master
input cav_2_mdc,
inout cav_2_mdio,

// i2c bus for control for Broadcom
input bcm7444_i2c_scl,
inout bcm7444_i2c_sda,

// i2c bus for control for dakota
input ipq4019_i2c_scl,
inout ipq4019_i2c_sda,

// i2c bus for control for Ethernet over Power
input qca7550_i2c_scl,
inout qca7550_i2c_sda,

`ifdef JTAG
input tms,
input tck,
input tdi,
output tdo,
`endif

// cavium Nor Flash 
inout [2:0] cav_resetn,
input [2:0] cav_spi_wpn,
input [2:0]  cav_spi_csn0,
output [2:0] cav_spi_csn_o,
input [2:0]  cav_spi_clk_i,
output [2:0] cav_spi_clk_o,
inout [2:0] cav_spi_mosi,
input  [2:0] cav_spi_miso,
input [2:0] cav_sys_memcs1

) ;


//////////////////////////// Local Parameters ////////////////////////////////////
parameter RISING  = 2'b01 ;
parameter FALLING = 2'b10 ;

parameter FPGAVERSION = 32'h30_2E_30_30 ; 
parameter HEX_VERSION = 16'h0000 ; // should be the same as above 
parameter BRD_VERSION = 16'h0000 ;
////////////////////////////// Signals ///////////////////////////////////////////

//----------------------------------------------------------
// bcm rgmii interface io
//----------------------------------------------------------
wire bcm_mdio_i ;
wire bcm_mdio_o ;
wire bcm_mdio_t ;

gpio_tristate_io bcm7444_mdio_io( .dout (bcm_mdio_i), .din (bcm_mdio_o), .pad_io (bcm_mdio), .oe (bcm_mdio_t)) ;

mdio_interface bcm7444_mdio_mdc (
.mdc		(bcm_mdc),					// interface clock 
.mdio_i  (bcm_mdio_i),
.mdio_t  (bcm_mdio_t),
.mdio_o  (bcm_mdio_o) ) ;

//----------------------------------------------------------
// ipq4019 rgmii interface io
//----------------------------------------------------------
wire ipq4019_mdio_i ;
wire ipq4019_mdio_o ;
wire ipq4019_mdio_t ;

gpio_tristate_io ipq40197444_mdio_io( .dout (ipq4019_mdio_i), .din (ipq4019_mdio_o), .pad_io (ipq4019_mdio), .oe (ipq4019_mdio_t)) ;

mdio_interface ipq40197444_mdio_mdc (
.mdc		(ipq4019_mdc),					// interface clock 
.mdio_i  (ipq4019_mdio_i),
.mdio_t  (ipq4019_mdio_t),
.mdio_o  (ipq4019_mdio_o) ) ;

//----------------------------------------------------------
// qca7550 rgmii interface io
//----------------------------------------------------------
wire qca7550_mdio_i ;
wire qca7550_mdio_o ;
wire qca7550_mdio_t ;

gpio_tristate_io qca75507444_mdio_io( .dout (qca7550_mdio_i), .din (qca7550_mdio_o), .pad_io (qca7550_mdio), .oe (qca7550_mdio_t)) ;

mdio_interface qca75507444_mdio_mdc (
.mdc		(qca7550_mdc),					// interface clock 
.mdio_i  (qca7550_mdio_i),
.mdio_t  (qca7550_mdio_t),
.mdio_o  (qca7550_mdio_o) ) ;

//----------------------------------------------------------
// cav_0 mii interface io
//----------------------------------------------------------
wire cav_0_mdio_i ;
wire cav_0_mdio_o ;
wire cav_0_mdio_t ;

gpio_tristate_io cav_07444_mdio_io( .dout (cav_0_mdio_i), .din (cav_0_mdio_o), .pad_io (cav_0_mdio), .oe (cav_0_mdio_t)) ;

mdio_interface cav_07444_mdio_mdc (
.mdc		(cav_0_mdc),					// interface clock 
.mdio_i  (cav_0_mdio_i),
.mdio_t  (cav_0_mdio_t),
.mdio_o  (cav_0_mdio_o) ) ;

//----------------------------------------------------------
// cav_1 mii interface io
//----------------------------------------------------------
wire cav_1_mdio_i ;
wire cav_1_mdio_o ;
wire cav_1_mdio_t ;

gpio_tristate_io cav_17444_mdio_io( .dout (cav_1_mdio_i), .din (cav_1_mdio_o), .pad_io (cav_1_mdio), .oe (cav_1_mdio_t)) ;

mdio_interface cav_17444_mdio_mdc (
.mdc		(cav_1_mdc),					// interface clock 
.mdio_i  (cav_1_mdio_i),
.mdio_t  (cav_1_mdio_t),
.mdio_o  (cav_1_mdio_o) ) ;

//----------------------------------------------------------
// cav_2 mii interface io
//----------------------------------------------------------
wire cav_2_mdio_i ;
wire cav_2_mdio_o ;
wire cav_2_mdio_t ;

gpio_tristate_io cav_27444_mdio_io( .dout (cav_2_mdio_i), .din (cav_2_mdio_o), .pad_io (cav_2_mdio), .oe (cav_2_mdio_t)) ;

mdio_interface cav_27444_mdio_mdc (
.mdc		(cav_2_mdc),					// interface clock 
.mdio_i  (cav_2_mdio_i),
.mdio_t  (cav_2_mdio_t),
.mdio_o  (cav_2_mdio_o) ) ;

//----------------------------------------------------------
// cavium nor flash
//----------------------------------------------------------
wire [2:0] spi_csn ;
wire [2:0] spi_mosi_o ;
wire [2:0] spi_mosi_i ;
`ifndef JTAG
wire tms, tck, tdi, tdo ;
`endif

assign cav_spi_csn_o[0] = ( cav_resetn[0] ) ? spi_csn[0] : ( cav_spi_wpn[0] ) ? tms : spi_csn[0] ; // this is the chips spi_csn
assign cav_spi_csn_o[1] = ( cav_resetn[1] ) ? spi_csn[1] : ( cav_spi_wpn[1] ) ? tms : spi_csn[1] ; // this is the chips spi_csn
assign cav_spi_csn_o[2] = ( cav_resetn[2] ) ? spi_csn[2] : ( cav_spi_wpn[2] ) ? tms : spi_csn[2] ; // this is the chips spi_csn
assign cav_spi_clk_o[0] = ( cav_resetn[0] ) ? cav_spi_clk_i[0] : ( cav_spi_wpn[0] ) ? tck : cav_spi_clk_i[0] ; // this is the chips spi_clk
assign cav_spi_clk_o[1] = ( cav_resetn[1] ) ? cav_spi_clk_i[1] : ( cav_spi_wpn[1] ) ? tck : cav_spi_clk_i[1] ; // this is the chips spi_clk
assign cav_spi_clk_o[2] = ( cav_resetn[2] ) ? cav_spi_clk_i[2] : ( cav_spi_wpn[2] ) ? tck : cav_spi_clk_i[2] ; // this is the chips spi_clk

gpio_tristate_io mosi_0 ( .din (tdi), .pad_io (cav_spi_mosi[0]), .oe (~cav_resetn[0] && cav_spi_wpn[0]), .dout(spi_mosi_i[0])) ;
gpio_tristate_io mosi_1 ( .din (tdi), .pad_io (cav_spi_mosi[1]), .oe (~cav_resetn[1] && cav_spi_wpn[1]), .dout(spi_mosi_i[1])) ; 
gpio_tristate_io mosi_2 ( .din (tdi), .pad_io (cav_spi_mosi[2]), .oe (~cav_resetn[2] && cav_spi_wpn[2]), .dout(spi_mosi_i[2])) ; 

assign tdo = ( cav_resetn < 3'b111 ) ? 1'bz : ( cav_spi_wpn[0] ) ? cav_spi_miso[0] : ( cav_spi_wpn[1] ) ? cav_spi_miso[1] : ( cav_spi_wpn[2] ) ? cav_spi_miso[2] : 1'bz ;

// the following is to replace a picogate...
assign spi_csn[0] = cav_spi_csn0[0] && cav_sys_memcs1[0] ;
assign spi_csn[1] = cav_spi_csn0[1] && cav_sys_memcs1[1] ;
assign spi_csn[2] = cav_spi_csn0[2] && cav_sys_memcs1[2] ;

//----------------------------------------------------------
// i2s from adv7664s -> DSP
//----------------------------------------------------------

// i2s audio to DSP 
assign pld_dsp_mclk = ( i2s_select[0] ) ? adv_0_mclk : ( i2s_select[1] ) ? adv_1_mclk : ( i2s_select[2] ) ? adv_2_mclk : ( i2s_select[3] ) ? adv_3_mclk : 1'b0 ;
assign pld_dsp_sclk = ( i2s_select[0] ) ? adv_0_sclk : ( i2s_select[1] ) ? adv_1_sclk : ( i2s_select[2] ) ? adv_2_sclk : ( i2s_select[3] ) ? adv_3_sclk : 1'b0 ;
assign pld_dsp_data = ( i2s_select[0] ) ? adv_0_data : ( i2s_select[1] ) ? adv_1_data : ( i2s_select[2] ) ? adv_2_data : ( i2s_select[3] ) ? adv_3_data : 5'd0 ;

//----------------------------------------------------------
// i2s from DSP -> adv7664s
//----------------------------------------------------------
assign pld2adv_0_mclk = dsp_pld_mclk ;
assign pld2adv_0_sclk = dsp_pld_sclk ;
assign pld2adv_0_data = dsp_pld_data ;

assign pld2adv_1_mclk = dsp_pld_mclk ;
assign pld2adv_1_sclk = dsp_pld_sclk ;
assign pld2adv_1_data = dsp_pld_data ;

assign pld2adv_2_mclk = dsp_pld_mclk ;
assign pld2adv_2_sclk = dsp_pld_sclk ;
assign pld2adv_2_data = dsp_pld_data ;

assign pld2adv_3_mclk = dsp_pld_mclk ;
assign pld2adv_3_sclk = dsp_pld_sclk ;
assign pld2adv_3_data = dsp_pld_data ;
endmodule 