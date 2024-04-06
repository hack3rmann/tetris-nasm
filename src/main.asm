%include "lib/window.inc"
%include "lib/debug/print.inc"


section .bss align 4
    window resb Window.sizeof

section .data align 4
    exit_code dd 0

section .rodata align 4
    window_name db "Tetris", 0, 0

section .text
    global main


; #[cdecl]
; fn main() -> i32
main:
    push ebp
    mov ebp, esp

    ; window = Window_new(window_name, 640, 480)
    push 480
    push 640
    push window_name
    push window
    call Window_new

    ; loop {
    .msg_loop_start:
        ; let (exit_code, is_exit := dl) = window.process_messages()
        push window
        call Window_process_messages
        mov dword [exit_code], eax

        ; if is_exit { break }
        test dl, 1
        jnz .msg_loop_end

        jmp .msg_loop_start
    ; }
    .msg_loop_end:

    ; Window::drop(&mut window)
    push window
    call Window_drop

    mov eax, dword [exit_code]

    pop ebp
    ret