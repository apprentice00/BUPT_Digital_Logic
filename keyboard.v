module keyboard(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [3:0] col,
    input wire ack,
    
    output reg [3:0] row,
//    output reg [3:0] char
    
    output reg [13:0] temp_data
);

    reg       delay;    //当按下的时候，row停止扫描
    reg [3:0] char;
    reg [13:0] temp;
    reg [24:0] cnt;
    reg [24:0] debounce_cnt;
    reg key_pressed;
    reg key_released;
    reg [1:0] state;        //状态
    reg [24:0] ack_debounce_cnt;

    parameter row_scan_period = 25'd2_000_000;  // 20ms扫描一次
    parameter debounce_period = 26'd2_000_000;   // 20ms去抖动时间
    parameter ack_debounce_period = 26'd2_000_000;   // 20ms去抖动时间
    
//    //激励时间
//    parameter row_scan_period_t = 26'd10;       // 100ns扫描一次
//    parameter debounce_period_t = 26'd10;       // 200ns去抖动时间
    
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

    

    // 行扫描控制
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            row <= first_row;
            cnt <= 0;
            
        end
       else if(delay == 1) begin   //当列扫描到按键按下的时候，停止行扫描,固定为该行
            row <= row;
            //cnt <= 0;              //当按键有按下时，将cnt置为0，即将扫描的行重新计时，直至按键松开，然后继续扫描
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

    // 去抖动计数器和状态机
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
                        if (debounce_cnt == debounce_period) begin      //好像也同时把释放的抖动给消除了。
                            key_pressed <= 1;                           //释放后下一个时钟就会赋值。如果此时抖动，必须经历消抖时间才能，进入按下状态
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

    // 按键处理逻辑
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            char <= 4'd0;
            temp <= 15'd0;
            temp_data <= 15'd0;
        end
        
        else if(ack == 1)begin      //确认信号ack有效，将数据置为0
            if(ack_debounce_cnt == debounce_period)begin    //按键消抖
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
                        fourth_col : char <= 4'd0; // 功能键值设为0
                    endcase
                end
                second_row: begin
                    case (col)
                        first_col  : char <= 4'd4;
                        second_col : char <= 4'd5;
                        third_col  : char <= 4'd6;
                        fourth_col : char <= 4'd0; // 功能键值设为0
                    endcase
                end
                third_row: begin
                    case (col)
                        first_col  : char <= 4'd7;
                        second_col : char <= 4'd8;
                        third_col  : char <= 4'd9;
                        fourth_col : char <= 4'd0; // 功能键值设为0
                    endcase
                end
                fourth_row: begin
                    case (col)
                        first_col  : char <= 4'd0; // 功能键值设为0
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