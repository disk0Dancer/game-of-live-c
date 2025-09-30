# 1 "sim_app/start.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 424 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "sim_app/start.c" 2
# 1 "sim_app/sim.h" 1






void simFlush();
void simClear(int argb);
void simPutPixel(int x, int y, int argb);
int simRand();
void simInit();
void simExit();
void app();
# 2 "sim_app/start.c" 2

int main() {
    simInit();
    app();
    simExit();
    return 0;
}
