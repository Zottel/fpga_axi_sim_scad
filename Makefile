ECHO=@echo
.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make pack_kernel"
	$(ECHO) "      Command to pack the module krnl_scad to Vitis kernel"
	$(ECHO) ""
	$(ECHO) "  make build_hw"
	$(ECHO) "      Command to build xclbin files for Alveo platform, including krnl_scad and krnl_aes kernels"
	$(ECHO) ""
	$(ECHO) "  make vitis_opencl"
	$(ECHO) "      Command to build host executable which loads and starts the xclbin."
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."


PART := xcu50-fsvh2104-2-e
PLATFORM := xilinx_u50_gen3x16_xdma_201920_3
TARGET := hw
VIVADO := $(XILINX_VIVADO)/bin/vivado
BUILD_DIR := ./build
XO_FILE := $(BUILD_DIR)/scad.xo
XCLBIN_FILE := $(BUILD_DIR)/scad.xclbin

.phony: clean

pack_kernel:
	mkdir -p $(BUILD_DIR)
	$(VIVADO) -mode batch -source ./tcl/gen_xo.tcl -tclargs $(XO_FILE) $(TARGET) $(PART)

XOCDIRFLAGS := --report_dir $(BUILD_DIR)/reports --temp_dir $(BUILD_DIR)
XOCCFLAGS := --platform $(PLATFORM) -t $(TARGET)  -s -g --vivado.impl.jobs 32 --vivado.synth.jobs 32
XOCCLFLAGS := --link --optimize 3

build_hw:
	v++ $(XOCDIRFLAGS) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) -o $(XCLBIN_FILE) $(XO_FILE)


CXXFLAGS := -std=c++17 -Wno-deprecated-declarations
CXXFLAGS += -I$(XILINX_XRT)/include
LDFLAGS := -L$(XILINX_XRT)/lib
LDFLAGS += $(LDFLAGS) -lxrt_coreutil -lpthread -lOpenCL
EXECUTABLE := vitis_opencl
CPP_SRCS := ./cpp/vitis_opencl.cpp ./cpp/xcl2.cpp

build_sw: $(EXECUTABLE)

$(EXECUTABLE): $(CPP_SRCS) Makefile
	$(CXX) -o $(EXECUTABLE) $(filter %cpp,$^) $(CXXFLAGS) $(LDFLAGS)

all: pack_kernel build_hw $(EXECUTABLE)

clean:
	$(RM) -rf build
	$(RM) -f *.log *.jou
	$(RM) -f vitis_opencl
	$(RM) -rf .ipcache .Xil

