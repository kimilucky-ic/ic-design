`timescale 1ns/1ps
// Top testbench
module tb_top;

    // Clock and reset
    reg clk;
    reg rst_n;
    
    // CPU signals
    wire [31:0] imem_addr;
    wire [31:0] imem_data;
    wire [31:0] dmem_addr;
    wire dmem_write_en;
    wire [3:0] dmem_write_strb;
    wire [31:0] dmem_write_data;
    wire [31:0] dmem_read_data;
    
    // Instruction memory
    reg [31:0] instr_mem [0:1023];
    reg [31:0] data_mem  [0:1023];
    
    // Test program
    integer i;
    reg branch_checks_done;

    task check_reg;
        input [4:0] index;
        input [31:0] expected;
        begin
            if (u_cpu.u_regfile.regfile[index] !== expected) begin
                $display("REGRESSION: FAIL x%0d got %08h expected %08h", index, u_cpu.u_regfile.regfile[index], expected);
                $fatal(1, "RV32I register mismatch");
            end
        end
    endtask

    always @(posedge clk) begin
        if (rst_n && imem_addr == 32'd360 && !branch_checks_done) begin
            check_reg(8, 32'h00000001);
            check_reg(9, 32'h00000001);
            branch_checks_done <= 1'b1;
            $display("RV32I_BRANCH_FALLTHROUGH: PASS");
        end
    end
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Memory simulation
    assign imem_data = instr_mem[imem_addr[31:2]];
    assign dmem_read_data = data_mem[dmem_addr[31:2]];

    always @(posedge clk) begin
        if (dmem_write_en) begin
            if (dmem_write_strb[0]) data_mem[dmem_addr[31:2]][7:0]   <= dmem_write_data[7:0];
            if (dmem_write_strb[1]) data_mem[dmem_addr[31:2]][15:8]  <= dmem_write_data[15:8];
            if (dmem_write_strb[2]) data_mem[dmem_addr[31:2]][23:16] <= dmem_write_data[23:16];
            if (dmem_write_strb[3]) data_mem[dmem_addr[31:2]][31:24] <= dmem_write_data[31:24];
        end
    end
    
    // Instantiate CPU
    riscv_core u_cpu (
        .clk(clk),
        .rst_n(rst_n),
        .imem_addr(imem_addr),
        .imem_data(imem_data),
        .dmem_addr(dmem_addr),
        .dmem_write_en(dmem_write_en),
        .dmem_write_strb(dmem_write_strb),
        .dmem_write_data(dmem_write_data),
        .dmem_read_data(dmem_read_data)
    );
    // Monitor key signals every clock cycle
//    always @(posedge clk) begin
//        if (rst_n) begin
//               // Monitor key signals every clock cycle
//        $display("T=%0t PC=%h IR=%h EX_RES=%h WB_WE=%b WB_RD=%d WB_D=%h x1=%h x2=%h x3=%h x4=%h x5=%h x6=%h x7=%h",
//        $time,
//        u_cpu.if_pc,
//        u_cpu.if_id_instr,
//        u_cpu.ex_alu_result,
//        u_cpu.wb_rd_we,
//        u_cpu.wb_rd_addr,
//        u_cpu.wb_rd_data,
//        u_cpu.u_regfile.regfile[1],
//        u_cpu.u_regfile.regfile[2],
//        u_cpu.u_regfile.regfile[3],
//        u_cpu.u_regfile.regfile[4],
//        u_cpu.u_regfile.regfile[5],
//        u_cpu.u_regfile.regfile[6],
//        u_cpu.u_regfile.regfile[7]);
//        end
//    end

    // Test stimulus
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        branch_checks_done = 0;
        
        // Initialize memories
        for (i = 0; i < 1024; i = i + 1) begin
            instr_mem[i] = 32'b0;
            data_mem[i] = 32'b0;
        end
        
        // Load test program
        // === 分支测试 ===
        // 初始化: x1=1, x2=2, x3=3
        instr_mem[0] = 32'h00100093;  // addi x1, x0, 1
        instr_mem[1] = 32'h00200113;  // addi x2, x0, 2
        instr_mem[2] = 32'h00300193;  // addi x3, x0, 3

        // BEQ x1,x1 → 相等，跳过下一条
        instr_mem[3] = 32'h00108463;  // beq  x1, x1, 8
        instr_mem[4] = 32'h00000213;  // addi x4, x0, 0    ← 应跳过！
        instr_mem[5] = 32'h00400213;  // addi x4, x0, 4    ← 目标: x4=4

        // BNE x1,x2 → 不等，跳过下一条
        instr_mem[6] = 32'h00209463;  // bne  x1, x2, 8
        instr_mem[7] = 32'h00000293;  // addi x5, x0, 0    ← 应跳过！
        instr_mem[8] = 32'h00500293;  // addi x5, x0, 5    ← 目标: x5=5

        // BLT x1,x2 → x1<x2，跳过下一条
        instr_mem[9] = 32'h0020c463;  // blt  x1, x2, 8
        instr_mem[10]= 32'h00000313;  // addi x6, x0, 0    ← 应跳过！
        instr_mem[11]= 32'h00600313;  // addi x6, x0, 6    ← 目标: x6=6
        
        // BGE x2,x1 → x2>=x1，跳过下一条
        instr_mem[12]= 32'h00115463;  // bge  x2, x1, 8
        instr_mem[13]= 32'h00000393;  // addi x7, x0, 0    ← 应跳过！
        instr_mem[14]= 32'h00700393;  // addi x7, x0, 7    ← 目标: x7=7
        
        //1. 替换 [15]~[17]（加 BLTU + BGEU）
        
        instr_mem[15]= 32'h0020E463;  // bltu x1, x2, 8      跳到 [17]
        instr_mem[16]= 32'h00000413;  // addi x8, x0, 0      跳过
        instr_mem[17]= 32'h00800413;  // addi x8, x0, 8      x8=8
        
        instr_mem[18]= 32'h00117463;  // bgeu x2, x1, 8      跳到 [20]
        instr_mem[19]= 32'h00000493;  // addi x9, x0, 0      跳过
        instr_mem[20]= 32'h00900493;  // addi x9, x0, 9      x9=9
        
        //2. 追加在 [21]~[32]（JAL + JALR 测试）
        
        // ===== JAL/JALR 测试 =====
        instr_mem[21]= 32'h00C0006F;  // jal x0, 12          跳到 [24]
        instr_mem[22]= 32'h00000513;  // addi x10, x0, 0     跳过
        instr_mem[23]= 32'h00000593;  // addi x11, x0, 0     跳过
        instr_mem[24]= 32'h00A00513;  // addi x10, x0, 10    x10=10
        
        instr_mem[25]= 32'h008007EF;  // jal x15, 8          x15=返回地址, 跳到 [27]
        instr_mem[26]= 32'h00000593;  // addi x11, x0, 0     跳过
        instr_mem[27]= 32'h00B00593;  // addi x11, x0, 11    x11=11
        
        instr_mem[28]= 32'h08000713;  // addi x14, x0, 128   x14=[32]的地址
        instr_mem[29]= 32'h000706E7;  // jalr x13, x14, 0    跳到 [32]
        instr_mem[30]= 32'h00000613;  // addi x12, x0, 0     跳过
        instr_mem[31]= 32'h00000613;  // addi x12, x0, 0     跳过
        instr_mem[32]= 32'h00C00613;  // addi x12, x0, 12    x12=12
        // ===== 算术/逻辑/移位测试 =====
        // 设置操作数: x1=10, x2=5
        instr_mem[33]= 32'h00A00093;  // addi  x1, x0, 10       x1=10 (0xA)
        instr_mem[34]= 32'h00500113;  // addi  x2, x0, 5        x2=5
        
        // R 型算术
        instr_mem[35]= 32'h40208833;  // sub   x16, x1, x2       x16=10-5=5
        instr_mem[36]= 32'h0020A8B3;  // slt   x17, x1, x2       x17=1? (10<5)=0
        instr_mem[37]= 32'h00113933;  // sltu  x18, x2, x1       x18=1 (5<10 unsigned)
        
        // R 型逻辑
        instr_mem[38]= 32'h0020F9B3;  // and   x19, x1, x2       x19=10&5=0
        instr_mem[39]= 32'h0020EA33;  // or    x20, x1, x2       x20=10|5=15 (0xF)
        instr_mem[40]= 32'h0020CAB3;  // xor   x21, x1, x2       x21=10^5=15 (0xF)
        
        // I 型逻辑立即数
        instr_mem[41]= 32'h0FF0FB13;  // andi  x22, x1, 0xFF     x22=10&255=10
        instr_mem[42]= 32'hFF00EB93;  // ori   x23, x1, 0xFF0    x23=10|4080=4090 (0xFFA)
        instr_mem[43]= 32'h0FF0CC13;  // xori  x24, x1, 0xFF     x24=10^255=245 (0xF5)
        
        // LUI: x3 = 0x80000000（用于移位测试的负数值）
        instr_mem[44]= 32'h800001B7;  // lui   x3, 0x80000       x3=0x80000000
        
        // R 型移位
        instr_mem[45]= 32'h00209CB3;  // sll   x25, x1, x2       x25=10<<5=320 (0x140)
        instr_mem[46]= 32'h0021DD33;  // srl   x26, x3, x2       x26=0x80000000>>5=0x04000000
        instr_mem[47]= 32'h4021DDB3;  // sra   x27, x3, x2       x27=0x80000000>>5 arith=0xFC000000
        
        // I 型移位立即数
        instr_mem[48]= 32'h00209E13;  // slli  x28, x1, 2        x28=10<<2=40 (0x28)
        instr_mem[49]= 32'h0041DE93;  // srli  x29, 4=0x08000000
        instr_mem[50]= 32'h4041DF13;  // srai  x30, x3, 4        x30=0x80000000>>4 arith=0xF8000000
        
        // AUIPC: x31 = PC
        instr_mem[51]= 32'h00000F97;  // auipc x31, 0            x31=51*4=204 (0xCC)
        
        instr_mem[52]= 32'h00000013;  // nop
        instr_mem[53]= 32'h00000013;  // nop
        instr_mem[54]= 32'h00000013;  // nop

        // === SLTI/SLTIU 测试 ===
        instr_mem[55]= 32'h00312413;  // slti  x8, x1, 3          x8=(10<3)=0
        instr_mem[56]= 32'h00f12493;  // slti  x9, x1, 15         x9=(10<15)=1
        instr_mem[57]= 32'hffb12513;  // slti  x10, x1, -5        x10=(10<-5 signed)=0
        instr_mem[58]= 32'hffb13593;  // sltiu x11, x1, -5        x11=(10<0xFFB unsigned)=1

        // === Load/Store 测试 ===
        instr_mem[59]= 32'h00000713;  // addi  x14, x0, 0         base=0
        // SW + LW
        instr_mem[60]= 32'h00172023;  // sw    x1, 0(x14)         mem[0]=10
        instr_mem[61]= 32'h00072183;  // lw    x3, 0(x14)         x3=10
        // SH + LH + LHU
        instr_mem[62]= 32'hfff00793;  // addi  x15, x0, -1        x15=0xFFFFFFFF
        instr_mem[63]= 32'h00f71223;  // sh    x15, 4(x14)        mem_half=0xFFFF
        instr_mem[64]= 32'h00471203;  // lh    x4, 4(x14)         x4=0xFFFFFFFF
        instr_mem[65]= 32'h00475283;  // lhu   x5, 4(x14)         x5=0x0000FFFF
        // SB + LB + LBU
        instr_mem[66]= 32'h00f70423;  // sb    x15, 8(x14)        mem_byte=0xFF
        instr_mem[67]= 32'h00870303;  // lb    x6, 8(x14)         x6=0xFFFFFFFF
        instr_mem[68]= 32'h00874383;  // lbu   x7, 8(x14)         x7=0x000000FF
        // 排空
        instr_mem[69]= 32'h00000013;  // nop
        instr_mem[70]= 32'h00000013;  // nop
        instr_mem[71]= 32'h00000013;  // nop

        // ===== 补充测试 =====
        // 1. ADD (R型) — 唯一遗漏的 RV32I 指令
        instr_mem[72]= 32'h00208FB3;  // add   x31, x1, x2        x31 = 10+5 = 15 (0xF)

        // 2. BNE equal — 分支不跳转（fall-through）
        instr_mem[73]= 32'h00000413;  // addi  x8, x0, 0           x8 = 0 (flag)
        instr_mem[74]= 32'h00001463;  // bne   x0, x0, 8           x0==x0, 不应跳
        instr_mem[75]= 32'h00100413;  // addi  x8, x0, 1           fall-through → x8=1
        // 如果错跳, 跳过[75] → x8=0

        // 3. BEQ unequal — 分支不跳转（fall-through）
        instr_mem[76]= 32'h00000493;  // addi  x9, x0, 0           x9 = 0 (flag)
        instr_mem[77]= 32'h00208463;  // beq   x1, x2, 8           x1(10)≠x2(5), 不应跳
        instr_mem[78]= 32'h00100493;  // addi  x9, x0, 1           fall-through → x9=1
        // 如果错跳, 跳过[78] → x9=0

        // 4. SRL/SRA 正数（之前只测了 0x80000000 负数）
        instr_mem[79]= 32'h400001B7;  // lui   x3, 0x40000         x3 = 0x40000000
        instr_mem[80]= 32'h0021DEB3;  // srl   x29, x3, x2         x29 = 0x40000000>>5 = 0x02000000
        instr_mem[81]= 32'h4021DF33;  // sra   x30, x3, x2         x30 = 0x40000000>>>5 = 0x02000000

        // 5. 流水线 RAW 转发测试（相邻指令数据依赖）
        instr_mem[82]= 32'h01400213;  // addi  x4, x0, 20          x4 = 20
        instr_mem[83]= 32'h004202B3;  // add   x5, x4, x4          x5 = x4+x4 = 40 (需转发 x4)
        instr_mem[84]= 32'h01E20313;  // addi  x6, x4, 30          x6 = 20+30 = 50 (需转发)

        // 6. x0 硬连线写保护测试
        instr_mem[85]= 32'h07B00013;  // addi  x0, x0, 123         x0 必须保持 0
        instr_mem[86]= 32'h00007E23;  // sw    x0, 28(x14)         mem[7] 必须 = 0 (x14=0)

        // 排空
        instr_mem[87]= 32'h00000013;  // nop
        instr_mem[88]= 32'h00000013;  // nop
        instr_mem[89]= 32'h00000013;  // nop

        // Load-use and dependent forwarding: the first ADDI immediately consumes LW.
        instr_mem[90]= 32'h00072383;  // lw    x7, 0(x14)          x7=10
        instr_mem[91]= 32'h00138413;  // addi  x8, x7, 1           x8=11
        instr_mem[92]= 32'h007404B3;  // add   x9, x8, x7          x9=21

        // Apply reset
        #10 rst_n = 1;

        // Allow enough cycles for directed hazards and the full program tail.
        #5000;
        
        // Assert final architectural state; printing values alone hid failures.
        check_reg(0,  32'h00000000);
        check_reg(1,  32'h0000000a);
        check_reg(2,  32'h00000005);
        check_reg(3,  32'h40000000);
        check_reg(4,  32'h00000014);
        check_reg(5,  32'h00000028);
        check_reg(6,  32'h00000032);
        check_reg(7,  32'h0000000a);
        check_reg(8,  32'h0000000b);
        check_reg(9,  32'h00000015);
        check_reg(10, 32'h00000000);
        check_reg(11, 32'h00000001);
        check_reg(12, 32'h0000000c);
        check_reg(13, 32'h00000078);
        check_reg(14, 32'h00000000);
        check_reg(15, 32'hffffffff);
        check_reg(16, 32'h00000005);
        check_reg(17, 32'h00000000);
        check_reg(18, 32'h00000001);
        check_reg(19, 32'h00000000);
        check_reg(20, 32'h0000000f);
        check_reg(21, 32'h0000000f);
        check_reg(22, 32'h0000000a);
        check_reg(23, 32'hfffffffa);
        check_reg(24, 32'h000000f5);
        check_reg(25, 32'h00000140);
        check_reg(26, 32'h04000000);
        check_reg(27, 32'hfc000000);
        check_reg(28, 32'h00000028);
        check_reg(29, 32'h02000000);
        check_reg(30, 32'h02000000);
        check_reg(31, 32'h0000000f);
        if (!branch_checks_done) $fatal(1, "branch checkpoint was not reached");

        // Display results
        $display("===== RV32I 全指令集验证 =====");
//        $display("--- 基础设置 ---");
        $display(" x1  = %h (expect 0x0A)",           u_cpu.u_regfile.regfile[1]);
        $display(" x2  = %h (expect 0x05)",           u_cpu.u_regfile.regfile[2]);
//        $display("--- 访存测试 ---");
        $display(" x3  = %h (expect 0x40000000, final LUI)", u_cpu.u_regfile.regfile[3]);
        $display(" x4  = %h (expect 0x14, RAW fwd)",  u_cpu.u_regfile.regfile[4]);
        $display(" x5  = %h (expect 0x28, RAW fwd)",  u_cpu.u_regfile.regfile[5]);
        $display(" x6  = %h (expect 0x32, RAW fwd)",  u_cpu.u_regfile.regfile[6]);
        $display(" x7  = %h (expect 0x0A, final LW)",  u_cpu.u_regfile.regfile[7]);
//        $display("--- 分支不跳转 ---");
        $display(" x8  = %h (expect 0x0B, load-use ADDI)", u_cpu.u_regfile.regfile[8]);
        $display(" x9  = %h (expect 0x15, dependent ADD)", u_cpu.u_regfile.regfile[9]);
        $display(" x10 = %h (expect 0x00)",           u_cpu.u_regfile.regfile[10]);
        $display(" x11 = %h (expect 0x01)",           u_cpu.u_regfile.regfile[11]);
//        $display("--- 跳转测试 ---");
        $display(" x12 = %h (expect 0x0C, JALR)",     u_cpu.u_regfile.regfile[12]);
        $display(" x13 = %h (expect 0x78, ret addr)", u_cpu.u_regfile.regfile[13]);
        $display(" x14 = %h (expect 0x00, base)",     u_cpu.u_regfile.regfile[14]);
        $display(" x15 = %h (expect 0xFFFFFFFF)",     u_cpu.u_regfile.regfile[15]);
//        $display("--- R型 算术/逻辑 ---");
        $display(" x16 = %h (expect 0x05, SUB)",      u_cpu.u_regfile.regfile[16]);
        $display(" x17 = %h (expect 0x00, SLT)",      u_cpu.u_regfile.regfile[17]);
        $display(" x18 = %h (expect 0x01, SLTU)",     u_cpu.u_regfile.regfile[18]);
        $display(" x19 = %h (expect 0x00, AND)",      u_cpu.u_regfile.regfile[19]);
        $display(" x20 = %h (expect 0x0F, OR)",       u_cpu.u_regfile.regfile[20]);
        $display(" x21 = %h (expect 0x0F, XOR)",      u_cpu.u_regfile.regfile[21]);
//        $display("--- I型 逻辑立即数 ---");
        $display(" x22 = %h (expect 0x0A, ANDI)",     u_cpu.u_regfile.regfile[22]);
        $display(" x23 = %h (expect 0xFFFFFFFA, ORI)", u_cpu.u_regfile.regfile[23]);
        $display(" x24 = %h (expect 0xF5, XORI)",     u_cpu.u_regfile.regfile[24]);
//        $display("--- 移位 ---");
        $display(" x25 = %h (expect 0x140, SLL)",     u_cpu.u_regfile.regfile[25]);
        $display(" x26 = %h (expect 0x04000000, SRL neg)",  u_cpu.u_regfile.regfile[26]);
        $display(" x27 = %h (expect 0xFC000000, SRA neg)",  u_cpu.u_regfile.regfile[27]);
        $display(" x28 = %h (expect 0x28, SLLI)",     u_cpu.u_regfile.regfile[28]);
        $display(" x29 = %h (expect 0x02000000, SRL pos)",  u_cpu.u_regfile.regfile[29]);
        $display(" x30 = %h (expect 0x02000000, SRA pos)",  u_cpu.u_regfile.regfile[30]);
        $display(" x31 = %h (expect 0x0F, ADD R型)",  u_cpu.u_regfile.regfile[31]);
        $display("RV32I_REGRESSION: PASS (32 registers checked)");
        $finish;
    end
    
    // Waveform dumping
//    initial begin
//        $dumpfile("wave.vcd");
//        $dumpvars(0, tb_top);
//    end

endmodule
