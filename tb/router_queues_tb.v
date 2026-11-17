
`timescale 1ns/1ps

module router_queues_tb;

reg clk, rst, wr_en;
reg [15:0] packet_in;

reg rd0, rd1, rd2;

wire [15:0] dout0, dout1, dout2;

wire full0, full1, full2;
wire empty0, empty1, empty2;

wire [2:0] count0, count1, count2;

wire invalid;

// Instantiate router queues
router_queues uut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .packet_in(packet_in),

    .rd0(rd0),
    .rd1(rd1),
    .rd2(rd2),

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

    .invalid(invalid)
);

always #5 clk = ~clk;

task write_packet(input [15:0] data);
begin
    @(negedge clk);
    packet_in = data;
    wr_en = 1;

    @(negedge clk);
    wr_en = 0;

    #1;
    $display("WRITE %h | C0=%0d C1=%0d C2=%0d",
             data, count0, count1, count2);
end
endtask

initial begin

    $dumpfile("sim/router_queues.vcd");
    $dumpvars(0, router_queues_tb);

    clk = 0;
    rst = 1;
    wr_en = 0;
    packet_in = 0;

    rd0 = 0;
    rd1 = 0;
    rd2 = 0;

    $display("--------------------------------");
    $display("THREE FIFO ROUTER TEST STARTED");
    $display("--------------------------------");

    #12;
    rst = 0;

    // Destination 00 -> FIFO 0
    write_packet(16'h1234);

    // Destination 01 -> FIFO 1
    write_packet(16'h5678);

    // Destination 10 -> FIFO 2
    write_packet(16'h9234);

    // Another packet for FIFO 0
    write_packet(16'h2345);

    $display("--------------------------------");
    $display("QUEUE COUNTS:");
    $display("FIFO 0 = %0d", count0);
    $display("FIFO 1 = %0d", count1);
    $display("FIFO 2 = %0d", count2);

    // Invalid destination 11
    write_packet(16'hC123);

    $display("INVALID FLAG = %b", invalid);

    #10;

    $display("--------------------------------");
    $display("THREE FIFO ROUTER TEST COMPLETED");
    $display("--------------------------------");

    $finish;

end

endmodule
