module apbif (
			pclk,
			presetn,
			psel,
			penable,
			paddr,
			pwdata,
			pwrite,
			prdata,
			
			lcd_clk,
			rst_n,
			
			start_show,
			row_1,
			row_2,
			no_busy
			);
			
input           pclk;
input           presetn;
input			psel;
input			penable;
input	[5:2]	paddr;
input	[31:0]	pwdata;
input			pwrite;
output	[31:0]	prdata;

input			lcd_clk;
input			rst_n;

output			start_show;
output	[127:0]	row_1;
output	[127:0]	row_2;
input			no_busy;

reg		[31:0]	prdata;
reg				start_show;

wire			start_show;
wire			row_1_0_hit;
wire			row_1_1_hit;
wire			row_1_2_hit;
wire			row_1_3_hit;

wire			row_2_0_hit;
wire			row_2_1_hit;
wire			row_2_2_hit;
wire			row_2_3_hit;

wire			start_show_hit;

reg		[31:0]	reg0_row_1;
reg		[31:0]	reg1_row_1;
reg		[31:0]	reg2_row_1;
reg		[31:0]	reg3_row_1;

reg		[31:0]	reg0_row_2;
reg		[31:0]	reg1_row_2;
reg		[31:0]	reg2_row_2;
reg		[31:0]	reg3_row_2;

reg				reg_start_show_ff1;
reg				reg_start_show;
reg				start_show_run;

reg				start_show_run_ff1;
reg				start_show_run_ff2;
reg				start_show_run_ff3;

assign	row_1 = {reg3_row_1,reg2_row_1,reg1_row_1,reg0_row_1};
assign	row_2 = {reg3_row_2,reg2_row_2,reg1_row_2,reg0_row_2};

assign	row_1_0_hit = ({paddr, 2h'0} == 6'h0);
assign	row_1_1_hit = ({paddr, 2h'0} == 6'h4);
assign	row_1_2_hit = ({paddr, 2h'0} == 6'h8);
assign	row_1_3_hit = ({paddr, 2h'0} == 6'hc);

assign	row_2_0_hit = ({paddr, 2h'0} == 6'h10);
assign	row_2_1_hit = ({paddr, 2h'0} == 6'h14);
assign	row_2_2_hit = ({paddr, 2h'0} == 6'h18);
assign	row_2_3_hit = ({paddr, 2h'0} == 6'h1c);

assign	start_show_hit = ({paddr, 2'h0} == 6'h20);

assign	wr_en = psel & pwrite & penable;

always @(*) begin
	if(psel & (~pwrite)) begin
		case(paddr)
			4'h0:	prdata = reg0_row_1;
			4'h1:	prdata = reg1_row_1;
			4'h2:	prdata = reg2_row_1;
			4'h3:	prdata = reg3_row_1;
			4'h4:	prdata = reg0_row_2;
			4'h5:	prdata = reg1_row_2;
			4'h6:	prdata = reg2_row_2;
			4'h7:	prdata = reg3_row_2;
			4'h8:	prdata = {31'h0,start_show_hit};
			4'h9:	prdata = {31'h0,reg1_no_busy};
			default:prdata = 32'h0000;
		endcase
	endcase
	else begin
		prdata = 32'h0000;
	end
end

//no_busy from another clock domain
always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg0_no_busy <= 1'b0;
		reg1_no_busy <=	1'b1;
	end
	else begin
		reg0_no_busy <= no_busy;
		reg1_no_busy <= reg0_no_busy;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg3_row_1 <= "ABCD";
	end
	else if(wr_en & row_1_3_hit) begin
		reg3_row_1 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg2_row_1 <= "EFGH";
	end
	else if(wr_en & row_1_2_hit) begin
		reg2_row_1 <= pwdata;
	end
end				

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg1_row_1 <= "IJKL";
	end
	else if(wr_en & row_1_1_hit) begin
		reg1_row_1 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg0_row_1 <= "MNOP";
	end
	else if(wr_en & row_1_0_hit) begin
		reg0_row_1 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg3_row_2 <= "abcd";
	end
	else if(wr_en & row_2_3_hit) begin
		reg3_row_2 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg2_row_2 <= "efgh";
	end
	else if(wr_en & row_2_2_hit) begin
		reg2_row_2 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg1_row_2 <= "ijkl";
	end
	else if(wr_en & row_2_1_hit) begin
		reg1_row_2 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg0_row_2 <= "mnop";
	end
	else if(wr_en & row_2_0_hit) begin
		reg0_row_2 <= pwdata;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg_start_show <= 1'b0;
	end
	else if(wr_en & start_show_hit) begin
		reg_start_show <= pwdata[0];
	end
	else if(reg_start_show) begin
		reg_start_show <= 1'b0;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		reg_start_show_ff1 <= 1'b0;
	end
	else begin
		reg_start_show_ff1 <= reg_start_show;
	end
end

always @(negedge presetn or posedge pclk) begin
	if(~presetn) begin
		start_show_run <= 1'b0;
	end
	else begin
		if(reg_start_show & (~reg_start_show_ff1)) begin
			start_show_run <= ~start_show_run;
		end
	end
end

always @(negedge rst_n or posedge lcd_clk) begin
	if(~rst_n) begin
		start_show_run_ff1 <= 1'b0;
		start_show_run_ff2 <= 1'b0;
		start_show_run_ff3 <= 1'b0;
	end
	else begin
		start_show_run_ff1 <= start_show_run;
		start_show_run_ff2 <= start_show_run_ff1;
		start_show_run_ff3 <= start_show_run_ff2;
	end
end

always @(negedge rst_n or posedge lcd_clk) begin
	if(~rst_n) begin
		start_show <= 1'b0;
	end
	else if(start_show_run_ff2 ^ start_show_run_ff3) begin
		start_show <= 1'b1;
	end
	else begin
		start_show <= 1'b0;
	end
end

endmodule