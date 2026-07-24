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

    always_ff @(posedge clk) begin
        
        if (reset) begin
            tvalid <= 0;
            tdata <= 0;
        end else begin            
            tvalid <= 1;
            if ((tvalid==1) && (tready==1)) tdata <= tdata + 1;
        end
        
    end
    
    assign tlast  = (tdata%Lframe == (Lframe-1)) ? 1'b1 : 1'b0;

endmodule
