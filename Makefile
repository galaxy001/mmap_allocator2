CC ?= gcc
CFLAGS = -O3
OFLAGS = -Wall -fPIC 
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
	ls -l $(BIN_DIR)

# Clean the built directory
.PHONY: clean dump_commands all test
clean:
	rm -rf $(OBJ_DIR) $(LIB_DIR) $(BIN_DIR)