
VAR_TRUE=true


XCLBIN := ./xclbin_$(APP)
DSA := $(call device2sandsa, $(DEVICE))

CXX := $(XILINX_SDX)/bin/xcpp
XOCC := $(XILINX_SDX)/bin/xocc

include $(ABS_COMMON_REPO)/utils/opencl.mk



#--kernel_frequency <frequency>
#--xp prop:solution.kernel_compiler_margin=<Frequency Percentage>
#--xp param:compiler.enableAutoFrequencyScaling=0

HOST_SRCS = ./host_graph.cpp ./libgraph/graph.cpp ./libgraph/he_mem.cpp ./libgraph/data_helper.cpp
HOST_SRCS += ./libgraph/host_graph_sw_verification.cpp  ./libgraph/host_graph_sw.cpp
ifeq ($(strip $(HAVE_APPLY)), $(strip $(VAR_TRUE)))
HOST_SRCS += $(APPCONFIG)/host_vertex_apply.cpp
HOST_SRCS += ./libgraph/host_graph_apply_verification.cpp
endif

# Host compiler global settings
CXXFLAGS := $(opencl_CXXFLAGS) -Wall
CXXFLAGS += -I/$(XILINX_SDX)/Vivado_HLS/include/ -O3 -g -fmessage-length=0 -std=c++14 -Wno-deprecated-declarations
CXXFLAGS += -I ./
CXXFLAGS += -I ./libfpga
CXXFLAGS += -I ./libgraph
CXXFLAGS += -I $(APPCONFIG)

# Host linker flags
LDFLAGS := $(opencl_LDFLAGS)
LDFLAGS += -lrt -lstdc++  -lxilinxopencl


# Kernel compiler global settings
CLFLAGS = -t $(TARGET) --platform $(DEVICE) --save-temps  -O3
CLFLAGS += -I ./
CLFLAGS += -I ./libfpga
CLFLAGS += -I $(APPCONFIG)
CLFLAGS += --xp prop:solution.kernel_compiler_margin=10%

# Kernel linker flags
LDCLFLAGS += --xp prop:solution.kernel_compiler_margin=10% --kernel_frequency=280

EXECUTABLE = host_graph_fpga_$(APP)

EMCONFIG_DIR = $(XCLBIN)/$(DSA)

BINARY_CONTAINERS += $(XCLBIN)/graph_fpga.$(TARGET).$(DSA).xclbin


#Include Libraries

include $(ABS_COMMON_REPO)/xcl/xcl.mk
CXXFLAGS +=  $(xcl_CXXFLAGS)
LDFLAGS +=   $(xcl_CXXFLAGS)
HOST_SRCS += $(xcl_SRCS)

CP = cp -rf



GS_KERNEL_PATH    = ./libfpga/common
APPLY_KERNEL_PATH = $(APPCONFIG)



ifeq ($(strip $(HAVE_FULL_SLR)), $(strip $(VAR_TRUE)))
CXXFLAGS += -DSUB_PARTITION_NUM=4
else
CXXFLAGS += -DSUB_PARTITION_NUM=1
endif

ifeq ($(strip $(HAVE_APPLY)), $(strip $(VAR_TRUE)))
CXXFLAGS += -DHAVE_APPLY=1
else
CXXFLAGS += -DHAVE_APPLY=0
endif


ifeq ($(strip $(HAVE_VERTEX_ACTIVE_BIT)), $(strip $(VAR_TRUE)))
CXXFLAGS += -DHAVE_VERTEX_ACTIVE_BIT=1
CLFLAGS  += -DHAVE_VERTEX_ACTIVE_BIT=1
else
CXXFLAGS += -DHAVE_VERTEX_ACTIVE_BIT=0
CLFLAGS  += -DHAVE_VERTEX_ACTIVE_BIT=0
endif

ifeq ($(strip $(HAVE_EDGE_PROP)), $(strip $(VAR_TRUE)))
CXXFLAGS += -DHAVE_EDGE_PROP=1
CLFLAGS  += -DHAVE_EDGE_PROP=1
else
CXXFLAGS += -DHAVE_EDGE_PROP=0
CLFLAGS  += -DHAVE_EDGE_PROP=0
endif


ifeq ($(strip $(HAVE_UNSIGNED_PROP)), $(strip $(VAR_TRUE)))
CXXFLAGS += -DHAVE_UNSIGNED_PROP=1
CLFLAGS  += -DHAVE_UNSIGNED_PROP=1
else
CXXFLAGS += -DHAVE_UNSIGNED_PROP=0
CLFLAGS  += -DHAVE_UNSIGNED_PROP=0
endif
