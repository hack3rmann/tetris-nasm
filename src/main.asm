%include "lib/window.inc"
%include "lib/keyboard.inc"
%include "lib/graphics.inc"
%include "src/game.inc"
%include "lib/debug/print.inc"

extern printf


section .bss align 4
    window      resb Window.sizeof
    keyboard    resb Keyboard.sizeof
    graphics    resb Graphics.sizeof
    game        resb Game.sizeof
    prev_time   resd 1
    duration    resd 1

section .data align 4
    exit_code   dd 0

section .rodata align 4
    window_name db "Tetris", 0, 0
    thousand    dd 1_000.0

section .text
    global main


; #[cdecl]
; fn main() -> i32
main:
    push ebp
    mov ebp, esp

    ; window = Window::new(window_name, 800, 600)
    push 600
    push 800
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

    ; game = Game::new()
    push game
    call Game_new

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

        ; if duration == 0 { continue }
        cmp dword [duration], 0
        je .msg_loop_start

        ; prev_time += duration
        add dword [prev_time], eax

        ; graphics.image.fill(%color)
        push RGB(26, 27, 38)
        lea eax, dword [graphics+Graphics.image]
        push eax
        call ScreenImage_fill

        ; game.update(duration as f32 / 1_000.0)
        fild dword [duration]
        fdiv dword [thousand]
        sub esp, 4
        fstp dword [esp]
        push game
        call Game_update

        ; game.draw(&mut graphics.image)
        lea eax, dword [graphics+Graphics.image]
        push eax
        push game
        call Game_draw

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