%ifndef _TETRIS_LIB_MEM_
%define _TETRIS_LIB_MEM_



; MEM_ZEROED struct, ptr
%macro MEM_ZEROED 2
    %push
    %assign %$i 0
    %rep %1.sizeof / 4
        mov dword [%2+%$i], 0
    %assign %$i %$i+4
    %endrep
    %pop
%endmacro

; MEM_COPY dst_ptr, src_ptr, n_bytes
%macro MEM_COPY 3
    %push
    %assign %$i 0
    %rep %3 / 4
        push dword [%2 + 4 * %$i]
        pop dword [%1 + 4 * %$i]
    %assign %$i %$i+1
    %endrep
    %pop
%endmacro

; MEM_SET dst_ptr, value, n_bytes
%macro MEM_SET 3
    %push
    %assign %$i 0
    %rep %3 / 4
        mov dword [%1 + 4 * %$i], %2
    %assign %$i %$i+1
    %endrep
    %pop
%endmacro

; PUSH_STRUCT Type, value_ptr
%macro PUSH_STRUCT 2
    sub esp, %1.sizeof
    MEM_COPY esp, %2, %1.sizeof
%endmacro

%define ALIGNED(n_bytes) \
    n_bytes + (4 - (n_bytes % 4)) % 4



%endif ; !_TETRIS_LIB_MEM_
