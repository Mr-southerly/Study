module top; 

lcd_if l_if(); 

environment env; 

run u_run(l_if); 

lcd1602 u_lcd(
		.pclk	(l_if.pclk),
		.presetn(l_if.presetn),
		.psel	(l_if.psel),
		.penable(l_if.penable),
		.paddr	(l_if.paddr),
		.pwdata	(l_if.pwdata),
		.pwrite	(l_if.pwrite),
		.prdata	(l_if.prdata),
		.lcd_en	(l_if.lcd_en),
		.lcd_rw	(l_if.lcd_rw),
		.lcd_rs	(l_if.lcd_rs),
		.lcd_data(l_if.lcd_data),
		.lcd_clk(l_if.lcd_clk),
		.rst_n	(l_if.rst_n)
		);
		
	initial begin
		$fsdbDumpfile("lcd.fsdb");
		$fsdbDumpvars(0, top);
	end
	
endmodule
		