`timescale 1ns/1ps
module instr_rom (
    input wire [31:0] addr,
    output reg [31:0] instr
);
    wire [7:0] wa = addr[9:2];
    always @(*) begin
        case (wa)
            8'h00: instr = 32'h100000b7;
            8'h01: instr = 32'h05200113;
            8'h02: instr = 32'h0020a023;
            8'h03: instr = 32'h7ff00293;
            8'h04: instr = 32'hfff28293;
            8'h05: instr = 32'hfe029ee3;
            8'h06: instr = 32'h05600113;
            8'h07: instr = 32'h0020a023;
            8'h08: instr = 32'h7ff00293;
            8'h09: instr = 32'hfff28293;
            8'h0a: instr = 32'hfe029ee3;
            8'h0b: instr = 32'h03300113;
            8'h0c: instr = 32'h0020a023;
            8'h0d: instr = 32'h7ff00293;
            8'h0e: instr = 32'hfff28293;
            8'h0f: instr = 32'hfe029ee3;
            8'h10: instr = 32'h03200113;
            8'h11: instr = 32'h0020a023;
            8'h12: instr = 32'h7ff00293;
            8'h13: instr = 32'hfff28293;
            8'h14: instr = 32'hfe029ee3;
            8'h15: instr = 32'h04900113;
            8'h16: instr = 32'h0020a023;
            8'h17: instr = 32'h7ff00293;
            8'h18: instr = 32'hfff28293;
            8'h19: instr = 32'hfe029ee3;
            8'h1a: instr = 32'h05f00113;
            8'h1b: instr = 32'h0020a023;
            8'h1c: instr = 32'h7ff00293;
            8'h1d: instr = 32'hfff28293;
            8'h1e: instr = 32'hfe029ee3;
            8'h1f: instr = 32'h04300113;
            8'h20: instr = 32'h0020a023;
            8'h21: instr = 32'h7ff00293;
            8'h22: instr = 32'hfff28293;
            8'h23: instr = 32'hfe029ee3;
            8'h24: instr = 32'h05000113;
            8'h25: instr = 32'h0020a023;
            8'h26: instr = 32'h7ff00293;
            8'h27: instr = 32'hfff28293;
            8'h28: instr = 32'hfe029ee3;
            8'h29: instr = 32'h05500113;
            8'h2a: instr = 32'h0020a023;
            8'h2b: instr = 32'h7ff00293;
            8'h2c: instr = 32'hfff28293;
            8'h2d: instr = 32'hfe029ee3;
            8'h2e: instr = 32'h05f00113;
            8'h2f: instr = 32'h0020a023;
            8'h30: instr = 32'h7ff00293;
            8'h31: instr = 32'hfff28293;
            8'h32: instr = 32'hfe029ee3;
            8'h33: instr = 32'h04f00113;
            8'h34: instr = 32'h0020a023;
            8'h35: instr = 32'h7ff00293;
            8'h36: instr = 32'hfff28293;
            8'h37: instr = 32'hfe029ee3;
            8'h38: instr = 32'h04b00113;
            8'h39: instr = 32'h0020a023;
            8'h3a: instr = 32'h7ff00293;
            8'h3b: instr = 32'hfff28293;
            8'h3c: instr = 32'hfe029ee3;
            8'h3d: instr = 32'h00d00113;
            8'h3e: instr = 32'h0020a023;
            8'h3f: instr = 32'h7ff00293;
            8'h40: instr = 32'hfff28293;
            8'h41: instr = 32'hfe029ee3;
            8'h42: instr = 32'h00a00113;
            8'h43: instr = 32'h0020a023;
            8'h44: instr = 32'h7ff00293;
            8'h45: instr = 32'hfff28293;
            8'h46: instr = 32'hfe029ee3;
            8'h47: instr = 32'h0000006f;
            default: instr = 32'h00000013;
        endcase
    end
endmodule
