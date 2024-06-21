/*
�������ʾģ�飬�����������data��ʾ��8���������
���룺data = h_data * 10000 + l_data
�����h_data(���ĸ��ܣ���l_data(���ĸ��ܣ�
*/
module nixie_tube(
input      wire           clk,
input      wire           rst_n,
input      wire[31:0]     data,    //�����������

output     reg            l_qw,    //���ڹ���������ܿ�������ܵĿ��أ�ǧλ��
output     reg            l_bw,    //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     reg            l_sw,    //���ڹ���������ܿ�������ܵĿ��أ�ʮλ��
output     reg            l_gw,    //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     reg            h_qw,    //���ڹ���������ܿ�������ܵĿ��أ�ǧλ����
output     reg            h_bw,    //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     reg            h_sw,    //���ڹ���������ܿ�������ܵĿ��أ�ʮλ��
output     reg            h_gw,    //���ڹ���������ܿ�������ܵĿ��أ���λ��
output     reg [7:0]      smg      //ӳ�䵽��ʵ������
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
reg [13:0] counter;     //����ܼ���ֵ
reg [3:0]  h_qw_value;    //����ǧ��λ��ֵ����
reg [3:0]  h_bw_value;    //����ܰ�λ��ֵ
reg [3:0]  h_sw_value;    //�����ʮλ��ֵ
reg [3:0]  h_gw_value;    //����ܸ�λ��ֵ
reg [3:0]  l_qw_value;    //�����ǧλ��ֵ����
reg [3:0]  l_bw_value;    //����ܰ�λ��ֵ
reg [3:0]  l_sw_value;    //�����ʮλ��ֵ
reg [3:0]  l_gw_value;    //����ܸ�λ��ֵ
reg [2:0]  scan_ws;     //�����ɨ��λ�����к�(��0 ��λ 1 ��λ 2 ʮλ 3 ǧλ)(��4 ��λ 5 ��λ 6 ʮλ 7 ǧλ)
reg [3:0]  scan_value;  //����λɨ��ֵ

/*
 *��������ʱ��10ns 100MHz��
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
����
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
 *ѡ��򿪵������
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
        l_qw <= 1'b1; //ȫ�أ���Ϊ����ִ���л�򿪲�������ܣ�ÿ�ε�λ�����ɨ��ǰ�ȹر���������ܣ�
        l_bw <= 1'b1;
        l_sw <= 1'b1;
        l_gw <= 1'b1;
        h_qw <= 1'b1;
        h_bw <= 1'b1;
        h_sw <= 1'b1;
        h_gw <= 1'b1;
		  case(scan_ws)                     //�������ĸ������
		     3'b000  : begin          //��
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
 *�������д������
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
 *ɨ��λ�Ÿ�ֵ
 */
always @ (posedge clk or negedge rst_n) begin
       if(!rst_n)
            scan_ws <= 3'b000;
        else if(!(cnt % 26'd180000)) begin         //����ˢ��ʱ��
        if(scan_ws == 3'b111)
            scan_ws <= 3'b000;
        else
            scan_ws <= 3'b001 + scan_ws;
        end
        else
            scan_ws <= scan_ws ;
end

/*
 *��ɨ��ֵǧ��ʮ��λ��ֵ
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
