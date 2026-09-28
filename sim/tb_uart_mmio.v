`timescale 1ns/1ps
module tb_uart_mmio;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    wire [3:0] led;
    wire uart_tx;
    integer i;
    reg [7:0] received;

    fpga_top dut (.clk(clk), .rst_n(rst_n), .led(led), .uart_tx(uart_tx));
    always #5 clk = ~clk;

    initial begin
        repeat (4) @(posedge clk);
        rst_n <= 1'b1;
        wait (uart_tx === 1'b0);
        // Sample the middle of the start bit, then the middle of each data bit.
        repeat (117) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "MMIO UART start bit failed");
        for (i = 0; i < 8; i = i + 1) begin
            repeat (234) @(posedge clk);
            received[i] = uart_tx;
        end
        repeat (117) @(posedge clk);
        repeat (2) @(posedge clk);
        if (uart_tx !== 1'b1) $fatal(1, "MMIO UART stop bit failed");
        if (received !== 8'h41)
            $fatal(1, "MMIO UART received 0x%02h, expected 0x41", received);
        $display("CPU_MMIO_UART_TEST: PASS byte=0x%02h", received);
        $finish;
    end

    initial begin
        #1000000;
        $fatal(1, "MMIO UART timeout");
    end
endmodule
