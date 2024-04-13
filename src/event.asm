%include "src/event.inc"
%include "lib/debug/print.inc"



section .text

; #[stdcall]
; EventDispatcher::new() -> Self
EventDispatcher_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase                equ 12
    .return                 equ .argbase+0

    .args_size              equ .return-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return.events = Vec::new(sizeof(Event))
    push Event.sizeof
    lea eax, dword [edi+EventDispatcher.events]
    push eax
    call Vec_new

    %assign i 0
    %rep EventDispatcher.subscribers.len

        ; return.subscribers[i] = Vec::new(sizeof(Subscriber))
        push Subscriber.sizeof
        lea eax, dword [edi+EventDispatcher.subscribers+i*EventDispatcher.subscribers.elem_size]
        push eax
        call Vec_new

    %assign i i+1
    %endrep

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; EventDispatcher::init()
EventDispatcher_init:
    push EVENT_DISPATCHER
    call EventDispatcher_new
    ret


; #[stdcall]
; EventDispatcher::drop(&mut self)
EventDispatcher_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; Vec::drop(&mut self.events)
    lea eax, dword [esi+EventDispatcher.events]
    push eax
    call Vec_drop

    %assign i 0
    %rep EventDispatcher.subscribers.len

        ; Vec::drop(&mut self.subscribers[i])
        lea eax, dword [esi+EventDispatcher.subscribers+i*EventDispatcher.subscribers.elem_size]
        push eax
        call Vec_drop

    %assign i i+1
    %endrep

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; EventDispatcher::throw(event: &mut Event)
EventDispatcher_throw:
    push ebp
    mov ebp, esp

    .argbase            equ 8
    .event              equ .argbase+0

    .args_size          equ .event-.argbase+4

    ; EVENT_DISPATCHER.events.push(event)
    push dword [ebp+.event]
    push EVENT_DISPATCHER+EventDispatcher.events
    call Vec_push

    pop ebp
    ret .args_size


; #[stdcall]
; EventDispatcher::dispatch_all()
EventDispatcher_dispatch_all:
    push ebp
    push ebx
    mov ebp, esp

    .subscribers            equ -20
    .sub_index              equ -16
    .event                  equ -12
    .n_subscribers          equ -8
    .event_index            equ -4

    .stack_size             equ -.subscribers

    sub esp, .stack_size
    
    ; for event_index in 0..EVENT_DISPATCHER.events.len {
    mov dword [ebp+.event_index], 0
    .for_event_index_start:
    mov ecx, dword [EVENT_DISPATCHER+EventDispatcher.events+Vec.len]
    cmp dword [ebp+.event_index], ecx
    jae .for_event_index_end

        ; event = &mut EVENT_DISPATCHER.events[event_index]
        mov eax, Event_CAPACITY_BYTES
        mul dword [ebp+.event_index]
        add eax, dword [EVENT_DISPATCHER+EventDispatcher.events+Vec.ptr]
        mov dword [ebp+.event], eax

        ; subscribers = &mut EVENT_DISPATCHER.subscribers[event.type]
        mov ecx, dword [ebp+.event]
        mov ecx, dword [ecx+Event.type]
        mov eax, Vec.sizeof
        mul ecx
        add eax, EVENT_DISPATCHER+EventDispatcher.subscribers
        mov dword [ebp+.subscribers], eax

        ; n_subscribers = subscribers.len
        mov eax, dword [ebp+.subscribers]
        mov eax, dword [eax+Vec.len]
        mov dword [ebp+.n_subscribers], eax

        ; for sub_index in 0..n_subscribers {
        mov dword [ebp+.sub_index], 0
        .for_sub_index_start:
        mov ecx, dword [ebp+.n_subscribers]
        cmp dword [ebp+.sub_index], ecx
        jae .for_sub_index_end

            ; (subscribers[sub_index].callback)(subscribers[sub_index].env, event)
            mov eax, dword [ebp+.subscribers]
            mov eax, dword [eax+Vec.ptr]
            mov ecx, dword [ebp+.sub_index]
            lea eax, dword [eax+4*ecx]
            mov ecx, dword [eax+Subscriber.callback]
            lea edx, dword [eax+Subscriber.env]
            sub esp, Subscriber.env.sizeof
            MEM_COPY esp, edx, Subscriber.env.sizeof
            push dword [ebp+.event]
            call ecx

        inc dword [ebp+.sub_index]
        jmp .for_sub_index_start
        ; }
        .for_sub_index_end:

    inc dword [ebp+.event_index]
    jmp .for_event_index_start
    ; }
    .for_event_index_end:

    ; EVENT_DISPATCHER.events.clear()
    push EVENT_DISPATCHER+EventDispatcher.events
    call Vec_clear

    add esp, .stack_size

    pop ebx
    pop ebp
    ret


; #[stdcall]
; fn EventDispatcher::add_listener(event_type: EventType, subscriber: &mut Subscriber)
EventDispatcher_add_listener:
    push ebp
    mov ebp, esp

    .argbase                equ 8
    .event_type             equ .argbase+0
    .subscriber             equ .argbase+4

    .args_size              equ .subscriber-.argbase+4

    ; EVENT_DISPATCHER.subscribers[event_type].push(subscriber)
    push dword [ebp+.subscriber]
    mov eax, dword [ebp+.event_type]
    mov edx, Vec.sizeof
    mul edx
    add eax, EVENT_DISPATCHER+EventDispatcher.subscribers
    push eax
    call Vec_push

    pop ebp
    ret .args_size