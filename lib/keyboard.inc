%ifndef _TETRIS_LIB_KEYBOARD_
%define _TETRIS_LIB_KEYBOARD_



%define KeyCode_Space 0x20



struc Keyboard
    .pressed_keys           resd 256 / 32
    .keys_to_release        resd 256 / 32
    .sizeof                 equ $-.pressed_keys
endstruc

extern Keyboard_new, Keyboard_init_window, Keyboard_on_key_up
extern Keyboard_on_key_down, Keyboard_is_pressed
extern Keyboard_press, Keyboard_release



%endif ; !_TETRIS_LIB_KEYBOARD_