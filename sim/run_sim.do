#==============================================================================
# ModelSim 仿真脚本 — RISC-V RV32I CPU 全指令集验证
# 用法: 在 ModelSim 中执行 do run_sim.do
# 或命令行: vsim -do run_sim.do
#==============================================================================

# 关闭 transcript 回显
quietly set EchoOnLines 0

# 创建工作库
if {[file exists work]} {
    vdel -all
}
vlib work

#==============================================================================
# 编译所有源文件（-mfcu 保证宏定义跨文件可见）
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
    ../source/tb_top.v

echo "=== 编译完成，启动仿真 ==="

#==============================================================================
# 启动仿真
#==============================================================================
vsim -L work work.tb_top

# 添加波形（可选，需要时取消注释）
# add wave -divider "Fetch"
# add wave tb_top/u_cpu/if_pc
# add wave tb_top/u_cpu/if_instr
# add wave -divider "Decode"
# add wave tb_top/u_cpu/id_pc
# add wave tb_top/u_cpu/id_instr
# add wave -divider "RegFile"
# add wave tb_top/u_cpu/u_regfile/regfile
# add wave -divider "Execute"
# add wave tb_top/u_cpu/ex_alu_result
# add wave -divider "Memory"
# add wave tb_top/u_cpu/mem_alu_result
# add wave -divider "Writeback"
# add wave tb_top/u_cpu/wb_rd_addr
# add wave tb_top/u_cpu/wb_rd_data
# add wave tb_top/u_cpu/wb_rd_we

# 运行到 $stop
run -all

echo ""
echo "=========================================="
echo "  仿真完成！查看 Transcript 窗口结果"
echo "  预期：所有寄存器值匹配 expect"
echo "=========================================="
