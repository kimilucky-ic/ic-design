if {[file exists work_uart]} { vdel -lib work_uart -all }
vlib work_uart
vlog -work work_uart ../source/uart_tx.v ../sim/tb_uart_tx.v
vsim -c work_uart.tb_uart_tx -do "run -all; quit -f"