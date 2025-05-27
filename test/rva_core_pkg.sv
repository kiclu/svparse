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
// Name: rva_core_pkg.sv
// Auth: Nikola Lukić
// Date: 29.04.2025.
// Desc: RVA Core package
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package rva_core_pkg;

  import axi5_pkg::*;

  /*
   * CORE FRONT-END CONFIG
   */

  typedef struct {
    int unsigned    FETCH_WIDTH;
  } rva_core_fe_cfg_t;

  /*
   * CORE CONFIG
   */

  typedef struct {

    // extension support flags
    bit             RVA;
    bit             RVB;
    bit             RVC;
    bit             RVD;
    bit             RVF;
    bit             RVI;
    bit             RVM;
    bit             RVS;
    bit             RVU;
    bit             RVZIFENCEI;
    bit             RVZICSR;
    bit             RVZICNTR;
    bit             RVZICOND;

    int unsigned    XLEN;
    int unsigned    FLEN;

    // initial PC value
    bit [63:0]      PC_RST;

    //bit [XLEN-1:0]  VENDOR_ID     = 'h0;
    //bit [XLEN-1:0]  ARCH_ID       = 'h0;
    //bit [XLEN-1:0]  IMP_ID        = 'h0;
    //bit [XLEN-1:0]  HART_ID       = 'h0;

    // instruction memory bus config
    axi5_cfg_t      IMEM_BUS_CFG;
    // data memory bus config
    axi5_cfg_t      DMEM_BUS_CFG;

    // front-end width
    int unsigned    FE_WIDTH;
    // back-end width
    int unsigned    BE_WIDTH;

  } rva_core_cfg_t;

  localparam rva_core_cfg_t RVA_CORE_CFG_RV32I = '{
    RVA:                0,
    RVB:                0,
    RVC:                0,
    RVD:                0,
    RVF:                0,
    RVI:                1,
    RVM:                0,
    RVS:                0,
    RVU:                0,
    RVZIFENCEI:         0,
    RVZICSR:            0,
    RVZICNTR:           0,
    RVZICOND:           0,
    XLEN:               32,
    FLEN:               32,
    PC_RST:             32'h0010_0000,
    IMEM_BUS_CFG: '{
      ADDR_WIDTH:       32,
      DATA_WIDTH:       128,
      STRB_WIDTH:       16,
      BRESP_WIDTH:      2,
      RRESP_WIDTH:      2,
      MECID_WIDTH:      0,
      ID_W_WIDTH:       4,
      ID_R_WIDTH:       4,
      RCHUNKNUM_WIDTH:  0,
      RCHUNKSTRB_WIDTH: 0,
      AWSNOOP_WIDTH:    4,
      ARSNOOP_WIDTH:    4,
      AWCMO_WIDTH:      0,
      SUBSYSID_WIDTH:   0,
      MPAM_WIDTH:       0,
      TAG_WIDTH:        4,
      TAGU_WIDTH:       1,
      LOOP_W_WIDTH:     0,
      LOOP_R_WIDTH:     0,
      USER_REQ_WIDTH:   0,
      USER_DATA_WIDTH:  0,
      USER_RESP_WIDTH:  0,
      AWUSER_WIDTH:     0,
      WUSER_WIDTH:      0,
      BUSER_WIDTH:      0,
      ARUSER_WIDTH:     0,
      RUSER_WIDTH:      0,
      SECSID_WIDTH:     0,
      SID_WIDTH:        0,
      SSID_WIDTH:       0,
      POISON_WIDTH:     2
    },
    DMEM_BUS_CFG: '{
      ADDR_WIDTH:       32,
      DATA_WIDTH:       128,
      STRB_WIDTH:       16,
      BRESP_WIDTH:      2,
      RRESP_WIDTH:      2,
      MECID_WIDTH:      0,
      ID_W_WIDTH:       4,
      ID_R_WIDTH:       4,
      RCHUNKNUM_WIDTH:  0,
      RCHUNKSTRB_WIDTH: 0,
      AWSNOOP_WIDTH:    4,
      ARSNOOP_WIDTH:    4,
      AWCMO_WIDTH:      0,
      SUBSYSID_WIDTH:   0,
      MPAM_WIDTH:       0,
      TAG_WIDTH:        4,
      TAGU_WIDTH:       1,
      LOOP_W_WIDTH:     0,
      LOOP_R_WIDTH:     0,
      USER_REQ_WIDTH:   0,
      USER_DATA_WIDTH:  0,
      USER_RESP_WIDTH:  0,
      AWUSER_WIDTH:     0,
      WUSER_WIDTH:      0,
      BUSER_WIDTH:      0,
      ARUSER_WIDTH:     0,
      RUSER_WIDTH:      0,
      SECSID_WIDTH:     0,
      SID_WIDTH:        0,
      SSID_WIDTH:       0,
      POISON_WIDTH:     2
    },
    FE_WIDTH:           4,
    BE_WIDTH:           4
  };

  localparam int unsigned INSN_TAG_WIDTH = 8;

  localparam int unsigned PADDR_WIDTH = $clog2(PHY_REG_CNT);

  typedef logic [INSN_TAG_WIDTH-1:0]  rva_core_itag_t;
  typedef logic [PADDR_WIDTH-1:0]     rva_core_paddr_t;

  typedef struct packed {
    rva_core_paddr_t  raddr;
    logic             rres;
  } rva_core_reg_t;

  typedef struct packed {
    logic             st;
    logic             ld;
    logic             op_32;
    logic             op;
  } rva_core_ex_t;

  typedef struct packed {
    logic [6:0]       func7;
    logic [2:0]       func3;
  } rva_core_func_t;

  typedef struct packed {

    rva_core_itag_t   tag;

    rva_core_reg_t    rs3;
    rva_core_reg_t    rs2;
    rva_core_reg_t    rs1;
    rva_core_reg_t    rd;

    logic [63:0]      imm;

    rva_core_func_t   func;
    rva_core_ex_t     ex;

  } rva_core_uop_t;

endpackage : rva_core_pkg

interface rva_core_rfi_w_if
  import rva_core_pkg::*;
#(

) (

);

  logic aaddr;
  logic paddr;

  logic wdata;

  logic we;

  modport sink (
    input  aaddr,
    input  paddr,
    input  wdata,
    input  we
  );

  modport source (
    output aaddr,
    output paddr,
    output wdata,
    output we
  );

endinterface : rva_core_rfi_w_if

interface rva_core_rfi_r_if
  import rva_core_pkg::*;
#() ();

  logic paddr;
  logic rdata;

  modport sink (
    input  paddr,
    output rdata
  );

  modport source (
    output paddr,
    input  rdata
  );

endinterface : rva_core_rfi_r_if

interface rva_core_ret_if
  import rva_core_pkg::*;
#() ();

endinterface : rva_core_ret_if
