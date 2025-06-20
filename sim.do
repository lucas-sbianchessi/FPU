# sim.do - Simulation script for FPU

# Compile design and testbench
vlog fpu.sv
vlog fpu_tb.sv

# Load the testbench in the simulator
vsim work.fpu_tb

# Add signals to the waveform window (optional)
add wave *
# add wave -position insertpoint sim:/fpu_tb/dut/mantissa_A

# Run the simulation for 1000 ns
run 1000ns

# Keep the simulation open (optional)
# quit -sim
