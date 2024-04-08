%include "lib/window.inc"
%include "lib/keyboard.inc"
%include "lib/graphics.inc"
%include "lib/debug/print.inc"

extern printf


section .bss align 4
    window      resb Window.sizeof
    keyboard    resb Keyboard.sizeof
    graphics    resb Graphics.sizeof

section .data align 4
    exit_code   dd 0
    x dd 0.0
    y dd 0.0
    vel_x dd 0.05
    vel_y dd 0.05
    size dd 1.0

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

        ; if keyboard.is_pressed('W') {
        push "W"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_W_is_not_pressed

            ; y += vel_y
            fld dword [y]
            fadd dword [vel_y]
            fstp dword [y]
        ; }
        .keyboard_W_is_not_pressed:

        ; if keyboard.is_pressed('S') {
        push "S"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_S_is_not_pressed

            ; y -= vel_y
            fld dword [y]
            fsub dword [vel_y]
            fstp dword [y]
        ; }
        .keyboard_S_is_not_pressed:

        ; if keyboard.is_pressed('D') {
        push "D"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_D_is_not_pressed

            ; x += vel_x
            fld dword [x]
            fadd dword [vel_x]
            fstp dword [x]
        ; }
        .keyboard_D_is_not_pressed:

        ; if keyboard.is_pressed('A') {
        push "A"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .keyboard_A_is_not_pressed

            ; x -= vel_x
            fld dword [x]
            fsub dword [vel_x]
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