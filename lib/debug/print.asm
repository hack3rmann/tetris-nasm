%include "lib/debug/print.inc"

extern printf, putchar



section .text

; #[stdcall]
; fn debug_print_u32(value: u32)
debug_print_u32:
    push ebp
    mov ebp, esp

    .fmt        equ -4
    .value      equ 8
    .stack_size equ -.fmt

    sub esp, .stack_size

    mov dword [ebp+.fmt], `%u`

    ; printf("%u", value)
    push dword [ebp+.value]
    lea eax, dword [ebp+.fmt]
    push eax
    call printf
    add esp, 8

    add esp, .stack_size

    pop ebp
    ret 4


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