# ASM2IR генератор

два варианта ASM to LLVM IR транслятора для Game of Life

## файлы

- app_asm2ir_emul.cpp - версия с эмулирующими функциями
- app_asm2ir_full.cpp - версия с инлайном всего в IR
- app_game_of_life.s - игра на кастомном асме
- Makefile

## билд

```bash
make all
make clean
```

## запуск

```bash
./app_asm2ir_emul app_game_of_life.s
./app_asm2ir_full app_game_of_life.s
```

## формат ASM

### регистры
x0-x15 - 16 штук 32 битных
- x0 - обычно cur массив
- x1 - обычно nxt массив
- x2-x7 - счетчики циклов, координаты

### инструкции

массивы:
```
ALLOC_ARRAYS x0 x1          # выделить 2 массива по 16384
CLEAR_ARRAY x0 16384        # занулить
COPY_ARRAY x0 x1 16384      # скопировать
GET_CELL x6 x0 x4 x3        # читать ячейку
SET_CELL x1 x4 x3 x5        # записать ячейку
```

графика:
```
DRAW_CELL_4x4 x4 x3 x5      # нарисовать 4x4 пиксельную клетку
SELECT_COLOR x5 x6 0xFFFFFFFF 0xFF000000   # выбрать цвет
FLUSH                       # обновить экран
```

бизнес-логика:
```
COUNT_NEIGHBORS x7 x0 x4 x3     # посчитать соседей
GAME_OF_LIFE_RULE x5 x6 x7     # применить правила GoL
RANDOMIZE_CELL x0 x4 x3 180     # инит случайно (18%)
```

управление:
```
MOV x2 0                    # x2 = 0
INC_NEi x4 x4 128           # x4++; результат != 128
BR_COND x4 loop exit        # условный переход
EXIT                        # выход
```

метки:
```
entry:
    MOV x0 0
loop:
    INC_NEi x0 x0 10
    BR_COND x0 loop exit
exit:
    EXIT
```

## две реализации

app_asm2ir_emul - каждая инструкция вызывает C функцию
- проще
- легче дебажить
- пример: DRAW_CELL_4x4 → call @do_DRAW_CELL_4x4()

app_asm2ir_full - каждая инструкция разворачивается в IR
- оптимизируется лучше
- сложнее генерировать
- пример: DRAW_CELL_4x4 → 16 вызовов simPutPixel инлайнятся

## структура app_game_of_life.s

```
entry:
    ALLOC_ARRAYS x0 x1
    CLEAR_ARRAY x0 16384

rand_y_loop:                # рандомная инициализация
    RANDOMIZE_CELL ...

main_loop:                  # главный цикл 1000 итераций
draw_y_loop:                # отрисовка
    GET_CELL ...
    DRAW_CELL_4x4 ...

flush_frame:
    FLUSH

gen_y_loop:                 # вычисление поколения
    COUNT_NEIGHBORS ...
    GAME_OF_LIFE_RULE ...
    SET_CELL ...

copy_arrays:
    COPY_ARRAY x0 x1 16384

exit:
    EXIT
```

## grid

- 128x128 клеток = 16384 всего
- каждая клетка 4x4 пикселя
- экран 512x512
- два буфера cur (x0) и nxt (x1)

## заметки

- метки case-sensitive
- только регистры x0-x15
- цвета в hex 0xRRGGBBAA
