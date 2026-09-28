`timescale 1ns / 1ps

// UART transmitter with byte latching at the rising edge of tx_pluse.
module uart_tx #(
    parameter BPS_NUM = 16'd233
)(
    input          clk,
    input  [7:0]    tx_data,
    input          tx_pluse,
    output reg     uart_tx,
    output         tx_busy
);
    reg             tx_en = 1'b0;
    reg [15:0]      clk_div_cnt = 16'd0;
    reg [2:0]       tx_bit_cnt = 3'd0;
    reg [2:0]       tx_state = 3'd0;
    reg [2:0]       tx_state_n = 3'd0;
    reg             tx_pluse_reg = 1'b0;
    reg [7:0]       tx_data_reg = 8'h00;

    localparam IDLE       = 3'h0;
    localparam SEND_START = 3'h1;
    localparam SEND_DATA  = 3'h2;
    localparam SEND_STOP  = 3'h3;
    localparam SEND_END   = 3'h4;

    assign tx_busy = (tx_state != IDLE);

    always @(posedge clk)
        tx_pluse_reg <= tx_pluse;

    always @(posedge clk) begin
        if (~tx_pluse_reg & tx_pluse) begin
            tx_en       <= 1'b1;
            tx_data_reg <= tx_data;
        end else if (tx_state == SEND_END) begin
            tx_en <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (clk_div_cnt == BPS_NUM || (~tx_pluse_reg & tx_pluse))
            clk_div_cnt <= 16'd0;
        else
            clk_div_cnt <= clk_div_cnt + 16'd1;
    end

    always @(posedge clk) begin
        if (!tx_en)
            tx_bit_cnt <= 3'd0;
        else if ((tx_bit_cnt == 3'd7) && (clk_div_cnt == BPS_NUM))
            tx_bit_cnt <= 3'd0;
        else if ((tx_state == SEND_DATA) && (clk_div_cnt == BPS_NUM))
            tx_bit_cnt <= tx_bit_cnt + 3'd1;
    end

    always @(posedge clk)
        tx_state <= tx_state_n;

    always @(*) begin
        case (tx_state)
            IDLE:       tx_state_n = (~tx_pluse_reg & tx_pluse) ? SEND_START : IDLE;
            SEND_START: tx_state_n = (clk_div_cnt == BPS_NUM) ? SEND_DATA : SEND_START;
            SEND_DATA:  tx_state_n = (tx_bit_cnt == 3'd7 && clk_div_cnt == BPS_NUM) ? SEND_STOP : SEND_DATA;
            SEND_STOP:  tx_state_n = (clk_div_cnt == BPS_NUM) ? SEND_END : SEND_STOP;
            SEND_END:   tx_state_n = IDLE;
            default:    tx_state_n = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (tx_en) begin
            case (tx_state)
                IDLE:       uart_tx <= 1'b1;
                SEND_START: uart_tx <= 1'b0;
                SEND_DATA:  uart_tx <= tx_data_reg[tx_bit_cnt];
                SEND_STOP:  uart_tx <= 1'b1;
                default:    uart_tx <= 1'b1;
            endcase
        end else begin
            uart_tx <= 1'b1;
        end
    end
endmodule
