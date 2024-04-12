%include "lib/vec.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"

extern malloc, realloc, free, memcpy



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



; #[stdcall]
; fn Vec::new(elem_size: u32) -> Self
Vec_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0
    .elem_size      equ .argbase+4

    .args_size      equ .elem_size-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return = mem::zeroed()
    MEM_ZEROED Vec, edi

    ; return.elem_size = elem_size
    mov eax, dword [ebp+.elem_size]
    mov dword [edi+Vec.elem_size], eax

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Vec::with_capacity(cap: u32, elem_size: u32) -> Self
Vec_with_capacity:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0
    .cap            equ .argbase+4
    .elem_size      equ .argbase+8

    .args_size      equ .elem_size-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return.elem_size = elem_size
    mov eax, dword [ebp+.elem_size]
    mov dword [edi+Vec.elem_size], eax

    ; return.len = 0
    mov dword [edi+Vec.len], 0

    ; return.cap = cap
    mov eax, dword [ebp+.cap]
    mov dword [edi+Vec.cap], eax

    ; return.ptr = malloc(elem_size * cap)
    mov eax, dword [ebp+.elem_size]
    mul dword [ebp+.cap]
    push eax
    call malloc
    add esp, 4
    mov dword [edi+Vec.ptr], eax

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Vec::drop(&mut self)
Vec_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    .args_size      equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; free(self.ptr)
    push dword [esi+Vec.ptr]
    call free
    add esp, 4

    ; *self = mem::zeroed()
    MEM_ZEROED Vec, esi

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Vec::push(&mut self, value_ptr: &mut T)
Vec_push:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .value_ptr      equ .argbase+4

    .args_size      equ .value_ptr-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.cap == 0 {
    cmp dword [esi+Vec.cap], 0
    jne .self_cap_is_not_zero

        ; self.ptr = malloc(self.elem_size)
        push dword [esi+Vec.elem_size]
        call malloc
        add esp, 4
        mov dword [esi+Vec.ptr], eax

        ; self.cap = 1
        mov dword [esi+Vec.cap], 1
    
    .self_cap_is_not_zero:
    ; } else if self.len == self.cap {
    mov eax, dword [esi+Vec.len]
    cmp dword [esi+Vec.cap], eax
    jne .enough_capacity

        ; self.cap += self.cap / 2 + 1
        mov eax, dword [esi+Vec.cap]
        shr eax, 1
        inc eax
        add dword [esi+Vec.cap], eax

        ; self.ptr = realloc(self.ptr, self.elem_size * self.cap);
        mov eax, dword [esi+Vec.cap]
        mul dword [esi+Vec.elem_size]
        push eax
        push dword [esi+Vec.ptr]
        call realloc
        add esp, 8
        mov dword [esi+Vec.ptr], eax
    ; }
    .enough_capacity:

    ; self.ptr[self.len] = *value_ptr
    push dword [esi+Vec.elem_size]
    push dword [ebp+.value_ptr]
    mov eax, dword [esi+Vec.len]
    mul dword [esi+Vec.elem_size]
    add eax, dword [esi+Vec.ptr]
    push eax
    call memcpy
    add esp, 12

    ; self.len += 1
    inc dword [esi+Vec.len]

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Vec::clear(&mut self)
Vec_clear:
    push ebp
    push esi
    mov ebp, esp

    .argbase                equ 12
    .self                   equ .argbase+0

    .args_size              equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.len = 0
    mov dword [esi+Vec.len], 0

    pop esi
    pop ebp
    ret .args_size