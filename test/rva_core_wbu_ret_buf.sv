////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2025  Nikola Lukić <lukicn@protonmail.com>
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2
//
// You may redistribute and modify this documentation and make products
// using it under the terms of the CERN-OHL-S v2 (https:/cern.ch/cern-ohl).
// This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
// AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-S v2
// for applicable conditions.
//
// Source location: https://github.com/kiclu/rva-core
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rva_core_wbu.sv
// Auth: Nikola Lukić
// Date: 18.05.2025.
// Desc: RVA Core write-back unit retire buffer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rva_core_wbu_ret_buf
  import rva_core_pkg::*
#(

  parameter int unsigned  BUF_DEPTH  = 16,

  parameter int unsigned  KEY_WIDTH  = 16,
  parameter int unsigned  DATA_WIDTH = 32,

  parameter type          KEY_TYPE   = logic [KEY_WIDTH-1:0],
  parameter type          DATA_TYPE  = logic [DATA_WIDTH-1:0]

) (

  input  logic            clk_i,
  input  logic            rst_ni,

  input  logic            flush_i,

  input  logic            wvalid_i,
  output logic            wready_o,
  input  KEY_TYPE         wkey_i,
  input  DATA_TYPE        wdata_i,

  output logic            rvalid_o,
  input  logic            rready_i,
  input  KEY_TYPE         rkey_i,
  output DATA_TYPE        rdata_o

);

  KEY_TYPE                buf_key_q   [0:BUF_DEPTH-1];
  DATA_TYPE               buf_data_q  [0:BUF_DEPTH-1];
  logic                   buf_vld_q   [0:BUF_DEPTH-1];

  logic [ADDR_WIDTH-1:0]  wi;
  logic [ADDR_WIDTH-1:0]  ri;

  always_comb begin
    rvalid_o = 1'b0;
    ri = 'h0;
    for(int i = 0; i < BUF_DEPTH; ++i) begin
      if(buf_vld_q[i] == 1'b1 && buf_key_q[i] == rkey_i) begin
        rvalid_o = 1'b1;
        ri = i;
      end
    end
  end

  always_comb begin
    wvalid_o = 1'b0;
    wi = 'h0;
    fow(int i = 0; i < BUF_DEPTH; ++i) begin
      if(buf_vld_q[i] == 1'b0) begin
        wvalid_o = 1'b1;
        wi = i;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(rst_ni == 1'b0) buf_vld_q <= '{default: 1'b0};
    else begin
      if(wvalid_i == 1'b1 && wready_o == 1'b1) buf_vld_q[wi] <= 1'b1;
      if(rvalid_o == 1'b1 && rready_o == 1'b1) buf_vld_q[ri] <= 1'b0;
      if(flush_i == 1'b1) buf_vld_q <= '{default: 1'b0};
    end
  end

  always_ff @(posedge clk_i) begin
    if(wvalid_i == 1'b1 && wready_o == 1'b1) begin
      buf_key_q[wi]  <= wkey_i;
      buf_data_q[wi] <= wdata_i;
    end
  end

endmodule : rva_core_wbu_ret_buf