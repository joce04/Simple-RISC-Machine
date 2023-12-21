onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7_top_tb/SW
add wave -noupdate /lab7_top_tb/LEDR
add wave -noupdate /lab7_top_tb/DUT/clk
add wave -noupdate /lab7_top_tb/DUT/mem_cmd
add wave -noupdate /lab7_top_tb/DUT/mem_addr
add wave -noupdate /lab7_top_tb/DUT/CPU/sh
add wave -noupdate /lab7_top_tb/DUT/CPU/controller/current_state
add wave -noupdate /lab7_top_tb/DUT/CPU/instruction/instructionReg
add wave -noupdate /lab7_top_tb/DUT/CPU/sximm
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate -group Registers /lab7_top_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab7_top_tb/DUT/read_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 126
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {662 ps}
