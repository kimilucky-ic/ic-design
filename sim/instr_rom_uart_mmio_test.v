module instr_rom (
    input  wire [31:0] addr,
    output reg  [31:0] instr
);
    always @(*) begin
        case (addr[9:2])
            8'h00: instr = 32'h100000B7; // lui  x1, 0x10000 -> 0x10000000
            8'h01: instr = 32'h04100113; // addi x2, x0, 65 ('A')
            8'h02: instr = 32'h0020A023; // sw   x2, 0(x1)
            8'h03: instr = 32'h0000006F; // jal  x0, 0
            default: instr = 32'h00000013;
        endcase
    end
endmodule