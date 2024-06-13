`default_nettype none

module top_int
#(
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 6,
  parameter integer C_M_AXI_PROGMEM_ID_WIDTH = 1,
  parameter integer C_M_AXI_PROGMEM_DATA_WIDTH = 256,
  parameter integer C_M_AXI_PROGMEM_ADDR_WIDTH = 64,
  parameter integer C_M_AXI_GMEM_ID_WIDTH = 1,
  parameter integer C_M_AXI_GMEM_DATA_WIDTH = 64,
  parameter integer C_M_AXI_GMEM_ADDR_WIDTH = 64
)(
    input wire ap_clk,
    input wire ap_rst_n,
  input wire  s_axi_control_AWVALID,
  input wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_AWADDR,
  input wire  s_axi_control_WVALID,
  input wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_WDATA,
  input wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_WSTRB,
  input wire  s_axi_control_ARVALID,
  input wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_ARADDR,
  input wire  s_axi_control_RREADY,
  input wire  s_axi_control_BREADY,
  output wire  s_axi_control_AWREADY,
  output wire  s_axi_control_WREADY,
  output wire  s_axi_control_ARREADY,
  output wire  s_axi_control_RVALID,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_RDATA,
  output wire [1:0] s_axi_control_RRESP,
  output wire  s_axi_control_BVALID,
  output wire [1:0] s_axi_control_BRESP,
  input wire  m_axi_progmem_AWREADY,
  input wire  m_axi_progmem_WREADY,
  input wire  m_axi_progmem_ARREADY,
  input wire  m_axi_progmem_RVALID,
  input wire [C_M_AXI_PROGMEM_DATA_WIDTH-1:0] m_axi_progmem_RDATA,
  input wire  m_axi_progmem_RLAST,
  input wire [C_M_AXI_PROGMEM_ID_WIDTH-1:0] m_axi_progmem_RID,
  input wire [1:0] m_axi_progmem_RRESP,
  input wire  m_axi_progmem_BVALID,
  input wire [C_M_AXI_PROGMEM_ID_WIDTH-1:0] m_axi_progmem_BID,
  input wire [1:0] m_axi_progmem_BRESP,
  output wire  m_axi_progmem_AWVALID,
  output wire [C_M_AXI_PROGMEM_ADDR_WIDTH-1:0] m_axi_progmem_AWADDR,
  output wire [C_M_AXI_PROGMEM_ID_WIDTH-1:0] m_axi_progmem_AWID,
  output wire [7:0] m_axi_progmem_AWLEN,
  output wire [2:0] m_axi_progmem_AWSIZE,
  output wire [1:0] m_axi_progmem_AWBURST,
  output wire [1:0] m_axi_progmem_AWLOCK,
  output wire [3:0] m_axi_progmem_AWCACHE,
  output wire [2:0] m_axi_progmem_AWPROT,
  output wire [3:0] m_axi_progmem_AWQOS,
  output wire [3:0] m_axi_progmem_AWREGION,
  output wire  m_axi_progmem_WVALID,
  output wire [C_M_AXI_PROGMEM_DATA_WIDTH-1:0] m_axi_progmem_WDATA,
  output wire [C_M_AXI_PROGMEM_DATA_WIDTH/8-1:0] m_axi_progmem_WSTRB,
  output wire  m_axi_progmem_WLAST,
  output wire  m_axi_progmem_ARVALID,
  output wire [C_M_AXI_PROGMEM_ADDR_WIDTH-1:0] m_axi_progmem_ARADDR,
  output wire [C_M_AXI_PROGMEM_ID_WIDTH-1:0] m_axi_progmem_ARID,
  output wire [7:0] m_axi_progmem_ARLEN,
  output wire [2:0] m_axi_progmem_ARSIZE,
  output wire [1:0] m_axi_progmem_ARBURST,
  output wire [1:0] m_axi_progmem_ARLOCK,
  output wire [3:0] m_axi_progmem_ARCACHE,
  output wire [2:0] m_axi_progmem_ARPROT,
  output wire [3:0] m_axi_progmem_ARQOS,
  output wire [3:0] m_axi_progmem_ARREGION,
  output wire  m_axi_progmem_RREADY,
  output wire  m_axi_progmem_BREADY,
  input wire  m_axi_gmem_AWREADY,
  input wire  m_axi_gmem_WREADY,
  input wire  m_axi_gmem_ARREADY,
  input wire  m_axi_gmem_RVALID,
  input wire [C_M_AXI_GMEM_DATA_WIDTH-1:0] m_axi_gmem_RDATA,
  input wire  m_axi_gmem_RLAST,
  input wire [C_M_AXI_GMEM_ID_WIDTH-1:0] m_axi_gmem_RID,
  input wire [1:0] m_axi_gmem_RRESP,
  input wire  m_axi_gmem_BVALID,
  input wire [C_M_AXI_GMEM_ID_WIDTH-1:0] m_axi_gmem_BID,
  input wire [1:0] m_axi_gmem_BRESP,
  output wire  m_axi_gmem_AWVALID,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0] m_axi_gmem_AWADDR,
  output wire [C_M_AXI_GMEM_ID_WIDTH-1:0] m_axi_gmem_AWID,
  output wire [7:0] m_axi_gmem_AWLEN,
  output wire [2:0] m_axi_gmem_AWSIZE,
  output wire [1:0] m_axi_gmem_AWBURST,
  output wire [1:0] m_axi_gmem_AWLOCK,
  output wire [3:0] m_axi_gmem_AWCACHE,
  output wire [2:0] m_axi_gmem_AWPROT,
  output wire [3:0] m_axi_gmem_AWQOS,
  output wire [3:0] m_axi_gmem_AWREGION,
  output wire  m_axi_gmem_WVALID,
  output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0] m_axi_gmem_WDATA,
  output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_WSTRB,
  output wire  m_axi_gmem_WLAST,
  output wire  m_axi_gmem_ARVALID,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0] m_axi_gmem_ARADDR,
  output wire [C_M_AXI_GMEM_ID_WIDTH-1:0] m_axi_gmem_ARID,
  output wire [7:0] m_axi_gmem_ARLEN,
  output wire [2:0] m_axi_gmem_ARSIZE,
  output wire [1:0] m_axi_gmem_ARBURST,
  output wire [1:0] m_axi_gmem_ARLOCK,
  output wire [3:0] m_axi_gmem_ARCACHE,
  output wire [2:0] m_axi_gmem_ARPROT,
  output wire [3:0] m_axi_gmem_ARQOS,
  output wire [3:0] m_axi_gmem_ARREGION,
  output wire  m_axi_gmem_RREADY,
  output wire  m_axi_gmem_BREADY
);
  
axi_lite_interface #(.DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH),.ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH)) s_axi_control();
assign s_axi_control.AWVALID = s_axi_control_AWVALID;
assign s_axi_control.AWADDR = s_axi_control_AWADDR;
assign s_axi_control.WVALID = s_axi_control_WVALID;
assign s_axi_control.WDATA = s_axi_control_WDATA;
assign s_axi_control.WSTRB = s_axi_control_WSTRB;
assign s_axi_control.ARVALID = s_axi_control_ARVALID;
assign s_axi_control.ARADDR = s_axi_control_ARADDR;
assign s_axi_control.RREADY = s_axi_control_RREADY;
assign s_axi_control.BREADY = s_axi_control_BREADY;
assign s_axi_control_AWREADY = s_axi_control.AWREADY;
assign s_axi_control_WREADY = s_axi_control.WREADY;
assign s_axi_control_ARREADY = s_axi_control.ARREADY;
assign s_axi_control_RVALID = s_axi_control.RVALID;
assign s_axi_control_RDATA = s_axi_control.RDATA;
assign s_axi_control_RRESP = s_axi_control.RRESP;
assign s_axi_control_BVALID = s_axi_control.BVALID;
assign s_axi_control_BRESP = s_axi_control.BRESP;
axi_interface #(.ID_WIDTH(C_M_AXI_PROGMEM_ID_WIDTH),.DATA_WIDTH(C_M_AXI_PROGMEM_DATA_WIDTH),.ADDR_WIDTH(C_M_AXI_PROGMEM_ADDR_WIDTH)) m_axi_progmem();
assign m_axi_progmem.AWREADY = m_axi_progmem_AWREADY;
assign m_axi_progmem.WREADY = m_axi_progmem_WREADY;
assign m_axi_progmem.ARREADY = m_axi_progmem_ARREADY;
assign m_axi_progmem.RVALID = m_axi_progmem_RVALID;
assign m_axi_progmem.RDATA = m_axi_progmem_RDATA;
assign m_axi_progmem.RLAST = m_axi_progmem_RLAST;
assign m_axi_progmem.RID = m_axi_progmem_RID;
assign m_axi_progmem.RRESP = m_axi_progmem_RRESP;
assign m_axi_progmem.BVALID = m_axi_progmem_BVALID;
assign m_axi_progmem.BID = m_axi_progmem_BID;
assign m_axi_progmem.BRESP = m_axi_progmem_BRESP;
assign m_axi_progmem_AWVALID = m_axi_progmem.AWVALID;
assign m_axi_progmem_AWADDR = m_axi_progmem.AWADDR;
assign m_axi_progmem_AWID = m_axi_progmem.AWID;
assign m_axi_progmem_AWLEN = m_axi_progmem.AWLEN;
assign m_axi_progmem_AWSIZE = m_axi_progmem.AWSIZE;
assign m_axi_progmem_AWBURST = m_axi_progmem.AWBURST;
assign m_axi_progmem_AWLOCK = m_axi_progmem.AWLOCK;
assign m_axi_progmem_AWCACHE = m_axi_progmem.AWCACHE;
assign m_axi_progmem_AWPROT = m_axi_progmem.AWPROT;
assign m_axi_progmem_AWQOS = m_axi_progmem.AWQOS;
assign m_axi_progmem_AWREGION = m_axi_progmem.AWREGION;
assign m_axi_progmem_WVALID = m_axi_progmem.WVALID;
assign m_axi_progmem_WDATA = m_axi_progmem.WDATA;
assign m_axi_progmem_WSTRB = m_axi_progmem.WSTRB;
assign m_axi_progmem_WLAST = m_axi_progmem.WLAST;
assign m_axi_progmem_ARVALID = m_axi_progmem.ARVALID;
assign m_axi_progmem_ARADDR = m_axi_progmem.ARADDR;
assign m_axi_progmem_ARID = m_axi_progmem.ARID;
assign m_axi_progmem_ARLEN = m_axi_progmem.ARLEN;
assign m_axi_progmem_ARSIZE = m_axi_progmem.ARSIZE;
assign m_axi_progmem_ARBURST = m_axi_progmem.ARBURST;
assign m_axi_progmem_ARLOCK = m_axi_progmem.ARLOCK;
assign m_axi_progmem_ARCACHE = m_axi_progmem.ARCACHE;
assign m_axi_progmem_ARPROT = m_axi_progmem.ARPROT;
assign m_axi_progmem_ARQOS = m_axi_progmem.ARQOS;
assign m_axi_progmem_ARREGION = m_axi_progmem.ARREGION;
assign m_axi_progmem_RREADY = m_axi_progmem.RREADY;
assign m_axi_progmem_BREADY = m_axi_progmem.BREADY;
axi_interface #(.ID_WIDTH(C_M_AXI_GMEM_ID_WIDTH),.DATA_WIDTH(C_M_AXI_GMEM_DATA_WIDTH),.ADDR_WIDTH(C_M_AXI_GMEM_ADDR_WIDTH)) m_axi_gmem();
assign m_axi_gmem.AWREADY = m_axi_gmem_AWREADY;
assign m_axi_gmem.WREADY = m_axi_gmem_WREADY;
assign m_axi_gmem.ARREADY = m_axi_gmem_ARREADY;
assign m_axi_gmem.RVALID = m_axi_gmem_RVALID;
assign m_axi_gmem.RDATA = m_axi_gmem_RDATA;
assign m_axi_gmem.RLAST = m_axi_gmem_RLAST;
assign m_axi_gmem.RID = m_axi_gmem_RID;
assign m_axi_gmem.RRESP = m_axi_gmem_RRESP;
assign m_axi_gmem.BVALID = m_axi_gmem_BVALID;
assign m_axi_gmem.BID = m_axi_gmem_BID;
assign m_axi_gmem.BRESP = m_axi_gmem_BRESP;
assign m_axi_gmem_AWVALID = m_axi_gmem.AWVALID;
assign m_axi_gmem_AWADDR = m_axi_gmem.AWADDR;
assign m_axi_gmem_AWID = m_axi_gmem.AWID;
assign m_axi_gmem_AWLEN = m_axi_gmem.AWLEN;
assign m_axi_gmem_AWSIZE = m_axi_gmem.AWSIZE;
assign m_axi_gmem_AWBURST = m_axi_gmem.AWBURST;
assign m_axi_gmem_AWLOCK = m_axi_gmem.AWLOCK;
assign m_axi_gmem_AWCACHE = m_axi_gmem.AWCACHE;
assign m_axi_gmem_AWPROT = m_axi_gmem.AWPROT;
assign m_axi_gmem_AWQOS = m_axi_gmem.AWQOS;
assign m_axi_gmem_AWREGION = m_axi_gmem.AWREGION;
assign m_axi_gmem_WVALID = m_axi_gmem.WVALID;
assign m_axi_gmem_WDATA = m_axi_gmem.WDATA;
assign m_axi_gmem_WSTRB = m_axi_gmem.WSTRB;
assign m_axi_gmem_WLAST = m_axi_gmem.WLAST;
assign m_axi_gmem_ARVALID = m_axi_gmem.ARVALID;
assign m_axi_gmem_ARADDR = m_axi_gmem.ARADDR;
assign m_axi_gmem_ARID = m_axi_gmem.ARID;
assign m_axi_gmem_ARLEN = m_axi_gmem.ARLEN;
assign m_axi_gmem_ARSIZE = m_axi_gmem.ARSIZE;
assign m_axi_gmem_ARBURST = m_axi_gmem.ARBURST;
assign m_axi_gmem_ARLOCK = m_axi_gmem.ARLOCK;
assign m_axi_gmem_ARCACHE = m_axi_gmem.ARCACHE;
assign m_axi_gmem_ARPROT = m_axi_gmem.ARPROT;
assign m_axi_gmem_ARQOS = m_axi_gmem.ARQOS;
assign m_axi_gmem_ARREGION = m_axi_gmem.ARREGION;
assign m_axi_gmem_RREADY = m_axi_gmem.RREADY;
assign m_axi_gmem_BREADY = m_axi_gmem.BREADY;
  
wire start;
wire done;
wire idle;
wire [(64 * 2)-1:0] args;
axi_lite_control_slave
  #(.ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH), .DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH), .ARG_WORDS(2*2) )
  ctrl (.ap_clk(ap_clk), .ap_rst_n(ap_rst_n), .axi(s_axi_control),
        .start(start), .done(done), .idle(idle),
        .args(args));
  
wire [63:0] progmem_pointer;
assign progmem_pointer = args[(64 * (0+1))-1:(64 * (0))];
axi_interface #(.ID_WIDTH(1),.DATA_WIDTH(256),.ADDR_WIDTH(64)) m_axi_progmem_buffered();
axi_buffer
  #( .ADDR_WIDTH(64), .DATA_WIDTH(256), .BUFFER_DEPTH(4))
  axi_buffer_progmem_inst ( .ap_clk(ap_clk), .to_master(m_axi_progmem_buffered), .to_slave(m_axi_progmem));
axi_interface #(.ID_WIDTH(1),.DATA_WIDTH(256),.ADDR_WIDTH(64)) m_axi_internal_progmem();
axi_address_offset #(.ID_WIDTH(1),.DATA_WIDTH(256),.ADDR_WIDTH(64))
  m_axi_progmem_offset(.offset(progmem_pointer), .to_slave(m_axi_progmem_buffered), .to_master(m_axi_internal_progmem));
wire [63:0] gmem_pointer;
assign gmem_pointer = args[(64 * (1+1))-1:(64 * (1))];
axi_interface #(.ID_WIDTH(1),.DATA_WIDTH(64),.ADDR_WIDTH(64)) m_axi_gmem_buffered();
axi_buffer
  #( .ADDR_WIDTH(64), .DATA_WIDTH(64), .BUFFER_DEPTH(4))
  axi_buffer_gmem_inst ( .ap_clk(ap_clk), .to_master(m_axi_gmem_buffered), .to_slave(m_axi_gmem));
axi_interface #(.ID_WIDTH(1),.DATA_WIDTH(64),.ADDR_WIDTH(64)) m_axi_internal_gmem();
axi_address_offset #(.ID_WIDTH(1),.DATA_WIDTH(64),.ADDR_WIDTH(64))
  m_axi_gmem_offset(.offset(gmem_pointer), .to_slave(m_axi_gmem_buffered), .to_master(m_axi_internal_gmem));
  
  processor proc(
    .clock(ap_clk), .start(start), .done(done), .idle(idle), .mem_progmem(m_axi_internal_progmem), .mem_gmem(m_axi_internal_gmem)
  );  
endmodule
