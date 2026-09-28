//==============================================================================
// instr_rom — FPGA 可综合指令 ROM (case 语句, 无 $readmemh)
// 包含 instr_mem.hex 中的 RV32I 测试程序
// 组合逻辑输出, 无时钟 — PDS 综合直接映射为 LUT
//==============================================================================

module instr_rom (
    input  wire [31:0] addr,    // 字节地址
    output reg  [31:0] instr    // 32-bit 指令
);

    // 字地址: 忽略低2bit, 256字 max
    wire [7:0] wa = addr[9:2];

    always @(*) begin
        case (wa)
            8'h00: instr = 32'h00100093;
            8'h01: instr = 32'h00200113;
            8'h02: instr = 32'h00300193;
            8'h03: instr = 32'h00108463;
            8'h04: instr = 32'h00000213;
            8'h05: instr = 32'h00400213;
            8'h06: instr = 32'h00209463;
            8'h07: instr = 32'h00000293;
            8'h08: instr = 32'h00500293;
            8'h09: instr = 32'h0020c463;
            8'h0A: instr = 32'h00000313;
            8'h0B: instr = 32'h00600313;
            8'h0C: instr = 32'h00115463;
            8'h0D: instr = 32'h00000393;
            8'h0E: instr = 32'h00700393;
            8'h0F: instr = 32'h0020e463;
            8'h10: instr = 32'h00000413;
            8'h11: instr = 32'h00800413;
            8'h12: instr = 32'h00117463;
            8'h13: instr = 32'h00000493;
            8'h14: instr = 32'h00900493;
            8'h15: instr = 32'h00c0006f;
            8'h16: instr = 32'h00000513;
            8'h17: instr = 32'h00000593;
            8'h18: instr = 32'h00a00513;
            8'h19: instr = 32'h008007ef;
            8'h1A: instr = 32'h00000593;
            8'h1B: instr = 32'h00b00593;
            8'h1C: instr = 32'h08000713;
            8'h1D: instr = 32'h000706e7;
            8'h1E: instr = 32'h00000613;
            8'h1F: instr = 32'h00000613;
            8'h20: instr = 32'h00c00613;
            8'h21: instr = 32'h00a00093;
            8'h22: instr = 32'h00500113;
            8'h23: instr = 32'h40208833;
            8'h24: instr = 32'h0020a8b3;
            8'h25: instr = 32'h00113933;
            8'h26: instr = 32'h0020f9b3;
            8'h27: instr = 32'h0020ea33;
            8'h28: instr = 32'h0020cab3;
            8'h29: instr = 32'h0ff0fb13;
            8'h2A: instr = 32'hff00eb93;
            8'h2B: instr = 32'h0ff0cc13;
            8'h2C: instr = 32'h800001b7;
            8'h2D: instr = 32'h00209cb3;
            8'h2E: instr = 32'h0021dd33;
            8'h2F: instr = 32'h4021ddb3;
            8'h30: instr = 32'h00209e13;
            8'h31: instr = 32'h0041de93;
            8'h32: instr = 32'h4041df13;
            8'h33: instr = 32'h00000f97;
            8'h34: instr = 32'h00000013;
            8'h35: instr = 32'h00000013;
            8'h36: instr = 32'h00000013;
            8'h37: instr = 32'h00312413;
            8'h38: instr = 32'h00f12493;
            8'h39: instr = 32'hffb12513;
            8'h3A: instr = 32'hffb13593;
            8'h3B: instr = 32'h00000713;
            8'h3C: instr = 32'h00172023;
            8'h3D: instr = 32'h00072183;
            8'h3E: instr = 32'hfff00793;
            8'h3F: instr = 32'h00f71223;
            8'h40: instr = 32'h00471203;
            8'h41: instr = 32'h00475283;
            8'h42: instr = 32'h00f70423;
            8'h43: instr = 32'h00870303;
            8'h44: instr = 32'h00874383;
            8'h45: instr = 32'h00000013;
            8'h46: instr = 32'h00000013;
            8'h47: instr = 32'h00000013;
            8'h48: instr = 32'h00208fb3;
            8'h49: instr = 32'h00000413;
            8'h4A: instr = 32'h00009463;
            8'h4B: instr = 32'h00100413;
            8'h4C: instr = 32'h00000493;
            8'h4D: instr = 32'h00108463;
            8'h4E: instr = 32'h00100493;
            8'h4F: instr = 32'h400001b7;
            8'h50: instr = 32'h0021deb3;
            8'h51: instr = 32'h4021df33;
            8'h52: instr = 32'h01400213;
            8'h53: instr = 32'h004202b3;
            8'h54: instr = 32'h01e20313;
            8'h55: instr = 32'h07b00013;
            8'h56: instr = 32'h000072e3;
            8'h57: instr = 32'h00000013;
            8'h58: instr = 32'h00000013;
            8'h59: instr = 32'h00000013;
            // 未使用的地址 → NOP
            default: instr = 32'h00000013;
        endcase
    end

endmodule
