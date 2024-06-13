/**********
Copyright (c) 2018, Xilinx, Inc.
All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**********/

// #include "mio.hpp"
#include "argh.hpp"

#include "xcl2.hpp"
#include <memory>
#include <vector>
#include <iomanip>
#include <chrono>

#define MEMSIZE (((size_t) 1024) * ((size_t) 1024) * ((size_t) 128))

std::vector<std::pair<std::string, int>> memories = {
	// COPY MEMORY BELOW
	{"insert_memory_name_here", insert_memory_width_here},
	// COPY MEMORY ABOVE
};

void wait_for_enter(const std::string &msg) {
	std::cout << msg << std::endl;
	std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

int main(int argc, char **argv) {
	auto cmdl = argh::parser(argc, argv);
	
	if (cmdl[1].empty() || cmdl["--help"]) {
		std::cout << "Usage: " << cmdl[0] << " <XCLBIN File>" << std::endl;
		for (const auto& mem: memories) {
			std::cout << "         [ --" << mem.first << "=<filename> ]" << std::endl;
		}
		
		if (cmdl[1].empty()) {
			return EXIT_FAILURE;
		} else {
			return EXIT_SUCCESS;
		}
	}
	
	std::string binaryFile = cmdl[1];
	
	cl_int err;
	
	//OPENCL HOST CODE AREA START
	//Create Program and Kernel
	auto devices = xcl::get_xil_devices();
	auto device = devices[0];
	
	OCL_CHECK(err, cl::Context context(device, NULL, NULL, NULL, &err));
	OCL_CHECK(err,
		cl::CommandQueue q(context, device, CL_QUEUE_PROFILING_ENABLE, &err));
	
	auto device_name = device.getInfo<CL_DEVICE_NAME>();
	
	std::cout << "CL_DEVICE_NAME:                     " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
	std::cout << "CL_DEVICE_PLATFORM:                 " << device.getInfo<CL_DEVICE_PLATFORM>() << std::endl;
	std::cout << "CL_DEVICE_VENDOR:                   " << device.getInfo<CL_DEVICE_VENDOR>() << std::endl;
	std::cout << "CL_DEVICE_VERSION:                  " << device.getInfo<CL_DEVICE_VERSION>() << std::endl;
	std::cout << "CL_DRIVER_VERSION:                  " << device.getInfo<CL_DRIVER_VERSION>() << std::endl;
	std::cout << "CL_DEVICE_LOCAL_MEM_SIZE:           " << device.getInfo<CL_DEVICE_LOCAL_MEM_SIZE>() << std::endl;
	std::cout << "CL_DEVICE_GLOBAL_MEM_SIZE:          " << device.getInfo<CL_DEVICE_GLOBAL_MEM_SIZE>() << std::endl;
	std::cout << "CL_DEVICE_AVAILABLE:                " << device.getInfo<CL_DEVICE_AVAILABLE>() << std::endl;
	std::cout << "CL_DEVICE_COMPILER_AVAILABLE:       " << device.getInfo<CL_DEVICE_COMPILER_AVAILABLE>() << std::endl;
	std::cout << "CL_DEVICE_MAX_COMPUTE_UNITS:        " << device.getInfo<CL_DEVICE_MAX_COMPUTE_UNITS>() << std::endl;
	std::cout << "CL_DEVICE_MAX_CLOCK_FREQUENCY:      " << device.getInfo<CL_DEVICE_MAX_CLOCK_FREQUENCY>() << std::endl;
	std::cout << "CL_DEVICE_EXTENSIONS:               " << device.getInfo<CL_DEVICE_EXTENSIONS>() << std::endl;
	std::cout << "CL_DEVICE_ENDIAN_LITTLE:            " << device.getInfo<CL_DEVICE_ENDIAN_LITTLE>() << std::endl;
	std::cout << "CL_DEVICE_ADDRESS_BITS:             " << device.getInfo<CL_DEVICE_ADDRESS_BITS>() << std::endl;
	std::cout << "CL_DEVICE_MAX_CONSTANT_ARGS:        " << device.getInfo<CL_DEVICE_MAX_CONSTANT_ARGS>() << std::endl;
	std::cout << "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE: " << device.getInfo<CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE>() << std::endl;
	std::cout << "CL_DEVICE_MAX_MEM_ALLOC_SIZE:       " << device.getInfo<CL_DEVICE_MAX_MEM_ALLOC_SIZE>() << std::endl;
	std::cout << "CL_DEVICE_MAX_PARAMETER_SIZE:       " << device.getInfo<CL_DEVICE_MAX_PARAMETER_SIZE>() << std::endl;
	std::cout << "CL_DEVICE_MEM_BASE_ADDR_ALIGN:      " << device.getInfo<CL_DEVICE_MEM_BASE_ADDR_ALIGN>() << std::endl;
	std::cout << "CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE: " << device.getInfo<CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE>() << std::endl;
	
	auto fileBuf = xcl::read_binary_file(binaryFile);
	cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
	devices.resize(1);

	std::cout << "Initializing cl::Program" << std::endl;
	OCL_CHECK(err, cl::Program program(context, devices, bins, NULL, &err));
	std::cout << "CL_PROGRAM_KERNEL_NAMES: " << program.getInfo<CL_PROGRAM_KERNEL_NAMES>() << std::endl;

	std::cout << "Initializing cl::Kernel" << std::endl;
	OCL_CHECK(err, cl::Kernel krnl_scad(program, "krnl_scad", &err));
	std::cout << "CL_KERNEL_FUNCTION_NAME: " << krnl_scad.getInfo<CL_KERNEL_FUNCTION_NAME>() << std::endl;
	std::cout << "CL_KERNEL_NUM_ARGS:      " << krnl_scad.getInfo<CL_KERNEL_NUM_ARGS>() << std::endl;
	std::cout << "CL_KERNEL_ATTRIBUTES:    " << krnl_scad.getInfo<CL_KERNEL_ATTRIBUTES>() << std::endl;
	
	//wait_for_enter("Attach debugger now?");
	
	std::vector<std::unique_ptr<std::vector<uint8_t, aligned_allocator<uint8_t>>>> vector_memories;
	cl::vector<cl::Buffer> cl_buffers;
	
	for (const auto& mem: memories) {
		std::cout << "Creating buffer for " << mem.first << std::endl;
		std::unique_ptr<std::vector<uint8_t, aligned_allocator<uint8_t>>> vec;
		
		std::string mem_param = cmdl(std::string("--") + mem.first).str();
		if (!mem_param.empty()) {
			std::cout << "Copying data from " << mem_param << " to buffer for " << mem.first << std::endl;
			auto vec_in = xcl::read_binary_file(mem_param);
			vec = std::make_unique<std::vector<uint8_t, aligned_allocator<uint8_t>>>(vec_in.size(), aligned_allocator<uint8_t>());
			for (size_t i = 0; i < vec_in.size(); i++) {
				(*vec)[i] = vec_in[i];
			}
		} else {
			vec = std::make_unique<std::vector<uint8_t, aligned_allocator<uint8_t>>>(MEMSIZE, aligned_allocator<uint8_t>());
		}
		
		OCL_CHECK(err,
		    cl_buffers.push_back(cl::Buffer(
		          context,
		          CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
		          //CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY,
		          vec->size() * sizeof(uint8_t),
		          vec->data(),
		          &err
		        )));
		
		for (size_t i = 0; i < vec->size() && i < 32; i++) {
			std::cout << std::hex << std::setfill('0') << std::setw(2)
			          << (int) (*vec)[i];
		}
		std::cout << "..." << std::endl;
		vector_memories.push_back(std::move(vec));
	}
	
	for (size_t index = 0; index < memories.size(); index++) {
		std::cout << "Flags of " << memories[index].first << " after init" << std::endl;
		std::cout << "CL_MEM_SIZE:            " << cl_buffers[index].getInfo<CL_MEM_SIZE>() << std::endl;
		std::cout << "CL_MEM_HOST_PTR:        " << (void *) cl_buffers[index].getInfo<CL_MEM_HOST_PTR>() << std::endl;
		std::cout << "CL_MEM_MAP_COUNT:       " << cl_buffers[index].getInfo<CL_MEM_MAP_COUNT>() << std::endl;
		std::cout << "CL_MEM_REFERENCE_COUNT: " << cl_buffers[index].getInfo<CL_MEM_REFERENCE_COUNT>() << std::endl;
	}

	std::cout << "Setting kernel arguments." << std::endl;
	//Set the Kernel Arguments
	for (size_t i = 0; i < cl_buffers.size(); i++) {
		OCL_CHECK(err, err = krnl_scad.setArg(i, cl_buffers[i]));
	}
	
	std::cout << "Migrating buffers to device." << std::endl;
	for (int i = 0; i < cl_buffers.size(); i++) {
		OCL_CHECK(err,
				err = q.enqueueMigrateMemObjects({cl_buffers[i]},
					0 /* 0 means from host*/));
	}
	
	OCL_CHECK(err, err = q.finish());
	
	//wait_for_enter("Attach debugger now?");
	
	std::cout << "Launching kernel." << std::endl;
	
	using Clock = std::chrono::high_resolution_clock;
	auto before = Clock::now();
	//Launch the Kernel
	OCL_CHECK(err, err = q.enqueueTask(krnl_scad));
	
	OCL_CHECK(err, err = q.finish());
	auto after = Clock::now();
	
	std::cout << "Kernel ran for " << std::dec <<  std::chrono::duration_cast<std::chrono::milliseconds>(after-before).count() << "ms" << std::endl;
	
	std::cout << "Migrating buffers back from device.." << std::endl;
	for (int i = 0; i < cl_buffers.size(); i++) {
		OCL_CHECK(err,
				err = q.enqueueMigrateMemObjects({cl_buffers[i]},
					CL_MIGRATE_MEM_OBJECT_HOST /* 0 means from host*/));
	}
	OCL_CHECK(err, err = q.finish());
	
	for (size_t index = 0; index < memories.size(); index++) {
		std::cout << "Content of " << memories[index].first << " after run" << std::endl;
		for (size_t i = 0; i < vector_memories[index]->size() && i < 1024; i++) {
			std::cout << std::hex << std::setfill('0') << std::setw(2)
			          << (int) (*vector_memories[index])[i];
			
			if ((i % 8) == 7) {
				std::cout << " ";
			}
			if ((i % 32) == 31) {
				std::cout << std::endl;
			}
		}
		std::cout << "..." << std::endl;
	}
	
	//OPENCL HOST CODE AREA END
	
	//return (match ? EXIT_FAILURE : EXIT_SUCCESS);
	return (EXIT_SUCCESS);
}
