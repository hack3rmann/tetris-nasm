%include "lib/keyboard.inc"
%include "lib/window.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"



section .data align 4
    Keyboard_GLOBAL_KEYBOARD_PTR dd 0


section .text


; #[stdcall]
; fn Keyboard::new() -> Self
Keyboard_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return = mem::zeroed()
    MEM_ZEROED Keyboard, edi

    ; Self::GLOBAL_KEYBOARD_PTR = return
    mov dword [Keyboard_GLOBAL_KEYBOARD_PTR], edi

    pop edi
    pop ebp
    ret 4


; #[stdcall]
; fn Keyboard::init_window(window: &mut Window)
Keyboard_init_window:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .window         equ .argbase+0

    ; window := edi
    mov edi, dword [ebp+.window]

    ; window.callbacks.on_key_down = Self::on_key_down
    mov dword [edi+Window.callbacks+WindowCallbacks.on_key_down], Keyboard_on_key_down

    ; window.callbacks.on_key_up = Self::on_key_up
    mov dword [edi+Window.callbacks+WindowCallbacks.on_key_up], Keyboard_on_key_up

    pop edi
    pop ebp
    ret 4


; #[stdcall]
; fn Keyboard::on_key_down(_: &Window, key_code: u32)
Keyboard_on_key_down:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .key_code       equ .argbase+4

    ; let (keyboard := edi) = Self::GLOBAL_KEYBOARD_PTR
    mov edi, dword [Keyboard_GLOBAL_KEYBOARD_PTR]
    
    ; if keyboard.is_null() { return }
    test edi, edi
    jz .exit

    ; keyboard.press(key_code)
    push dword [ebp+.key_code]
    push edi
    call Keyboard_press

.exit:
    pop edi
    pop ebp
    ret 8


; #[stdcall]
; fn Keyboard::on_key_up(_: &Window, key_code: u32)
Keyboard_on_key_up:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .key_code       equ .argbase+4

    ; let (keyboard := edi) = Self::GLOBAL_KEYBOARD_PTR
    mov edi, dword [Keyboard_GLOBAL_KEYBOARD_PTR]

    ; if keyboard.is_null() { return }
    test edi, edi
    jz .exit

    ; keyboard.release(key_code)
    push dword [ebp+.key_code]
    push edi
    call Keyboard_release

.exit:
    pop edi
    pop ebp
    ret 8


; #[stdcall]
; fn Keyboard::is_pressed(&self, key_code: u32) -> bool
Keyboard_is_pressed:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .key_code       equ .argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; let (src := edx) = keyboard.pressed_keys[key_code / 32]
    mov ecx, dword [ebp+.key_code]
    shr ecx, 5
    mov edx, dword [esi+Keyboard.pressed_keys+4*ecx]

    ; let (mask := eax) = 1 << (31 - (key_code % 32))
    mov eax, dword [ebp+.key_code]
    and eax, 31
    mov ecx, 31
    sub ecx, eax
    mov eax, 1
    shl eax, cl

    ; return 0 != src & mask
    and eax, edx
    setnz al

    pop esi
    pop ebp
    ret 8


; #[stdcall]
; fn Keyboard::press(&mut self, key_code: u32)
Keyboard_press:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .key_code       equ .argbase+4
    
    ; self := esi
    mov esi, dword [ebp+.self]

    ; if key_code >= 256 { return }
    cmp dword [ebp+.key_code], 256
    jnb .exit

    ; let (src := edx) = keyboard.pressed_keys[key_code / 32]
    mov ecx, dword [ebp+.key_code]
    shr ecx, 5
    mov edx, dword [esi+Keyboard.pressed_keys+4*ecx]

    ; let (mask := eax) = 1 << (31 - (key_code % 32))
    mov eax, dword [ebp+.key_code]
    and eax, 31
    mov ecx, 31
    sub ecx, eax
    mov eax, 1
    shl eax, cl

    ; keyboard.pressed_keys[key_code / 32] = src | mask
    or eax, edx
    mov ecx, dword [ebp+.key_code]
    shr ecx, 5
    mov dword [esi+Keyboard.pressed_keys+4*ecx], eax

.exit:
    pop esi
    pop ebp
    ret 8


; #[stdcall]
; fn Keyboard::release(&mut self, key_code: u32)
Keyboard_release:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .key_code       equ .argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if key_code >= 256 { return }
    cmp dword [ebp+.key_code], 256
    jnb .exit

    ; let (src := edx) = keyboard.pressed_keys[key_code / 32]
    mov ecx, dword [ebp+.key_code]
    shr ecx, 5
    mov edx, dword [esi+Keyboard.pressed_keys+4*ecx]

    ; let (mask := eax) = ~(1 << (31 - (key_code % 32)))
    mov eax, dword [ebp+.key_code]
    and eax, 31
    mov ecx, 31
    sub ecx, eax
    mov eax, 1
    shl eax, cl
    not eax

    ; keyboard.pressed_keys[key_code / 32] = src & mask
    and eax, edx
    mov ecx, dword [ebp+.key_code]
    shr ecx, 5
    mov dword [esi+Keyboard.pressed_keys+4*ecx], eax

.exit:
    pop esi
    pop ebp
    ret 8