// double data rate mux to convert gmii to rgmii.
`timescale 1ns/1ps;

module rgmii_demux (
    input   logic           rgmii_clk,
    input   logic           rgmii_ctl,
    input   logic[3:0]      rgmii_d,
    output  logic           gmii_clk,
    output  logic           gmii_en=1'b0,
    output  logic[7:0]      gmii_d=8'h00
);

    assign #1ns gmii_clk = rgmii_clk;
    
    logic[3:0] rgmii_d_f=0;
    logic rgmii_ctl_f=0;
    always_ff @(negedge gmii_clk) begin
        rgmii_d_f <= rgmii_d;
        rgmii_ctl_f <= rgmii_ctl;
    end

    logic[3:0] rgmii_d_r=0;
    logic rgmii_ctl_r=0;
    always_ff @(posedge gmii_clk) begin
        rgmii_d_r <= rgmii_d;
        rgmii_ctl_r <= rgmii_ctl;

        gmii_d <= {rgmii_d_f, rgmii_d_r};
        gmii_en <= rgmii_ctl_r;
    end

endmodule


