
`timescale 1ns/1ps

module decoder_tb;

reg [1:0] dest;

wire q0_sel, q1_sel, q2_sel, invalid;

// Instantiate decoder
destination_decoder uut (
    .dest(dest),
    .q0_sel(q0_sel),
    .q1_sel(q1_sel),
    .q2_sel(q2_sel),
    .invalid(invalid)
);

initial begin

    $dumpfile("sim/decoder.vcd");
    $dumpvars(0, decoder_tb);

    $display("--------------------------------");
    $display("DESTINATION DECODER TEST STARTED");
    $display("--------------------------------");

    dest = 2'b00;
    #10;
    $display("DEST = %b | Q0=%b Q1=%b Q2=%b INVALID=%b",
              dest, q0_sel, q1_sel, q2_sel, invalid);

    dest = 2'b01;
    #10;
    $display("DEST = %b | Q0=%b Q1=%b Q2=%b INVALID=%b",
              dest, q0_sel, q1_sel, q2_sel, invalid);

    dest = 2'b10;
    #10;
    $display("DEST = %b | Q0=%b Q1=%b Q2=%b INVALID=%b",
              dest, q0_sel, q1_sel, q2_sel, invalid);

    dest = 2'b11;
    #10;
    $display("DEST = %b | Q0=%b Q1=%b Q2=%b INVALID=%b",
              dest, q0_sel, q1_sel, q2_sel, invalid);

    $display("--------------------------------");
    $display("ALL DECODER TESTS COMPLETED");
    $display("--------------------------------");

    $finish;

end

endmodule
