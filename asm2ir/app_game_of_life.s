entry:
    ALLOC_ARRAYS x0 x1
    MOV x2 0
    CLEAR_ARRAY x0 16384
    MOV x3 0
rand_y_loop:
    MOV x4 0
rand_x_loop:
    RANDOMIZE_CELL x0 x4 x3 180
    INC_NEi x4 x4 128
    BR_COND x4 rand_x_loop rand_y_inc
rand_y_inc:
    INC_NEi x3 x3 128
    BR_COND x3 rand_y_loop main_loop
main_loop:
    MOV x3 0
draw_y_loop:
    MOV x4 0
draw_x_loop:
    GET_CELL x6 x0 x4 x3
    SELECT_COLOR x5 x6 0xFFFFFFFF 0xFF000000
    DRAW_CELL_4x4 x4 x3 x5
    INC_NEi x4 x4 128
    BR_COND x4 draw_x_loop draw_y_inc
draw_y_inc:
    INC_NEi x3 x3 128
    BR_COND x3 draw_y_loop flush_frame
flush_frame:
    FLUSH
    MOV x3 0
gen_y_loop:
    MOV x4 0
gen_x_loop:
    COUNT_NEIGHBORS x7 x0 x4 x3
    GET_CELL x6 x0 x4 x3
    GAME_OF_LIFE_RULE x5 x6 x7
    SET_CELL x1 x4 x3 x5
    INC_NEi x4 x4 128
    BR_COND x4 gen_x_loop gen_y_inc
gen_y_inc:
    INC_NEi x3 x3 128
    BR_COND x3 gen_y_loop copy_arrays
copy_arrays:
    COPY_ARRAY x0 x1 16384
    INC_NEi x2 x2 1000
    BR_COND x2 main_loop exit
exit:
    EXIT
