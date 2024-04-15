%ifndef _TETRIS_LIB_VEC_
%define _TETRIS_LIB_VEC_

%include "lib/mem.inc"



struc Vec32
    .ptr        resd 1
    .len        resd 1
    .cap        resd 1
    .sizeof     equ ALIGNED($-.ptr)
endstruc

extern Vec32_new, Vec32_with_capacity, Vec32_drop, Vec32_push



struc Vec
    .ptr        resd 1
    .len        resd 1
    .cap        resd 1
    .elem_size  resd 1
    .sizeof     equ ALIGNED($-.ptr)
endstruc

extern Vec_new, Vec_with_capacity, Vec_drop, Vec_push, Vec_clear



%endif ; !_TETRIS_LIB_VEC_