`ifndef PKT_DRV_SV
`define PKT_DRV_SV
`include "pkt_data.sv"
`include "pkt_if.sv"
`include "env_cfg.sv"

class pkt_drv;
	env_cfg cfg;
	mailbox gen2drv_chan;
	vdrv dif;
	
	//for finish simu	
	int idle_cnt;
	
	int get_num;
	
	extern function new(env_cfg cfg,
						vdrv dif,
						mailbox gen2drv_chan
						);
	extern virtual task run();
	extern virtual task my_run();
	extern virtual task rst_sig();
	extern virtual task pkt_send(input pkt_data pkt);
	extern virtual task set_idle();

endclass

function pkt_drv::new(env_cfg cfg,
				      vdrv dif,
					  mailbox gen2drv_chan
					 );
	this.cfg = cfg;
	this.dif = dif;
	this.gen2drv_chan = gen2drv_chan;
	this.get_num = 0;
endfunction

task pkt_drv::run();
	fork
		my_run();
		set_idle();
	join_none
endtask

task pkt_drv::my_run();
	pkt_data send_pkt;
	
	//$display("At %0t, [DRV NOTE]: pkt_drv run start!", $time);
	rst_sig();
	//$display("At %0t, [DRV NOTE]: after rst_n", $time);
	while(1) begin
		gen2drv_chan.peek(send_pkt);
		//$display("At %0t, [DRV NOTE]: get no.%0d pkt from gen", $time, this.get_num++);		
		send_pkt.pack();
		pkt_send(send_pkt);
		gen2drv_chan.get(send_pkt);
		rst_sig();
	end
endtask:my_run

task pkt_drv::rst_sig();
	wait(top.rst_n == 1'b1);
	@(posedge top.clk);
	this.dif.vld <= '0;
	this.dif.sop <= '0;
	this.dif.eop <= '0;
	this.dif.data<= '0;
endtask

task pkt_drv::pkt_send(input pkt_data pkt);
	foreach(pkt.data[i]) begin
		@(posedge top.clk);
		this.dif.vld <= pkt.data[i][10];
		this.dif.sop <= pkt.data[i][9];
		this.dif.eop <= pkt.data[i][8];
		this.dif.data<= pkt.data[i][7:0];
	end	
endtask

task pkt_drv::set_idle();
	while(1)begin
		@(negedge top.clk);
		if(this.dif.vld == 1) idle_cnt = 0;
		else idle_cnt++;
		if(idle_cnt > this.cfg.drv_wait_pkt_time) this.cfg.drv_idle = 1;
		else this.cfg.drv_idle = 0;
	end
endtask:set_idle

`endif