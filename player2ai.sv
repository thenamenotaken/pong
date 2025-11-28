// I don't think this works actually, gonna have to rethink

module player2ai
    (input clock, reset,
    input [1:0] level_state,
    input [9:0] ball_y, paddle_y,
    output logic move, up);

    logic [9:0] range, low, high, paddle_mid;
    logic [9:0] goodrange, goodlow, goodhigh;
    logic good;

    enum logic [1:0] {MOVEUP, MOVEDOWN, STAY} this_move, next_move;

    assign paddle_mid = paddle_y + 10'd24;
    assign low = paddle_y + 10'd24 - range;
    assign high = paddle_y + 10'd24 + range;

    always_comb begin
        if (level_state == 2'b00) begin
            range = 10'd75;
            goodrange = 10'd35;
        end
        else if (level_state == 2'b01) begin
            range = 10'd55;

            goodrange = 10'd25;
        end
        else if (level_state == 2'b10) begin
            range = 10'd35;

            goodrange = 10'd15;
        end
        else begin
            range = 10'd24; 

            goodrange = 10'd8;
        end
    end

    always_comb begin
        unique case (this_move)
            MOVEUP : next_move = (ball_y > paddle_mid + goodrange) ? 
                STAY : MOVEUP;
            MOVEDOWN : next_move = (ball_y < paddle_mid - goodrange) ? 
                STAY : MOVEDOWN;
            STAY : begin
                if (good)
                    next_move = STAY;
                else if (ball_y > paddle_y)
                    next_move = MOVEDOWN;
                else
                    next_move = MOVEUP;
            end
        endcase

    end

    always_ff @(posedge clock)
        if (reset)
            this_move <= STAY;
        else 
            this_move <= next_move;

    RangeCheck #(10) r(.high(high), .low(low), .val(ball_y), 
        .is_between(good));

    assign move = ~(this_move == STAY);
    assign up = this_move == MOVEDOWN;
    
endmodule: player2ai
