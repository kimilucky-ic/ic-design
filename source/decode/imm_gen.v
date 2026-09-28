//# Immediate generator
module imm_gen (
    input  wire [31:0]  instr,
    input  wire [6:0]   imm_type,    // ← [2:0] 改成 [6:0]
    output reg  [31:0]  imm_out
);

always @(*) begin
    case (imm_type)
        `OPCODE_OP_IMM: imm_out = {{20{instr[31]}}, instr[31:20]};
        `OPCODE_LOAD:   imm_out = {{20{instr[31]}}, instr[31:20]};
        `OPCODE_JALR:   imm_out = {{20{instr[31]}}, instr[31:20]};
        `OPCODE_STORE:  imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        `OPCODE_BRANCH: imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        `OPCODE_LUI:    imm_out = {instr[31:12], 12'b0};
        `OPCODE_AUIPC:  imm_out = {instr[31:12], 12'b0};
        `OPCODE_JAL:    imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        default:        imm_out = 32'b0;
    endcase
end

endmodule