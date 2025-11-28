module stars
  (input logic clock, reset, finish_frame,
  input logic [9:0] row, col,
  input logic [9:0] x, y,
  output logic color1, color2, color3);

  logic [7:0] count;

  Counter #(8) cnt(.clk(clock), .en(finish_frame),
      .clear(reset), .load(1'b0), .up(1'b1),
      .D(8'b0), .Q(count));

  assign color1 = (row >= y) && (row <= (y+4))
      && (col >= x && col <= (x+4)) // center
      || (count[7:6] == 2'b10) &&
          ((row == y+14) && ((col == x+14) || (col == x-10))   
          || (row == y-10) && ((col == x-10) || (col == x+14))); 

  assign color2 = ((count[7:6] >= 2'b01) &&
       ((row >= y+5) && (row <= (y+9)) ||       
      (row >= y-5 && row <= y-1)) &&     
      (col >= x && col <= x+4) // left right
      || ((col >= x+5) && (col <= (x+9)) ||      
      (col >= x-5 && col <= x-1)) &&             
      (row >= y && row <= y+4)) // up down        
      || (count[7:6] == 2'b10 || count[7:6] == 2'b01)
          && ((row == y+9) && ((col == x+9) || (col == x-5))    
          || (row == y-5) && ((col == x-5) || (col == x+9)));   

  assign color3 = (count[7:6] == 2'b10)
      && (((row >= y+10) && (row <= (y+14)) ||    
      (row >= y-10 && row <= y-6)) &&             
      (col >= x && col <= x+4) // left right
      || ((col >= x+10) && (col <= (x+14)) ||     
      (col >= x-10 && col <= x-6)) &&             
      (row >= y && row <= y+4)); 

endmodule: stars

module starColors
  (input logic clock, reset, finish_frame,
  input logic [1:0] level_state,
  input logic [3:0] pts1, pts2,
  input logic [9:0] row, col,
  output logic [7:0] red, green, blue,
  output logic is_star);

  logic [23:0] rgb1, rgb2, rgb3, rgb4, rgb5, rgb6;
  always_comb begin
      unique case (level_state)
          2'b00: begin
              rgb1 = 24'hdaadf0;
              rgb2 =24'hb06dcf;
              rgb3 =24'h7344a6;
              rgb4 =24'he8d590;
              rgb5 =24'he3b468;
              rgb6 =24'hed8f4c;
          end
          2'b01: begin
              rgb1 =24'hb9a3e6;
              rgb2 =24'h7767b8;
              rgb3 =24'h57499c;
              rgb4 =24'hd9cd8b;
              rgb5 =24'hc9aa61;
              rgb6 =24'hc49847;
          end
          2'b10: begin
              rgb1 =24'hada3e6;
              rgb2 =24'h6a68b3;
              rgb3 =24'h514a91;
              rgb4 =24'hba9970;
              rgb5 =24'ha67e67;
              rgb6 =24'h7a5057; 
          end
          2'b11: begin
              rgb4 =24'hd0d4e8;
              rgb5 =24'h7c86b3;
              rgb6 =24'h45507d;
              rgb1 =24'he0d0e8;
              rgb2 =24'ha37cb3;
              rgb3 =24'h694187;
          end

          default: begin             
              rgb1 = 24'hdaadf0;
              rgb2 =24'hb06dcf;
              rgb3 =24'h7344a6;
              rgb4 =24'he8d590;
              rgb5 =24'he3b468;
              rgb6 =24'hed8f4c;
              end
      endcase
  end
  
  logic [8:0] p1c1, p1c2, p1c3, p2c1, p2c2, p2c3, p1star, p2star;
  logic [9:0] posx1, posx2, posx3, posx4, posx5,
      posx6, posx7, posx8, posx9;
  logic [9:0] posy1, posy2, posy3, posy4;

  assign posx1 = 10'd80;
  assign posx2 = 10'd160;
  assign posx3 = 10'd240;
  assign posx4 = 10'd320;
  assign posx5 = 10'd400;
  assign posx6 = 10'd480;
  assign posx7 = 10'd560;
  assign posx8 = 10'd640;
  assign posx9 = 10'd720;

  assign posy1 = 10'd100;
  assign posy2 = 10'd200;
  assign posy3 = 10'd300;
  assign posy4 = 10'd400;

  stars s11(.color1(p1c1[0]), .color2(p1c2[0]), .color3(p1c3[0]),
      .x(posx1), .y(posy1), .*);
  stars s12(.color1(p1c1[1]), .color2(p1c2[1]), .color3(p1c3[1]),
      .x(posx2), .y(posy2), .*);
  stars s13(.color1(p1c1[2]), .color2(p1c2[2]), .color3(p1c3[2]),
      .x(posx3), .y(posy1), .*);
  stars s14(.color1(p1c1[3]), .color2(p1c2[3]), .color3(p1c3[3]),
      .x(posx4), .y(posy2), .*);
  stars s15(.color1(p1c1[4]), .color2(p1c2[4]), .color3(p1c3[4]),
      .x(posx5), .y(posy1), .*);
  stars s16(.color1(p1c1[5]), .color2(p1c2[5]), .color3(p1c3[5]),
      .x(posx6), .y(posy2), .*);
  stars s17(.color1(p1c1[6]), .color2(p1c2[6]), .color3(p1c3[6]),
      .x(posx7), .y(posy1), .*);
  stars s18(.color1(p1c1[7]), .color2(p1c2[7]), .color3(p1c3[7]),
      .x(posx8), .y(posy2), .*);
  stars s19(.color1(p1c1[8]), .color2(p1c2[8]), .color3(p1c3[8]),
      .x(posx9), .y(posy1), .*);

  stars s21(.color1(p2c1[0]), .color2(p2c2[0]), .color3(p2c3[0]),
     .x(posx1), .y(posy3), .*);
  stars s22(.color1(p2c1[1]), .color2(p2c2[1]), .color3(p2c3[1]),
     .x(posx2), .y(posy4), .*);
  stars s23(.color1(p2c1[2]), .color2(p2c2[2]), .color3(p2c3[2]),
     .x(posx3), .y(posy3), .*);
  stars s24(.color1(p2c1[3]), .color2(p2c2[3]), .color3(p2c3[3]),
     .x(posx4), .y(posy4), .*);
  stars s25(.color1(p2c1[4]), .color2(p2c2[4]), .color3(p2c3[4]),
     .x(posx5), .y(posy3), .*);
  stars s26(.color1(p2c1[5]), .color2(p2c2[5]), .color3(p2c3[5]),
     .x(posx6), .y(posy4), .*);
  stars s27(.color1(p2c1[6]), .color2(p2c2[6]), .color3(p2c3[6]),
     .x(posx7), .y(posy3), .*);
  stars s28(.color1(p2c1[7]), .color2(p2c2[7]), .color3(p2c3[7]),
     .x(posx8), .y(posy4), .*);
  stars s29(.color1(p2c1[8]), .color2(p2c2[8]), .color3(p2c3[8]),
     .x(posx9), .y(posy3), .*);

  // masks for which stars should be visible based on points 
  //bc i can't think anything better
  logic [8:0] p1_mask, p2_mask;
  
  always_comb begin
      case (pts2)
          4'd0: p2_mask = 9'b000000000;
          4'd1: p2_mask = 9'b100000000;
          4'd2: p2_mask = 9'b110000000;
          4'd3: p2_mask = 9'b111000000;
          4'd4: p2_mask = 9'b111100000;
          4'd5: p2_mask = 9'b111110000;
          4'd6: p2_mask = 9'b111111000;
          4'd7: p2_mask = 9'b111111100;
          4'd8: p2_mask = 9'b111111110;
          default: p1_mask = 9'b111111111; // 9 or more
      endcase
      
      case (pts1)
        4'd0: p1_mask = 9'b000000000;
          4'd1: p1_mask = 9'b000000001;
          4'd2: p1_mask = 9'b000000011;
          4'd3: p1_mask = 9'b000000111;
          4'd4: p1_mask = 9'b000001111;
          4'd5: p1_mask = 9'b000011111;
          4'd6: p1_mask = 9'b000111111;
          4'd7: p1_mask = 9'b001111111;
          4'd8: p1_mask = 9'b011111111;
          default: p2_mask = 9'b111111111; // 9 or more
      endcase
  end
  
  // and masks to star colors
  logic [8:0] p1c1_masked, p1c2_masked, p1c3_masked;
  logic [8:0] p2c1_masked, p2c2_masked, p2c3_masked;
  
  assign p1c1_masked = p1c1 & p1_mask;
  assign p1c2_masked = p1c2 & p1_mask;
  assign p1c3_masked = p1c3 & p1_mask;
  assign p2c1_masked = p2c1 & p2_mask;
  assign p2c2_masked = p2c2 & p2_mask;
  assign p2c3_masked = p2c3 & p2_mask;

  always_comb begin
      if (p1c1_masked != 0)
          {red, green, blue} = rgb1;
      else if (p1c2_masked != 0)
          {red, green, blue} = rgb2;
      else if (p1c3_masked != 0)
          {red, green, blue} = rgb3;
      else if (p2c1_masked != 0)
          {red, green, blue} = rgb4;
      else if (p2c2_masked != 0)
          {red, green, blue} = rgb5;
      else if (p2c3_masked != 0)
          {red, green, blue} = rgb6;
  end

  assign p1star = p1c1_masked | p1c2_masked | p1c3_masked;
  assign p2star = p2c1_masked | p2c2_masked | p2c3_masked;

  assign is_star = (p1star != 0) || (p2star != 0);

endmodule: starColors