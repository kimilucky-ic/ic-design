`timescale 1ns/1ps
module tb_uart_cpu_rv32i;
    reg clk=1'b0;
    reg rst_n=1'b0;
    wire [3:0] led;
    wire uart_tx;
    integer i, bitno;
    reg [7:0] received;
    reg [7:0] expected [0:15];

    fpga_top dut(.clk(clk),.rst_n(rst_n),.led(led),.uart_tx(uart_tx));
    always #5 clk=~clk;

    initial begin
        expected[0]="C"; expected[1]="P"; expected[2]="U"; expected[3]="_";
        expected[4]="R"; expected[5]="V"; expected[6]="3"; expected[7]="2";
        expected[8]="I"; expected[9]="_"; expected[10]="P"; expected[11]="A";
        expected[12]="S"; expected[13]="S"; expected[14]=8'h0d; expected[15]=8'h0a;
        repeat(4) @(posedge clk);
        rst_n<=1'b1;
        for(i=0;i<16;i=i+1) begin
            @(negedge uart_tx);
            repeat(117) @(posedge clk);
            if(uart_tx!==1'b0) $fatal(1,"byte %0d invalid start bit",i);
            for(bitno=0;bitno<8;bitno=bitno+1) begin
                repeat(234) @(posedge clk);
                received[bitno]=uart_tx;
            end
            repeat(234) @(posedge clk);
            if(uart_tx!==1'b1) $fatal(1,"byte %0d invalid stop bit",i);
            if(received!==expected[i])
                $fatal(1,"byte %0d got 0x%02h expected 0x%02h",i,received,expected[i]);
            $display("RV32I_BYTE[%0d]: 0x%02h",i,received);
        end
        $display("CPU_RV32I_UART_TEST: PASS CPU_RV32I_PASS (16 bytes)");
        $finish;
    end

    initial begin
        #100000000;
        $fatal(1,"RV32I CPU test timeout or FAIL marker");
    end
endmodule
