`include "pkt_dec.sv"

`ifndef PKT_DATA_SV
`define PKT_DATA_SV

class pkt_data;

	rand bit [pkt_dec::DATA_WD -1:0]   payload_q[$];
	rand int         interval;
	rand int		 pkt_len;
	
	bit				 send_over;
	
	bit [10:0] data[$];
	
	constraint data_size_cons{
		payload_q.size() == pkt_len;
	};

	constraint pkt_len_cons{
		pkt_len inside {[1:50]};
		//pkt_len == 1;
	};
	
	constraint interval_cons{
		interval inside {[3:6]};
	};

	constraint pkt_id_cons{
		payload_q[0] dist {0:/10, 1:/30, 2:/60};
	};
	
	extern function new();
	extern virtual function string psprintf(string preset = "");
	extern virtual function bit compare(pkt_data to);
	extern virtual function void pack();
	extern virtual function void unpack();
	extern virtual function pkt_data copy(pkt_data to=null);
	
endclass

function pkt_data::new();

endfunction

function bit pkt_data::compare(pkt_data to);
	bit match = 1;
	if(this.pkt_len != to.pkt_len) match = 0;
	foreach(payload_q[i]) if(this.payload_q[i] != to.payload_q[i])
		match = 0;
	return match;
endfunction:compare

function void pkt_data::pack();
	foreach (this.payload_q[i]) begin
		if (i==0 & i==pkt_len-1) //modify!!!!!
			this.data.push_back({1'b1, 1'b1, 1'b1, payload_q[i]});
		else if (i==0)
			this.data.push_back({1'b1, 1'b1, 1'b0, payload_q[i]});		
		else if (i==pkt_len-1)
			this.data.push_back({1'b1, 1'b0, 1'b1, payload_q[i]});
		else
			this.data.push_back({1'b1, 1'b0, 1'b0, payload_q[i]});		
	end
	for(int i=0; i<interval; i++)begin
	    this.data.push_front({'0});
	end
endfunction

function string pkt_data::psprintf(string preset = "");
	psprintf = {preset, $psprintf("pkt_len = %0d", pkt_len)};
	foreach(payload_q[i])
		psprintf = {psprintf, ",", $psprintf("payload[%0d] = 'h%0h", i, payload_q[i])};
endfunction

function pkt_data pkt_data::copy(pkt_data to=null);
	pkt_data tmp;
	if (to == null)
		tmp = new();
	else
		$cast(tmp, to);
	tmp.interval = this.interval;
	tmp.pkt_len  = this.pkt_len;
	tmp.send_over= this.send_over;
	foreach(this.payload_q[i])begin
		tmp.payload_q.push_back(this.payload_q[i]);
	end
	return tmp;
endfunction

function void pkt_data::unpack();
	this.pkt_len = payload_q.size();
endfunction

`endif