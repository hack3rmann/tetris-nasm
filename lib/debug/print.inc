%ifndef _TETRIS_LIB_DEBUG_PRINT_
%define _TETRIS_LIB_DEBUG_PRINT_



extern debug_print_u32, debug_newline

%macro DEBUG_PRINT_U32 1
    pusha
    push dword %1
    call debug_print_u32
    popa
%endmacro

%macro DEBUG_PRINTLN_U32 1
    pusha
    push dword %1
    call debug_print_u32
    call debug_newline
    popa
%endmacro

%macro DEBUG_NEWLINE 0
    pusha
    call debug_newline
    popa
%endmacro



%endif ; !_TETRIS_LIB_DEBUG_PRINT_