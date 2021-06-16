module run(lcd_if lif);
	environment env;
	transaction tr;
	event put_tr;
	
	initial begin
		env = new(lif);
		tr = new();
		
		//add your code
		/************************************************************/
		tr = env.sequencer.tr
		/************************************************************/
		
		/******************************reset********************************/
		env.clkGen.clkGenerator("apbclk", "lcdclk", 10, 10);
		env.rest;
		
		/********************************************************************/
		begin
			#110_000ns;
			assert(tr.randomize() with {tr.cmd_a == ENABLE; tr.op == WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE23_20; tr.op ==WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE11_8; tr.op ==WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE27_24; tr.op ==WRITE;});
			env.run_gen;
			#700;
			#78000ns;
			assert(tr.randomize() with {tr.cmd_a == ENABLE; tr.op == WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE3_0; tr.op ==WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE31_28; tr.op ==WRITE;});
			env.run_gen;
			#700;
			assert(tr.randomize() with {tr.cmd_a == VAULE19_16; tr.op ==WRITE;});
			env.run_gen;
			#700;
			#78000ns;
			$display("\nTEST CASE PASS ......\n");
			$finish;
		end
	end
	
	/**********************run env*********************************/
	initial begin
		fork
		env.mon.main;
		env.dri.apb_wr;
		env.scor.compare;
		join
	end
	
	/**********************test end********************************/
	initial begin
		#110_0000ns;
		$display("\nTEST CASE END......\n");
		$finish;
	end
	
	/************************covergroup***************************/
	covergroup cov_addr;
		apbdataw: coverpoint tr.pwdata;
	endgroup
	
	cov_addr cov;
	
	initial begin
		cov = new();
		forever @(posedge lif.pclk)
		cov.sample();
	end
	
endmodule