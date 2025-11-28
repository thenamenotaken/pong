module chipInterface2 (
    input  logic        CLOCK_100,
    input  logic [ 3:0] BTN,
    input  logic [15:0] SW,
    output logic [ 3:0] D2_AN, D1_AN,
    output logic [ 7:0] D2_SEG, D1_SEG,
    output logic        hdmi_clk_n, hdmi_clk_p,
    output logic [ 2:0] hdmi_tx_p, hdmi_tx_n
    );

    logic clk_40MHz, clk_200MHz;
    logic locked, reset;
    logic HS, VS, blank;
    logic [9:0] row, col;  
    logic [7:0] red, green, blue;
    logic frame_done;
    logic [3:0] p1_points, p2_points;
    logic [1:0] curr_state_debug;

    // Synchronized signals
    logic start_pt_sync, up1_sync, move1_sync, up2_sync, move2_sync, 
        reset_sync;


    //clock wizard configured with a 1x and 5x clock
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_40MHz),
        .clk_out2(clk_200MHz),
        .reset(1'b0), //could is be the fact we're resetting the clk as well?
        .locked(locked),
        .clk_in1(CLOCK_100)
    );
    
    // synchronize all buttons
    Synchronizer sync_start_pt(.async(BTN[3]), .clock(clk_40MHz), 
                .sync(start_pt_sync));
    Synchronizer sync_up1(.async(~SW[14]), .clock(clk_40MHz), 
                .sync(up1_sync));
    Synchronizer sync_move1(.async(SW[15]), .clock(clk_40MHz), 
                .sync(move1_sync));
    Synchronizer sync_up2(.async(~SW[0]), .clock(clk_40MHz), 
                .sync(up2_sync));
    Synchronizer sync_move2(.async(SW[1]), .clock(clk_40MHz), 
                .sync(move2_sync));
    Synchronizer sync_reset(.async(BTN[0]), .clock(clk_40MHz), 
                .sync(reset_sync));

   
    vga v (.clock_40MHz(clk_40MHz), .reset(reset_sync), .HS(HS), .VS(VS), 
           .blank(blank), .row(row), .col(col), .frame_complete(frame_done));

    
    Pong p(.clock(clk_40MHz), .reset(reset_sync | BTN[0]), 
            .frame_done(frame_done),
           .row(row), .col(col), .ai_mode(SW[8]),
           .up1(up1_sync), .move1(move1_sync), 
           .up2(up2_sync), .move2(move2_sync),
           .start_pt(start_pt_sync), 
           .red(red), .green(green), .blue(blue),
           .p1_points(p1_points), .p2_points(p2_points),
           .curr_state_debug(curr_state_debug)); 

  
    EightSevenSegmentDisplays displays(
        .HEX7(4'h0), .HEX6({3'h0, reset_sync}), .HEX5(4'h0), .HEX4(p1_points),
        .HEX3(4'h0), .HEX2(4'h0), .HEX1(4'h0), .HEX0(p2_points),
        .CLOCK_100(CLOCK_100),
        .reset(reset | BTN[0]),
        .dec_points(8'h00),
        .blank(8'b11101110),  
        .D2_AN(D2_AN),
        .D1_AN(D1_AN),
        .D2_SEG(D2_SEG),
        .D1_SEG(D1_SEG)
    );

    // Connect signals to the VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_40MHz),
        .pix_clkx5(clk_200MHz),
        .pix_clk_locked(locked),
    
        //Reset is active HIGH
        .rst(reset),

        //Color and Sync Signals
        .red( red ),
        .green( green ),
        .blue( blue ),

        .hsync( HS ),
        .vsync( VS ),
        .vde( ~blank ),

        //Differential outputs
        .TMDS_CLK_P(hdmi_clk_p),          
        .TMDS_CLK_N(hdmi_clk_n),          
        .TMDS_DATA_P(hdmi_tx_p),        
        .TMDS_DATA_N(hdmi_tx_n)          
    );

endmodule : chipInterface2