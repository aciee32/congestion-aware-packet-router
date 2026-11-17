
module fifo (
    input wire clk,
    input wire rst,

    input wire wr_en,
    input wire rd_en,

    input wire [15:0] din,
    output wire [15:0] dout,

    output wire full,
    output wire empty,
    output reg [2:0] count
);

    // FIFO memory: 4 locations, each 16 bits
    reg [15:0] mem [0:3];

    // Read and write pointers
    reg [1:0] wr_ptr;
    reg [1:0] rd_ptr;

    // Accepted read and write operations
    wire do_read;
    wire do_write;

    assign full  = (count == 3'd4);
    assign empty = (count == 3'd0);

    // Output the packet at the read pointer
    assign dout = mem[rd_ptr];

    // A read is accepted only when FIFO is not empty.
    assign do_read = rd_en && !empty;

    // A write is accepted when FIFO is not full,
    // or when a read happens simultaneously.
    assign do_write = wr_en && (!full || do_read);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            wr_ptr <= 2'd0;
            rd_ptr <= 2'd0;
            count  <= 3'd0;
        end

        else begin

            // Write operation
            if (do_write) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read operation
            if (do_read) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Update FIFO occupancy
            case ({do_write, do_read})

                2'b10: count <= count + 1'b1;

                2'b01: count <= count - 1'b1;

                2'b11: count <= count;

                default: count <= count;

            endcase
        end
    end

endmodule
