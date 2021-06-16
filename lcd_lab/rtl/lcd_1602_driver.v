module lcd_1602_driver (
				clk,
				rst_n,
				lcd_en,
				lcd_rw,
				lcd_rs,
				lcd_data,
				start_show,
				row_1,
				row_2,
				no_busy
				);

input			clk;
input			rst_n;

input			start_show;
output			lcd_en;
output			lcd_rw;
output			lcd_rs;
output	[7:0]	lcd_data;

input	[127:0]	row_1;
input	[127:0]	row_2;
output			no_busy;

wire			clk;
wire			rst_n;
reg				lcd_en;
wire			lcd_rw;
reg		[7:0]	lcd_data;
reg				lcd_rs;
reg		[5:0]	c_state;
reg		[5:0]	n_state;

wire			lcd_en_pre;
wire			lcd_en_wire;

reg				lcd_en_wire_ff1;
reg				lcd_en_wire_ff2;
reg				lcd_en_wire_ff3;

reg				start_flag;
reg				no_busy;

wire	[127:0]	row_1;
wire	[127:0]	row_2;

//*********************************************************************//
//initialize
//first step is waiting more than 20 ms
parameter TIME_20MS = 1000_000;  //200000000/20=1000000
//parameter TIME_15MS = 9'h100; //just for test 
parameter TIME_500HZ = 100_000;
//parameter TIME 500Hz= 4'hf; //iust for test
//use gray code
parameter	IDLE = 8'h00;
parameter	SET_FUNCTION = 8'h01;
parameter	DISP_OFF = 8'h02;
parameter	DISP_CLEAR = 8'h03;
parameter	ENTRY_MODE = 8'h04;
parameter	DISP_ON = 8'h05;
parameter	ROW1_ADDR = 8'h06;
parameter	ROW1_0 = 8'h07;
parameter	ROW1_1 = 8'h08;
parameter	ROW1_2 = 8'h09;
parameter	ROW1_3 = 8'h0A;
parameter	ROW1_4 = 8'h0B;
parameter	ROW1_5 = 8'h0C;
parameter	ROW1_6 = 8'h0D;
parameter	ROW1_7 = 8'h0E;
parameter	ROW1_8 = 8'h0F;
parameter	ROW1_9 = 8'h10;
parameter	ROW1_A = 8'h11;
parameter	ROW1_B = 8'h12;
parameter	ROW1_C = 8'h13;
parameter	ROW1_D = 8'h14;
parameter	ROW1_E = 8'h15;
parameter	ROW1_F = 8'h16;

parameter	ROW2_ADDR = 8'h17;
parameter	ROW2_0 = 8'h18;
parameter	ROW2_1 = 8'h19;
parameter	ROW2_2 = 8'h1A;
parameter	ROW2_3 = 8'h1B;
parameter	ROW2_4 = 8'h1C;
parameter	ROW2_5 = 8'h1D;
parameter	ROW2_6 = 8'h1E;
parameter	ROW2_7 = 8'h1F;
parameter	ROW2_8 = 8'h20;
parameter	ROW2_9 = 8'h21;
parameter	ROW2_A = 8'h22;
parameter	ROW2_B = 8'h23;
parameter	ROW2_C = 8'h24;
parameter	ROW2_D = 8'h25;
parameter	ROW2_E = 8'h26;
parameter	ROW2_F = 8'h27;
parameter	SHOW_END = 8'h28;

//20ms
reg		[19:0]	cnt_20ms;
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_20ms <= 0;
	end
	else if(cnt_20ms == TIME_20MS - 1) begin
		cnt_20ms <= cnt_20ms;
	end
	else
		cnt_20ms <= cnt_20ms + 1;
end
wire	delay_done = (cnt_20ms == TIME_20MS - 1) ? 1'b1 : 1'b0;

