%include "lib/window.inc"
%include "lib/keyboard.inc"
%include "lib/graphics.inc"
%include "src/game.inc"
%include "src/event.inc"
%include "lib/float_consts.inc"
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
    exit_code           dd 0
    moving_direction    dd 0
    speed_multiplier    dd 1.0

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

    ; EventDispatcher::init()
    call EventDispatcher_init

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

        ; moving_direction = 0
        mov dword [moving_direction], 0

        ; if keyboard.just_pressed('A')
        push "A"
        push keyboard
        call Keyboard_just_pressed
        test al, al
        jz .A_is_not_pressed
        
            dec dword [moving_direction]
        ; }
        .A_is_not_pressed:

        ; if keyboard.just_pressed('D')
        push "D"
        push keyboard
        call Keyboard_just_pressed
        test al, al
        jz .D_is_not_pressed

            inc dword [moving_direction]
        ; }
        .D_is_not_pressed:

        ; speed_multiplier = 1.0
        fld1
        fstp dword [speed_multiplier]

        ; if keyboard.is_pressed('S') {
        push "S"
        push keyboard
        call Keyboard_is_pressed
        test al, al
        jz .S_is_not_pressed
        
            ; speed_multiplier = 5.0
            fld dword [seven]
            fstp dword [speed_multiplier]
        ; }
        .S_is_not_pressed:
        
        ; if keyboard.just_pressed('R') {
        push "R"
        push keyboard
        call Keyboard_just_pressed
        test al, al
        je .R_is_not_pressed
        
            ; game.rotate()
            push game
            call Game_rotate
        ; }
        .R_is_not_pressed:

        ; if keyboard.just_pressed(VK_SPACE) {
        push VK_SPACE
        push keyboard
        call Keyboard_just_pressed
        test al, al
        jz .VS_SPACE_is_not_pressed
        
            ; game.drop_piece()
            push game
            call Game_drop_piece
        ; }
        .VS_SPACE_is_not_pressed:

        ; if keyboard.just_pressed('Q') {
        push "Q"
        push keyboard
        call Keyboard_just_pressed
        test al, al
        jz .Q_is_not_pressed

            ; game.try_swap_saved()
            push game
            call Game_try_swap_saved
        ; }
        .Q_is_not_pressed:

        ; game.speed_multiplier = speed_multiplier
        fld dword [speed_multiplier]
        fstp dword [game+Game.speed_multiplier]

        ; game.set_moving_direction(moving_direction)
        push dword [moving_direction]
        push game
        call Game_set_moving_direction

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

        ; keyboard.update()
        push keyboard
        call Keyboard_update

        ; EventDispatcher::dispatch_all()
        call EventDispatcher_dispatch_all

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