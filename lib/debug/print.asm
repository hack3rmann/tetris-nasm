%include "lib/debug/print.inc"

extern printf, putchar



section .text

; #[stdcall]
; fn debug_u32(value: u32)
debug_u32:
    push ebp
    mov ebp, esp

    .fmt            equ -4

    .argbase        equ 8
    .value          equ .argbase+0
    
    .args_size      equ .value-.argbase+4
    .stack_size     equ -.fmt

    sub esp, .stack_size

    mov dword [ebp+.fmt], `%d`

    ; printf("%d", value)
    push dword [ebp+.value]
    lea eax, dword [ebp+.fmt]
    push eax
    call printf
    add esp, 8

    add esp, .stack_size

    pop ebp
    ret .args_size


; #[stdcall]
; fn debug_newline()
debug_newline:
    push ebp
    mov ebp, esp

    ; putchar('\n')
    push 10
    call putchar
    add esp, 4

    pop ebp
    ret


; #[stdcall]
; fn debug(string: *const u8)
debug:
    push ebp
    mov ebp, esp

    .argbase        equ 8
    .string         equ .argbase+0

    .args_size      equ .string-.argbase+4

    push dword [ebp+.string]
    call printf
    add esp, 4

    pop ebp
    ret .args_size