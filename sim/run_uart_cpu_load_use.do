if {[file exists work_cpu_load_use]} { vdel -lib work_cpu_load_use -all }
vlib work_cpu_load_use
vlog -mfcu -work work_cpu_load_use +incdir+../source/common \
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
    instr_rom_cpu_uart_load_use.v \
    tb_uart_cpu_load_use.v
vsim -c work_cpu_load_use.tb_uart_cpu_load_use -do "run -all; quit -f"
