%ifndef _TETRIS_LIB_NUMERIC_
%define _TETRIS_LIB_NUMERIC_



; ABS dst, tmp
%macro ABS 2
    mov %2, %1
    sar %2, 31
    xor %1, %2
    sub %1, %2
%endmacro



%endif ; !_TETRIS_LIB_NUMERIC_