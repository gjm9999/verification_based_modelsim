`include "pkt_dec.sv"
`timescale 10ns/10ps
module top();
	
	logic clk;
	logic rst_n;
	
	initial begin
       	#0ns clk = 0;
		forever #5ns clk = ~clk;
	end
		
	initial begin
		#0ns rst_n = 0;
		#225ns rst_n = 1;	
	end

	wire 					data_in_vld		;
	wire 					sop_in_vld		;
	wire 					eop_in_vld		;
	wire [8			-1:0]   data_in			;
	wire 					data_out_vld	;
	wire 					sop_out_vld		;
	wire 					eop_out_vld		;
	wire [8			-1:0]   data_out		;
	wire 					fb_vld			;
	wire 					fb_eop			;
	wire 					fb_cnt			;
	
	pkt_if_pack pkt_bus(clk, rst_n);

	flow_proc #(.DATA_WIDTH(8))
	U_flow_proc(
		.clk      		(clk)				,
		.rst_n			(rst_n)				,
		.data_in_vld	(data_in_vld)		,
		.sop_in_vld		(sop_in_vld)		,
		.eop_in_vld		(eop_in_vld)		,
		.data_in		(data_in)			,
	
		.data_out_vld	(data_out_vld)		,
		.sop_out_vld	(sop_out_vld)		,
		.eop_out_vld	(eop_out_vld)		,
		.data_out		(data_out)			,
	
		.fb_vld			(fb_vld)			,
		.fb_eop			(fb_eop)			,
		.fb_cnt			(fb_cnt)
	);
	
	//test_sva #(.DATA_WIDTH(8)) U_test_sva(clk, rst_n);

	assign data_in_vld = pkt_bus.pkt_in_bus.vld		;
	assign sop_in_vld  = pkt_bus.pkt_in_bus.sop		;
	assign eop_in_vld  = pkt_bus.pkt_in_bus.eop		;
	assign data_in 	   = pkt_bus.pkt_in_bus.data    ;

	assign pkt_bus.pkt_out_bus.vld  = data_out_vld	;
	assign pkt_bus.pkt_out_bus.sop  = sop_out_vld	;
	assign pkt_bus.pkt_out_bus.eop  = eop_out_vld	;
	assign pkt_bus.pkt_out_bus.data = data_out		;

	test u_test(pkt_bus);

endmodule