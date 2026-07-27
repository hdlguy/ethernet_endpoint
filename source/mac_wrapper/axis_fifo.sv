//
module axis_fifo #(
    parameter int width = 8,
    parameter int depth = 4096
)(
    //
    input   logic               s_aresetn,
    input   logic               s_aclk,     
    input   logic               s_tvalid,  
    output  logic               s_tready,  
    input   logic[width-1:0]    s_tdata,   
    input   logic               s_tlast,   
    //
    input   logic               m_aclk,     
    output  logic               m_tvalid,  
    input   logic               m_tready,  
    output  logic[width-1:0]    m_tdata,   
    output  logic               m_tlast   
);

    xpm_fifo_axis #(
        .CASCADE_HEIGHT(0),  
        .CDC_SYNC_STAGES(2),  
        .CLOCKING_MODE("independent_clock"), 
        .ECC_MODE("no_ecc"),            
        .EN_SIM_ASSERT_ERR("warning"),  
        .FIFO_DEPTH(depth),             
        .FIFO_MEMORY_TYPE("auto"),      
        .PACKET_FIFO("false"),          
        .PROG_EMPTY_THRESH(10),         
        .PROG_FULL_THRESH(10),          
        .RD_DATA_COUNT_WIDTH(1),        
        .RELATED_CLOCKS(0),             
        .SIM_ASSERT_CHK(0),             
        .TDATA_WIDTH(width),            
        .TDEST_WIDTH(1),                
        .TID_WIDTH(1),                  
        .TUSER_WIDTH(1),                
        .USE_ADV_FEATURES("1000"),      
        .WR_DATA_COUNT_WIDTH(1)         
    ) xpm_fifo_axis_inst (
        //
        .s_aresetn(s_aresetn), 
        //
        .s_aclk(s_aclk), 
        .s_axis_tvalid(s_tvalid),
        .s_axis_tready(s_tready),
        .s_axis_tlast(s_tlast), 
        .s_axis_tdata(s_tdata), 
        .s_axis_tstrb({width/8{1'b1}}), 
        .s_axis_tkeep({width/8{1'b1}}),                                                                                                                                                                                       
        .s_axis_tid(0), 
        .s_axis_tdest(0), 
        .s_axis_tuser(0), 
        //
        .m_aclk(m_aclk),
        .m_axis_tvalid(m_tvalid),
        .m_axis_tready(m_tready), 
        .m_axis_tlast(m_tlast), 
        .m_axis_tdata(m_tdata), 
        .m_axis_tstrb(), 
        .m_axis_tkeep(), 
        .m_axis_tid(),
        .m_axis_tdest(), 
        .m_axis_tuser(),
        //
        .prog_full_axis(),
        .almost_full_axis(), 
        .wr_data_count_axis(), 
        .prog_empty_axis(),
        .almost_empty_axis(),
        .rd_data_count_axis(), 
        //
        .injectsbiterr_axis(0),
        .injectdbiterr_axis(0), 
        .sbiterr_axis(),
        .dbiterr_axis() 
    );
   
endmodule


/*
// XPM_FIFO instantiation template for AXI Stream FIFO configurations
// Refer to the targeted device family architecture libraries guide for XPM_FIFO documentation
// =======================================================================================================================

// Parameter usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Parameter name       | Data type          | Restrictions, if applicable                                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0: No Cascade Height: Enables Vivado Synthesis to choose.                                                           |
// | 1 or more: Vivado Synthesis sets the specified value as Cascade Height.                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | CDC_SYNC_STAGES      | Integer            | Range: 2 - 8. Default value = 2.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the number of synchronization stages on the CDC path.                                                     |
// | Applicable only if CLOCKING_MODE = "independent_clock"                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | CLOCKING_MODE        | String             | Allowed values: common_clock, independent_clock. Default value = common_clock.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies whether the AXI Stream FIFO uses a common clock or independent clocks.                                    |
// |                                                                                                                     |
// |   "common_clock": Common clocking; clock both write and read domain s_aclk                                          |
// |   "independent_clock": Independent clocking; clock write domain with s_aclk and read domain with m_aclk             |
// +---------------------------------------------------------------------------------------------------------------------+
// | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "no_ecc": Disables ECC                                                                                            |
// |   "en_ecc": Enables both ECC Encoder and Decoder                                                                    |
// |                                                                                                                     |
// | NOTE: ECC_MODE must be "no_ecc" if you set FIFO_MEMORY_TYPE to "auto" Violating this might result incorrect behavior.|
// +---------------------------------------------------------------------------------------------------------------------+
// | EN_SIM_ASSERT_ERR    | String             | Default value = warning.                                                |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "warning": Report warning message for FIFO overflow and underflow in simulation.                                  |
// |   "error": Report error message for FIFO overflow and underflow in simulation.                                      |
// |   "fatal": Report fatal message for FIFO overflow and underflow in simulation.                                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_DEPTH           | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the AXI Stream FIFO Write Depth, must be power of two.                                                      |
// | NOTE: The maximum FIFO size (width x depth) has a limit of 150-Megabits.                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed, ultra. Default value = auto.  |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the fifo memory primitive (resource type) to use-                                                         |
// |                                                                                                                     |
// |   "auto": Enables Vivado Synthesis to choose                                                                        |
// |   "block": Block RAM FIFO                                                                                           |
// |   "distributed": Distributed RAM FIFO                                                                               |
// |   "ultra": UltraRAM FIFO                                                                                            |
// |                                                                                                                     |
// | NOTE: Selecting Block RAM or UltraRAM specific features, like ECC or Asymmetry, with FIFO_MEMORY_TYPE set to "auto" might cause a behavior mismatch.|
// +---------------------------------------------------------------------------------------------------------------------+
// | PACKET_FIFO          | String             | Allowed values: false, true. Default value = false.                     |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "true": Enables Packet FIFO mode.                                                                                 |
// |   "false": Disables Packet FIFO mode.                                                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_EMPTY_THRESH    | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the minimum number of read words in the FIFO at or below which prog_empty asserts.                        |
// |                                                                                                                     |
// |   Min_Value = 5                                                                                                     |
// |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
// |                                                                                                                     |
// | NOTE: The default threshold value depends on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value              |
// | changes, verify that the threshold value is within the valid range though the programmable flags are not used.      |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_FULL_THRESH     | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the maximum number of write words in the FIFO at or above which prog_full asserts.                        |
// |                                                                                                                     |
// |   Min_Value = 5 + CDC_SYNC_STAGES                                                                                   |
// |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
// |                                                                                                                     |
// | NOTE: The default threshold value depends on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value              |
// | changes, verify that the threshold value is within the valid range though the programmable flags are not used.      |
// +---------------------------------------------------------------------------------------------------------------------+
// | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of rd_data_count_axis. To reflect the correct value, the width must be log2(FIFO_DEPTH)+1.      |
// +---------------------------------------------------------------------------------------------------------------------+
// | RELATED_CLOCKS       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies whether the s_aclk and m_aclk share the same source with different clock ratios.                          |
// | Applicable only if CLOCKING_MODE = "independent_clock"                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0: Disable simulation message reporting. This does not report messages related to potential misuse.                 |
// | 1: Enable simulation message reporting. This reports messages related to potential misuse.                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | TDATA_WIDTH          | Integer            | Range: 8 - 2048. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata.                                                 |
// | NOTE: The maximum FIFO size (width x depth) has a limit of 150-Megabits.                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | TDEST_WIDTH          | Integer            | Range: 1 - 32. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TDEST port, s_axis_tdest and m_axis_tdest.                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | TID_WIDTH            | Integer            | Range: 1 - 32. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the ID port, s_axis_tid and m_axis_tid.                                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | TUSER_WIDTH          | Integer            | Range: 1 - 4086. Default value = 1.                                     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TUSER port, s_axis_tuser and m_axis_tuser.                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_ADV_FEATURES     | String             | Default value = 1000.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Enables almost_empty_axis, rd_data_count_axis, prog_empty_axis, almost_full_axis, wr_data_count_axis,               |
// | and prog_full_axis sideband signals.                                                                                |
// |                                                                                                                     |
// |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag; Default value of this bit is 0                           |
// |   Setting USE_ADV_FEATURES[2] to 1 enables wr_data_count; Default value of this bit is 0                            |
// |   Setting USE_ADV_FEATURES[3] to 1 enables almost_full flag; Default value of this bit is 0                         |
// |   Setting USE_ADV_FEATURES[9] to 1 enables prog_empty flag; Default value of this bit is 0                          |
// |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count; Default value of this bit is 0                           |
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[13] to 1 enables less than 8 packet size in asynchronous Axi-stream FIFO with packet mode; Default value of this bit is 0|
// +---------------------------------------------------------------------------------------------------------------------+
// | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of wr_data_count_axis. To reflect the correct value, the width must be log2(FIFO_DEPTH)+1.      |
// +---------------------------------------------------------------------------------------------------------------------+

// Port usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | almost_empty_axis| Output    | 1                                     | m_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Almost Empty: When asserted, this signal indicates that the FIFO can perform only one more read before it goes to   |
// | empty.                                                                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | almost_full_axis| Output    | 1                                     | s_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Almost Full: When asserted, this signal indicates that the FIFO can perform only one more write before it is full.  |
// +---------------------------------------------------------------------------------------------------------------------+
// | dbiterr_axis   | Output    | 1                                     | m_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Double Bit Error: Indicates that the ECC decoder detected a double-bit error and data in the FIFO core becomes corrupted.|
// +---------------------------------------------------------------------------------------------------------------------+
// | injectdbiterr_axis| Input     | 1                                     | s_aclk  | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Double Bit Error Injection: Injects a double bit error if using the ECC feature.                                    |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectsbiterr_axis| Input     | 1                                     | s_aclk  | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Single Bit Error Injection: Injects a single bit error if using the ECC feature.                                    |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_aclk         | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Master Interface Clock: This clock samples all signals on master interface on the rising edge.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tdata   | Output    | TDATA_WIDTH                           | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TDATA: The primary payload that provides the data that is passing across the interface. The width                   |
// | of the data payload is an integer number of bytes.                                                                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tdest   | Output    | TDEST_WIDTH                           | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TDEST: Provides routing information for the data stream.                                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tid     | Output    | TID_WIDTH                             | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TID: The data stream identifier that indicates different streams of data.                                           |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tkeep   | Output    | TDATA_WIDTH/8                         | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TKEEP: The byte qualifier that indicates whether the content of the associated byte of TDATA processes              |
// | as part of the data stream. Associated bytes that have the TKEEP byte qualifier deasserted are null bytes           |
// | that you can remove it from the data stream. For a 64-bit DATA, bit 0 corresponds to the least significant byte     |
// | on DATA, and bit 7 corresponds to the most significant byte. For example:                                           |
// |                                                                                                                     |
// |   KEEP[0] = 1b, DATA[7:0] is not a NULL byte                                                                        |
// |   KEEP[7] = 0b, DATA[63:56] is a NULL byte                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tlast   | Output    | 1                                     | m_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TLAST: Indicates the boundary of a packet.                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tready  | Input     | 1                                     | m_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TREADY: Indicates that the slave can accept a transfer in the current cycle.                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tstrb   | Output    | TDATA_WIDTH/8                         | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TSTRB: The byte qualifier that indicates whether the content of the associated byte of TDATA processes              |
// | as a data byte or a position byte. For a 64-bit DATA, bit 0 corresponds to the least significant byte on            |
// | DATA, and bit 0 corresponds to the least significant byte on DATA, and bit 7 corresponds to the most significant    |
// | byte. For example:                                                                                                  |
// |                                                                                                                     |
// |   STROBE[0] = 1b, DATA[7:0] is valid                                                                                |
// |   STROBE[7] = 0b, DATA[63:56] is not valid                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tuser   | Output    | TUSER_WIDTH                           | m_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TUSER: The user-defined sideband information that transmits alongside the data stream.                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | m_axis_tvalid  | Output    | 1                                     | m_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TVALID: Indicates that the master is driving a valid transfer.                                                      |
// |                                                                                                                     |
// |   A transfer takes place when both TVALID and TREADY assert                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | prog_empty_axis| Output    | 1                                     | m_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Programmable Empty: This signal asserts when the number of words in the FIFO is less than or equal                  |
// | to the programmable empty threshold value.                                                                          |
// | It deasserts when the number of words in the FIFO exceeds the programmable empty threshold value.                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | prog_full_axis | Output    | 1                                     | s_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Programmable Full: This signal asserts when the number of words in the FIFO is greater than or equal                |
// | to the programmable full threshold value.                                                                           |
// | It deasserts when the number of words in the FIFO is less than the programmable full threshold value.               |
// +---------------------------------------------------------------------------------------------------------------------+
// | rd_data_count_axis| Output    | RD_DATA_COUNT_WIDTH                   | m_aclk  | NA          | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Data Count: This bus indicates the number of words available for reading in the FIFO.                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_aclk         | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Slave Interface Clock: This clock samples all signals on slave interface on the rising edge.                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_aresetn      | Input     | 1                                     | NA      | Active-low  | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Active-Low asynchronous reset.                                                                                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tdata   | Input     | TDATA_WIDTH                           | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TDATA: The primary payload that provides the data that is passing across the interface. The width                   |
// | of the data payload is an integer number of bytes.                                                                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tdest   | Input     | TDEST_WIDTH                           | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TDEST: Provides routing information for the data stream.                                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tid     | Input     | TID_WIDTH                             | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TID: The data stream identifier that indicates different streams of data.                                           |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tkeep   | Input     | TDATA_WIDTH/8                         | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TKEEP: The byte qualifier that indicates whether the content of the associated byte of TDATA processes              |
// | as part of the data stream. Associated bytes that have the TKEEP byte qualifier deasserted are null bytes           |
// | that you can remove it from the data stream. For a 64-bit DATA, bit 0 corresponds to the least significant byte     |
// | on DATA, and bit 7 corresponds to the most significant byte. For example:                                           |
// |                                                                                                                     |
// |   KEEP[0] = 1b, DATA[7:0] is not a NULL byte                                                                        |
// |   KEEP[7] = 0b, DATA[63:56] is a NULL byte                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tlast   | Input     | 1                                     | s_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TLAST: Indicates the boundary of a packet.                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tready  | Output    | 1                                     | s_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TREADY: Indicates that the slave can accept a transfer in the current cycle.                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tstrb   | Input     | TDATA_WIDTH/8                         | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TSTRB: The byte qualifier that indicates whether the content of the associated byte of TDATA processes              |
// | as a data byte or a position byte. For a 64-bit DATA, bit 0 corresponds to the least significant byte on            |
// | DATA, and bit 0 corresponds to the least significant byte on DATA, and bit 7 corresponds to the most significant    |
// | byte. For example:                                                                                                  |
// |                                                                                                                     |
// |   STROBE[0] = 1b, DATA[7:0] is valid                                                                                |
// |   STROBE[7] = 0b, DATA[63:56] is not valid                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tuser   | Input     | TUSER_WIDTH                           | s_aclk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TUSER: The user-defined sideband information that transmits alongside the data stream.                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | s_axis_tvalid  | Input     | 1                                     | s_aclk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | TVALID: Indicates that the master is driving a valid transfer.                                                      |
// |                                                                                                                     |
// |   A transfer takes place when both TVALID and TREADY assert.                                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | sbiterr_axis   | Output    | 1                                     | m_aclk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Single Bit Error: Indicates that the ECC decoder detected and fixed a single-bit error.                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_data_count_axis| Output    | WR_DATA_COUNT_WIDTH                   | s_aclk  | NA          | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Data Count: This bus indicates the number of words written into the FIFO.                                     |
// +---------------------------------------------------------------------------------------------------------------------+


// xpm_fifo_axis : In order to incorporate this function into the design,
//    Verilog    : the following instance declaration needs to be placed
//   instance    : in the body of the design code.  The instance name
//  declaration  : (xpm_fifo_axis_inst) and/or the port declarations within the
//     code      : parenthesis may be changed to properly reference and
//               : connect this function to the design.  All inputs
//               : and outputs must be connected.

//  Please reference the appropriate libraries guide for additional information on the XPM modules.

//  <-----Cut code below this line---->

   // xpm_fifo_axis: AXI Stream FIFO
   // Xilinx Parameterized Macro, version 2026.1

   xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .EN_SIM_ASSERT_ERR("warning"),  // String
      .FIFO_DEPTH(2048),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(10),         // DECIMAL
      .PROG_FULL_THRESH(10),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(32),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("1000"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
   )
   xpm_fifo_axis_inst (
      .s_aresetn(s_aresetn), // 1-bit input: Active-Low asynchronous reset.
      .s_aclk(s_aclk), // 1-bit input: Slave Interface Clock: This clock samples all signals on slave interface on the rising
                                               // edge.

      .m_aclk(m_aclk), // 1-bit input: Master Interface Clock: This clock samples all signals on master interface on the
                                               // rising edge.

      .s_axis_tvalid(s_axis_tvalid), // 1-bit input: TVALID: Indicates that the master is driving a valid transfer. A transfer takes place
                                               // when both TVALID and TREADY assert.

      .s_axis_tready(s_axis_tready), // 1-bit output: TREADY: Indicates that the slave can accept a transfer in the current cycle.
      .s_axis_tlast(s_axis_tlast), // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tdata(s_axis_tdata), // TDATA_WIDTH-bit input: TDATA: The primary payload that provides the data that is passing across the
                                               // interface. The width of the data payload is an integer number of bytes.

      .s_axis_tstrb(s_axis_tstrb), // TDATA_WIDTH/8-bit input: TSTRB: The byte qualifier that indicates whether the content of the
                                               // associated byte of TDATA processes as a data byte or a position byte. For a 64-bit DATA, bit 0
                                               // corresponds to the least significant byte on DATA, and bit 0 corresponds to the least significant
                                               // byte on DATA, and bit 7 corresponds to the most significant byte. For example: STROBE[0] = 1b,
                                               // DATA[7:0] is valid STROBE[7] = 0b, DATA[63:56] is not valid

      .s_axis_tkeep(s_axis_tkeep), // TDATA_WIDTH/8-bit input: TKEEP: The byte qualifier that indicates whether the content of the
                                               // associated byte of TDATA processes as part of the data stream. Associated bytes that have the TKEEP
                                               // byte qualifier deasserted are null bytes that you can remove it from the data stream. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on DATA, and bit 7 corresponds to the most
                                               // significant byte. For example: KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b, DATA[63:56]
                                               // is a NULL byte

      .s_axis_tid(s_axis_tid), // TID_WIDTH-bit input: TID: The data stream identifier that indicates different streams of data.
      .s_axis_tdest(s_axis_tdest), // TDEST_WIDTH-bit input: TDEST: Provides routing information for the data stream.
      .s_axis_tuser(s_axis_tuser), // TUSER_WIDTH-bit input: TUSER: The user-defined sideband information that transmits alongside the
                                               // data stream.

      .m_axis_tvalid(m_axis_tvalid), // 1-bit output: TVALID: Indicates that the master is driving a valid transfer. A transfer takes place
                                               // when both TVALID and TREADY assert

      .m_axis_tready(m_axis_tready), // 1-bit input: TREADY: Indicates that the slave can accept a transfer in the current cycle.
      .m_axis_tlast(m_axis_tlast), // 1-bit output: TLAST: Indicates the boundary of a packet.
      .m_axis_tdata(m_axis_tdata), // TDATA_WIDTH-bit output: TDATA: The primary payload that provides the data that is passing across
                                               // the interface. The width of the data payload is an integer number of bytes.

      .m_axis_tstrb(m_axis_tstrb), // TDATA_WIDTH/8-bit output: TSTRB: The byte qualifier that indicates whether the content of the
                                               // associated byte of TDATA processes as a data byte or a position byte. For a 64-bit DATA, bit 0
                                               // corresponds to the least significant byte on DATA, and bit 0 corresponds to the least significant
                                               // byte on DATA, and bit 7 corresponds to the most significant byte. For example: STROBE[0] = 1b,
                                               // DATA[7:0] is valid STROBE[7] = 0b, DATA[63:56] is not valid

      .m_axis_tkeep(m_axis_tkeep), // TDATA_WIDTH/8-bit output: TKEEP: The byte qualifier that indicates whether the content of the
                                               // associated byte of TDATA processes as part of the data stream. Associated bytes that have the TKEEP
                                               // byte qualifier deasserted are null bytes that you can remove it from the data stream. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on DATA, and bit 7 corresponds to the most
                                               // significant byte. For example: KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b, DATA[63:56]
                                               // is a NULL byte

      .m_axis_tid(m_axis_tid), // TID_WIDTH-bit output: TID: The data stream identifier that indicates different streams of data.
      .m_axis_tdest(m_axis_tdest), // TDEST_WIDTH-bit output: TDEST: Provides routing information for the data stream.
      .m_axis_tuser(m_axis_tuser), // TUSER_WIDTH-bit output: TUSER: The user-defined sideband information that transmits alongside the
                                               // data stream.

      .prog_full_axis(prog_full_axis), // 1-bit output: Programmable Full: This signal asserts when the number of words in the FIFO is
                                               // greater than or equal to the programmable full threshold value. It deasserts when the number of
                                               // words in the FIFO is less than the programmable full threshold value.

      .almost_full_axis(almost_full_axis), // 1-bit output: Almost Full: When asserted, this signal indicates that the FIFO can perform only one
                                               // more write before it is full.

      .wr_data_count_axis(wr_data_count_axis), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates the number of words written
                                               // into the FIFO.

      .prog_empty_axis(prog_empty_axis), // 1-bit output: Programmable Empty: This signal asserts when the number of words in the FIFO is less
                                               // than or equal to the programmable empty threshold value. It deasserts when the number of words in
                                               // the FIFO exceeds the programmable empty threshold value.

      .almost_empty_axis(almost_empty_axis), // 1-bit output: Almost Empty: When asserted, this signal indicates that the FIFO can perform only one
                                               // more read before it goes to empty.

      .rd_data_count_axis(rd_data_count_axis), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the number of words available
                                               // for reading in the FIFO.

      .injectsbiterr_axis(injectsbiterr_axis), // 1-bit input: Single Bit Error Injection: Injects a single bit error if using the ECC feature.
      .injectdbiterr_axis(injectdbiterr_axis), // 1-bit input: Double Bit Error Injection: Injects a double bit error if using the ECC feature.
      .sbiterr_axis(sbiterr_axis), // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected and fixed a single-bit
                                               // error.

      .dbiterr_axis(dbiterr_axis) // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected a double-bit error and data
                                               // in the FIFO core becomes corrupted.

   );

   // End of xpm_fifo_axis_inst instantiation
				
				
*/