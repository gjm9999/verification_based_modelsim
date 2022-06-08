`ifndef PKT_MON_SV
`define PKT_MON_SV

`include "pkt_data.sv"
`include "pkt_if.sv"
`include "env_cfg.sv"

class pkt_mon;
	env_cfg cfg;
	vmon mif;
	mailbox mon2chk_chan;
	bit inout_type;
	bit rec_status;//0:wait sop, 1:wait eop
	int wait_pkt_time = 1000;
	
	extern function new(env_cfg cfg,
						vmon mif,
						mailbox mon2chk_chan,
						bit inout_type);
	extern virtual task run();
	extern virtual task send_chk(pkt_data pkt);
endclass

function pkt_mon::new(env_cfg cfg,
					  vmon mif,
					  mailbox mon2chk_chan,
					  bit inout_type
					 );
	this.cfg = cfg;
	this.mif = mif;
	this.mon2chk_chan = mon2chk_chan;
	this.wait_pkt_time = cfg.mon_wait_pkt_time;
	this.rec_status = 0;
	this.inout_type = inout_type;
endfunction : new

task pkt_mon::run();
	pkt_data  rec_pkt;
	int 	  wait_time;
	int		  i = 0;
	
	//$display("At %0t, [MON NOTE]: run start!", $time);
	while(1) begin
		while(1) begin
			@(posedge top.clk);
			if(mif.vld == 1)begin
				//$display("At %0t, [MON REPORT]: %0h", $time, mif.data);
				wait_time = 0;
				if(rec_status == 0) begin//wait sop
					rec_pkt = new();
					if(mif.sop == 0) begin
						$display("At %0t, [MON ERROR]: ERROR! The first pkt cycle is not sop!", $time);
						break;
					end
					else begin
						rec_pkt.payload_q.push_back(mif.data);
						if(mif.eop == 1) begin
							rec_status = 0;
							//$display("At %0t, [MON NOTE]: get no.%0d pkt!", $time, i++);
							send_chk(rec_pkt);
						end
						else
							rec_status = 1;
					end
				end
				else if(rec_status == 1) begin//wait eop
					if(mif.sop == 1) begin
						$display("At %0t, [MON ERROR]: ERROR! SOP????", $time);
						break;
					end
					else begin
						rec_pkt.payload_q.push_back(mif.data);
						if(mif.eop == 1) begin
							rec_status = 0;
							//$display("At %0t, [MON NOTE]: get no.%0d pkt!", $time, i++);
							send_chk(rec_pkt);
						end
						else
							rec_status = 1;
					end
				end
			end
			else begin
				wait_time++;
				if(wait_time <= wait_pkt_time) begin
					wait_time++;
				end
				else break;
			end
		end
		this.cfg.mon_idle = 1;
		//$display("At %0t, [MON NOTE]: mon run over!", $time);
		break;
	end
endtask : run
	
task pkt_mon::send_chk(pkt_data pkt);
	pkt.unpack();
	mon2chk_chan.put(pkt);
	//if(this.inout_type == 0) $display("At %0t, [IN  MON NOTE]: send a pkt: %s", $time, pkt.psprintf());
	//if(this.inout_type == 1) $display("At %0t, [OUT MON NOTE]: send a pkt: %s", $time, pkt.psprintf());
endtask : send_chk	
`endif







