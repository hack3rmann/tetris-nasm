%ifndef _TETRIS_EVENT_
%define _TETRIS_EVENT_

%include "lib/vec.inc"



%define EventType_LineClear             0
%define EventType_GameOver              1
%define EventType_FigureSwitch          2

%define EventType_COUNT (1 + EventType_FigureSwitch)



%define Event_CAPACITY_BYTES 512

struc Event
    .type                   resd 1
    .data                   resb Event_CAPACITY_BYTES-4
    .sizeof                 equ ALIGNED($-.type)
endstruc



struc EventDispatcher
    ; : Vec<Event>
    .events                 resb Vec.sizeof

    ; [Vec32<fn(&Event)>; EventType_COUNT]
    .subscribers.len        equ EventType_COUNT
    .subscribers.elem_size  equ Vec32.sizeof
    .subscribers            resb .subscribers.len * .subscribers.elem_size

    .sizeof                 equ ALIGNED($-.events)
endstruc

section .bss
    EVENT_DISPATCHER resb EventDispatcher.sizeof

extern EventDispatcher_new, EventDispatcher_drop, EventDispatcher_init
extern EventDispatcher_throw, EventDispatcher_dispatch_all
extern EventDispatcher_add_listener



%endif ; !_TETRIS_EVENT_