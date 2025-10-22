.PHONY: build run clean fmt ir logger pass collect.traces

SRC_DIR := sim_app
SRCS := $(wildcard $(SRC_DIR)/*.c)
BUILD_DIR := build
IR_DIR := ir
STATS_DIR := stats
APP := $(BUILD_DIR)/app

CFLAGS := -I/opt/homebrew/include/SDL2 -D_THREAD_SAFE
LDFLAGS := -L/opt/homebrew/lib -lSDL2 -Wl,-rpath,/opt/homebrew/lib

build:
	mkdir -p $(BUILD_DIR)
	clang $(SRCS) -o $(APP) $(CFLAGS) $(LDFLAGS)

run: build
	./$(APP)

ir:
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

LLVM_CLANG := /opt/homebrew/opt/llvm/bin/clang

collect.traces: pass ir
	mkdir -p $(STATS_DIR) $(BUILD_DIR)

	@rm -f trace.txt relations.txt
	$(LLVM_CLANG) -fpass-plugin=./libpass.so -O1 -c $(SRC_DIR)/app.c $(CFLAGS) -o $(BUILD_DIR)/app_O1.o
	clang $(BUILD_DIR)/app_O1.o $(SRC_DIR)/sim.c $(SRC_DIR)/start.c runtime_logger.o $(CFLAGS) $(LDFLAGS) -o my_app_O1
	./my_app_O1 &
	sleep 2
	killall my_app_O1 2>/dev/null || true
	@mv trace.txt $(STATS_DIR)/trace_O1.txt 2>/dev/null || echo "No trace.txt"
	@mv relations.txt $(STATS_DIR)/relations_O1.txt 2>/dev/null || echo "No relations.txt"

	@rm -f trace.txt relations.txt
	$(LLVM_CLANG) -fpass-plugin=./libpass.so -O2 -c $(SRC_DIR)/app.c $(CFLAGS) -o $(BUILD_DIR)/app_O2.o
	clang $(BUILD_DIR)/app_O2.o $(SRC_DIR)/sim.c $(SRC_DIR)/start.c runtime_logger.o $(CFLAGS) $(LDFLAGS) -o my_app_O2
	./my_app_O2 &
	sleep 2
	killall my_app_O2 2>/dev/null || true
	@mv trace.txt $(STATS_DIR)/trace_O2.txt 2>/dev/null || echo "No trace.txt"
	@mv relations.txt $(STATS_DIR)/relations_O2.txt 2>/dev/null || echo "No relations.txt"

	@rm -f trace.txt relations.txt
	$(LLVM_CLANG) -fpass-plugin=./libpass.so -O3 -c $(SRC_DIR)/app.c $(CFLAGS) -o $(BUILD_DIR)/app_O3.o
	clang $(BUILD_DIR)/app_O3.o $(SRC_DIR)/sim.c $(SRC_DIR)/start.c runtime_logger.o $(CFLAGS) $(LDFLAGS) -o my_app_O3
	./my_app_O3 &
	sleep 2
	killall my_app_O3 2>/dev/null || true
	@mv trace.txt $(STATS_DIR)/trace_O3.txt 2>/dev/null || echo "No trace.txt"
	@mv relations.txt $(STATS_DIR)/relations_O3.txt 2>/dev/null || echo "No relations.txt"

	@rm -f trace.txt relations.txt
	$(LLVM_CLANG) -fpass-plugin=./libpass.so -Os -c $(SRC_DIR)/app.c $(CFLAGS) -o $(BUILD_DIR)/app_Os.o
	clang $(BUILD_DIR)/app_Os.o $(SRC_DIR)/sim.c $(SRC_DIR)/start.c runtime_logger.o $(CFLAGS) $(LDFLAGS) -o my_app_Os
	./my_app_Os &
	sleep 2
	killall my_app_Os 2>/dev/null || true
	@mv trace.txt $(STATS_DIR)/trace_Os.txt 2>/dev/null || echo "No trace.txt"
	@mv relations.txt $(STATS_DIR)/relations_Os.txt 2>/dev/null || echo "No relations.txt"

clean:
	rm -f trace.txt relations.txt
	rm -rf $(BUILD_DIR) $(IR_DIR) $(STATS_DIR) *.o *.so my_app my_app_O1 my_app_O2 my_app_O3 my_app_Os