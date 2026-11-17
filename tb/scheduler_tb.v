
`timescale 1ns/1ps

module scheduler_tb;

    reg clk, rst;
    reg empty0, empty1, empty2;
    reg transmit_done;

    wire rd0, rd1, rd2;
    wire [1:0] selected_queue;
    wire valid;

    round_robin_arbiter uut (
        .clk(clk),
        .rst(rst),
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
                $display("Selected Queue = %0d | RD0=%b RD1=%b RD2=%b",
                         selected_queue, rd0, rd1, rd2);
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
        $dumpfile("sim/scheduler.vcd");
        $dumpvars(0, scheduler_tb);

        clk = 0;
        rst = 1;
        empty0 = 1;
        empty1 = 1;
        empty2 = 1;
        transmit_done = 0;

        $display("--------------------------------");
        $display("ROUND ROBIN SCHEDULER TEST");
        $display("--------------------------------");

        #10;
        rst = 0;

        // All queues have packets
        empty0 = 0;
        empty1 = 0;
        empty2 = 0;

        $display("\nALL QUEUES NON-EMPTY");
        repeat (6) transmit();

        // Queue 1 becomes empty
        empty1 = 1;
        $display("\nQUEUE 1 EMPTY");
        repeat (4) transmit();

        // Only queue 2 has packets
        empty0 = 1;
        empty2 = 0;
        $display("\nONLY QUEUE 2 NON-EMPTY");
        repeat (3) transmit();

        // All queues empty
        empty0 = 1;
        empty1 = 1;
        empty2 = 1;
        $display("\nALL QUEUES EMPTY");
        transmit();

        #10;
        $display("\nROUND ROBIN TEST COMPLETED");
        $finish;
    end

endmodule
