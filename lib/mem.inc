%ifndef _TETRIS_LIB_MEM_
%define _TETRIS_LIB_MEM_



; MEM_ZEROED struct, ptr
%macro MEM_ZEROED 2
    %assign __i 0
    %rep %1.sizeof / 4
        mov dword [%2+__i], 0
    %assign __i __i+4
    %endrep
%endmacro

; MEM_COPY dst_ptr, src_ptr, n_bytes
%macro MEM_COPY 3
    push eax

    %assign __i 0
    %rep %3 / 4
        mov eax, dword [%2 + 4*i]
        mov dword [%1 + 4*i], eax
    %assign __i __i+1
    %endrep

    pop eax
%endmacro



%endif ; !_TETRIS_LIB_MEM_
