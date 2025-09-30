.PHONY: build run step clean fmt

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

ir:
	mkdir -p $(IR_DIR)
	for f in $(SRCS); do \
	  base=$$(basename $$f .c); \
	  clang -E $$f $(CFLAGS) > $(IR_DIR)/$$base.i; \
	  clang -S $$f $(CFLAGS) -o $(IR_DIR)/$$base.s; \
	  clang -S -emit-llvm $$f $(CFLAGS) -o $(IR_DIR)/$$base.ll; \
	  clang -c -emit-llvm $$f $(CFLAGS) -o $(IR_DIR)/$$base.bc; \
	  clang -c $$f $(CFLAGS) -o $(IR_DIR)/$$base.o; \
	done
	clang $(SRCS) -o $(IR_DIR)/app $(CFLAGS) $(LDFLAGS)

clean:
	rm -rf $(BUILD_DIR) $(IR_DIR)

fmt:
	clang-format -i $(SRC_DIR)/*.c $(SRC_DIR)/*.h
