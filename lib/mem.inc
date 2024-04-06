%ifndef _TETRIS_LIB_MEM_
%define _TETRIS_LIB_MEM_



%macro MEM_ZEROED 2
    %assign __i 0
    %rep %1.sizeof / 4
        mov dword [%2+__i], 0
    %assign __i __i+4
    %endrep
%endmacro



%endif ; !_TETRIS_LIB_MEM_
