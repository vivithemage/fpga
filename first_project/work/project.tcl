set projDir "/home/vivi/development/fpga/first_project/work/planAhead"
set projName "first_project"
set topName top
set device xc6slx9-2tqg144
if {[file exists "$projDir/$projName"]} { file delete -force "$projDir/$projName" }
create_project $projName "$projDir/$projName" -part $device
set_property design_mode RTL [get_filesets sources_1]
set verilogSources [list "/home/vivi/development/fpga/first_project/work/verilog/greeter.v" "/home/vivi/development/fpga/first_project/work/verilog/hello_world_rom.v" "/home/vivi/development/fpga/first_project/work/verilog/mojo_top.v" "/home/vivi/development/fpga/first_project/work/verilog/spi_slave.v" "/home/vivi/development/fpga/first_project/work/verilog/uart_rx.v" "/home/vivi/development/fpga/first_project/work/verilog/cclk_detector.v" "/home/vivi/development/fpga/first_project/work/verilog/avr_interface.v" "/home/vivi/development/fpga/first_project/work/verilog/uart_tx.v"]
import_files -fileset [get_filesets sources_1] -force -norecurse $verilogSources
set ucfSources [list "/home/vivi/development/fpga/first_project/constraint/mojo.ucf"]
import_files -fileset [get_filesets constrs_1] -force -norecurse $ucfSources
set_property top mojo_top [get_property srcset [current_run]]
set_property -name {steps.bitgen.args.More Options} -value {-g Binary:Yes -g Compress} -objects [get_runs impl_1]
update_compile_order -fileset sources_1
launch_runs -runs synth_1
wait_on_run synth_1
launch_runs -runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step Bitgen
wait_on_run impl_1
