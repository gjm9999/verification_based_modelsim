`ifndef PKT_IF_SV
`define PKT_IF_SV
`timescale 1ns/1ps
interface pkt_if(input clk, rst_n);
		
	logic [7:0] data;
	logic 	    sop;
	logic		eop;
	logic		vld;
	
	clocking drv @(posedge clk);
		default input #1ps output #1ps;
		output 	data;
		output	sop, eop, vld;
	endclocking : drv
	modport pkt_drv (clocking drv);
	
	clocking mon @(posedge clk);
		default input #1ps output #1ps;
		input 	data;
		input	sop, eop, vld;
	endclocking : mon
	modport pkt_mon (clocking mon);
	
endinterface

typedef virtual pkt_if.drv vdrv;
typedef virtual pkt_if.mon vmon;

`endif