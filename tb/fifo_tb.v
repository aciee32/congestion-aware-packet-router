
`timescale 1ns/1ps

module fifo_tb;

    reg clk;
    reg rst;

    reg wr_en;
    reg rd_en;

    reg [15:0] din;

    wire [15:0] dout;
    wire full;
    wire empty;
    wire [2:0] count;

    // Instantiate FIFO
    fifo uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .count(count)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Task to write one packet
    task push;
        input [15:0] packet;
        begin
            @(negedge clk);
            din = packet;
            wr_en = 1;

            @(posedge clk);
            #1;

            @(negedge clk);
            wr_en = 0;
            #1;

            $display("WRITE: %h | COUNT: %d | FULL: %b",
                     packet, count, full);
        end
    endtask

    // Task to read and verify one packet
    task pop;
        input [15:0] expected_packet;
        begin
            @(negedge clk);
            rd_en = 1;
            #1;

            if (dout !== expected_packet) begin
                $display("ERROR: Expected %h, got %h",
                         expected_packet, dout);
                $finish;
            end

            @(posedge clk);
            #1;

            @(negedge clk);
            rd_en = 0;
            #1;

            $display("READ : %h | COUNT: %d | EMPTY: %b",
                     expected_packet, count, empty);
        end
    endtask

    initial begin

        $dumpfile("sim/fifo.vcd");
        $dumpvars(0, fifo_tb);

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 16'd0;

        $display("--------------------------------");
        $display("       FIFO TEST STARTED");
        $display("--------------------------------");

        // Reset
        repeat(2) @(posedge clk);
        #1;
        rst = 0;

        if (count !== 0 || empty !== 1) begin
            $display("ERROR: Reset failed");
            $finish;
        end

        $display("RESET PASSED");

        // Write four packets
        push(16'h1111);
        push(16'h2222);
        push(16'h3333);
        push(16'h4444);

        if (full !== 1 || count !== 4) begin
            $display("ERROR: FIFO full test failed");
            $finish;
        end

        $display("FULL CONDITION PASSED");

        // Attempt an extra write while full
        push(16'hAAAA);

        if (count !== 4) begin
            $display("ERROR: FIFO overflow protection failed");
            $finish;
        end

        $display("OVERFLOW PROTECTION PASSED");

        // Simultaneous read and write while full
        @(negedge clk);
        rd_en = 1;
        wr_en = 1;
        din = 16'h5555;
        #1;

        if (dout !== 16'h1111) begin
            $display("ERROR: Simultaneous operation read mismatch");
            $finish;
        end

        @(posedge clk);
        #1;

        if (count !== 4) begin
            $display("ERROR: Simultaneous operation count failed");
            $finish;
        end

        @(negedge clk);
        rd_en = 0;
        wr_en = 0;
        #1;

        $display("SIMULTANEOUS READ/WRITE PASSED");

        // Read remaining packets in FIFO order
        pop(16'h2222);
        pop(16'h3333);
        pop(16'h4444);
        pop(16'h5555);

        if (empty !== 1 || count !== 0) begin
            $display("ERROR: FIFO empty test failed");
            $finish;
        end

        $display("EMPTY CONDITION PASSED");

        // Attempt to read from an empty FIFO
        @(negedge clk);
        rd_en = 1;

        @(posedge clk);
        #1;

        if (count !== 0) begin
            $display("ERROR: Empty read protection failed");
            $finish;
        end

        @(negedge clk);
        rd_en = 0;

        $display("EMPTY READ PROTECTION PASSED");

        $display("--------------------------------");
        $display("       ALL TESTS PASSED");
        $display("--------------------------------");

        #10;
        $finish;

    end

endmodule
