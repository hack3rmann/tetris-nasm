%ifndef _TETRIS_STATE_
%define _TETRIS_STATE_

%include "src/event.inc"



%define GameState_StartMenu 0
%define GameState_PauseMenu 1
%define GameState_Game      2

section .data align 4
    GameState_CURRENT db GameState_Game
GameState_CALLBACKS:
    .START_MENU dd 0
    .PAUSE_MENU dd 0
    .GAME       dd 0



struc StateSwitchEvent
    .type                   resd 1
    .prev_state             resd 1
    .next_state             resd 1
    .sizeof                 equ Event.sizeof
endstruc

extern StateSwitchEvent_throw



extern state_switch



%endif ; !_TETRIS_STATE_