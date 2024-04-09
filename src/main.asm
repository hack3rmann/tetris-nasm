%include "lib/window.inc"
%include "lib/keyboard.inc"
%include "lib/graphics.inc"
%include "lib/debug/print.inc"

extern printf


section .bss align 4
    window      resb Window.sizeof
    keyboard    resb Keyboard.sizeof
    graphics    resb Graphics.sizeof
    prev_time   resd 1
    duration    resd 1
    dx_         resd 1
    dy_         resd 1

section .data align 4
    exit_code   dd 0
    x dd 0.0
    y dd 0.0
    vel_x dd 100.0
    vel_y dd 100.0
    size dd 1.0
    n_milliseconds_in_second dd 1_000.0

section .rodata align 4
    window_name db "Tetris", 0, 0

section .text
    global main


; #[cdecl]
; fn main() -> i32
main:
    push ebp
    mov ebp, esp

    ; window = Window::new(window_name, 640, 480)
    push 480
    push 640
    push window_name
    push window
    call Window_new

    ; keyboard = Keyboard::new()
    push keyboard
    call Keyboard_new

    ; graphics = Graphics::new(&window)
    push window
    push graphics
    call Graphics_new

    ; window.add_event_listener(Keyboard::window_event_listener)
    push Keyboard_window_event_listener
    push window
    call Window_add_event_listener

    ; window.add_event_listener(Graphics::window_event_listener)
    push Graphics_window_event_listener
    push window
    call Window_add_event_listener

    ; prev_time = GetTickCount()
    call GetTickCount
    mov dword [prev_time], eax

    ; loop {
    .msg_loop_start:
        ; window.request_redraw()
        push window
        call Window_request_redraw

        ; let (exit_code, is_exit := dl) = window.process_messages()
        push window
        call Window_process_messages
        mov dword [exit_code], eax

        ; if is_exit { break }
        test dl, 1
        jnz .msg_loop_end

        ; let (instant := eax) = GetTickCount()
        call GetTickCount

        ; duration = instant - prev_time
        sub eax, dword [prev_time]
        mov dword [duration], eax

        ; prev_time += duration
        add dword [prev_time], eax

        ; dx_ = vel_x * (duration as f32) / 1_000.0
        fld dword [vel_x]
        fild dword [duration]
        fmulp
        fdiv dword [n_milliseconds_in_second]
        fstp dword [dx_]

        ; dy_ = vel_y * (duration as f32) / 1_000.0
        fld dword [vel_y]
        fild dword [duration]
        fmulp
        fdiv dword [n_milliseconds_in_second]
        fstp dword [dy_]

        ; if keyboard.is_pressed('W') {
        push "W"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_W_is_not_pressed

            ; y += dy_
            fld dword [y]
            fadd dword [dy_]
            fstp dword [y]
        ; }
        .keyboard_W_is_not_pressed:

        ; if keyboard.is_pressed('S') {
        push "S"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_S_is_not_pressed

            ; y -= dy_
            fld dword [y]
            fsub dword [dy_]
            fstp dword [y]
        ; }
        .keyboard_S_is_not_pressed:

        ; if keyboard.is_pressed('D') {
        push "D"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_D_is_not_pressed

            ; x += dx_
            fld dword [x]
            fadd dword [dx_]
            fstp dword [x]
        ; }
        .keyboard_D_is_not_pressed:

        ; if keyboard.is_pressed('A') {
        push "A"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_A_is_not_pressed

            ; x -= dx_
            fld dword [x]
            fsub dword [dx_]
            fstp dword [x]
        ; }
        .keyboard_A_is_not_pressed:

        ; move(x, y)
        push dword [y]
        push dword [x]
        call move

        jmp .msg_loop_start
    ; }
    .msg_loop_end:

    ; Graphics::drop(&mut graphics)
    push graphics
    call Graphics_drop

    ; Window::drop(&mut window)
    push window
    call Window_drop

    DEBUGLN `Exiting with code `, dword [exit_code]

    mov eax, dword [exit_code]

    pop ebp
    ret