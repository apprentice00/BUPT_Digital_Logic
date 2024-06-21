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
    input                  sys_clk,          // ϵͳʱ��
    input                  sys_rst_n,        // ϵͳ��λ���͵�ƽ��Ч
    
    input                  start,            // ��ʼ�źţ���ʼ�����������ݿ���
    input                  pil_mode,         // ����ģʽ
    input                  ack,              // ����ȷ���źţ�����ȷ�����á���Ť
    
    input      [13:0]      temp_data,        // �Ӽ����õ�������


    output reg [13:0]      max_bot_num,      // �������ƿ�������ĸ������
    output reg [13:0]      max_sgl_bot,      // ���õ�ƿ��ҩƷ����
    output reg [13:0]      now_bot_bil_num,  // ��ǰҩƿ�е�ҩƬ������
    output reg [13:0]      bot_finished,     // �Ѿ����װƬ��ҩƿ����
    
    output reg             finish,           //��ɹ���
    output reg             stop,             //�쳣ֹͣ
    output reg             work_mode,       //����ģʽ
    output reg [1:0]       finish_set       // ������ã�0�����ã�1�������ƿ����2���õ�ƿ��ҩƷ����
);

parameter ordinary      = 1'b0;       // ��ͨ����ģʽ
parameter customization = 1'b1;       // ���ƻ�����ģʽ
parameter setting       = 1'b0;       // ���ý׶�
parameter working       = 1'b1;       // �����׶�

//����չʾ
parameter max_bot       = 14'd999;   // ��ǰ���õ����ƿ��
parameter max_pil       = 14'd999;   // ��ǰ���õĵ�ƿ���ҩƬ��

reg [25:0] ack_debounce_cnt;
parameter debounce_period = 26'd2_000_000;   // 20msȥ����ʱ��


//test
//parameter max_bot_num_t       = 14'd500;   // ��ǰ���õ����ƿ��
//parameter max_sgl_bot_t       = 14'd100;   // ��ǰ���õĵ�ƿ���ҩƬ��


reg finish_bot;                       // ��ƿװ�꣬����ģʽ���������������ֵ


reg [26:0] cnt;                       // ������


reg [1:0] state;        //״̬

parameter IDLE = 2'b00;
parameter PRESSED = 2'b01;
parameter RELEASED = 2'b11;

// ���߼�
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
    end else if(work_mode == setting && finish_set != 2'd2 && state == PRESSED ) begin     //ȷ���źţ��趨ֵ
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
        finish_set <= 2'd1;     //ֻ����ÿƿ�е�ҩƿ����
        now_bot_bil_num <= 14'd0;
        //max_bot_num <= 14'd0;
        max_sgl_bot <= 14'd0;
        finish_bot <= 1'b0;
    end 
    else if (finish_set == 2'd2 && work_mode == setting) begin      //����Ƿ����Ҫ��
        if (max_bot_num <= max_bot && max_sgl_bot <= max_pil) begin
            work_mode <= working;
        end else begin
            stop = 1'b1;    //����ֹͣ�����
        end
    end
     else if (start == 1'b1 && work_mode == working && stop == 1'b0 && finish == 1'b0) begin
        if (now_bot_bil_num < 14'd0 || now_bot_bil_num > max_sgl_bot || bot_finished < 14'd0 || bot_finished > max_bot) begin
            stop <= 1'b1;   //ϵͳ�쳣����ֹͣ�����
        end else if (bot_finished == max_bot_num) begin
              finish <= 1'b1;   //�������
        end else if (now_bot_bil_num == max_sgl_bot) begin      //���һ��װƬ
            now_bot_bil_num <= 14'd0;
            bot_finished <= bot_finished + 1'd1;
            if (pil_mode == customization) begin
                work_mode <= setting;
                finish_bot <= 1'b1;
            end
        end else begin
            if (cnt == 27'd100_000_000) begin       //����һƬװƿ�Ƿ��е�����1���
                cnt <= 27'd0;
                now_bot_bil_num <= now_bot_bil_num + 1'd1;
            end else begin
                cnt <= cnt + 1'd1;
            end
        end
    end
end


// ack״̬��������¼һ��ʱ�ӵ�ack��Ч�ź�
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ack_debounce_cnt <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin     //��Ϊ����״̬��ʱ��ֻҪackΪ1���ͽ�������
                   if(ack == 1)begin
                      state <= PRESSED;
                   end
                end
                PRESSED: begin          //��һ��ʱ�ӣ�����RELEASED״̬
                    state <= RELEASED;
                end
                RELEASED: begin     //�ͷ�״̬�������������״̬
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
