
module round_robin_arbiter (
    input wire clk,
    input wire rst,

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

    always @(*) begin
        rd0 = 0;
        rd1 = 0;
        rd2 = 0;
        valid = 0;
        selected_queue = 2'b00;

        case (priority)

            2'd0: begin
                if (!empty0) begin
                    rd0 = 1;
                    selected_queue = 2'd0;
                    valid = 1;
                end
                else if (!empty1) begin
                    rd1 = 1;
                    selected_queue = 2'd1;
                    valid = 1;
                end
                else if (!empty2) begin
                    rd2 = 1;
                    selected_queue = 2'd2;
                    valid = 1;
                end
            end

            2'd1: begin
                if (!empty1) begin
                    rd1 = 1;
                    selected_queue = 2'd1;
                    valid = 1;
                end
                else if (!empty2) begin
                    rd2 = 1;
                    selected_queue = 2'd2;
                    valid = 1;
                end
                else if (!empty0) begin
                    rd0 = 1;
                    selected_queue = 2'd0;
                    valid = 1;
                end
            end

            2'd2: begin
                if (!empty2) begin
                    rd2 = 1;
                    selected_queue = 2'd2;
                    valid = 1;
                end
                else if (!empty0) begin
                    rd0 = 1;
                    selected_queue = 2'd0;
                    valid = 1;
                end
                else if (!empty1) begin
                    rd1 = 1;
                    selected_queue = 2'd1;
                    valid = 1;
                end
            end

            default: begin
                valid = 0;
            end

        endcase
    end

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
