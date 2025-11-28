module Pong
   (input logic [9:0] row, col,
   input logic move1, up1, move2, up2, start_pt, ai_mode,
   input logic frame_done,
   input logic clock, reset,
   output logic [7:0] red, green, blue,
   output logic [3:0] p1_points, p2_points,
   output logic [1:0] curr_state_debug);

   assign curr_state_debug = curr_pt_state;

   logic origin, finish_ind;
   logic [9:0] paddle_y1, paddle_y2, ball_x, ball_y;
   logic p1_win, p2_win;
   logic is_ball, is_paddle1, is_paddle2;

   
   enum logic [1:0] {idle, play_pt, finish_pt} curr_pt_state, next_pt_state; 
   enum logic [1:0] {ez = 2'b00, normal = 2'b01, 
    kinda_hard = 2'b10, hardo = 2'b11} curr_level_state, next_level_state; 

    enum logic {P1_SERVE, P2_SERVE} this_serve, next_serve;
    logic p1_serves;

    always_comb begin
        case (this_serve)
            P1_SERVE: next_serve = p1_win ? P2_SERVE : P1_SERVE;
            P2_SERVE: next_serve = p2_win ? P1_SERVE : P2_SERVE;
            default : next_serve = P1_SERVE;
        endcase
    end

    assign p1_serves = (P1_SERVE == this_serve);

    always_ff @(posedge clock) begin
        if (reset)
            this_serve <= P1_SERVE;
        else
            this_serve <= next_serve;
    end

   // pt states ST logic
   always_comb begin
       case (curr_pt_state)
           idle: 
               if (start_pt)
                   next_pt_state = play_pt;
               else 
                   next_pt_state = idle;
           play_pt: 
               if (~p1_win & ~p2_win)
                   next_pt_state = play_pt;
               else if (p1_win | p2_win)
                   next_pt_state = finish_pt;  
           finish_pt: 
               if (frame_done)
                    next_pt_state = idle;
       endcase
   end

   // output logic for pt states
   always_comb begin
       unique case (curr_pt_state)
           idle: begin
               origin = 1; 
               finish_ind = 0;
           end
           play_pt: begin
               origin = 0; 
               finish_ind = 0;
           end
           finish_pt: begin
               origin = 0;
               finish_ind = 1; 
           end
           default: begin
               origin = 0;
               finish_ind = 0;
           end
       endcase
   end

   always_ff @(posedge clock) begin
       if (reset) begin
           curr_pt_state <= idle;
           curr_level_state <= ez;
       end
       else begin
           curr_pt_state <= next_pt_state;
           curr_level_state <= next_level_state;
       end
   end

   // level state logic
    always_comb begin
        if (p1_points + p2_points <= 2)
            next_level_state = ez;
        else if (p1_points + p2_points <= 10)
            next_level_state = normal;
        else if (p1_points + p2_points <= 15)
            next_level_state = kinda_hard;
        else
            next_level_state = hardo;
    end

    //level background logic
    logic background_1, background_2, background_3, background_4; 
    always_comb begin
        unique case(curr_level_state)
            ez: begin
                background_1 = 1;
                background_2 = 0;
                background_3 = 0;
                background_4 = 0;
            end
            normal: begin
                background_1 = 0;
                background_2 = 1;
                background_3 = 0;
                background_4 = 0;
            end
            kinda_hard: begin
                background_1 = 0;
                background_2 = 0;
                background_3 = 1;
                background_4 = 0;
            end
            hardo: begin
                background_1 = 0;
                background_2 = 0;
                background_3 = 0;
                background_4 = 1;
            end
        endcase
    end

   // score counters
   logic increment_p1, increment_p2;
   
   always_ff @(posedge clock) begin
       if (reset) begin
           increment_p1 <= 0;
           increment_p2 <= 0;
       end
       else begin
           increment_p1 <= (curr_pt_state == play_pt) && 
                (next_pt_state == finish_pt) 
                && p1_win && (p1_points !=9);
           increment_p2 <= (curr_pt_state == play_pt) && 
                (next_pt_state == finish_pt) 
                && p2_win && (p2_points !=9);
       end
   end

   Counter #(.WIDTH(4)) pt1(.clk(clock), .en(increment_p1), .clear(reset), 
        .load(1'b0),.up(1'b1), .D(4'b0), .Q(p1_points));

   Counter #(.WIDTH(4)) pt2(.clk(clock), .en(increment_p2), .clear(reset), 
        .load(1'b0),.up(1'b1), .D(4'b0), .Q(p2_points));
       
   logic ai_up, ai_move;
    
   player2ai bot(.level_state(curr_level_state), .ball_y(ball_y), 
        .paddle_y(paddle_y2),.move(ai_move), .up(ai_up), .clock(clock), 
        .reset(reset));
    
   logic up2_pick, move2_pick;
   assign up2_pick = ai_mode ? ai_up : up2;
   assign move2_pick = ai_mode ? ai_move : move2;

   paddle p(.origin(origin), .finish_frame(frame_done),
       .move1(move1), .up1(up1), .move2(move2_pick), .up2(up2_pick),
       .clock(clock), .paddle_y1(paddle_y1), .paddle_y2(paddle_y2));

   ball b(.clk(clock), .rst(reset), .finish_frame(frame_done),
       .origin(origin), .level_state(curr_level_state), .serve(p1_serves),
       .paddle_y1(paddle_y1), .paddle_y2(paddle_y2),
       .ball_x(ball_x), .ball_y(ball_y),
       .p1_win(p1_win), .p2_win(p2_win));

   areaCheck bcheck(.x(ball_x), .y(ball_y), .length(10'd4), 
        .height(10'd4),.row(row), .col(col), .is_in(is_ball));

   areaCheck p1check(.x(10'd40), .y(paddle_y1), .length(10'd4), 
        .height(10'd48),.row(row), .col(col), .is_in(is_paddle1));

   areaCheck p2check(.x(10'd757), .y(paddle_y2), .length(10'd4), 
        .height(10'd48),.row(row), .col(col), .is_in(is_paddle2));
    
   logic [7:0] bg_red, bg_green, bg_blue;

   background bg(.row(row), .col(col), 
                 .background_1(background_1), 
                 .background_2(background_2), 
                 .background_3(background_3), 
                 .background_4(background_4),
                 .clock(clock), .reset(reset), .frame_done(frame_done),
                 .red(bg_red), .green(bg_green), .blue(bg_blue));

    logic [7:0] starRed, starGreen, starBlue;
    logic is_star;
      starColors st(.clock(clock), .reset(reset), .finish_frame(frame_done),
        .level_state(curr_level_state), .pts1(p1_points), .pts2(p2_points),
        .row(row), .col(col), .red(starRed), .green(starGreen), 
        .blue(starBlue),.is_star(is_star));
        
   always_comb begin
       if (is_ball)
           {red, green, blue} = 24'hFFFFFF;
       else if (is_paddle1)
           {red, green, blue} = 24'hFFFF00;
       else if (is_paddle2)
           {red, green, blue} = 24'h00FFFF;
       else if (is_star)
            {red, green, blue} = {starRed, starGreen, starBlue};
       else
           {red, green, blue} = {bg_red, bg_green, bg_blue};
   end

endmodule: Pong



