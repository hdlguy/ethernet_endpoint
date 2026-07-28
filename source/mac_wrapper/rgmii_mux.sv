// double data rate mux to convert gmii to rgmii.
module rgmii_mux (
    input   logic           gmii_clk,
    input   logic           gmii_en,
    input   logic           gmii_er,
    input   logic[7:0]      gmii_d,
    output  logic           rgmii_clk,
    output  logic           rgmii_ctl,
    output  logic[3:0]      rgmii_d
);


    logic gmii_en_q, gmii_er_q;
    logic[7:0] gmii_d_q;
    always_ff @(posedge gmii_clk) begin
        gmii_en_q <= gmii_en;
        gmii_er_q <= gmii_er;
        gmii_d_q  <= gmii_d;
    end

    assign #1 rgmii_clk = gmii_clk; // delay the clock
    always_comb begin
        if (gmii_clk == 1'b1) begin
            rgmii_ctl = gmii_en_q;
            rgmii_d = gmii_d_q[3:0];
        end else begin
            rgmii_ctl = gmii_en_q | gmii_er_q;
            rgmii_d = gmii_d_q[7:4];
        end
    end

endmodule
