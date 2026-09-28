`timescale 1ns/1ps
module tb_uart_cpu_load_use;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    wire [3:0] led;
    wire uart_tx;
    integer i, bitno;
    reg [7:0] received;
    reg [7:0] expected [0:14];

    fpga_top dut (.clk(clk), .rst_n(rst_n), .led(led), .uart_tx(uart_tx));
    always #5 clk = ~clk;

    initial begin
        expected[0]="L"; expected[1]="O"; expected[2]="A"; expected[3]="D";
        expected[4]="_"; expected[5]="U"; expected[6]="S"; expected[7]="E";
        expected[8]="_"; expected[9]="P"; expected[10]="A"; expected[11]="S";
        expected[12]="S"; expected[13]=8'h0d; expected[14]=8'h0a;
        repeat (4) @(posedge clk);
        rst_n <= 1'b1;
        for (i=0; i<15; i=i+1) begin
            @(negedge uart_tx);
            repeat (117) @(posedge clk);
            if (uart_tx !== 1'b0) $fatal(1,"byte %0d start bit invalid",i);
            for (bitno=0; bitno<8; bitno=bitno+1) begin
                repeat (234) @(posedge clk);
                received[bitno] = uart_tx;
            end
            repeat (234) @(posedge clk);
            if (uart_tx !== 1'b1) $fatal(1,"byte %0d stop bit invalid",i);
            if (received !== expected[i])
                $fatal(1,"byte %0d got 0x%02h expected 0x%02h",i,received,expected[i]);
            $display("LOAD_USE_BYTE[%0d]: 0x%02h",i,received);
        end
        $display("CPU_LOAD_USE_UART_TEST: PASS LOAD_USE_PASS");
        $finish;
    end

    initial begin
        #100000000;
        $fatal(1,"load-use UART test timeout (FAIL marker or stopped CPU)");
    end
endmodule
