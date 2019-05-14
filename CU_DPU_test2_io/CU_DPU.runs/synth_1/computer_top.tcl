# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.cache/wt [current_project]
set_property parent.project_path Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
set_property ip_output_repo z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/adder.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/alu.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/control_unit.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/data_path.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/flipflop.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/main_decoder.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/mem_data.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/mem_instructions.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/mux2.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/processor.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/registerfile.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/signextender.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/processor_top.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/shiftleft2.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/computer_top.vhd
  Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/sources_1/new/display_hex.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/constrs_1/imports/z/Nexys4DDR_Master.xdc
set_property used_in_implementation false [get_files Z:/CS-401-1-CompArch/MP4/CU_DPU_test2_io/CU_DPU.srcs/constrs_1/imports/z/Nexys4DDR_Master.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top computer_top -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef computer_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file computer_top_utilization_synth.rpt -pb computer_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
