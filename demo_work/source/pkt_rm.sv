`ifndef PKT_RM_SV
`define PKT_RM_SV
`include "pkt_data.sv"
`include "pkt_if.sv"
`include "env_cfg.sv"

class pkt_rm;
	mailbox in_chan;
	mailbox out_chan;

	extern function new(mailbox in_chan, mailbox out_chan);
	extern virtual task run();
	extern virtual task my_run();
	extern function pkt_data data_trans(pkt_data in_data);

endclass

function pkt_rm::new(mailbox in_chan, mailbox out_chan);
	this.in_chan  = in_chan;
	this.out_chan = out_chan;
endfunction:new

task pkt_rm::run();
	fork
		my_run();
	join_none
endtask

task pkt_rm::my_run();
	pkt_data rcv_pkt;
	pkt_data send_pkt;
	while(1) begin
		this.in_chan.get(rcv_pkt);		
		//$display("At %0t, [RM NOTE]: get a expect pkt", $time);
		send_pkt = data_trans(rcv_pkt);
		this.out_chan.put(send_pkt);
		//$display("At %0t, [RM NOTE]: send a expect pkt", $time);
	end
endtask:my_run

function pkt_data pkt_rm::data_trans(pkt_data in_data);
	pkt_data tmp;
	tmp = in_data.copy();
	//foreach(in_data.payload_q[i])begin
	//	if(i == in_data.pkt_len - 1)begin
	//		tmp.payload_q[i] = in_data.payload_q[i];
	//		$display("At %0t, [RM NOTE]: tmp.payload_q[%0d] = %0h", $time, i, tmp.payload_q[i]);
	//	end
	//	else if (i >= 1)begin
	//		tmp.payload_q[i-1] = in_data.payload_q[i-1] ^ in_data.payload_q[i];
	//		$display("At %0t, [RM NOTE]: tmp.payload_q[%0d] = %0h, in_data.payload_q[i-1]=%0h, in_data.payload_q[i]=%0h", $time, i, tmp.payload_q[i], in_data.payload_q[i-1], in_data.payload_q[i]);
	//	end
	//end
	
	foreach(in_data.payload_q[i])begin
		if (i >= 1)begin
			tmp.payload_q[i-1] = in_data.payload_q[i-1] ^ in_data.payload_q[i];
		end
	end
	tmp.payload_q[in_data.pkt_len - 1] = in_data.payload_q[in_data.pkt_len - 1];
	
	return tmp;
endfunction:data_trans

`endif