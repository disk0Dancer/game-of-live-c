#define SIM_X_SIZE 512
#define SIM_Y_SIZE 512
#define CELL_SIZE 4
#define GRID_W (SIM_X_SIZE / CELL_SIZE)
#define GRID_H (SIM_Y_SIZE / CELL_SIZE)

void simFlush();
void simClear(int argb);
void simPutPixel(int x, int y, int argb);
int simRand();
void simInit();
void simExit();
void app();