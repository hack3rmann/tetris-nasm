%ifndef _TETRIS_GAME_
%define _TETRIS_GAME_

%include "lib/graphics.inc"



%define CellType_Empty  0
%define CellType_T      1
%define CellType_Z      2
%define CellType_L      3
%define CellType_O      4
%define CellType_S      5
%define CellType_I      6
%define CellType_R      7

%define BACKGROUND_COLOR    RGB(22, 22, 30)

%define FIGURE_SIZE             16

%define CELL_SIZE_PIXELS        28
%define CELL_PADDING_PIXELS     1
%define FIELD_WIDTH_PIXELS      (CELL_SIZE_PIXELS * GameField_WIDTH)
%define FIELD_HEIGHT_PIXELS     (CELL_SIZE_PIXELS * GameField_HEIGHT)

%define CollisionType_None                0
%define CollisionType_SideBoundary        1
%define CollisionType_BottomBoundary      2
%define CollisionType_GamePiece           3



section .rodata align 4
    FIGURES:
        .empty  db 0, 0, 0, 0, \
                   0, 0, 0, 0, \
                   0, 0, 0, 0, \
                   0, 0, 0, 0
        .t  db 0, 0, 0, 0, \
               0, 0, 1, 0, \
               0, 1, 1, 1, \
               0, 0, 0, 0
        .z  db 0, 0, 0, 0, \
               0, 1, 1, 0, \
               0, 0, 1, 1, \
               0, 0, 0, 0
        .l  db 0, 1, 0, 0, \
               0, 1, 0, 0, \
               0, 1, 1, 0, \
               0, 0, 0, 0
        .o  db 0, 0, 0, 0, \
               0, 1, 1, 0, \
               0, 1, 1, 0, \
               0, 0, 0, 0
        .s  db 0, 0, 0, 0, \
               0, 0, 1, 1, \
               0, 1, 1, 0, \
               0, 0, 0, 0
        .i  db 0, 0, 1, 0, \
               0, 0, 1, 0, \
               0, 0, 1, 0, \
               0, 0, 1, 0
        .r  db 0, 1, 1, 0, \
               0, 1, 0, 0, \
               0, 1, 0, 0, \
               0, 0, 0, 0

    cell_colors     dd RGB(16,  16,  20),  RGB(146, 43,  140), \
                       RGB(213, 69,  73),  RGB(219, 106, 71),  \
                       RGB(228, 178, 143), RGB(68,  157, 158), \
                       RGB(96,  197, 255), RGB(10,  106, 186)
    
    Game_INITIAL_FALL_SPEED dd 2.0



struc Cell
    ; : CellType
    .type                   resb 1 + 3
    .sizeof                 equ $-.type
endstruc



%define GameField_WIDTH     10
%define GameField_HEIGHT    20
%define GameField_N_CELLS   (GameField_WIDTH * GameField_HEIGHT)

struc GameField
    ; : [Cell; Self::N_CELLS]
    .cells                  resb GameField_N_CELLS * Cell.sizeof
    .sizeof                 equ $-.cells
endstruc

extern GameField_new, GameField_draw, GameField_draw_cell



%define Game_DEFAULT_FIGURE_ROW (GameField_HEIGHT - 4)
%define Game_DEFAULT_FIGURE_COL (GameField_WIDTH / 2 - 2)

struc Game
    .field                  resb GameField.sizeof
    .cur_figure_type        resb 1 + 3
    .cur_figure             resb 16
    .figure_row             resd 1
    .figure_col             resd 1
    .fall_speed             resd 1
    .speed_multiplier       resd 1
    .last_fall_time         resd 1
    .moving_direction       resd 1
    .sizeof                 equ $-.field
endstruc

extern Game_new, Game_draw, Game_update, Game_set_moving_direction, Game_rotate



%endif ; !_TETRIS_GAME_