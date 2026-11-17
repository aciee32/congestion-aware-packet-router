
`timescale 1ns/1ps

module performance_tb;

    reg clk, rst, mode;
    reg in_valid, out_ready;
    reg [15:0] packet_in;

    wire in_ready;
    wire invalid_packet;
    wire out_valid;
    wire [15:0] packet_out;

    wire [2:0] count0, count1, count2;

    integer arrival_time [0:15];
    integer service_count [0:2];
    integer first3_count [0:2];

    integer wait_sum;
    integer drain_cycles;
    integer i, id;

    real avg_wait;
    real throughput;
    real fairness;

    real rr_avg, ca_avg;
    real rr_fair, ca_fair;
    real rr_throughput, ca_throughput;

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

    // Task to send a packet
    task send_packet;
        input [1:0] dest;
        input integer packet_id;
        begin
            @(negedge clk);

            packet_in = (dest << 14) | packet_id;
            in_valid = 1;

            while (!in_ready)
                @(negedge clk);

            @(posedge clk);
            #1;

            arrival_time[packet_id] = $time;

            $display("INPUT: ID=%0d DEST=%0d",
                     packet_id, dest);

            in_valid = 0;
            packet_in = 0;
        end
    endtask

    // Performance experiment
    task run_experiment;
        input selected_mode;
        begin
            mode = selected_mode;

            rst = 1;
            in_valid = 0;
            out_ready = 0;
            packet_in = 0;

            repeat (2) @(posedge clk);
            #1;
            rst = 0;

            wait_sum = 0;
            drain_cycles = 0;

            service_count[0] = 0;
            service_count[1] = 0;
            service_count[2] = 0;

            first3_count[0] = 0;
            first3_count[1] = 0;
            first3_count[2] = 0;

            $display("\n================================");

            if (selected_mode == 0)
                $display("ROUND ROBIN PERFORMANCE");
            else
                $display("CONGESTION AWARE PERFORMANCE");

            $display("================================");

            // Send three packets to each queue
            send_packet(2'b00, 1);
            send_packet(2'b00, 2);
            send_packet(2'b00, 3);

            send_packet(2'b01, 4);
            send_packet(2'b01, 5);
            send_packet(2'b01, 6);

            send_packet(2'b10, 7);
            send_packet(2'b10, 8);
            send_packet(2'b10, 9);

            $display("\nINITIAL COUNTS: Q0=%0d Q1=%0d Q2=%0d",
                     count0, count1, count2);

            // Enable output transmission
            out_ready = 1;

            for (i = 0; i < 9; i = i + 1) begin

                @(negedge clk);
                #1;

                if (out_valid) begin

                    id = packet_out[13:0];

                    // Calculate waiting time
                    wait_sum = wait_sum +
                               ($time - arrival_time[id]);

                    // Count total services
                    service_count[packet_out[15:14]] =
                    service_count[packet_out[15:14]] + 1;

                    // Count only the first three services
                    if (i < 3)
                        first3_count[packet_out[15:14]] =
                        first3_count[packet_out[15:14]] + 1;

                    $display("OUTPUT: ID=%0d QUEUE=%0d WAIT=%0d ns",
                             id,
                             packet_out[15:14],
                             $time - arrival_time[id]);

                end
                else begin
                    $display("ERROR: NO PACKET AVAILABLE");
                end

                drain_cycles = drain_cycles + 1;

                @(posedge clk);
                #1;
            end

            out_ready = 0;

            // Calculate performance metrics
            avg_wait = wait_sum / 9.0;

            throughput = 9.0 / drain_cycles;

            // Jain's fairness index for first three services
            fairness = 9.0 /
                (3.0 * (
                    first3_count[0] * first3_count[0] +
                    first3_count[1] * first3_count[1] +
                    first3_count[2] * first3_count[2]
                ));

            $display("\nSERVICE COUNTS:");
            $display("Q0=%0d Q1=%0d Q2=%0d",
                     service_count[0],
                     service_count[1],
                     service_count[2]);

            $display("\nFIRST THREE SERVICE COUNTS:");
            $display("Q0=%0d Q1=%0d Q2=%0d",
                     first3_count[0],
                     first3_count[1],
                     first3_count[2]);

            $display("\nPERFORMANCE RESULTS:");

            $display("Average Waiting Time = %0.2f ns",
                     avg_wait);

            $display("Throughput = %0.2f packets/cycle",
                     throughput);

            $display("First-3-Service Fairness = %0.3f",
                     fairness);

            // Store results for final comparison
            if (selected_mode == 0) begin
                rr_avg = avg_wait;
                rr_fair = fairness;
                rr_throughput = throughput;
            end
            else begin
                ca_avg = avg_wait;
                ca_fair = fairness;
                ca_throughput = throughput;
            end

        end
    endtask

    // Main test
    initial begin

        $dumpfile("sim/performance.vcd");
        $dumpvars(0, performance_tb);

        clk = 0;
        rst = 1;
        mode = 0;
        in_valid = 0;
        out_ready = 0;
        packet_in = 0;

        $display("\nPACKET ROUTER PERFORMANCE COMPARISON");

        // Experiment 1: Round Robin
        run_experiment(1'b0);

        // Experiment 2: Congestion Aware
        run_experiment(1'b1);

        // Final comparison
        $display("\n================================");
        $display("FINAL PERFORMANCE COMPARISON");
        $display("================================");

        $display("PARAMETER       ROUND ROBIN    CONGESTION AWARE");

        $display("Average Wait    %0.2f ns       %0.2f ns",
                 rr_avg, ca_avg);

        $display("Throughput      %0.2f             %0.2f",
                 rr_throughput, ca_throughput);

        $display("Fairness        %0.3f            %0.3f",
                 rr_fair, ca_fair);

        $display("\nPERFORMANCE COMPARISON COMPLETED");

        $finish;

    end

endmodule
