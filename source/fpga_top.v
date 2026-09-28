//==============================================================================
// fpga_top — RISC-V CPU + 指令 ROM + 数据存储器
// LED0 (AD25) = CPU 活动指示 (activity counter bit)
// UART TX 写地址: 0x1000_0000，写入低 8 位即可发送一个字节。
//==============================================================================
`timescale 1ns/1ps

module fpga_top (
    input  wire        clk,       // 27MHz  @ D18
    input  wire        rst_n,     // 复位    @ C22 (低有效)
    output wire [3:0]  led,       // LED[0]=AD25(已验证), LED[1:3]=NC
    output wire        uart_tx    // UART TX @ AB26
);

    //==========================================================================
    // 复位同步器
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
    // RISC-V CPU 信号
    //==========================================================================
    wire [31:0] imem_addr;
    wire [31:0] imem_data;
    wire [31:0] dmem_addr;
    wire        dmem_write_en;
    wire [3:0]  dmem_write_strb;
    wire [31:0] dmem_write_data;
    wire [31:0] dmem_read_data;

    localparam [31:0] UART_TX_ADDR      = 32'h1000_0000;
    localparam [31:0] UART_STATUS_ADDR = 32'h1000_0004;
    wire uart_mmio_write = dmem_write_en && (dmem_addr == UART_TX_ADDR);
    wire uart_mmio_read  = (dmem_addr == UART_STATUS_ADDR);
    reg [7:0] uart_tx_data;
    reg       uart_tx_pulse;
    wire      uart_tx_busy;

    //==========================================================================
    // 指令 ROM — FPGA 可综合 (case 语句实现)
    //==========================================================================
    instr_rom u_instr_rom (
        .addr  (imem_addr),
        .instr (imem_data)
    );

    //==========================================================================
    // 数据存储器 — 1KB, 字节/半字/字读写
    //==========================================================================
    reg [31:0] dmem [0:255];

    always @(posedge clk) begin
        if (dmem_write_en && !uart_mmio_write) begin
            if (dmem_write_strb[0]) dmem[ dmem_addr[9:2] ][7:0]   <= dmem_write_data[7:0];
            if (dmem_write_strb[1]) dmem[ dmem_addr[9:2] ][15:8]  <= dmem_write_data[15:8];
            if (dmem_write_strb[2]) dmem[ dmem_addr[9:2] ][23:16] <= dmem_write_data[23:16];
            if (dmem_write_strb[3]) dmem[ dmem_addr[9:2] ][31:24] <= dmem_write_data[31:24];
        end
    end

    assign dmem_read_data = uart_mmio_read ? {31'b0, uart_tx_busy} : dmem[ dmem_addr[9:2] ];

    // UART 写入寄存器。pulse 只保持一个时钟周期，uart_tx 模块负责串行化。
    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced) begin
            uart_tx_data  <= 8'h00;
            uart_tx_pulse <= 1'b0;
        end else begin
            uart_tx_pulse <= 1'b0;
            if (uart_mmio_write) begin
                uart_tx_data  <= dmem_write_data[7:0];
                uart_tx_pulse <= 1'b1;
            end
        end
    end

    uart_tx #(
        .BPS_NUM(16'd233)
    ) u_uart_tx (
        .clk       (clk),
        .tx_data   (uart_tx_data),
        .tx_pluse  (uart_tx_pulse),
        .uart_tx   (uart_tx),
        .tx_busy   (uart_tx_busy)
    );

    //==========================================================================
    // RISC-V CPU 核心
    //==========================================================================
    riscv_core u_cpu (
        .clk              (clk),
        .rst_n            (rst_n_synced),
        .imem_addr        (imem_addr),
        .imem_data        (imem_data),
        .dmem_addr        (dmem_addr),
        .dmem_write_en    (dmem_write_en),
        .dmem_write_strb  (dmem_write_strb),
        .dmem_write_data  (dmem_write_data),
        .dmem_read_data   (dmem_read_data)
    );

    //==========================================================================
    // CPU 活动检测 + LED
    //==========================================================================
    reg [31:0] prev_pc;
    reg [27:0] activity_cnt;

    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced) begin
            prev_pc      <= 32'hFFFFFFFF;
            activity_cnt <= 28'd0;
        end else begin
            prev_pc <= imem_addr;
            if (imem_addr != prev_pc)
                activity_cnt <= activity_cnt + 28'd1;
        end
    end

    assign led[0] = activity_cnt[26];
    assign led[1] = 1'b0;
    assign led[2] = 1'b0;
    assign led[3] = 1'b0;
endmodule
