if {[file exists work_mmio]} { vdel -lib work_mmio -all }
vlib work_mmio
vlog -mfcu -work work_mmio +incdir+../source/common \
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
    ../sim/instr_rom_uart_mmio_test.v \
    ../sim/tb_uart_mmio.v
vsim -c work_mmio.tb_uart_mmio -do "run -all; quit -f"