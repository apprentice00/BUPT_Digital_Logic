`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/02 09:57:30
// Design Name: 
// Module Name: light_control
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


module light_control(
input                  sys_clk         , 
input                  sys_rst_n       ,

input                  finish          ,      //完成工作
input                  stop            ,      //异常停止
input                  work_mode       ,      //工作模式
input                  start           ,
input       wire[1:0] finish_set       ,

output      reg         red            ,      //红灯,停止信号
output      reg[7:0]    green          ,      //绿灯，流水灯工作状态。常量一次工作完成
output      reg[1:0]    yellow                //黄灯，设置状态
    );

parameter setting       = 1'b0;       // 设置阶段
parameter working       = 1'b1;       // 工作阶段

parameter green_0       =8'b00000000;
parameter green_1       =8'b00000001;
parameter green_2       =8'b00000010;
parameter green_3       =8'b00000100;
parameter green_4       =8'b00001000;
parameter green_5       =8'b00010000;
parameter green_6       =8'b00100000;
parameter green_7       =8'b01000000;
parameter green_8       =8'b10000000;
parameter green_all     =8'b11111111;


reg     [3:0]   cnt;
reg     [25:0]  cnt_1;
    
always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0) begin
            green <= green_0;
            red <= 1'b0;
            yellow <= 2'b00; 
            cnt <= 4'd0;
        end
        else if(stop == 1'b1) begin     //异常停止
             green <= green_0;
             red <= 1'b1;
             yellow <= 2'b00;
             cnt <= 4'd0; 
        end
        else if(finish == 1'b1) begin    //工作完成
              green <= green_all;
              red <= 1'b0;
              yellow <= 2'b00;
              cnt <= 4'd0; 
        end
        else if(work_mode == setting) begin   //设置阶段
              green <= green_0;
              red <= 1'b0;
              cnt <= 4'd0;
              case(finish_set) 
                2'd0 : begin
                    yellow <= 2'b11;
                end
                2'd1: begin
                    yellow <= 2'b01;
                end
                2'd2: begin
                    yellow <= 2'b00;
                end
              endcase              
        end
        else if(work_mode == working && start == 1) begin  //工作阶段
               red <= 1'b0;   
               yellow <= 2'b00;
               if(cnt_1 == 26'd50_000_000) begin    //0.5s
                   case(cnt)
                    4'd0 : begin
                        cnt <= cnt + 1'd1;
                        green <= green_0;
                    end
                    4'd1 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_1;
                    end
                    4'd2 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_2;
                    end
                    4'd3 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_3;
                    end
                    4'd4 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_4;
                    end
                    4'd5 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_5;
                    end
                    4'd6 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_6;
                    end
                    4'd7 : begin
                         cnt <= cnt + 1'd1;
                         green <= green_7;
                    end
                    4'd8 : begin
                         cnt <= 4'd0;
                         green <= green_8;
                    end
                    default : ;
                   endcase                              
               end
        end
end

/*
 *计数器（时基10ns 100MHz）,用于流水灯
 */
always @ (posedge sys_clk or negedge sys_rst_n) begin
   if(!sys_rst_n)
	   cnt_1 <= 26'd0;
	else begin
	   if(cnt_1 < 26'd50000000)
		   cnt_1 <= cnt_1 + 1'b1;
		else
		   cnt_1 <= 26'd0;
	end
	
end

endmodule
