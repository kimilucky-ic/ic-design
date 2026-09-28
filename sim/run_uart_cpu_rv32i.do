if {[file exists work_cpu_rv32i]} { vdel -lib work_cpu_rv32i -all }
vlib work_cpu_rv32i
vlog -mfcu -work work_cpu_rv32i +incdir+../source/common \
    ../source/common/config.v \
    ../source/common/defines.v \
    ../source/decode/decoder.v \
    ../source/decode/imm_gen.v \
    ../source/execution/alu.v \
    ../source/regfile/register_file.v \
    ../source/core/fetch_stage.v \
    ../source/core/decode_stage.v \
    ../source/core/execute_stage.v \
    ../source/core/memory_stage.v \
    ../source/core/writeback_stage.v \
    ../source/core/branch_unit.v \
    ../source/core/hazard_ctrl.v \
    ../source/core/forward_unit.v \
    ../source/top/riscv_core.v \
    ../source/uart_tx.v \
    ../source/fpga_top.v \
    instr_rom_cpu_rv32i.v \
    tb_uart_cpu_rv32i.v
vsim -c work_cpu_rv32i.tb_uart_cpu_rv32i -do "run -all; quit -f"
