/*
 * Copyright (c) 2024 Eric Smith
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Implement Figure 29.3 from Dally & Harting to see how bad it is in practice. 

module tt_um_dlmiles_bad_synchronizer (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire clk1;

  reg skew;
    
  reg [3:0] stage1;
  reg [3:0] stage2;
  reg [3:0] stage3;

  // Unique Inputs
    
  assign clk1 = ui_in[0];
    
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = {3'b000,skew,stage3[3:0]};
  assign uio_out = {stage1[3:0],stage2[3:0]};
  assign uio_oe  = 8'hFF;
    
  // Skew is used to externally align clk & clk1 edges.
  always @(posedge clk or negedge rst_n)
      if ( 0 == rst_n )
          skew <= 1'b0;
      else
          skew <= clk1;

    
  always @(posedge clk or negedge rst_n)
      if ( 0 == rst_n )
          stage1[3:0] <= 4'd0;
      else
          stage1[3:0] <= stage1[3:0] + 4'd1;


  always @(posedge clk1 or negedge rst_n)
      if ( 0 == rst_n )
          stage2[3:0] <= 4'd0;
      else
          stage2[3:0] <= stage1[3:0];    

  always @(posedge clk1 or negedge rst_n)
      if ( 0 == rst_n )
          stage3[3:0] <= 4'd0;
      else
          stage3[3:0] <= stage2[3:0];  

    
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:0], ui_in[7:1], 1'b0};

endmodule
