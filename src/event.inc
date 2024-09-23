%ifndef _TETRIS_EVENT_
%define _TETRIS_EVENT_

%include "lib/vec.inc"



%define EventType_LineClear 0
%define EventType_StateSwitch 1
%define EventType_COUNT EventType_StateSwitch+1



%define Event_CAPACITY_BYTES 512

struc Event
    .type                   resd 1
    .data                   resb Event_CAPACITY_BYTES-4
    .sizeof                 equ ALIGNED($-.type)
endstruc



%define Subscriber_CAPACITY_BYTES 128

struc Subscriber
    .env.sizeof             equ Subscriber_CAPACITY_BYTES-4
    .env                    resb .env.sizeof
    ; fn(env: Env, &mut Event)
    .callback               resd 1
    .sizeof                 equ ALIGNED($-.env)
endstruc



%assign EventDispatcher_N_SUBSCRIBERS EventType_COUNT

struc EventDispatcher
    ; : Vec<Event>
    .events                         resb Vec.sizeof
    ; [Vec<Subscriber>; EventType_COUNT]
    .subscriber_lists               resb ALIGNED(Vec.sizeof * EventDispatcher_N_SUBSCRIBERS)
    .sizeof                         equ ALIGNED($-.events)
endstruc

section .bss
    EVENT_DISPATCHER resb EventDispatcher.sizeof

extern EventDispatcher_new, EventDispatcher_drop, EventDispatcher_init
extern EventDispatcher_throw, EventDispatcher_dispatch_all
extern EventDispatcher_add_listener



%endif ; !_TETRIS_EVENT_