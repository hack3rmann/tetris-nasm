%ifndef _TETRIS_LIB_DEBUG_PRINT_
%define _TETRIS_LIB_DEBUG_PRINT_



extern debug_u32, debug_newline, debug

%macro DEBUG_U32 1
    pusha
    push dword %1
    call debug_u32
    popa
%endmacro

%macro DEBUGLN_U32 1
    pusha
    push dword %1
    call debug_u32
    call debug_newline
    popa
%endmacro

%macro DEBUG_NEWLINE 0
    pusha
    call debug_newline
    popa
%endmacro

%macro DEBUG_STRING 1
%push
    section .rodata align 4
        %$fmt db %1, 0

    section .text
        pusha
        push %$fmt
        call debug
        popa
%pop
%endmacro

%macro DEBUGLN_STRING 1
%push
    section .rodata align 4
        %$fmt db %1, 10, 0

    section .text
        pusha
        push %$fmt
        call debug
        popa
%pop
%endmacro

%macro DEBUG 1
    %rep %0
        %ifstr %1
            DEBUG_STRING %1
        %else
            DEBUG_U32 %1
        %endif
    %rotate 1
    %endrep
%endmacro

%macro DEBUGLN 0-*
    %rep %0
        DEBUG %1
    %rotate 1
    %endrep

    DEBUG_NEWLINE
%endmacro



%endif ; !_TETRIS_LIB_DEBUG_PRINT_