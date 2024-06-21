module keyboard(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [3:0] col,
    input wire ack,
    
    output reg [3:0] row,
//    output reg [3:0] char
    
    output reg [13:0] temp_data
);

    reg       delay;    //�����µ�ʱ��rowֹͣɨ��
    reg [3:0] char;
    reg [13:0] temp;
    reg [24:0] cnt;
    reg [24:0] debounce_cnt;
    reg key_pressed;
    reg key_released;
    reg [1:0] state;        //״̬
    reg [24:0] ack_debounce_cnt;

    parameter row_scan_period = 25'd2_000_000;  // 20msɨ��һ��
    parameter debounce_period = 26'd2_000_000;   // 20msȥ����ʱ��
    parameter ack_debounce_period = 26'd2_000_000;   // 20msȥ����ʱ��
    
//    //����ʱ��
//    parameter row_scan_period_t = 26'd10;       // 100nsɨ��һ��
//    parameter debounce_period_t = 26'd10;       // 200nsȥ����ʱ��
    
    parameter first_row  = 4'b1110;
    parameter second_row = 4'b1101;
    parameter third_row  = 4'b1011;
    parameter fourth_row = 4'b0111;
    parameter first_col  = 4'b1110;
    parameter second_col = 4'b1101;
    parameter third_col  = 4'b1011;
    parameter fourth_col = 4'b0111;

    parameter IDLE = 2'b00;
    parameter PRESSED = 2'b01;
    parameter RELEASED = 2'b10;

    

    // ��ɨ�����
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            row <= first_row;
            cnt <= 0;
            
        end
       else if(delay == 1) begin   //����ɨ�赽�������µ�ʱ��ֹͣ��ɨ��,�̶�Ϊ����
            row <= row;
            //cnt <= 0;              //�������а���ʱ����cnt��Ϊ0������ɨ��������¼�ʱ��ֱ�������ɿ���Ȼ�����ɨ��
        end
        else begin
               if (cnt == row_scan_period) begin
                    row <= {row[2:0], row[3]};
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1'd1;
                end
        end
       
    end

    // ȥ������������״̬��
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debounce_cnt <= 0;
            key_pressed <= 0;
            key_released <= 1;
            state <= IDLE;
            delay <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (col != 4'b1111) begin
                        delay <= 1;
                        if (debounce_cnt == debounce_period) begin      //����Ҳͬʱ���ͷŵĶ����������ˡ�
                            key_pressed <= 1;                           //�ͷź���һ��ʱ�Ӿͻḳֵ�������ʱ���������뾭������ʱ����ܣ����밴��״̬
                            key_released <= 0;  
                            state <= PRESSED;
                        end else begin
                            debounce_cnt <= debounce_cnt + 1'b1;
                        end
                    end else begin
                        debounce_cnt <= 0;
                        key_pressed <= 0;
                        key_released <= 1;
                        delay <= 0;
                    end
                end
                PRESSED: begin
                    if (col == 4'b1111) begin
                        state <= RELEASED;
                    end
                end
                RELEASED: begin
                    key_pressed <= 0;
                    key_released <= 1;
                    delay <= 0;
                    debounce_cnt <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

    // ���������߼�
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            char <= 4'd0;
            temp <= 15'd0;
            temp_data <= 15'd0;
        end
        
        else if(ack == 1)begin      //ȷ���ź�ack��Ч����������Ϊ0
            if(ack_debounce_cnt == debounce_period)begin    //��������
                temp_data <= 14'd0;
                temp <= 14'd0;
                ack_debounce_cnt <= 0;
                char <= 4'd0;
             end else begin
                ack_debounce_cnt <= ack_debounce_cnt + 1;
             end
         end
                            
        else if (state == PRESSED && key_pressed && !key_released) begin
            case (row)
                first_row: begin
                    case (col)
                        first_col  : char <= 4'd1;
                        second_col : char <= 4'd2;
                        third_col  : char <= 4'd3;
                        fourth_col : char <= 4'd0; // ���ܼ�ֵ��Ϊ0
                    endcase
                end
                second_row: begin
                    case (col)
                        first_col  : char <= 4'd4;
                        second_col : char <= 4'd5;
                        third_col  : char <= 4'd6;
                        fourth_col : char <= 4'd0; // ���ܼ�ֵ��Ϊ0
                    endcase
                end
                third_row: begin
                    case (col)
                        first_col  : char <= 4'd7;
                        second_col : char <= 4'd8;
                        third_col  : char <= 4'd9;
                        fourth_col : char <= 4'd0; // ���ܼ�ֵ��Ϊ0
                    endcase
                end
                fourth_row: begin
                    case (col)
                        first_col  : char <= 4'd0; // ���ܼ�ֵ��Ϊ0
                        second_col : char <= 4'd0;
                        third_col  : char <= 4'd0;
                        fourth_col : char <= 4'd0;
                    endcase
                end
            endcase
 //         end
        end else if (state == RELEASED) begin
                if(temp <= 14'd999) begin
                    temp <= (temp * 10) + char;
                    temp_data <= (temp * 10) + char;
                    char <= 4'd0;
                 end else begin
                    temp <= 14'd0;
                    temp_data <= 14'd0;
                    char <= 4'd0;
                end
        end 
    end

endmodule