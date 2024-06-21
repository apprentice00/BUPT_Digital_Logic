/*
数码管显示模块，将输入的数据data显示到8个数码管上
输入：data = h_data * 10000 + l_data
输出：h_data(左四个管），l_data(右四个管）
*/
module nixie_tube(
input      wire           clk,
input      wire           rst_n,
input      wire[31:0]     data,    //外面给的数据

output     reg            l_qw,    //用于共阳极数码管控制数码管的开关（千位）
output     reg            l_bw,    //用于共阳极数码管控制数码管的开关（百位）
output     reg            l_sw,    //用于共阳极数码管控制数码管的开关（十位）
output     reg            l_gw,    //用于共阳极数码管控制数码管的开关（个位）
output     reg            h_qw,    //用于共阳极数码管控制数码管的开关（千位）左
output     reg            h_bw,    //用于共阳极数码管控制数码管的开关（百位）
output     reg            h_sw,    //用于共阳极数码管控制数码管的开关（十位）
output     reg            h_gw,    //用于共阳极数码管控制数码管的开关（个位）
output     reg [7:0]      smg      //映射到真实引脚中
    );

parameter   show_zero   = 8'b11000000;
parameter   show_one    = 8'b11111001;
parameter   show_two    = 8'b10100100;
parameter   show_three  = 8'b10110000;
parameter   show_four   = 8'b10011001;
parameter   show_five   = 8'b10010010;
parameter   show_six    = 8'b10000010;
parameter   show_seven  = 8'b11111000;
parameter   show_eight  = 8'b10000000;
parameter   show_nine   = 8'b10010000;

reg [25:0] cnt;
reg [13:0] counter;     //数码管计数值
reg [3:0]  h_qw_value;    //数码千管位的值，左
reg [3:0]  h_bw_value;    //数码管百位的值
reg [3:0]  h_sw_value;    //数码管十位的值
reg [3:0]  h_gw_value;    //数码管个位的值
reg [3:0]  l_qw_value;    //数码管千位的值，右
reg [3:0]  l_bw_value;    //数码管百位的值
reg [3:0]  l_sw_value;    //数码管十位的值
reg [3:0]  l_gw_value;    //数码管个位的值
reg [2:0]  scan_ws;     //数码管扫描位数序列号(左0 个位 1 百位 2 十位 3 千位)(右4 个位 5 百位 6 十位 7 千位)
reg [3:0]  scan_value;  //单个位扫描值

/*
 *计数器（时基10ns 100MHz）
 */
always @ (posedge clk or negedge rst_n) begin
   if(!rst_n)
	   cnt <= 26'd0;
	else begin
	   if(cnt < 26'd50000000)
		   cnt <= cnt + 1'b1;
		else
		   cnt <= 26'd0;
	end
	
end
/*
测试
 */
//always @ (posedge clk or negedge rst_n) begin
//   if(!rst_n) 
//		counter <= 14'd0;
   
//	else if(cnt == 26'd50000000) begin
//	   if(counter < 14'd9999) 
//		   counter <= counter +1'b1;
//      else
//         counter <= 14'd0;
//	end
 
//end
		
 
/*
 *选择打开的数码管
 */
always @ (posedge clk or negedge rst_n) begin
   if(!rst_n) begin
		  l_qw <= 1'b1;
		  l_bw <= 1'b1;
		  l_sw <= 1'b1;
		  l_gw <= 1'b1;
		  h_qw <= 1'b1;
          h_bw <= 1'b1;
          h_sw <= 1'b1;
          h_gw <= 1'b1;
	     scan_value <= 4'd0;
   end
   else if(!(cnt % 26'd180000)) begin      //4ms 
        l_qw <= 1'b1; //全关（因为程序执行中会打开部分数码管，每次单位数码管扫描前先关闭所有数码管）
        l_bw <= 1'b1;
        l_sw <= 1'b1;
        l_gw <= 1'b1;
        h_qw <= 1'b1;
        h_bw <= 1'b1;
        h_sw <= 1'b1;
        h_gw <= 1'b1;
		  case(scan_ws)                     //决定打开哪个数码管
		     3'b000  : begin          //右
			  scan_value <= l_gw_value;
              l_gw <= 1'b0;			   
			  end                                     
			  3'b001  : begin                         
			  scan_value <= l_sw_value;                 
			  l_sw <= 1'b0;
			  end
			  3'b010  : begin
			  scan_value <= l_bw_value;
			  l_bw <= 1'b0;
			  end
			  3'b011  : begin
			  scan_value <= l_qw_value;
			  l_qw <= 1'b0;
			  end
		      3'b100  : begin
               scan_value <= h_gw_value;
               h_gw <= 1'b0;               
               end                                     
               3'b101  : begin                         
               scan_value <= h_sw_value;                 
               h_sw <= 1'b0;
               end
               3'b110  : begin
               scan_value <= h_bw_value;
               h_bw <= 1'b0;
               end
               3'b111  : begin
               scan_value <= h_qw_value;
               h_qw <= 1'b0;
               end			  
			  default : ;
		  endcase
	end 
end
 
/*
 *向数码管写入数据
 */
always @ (posedge clk or negedge rst_n) begin
   if(!rst_n) begin
	   smg <= show_zero;
	end
   else begin
	    case(scan_value)            
          4'd0 : smg <= show_zero;
          4'd1 : smg <= show_one;
          4'd2 : smg <= show_two;
          4'd3 : smg <= show_three;
          4'd4 : smg <= show_four;
          4'd5 : smg <= show_five;
          4'd6 : smg <= show_six;
          4'd7 : smg <= show_seven;
          4'd8 : smg <= show_eight; 
          4'd9 : smg <= show_nine;  
          default : ;
		 endcase 
	end
end	
	
 
/*
 *扫描位号赋值
 */
always @ (posedge clk or negedge rst_n) begin
       if(!rst_n)
            scan_ws <= 3'b000;
        else if(!(cnt % 26'd180000)) begin         //到达刷新时间
        if(scan_ws == 3'b111)
            scan_ws <= 3'b000;
        else
            scan_ws <= 3'b001 + scan_ws;
        end
        else
            scan_ws <= scan_ws ;
end

/*
 *向扫描值千百十个位赋值
 */
always @ (posedge clk or negedge rst_n) begin
       if(!rst_n) begin
			h_qw_value <= 4'd0;
			h_bw_value <= 4'd0;
			h_sw_value <= 4'd0;
			h_gw_value <= 4'd0;
			l_qw_value <= 4'd0;
            l_bw_value <= 4'd0;
            l_sw_value <= 4'd0;
            l_gw_value <= 4'd0;
		 end
		 else
            h_qw_value <= data/29'd10000000;
            h_bw_value <= data/25'd1000000%4'd10;
            h_sw_value <= data/20'd100000%4'd10;
            h_gw_value <= data/18'd10000%4'd10;
            l_qw_value <= data/15'd1000%4'd10;
            l_bw_value <= data/12'd100%4'd10;
            l_sw_value <= data/8'd10%4'd10;
            l_gw_value <= data%4'd10;
            
//            h_qw_value <= counter/29'd10000000;
//            h_bw_value <= counter/25'd1000000%4'd10;
//            h_sw_value <= counter/20'd100000%4'd10;
//            h_gw_value <= counter/18'd10000%4'd10;
//            l_qw_value <= counter/15'd1000%4'd10;
//            l_bw_value <= counter/12'd100%4'd10;
//            l_sw_value <= counter/8'd10%4'd10;
//            l_gw_value <= counter%4'd10;
end	
endmodule
