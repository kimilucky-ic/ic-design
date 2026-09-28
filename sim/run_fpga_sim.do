#==============================================================================
# ModelSim 仿真脚本 — FPGA Top 验证 (CPU + instr_rom + data_mem)
#==============================================================================

quietly set EchoOnLines 0

if {[file exists work]} {
    vdel -all
}
vlib work

#==============================================================================
# 编译所有源文件
#==============================================================================
vlog -mfcu -work work +incdir+../source/common \
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
    ../source/instr_rom.v \
    ../source/uart_tx.v \
    ../source/fpga_top.v \
    ../sim/tb_fpga_top.v

echo "=== 编译完成，启动仿真 ==="

vsim -L work work.tb_fpga_top

# 运行到 $stop
run -all
