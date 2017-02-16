`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Eva Automation
// Engineer: Leonard Lay
// 
// Create Date:     07/09/2015 
// Design Name: 
// Module Name: mdio_interface 
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
module mdio_interface(
input mdc,					// interface clock 
input mdio_i,
output reg mdio_t = 1'b0,
output mdio_o  
) ;

//////////////////////////////////////////////////////////////////////////////
// Local Parameter Declarations
//////////////////////////////////////////////////////////////////////////////
parameter REG0_CFG = 16'b0010_0001_0000_0000 ; // 100Mbps, disable auto-negotiate, full duplex
parameter REG1_CFG = 16'b0100_0000_0010_0100 ; 
parameter REG2_CFG = 16'b0000_0000_0100_1101 ;
parameter REG3_CFG = 16'b1101_0000_0010_0011 ; // Ar8032 PHY
parameter REG4_CFG = 16'b0000_0001_0000_0001 ;
parameter REG5_CFG = 16'b0000_0000_0000_0000 ;
parameter REG6_CFG = 16'b0000_0000_0000_0000 ;
parameter REG10CFG = 16'b0010_1100_0001_0000 ;
parameter REG16CFG = 16'b0000_0000_0000_0010 ;
parameter REG17CFG = 16'b0000_0000_0011_0010 ; // rmii interface with the buffer allowing 7200 byte packets


//////////////////////////////////////////////////////////////////////////////
// Signal Declarations
//////////////////////////////////////////////////////////////////////////////
reg [35:0] shift = 36'd0 ;
reg preamble = 1'b0 ;
reg rdnwr = 1'b0 ;
reg [6:0] activity = 6'h20 ;
reg [4:0] phy = 5'd0 ;
reg [4:0] addr = 5'd0 ;
reg [16:0] shift_out = { 1'b0,REG0_CFG } ;
reg shift_it = 1'b0 ;
reg drive_it = 1'b0 ;
reg load_shift = 1'b0 ;

assign mdio_o = shift_out[15] && ~load_shift ;

always@(posedge mdc)
begin
	shift 		<= { shift[34:0], mdio_i } ;
	preamble 	<= ( shift[35:0] == 36'hffff_ffff_6 ) || ( shift[35:0] == 36'hffff_ffff_5 ) ;
	rdnwr 		<= ( preamble ) ? ( shift[4:1] == 4'h6 ) : rdnwr ;
	activity 	<= ( preamble ) ? 7'd0 : ( activity[6] ) ? activity : activity + 7'd1 ; 
	addr 		<= ( activity == 7'h08 ) ? shift[4:0] : addr ;
	load_shift 	<= ( activity == 7'd08 ) ;
	shift_it 	<= ( activity == 7'd08 ) ? 1'b1 : ( activity == 7'd25 ) ? 1'b0 : shift_it ;
	drive_it 	<= ( activity == 7'd07 ) ? 1'b1 : ( activity == 7'd24 ) ? 1'b0 : drive_it ;
	phy	 		<= ( activity == 7'd3 ) ? shift[4:0] : phy ;
	
	if ( load_shift )
		case(addr)
			5'h00 : shift_out <= { 1'b0,REG0_CFG } ;
			5'h01 : shift_out <= { 1'b0,REG1_CFG } ;
			5'h02 : shift_out <= { 1'b0,REG2_CFG } ;
			5'h03 : shift_out <= { 1'b0,REG3_CFG } ;
			5'h04 : shift_out <= { 1'b0,REG4_CFG } ;
			5'h05 : shift_out <= { 1'b0,REG5_CFG } ;
			5'h06 : shift_out <= { 1'b0,REG6_CFG } ;
			5'h10 : shift_out <= { 1'b0,REG10CFG } ;
//			5'h12 : shift_out <= { 1'b0,REG6_CFG } ; // all zeros
			5'h16 : shift_out <= { 1'b0,REG16CFG } ;
			5'h17 : shift_out <= { 1'b0,REG17CFG } ;
			default : shift_out <= { 1'b0,16'b0000_0000_0000_0000 } ;
		endcase
	else
		shift_out <= ( shift_it ) ? { shift_out[15:0], 1'b0 } : shift_out ;
		 // 
	mdio_t <= ( rdnwr ) && ( drive_it ) && ( phy == 5'd4 ) ; // || ( phy == 5'd4 ) || ( phy == 5'd5 )
//	mdio_o <= shift_out[15] && ~load_shift ;
	
end

endmodule 