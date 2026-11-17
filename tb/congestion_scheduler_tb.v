
`timescale 1ns/1ps

module congestion_scheduler_tb;

    reg clk, rst;
    reg [2:0] count0, count1, count2;
    reg empty0, empty1, empty2;
    reg transmit_done;

    wire rd0, rd1, rd2;
    wire [1:0] selected_queue;
    wire valid;

    congestion_scheduler uut (
        .clk(clk),
        .rst(rst),
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
                $display("Q0=%0d Q1=%0d Q2=%0d | SELECTED=Q%0d",
                         count0, count1, count2, selected_queue);

                transmit_done = 1;
                @(posedge clk);
                #1 transmit_done = 0;
            end
            else begin
                $display("NO QUEUE AVAILABLE");
            end
            #2;
        end
    endtask

    initial begin

        $dumpfile("sim/congestion_scheduler.vcd");
        $dumpvars(0, congestion_scheduler_tb);

        clk = 0;
        rst = 1;
        transmit_done = 0;

        count0 = 0;
        count1 = 0;
        count2 = 0;

        empty0 = 1;
        empty1 = 1;
        empty2 = 1;

        $display("--------------------------------");
        $display("CONGESTION AWARE SCHEDULER TEST");
        $display("--------------------------------");

        #10;
        rst = 0;

        // Test 1: Different occupancies
        $display("\nTEST 1: DIFFERENT OCCUPANCIES");

        empty0 = 0;
        empty1 = 0;
        empty2 = 0;

        count0 = 3;
        count1 = 1;
        count2 = 2;

        transmit();

        // Test 2: Equal occupancy (tie-breaking)
        $display("\nTEST 2: EQUAL OCCUPANCY");

        count0 = 2;
        count1 = 2;
        count2 = 3;

        repeat (4) transmit();

        // Test 3: Skip empty queue
        $display("\nTEST 3: EMPTY QUEUE");

        empty0 = 1;
        count1 = 3;
        count2 = 1;

        transmit();

        // Test 4: Only one queue available
        $display("\nTEST 4: ONLY QUEUE 0 AVAILABLE");

        empty0 = 0;
        empty1 = 1;
        empty2 = 1;

        count0 = 2;

        repeat (3) transmit();

        // Test 5: All queues empty
        $display("\nTEST 5: ALL QUEUES EMPTY");

        empty0 = 1;
        empty1 = 1;
        empty2 = 1;

        transmit();

        #10;
        $display("\nCONGESTION SCHEDULER TEST COMPLETED");

        $finish;

    end

endmodule
