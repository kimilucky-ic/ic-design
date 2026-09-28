//==============================================================================
// 4灯全亮测试 — 验证4个LED引脚是否全部正确
// 如果4灯全亮 → 引脚没问题
// 如果只有某些亮 → 不亮的引脚有问题
//==============================================================================
`timescale 1ns/1ps

module fpga_top (
    input  wire        clk,
    input  wire        rst_n,
    output wire [3:0]  led,
    output wire        uart_tx
);

    assign led     = 4'b1111;   // 4灯全亮
    assign uart_tx = 1'b1;

endmodule
