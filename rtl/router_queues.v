
module router_queues (

    input wire clk,
    input wire rst,

    input wire wr_en,
    input wire [15:0] packet_in,

    input wire rd0,
    input wire rd1,
    input wire rd2,

    output wire [15:0] dout0,
    output wire [15:0] dout1,
    output wire [15:0] dout2,

    output wire full0,
    output wire full1,
    output wire full2,

    output wire empty0,
    output wire empty1,
    output wire empty2,

    output wire [2:0] count0,
    output wire [2:0] count1,
    output wire [2:0] count2,

    output wire invalid
);

wire q0_sel, q1_sel, q2_sel;

wire wr0, wr1, wr2;

// Destination decoder
destination_decoder decoder (
    .dest(packet_in[15:14]),
    .q0_sel(q0_sel),
    .q1_sel(q1_sel),
    .q2_sel(q2_sel),
    .invalid(invalid)
);

// Write enable generation
assign wr0 = wr_en && q0_sel && !full0;
assign wr1 = wr_en && q1_sel && !full1;
assign wr2 = wr_en && q2_sel && !full2;

// FIFO 0
fifo fifo0 (
    .clk(clk),
    .rst(rst),
    .wr_en(wr0),
    .rd_en(rd0),
    .din(packet_in),
    .dout(dout0),
    .full(full0),
    .empty(empty0),
    .count(count0)
);

// FIFO 1
fifo fifo1 (
    .clk(clk),
    .rst(rst),
    .wr_en(wr1),
    .rd_en(rd1),
    .din(packet_in),
    .dout(dout1),
    .full(full1),
    .empty(empty1),
    .count(count1)
);

// FIFO 2
fifo fifo2 (
    .clk(clk),
    .rst(rst),
    .wr_en(wr2),
    .rd_en(rd2),
    .din(packet_in),
    .dout(dout2),
    .full(full2),
    .empty(empty2),
    .count(count2)
);

endmodule
