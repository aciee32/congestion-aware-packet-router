
`timescale 1ns/1ps

module router_controller_tb;

    reg clk, rst, mode;
    reg [2:0] count0, count1, count2;
    reg empty0, empty1, empty2;
    reg transmit_done;

    wire rd0, rd1, rd2;
    wire [1:0] selected_queue;
    wire valid;

    router_controller uut (
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
        .rd0(rd0),
        .rd1(rd1),
        .rd2(rd2),
        .selected_queue(selected_queue),
        .valid(valid)
    );

    always #5 clk = ~clk;

    task transmit;
        begin
            #2;

            if (valid) begin
                $display("MODE=%b | SELECTED=Q%0d | RD0=%b RD1=%b RD2=%b",
                         mode, selected_queue, rd0, rd1, rd2);

                transmit_done = 1;
                @(posedge clk);
                #1 transmit_done = 0;
            end
            else begin
                $display("MODE=%b | NO QUEUE AVAILABLE", mode);
            end

            #2;
        end
    endtask

    initial begin

        $dumpfile("sim/router_controller.vcd");
        $dumpvars(0, router_controller_tb);

        clk = 0;
        rst = 1;
        mode = 0;
        transmit_done = 0;

        count0 = 0;
        count1 = 0;
        count2 = 0;

        empty0 = 0;
        empty1 = 0;
        empty2 = 0;

        $display("--------------------------------");
        $display("ROUTER CONTROLLER TEST");
        $display("--------------------------------");

        #10;
        rst = 0;

        // Test 1: Round-Robin mode

        $display("\nTEST 1: ROUND ROBIN MODE");

        mode = 0;

        count0 = 3;
        count1 = 1;
        count2 = 2;

        repeat (3) transmit();

        // Test 2: Congestion-Aware mode

        $display("\nTEST 2: CONGESTION AWARE MODE");

        mode = 1;

        repeat (3) transmit();

        // Test 3: Empty queue handling

        $display("\nTEST 3: EMPTY QUEUE");

        empty1 = 1;
        count0 = 3;
        count2 = 1;

        repeat (3) transmit();

        // Test 4: All queues empty

        $display("\nTEST 4: ALL QUEUES EMPTY");

        empty0 = 1;
        empty1 = 1;
        empty2 = 1;

        transmit();

        #10;

        $display("\nROUTER CONTROLLER TEST COMPLETED");

        $finish;

    end

endmodule
