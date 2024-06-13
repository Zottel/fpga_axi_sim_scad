#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

verilator --cc cpp/vitis_verilator.cpp \
          verilog/*.v \
          --sv verilog/*.sv \
          --top-module top \
          --exe --trace

make --silent -C obj_dir -f Vtop.mk

PROGMEM=./mem_progmem.bin
GMEM=./mem_gmem.bin

for MEM in "${PROGMEM}" "${GMEM}"
do
	if [[ -f "${MEM}" ]]
	then
			touch "${MEM}"
	fi
	truncate -s 16M "${MEM}"
done

# For debugging, add
# gdb -ex run -ex quit --args
# in front of the execution.
time \
./obj_dir/Vtop --progmem="${PROGMEM}" \
               --gmem="${GMEM}" \
               --trace-vcd-file=./trace.vcd \
               --random-divisor=0 --random-seed=0
# random-divisor changes the chance of memory transfers happenning.
# (--random-divisor=128 means 1/128 chance.)

echo

for MEM in "${PROGMEM}" "${GMEM}"
do
	echo "${MEM} after execution:"
	echo xxd -g 8 -c 8 -l 128 ${MEM}
	xxd -g 8 -c 8 -l 128 ${MEM}
	echo
done


