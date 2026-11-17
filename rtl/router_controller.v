
module router_controller (
    input wire clk,
    input wire rst,
    input wire mode,

    input wire [2:0] count0,
    input wire [2:0] count1,
    input wire [2:0] count2,

    input wire empty0,
    input wire empty1,
    input wire empty2,

    input wire transmit_done,

    output wire rd0,
    output wire rd1,
    output wire rd2,

    output wire [1:0] selected_queue,
    output wire valid
);

    wire rr_rd0, rr_rd1, rr_rd2;
    wire ca_rd0, ca_rd1, ca_rd2;

    wire [1:0] rr_selected;
    wire [1:0] ca_selected;

    wire rr_valid, ca_valid;

    // Round-Robin Scheduler

    round_robin_arbiter rr_scheduler (
        .clk(clk),
        .rst(rst),
        .empty0(empty0),
        .empty1(empty1),
        .empty2(empty2),
        .transmit_done(transmit_done && !mode),
        .rd0(rr_rd0),
        .rd1(rr_rd1),
        .rd2(rr_rd2),
        .selected_queue(rr_selected),
        .valid(rr_valid)
    );

    // Congestion-Aware Scheduler

    congestion_scheduler ca_scheduler (
        .clk(clk),
        .rst(rst),
        .count0(count0),
        .count1(count1),
        .count2(count2),
        .empty0(empty0),
        .empty1(empty1),
        .empty2(empty2),
        .transmit_done(transmit_done && mode),
        .rd0(ca_rd0),
        .rd1(ca_rd1),
        .rd2(ca_rd2),
        .selected_queue(ca_selected),
        .valid(ca_valid)
    );

    // Select the active scheduler

    assign rd0 = mode ? ca_rd0 : rr_rd0;
    assign rd1 = mode ? ca_rd1 : rr_rd1;
    assign rd2 = mode ? ca_rd2 : rr_rd2;

    assign selected_queue = mode ? ca_selected : rr_selected;
    assign valid = mode ? ca_valid : rr_valid;

endmodule
