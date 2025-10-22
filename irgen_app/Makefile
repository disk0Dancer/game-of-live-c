.PHONY: all build run clean

LLVM_CONFIG := /opt/homebrew/opt/llvm/bin/llvm-config
CXX := clang++

CXXFLAGS := $(shell $(LLVM_CONFIG) --cxxflags) -std=c++17
LDFLAGS := $(shell $(LLVM_CONFIG) --ldflags --libs core executionengine native)
LDFLAGS += -I/opt/homebrew/include/SDL2 -D_THREAD_SAFE
LDFLAGS += -L/opt/homebrew/lib -lSDL2 -Wl,-rpath,/opt/homebrew/lib

SRC := app_ir_gen.cpp
SIM_SRC := ../sim_app/sim.c
TARGET := app_ir_gen

all: build

build: $(TARGET)

$(TARGET): $(SRC) $(SIM_SRC)
	$(CXX) $(CXXFLAGS) $(SRC) $(SIM_SRC) -o $(TARGET) $(LDFLAGS)

run: build
	./$(TARGET)

clean:
	rm -f $(TARGET)
