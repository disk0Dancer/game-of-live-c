.PHONY: build run clean fmt ir logger pass

SRC_DIR := sim_app
SRCS := $(wildcard $(SRC_DIR)/*.c)
BUILD_DIR := build
IR_DIR := ir
APP := $(BUILD_DIR)/app

CFLAGS := -I/opt/homebrew/include/SDL2 -D_THREAD_SAFE
LDFLAGS := -L/opt/homebrew/lib -lSDL2 -Wl,-rpath,/opt/homebrew/lib

build:
	mkdir -p $(BUILD_DIR)
	clang $(SRCS) -o $(APP) $(CFLAGS) $(LDFLAGS)

run: build
	./$(APP)

ir: build
	mkdir -p $(IR_DIR)
	clang -S -emit-llvm $(SRC_DIR)/app.c $(CFLAGS) -o $(IR_DIR)/app.ll
	clang -O1 -S -emit-llvm $(SRC_DIR)/app.c $(CFLAGS) -o $(IR_DIR)/app_O1.ll
	clang -O2 -S -emit-llvm $(SRC_DIR)/app.c $(CFLAGS) -o $(IR_DIR)/app_O2.ll
	clang -O3 -S -emit-llvm $(SRC_DIR)/app.c $(CFLAGS) -o $(IR_DIR)/app_O3.ll
	clang -Os -S -emit-llvm $(SRC_DIR)/app.c $(CFLAGS) -o $(IR_DIR)/app_Os.ll

logger:
	clang -c runtime_logger.c -o runtime_logger.o

pass: logger
	clang++ -shared -fPIC MyPass.cpp -o libpass.so \
		`/opt/homebrew/opt/llvm/bin/llvm-config --cxxflags --ldflags --libs core passes` -undefined dynamic_lookup

pass.apply: pass ir
	clang -fpass-plugin=./libpass.so -O1 $(SRC_DIR)/app.c $(SRC_DIR)/sim.c $(SRC_DIR)/start.c runtime_logger.o $(CFLAGS) $(LDFLAGS) -o my_app
	./my_app

clean:
	rm -f trace.txt relations.txt
	rm -rf $(BUILD_DIR) $(IR_DIR) *.o *.so my_app