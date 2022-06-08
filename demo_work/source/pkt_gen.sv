`ifndef PKT_GEN_SV
`define PKT_GEN_SV
`include "pkt_data.sv"
`include "env_cfg.sv"
`timescale 10ns/1ns
class pkt_gen;
	env_cfg cfg;
	mailbox gen2drv_chan;
	pkt_data pkt;
	int send_num;
	
	extern function new(env_cfg cfg, mailbox gen2drv_chan);
	extern virtual task run();
	
endclass

function pkt_gen::new(env_cfg cfg, mailbox gen2drv_chan);
	this.cfg = cfg;
	this.gen2drv_chan  = gen2drv_chan;
	this.pkt      = new();
endfunction

task pkt_gen::run();
	pkt_data send_pkt;
	pkt_data chk_pkt;
	
	$display("At %0t, [GEN NOTE]: send_num = %0d", $time, send_num);
	repeat(send_num) begin
		assert(pkt.randomize());
		$cast(send_pkt, pkt.copy());
		$cast(chk_pkt, pkt.copy());
		gen2drv_chan.put(send_pkt);
	end
	
	this.cfg.gen_idle = 1;
	//$display("At %0t, [GEN NOTE]: gen over pkt", $time);
endtask

`endif