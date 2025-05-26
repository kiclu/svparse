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
// Name: rva_core_ifu_fetch_buf.sv
// Auth: Nikola Lukić
// Date: 05.05.2025.
// Desc: RVA Core instruction fetch buffer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rva_core_ifu_fetch_buf
  import rva_core_pkg::*;
  import axi5_pkg::*;
  import asc_pkg::*;
#(
  parameter  rva_core_cfg_t       CORE_CFG   = RVA_CORE_CFG_RV32I,
  parameter  int unsigned         FIFO_DEPTH = 2,
  localparam int unsigned         XLEN       = CORE_CFG.XLEN,
  localparam int unsigned         DATA_WIDTH = CORE_CFG.IMEM_BUS_CFG.DATA_WIDTH
) (

  input  logic                    core_clk_i,
  input  logic                    core_rst_ni,

  input  logic                    ifu_flush_i,

  input  logic                    ifetch_buf_wvalid_i,
  output logic                    ifetch_buf_wready_o,
  input  logic [DATA_WIDTH-1:0]   ifetch_buf_wdata_i,
  input  logic [XLEN-1:0]         ifetch_buf_waddr_i,
  input  logic                    ifetch_buf_wresp_i,

  // streaming source port
  asc_if.source                   ifu_so_if [0:CORE_CFG.FE_WIDTH-1]

);

  localparam int unsigned IMUX_WIDTH = 2*CORE_CFG.FE_WIDTH-1;
  //localparam int unsigned ISEL_WIDTH = $clog2(2*CORE_CFG.FE_WIDTH);
  //localparam int unsigned ADDR_WIDTH = $clog2(FIFO_DEPTH*DATA_WIDTH/16);
  //localparam int unsigned LEN_WIDTH  = $clog2(DATA_WIDTH/16);

  logic [31:0]            imux_data_in  [0:IMUX_WIDTH-1];
  logic                   imux_vld_in   [0:IMUX_WIDTH-1];

  logic                   imux_cinsn    [0:CORE_CFG.FE_WIDTH-1];
  logic [ISEL_WIDTH-1:0]  imux_sel      [0:CORE_CFG.FE_WIDTH-1];
  logic [31:0]            imux_data_out [0:CORE_CFG.FE_WIDTH-1];
  logic                   imux_vld_out  [0:CORE_CFG.FE_WIDTH-1];

  logic                   ifetch_buf_valid;
  logic                   ifetch_buf_ready;
  logic [LEN_WIDTH-1:0]   ifetch_buf_rlen;
  logic [DATA_WIDTH-1:0]  ifetch_buf_rdata;
  logic [ADDR_WIDTH-1:0]  ifetch_buf_rcnt;

  logic                   so_buf_we     [0:CORE_CFG.FE_WIDTH-1];
  logic [31:0]            so_buf_data   [0:CORE_CFG.FE_WIDTH-1];
  logic                   so_buf_full   [0:CORE_CFG.FE_WIDTH-1];

  fifo_sync_wa #(
    .DATA_WIDTH (DATA_WIDTH             ),
    .FIFO_DEPTH (FIFO_DEPTH             ),
    .WORD_WIDTH (16                     )
  )
  u_ifetch_insn_buf (
    .clk_i      (core_clk_i             ),
    .rst_ni     (core_rst_ni            ),
    .clr_i      (ifu_flush_i            ),

    .wvalid_i   (ifetch_buf_wvalid_i    ),
    .wready_o   (ifetch_buf_wready_o    ),
    .wlen_i     (DATA_WIDTH-1           ),
    .wdata_i    (ifetch_buf_wdata_i     ),
    .wcnt_o     (                       ),

    .rvalid_o   (ifetch_buf_rvalid      ),
    .rready_i   (ifetch_buf_rready      ),
    .rlen_i     (ifetch_buf_rlen        ),
    .rdata_o    (ifetch_buf_rdata       ),
    .rcnt_o     (ifetch_buf_rcnt        )
  );

  logic [(XLEN*DATA_WIDTH/16)-1:0] ifetch_buf_addr;

  for(genvar i = 0; i < IMUX_WIDTH+1; ++i) begin
    assign ifetch_buf_addr[32*i+:32] = ifetch_buf_waddr_i + (i << 1);
  end

  fifo_sync_wa #(
    .DATA_WIDTH (XLEN*DATA_WIDTH/16     ),
    .FIFO_DEPTH (FIFO_DEPTH             ),
    .WORD_WIDTH (XLEN                   )
  )
  u_ifetch_addr_buf (
    .clk_i      (core_clk_i             ),
    .rst_ni     (core_rst_ni            ),
    .clr_i      (ifu_flush_i            ),

    .wvalid_i   (ifetch_buf_wvalid_i    ),
    .wready_o   (ifetch_buf_wready_o    ),
    .wlen_i     (DATA_WIDTH-1           ),
    .wdata_i    (ifetch_buf_addr        ),
    .wcnt_o     (                       ),

    .rvalid_o   (ifetch_buf_rvalid      ),
    .rready_i   (ifetch_buf_rready      ),
    .rlen_i     (ifetch_buf_rlen        ),
    .rdata_o    (                       ),
    .rcnt_o     (                       )
  );

  for(genvar i = 0; i < IMUX_WIDTH; ++i) begin
    assign imux_vld_in[i] = ifetch_buf_valid == 1'b1 && i < ifetch_buf_rcnt;
  end

  // instruction multiplexer input data
  // fetch buffer data can contain compressed 16-bit instructions
  // therefore multiplexer inputs have a stride of 16 bits
  // ex for fetch width of 4, inputs will be
  // [15:0], [31:16], [47:32] ... [127:112]
  for(genvar i = 0; i < IMUX_WIDTH; ++i) begin
    assign imux_data_in[i] = ifetch_buf_rdata[i*16+:32];
  end

  for(genvar i = 0; i < CORE_CFG.FE_WIDTH; ++i) begin : imux_genblk

    // generate select signal for every stream interface mux
    if(i == 0) assign imux_sel[i] = 'h0;
    else begin : imux_sel_genblk
      always_comb begin
        if(so_buf_full[i-1] == 1'b1 || imux_vld_in[i] == 1'b0) begin
          // previous stream interface is stalled,
          // keep the same select index and try again
          imux_sel[i] = imux_sel[i-1];
        end
        else if(imux_cinsn[i-1] == 1'b1) begin
          // compressed instruction on previuos stream interface,
          // stride 1 word (16 bits) from previous select
          imux_sel[i] = imux_sel[i-1] + 'h1;
        end
        else begin
          // uncompressed instruction on previous stream interface,
          // stride 2 words (32 bits) from previous select
          imux_sel[i] = imux_sel[i-1] + 'h2;
        end
      end
    end // imux_sel_genblk
    assign imux_cinsn[i] = imux_data_out[i][1:0] != 2'b11;

  end // imux_genblk

  for(genvar i = 0; i < CORE_CFG.FE_WIDTH; ++i) begin : ifu_so_imux_out_genblk
    assign imux_data_out[i] = imux_data_in[imux_sel[i]];
    assign imux_vld_out[i]  = imux_vld_in[imux_sel[i]];
  end

  assign ifetch_buf_rlen = imux_sel[CORE_CFG.FE_WIDTH-1] + (imux_cinsn[CORE_CFG.FE_WIDTH-1] == 1'b0);

  for(genvar i = 0; i < CORE_CFG.FE_WIDTH; ++i) begin : ifu_so_buf_genblk

    assign so_buf_data[i] = imux_data_out[i];
    assign so_buf_we[i]   = imux_vld_out[i];

    asc_source_buf_sc #(2)
    u_ifu_so_buf (
      .clk_i    (core_clk_i         ),
      .rst_ni   (core_rst_ni        ),
      .clr_i    (ifu_flush_i        ),
      .stall_o  (                   ),
      .sp_if    (ifu_so_if[i]       ),
      .we_i     (so_buf_we[i]       ),
      .wdata_i  (so_buf_data[i]     ),
      .werr_i   (1'b0               ),
      .wchan_i  (                   ),
      .full_o   (so_buf_full[i]     )
    );

  end // ifu_so_buf_genblk

endmodule : rva_core_ifu_fetch_buf
