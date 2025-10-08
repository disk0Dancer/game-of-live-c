#include "sim.h"
#include <string.h>

static int idx(int x, int y) { return y * GRID_W + x; }

static int wrap(int v, int max) {
    if (v < 0)
        return v + max;
    if (v >= max)
        return v - max;
    return v;
}

static int neighbors(const int *a, int x, int y) {
    int xm = wrap(x - 1, GRID_W), xp = wrap(x + 1, GRID_W);
    int ym = wrap(y - 1, GRID_H), yp = wrap(y + 1, GRID_H);
    return a[idx(xm, ym)] + a[idx(x, ym)] + a[idx(xp, ym)] + a[idx(xm, y)] + a[idx(xp, y)] +
           a[idx(xm, yp)] + a[idx(x, yp)] + a[idx(xp, yp)];
}

static void step_generation(int *dst, const int *src) {
    for (int y = 0; y < GRID_H; ++y) {
        for (int x = 0; x < GRID_W; ++x) {
            int n = neighbors(src, x, y);
            int alive = src[idx(x, y)] != 0;
            int next_alive = alive ? (n == 2 || n == 3) : (n == 3);
            dst[idx(x, y)] = next_alive;
        }
    }
}

static void randomize(int *cur, int permill) {
    for (int i = 0; i < GRID_W * GRID_H; ++i)
        cur[i] = ((simRand() % 1000) < permill) ? 1 : 0;
}

static void clear_all(int *cur) { memset(cur, 0, GRID_W * GRID_H * sizeof(int)); }

static void draw_cell(int cx, int cy, int argb) {
    int px = cx * CELL_SIZE;
    int py = cy * CELL_SIZE;
    for (int yy = 0; yy < CELL_SIZE; ++yy)
        for (int xx = 0; xx < CELL_SIZE; ++xx)
            simPutPixel(px + xx, py + yy, argb);
}

static void draw_frame(const int *cur) {
    const int ALIVE = 0xFFFFFFFF;
    const int DEAD = 0xFF000000;
    for (int y = 0; y < GRID_H; ++y)
        for (int x = 0; x < GRID_W; ++x)
            draw_cell(x, y, cur[idx(x, y)] ? ALIVE : DEAD);
}

void app(void) {
    int cur[GRID_W * GRID_H];
    int nxt[GRID_W * GRID_H];
    clear_all(cur);
    randomize(cur, 180);
    for (int step = 0; step < 1000; ++step) {
        draw_frame(cur);
        simFlush();
        step_generation(nxt, cur);
        for (int i = 0; i < GRID_W * GRID_H; ++i) {
            cur[i] = nxt[i];
        }
    }
}