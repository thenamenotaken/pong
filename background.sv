module background
    (input logic [9:0] row, col,
    input logic clock, reset, frame_done,
    input logic background_1, background_2, background_3, background_4,
    output logic [7:0] red, green, blue);

    logic [7:0] sky_red, sky_green, sky_blue;
    logic is_sun, is_ground;
    logic is_cloud1, is_cloud2, is_cloud3, is_cloud4;
    logic is_shadow1, is_shadow2, is_shadow3, is_shadow4;
    logic draw_any_cloud;
    
    //cloud pos
    logic [10:0] cloud1_x, cloud2_x, cloud3_x, cloud4_x;

    logic [9:0] sun_y;
    logic [7:0] more_blue, more_red, less_green; 
    logic [23:0] cloud_color;

    always_comb begin
        if (background_1) begin
            sun_y = 10'd400;
            more_blue = 8'd0;
            more_red = 8'd0;
            less_green = 8'd0;
            cloud_color = 24'hff8375; 
        end
        else if (background_2) begin
            sun_y = 10'd450;
            more_blue = 8'd15;
            more_red = 8'd10;
            less_green = 8'd20;
            cloud_color = 24'hd43f65;
        end
        else if (background_3) begin
            sun_y = 10'd500;
            more_blue = 8'd30;
            more_red = 8'd20;
            less_green = 8'd40;
            cloud_color = 24'h991d93;
        end
        else begin  // background_4
            sun_y = 10'd550;
            more_blue = 8'd50;
            more_red = 8'd30;
            less_green = 8'd60;
            cloud_color = 24'h5d147d;
        end
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            cloud1_x <= 11'd50;
            cloud2_x <= 11'd300;
            cloud3_x <= 11'd550;
            cloud4_x <= 11'd800;
        end
        else if (frame_done) begin
            cloud1_x <= (cloud1_x >= 11'd1023) ? 
                        11'd0 : cloud1_x + 11'd1;
            cloud2_x <= (cloud2_x >= 11'd1023) ? 11'd0 
                        : cloud2_x + 11'd1;
            cloud3_x <= (cloud3_x >= 11'd1023) ? 11'd0 
                        : cloud3_x + 11'd1;
            cloud4_x <= (cloud4_x >= 11'd1023) ? 11'd0 
                        : cloud4_x + 11'd1;
        end
    end
    
    cloud #(.LENGTH(80)) c1 (
        .x(cloud1_x[9:0]), .y(10'd90), 
        .row(row), .col(col), 
        .is_cloud(is_cloud1), .is_shadow(is_shadow1)
    );
    
    cloud #(.LENGTH(120)) c2 (  
        .x(cloud2_x[9:0]), .y(10'd120), 
        .row(row), .col(col), 
        .is_cloud(is_cloud2), .is_shadow(is_shadow2)
    );
    
    cloud #(.LENGTH(60)) c3 (  
        .x(cloud3_x[9:0]), .y(10'd40), 
        .row(row), .col(col), 
        .is_cloud(is_cloud3), .is_shadow(is_shadow3)
    );
    
    cloud #(.LENGTH(100)) c4 (
        .x(cloud4_x[9:0]), .y(10'd140), 
        .row(row), .col(col), 
        .is_cloud(is_cloud4), .is_shadow(is_shadow4)
    );
    
    assign draw_any_cloud = is_cloud1 | is_cloud2 | is_cloud3 | is_cloud4;
    
    
    always_comb begin
        if (row < 10'd200) begin
            //top - add 
            sky_red   = (8'd50 + more_red + (row >> 1) > 8'd255) ? 
                        8'd255 : (8'd50 + more_red + (row >> 1));
            sky_green = (8'd30 > less_green) ? ((8'd30 - less_green + 
                        (row >> 2) > 8'd255) ? 8'd255 : (8'd30 - less_green 
                        + (row >> 2))) : (row >> 2);
            sky_blue  = (8'd90 + more_blue + (row >> 2) > 8'd255) ? 8'd255 
                        : (8'd90 + more_blue + (row >> 2));
        end
        else if (row < 10'd400) begin
            //mid 
            sky_red   = (8'd150 + more_red + ((row - 10'd200) >> 1) 
                        > 8'd255) ? 8'd255 : (8'd150 + more_red + 
                        ((row - 10'd200) >> 1));
            sky_green = (8'd80 > less_green) ? ((8'd80 - less_green 
                        + ((row - 10'd200) >> 2) > 8'd255) ? 8'd255 : 
                        (8'd80 - less_green + ((row - 10'd200) >> 2))) : 
                        ((row - 10'd200) >> 2);
            sky_blue  = (8'd140 + more_blue > 8'd255) ? 8'd255 : 
                        ((8'd140 + more_blue - ((row - 10'd200) >> 2) < 8'd0) 
                        ? 8'd0 : (8'd140 + more_blue - ((row - 10'd200) >> 2)));
        end
        else if (row < 10'd480) begin
            //bottom
            sky_red   = (8'd250 + more_red + ((row - 10'd400) >> 2) > 8'd255) 
                        ? 8'd255 : (8'd250 + more_red + ((row - 10'd400) >> 2));
            sky_green = (8'd130 > less_green) ? ((8'd130 - less_green + 
                        ((row - 10'd400) >> 1) > 8'd255) ? 8'd255 : 
                        (8'd130 - less_green + ((row - 10'd400) >> 1))) : 
                        ((row - 10'd400) >> 1);
            sky_blue  = (8'd90 + more_blue > 8'd255) ? 8'd255 : ((8'd90 + 
                        more_blue - ((row - 10'd400) >> 2) < 8'd0) ? 8'd0 : 
                        (8'd90 + more_blue - ((row - 10'd400) >> 2)));
        end
        else begin
            //ground 
            sky_red   = 8'd35;
            sky_green = 8'd19;
            sky_blue  = 8'd110;
        end
    end
    
    logic [19:0] sun_dist_sq;
    logic [9:0] sun_x;
    
    assign sun_x = 10'd400;   
    
    assign sun_dist_sq = (col - sun_x) * (col - sun_x) + 
                        (row - sun_y) * (row - sun_y);
    
    assign is_sun = (sun_dist_sq < 20'd900);
    assign is_ground = (row >= 10'd480);
    
    always_comb begin
        if (is_ground)
            {red, green, blue} = 24'h23136e;
        else if (is_sun)
            {red, green, blue} = 24'hFFFAE6;
        else if (draw_any_cloud)
            {red, green, blue} = cloud_color;  
        else
            {red, green, blue} = {sky_red, sky_green, sky_blue};
    end

endmodule : background

module cloud
    #(parameter LENGTH = 80)
    (input logic [9:0] x, y, row, col,
    output logic is_cloud,
    output logic is_shadow);

    logic is_base, is_bump1, is_bump2, is_bump3, is_bump4, is_bump5, 
            is_bump6, is_bump7;
    
    assign is_cloud = is_base | is_bump1 | is_bump2 | is_bump3 | is_bump4 
            | is_bump5 | is_bump6 | is_bump7; 
    assign is_shadow = 1'b0;

    areaCheck base (.x(x), .y(y), 
                    .length(LENGTH), .height(10'd12), 
                    .row(row), .col(col), .is_in(is_base));
    
    areaCheck b1 (.x(x + 10'd5), .y(y - 10'd10), 
                  .length(LENGTH - 10'd17), .height(10'd12),
                  .row(row), .col(col), .is_in(is_bump1));
    
    areaCheck b2 (.x(x + (LENGTH >> 3)), .y(y - 10'd20), 
                  .length(LENGTH >> 3), .height(10'd22),
                  .row(row), .col(col), .is_in(is_bump2));
    
    areaCheck b3 (.x(x + (LENGTH >> 2) + 10'd5), .y(y - 10'd28), 
                  .length(LENGTH >> 2), .height(10'd30),
                  .row(row), .col(col), .is_in(is_bump3));
    
    areaCheck b4 (.x(x + (LENGTH >> 2) + 10'd12), .y(y - 10'd35), 
                  .length(LENGTH >> 4), .height(10'd8),
                  .row(row), .col(col), .is_in(is_bump4));
    
    areaCheck b5 (.x(x + (LENGTH >> 1) + 10'd5), .y(y - 10'd18), 
                  .length(LENGTH >> 3), .height(10'd20),
                  .row(row), .col(col), .is_in(is_bump5));
    
    areaCheck b6 (.x(x + LENGTH - (LENGTH >> 3) - 10'd5), .y(y - 10'd12), 
                  .length(LENGTH >> 4), .height(10'd10),
                  .row(row), .col(col), .is_in(is_bump6));
    
    areaCheck b7 (.x(x + LENGTH - 10'd10), .y(y - 10'd8), 
                  .length(LENGTH >> 5), .height(10'd5),
                  .row(row), .col(col), .is_in(is_bump7));
    
endmodule : cloud

