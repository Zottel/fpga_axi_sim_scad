#!/usr/bin/env python3
import os, sys

base_path = os.path.dirname(os.path.realpath(__file__))
input_file = os.path.join(base_path, "cpp", "vitis_verilator.cpp")
output_file = os.path.join(base_path, "example", "cpp", "vitis_verilator")

# Top-level design module.
# Later replaces insert_module_name_here
module_name = "derp"

# Define the AXI memories connected to the simulated design.
# Later replace insert_memory_name_here and insert_memory_width_here
memories = [
    ("progmem", 256),
    ("gmem", 64),
]


f_in = open(input_file,'r')
f_out = open(output_file,'w')

# Iterate lines. We use manual iterator advancement since we access the iterator
# also in a nested loop that reads and copies marked code blocks.
while (l := next(f_in, None)) is not None:
    if not 'COPY MEMORY BELOW' in l:
        l = l.replace("insert_module_name_here", module_name)
        sys.stdout.write(l)
        f_out.write(l)
    else:
        # Read code block into buffer-
        block = []
        while (l := next(f_in, None)) is not None and not 'COPY MEMORY ABOVE' in l:
            block.append(l)

        # Copy the code block for each memory with specific replacements.
        for (mem_name, mem_width) in memories:
            mem_width = str(mem_width)

            for block_l in block:
                block_l = block_l.replace("insert_module_name_here", module_name)
                block_l = block_l.replace("insert_memory_name_here", mem_name)
                block_l = block_l.replace("insert_memory_width_here", mem_width)
                sys.stdout.write(block_l)
                f_out.write(block_l)

