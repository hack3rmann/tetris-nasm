%ifndef _TETRIS_LIB_WINDOW_
%define _TETRIS_LIB_WINDOW_

%include "lib/winapi/window.inc"



struc WindowClass
    .hinstance  resd 1
    .name       resd 1
    .sizeof     equ $-.hinstance
endstruc

extern WindowClass_new, WindowClass_drop



struc WindowCallbacks
    ; #[stdcall] fn(&Window)
    .on_draw        resd 1
    ; #[stdcall] fn(&Window, key_code: u32)
    .on_key_down    resd 1
    ; #[stdcall] fn(&Window, key_code: u32)
    .on_key_up      resd 1
    .sizeof         equ $-.on_draw
endstruc



struc Window
    .hwnd       resd 1
    .msg        resb MSG.sizeof
    .class      resb WindowClass.sizeof
    .callbacks  resb WindowCallbacks.sizeof
    .sizeof     equ $-.hwnd
endstruc

%define Window_DEFAULT_POS_X 100
%define Window_DEFAULT_POS_Y 100

extern Window_new, Window_drop, Window__window_setup_procedure
extern Window__window_procedure, Window_close, Window_process_messages
extern Window_block_on_messages, Window_request_redraw



%endif ; !_TETRIS_LIB_WINDOW_