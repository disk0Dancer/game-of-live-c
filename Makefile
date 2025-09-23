.PHONY: build up clean

sim-build:
	clang sim_app/*.c -o build/app \
      -I/opt/homebrew/include/SDL2 -D_THREAD_SAFE \
      -L/opt/homebrew/lib -lSDL2 \
      -Wl,-rpath,/opt/homebrew/lib

sim-up: sim-build
	./build/app

clean:
	rm -f build/*

fmt:
	clang-format -i **/*.c **/*.h
