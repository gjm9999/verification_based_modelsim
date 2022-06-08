`ifndef PKT_CHK_SV
`define PKT_CHK_SV

`include "pkt_data.sv"
`include "env_cfg.sv"

class pkt_chk;
	env_cfg cfg;
	pkt_data expect_q[$];
	int in_expect, in_actual;
	int match, not_match;
	mailbox gen2chk_chan;
	mailbox mon2chk_chan;
	
	//for finish simu
	int idle_cnt;
	
	extern function new(env_cfg cfg, 
						mailbox gen2chk_chan, 
						mailbox mon2chk_chan);
	extern virtual task run();
	extern virtual task expect_gain();
	extern virtual task actual_gain();
	extern virtual task set_idle();
	extern virtual function report();

endclass:pkt_chk

function pkt_chk::new(env_cfg cfg, 
					  mailbox gen2chk_chan, 
					  mailbox mon2chk_chan);
	this.cfg = cfg;
	this.gen2chk_chan = gen2chk_chan;
	this.mon2chk_chan = mon2chk_chan;
endfunction:new

task pkt_chk::run();
	fork
		expect_gain();
		actual_gain();
		set_idle();
	join_none
endtask:run

task pkt_chk::expect_gain();
	pkt_data expect_data;
	while(1) begin
		gen2chk_chan.get(expect_data);
		$display("At %0t, [CHK NOTE]: get a expect pkt", $time);
		this.expect_q.push_back(expect_data);
		in_expect++;
		idle_cnt = 0;
		//$display("At %0t, [CHK NOTE]: get a expect pkt", $time);
	end
endtask:expect_gain

task pkt_chk::actual_gain();
	pkt_data expect_data;
	pkt_data actual_data;
	while(1) begin
		mon2chk_chan.get(actual_data);
		$display("At %0t, [CHK NOTE]: get a actual pkt", $time);
		in_actual++;
		idle_cnt = 0;
		if(this.expect_q.size == 0) begin
			$display("At %0t, [CHK ERROR]: expect_q==0???", $time);
			$finish;
		end
		else begin
			expect_data = expect_q[0];
			if(!expect_data.compare(actual_data)) begin
				$display("At %0t, [CHK ERROR]: no match, \nexpect data:%s \nactual data:%s ", $time, expect_data.psprintf(), actual_data.psprintf());
				expect_q.pop_front();
				not_match++;
			end
			else begin
				expect_q.pop_front();
				$display("At %0t, [CHK NOTE]: match!!!!", $time);
				//$display("At %0t, [CHK NOTE]: match!!!! \nexpect data:%s \nactual data:%s ", $time, expect_data.psprintf(), actual_data.psprintf());
				match++;
			end
		end
	end
endtask:actual_gain

task pkt_chk::set_idle();
	while(1)begin
		@(negedge top.clk);
		idle_cnt++;
		if(idle_cnt > this.cfg.chk_wait_pkt_time) this.cfg.chk_idle = 1;
		else this.cfg.chk_idle = 0;
	end
endtask:set_idle

function pkt_chk::report();
	$display("----------------------------------------------------------------------------------------------------");
	$display("[CHECKER REPORT]expect pkt_num=%0d, actual pkt_num=%0d, match pkt_num=%0d, not match pkt_num=%0d", in_expect, in_actual, match, not_match);
	$display("----------------------------------------------------------------------------------------------------");
endfunction:report

`endif