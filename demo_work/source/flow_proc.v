`ifndef FLOW_PROC_V
`define FLOW_PROC_V

module flow_proc #(
	parameter DATA_WIDTH = 8
)(
	input						clk				,
	input						rst_n			,
	
	input						data_in_vld		,
	input						sop_in_vld		,
	input						eop_in_vld		,
	input  [DATA_WIDTH-1:0]		data_in			,
	
	output reg						data_out_vld	,
	output reg						sop_out_vld		,
	output reg						eop_out_vld		,
	output reg[DATA_WIDTH-1:0]		data_out		,
	
	output						fb_vld			,
	output						fb_eop			,
	output						fb_cnt			
);
	
	reg						data_in_vld_ff1	;
	reg						sop_in_vld_ff1;
	reg						eop_in_vld_ff1;
	reg [DATA_WIDTH-1:0]	data_in_ff1;
	
	reg [31:0]				data_id_cnt[(2<<DATA_WIDTH-1) -1:0];
	
	wire [DATA_WIDTH-1:0] data_in_merge = data_in_ff1 ^ data_in;
	always @(posedge clk or negedge rst_n)begin
		if(rst_n == 1'b0)begin
			data_in_vld_ff1 <= 1'b0;
			sop_in_vld_ff1	 <= 1'b0;
			eop_in_vld_ff1   <= 1'b0;
			data_in_ff1      <= {DATA_WIDTH{1'b0}};
		end
		else begin
			data_in_vld_ff1 <= data_in_vld;
			sop_in_vld_ff1	 <= sop_in_vld;
			eop_in_vld_ff1	 <= eop_in_vld;
			data_in_ff1	 	 <= data_in;
		end
	end
	
	wire 					pre_data_out_vld = data_in_vld_ff1;
	wire 					pre_sop_out_vld  = sop_in_vld_ff1;
	wire 					pre_eop_out_vld  = eop_in_vld_ff1;	
	wire [DATA_WIDTH-1:0] 	pre_data_out     = {DATA_WIDTH{eop_in_vld_ff1}}  & data_in_ff1 |
										   {DATA_WIDTH{~eop_in_vld_ff1}} & data_in_merge;

	always @(posedge clk or negedge rst_n)begin
		if(rst_n == 1'b0)begin
			data_out_vld <= 1'b0;
			sop_out_vld	 <= 1'b0;
			eop_out_vld   <= 1'b0;
			data_out      <= {DATA_WIDTH{1'b0}};
		end
		else begin
			data_out_vld <= pre_data_out_vld;
			sop_out_vld	 <= pre_sop_out_vld;
			eop_out_vld	 <= pre_eop_out_vld;
			data_out	 <= pre_data_out;
		end
	end
	
	genvar i;
	generate
		for(i=0;i<(2<<DATA_WIDTH-1);i=i+1)begin
			always @(posedge clk) begin
				if(rst_n == 1'b0)begin
					data_id_cnt[i] <= 32'b0;
				end
				else if(sop_in_vld & data_in == i)begin
					data_id_cnt[i] <= data_id_cnt[i] + 32'b1;
				end
				else begin
					data_id_cnt[i] <= data_id_cnt[i];
				end
			end
		end
	endgenerate	
endmodule

`endif