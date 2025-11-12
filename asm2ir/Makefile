LLVM_CONFIG := /opt/homebrew/opt/llvm/bin/llvm-config
CXX := clang++
CC := clang

CXXFLAGS := $(shell $(LLVM_CONFIG) --cxxflags) -std=c++17
LDFLAGS := $(shell $(LLVM_CONFIG) --ldflags --libs core irreader support)
LDFLAGS_SIM := $(shell $(LLVM_CONFIG) --ldflags --libs core executionengine native)
LDFLAGS_SIM += -I/opt/homebrew/include/SDL2 -D_THREAD_SAFE
LDFLAGS_SIM += -L/opt/homebrew/lib -lSDL2 -Wl,-rpath,/opt/homebrew/lib

APP_SRC := ../sim_app/app.c
SIM_SRC := ../sim_app/sim.c

all: app_asm2ir_emul app_asm2ir_full

app_asm2ir_emul: app_asm2ir_emul.cpp $(SIM_SRC)
	$(CXX) $(CXXFLAGS) $< $(SIM_SRC) -o $@ $(LDFLAGS_SIM)

app_asm2ir_full: app_asm2ir_full.cpp $(SIM_SRC)
	$(CXX) $(CXXFLAGS) $< $(SIM_SRC) -o $@ $(LDFLAGS_SIM)

test_emul: app_asm2ir_emul
	./app_asm2ir_emul app_game_of_life.s

test_full: app_asm2ir_full
	./app_asm2ir_full app_game_of_life.s

test: test_emul test_full

clean:
	rm -f app_asm2ir_emul app_asm2ir_full
