
module router_top (
    input wire clk,
    input wire rst,

    input wire mode,

    input wire in_valid,
    input wire [15:0] packet_in,
    output wire in_ready,
    output wire invalid_packet,

    input wire out_ready,
    output wire out_valid,
    output reg [15:0] packet_out,

    output wire [2:0] count0,
    output wire [2:0] count1,
    output wire [2:0] count2
);

    wire full0, full1, full2;
    wire empty0, empty1, empty2;

    wire [15:0] dout0, dout1, dout2;

    wire sched_rd0, sched_rd1, sched_rd2;
    wire fifo_rd0, fifo_rd1, fifo_rd2;

    wire [1:0] selected_queue;
    wire sched_valid;
    wire transmit_done;

    wire invalid_dest;

    // Input destination and FIFO capacity check

    assign invalid_dest = (packet_in[15:14] == 2'b11);

    assign in_ready =
        invalid_dest ? 1'b1 :
        (packet_in[15:14] == 2'b00) ? !full0 :
        (packet_in[15:14] == 2'b01) ? !full1 :
        !full2;

    assign invalid_packet = in_valid && invalid_dest;

    // Write valid packets into the selected FIFO

    router_queues queues (
        .clk(clk),
        .rst(rst),
        .wr_en(in_valid && in_ready && !invalid_dest),
        .packet_in(packet_in),

        .rd0(fifo_rd0),
        .rd1(fifo_rd1),
        .rd2(fifo_rd2),

        .dout0(dout0),
        .dout1(dout1),
        .dout2(dout2),

        .full0(full0),
        .full1(full1),
        .full2(full2),

        .empty0(empty0),
        .empty1(empty1),
        .empty2(empty2),

        .count0(count0),
        .count1(count1),
        .count2(count2),

        .invalid()
    );

    // Select scheduling algorithm

    router_controller controller (
        .clk(clk),
        .rst(rst),
        .mode(mode),

        .count0(count0),
        .count1(count1),
        .count2(count2),

        .empty0(empty0),
        .empty1(empty1),
        .empty2(empty2),

        .transmit_done(transmit_done),

        .rd0(sched_rd0),
        .rd1(sched_rd1),
        .rd2(sched_rd2),

        .selected_queue(selected_queue),
        .valid(sched_valid)
    );

    // Remove packet only after output handshake

    assign out_valid = sched_valid;
    assign transmit_done = out_valid && out_ready;

    assign fifo_rd0 = sched_rd0 && out_ready;
    assign fifo_rd1 = sched_rd1 && out_ready;
    assign fifo_rd2 = sched_rd2 && out_ready;

    // Select packet data from the chosen FIFO

    always @(*) begin
        packet_out = 16'b0;

        if (sched_valid) begin
            case (selected_queue)
                2'd0: packet_out = dout0;
                2'd1: packet_out = dout1;
                2'd2: packet_out = dout2;
                default: packet_out = 16'b0;
            endcase
        end
    end

endmodule
