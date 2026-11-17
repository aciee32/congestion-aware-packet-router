
module destination_decoder (
    input wire [1:0] dest,

    output reg q0_sel,
    output reg q1_sel,
    output reg q2_sel,
    output reg invalid
);

always @(*) begin

    // Default values
    q0_sel = 0;
    q1_sel = 0;
    q2_sel = 0;
    invalid = 0;

    case (dest)

        2'b00: q0_sel = 1;

        2'b01: q1_sel = 1;

        2'b10: q2_sel = 1;

        2'b11: invalid = 1;

    endcase

end

endmodule
