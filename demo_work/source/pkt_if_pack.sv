`include "pkt_if.sv"

`ifndef PKT_INTERFACE_SV
`define PKT_INTERFACE_SV

interface pkt_if_pack(
	input logic		clk		,
	input logic		rst_n
	);
	
	pkt_if		pkt_in_bus	(clk, rst_n);
	pkt_if		pkt_out_bus (clk, rst_n);
	
endinterface : pkt_if_pack

//class pkt_interface;

//	virtual pkt_if pkt_in_bus  = pkt_if_pack.pkt_in_bus;
//	virtual pkt_if pkt_out_bus = pkt_if_pack.pkt_out_bus;
	
//endclass : pkt_interface

`endif