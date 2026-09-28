`timescale 1ns/1ps
//==============================================================================
// tb_fpga_top — FPGA 顶层仿真 (CPU + ROM + 数据存储 + LED)
//==============================================================================

module tb_fpga_top;

    reg clk;
    reg rst_n;
    wire [3:0] led;
    wire uart_tx;

    fpga_top u_fpga_top (
        .clk    (clk),
        .rst_n  (rst_n),
        .led    (led),
        .uart_tx(uart_tx)
    );

    always #5 clk = ~clk;

    //==========================================================================
    // LED 监控: sim_led = activity_cnt[3], 每16周期翻转
    //==========================================================================
    wire sim_led;
    integer last_cnt;

    assign sim_led = u_fpga_top.activity_cnt[3];

    always @(posedge clk) begin
        if (rst_n && (u_fpga_top.activity_cnt !== last_cnt)) begin
            last_cnt = u_fpga_top.activity_cnt;
            if (u_fpga_top.activity_cnt % 50 == 0) begin
                $display("T=%0t act=%0d sim_led=%b led=%b PC=%h",
                    $time, u_fpga_top.activity_cnt,
                    sim_led, led[0],
                    u_fpga_top.u_cpu.if_pc);
            end
        end
    end

    //==========================================================================
    // 测试
    //==========================================================================
    initial begin
        clk = 0; rst_n = 0; last_cnt = 0;
        #10 rst_n = 1;
        #5000;

        $display("");
        $display("====== FPGA TOP 仿真结果 ======");
        $display("");
        $display("--- LED ---");
        $display("activity_cnt = %0d (>0=CPU在跑)", u_fpga_top.activity_cnt);
        $display("sim_led(bit3) = %b (每16周期翻转, 已验证计数)", sim_led);
        $display("led[0](bit26) = %b (FPGA: ~5s周期, 仿真500周期看不到翻转)", led[0]);
        $display("");
        $display("--- 寄存器 ---");
        $display(" x1  = %h (expect 0A)  %s", u_fpga_top.u_cpu.u_regfile.regfile[1],  u_fpga_top.u_cpu.u_regfile.regfile[1]  === 32'h0000000A ? "OK" : "FAIL");
        $display(" x2  = %h (expect 05)  %s", u_fpga_top.u_cpu.u_regfile.regfile[2],  u_fpga_top.u_cpu.u_regfile.regfile[2]  === 32'h00000005 ? "OK" : "FAIL");
        $display(" x4  = %h (expect 14)  %s", u_fpga_top.u_cpu.u_regfile.regfile[4],  u_fpga_top.u_cpu.u_regfile.regfile[4]  === 32'h00000014 ? "OK" : "FAIL");
        $display(" x5  = %h (expect 28)  %s", u_fpga_top.u_cpu.u_regfile.regfile[5],  u_fpga_top.u_cpu.u_regfile.regfile[5]  === 32'h00000028 ? "OK" : "FAIL");
        $display(" x6  = %h (expect 32)  %s", u_fpga_top.u_cpu.u_regfile.regfile[6],  u_fpga_top.u_cpu.u_regfile.regfile[6]  === 32'h00000032 ? "OK" : "FAIL");
        $display(" x7  = %h (expect FF)  %s", u_fpga_top.u_cpu.u_regfile.regfile[7],  u_fpga_top.u_cpu.u_regfile.regfile[7]  === 32'h000000FF ? "OK" : "FAIL");
        $display(" x8  = %h (expect 01)  %s", u_fpga_top.u_cpu.u_regfile.regfile[8],  u_fpga_top.u_cpu.u_regfile.regfile[8]  === 32'h00000001 ? "OK" : "FAIL");
        $display(" x9  = %h (expect 01)  %s", u_fpga_top.u_cpu.u_regfile.regfile[9],  u_fpga_top.u_cpu.u_regfile.regfile[9]  === 32'h00000001 ? "OK" : "FAIL");
        $display(" x12 = %h (expect 0C)  %s", u_fpga_top.u_cpu.u_regfile.regfile[12], u_fpga_top.u_cpu.u_regfile.regfile[12] === 32'h0000000C ? "OK" : "FAIL");
        $display(" x13 = %h (expect 78)  %s", u_fpga_top.u_cpu.u_regfile.regfile[13], u_fpga_top.u_cpu.u_regfile.regfile[13] === 32'h00000078 ? "OK" : "FAIL");
        $display(" x16 = %h (expect 05)  %s", u_fpga_top.u_cpu.u_regfile.regfile[16], u_fpga_top.u_cpu.u_regfile.regfile[16] === 32'h00000005 ? "OK" : "FAIL");
        $display(" x20 = %h (expect 0F)  %s", u_fpga_top.u_cpu.u_regfile.regfile[20], u_fpga_top.u_cpu.u_regfile.regfile[20] === 32'h0000000F ? "OK" : "FAIL");
        $display(" x25 = %h (expect 140) %s", u_fpga_top.u_cpu.u_regfile.regfile[25], u_fpga_top.u_cpu.u_regfile.regfile[25] === 32'h00000140 ? "OK" : "FAIL");
        $display(" x29 = %h (expect 02000000) %s", u_fpga_top.u_cpu.u_regfile.regfile[29], u_fpga_top.u_cpu.u_regfile.regfile[29] === 32'h02000000 ? "OK" : "FAIL");
        $display("================================");

        $stop;
    end

endmodule
