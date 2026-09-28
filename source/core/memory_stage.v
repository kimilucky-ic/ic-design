//# MEM stage
module memory_stage (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  mem_pc,
    // Pipeline input
    input  wire [31:0]  mem_alu_result,
    input  wire [31:0]  mem_store_data,
    input  wire         mem_mem_read,
    input  wire         mem_mem_write,
    input  wire [2:0]   mem_mem_type,
    input  wire [4:0]   mem_rd,
    input  wire         mem_reg_write,
    input  wire [1:0]   mem_wb_sel,
    
    // Memory interface
    output wire [31:0]  mem_addr,
    output wire [31:0]  mem_write_data,
    output wire         mem_write_en,
    output wire [3:0]   mem_write_strb,
    input  wire [31:0]  mem_read_data,
    
    // Pipeline output
    output reg  [31:0]  mem_wb_data,
    output wire  [4:0]   mem_wb_rd,
    output wire          mem_wb_reg_write
);

    // Memory address and write data
    assign mem_addr = mem_alu_result;
    // Replicate the store value across the byte lanes that mem_write_strb may
    // select, so the correct byte/halfword lands in the enabled lane regardless
    // of addr[1:0] (misaligned byte/halfword stores would otherwise write 0).
    wire [31:0] mem_write_data_lanes =
        (mem_mem_type == `MEM_BYTE) ? {4{mem_store_data[7:0]}} :
        (mem_mem_type == `MEM_HALF) ? {2{mem_store_data[15:0]}} :
        mem_store_data;
    assign mem_write_data = mem_write_data_lanes;
    assign mem_write_en = mem_mem_write;
    
    // Generate write byte enables
    assign mem_write_strb[0] = mem_mem_write && (
        (mem_mem_type == `MEM_BYTE && mem_addr[1:0] == 2'b00) ||
        (mem_mem_type == `MEM_HALF && mem_addr[1:0] == 2'b00) ||
        (mem_mem_type == `MEM_WORD)
    );
    
    assign mem_write_strb[1] = mem_mem_write && (
        (mem_mem_type == `MEM_BYTE && mem_addr[1:0] == 2'b01) ||
        (mem_mem_type == `MEM_HALF && mem_addr[1:0] == 2'b00) ||
        (mem_mem_type == `MEM_WORD)
    );
    
    assign mem_write_strb[2] = mem_mem_write && (
        (mem_mem_type == `MEM_BYTE && mem_addr[1:0] == 2'b10) ||
        (mem_mem_type == `MEM_HALF && mem_addr[1:0] == 2'b10) ||
        (mem_mem_type == `MEM_WORD)
    );
    
    assign mem_write_strb[3] = mem_mem_write && (
        (mem_mem_type == `MEM_BYTE && mem_addr[1:0] == 2'b11) ||
        (mem_mem_type == `MEM_HALF && mem_addr[1:0] == 2'b10) ||
        (mem_mem_type == `MEM_WORD)
    );
    
    // Memory read data processing
    reg [31:0] mem_read_processed;
    always @(*) begin
        case (mem_mem_type)
            `MEM_BYTE: begin
                case (mem_addr[1:0])
                    2'b00: mem_read_processed = {{24{mem_read_data[7]}}, mem_read_data[7:0]};
                    2'b01: mem_read_processed = {{24{mem_read_data[15]}}, mem_read_data[15:8]};
                    2'b10: mem_read_processed = {{24{mem_read_data[23]}}, mem_read_data[23:16]};
                    2'b11: mem_read_processed = {{24{mem_read_data[31]}}, mem_read_data[31:24]};
                endcase
            end
            `MEM_HALF: begin
                case (mem_addr[1])
                    1'b0: mem_read_processed = {{16{mem_read_data[15]}}, mem_read_data[15:0]};
                    1'b1: mem_read_processed = {{16{mem_read_data[31]}}, mem_read_data[31:16]};
                endcase
            end
            `MEM_WORD: begin
                mem_read_processed = mem_read_data;
            end
            `MEM_BYTE_U: begin
                case (mem_addr[1:0])
                    2'b00: mem_read_processed = {24'b0, mem_read_data[7:0]};
                    2'b01: mem_read_processed = {24'b0, mem_read_data[15:8]};
                    2'b10: mem_read_processed = {24'b0, mem_read_data[23:16]};
                    2'b11: mem_read_processed = {24'b0, mem_read_data[31:24]};
                endcase
            end
            `MEM_HALF_U: begin
                case (mem_addr[1])
                    1'b0: mem_read_processed = {16'b0, mem_read_data[15:0]};
                    1'b1: mem_read_processed = {16'b0, mem_read_data[31:16]};
                endcase
            end
            default: mem_read_processed = mem_read_data;
        endcase
    end
    
    // Write-back data selection
    always @(*) begin
        case (mem_wb_sel)
            2'b00: mem_wb_data = mem_alu_result;      // ALU result
            2'b01: mem_wb_data = mem_read_processed;  // Memory read
            2'b10: mem_wb_data = mem_pc + 4; // PC + 4 (for JAL/JALR)
            2'b11: mem_wb_data = mem_alu_result;  // LUI: imm passed through ALU
            default: mem_wb_data = 32'b0;
        endcase
    end
    
    // Pipeline registers
    assign mem_wb_rd = mem_rd;
    assign mem_wb_reg_write = mem_reg_write;

endmodule