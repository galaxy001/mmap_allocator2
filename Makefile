CC ?= gcc
CXX ?= g++
CFLAGS = -O3
CXXFLAGS = -std=gnu++20
OFLAGS = -Wall -fPIC -pthread
LDFLAGS = -shared

# gdb: set env LD_PRELOAD=/home/lzh/mmap_allocator/build/lib/libmmap_allocator.so

# Define the source and include directories
SRC_DIR = src
INCLUDE_DIR = include

# Define the output directories for built artifacts
OBJ_DIR = build/obj
LIB_DIR = build/lib
BIN_DIR = build/bin

# Define the library name
LIB_NAME = mmap_allocator

# Define the library source files and header files
LIB_SRCS = $(wildcard $(SRC_DIR)/*.c)
LIB_HDRS = $(wildcard $(INCLUDE_DIR)/*.h)
INC = -I$(INCLUDE_DIR)

# Define the object files
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(LIB_SRCS))

# Define the ISO output file
ISO_FILE = mmap_allocator.so

all: $(LIB_DIR)/lib$(LIB_NAME).so $(LIB_DIR)/lib$(LIB_NAME).a

# Build the library
$(LIB_DIR)/lib$(LIB_NAME).so: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	$(CC) $(LDFLAGS) -o $@ $^

$(LIB_DIR)/lib$(LIB_NAME).a: $(OBJ_FILES)
	mkdir -p $(LIB_DIR)
	ar r $@ $^

# Build the object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(LIB_HDRS)
	mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) $(OFLAGS) $(INC) -c $< -o $@

print-%:
	@echo $*=$($*)

dump_commands:
	@$(MAKE) -np --print-directory | grep -E 'gcc|\b$(CC)\b' > compile_commands.json

# Build the ISO
.PHONY: iso

test: $(LIB_DIR)/lib$(LIB_NAME).a
	mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $(OFLAGS) -pthread -fopenmp -fopenmp-simd -I. mmaptest/c_test.c $^ -o $(BIN_DIR)/c_test
	$(CXX) $(CFLAGS) $(CXXFLAGS) $(OFLAGS) -pthread -I. mmaptest/test.cpp $^ -o $(BIN_DIR)/cpp_test
	ls -l $(BIN_DIR)

run: $(BIN_DIR)/cpp_test
	ENV_PROFILE_FILE_PATH=stats_cpp.txt ENV_PROFILE_FREQUENCY=1 ENV_MMAP_ALLOCATOR_MIN_BSIZE=4 ENV_MMAP_HEAP_SIZE=1073741824 $(BIN_DIR)/cpp_test
	ENV_PROFILE_FILE_PATH=stats_cc.txt ENV_PROFILE_FREQUENCY=1 ENV_NAMING_TEMPLATE="/tmp/mmap_alloc.XXXXXXXX" ENV_MMAP_ALLOCATOR_MIN_BSIZE=4194304 ENV_MMAP_HEAP_SIZE=68719476736 $(BIN_DIR)/c_test

fmt:
	clang-format -i *.hpp

# Clean the built directory
.PHONY: clean dump_commands all test
clean:
	rm -rf $(OBJ_DIR) $(LIB_DIR) $(BIN_DIR)