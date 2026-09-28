`timescale 1ns/1ps
module fpga_top_coremark (
    input wire clk,
    input wire rst_n,
    output wire [3:0] led,
    output wire uart_tx
);
    reg rstn_sync1, rstn_sync2;
    wire rst_n_synced = rstn_sync2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rstn_sync1 <= 1'b0; rstn_sync2 <= 1'b0; end
        else begin rstn_sync1 <= 1'b1; rstn_sync2 <= rstn_sync1; end
    end

    wire [31:0] imem_addr, imem_data, dmem_addr, dmem_write_data, dmem_read_data;
    wire [3:0] dmem_write_strb;
    wire dmem_write_en;
    localparam [31:0] FLASH_LIMIT = 32'h00008000;
    localparam [31:0] RAM_BASE = 32'h00008000;
    localparam [31:0] RAM_LIMIT = 32'h00010000;
    localparam [31:0] UART_TX_ADDR = 32'h10000000;
    localparam [31:0] UART_STATUS_ADDR = 32'h10000004;
    localparam [31:0] CYCLE_COUNTER_ADDR = 32'h10000008;

    wire [31:0] dmem_flash_data;
    coremark_rom u_instruction_rom(.addr(imem_addr), .data(imem_data));
    coremark_rom u_data_rom(.addr(dmem_addr), .data(dmem_flash_data));

    reg [31:0] dmem [0:8191];
    reg [31:0] cycle_counter;
    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced) cycle_counter <= 32'd0;
        else cycle_counter <= cycle_counter + 32'd1;
    end

    wire uart_mmio_write = dmem_write_en && (dmem_addr == UART_TX_ADDR);
    wire uart_mmio_read = (dmem_addr == UART_STATUS_ADDR);
    wire cycle_counter_read = (dmem_addr == CYCLE_COUNTER_ADDR);
    always @(posedge clk) begin
        if (dmem_write_en && dmem_addr >= RAM_BASE && dmem_addr < RAM_LIMIT) begin
            if (dmem_write_strb[0]) dmem[dmem_addr[14:2]][7:0] <= dmem_write_data[7:0];
            if (dmem_write_strb[1]) dmem[dmem_addr[14:2]][15:8] <= dmem_write_data[15:8];
            if (dmem_write_strb[2]) dmem[dmem_addr[14:2]][23:16] <= dmem_write_data[23:16];
            if (dmem_write_strb[3]) dmem[dmem_addr[14:2]][31:24] <= dmem_write_data[31:24];
        end
    end

    reg [7:0] uart_tx_data;
    reg uart_tx_pulse;
    wire uart_tx_busy;
    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced) begin uart_tx_data <= 0; uart_tx_pulse <= 0; end
        else begin
            uart_tx_pulse <= 0;
            if (uart_mmio_write) begin
                uart_tx_data <= dmem_write_data[7:0];
                uart_tx_pulse <= 1;
            end
        end
    end
    uart_tx #(.BPS_NUM(16'd233)) u_uart_tx(
        .clk(clk), .tx_data(uart_tx_data), .tx_pluse(uart_tx_pulse),
        .uart_tx(uart_tx), .tx_busy(uart_tx_busy)
    );

    assign dmem_read_data = uart_mmio_read ? {31'b0, uart_tx_busy} :
                            cycle_counter_read ? cycle_counter :
                            (dmem_addr < FLASH_LIMIT) ? dmem_flash_data :
                            (dmem_addr >= RAM_BASE && dmem_addr < RAM_LIMIT) ? dmem[dmem_addr[14:2]] :
                            32'b0;

    riscv_core u_cpu(
        .clk(clk), .rst_n(rst_n_synced), .imem_addr(imem_addr), .imem_data(imem_data),
        .dmem_addr(dmem_addr), .dmem_write_en(dmem_write_en),
        .dmem_write_strb(dmem_write_strb), .dmem_write_data(dmem_write_data),
        .dmem_read_data(dmem_read_data)
    );

    reg [31:0] prev_pc;
    reg [27:0] activity_cnt;
    always @(posedge clk or negedge rst_n_synced) begin
        if (!rst_n_synced) begin prev_pc <= 32'hFFFFFFFF; activity_cnt <= 0; end
        else begin
            prev_pc <= imem_addr;
            if (imem_addr != prev_pc) activity_cnt <= activity_cnt + 1'b1;
        end
    end
    assign led = {3'b000, activity_cnt[26]};
endmodule
