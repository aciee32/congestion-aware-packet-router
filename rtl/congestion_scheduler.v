
module congestion_scheduler (
    input wire clk,
    input wire rst,

    input wire [2:0] count0,
    input wire [2:0] count1,
    input wire [2:0] count2,

    input wire empty0,
    input wire empty1,
    input wire empty2,

    input wire transmit_done,

    output reg rd0,
    output reg rd1,
    output reg rd2,

    output reg [1:0] selected_queue,
    output reg valid
);

    reg [1:0] priority;

    reg [2:0] min_count;

    always @(*) begin

        rd0 = 0;
        rd1 = 0;
        rd2 = 0;

        valid = 0;
        selected_queue = 0;
        min_count = 3'd7;

        // Find minimum occupancy among non-empty queues

        if (!empty0 && count0 < min_count)
            min_count = count0;

        if (!empty1 && count1 < min_count)
            min_count = count1;

        if (!empty2 && count2 < min_count)
            min_count = count2;

        // Select queue using rotating priority

        case (priority)

            2'd0: begin
                if (!empty0 && count0 == min_count) begin
                    rd0 = 1;
                    selected_queue = 0;
                    valid = 1;
                end
                else if (!empty1 && count1 == min_count) begin
                    rd1 = 1;
                    selected_queue = 1;
                    valid = 1;
                end
                else if (!empty2 && count2 == min_count) begin
                    rd2 = 1;
                    selected_queue = 2;
                    valid = 1;
                end
            end

            2'd1: begin
                if (!empty1 && count1 == min_count) begin
                    rd1 = 1;
                    selected_queue = 1;
                    valid = 1;
                end
                else if (!empty2 && count2 == min_count) begin
                    rd2 = 1;
                    selected_queue = 2;
                    valid = 1;
                end
                else if (!empty0 && count0 == min_count) begin
                    rd0 = 1;
                    selected_queue = 0;
                    valid = 1;
                end
            end

            2'd2: begin
                if (!empty2 && count2 == min_count) begin
                    rd2 = 1;
                    selected_queue = 2;
                    valid = 1;
                end
                else if (!empty0 && count0 == min_count) begin
                    rd0 = 1;
                    selected_queue = 0;
                    valid = 1;
                end
                else if (!empty1 && count1 == min_count) begin
                    rd1 = 1;
                    selected_queue = 1;
                    valid = 1;
                end
            end

            default: begin
                valid = 0;
            end

        endcase
    end

    // Update priority after successful transmission

    always @(posedge clk or posedge rst) begin

        if (rst)
            priority <= 2'd0;

        else if (transmit_done && valid) begin

            if (selected_queue == 2'd0)
                priority <= 2'd1;

            else if (selected_queue == 2'd1)
                priority <= 2'd2;

            else
                priority <= 2'd0;

        end
    end

endmodule
