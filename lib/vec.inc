%ifndef _TETRIS_LIB_VEC_
%define _TETRIS_LIB_VEC_



struc Vec32
    .ptr        resd 1
    .len        resd 1
    .cap        resd 1
    .sizeof     equ $-.ptr
endstruc

extern Vec32_new, Vec32_with_capacity, Vec32_drop, Vec32_push



%endif ; !_TETRIS_LIB_VEC_