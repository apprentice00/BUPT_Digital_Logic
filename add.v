`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/04 20:15:19
// Design Name: 
// Module Name: add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add(
input                  sys_clk         , 
input                  sys_rst_n       ,

output  reg[13:0]      counter
);

reg [25:0] cnt;
/*
 *计数器（时基20ns 50MHz）
 */
always @ (posedge sys_clk or negedge sys_rst_n) begin
   if(!sys_rst_n)
	   cnt <= 26'd0;
	else begin
	   if(cnt < 26'd50000000)
		   cnt <= cnt + 1'b1;
		else
		   cnt <= 26'd0;
	end
	
end
/*
 *定时器(1s)，用于数码管显示
 */
always @ (posedge sys_clk or negedge sys_rst_n) begin
   if(!sys_clk) 
		counter <= 14'd0;
   
	else if(cnt == 26'd50000000) begin
	   if(counter < 14'd9999) 
		   counter <= counter +1'b1;
      else
         counter <= 14'd0;
	end
 end
 
endmodule
