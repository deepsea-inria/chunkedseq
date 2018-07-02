
PACKAGE_PATH=../../

PBENCH_PATH=$(PACKAGE_PATH)/pbench
CMDLINE_PATH=$(PACKAGE_PATH)/cmdline/include
CHUNKEDSEQ_PATH=$(PACKAGE_PATH)/chunkedseq/include

####################################################################
# Makefile options

# Create a file called "settings.sh" in this folder if you want to
# configure particular options. See section below for options.

-include settings.sh

####################################
# Example settings.sh 
#
# USE_HWLOC=1
# USE_CILK=1
# USE_32_BIT_WORD_SIZE=1
# CUSTOM_MALLOC_PREFIX=-ltcmalloc 
# CILK_EXTRAS_PREFIX=-L ../../../../cilk-plus-rts/lib -I ../../../../cilk-plus-rts/include -ldl -DCILK_RUNTIME_WITH_STATS
####################################

####################################################################

INCLUDE_FILES=$(wildcard *.hpp) $(wildcard $(CHUNKEDSEQ_PATH)/*.hpp) $(wildcard $(CMDLINE_PATH)/*.hpp) 

INCLUDE_DIRECTIVES=-I $(CHUNKEDSEQ_PATH) -I $(CMDLINE_PATH)

include $(PBENCH_PATH)/Makefile_common

WARNINGS_PREFIX=-Wno-subobject-linkage -Wno-overflow -Wno-format
COMMON_PREFIX=-std=c++1y $(WARNINGS_PREFIX) -ldl -DSKIP_MAP
DEBUG_PREFIX=$(COMMON_PREFIX) -g3 -Og
O2_PREFIX=-O2 -march=native -DNDEBUG -lm $(COMMON_PREFIX) $(CUSTOM_MALLOC_PREFIX)
BENCH_PREFIX=$(COMMON_OPT_PREFIX) $(O2_PREFIX)
CPP_FILES=microtime.cpp atomic.cpp

%.dbg: %.cpp $(INCLUDE_FILES)
	g++ $(DEBUG_PREFIX) $(INCLUDE_DIRECTIVES) $(CPP_FILES) -o $@ $<

%.exe: %.cpp $(INCLUDE_FILES)
	g++ $(BENCH_PREFIX) $(INCLUDE_DIRECTIVES) $(CPP_FILES) -o $@ $<

clean: pbench_clean
	rm -f *.dbg *.exe
