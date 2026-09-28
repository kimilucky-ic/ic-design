`timescale 1ns/1ps

module tb_uart_tx;
    localparam integer BPS_NUM = 16'd9;
    reg clk = 1'b0;
    reg [7:0] tx_data = 8'h41;
    reg tx_pluse = 1'b0;
    wire uart_tx;
    wire tx_busy;

    uart_tx #(.BPS_NUM(BPS_NUM)) dut (
        .clk(clk),
        .tx_data(tx_data),
        .tx_pluse(tx_pluse),
        .uart_tx(uart_tx),
        .tx_busy(tx_busy)
    );

    always #5 clk = ~clk;

    initial begin
        repeat (3) @(posedge clk);
        tx_pluse <= 1'b1;
        @(posedge clk);
        tx_pluse <= 1'b0;

        // Start bit, eight data bits (LSB first), stop bit.
        repeat (BPS_NUM + 1) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART start bit failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b1) $fatal(1, "UART bit 0 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 1 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 2 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 3 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 4 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 5 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b1) $fatal(1, "UART bit 6 failed");
        repeat (BPS_NUM) @(posedge clk);
        if (uart_tx !== 1'b0) $fatal(1, "UART bit 7 failed");
        repeat (BPS_NUM) @(posedge clk);
        repeat (2) @(posedge clk);
        if (uart_tx !== 1'b1) $fatal(1, "UART stop bit failed");

        $display("UART_TX_TEST: PASS byte=0x41");
        $finish;
    end
endmodule
