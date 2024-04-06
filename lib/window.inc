%ifndef _TETRIS_LIB_WINDOW_
%define _TETRIS_LIB_WINDOW_

%include "lib/winapi/window.inc"



section .text

struc WindowClass
    .hinstance  resd 1
    .name       resd 1
    .sizeof     equ $-.hinstance
endstruc

extern WindowClass_new, WindowClass_drop



struc Window
    .hwnd   resd 1
    .msg    resb MSG.sizeof
    .class  resb WindowClass.sizeof
    .sizeof equ $-.class
endstruc

%define Window_DEFAULT_POS_X 100
%define Window_DEFAULT_POS_Y 100

extern Window_new, Window_drop, Window__window_setup_procedure
extern Window__window_procedure, Window_close, Window_process_messages
extern Window_block_on_messages



%endif ; !_TETRIS_LIB_WINDOW_