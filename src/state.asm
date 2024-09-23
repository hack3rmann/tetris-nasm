%include "src/state.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"



; #[stdcall]
; fn StateSwitchEvent::throw(next_state: GameState)
StateSwitchEvent_throw:
    push ebp
    mov ebp, esp

    .event                  equ -StateSwitchEvent.sizeof

    .argbase                equ 8
    .next_state             equ .argbase+0

    .args_size              equ .next_state-.argbase+4
    .stack_size             equ -.event

    DEBUGLN `esp = `, esp

    sub esp, .stack_size
    
    ; event = mem::zeroed()
    MEM_ZEROED StateSwitchEvent, ebp+.event

    ; event.type = EventType::StateSwitch
    mov dword [ebp+.event+StateSwitchEvent.type], EventType_StateSwitch

    ; event.prev_state = GameState_CURRENT
    mov eax, dword [GameState_CURRENT]
    mov dword [ebp+.event+StateSwitchEvent.prev_state], eax

    ; event.next_state = next_state
    mov eax, dword [ebp+.next_state]
    mov dword [ebp+.event+StateSwitchEvent.next_state], eax

    ; EventDispatcher::throw(&mut event)
    lea eax, dword [ebp+.event]
    push eax
    call EventDispatcher_throw

    add esp, .stack_size

    DEBUGLN `esp = `, esp

    pop ebp
    ret .args_size


; #[stdcall]
; state_switch(_env: Env, event: &mut StateSwitchEvent)
state_switch:
    push ebp
    mov ebp, esp

    .argbase                    equ 8
    ._env                       equ .argbase+0
    .event                      equ .argbase+4

    .args_size                  equ Subscriber.env.sizeof+4

    ; GameState_CURRENT = event.next_state
    mov eax, dword [ebp+.event+StateSwitchEvent.next_state]
    mov dword [GameState_CURRENT], eax

    pop ebp
    ret .args_size