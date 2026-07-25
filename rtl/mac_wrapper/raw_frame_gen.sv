//
module raw_frame_gen #(
    parameter int Lframe = 64 // length of frame
) (
    input   logic       reset,
    input   logic       clk,
    output  logic       tvalid,
    input   logic       tready,
    output  logic[7:0]  tdata,
    output  logic       tlast
);

    logic tvalid_int=0;
    logic[7:0]  tdata_int=0;
    always_ff @(posedge clk) begin
        
        if (reset) begin
            tvalid_int <= 0;
            tdata_int <= 0;
        end else begin            
            tvalid_int <= 1;
            if ((tvalid==1) && (tready==1)) tdata_int <= tdata_int + 1;
        end
        
    end
    
    assign tvalid = tvalid_int;
    assign tdata  = tdata_int;
    
    assign tlast  = (tdata%Lframe == (Lframe-1)) ? 1'b1 : 1'b0;

endmodule
