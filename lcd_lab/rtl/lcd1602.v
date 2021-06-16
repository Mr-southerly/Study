module lcd1602 (
			pclk,
			presetn,
			psel,
			penable,
			paddr,
			pwdata,
			pwrite,
			prdata,
			
			lcd_en,
			lcd_rw,
			lcd_rs,
			lcd_data,
			lcd_clk,
			
			rst_n
			);

input           pclk;
input           presetn;
input			psel;
input			penable;
input	[5:2]	paddr;
input	[31:0]	pwdata;
input			pwrite;
output	[31:0]	prdata;

input 			lcd_clk;
input			rst_n;

output			lcd_en;
output			lcd_rw;
output			lcd_rs;
output	[7:0]	lcd_data;

wire			start_show;
wire	[127:0]	row_1;
wire	[127:0]	row_2;
wire			no_busy;

lcd_1602_driver u1_lcd_1602_driver(
				.clk	(lcd_clk),
				.rst_n	(rst_n),
				.lcd_en	(lcd_en),
				.lcd_rw	(lcd_rw),
				.lcd_rs	(lcd_rs),
				.lcd_data(lcd_data),
				.start_show(start_show),
				.row_1	(row_1),
				.row_2	(row_2),
				.no_busy(no_busy)
				);

apbif u_apbif(
				.pclk	(pclk),
				.presetn(presetn),
				.psel	(psel),
				.penable(penable),
				.paddr	(paddr),
				.pwdata	(pwdata),
				.pwrite	(pwrite),
				.prdata	(prdata),
				
				.lcd_clk(lcd_clk),
				.rst_n	(rst_n),
				.start_show(start_show),
				.row_1	(row_1),
				.row_2	(row_2),  
				.no_busy(no_busy)
				);

endmodule