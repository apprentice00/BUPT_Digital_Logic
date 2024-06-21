`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/17 15:52:25
// Design Name: 
// Module Name: Top
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


module Top(
input                  sys_clk         , 
input                  sys_rst_n       ,
input                  start           ,     //��ʼ�źţ���ʼ�����������ݿ���
input                  pil_mode        ,     //����ģʽ
input                  ack             ,     //����ȷ���źţ�����ȷ�����á���Ť
input                  display_mode    ,     //��ʾģʽ�����ݿ���

input      wire[3:0]   col            , 
output     wire[3:0]   row            ,
 
output     wire        l_qw           ,      //���ڹ���������ܿ�������ܵĿ��أ�ǧλ����
output     wire        l_bw           ,      //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     wire        l_sw           ,      //���ڹ���������ܿ�������ܵĿ��أ�ʮλ��
output     wire        l_gw           ,      //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     wire        h_qw           ,      //���ڹ���������ܿ�������ܵĿ��أ�ǧλ����
output     wire        h_bw           ,      //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     wire        h_sw           ,      //���ڹ���������ܿ�������ܵĿ��أ�ʮλ��
output     wire        h_gw           ,      //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     wire[7:0]   smg            ,

output     wire        red            ,      //���,ֹͣ�ź�
output     wire[7:0]   green          ,      //�̵ƣ���������
output     wire[1:0]   yellow                //�Ƶƣ������ź�

    );
    
wire       [13:0]   temp_data         ;      //�Ӽ����õ�������

wire       [13:0]   max_bot_num       ;      //�������ƿ�������ĸ������
wire       [13:0]   max_sgl_bot       ;      //���õ�ƿ��ҩƷ����
wire       [13:0]   now_bot_bil_num   ;      //��ǰҩƿ�е�ҩƬ������
wire       [13:0]   bot_finished      ;      //�Ѿ����װƬ��ҩƿ����     
   
wire       [31:0]   data              ;      //���������ܵ�����

wire                finish            ;      //��ɹ���
wire                stop              ;      //�쳣ֹͣ
wire                work_mode         ;      //����ģʽ
wire       [1:0]    finish_set        ;      //�Ѿ����õ�����


///*
// ʵ����������̡���Ŀ�ˣ����ڳɹ���
//*/
keyboard keyboard_inst(
.sys_clk             (sys_clk  )       ,
.sys_rst_n           (sys_rst_n)       ,
.col                 (col      )       ,
.ack                 (ack      )       ,
                             
.row                 (row      )       ,
.temp_data           (temp_data)      
);

/*
ʵ�����������ϰ���Գɹ�
*/ 
main main_inst(
.sys_clk             (sys_clk  )       ,
.sys_rst_n           (sys_rst_n)       ,
.start               (start    )       ,
.pil_mode            (pil_mode )       ,
.ack                 (ack      )       ,

.temp_data           (temp_data)       ,

.finish              (finish      )     ,
.stop                (stop    )         ,
.work_mode           (work_mode   )     ,
.finish_set          (finish_set  )     ,

//tt
//.state                (state    )         ,

.max_bot_num         (max_bot_num)     ,
.max_sgl_bot         (max_sgl_bot)     ,
.now_bot_bil_num     (now_bot_bil_num) ,
.bot_finished        (bot_finished)       
);

/*
 ʵ��������ܣ��ϰ���Գɹ�
*/
nixie_tube nixie_tube_inst
(
.     clk                    (sys_clk         ),
.     rst_n                  (sys_rst_n       ),
.     data                   (data            ),
 
.     l_qw                   (l_qw            ),
.     l_bw                   (l_bw            ),
.     l_sw                   (l_sw            ),
.     l_gw                   (l_gw            ),
.     h_qw                   (h_qw            ),
.     h_bw                   (h_bw            ),
.     h_sw                   (h_sw            ),
.     h_gw                   (h_gw            ),
.     smg                    (smg             )
);


/*
 ʵ�����������ת��, �ϰ���Գɹ�
*/
data_transform data_transform_inst
(
.     sys_clk                (sys_clk         ),
.     sys_rst_n              (sys_rst_n       ),
.     display_mode           (display_mode    ),
.     work_mode              (work_mode       ),
 
.     temp_data              (temp_data       ),

.     max_bot_num             (max_bot_num    ),
.     max_sgl_bot             (max_sgl_bot    ),
.     now_bot_bil_num         (now_bot_bil_num),
.     bot_finished            (bot_finished   ),

.     data                    (data           )
); 

/*
 ʵ�����ƿ��ƣ��ϰ���Գɹ�
*/
light_control light_control_inst
(
.     sys_clk                (sys_clk         ),
.     sys_rst_n              (sys_rst_n       ),

.     finish                 (finish          ),
.     stop                   (stop          ),
.     start                  (start          ),
.     work_mode              (work_mode    ),
.     finish_set          (finish_set  )     ,

.     red                    (red),
.     green                  (green   ),
.     yellow                  (yellow  )
);      
endmodule
