`ifndef ENV_CFG_SV
`define ENV_CFG_SV

class env_cfg;
	bit chk_idle;
	bit gen_idle;
	bit drv_idle;
	bit mon_idle;
	
	int env_wait_pkt_time = 10000;
	int mon_wait_pkt_time = 1000;
	int drv_wait_pkt_time = 1000;
	int chk_wait_pkt_time = 1000;
endclass:env_cfg

`endif