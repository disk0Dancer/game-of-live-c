#include "sim.h"

#include <SDL.h>
#include <assert.h>
#include <stdlib.h>
#include <time.h>

#define FRAME_TICKS 50

static SDL_Renderer *Renderer = NULL;
static SDL_Window *Window = NULL;
static int Ticks = 0;

static void unpack_argb_int(int argb, int *r, int *g, int *b, int *a) {
    *a = (argb >> 24) & 255;
    *r = (argb >> 16) & 255;
    *g = (argb >> 8) & 255;
    *b = argb & 255;
}

void simInit(void) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        SDL_Log("SDL_Init failed: %s", SDL_GetError());
        exit(1);
    }
    if (SDL_CreateWindowAndRenderer(SIM_X_SIZE, SIM_Y_SIZE, 0, &Window, &Renderer) != 0) {
        SDL_Log("SDL_CreateWindowAndRenderer failed: %s", SDL_GetError());
        exit(1);
    }
    simClear(0xFF000000);
    SDL_RenderPresent(Renderer);
    Ticks = (int)SDL_GetTicks();
    srand((unsigned)time(NULL));
}

void simExit() {
    SDL_Event event;
    while (1) {
        if (SDL_PollEvent(&event) && event.type == SDL_QUIT)
            break;
    }
    if (Renderer)
        SDL_DestroyRenderer(Renderer);
    if (Window)
        SDL_DestroyWindow(Window);
    SDL_Quit();
}

void simFlush(void) {
    SDL_PumpEvents();
    assert(SDL_TRUE != SDL_HasEvent(SDL_QUIT) && "User-requested quit");
    uint32_t cur_ticks = SDL_GetTicks() - Ticks;
    if (cur_ticks < FRAME_TICKS) {
        SDL_Delay(FRAME_TICKS - cur_ticks);
    }
    SDL_RenderPresent(Renderer);
}

void simClear(int argb) {
    int r, g, b, a;
    unpack_argb_int(argb, &r, &g, &b, &a);
    SDL_SetRenderDrawColor(Renderer, (unsigned char)r, (unsigned char)g, (unsigned char)b,
                           (unsigned char)a);
    SDL_RenderClear(Renderer);
}

void simPutPixel(int x, int y, int argb) {
    assert(0 <= x && x < SIM_X_SIZE && "Out of range");
    assert(0 <= y && y < SIM_Y_SIZE && "Out of range");
    int r, g, b, a;
    unpack_argb_int(argb, &r, &g, &b, &a);
    SDL_SetRenderDrawColor(Renderer, r, g, b, a);
    SDL_RenderDrawPoint(Renderer, x, y);
    Ticks = SDL_GetTicks();
}

void simFillRect(int x, int y, int w, int h, int argb) {
    if (w <= 0 || h <= 0)
        return;
    if (x >= SIM_X_SIZE || y >= SIM_Y_SIZE)
        return;
    if (x + w <= 0 || y + h <= 0)
        return;

    int r, g, b, a;
    unpack_argb_int(argb, &r, &g, &b, &a);
    SDL_SetRenderDrawColor(Renderer, (unsigned char)r, (unsigned char)g, (unsigned char)b,
                           (unsigned char)a);
    SDL_Rect rc = {x, y, w, h};
    SDL_RenderFillRect(Renderer, &rc);
}

int simRand(void) { return rand(); }