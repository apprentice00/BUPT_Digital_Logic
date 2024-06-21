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
input                  start           ,     //开始信号，开始工作，用数据开关
input                  pil_mode        ,     //生产模式
input                  ack             ,     //输入确认信号，用于确认设置。按扭
input                  display_mode    ,     //显示模式，数据开关

input      wire[3:0]   col            , 
output     wire[3:0]   row            ,
 
output     wire        l_qw           ,      //用于共阳极数码管控制数码管的开关（千位）右
output     wire        l_bw           ,      //用于共阳极数码管控制数码管的开关（百位）
output     wire        l_sw           ,      //用于共阳极数码管控制数码管的开关（十位）
output     wire        l_gw           ,      //用于共阳极数码管控制数码管的开关（个位）
output     wire        h_qw           ,      //用于共阳极数码管控制数码管的开关（千位）左
output     wire        h_bw           ,      //用于共阳极数码管控制数码管的开关（百位）
output     wire        h_sw           ,      //用于共阳极数码管控制数码管的开关（十位）
output     wire        h_gw           ,      //用于共阳极数码管控制数码管的开关（个位）
output     wire[7:0]   smg            ,

output     wire        red            ,      //红灯,停止信号
output     wire[7:0]   green          ,      //绿灯，常亮工作
output     wire[1:0]   yellow                //黄灯，错误信号

    );
    
wire       [13:0]   temp_data         ;      //从键盘拿到的数据

wire       [13:0]   max_bot_num       ;      //设置最大瓶数，左四个数码管
wire       [13:0]   max_sgl_bot       ;      //设置单瓶中药品数量
wire       [13:0]   now_bot_bil_num   ;      //当前药瓶中的药片的数量
wire       [13:0]   bot_finished      ;      //已经完成装片的药瓶数量     
   
wire       [31:0]   data              ;      //输出到数码管的数据

wire                finish            ;      //完成工作
wire                stop              ;      //异常停止
wire                work_mode         ;      //工作模式
wire       [1:0]    finish_set        ;      //已经设置的数量


///*
// 实例化矩阵键盘。泪目了，终于成功了
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
实例化主程序，上板测试成功
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
 实例化数码管，上板测试成功
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
 实例化输出数据转换, 上板测试成功
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
 实例化灯控制，上板测试成功
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
