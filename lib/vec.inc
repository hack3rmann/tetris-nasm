%ifndef _TETRIS_LIB_VEC_
%define _TETRIS_LIB_VEC_



struc VecU32
    .ptr        resd 1
    .len        resd 1
    .cap        resd 1
    .sizeof     equ $-.ptr
endstruc

extern VecU32_new, VecU32_with_capacity, VecU32_drop, VecU32_push



%endif ; !_TETRIS_LIB_VEC_