/*****************************************************************/
//500ns  LCD1602    500HZ,FPGA 50Mhz
reg		[19:0]	cnt_500hz;
always	@(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_500hz <= 0;
	end
	else if(delay_done == 1) begin
		if(cnt_500hz == TIME_500HZ - 1)
			cnt_500hz <= 0;
		else
			cnt_500hz <= cnt_500hz + 1;
	end
	else
		cnt_500hz <= 0;
end

assign lcd_en_pre = (cnt_500hz > (TIME_500HZ - 1)/2) ? 1'b0 : 1'b1;
assign lcd_en_wire = (c_state != SHOW_END) & lcd_en_pre;
assign write_flag = (cnt_500hz == TIME_500HZ - 1) ? 1'b1 : 1'b0;

/***********************************************************************/
//set function, display off, display clear, entry mode set
//for timing delay lcd_en
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		lcd_en <= 1'b0;
		lcd_en_wire_ff1 <= 1'b0;
		lcd_en_wire_ff2 <= 1'b0;
		lcd_en_wire_ff3 <= 1'b0;
	end
	else begin
		lcd_en <= lcd_en_wire_ff3;
		lcd_en_wire_ff1 <= lcd_en_wire;
		lcd_en_wire_ff2 <= lcd_en_wire_ff1;
		lcd_en_wire_ff3 <= lcd_en_wire_ff2;
	end
end

/****************************************************************/
//busy
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		no_busy <= 1'b0;
	end
	else begin
		if(c_state == SHOW_END) begin
			no_busy <= 1'b1;
		end
		else begin
			no_busy <= 1'b0;
		end
	end
end

/*********************************************************************/
//shart_show
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		start_flag <= 1'b0;
	end
	else begin
		if(shart_show) begin
			start_flag <= 1'b1;
		end
		else if(write_flag == 1) begin
			start_flag <= 1'b0;
		end
	end
end

/********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		c_state <= IDLE;
	end
	else if(write_flag == 1) begin
		if(start_flag == 1'b1) begin
			c_state <= ROW1_ADDR;
		end
		else if(c_state == SHOW_END) begin
			c_state <= n_state;
		end
	end
	else begin
		c_state <= c_state;
	end
end

/*************************************************************************/
always @(*) begin
	case(c_state)
		IDLE: n_state = SET_FUNCTION;
		SET_FUNCTION: n_state = DISP_OFF;
		DISP_OFF: n_state = DISP_CLEAR;
		DISP_CLEAR: n_state = ENTRY_MODE;
		ENTRY_MODE: n_state = DISP_ON;
		DISP_ON: n_state = ROW1_ADDR;
		ROW1_ADDR: n_state = ROW1_0;
		ROW1_0: n_state = ROW1_1;
		ROW1_1: n_state = ROW1_2;
		ROW1_2: n_state = ROW1_3;
		ROW1_3: n_state = ROW1_4;
		ROW1_4: n_state = ROW1_5;
		ROW1_5: n_state = ROW1_6;
		ROW1_6: n_state = ROW1_7;
		ROW1_7: n_state = ROW1_8;
		ROW1_8: n_state = ROW1_9;
		ROW1_9: n_state = ROW1_A;
		ROW1_A: n_state = ROW1_B;
		ROW1_B: n_state = ROW1_C;
		ROW1_C: n_state = ROW1_D;
		ROW1_D: n_state = ROW1_E;
		ROW1_E: n_state = ROW1_F;		
		ROW1_F: n_state = ROW2_ADDR;
		
		ROW2_ADDR: n_state = ROW2_0;
		ROW2_0: n_state = ROW2_1;
		ROW2_1: n_state = ROW2_2;
		ROW2_2: n_state = ROW2_3;
		ROW2_3: n_state = ROW2_4;
		ROW2_4: n_state = ROW2_5;
		ROW2_5: n_state = ROW2_6;
		ROW2_6: n_state = ROW2_7;
		ROW2_7: n_state = ROW2_8;
		ROW2_8: n_state = ROW2_9;
		ROW2_9: n_state = ROW2_A;
		ROW2_A: n_state = ROW2_B;
		ROW2_B: n_state = ROW2_C;
		ROW2_C: n_state = ROW2_D;
		ROW2_D: n_state = ROW2_E;
		ROW2_E: n_state = ROW2_F;		
		ROW2_F: n_state = SHOW_END;		
		default: n_state = SHOW_END;
	endcase
end

/*******************************************************************/
assign lcd_rw = 0;
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		lcd_rs <= 0;
	end
	else if(write_flag == 1) begin
		if((n_state == SET_FUNCTION) || (n_state == DISP_OFF)||
			(n_state == DISP_CLEAR) || (n_state == ENTRY_MODE) ||
			(n_state == DISP_ON) || (n_state ==ROW1_ADDR) ||
			(n_state == ROW2_ADDR)) begin
			lcd_rs <= 0;
		end
		else if(start_flag) begin
			lcd_rs <= 0;
		end
		else begin
			lcd_rs <= 1;
		end
	end
	else begin
		lcd_rs <= lcd_rs;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		lcd_data <= 0;	
	end
	else if(write_flag) begin
		if(start_flag) begin
			lcd_data <= 8'h80;
		end
		else begin
			case(n_state)
				IDLE: lcd_data <= 8'hxx;
				SET_FUNCTION: lcd_data <= 8'h38;  //2*16  5*8 8
				DISP_OFF: lcd_data <= 8'h08;
				DISP_CLEAR: lcd_data <= 8'h01;
				ENTRY_MODE: lcd_data <= 8'h06;
				DISP_ON: lcd_data <= 8'h0c;
				ROW1_ADDR: lcd_data <= 8'h80; //00+80
				ROW1_0: lcd_data <= ROW_1 [127:120];
				ROW1_1: lcd_data <= ROW_1 [119:112];
				ROW1_2: lcd_data <= ROW_1 [111:104];
				ROW1_3: lcd_data <= ROW_1 [103:96];
				ROW1_4: lcd_data <= ROW_1 [95:88];
				ROW1_5: lcd_data <= ROW_1 [87:80];
				ROW1_6: lcd_data <= ROW_1 [79:72];
				ROW1_7: lcd_data <= ROW_1 [71:64];
				ROW1_8: lcd_data <= ROW_1 [63:56];
				ROW1_9: lcd_data <= ROW_1 [55:48];
				ROW1_A: lcd_data <= ROW_1 [47:40];
				ROW1_B: lcd_data <= ROW_1 [39:32];
				ROW1_C: lcd_data <= ROW_1 [31:24];
				ROW1_D: lcd_data <= ROW_1 [23:16];
				ROW1_E: lcd_data <= ROW_1 [15:8];
				ROW1_F: lcd_data <= ROW_1 [7:0];
				
				ROW2_ADDR: lcd_data <= 8'hc0;     //40+80
				ROW2_0: lcd_data <= ROW_2 [127:120];
				ROW2_1: lcd_data <= ROW_2 [119:112];
				ROW2_2: lcd_data <= ROW_2 [111:104];
				ROW2_3: lcd_data <= ROW_2 [103:96];
				ROW2_4: lcd_data <= ROW_2 [95:88];
				ROW2_5: lcd_data <= ROW_2 [87:80];
				ROW2_6: lcd_data <= ROW_2 [79:72];
				ROW2_7: lcd_data <= ROW_2 [71:64];
				ROW2_8: lcd_data <= ROW_2 [63:56];
				ROW2_9: lcd_data <= ROW_2 [55:48];
				ROW2_A: lcd_data <= ROW_2 [47:40];
				ROW2_B: lcd_data <= ROW_2 [39:32];
				ROW2_C: lcd_data <= ROW_2 [31:24];
				ROW2_D: lcd_data <= ROW_2 [23:16];
				ROW2_E: lcd_data <= ROW_2 [15:8];
				ROW2_F: lcd_data <= ROW_2 [7:0];
			endcase
		end
	end
	else begin
		lcd_data <= lcd_data;
	end
end

endmodule