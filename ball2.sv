module ball
    (input logic clk, rst, finish_frame, origin, serve,
     input logic [9:0] paddle_y1, paddle_y2,
    input logic [1:0] level_state,
     output logic [9:0] ball_x, ball_y, 
     output logic p1_win, p2_win);

    logic right, down;          
    logic right_next, down_next; 
    logic win;
    logic [3:0] x_speed, y_speed;
    
    assign win = p1_win | p2_win;

    always_comb begin
        if (level_state == 2'b00) begin
             x_speed = 4'd2;
             y_speed = 4'd1;
        end
        else if (level_state == 2'b01) begin
             x_speed = 4'd3;
             y_speed = 4'd1;
        end
        else if (level_state == 2'b10) begin
             x_speed = 4'd3;
             y_speed = 4'd2;
        end
        else begin
             x_speed = 4'd4;
             y_speed = 4'd3;
        end
    end

    Counter_any #(.WIDTH(10)) cx(.clk(clk), .en(finish_frame & ~origin & ~win), 
                .clear(1'b0), .load(rst|origin|win), .inc(x_speed),
                .up(right), .D(10'd399), .Q(ball_x));
    Counter_any #(.WIDTH(10)) cy(.clk(clk), .en(finish_frame & ~origin & ~win), 
                .clear(1'b0), .load(rst|origin|win), .inc(y_speed),
                .up(down), .D(10'd299), .Q(ball_y));

    // next dir based on collisions
    Boundary_Y by(.ball_y(ball_y), .down_in(down), .down_out(down_next));

    PaddleHit_And_Win phw(.ball_x(ball_x), .ball_y(ball_y),
                          .paddle_y1(paddle_y1), .paddle_y2(paddle_y2),
                          .right_in(right), .right_out(right_next),
                          .p1_win(p1_win), .p2_win(p2_win));

    // dir & update each frame
    always_ff @(posedge clk) begin
        if (rst) begin
            right <= 1'b1;  
            down <= 1'b1;   
        end
        else if (origin | win) begin
            right <= serve; 
            down <= serve;   
        end
        else if (finish_frame) begin
            right <= right_next;  
            down <= down_next;
        end
    end

endmodule : ball

module PaddleHit_And_Win
    (input logic [9:0] ball_x, ball_y, paddle_y1, paddle_y2,
     input logic right_in,
     output logic right_out, p1_win, p2_win);

    logic hit_x1, hit_y1, hit_x2, hit_y2; 

    //collision with left paddle
    RangeCheck #(.WIDTH(10)) p1_xb(.high(10'd44), .low(10'd38), 
                    .val(ball_x), .is_between(hit_x1));
    RangeCheck #(.WIDTH(10)) p1_yb(.high(paddle_y1 + 10'd47), .low(paddle_y1), 
                .val(ball_y), .is_between(hit_y1));

    //collision with right paddle
    RangeCheck #(.WIDTH(10)) p2_xb(.high(10'd762), .low(10'd756), .val(ball_x), 
                    .is_between(hit_x2));
    RangeCheck #(.WIDTH(10)) p2_yb(.high(paddle_y2 + 10'd47), .low(paddle_y2), 
                    .val(ball_y), .is_between(hit_y2));

    always_comb begin
        right_out = right_in;  
        
        
        if (hit_x1 & hit_y1 & ~right_in)
            right_out = 1'b1;
        
        else if (hit_x2 & hit_y2 & right_in)
            right_out = 1'b0;
    end

    // win conditions
    RangeCheck #(.WIDTH(10)) p2_win_check(.high(10'd3), .low(10'd0), 
                    .val(ball_x), .is_between(p2_win));
    RangeCheck #(.WIDTH(10)) p1_win_check(.high(10'd799), .low(10'd796), 
                    .val(ball_x), .is_between(p1_win));

endmodule : PaddleHit_And_Win

module Boundary_Y
    (input logic [9:0] ball_y,
     input logic down_in,
     output logic down_out);

    logic upperbound_hit, lowerbound_hit; 

    // upper bound and lower bound checks
    RangeCheck #(.WIDTH(10)) ub_check(.high(10'd5), .low(10'd0), 
                    .val(ball_y), .is_between(upperbound_hit));
    RangeCheck #(.WIDTH(10)) lb_check(.high(10'd599), .low(10'd594), 
                    .val(ball_y), .is_between(lowerbound_hit));

    always_comb begin
        down_out = down_in;  
        
        if (upperbound_hit & ~down_in)
            down_out = 1'b1;
        else if (lowerbound_hit & down_in)
            down_out = 1'b0;
    end

endmodule : Boundary_Y







