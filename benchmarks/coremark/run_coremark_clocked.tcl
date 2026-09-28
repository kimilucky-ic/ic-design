# Rebuild the archived 27 MHz CoreMark FPGA image from the release-candidate RTL.
set REPO_ROOT [file normalize [file join [file dirname [info script]] .. ..]]
cd $REPO_ROOT

add_design "source/common/config.v"
add_design "source/common/defines.v"
add_design "source/core/branch_unit.v"
add_design "source/core/decode_stage.v"
add_design "source/core/execute_stage.v"
add_design "source/core/fetch_stage.v"
add_design "source/core/forward_unit.v"
add_design "source/core/hazard_ctrl.v"
add_design "source/core/memory_stage.v"
add_design "source/core/writeback_stage.v"
add_design "source/decode/decoder.v"
add_design "source/decode/imm_gen.v"
add_design "source/execution/alu.v"
add_design "source/regfile/register_file.v"
add_design "source/top/riscv_core.v"
add_design "benchmarks/coremark/fpga/fpga_top_coremark.v"
add_design "benchmarks/coremark/rom/coremark_rom.v"
add_design "source/uart_tx.v"
add_constraint "source/fpga_top.fdc"
add_constraint "benchmarks/coremark/fpga/clock_27mhz.fdc"
set_global_include source/common/config.v true
set_global_include source/common/defines.v true
set_option max_threads 0
set_arch -family Logos2 -device PG2L200H -speedgrade -6 -package FBB676
set_option -options { top_module {fpga_top_coremark} top_library {work}} [get_filesets design_1]
launch_tasks [get_tasks {syn_1}] -to_action compile
wait_on_tasks [get_tasks {syn_1}] -to_action compile
launch_tasks [get_tasks {syn_1}] -to_action synthesize
wait_on_tasks [get_tasks {syn_1}] -to_action synthesize
launch_tasks [get_tasks {pnr_1}] -to_action dev_map
wait_on_tasks [get_tasks {pnr_1}] -to_action dev_map
launch_tasks [get_tasks {pnr_1}] -to_action place
wait_on_tasks [get_tasks {pnr_1}] -to_action place
launch_tasks [get_tasks {pnr_1}] -to_action route
wait_on_tasks [get_tasks {pnr_1}] -to_action route
launch_tasks [get_tasks {pnr_1}] -to_action route_optimize
wait_on_tasks [get_tasks {pnr_1}] -to_action route_optimize
launch_tasks [get_tasks {pnr_1}] -to_action report_timing
wait_on_tasks [get_tasks {pnr_1}] -to_action report_timing
launch_tasks [get_tasks {pnr_1}] -to_action gen_bit_stream
wait_on_tasks [get_tasks {pnr_1}] -to_action gen_bit_stream
