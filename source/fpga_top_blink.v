//==============================================================================
// LED Blink Test — 验证远程 FPGA 平台基本功能
// 目标: Logos2 PG2L200H, 27MHz 时钟, 4个LED
// LED0=常亮(验证配置成功), LED1~3=不同频率闪烁
// 不依赖 RISC-V CPU，纯硬件计数器驱动
//==============================================================================
`timescale 1ns/1ps

module fpga_top (
    input  wire        clk,       // 27MHz  @ D18
    input  wire        rst_n,     // 复位    @ C22 (低有效)
    output wire [3:0]  led,       // LED1~4 @ AD25, AC24, J16, M17
    output wire        uart_tx    // UART TX @ AB26 (不用，置高)
);

    //==========================================================================
    // 复位同步器 (2级同步，防止亚稳态)
    //==========================================================================
    reg rstn_sync1, rstn_sync2;
    wire rst_n_synced;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rstn_sync1 <= 1'b0;
            rstn_sync2 <= 1'b0;
        end else begin
            rstn_sync1 <= 1'b1;
            rstn_sync2 <= rstn_sync1;
        end
    end
    assign rst_n_synced = rstn_sync2;

    //==========================================================================
    // 27MHz 计数器 — 产生不同频率的 LED 闪烁
    // 27,000,000 / 2^25 ≈ 0.805 Hz (周期约1.24s)
    //==========================================================================
    reg [25:0] counter;
    wire       counter_msb;  // ~0.4Hz, 肉眼可见慢闪
    wire       counter_24;   // ~0.8Hz
    wire       counter_23;   // ~1.6Hz
    wire       counter_22;   // ~3.2Hz

    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced)
            counter <= 26'd0;
        else
            counter <= counter + 26'd1;
    end

    assign counter_msb = counter[25];   // 27M / 2^26 ≈ 0.40 Hz
    assign counter_24  = counter[24];   // 27M / 2^25 ≈ 0.80 Hz
    assign counter_23  = counter[23];   // 27M / 2^24 ≈ 1.61 Hz
    assign counter_22  = counter[22];   // 27M / 2^23 ≈ 3.22 Hz

    //==========================================================================
    // LED 输出 (高有效: 1=亮, 0=灭)
    // LED0 = 常亮 (证明 FPGA 配置成功)
    // LED1 = 慢闪 ~0.8Hz
    // LED2 = 中闪 ~1.6Hz
    // LED3 = 快闪 ~3.2Hz
    //==========================================================================
    assign led[0] = 1'b1;
    assign led[1] = counter_24;
    assign led[2] = counter_23;
    assign led[3] = counter_22;

    // UART TX 不用，保持高电平
    assign uart_tx = 1'b1;

endmodule
