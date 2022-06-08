`include "pkt_if.sv"
`include "environment.sv"
program automatic test(pkt_if_pack bus);
	timeunit 10ns;
	timeprecision 1ns;
	environment env;

	initial begin
		$printtimescale;
		$timeformat(-9, 3, "..ns..", 6);
	end
	
	initial begin
		env = new(bus);
		env.build();
		env.gen.send_num = 10;
		env.run();
		$display("At %0t, [TESt NOTE]: simulation finish~~~~~~~~~~~~~~~~~~", $time);
		$finish;
	end	

endprogram