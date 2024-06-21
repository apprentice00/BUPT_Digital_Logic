`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/17 15:53:33
// Design Name: 
// Module Name: main
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

module main(
    input                  sys_clk,          // 系统时钟
    input                  sys_rst_n,        // 系统复位，低电平有效
    
    input                  start,            // 开始信号，开始工作，用数据开关
    input                  pil_mode,         // 生产模式
    input                  ack,              // 输入确认信号，用于确认设置。按扭
    
    input      [13:0]      temp_data,        // 从键盘拿到的数据


    output reg [13:0]      max_bot_num,      // 设置最大瓶数，左四个数码管
    output reg [13:0]      max_sgl_bot,      // 设置单瓶中药品数量
    output reg [13:0]      now_bot_bil_num,  // 当前药瓶中的药片的数量
    output reg [13:0]      bot_finished,     // 已经完成装片的药瓶数量
    
    output reg             finish,           //完成工作
    output reg             stop,             //异常停止
    output reg             work_mode,       //工作模式
    output reg [1:0]       finish_set       // 完成设置，0无设置，1设置最大瓶数，2设置单瓶中药品数量
);

parameter ordinary      = 1'b0;       // 普通生产模式
parameter customization = 1'b1;       // 定制化生产模式
parameter setting       = 1'b0;       // 设置阶段
parameter working       = 1'b1;       // 工作阶段

//用于展示
parameter max_bot       = 14'd999;   // 提前设置的最大瓶数
parameter max_pil       = 14'd999;   // 提前设置的单瓶最大药片数

reg [25:0] ack_debounce_cnt;
parameter debounce_period = 26'd2_000_000;   // 20ms去抖动时间


//test
//parameter max_bot_num_t       = 14'd500;   // 提前设置的最大瓶数
//parameter max_sgl_bot_t       = 14'd100;   // 提前设置的单瓶最大药片数


reg finish_bot;                       // 单瓶装完，工作模式二下重新设置最大值


reg [26:0] cnt;                       // 计数器


reg [1:0] state;        //状态

parameter IDLE = 2'b00;
parameter PRESSED = 2'b01;
parameter RELEASED = 2'b11;

// 主逻辑
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0) begin
        
        max_bot_num <= 14'd0;
        max_sgl_bot <= 14'd0;
        //test
//        max_bot_num <= max_bot_num_t;
//        max_sgl_bot <= max_sgl_bot_t;
        
        now_bot_bil_num <= 14'd0;
        bot_finished <= 14'd0;
        work_mode <= setting;
        //test
//        work_mode <= working;
        
        stop <= 1'b0;
        finish_set <= 2'd0;
        cnt <= 27'd0;
        finish <= 1'b0;
    end else if(work_mode == setting && finish_set != 2'd2 && state == PRESSED ) begin     //确认信号，设定值
            if (finish_set == 2'd0) begin
                max_bot_num <= temp_data;
//                max_bot_num <= max_bot_num_t;
                finish_set <= finish_set + 2'd1;
            end else if (finish_set == 2'd1) begin
                max_sgl_bot <= temp_data;
    //            max_sgl_bot <= max_sgl_bot_t;
                finish_set <= finish_set + 2'd1;
            end

    end
    else if (work_mode == setting && pil_mode == customization && finish_bot == 1'b1) begin
        finish_set <= 2'd1;     //只设置每瓶中的药瓶数量
        now_bot_bil_num <= 14'd0;
        //max_bot_num <= 14'd0;
        max_sgl_bot <= 14'd0;
        finish_bot <= 1'b0;
    end 
    else if (finish_set == 2'd2 && work_mode == setting) begin      //检查是否符合要求
        if (max_bot_num <= max_bot && max_sgl_bot <= max_pil) begin
            work_mode <= working;
        end else begin
            stop = 1'b1;    //错误停止，检查
        end
    end
     else if (start == 1'b1 && work_mode == working && stop == 1'b0 && finish == 1'b0) begin
        if (now_bot_bil_num < 14'd0 || now_bot_bil_num > max_sgl_bot || bot_finished < 14'd0 || bot_finished > max_bot) begin
            stop <= 1'b1;   //系统异常错误停止，检查
        end else if (bot_finished == max_bot_num) begin
              finish <= 1'b1;   //工作完成
        end else if (now_bot_bil_num == max_sgl_bot) begin      //完成一次装片
            now_bot_bil_num <= 14'd0;
            bot_finished <= bot_finished + 1'd1;
            if (pil_mode == customization) begin
                work_mode <= setting;
                finish_bot <= 1'b1;
            end
        end else begin
            if (cnt == 27'd100_000_000) begin       //两秒一片装瓶是否有点慢，1秒吧
                cnt <= 27'd0;
                now_bot_bil_num <= now_bot_bil_num + 1'd1;
            end else begin
                cnt <= cnt + 1'd1;
            end
        end
    end
end


// ack状态机。仅记录一个时钟的ack有效信号
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ack_debounce_cnt <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin     //当为空闲状态的时候，只要ack为1，就进行设置
                   if(ack == 1)begin
                      state <= PRESSED;
                   end
                end
                PRESSED: begin          //下一个时钟，进入RELEASED状态
                    state <= RELEASED;
                end
                RELEASED: begin     //释放状态消抖，进入空闲状态
                    if(ack == 0) begin
                        if(ack_debounce_cnt == debounce_period) begin
                            state <= IDLE;
                            ack_debounce_cnt <= 26'd0;
                        end
                        else begin
                            ack_debounce_cnt = ack_debounce_cnt + 26'd1;
                        end
                    end else begin
                        state <= RELEASED;
                        ack_debounce_cnt <= 26'd0;
                    end
                end
            endcase
        end
    end

endmodule
