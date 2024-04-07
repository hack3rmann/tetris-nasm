%include "lib/vec.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"

extern malloc, realloc, free



section .text


; #[stdcall]
; fn Vec32::new() -> Self
Vec32_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return = mem::zeroed()
    MEM_ZEROED Vec32, edi

    pop edi
    pop ebp
    ret 4


; #[stdcall]
; fn Vec32::with_capacity(cap: u32) -> Self
Vec32_with_capacity:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0
    .cap            equ .argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return.len = 0
    mov dword [edi+Vec32.len], 0

    ; return.cap = cap
    mov eax, dword [ebp+.cap]
    mov dword [edi+Vec32.cap], eax

    ; return.ptr = malloc(4 * cap)
    shl eax, 2
    push eax
    call malloc
    add esp, 4
    mov dword [edi+Vec32.ptr], eax

    pop edi
    pop ebp
    ret 8


; #[stdcall]
; fn Vec32::drop(&mut self)
Vec32_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    ; self := esi
    mov esi, dword [ebp+.self]

    ; free(self.ptr)
    push dword [esi+Vec32.ptr]
    call free
    add esp, 4

    ; *self = mem::zeroed()
    MEM_ZEROED Vec32, esi

    pop esi
    pop ebp
    ret 4


; #[stdcall]
; fn Vec32::push(&mut self, value: u32)
Vec32_push:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .value          equ .argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.cap == 0 {
    cmp dword [esi+Vec32.cap], 0
    jne .self_cap_is_not_zero

        ; self.ptr = malloc(4 * 16)
        push 4 * 16
        call malloc
        add esp, 4
        mov dword [esi+Vec32.ptr], eax

        ; self.cap = 16
        mov dword [esi+Vec32.cap], 16
    
    .self_cap_is_not_zero:
    ; } else if self.len == self.cap {
    mov eax, dword [esi+Vec32.len]
    cmp dword [esi+Vec32.cap], eax
    jne .enough_capacity

        ; self.cap += self.cap / 2 + 1
        mov eax, dword [esi+Vec32.cap]
        shr eax, 1
        inc eax
        add dword [esi+Vec32.cap], eax

        ; self.ptr = realloc(self.ptr, 4 * self.cap);
        mov eax, dword [esi+Vec32.cap]
        shl eax, 2
        push eax
        push dword [esi+Vec32.ptr]
        call realloc
        add esp, 8
        mov dword [esi+Vec32.ptr], eax
    ; }
    .enough_capacity:

    ; self.ptr[self.len] = value
    mov ecx, dword [esi+Vec32.len]
    shl ecx, 2
    add ecx, dword [esi+Vec32.ptr]
    mov eax, dword [ebp+.value]
    mov dword [ecx], eax

    ; self.len += 1
    inc dword [esi+Vec32.len]

    pop esi
    pop ebp
    ret 8