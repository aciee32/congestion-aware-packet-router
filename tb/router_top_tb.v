
`timescale 1ns/1ps

module router_top_tb;

    reg clk, rst, mode;
    reg in_valid, out_ready;
    reg [15:0] packet_in;

    wire in_ready;
    wire invalid_packet;
    wire out_valid;
    wire [15:0] packet_out;

    wire [2:0] count0, count1, count2;

    router_top uut (
        .clk(clk),
        .rst(rst),
        .mode(mode),

        .in_valid(in_valid),
        .packet_in(packet_in),
        .in_ready(in_ready),
        .invalid_packet(invalid_packet),

        .out_ready(out_ready),
        .out_valid(out_valid),
        .packet_out(packet_out),

        .count0(count0),
        .count1(count1),
        .count2(count2)
    );

    always #5 clk = ~clk;

    // Send one packet

    task send_packet;
        input [15:0] data;
        begin
            @(negedge clk);

            packet_in = data;
            in_valid = 1;

            #1;

            while (!in_ready)
                @(negedge clk);

            @(posedge clk);
            #1;

            $display("PACKET IN: %h | COUNTS: %0d %0d %0d",
                     data, count0, count1, count2);

            in_valid = 0;
            packet_in = 0;
        end
    endtask

    // Transmit a specified number of packets

    task drain_packets;
        input integer number;
        integer i;
        begin
            @(negedge clk);
            out_ready = 1;

            for (i = 0; i < number; i = i + 1) begin
                #1;

                if (out_valid)
                    $display("PACKET OUT: %h | COUNTS: %0d %0d %0d",
                             packet_out, count0, count1, count2);
                else
                    $display("NO PACKET AVAILABLE");

                @(posedge clk);
                #1;
                @(negedge clk);
            end

            out_ready = 0;
        end
    endtask

    initial begin

        $dumpfile("sim/router_top.vcd");
        $dumpvars(0, router_top_tb);

        clk = 0;
        rst = 1;
        mode = 0;

        in_valid = 0;
        out_ready = 0;
        packet_in = 0;

        $display("--------------------------------");
        $display("COMPLETE PACKET ROUTER TEST");
        $display("--------------------------------");

        #12;
        rst = 0;

        // TEST 1: ROUND ROBIN

        $display("\nTEST 1: ROUND ROBIN");

        mode = 0;

        send_packet(16'h0123);
        send_packet(16'h4567);
        send_packet(16'h9234);

        $display("STARTING ROUND ROBIN TRANSMISSION");

        drain_packets(3);

        // TEST 2: CONGESTION AWARE

        $display("\nTEST 2: CONGESTION AWARE");

        mode = 1;

        send_packet(16'h0121);
        send_packet(16'h0122);
        send_packet(16'h0123);

        send_packet(16'h4561);

        send_packet(16'h9231);
        send_packet(16'h9232);

        $display("STARTING CONGESTION AWARE TRANSMISSION");

        drain_packets(6);

        // TEST 3: INVALID DESTINATION

        $display("\nTEST 3: INVALID DESTINATION");

        @(negedge clk);
        packet_in = 16'hC123;
        in_valid = 1;
        #1;

        $display("INVALID FLAG = %b", invalid_packet);

        @(posedge clk);
        #1;

        in_valid = 0;
        packet_in = 0;

        $display("COUNTS AFTER INVALID PACKET: %0d %0d %0d",
                 count0, count1, count2);

        #10;

        $display("\nCOMPLETE ROUTER TEST FINISHED");

        $finish;

    end

endmodule
