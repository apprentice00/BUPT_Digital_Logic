`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/31 08:35:30
// Design Name: 
// Module Name: data_transform
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


module data_transform(
input                  sys_clk         , 
input                  sys_rst_n       ,
input                  display_mode    ,     //��ʾģʽ
input                  work_mode       ,     //����ģʽ

input     wire[13:0]   temp_data      ,     //�Ӽ����õ�������

input     wire[13:0]   max_bot_num    ,     //�������ƿ�������ĸ������
input     wire[13:0]   max_sgl_bot    ,     //���õ�ƿ��ҩƷ����
input     wire[13:0]   now_bot_bil_num,     //��ǰҩƿ�е�ҩƬ������
input     wire[13:0]   bot_finished   ,     //�Ѿ����װƬ��ҩƿ����

output    reg [31:0]   data                 //���͵�������ϵ�����

    );
    
parameter   work_dis = 1'b1          ;      //��ʾ��װҩƷƿ���͵�ǰҩƿ�е�ҩƬ����
parameter   set_dis = 1'b0           ;      //��ʾ���õ�ҩƷƿ���͵�ƿҩƿ�е�ҩƬ����

parameter   setting = 1'b0           ;      // ���ý׶�
parameter   working = 1'b1           ;      // �����׶�

//reg [13:0]   max_bot_num    ;     //�������ƿ�������ĸ������
//reg [13:0]   max_sgl_bot    ;    //�������ƿ�������ĸ������
//reg [13:0]   now_bot_bil_num   ;     //�������ƿ�������ĸ������
//reg [13:0]   bot_finished    ;    //�������ƿ�������ĸ������

/*
����
 */
//always @ (posedge sys_clk or negedge sys_rst_n) begin
//   if(!sys_rst_n) begin
//		max_bot_num <= 14'd0;
//		max_sgl_bot <= 14'd0;
//		now_bot_bil_num <= 14'd0;
//		bot_finished <= 14'd0;
//    end
//	else if(cnt == 26'd50000000) begin
//	   if(max_bot_num < 14'd9999) 
//		   max_bot_num <= max_bot_num +1'd1;
//      else
//         max_bot_num <= 14'd0;
         
//	   if(max_sgl_bot < 14'd9999) 
//             max_sgl_bot <= max_sgl_bot +1'd1;
//        else
//           max_sgl_bot <= 14'd0;
           
//	   if(now_bot_bil_num < 14'd9999) 
//                 now_bot_bil_num <= now_bot_bil_num +1'd1;
//            else
//               now_bot_bil_num <= 14'd0;
               
//	   if(bot_finished < 14'd9999) 
//                     bot_finished <= bot_finished +1'd1;
//                else
//                   bot_finished <= 14'd0;           
//	end
 
//end


always @ (posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            data <= 32'd0;
        end
        else if(work_mode == setting) begin
            data <= temp_data;
        end
        else if(work_mode == working) begin
            if(display_mode == set_dis) begin
                    data <= max_bot_num * 10000 + max_sgl_bot;
                end
                else if(display_mode == work_dis)  begin
                    data <= bot_finished * 10000 + now_bot_bil_num;
                end
        end
end

endmodule
