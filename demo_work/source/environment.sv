`ifndef ENV_SV
`define ENV_SV

`include "pkt_gen.sv"
`include "pkt_drv.sv"
`include "pkt_mon.sv"
`include "pkt_rm.sv"
`include "pkt_chk.sv"
`include "pkt_if.sv"
`include "env_cfg.sv"
`include "pkt_if_pack.sv"

class environment;
	virtual pkt_if_pack bus;
	pkt_gen gen;
	pkt_drv drv;
	pkt_mon in_mon;
	pkt_mon out_mon;
	pkt_rm  rm;
	pkt_chk chk;
	env_cfg cfg;
	mailbox gen2drv_chan;
	mailbox in_mon2rm_chan;
	mailbox rm2chk_chan;
	mailbox out_mon2chk_chan;	
	
	int send_pkt_num;	
	int wait_time;

	extern function new(input virtual pkt_if_pack bus);
	extern virtual task build();
	extern virtual task run();
	extern virtual task report();	
endclass

function environment::new(input virtual pkt_if_pack bus);
	$display("At %0t, [ENV NOTE]: environment::new() start!", $time);
	this.bus = bus;
	this.cfg = new();	
	gen2drv_chan = new();
	in_mon2rm_chan = new();
	rm2chk_chan = new();
	out_mon2chk_chan = new();	
endfunction

task environment::build();
	int test[20];
	$display("At %0t, [ENV NOTE]: environment::build() start!", $time);
	gen = new(cfg, gen2drv_chan);
	drv = new(cfg, this.bus.pkt_in_bus, gen2drv_chan);
	in_mon = new(cfg, this.bus.pkt_in_bus, this.in_mon2rm_chan, 0);
	out_mon = new(cfg, this.bus.pkt_out_bus, this.out_mon2chk_chan, 1);
	rm  = new(this.in_mon2rm_chan, this.rm2chk_chan);	
	chk = new(cfg, this.rm2chk_chan, this.out_mon2chk_chan);
endtask
	
task environment::run();
	
	fork
		drv.run();
		gen.run();
		in_mon.run();
		out_mon.run();
		rm.run();
		chk.run();
	join_none
	
	#100;
	fork
		//$display("At %0t, [ENV NOTE]: wait for end............", $time);
		begin
			wait(cfg.gen_idle);
			wait(cfg.drv_idle);
			wait(cfg.mon_idle);
			wait(cfg.chk_idle);
			$display("At %0t, [ENV NOTE]: normal finish", $time);
		end
		begin
			while(1)begin
				@(negedge top.clk);
				if(this.bus.pkt_in_bus.vld) wait_time = 0;
				else wait_time++;
				if(wait_time > this.cfg.env_wait_pkt_time) break;
			end
			$display("At %0t, [ENV ERROR]: time out!!!!!", $time);
		end		
	join_any
	
	#1000;	
	report();
endtask

task environment::report();	
	$display("At %0t, [ENV NOTE]: report start", $time);
	repeat(100) @top.clk;
	chk.report();
	$display("At %0t, [ENV NOTE]: report over", $time);
endtask
`endif