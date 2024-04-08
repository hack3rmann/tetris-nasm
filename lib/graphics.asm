%include "lib/window.inc"
%include "lib/graphics.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"

extern calloc, realloc, free



section .data
    Graphics_GLOBAL_PTR dd 0
    x dd 0
    y dd 0

section .text

; #[stdcall]
; fn ScreenImage::new(width: u32, height: u32) -> Self
ScreenImage_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase        equ 12
    .return         equ .argbase+0
    .width          equ .argbase+4
    .height         equ .argbase+8

    .args_size      equ .height-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    DEBUGLN `ScreenImage::new(`, dword [ebp+.width], `, `, dword [ebp+.height], `)`

    ; return.width = width
    mov eax, dword [ebp+.width]
    mov dword [edi+ScreenImage.width], eax

    ; return.height = height
    mov edx, dword [ebp+.height]
    mov dword [edi+ScreenImage.height], edx

    ; let (volume := eax) = width * height
    mul edx

    ; return.data_ptr = calloc(volume, 4)
    push 4
    push eax
    call calloc
    add esp, 8
    mov dword [edi+ScreenImage.data_ptr], eax

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn ScreenImage::drop(&mut self)
ScreenImage_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    .args_size      equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    DEBUGLN `ScreenImage::drop(<Self at `, esi, `>)`

    ; free(self.data_ptr)
    push dword [esi+ScreenImage.data_ptr]
    call free
    add esp, 4

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn ScreenImage::resize(&mut self, width: u32, height: u32)
ScreenImage_resize:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .width          equ .argbase+4
    .height         equ .argbase+8

    .args_size      equ .height-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.width = width
    mov eax, dword [ebp+.width]
    mov dword [esi+ScreenImage.width], eax

    ; self.height = height
    mov edx, dword [ebp+.height]
    mov dword [esi+ScreenImage.height], edx

    ; let (volume := eax) = width * height
    mul edx

    ; self.data_ptr = realloc(self.data_ptr, 4 * volume)
    shl eax, 2
    push eax
    push dword [esi+ScreenImage.data_ptr]
    call realloc
    add esp, 8
    mov dword [esi+ScreenImage.data_ptr], eax

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn ScreenImage::set_pixel(&mut self, row: u32, col: u32, value: u32)
ScreenImage_set_pixel:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .row            equ .argbase+4
    .col            equ .argbase+8
    .value          equ .argbase+12

    .args_size      equ .value-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if row >= self.width { return }
    mov eax, dword [ebp+.row]
    cmp eax, dword [esi+ScreenImage.width]
    jnb .exit

    ; if col >= self.height { return }
    mov eax, dword [ebp+.col]
    cmp eax, dword [esi+ScreenImage.height]
    jnb .exit

    ; if self.data_ptr.is_null() { return }
    cmp dword [esi+ScreenImage.data_ptr], 0
    je .exit

    ; let (index := eax) = self.width * row + col
    mov edx, dword [esi+ScreenImage.width]
    mov eax, dword [ebp+.row]
    mul edx
    add eax, dword [ebp+.col]

    ; self.data_ptr[index] = value
    shl eax, 2
    add eax, dword [esi+ScreenImage.data_ptr]
    mov edx, dword [ebp+.value]
    mov dword [eax], edx

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn ScreenImage::fill_rect(&mut self, left: u32, top: u32, width: u32, height: u32, value: u32)
ScreenImage_fill_rect:
    push ebp
    push esi
    mov ebp, esp

    .col            equ -8
    .row            equ -4

    .argbase        equ 12
    .self           equ .argbase+0
    .left           equ .argbase+4
    .top            equ .argbase+8
    .width          equ .argbase+12
    .height         equ .argbase+16
    .value          equ .argbase+20

    .args_size      equ .value-.argbase+4
    .stack_size     equ -.col

    sub esp, .stack_size
    
    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.data_ptr.is_null() { return }
    cmp dword [esi+ScreenImage.data_ptr], 0
    je .exit

    ; for row in 0..height {
    mov dword [ebp+.row], 0
    .for_row_start:
        mov ecx, dword [ebp+.height]
        cmp dword [ebp+.row], ecx
        jnb .for_row_end

        ; for col in 0..width {
        mov dword [ebp+.col], 0
        .for_col_start:
            mov ecx, dword [ebp+.width]
            cmp dword [ebp+.col], ecx
            jnb .for_col_end

            ; self.set_pixel(row + top, col + left, value)
            push dword [ebp+.value]
            mov eax, dword [ebp+.col]
            add eax, dword [ebp+.left]
            push eax
            mov eax, dword [ebp+.row]
            add eax, dword [ebp+.top]
            push eax
            push esi
            call ScreenImage_set_pixel

            inc dword [ebp+.col]
            jmp .for_col_start
        ; }
        .for_col_end:

        inc dword [ebp+.row]
        jmp .for_row_start
    ; }
    .for_row_end:

.exit:
    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; ScreenImage::fill(&mut self, value: u32)
ScreenImage_fill:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .argbase        equ 16
    .self           equ .argbase+0
    .value          equ .argbase+4
    
    .args_size      equ .value-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.data_ptr.is_null() { return }
    cmp dword [esi+ScreenImage.data_ptr], 0
    je .exit

    ; let (volume := eax) = self.width * self.height
    mov eax, dword [esi+ScreenImage.width]
    mov edx, dword [esi+ScreenImage.height]
    mul edx

    ; let (end := edx) = self.data_ptr + 4 * volume
    mov edx, eax
    shl edx, 2
    add edx, dword [esi+ScreenImage.data_ptr]

    ; let (ptr := edi) = self.data_ptr
    mov edi, dword [esi+ScreenImage.data_ptr]

    ; value := eax
    mov eax, dword [ebp+.value]

    ; while ptr != end {
    .while_ptr_is_not_end_start:
        cmp edi, edx
        je .while_ptr_is_not_end_end

        ; *ptr = value
        mov dword [edi], eax

        add edi, 4
        jmp .while_ptr_is_not_end_start
    ; }
    .while_ptr_is_not_end_end:

.exit:
    pop edi
    pop esi
    pop ebp
    ret .args_size



; #[stdcall]
; Graphics::new(window: &Window) -> Self
Graphics_new:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .argbase        equ 16
    .return         equ .argbase+0
    .window         equ .argbase+4

    .args_size      equ .window-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    ; window := esi
    mov esi, dword [ebp+.window]

    DEBUGLN `Graphics::new(<Window at `, esi, `>)`

    ; return.image = ScreenImage::new(window.width, window.height)
    push dword [esi+Window.height]
    push dword [esi+Window.width]
    lea eax, dword [edi+Graphics.image]
    push eax
    call ScreenImage_new

    ; Self::GLOBAL_PTR = edi
    mov dword [Graphics_GLOBAL_PTR], edi

    ; return.init_image(window.width, window.height)
    push dword [esi+Window.height]
    push dword [esi+Window.width]
    push edi
    call Graphics_init_image

    pop edi
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Graphics::drop(&mut self)
Graphics_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    .args_size      equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; ScreenImage::drop(&mut self.image)
    lea eax, dword [esi+Graphics.image]
    push eax
    call ScreenImage_drop

    DEBUGLN `Graphics::drop(<Self at `, esi, `>)`

    ; Self::GLOBAL_PTR = null
    mov dword [Graphics_GLOBAL_PTR], 0

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Graphics::window_event_listener(window: &Window, msg: UINT, _: WPARAM, lparam: LPARAM)
Graphics_window_event_listener:
    push ebp
    mov ebp, esp

    .argbase        equ 8
    .window         equ .argbase+0
    .msg            equ .argbase+4
    .lparam         equ .argbase+12

    .args_size      equ .lparam-.argbase+4

    ; if msg == WM_PAINT {
    cmp dword [ebp+.msg], WM_PAINT
    jne .msg_is_not_WM_PAINT

        ; Graphics::on_redraw(window)
        push dword [ebp+.window]
        call Graphics_on_redraw

    ; }
    .msg_is_not_WM_PAINT:

    ; if msg == WM_SIZE {
    cmp dword [ebp+.msg], WM_SIZE
    jne .msg_is_not_WM_SIZE

        ; Graphics::on_window_resize(lparam & 0xFFFF, lparam >> 16)
        mov eax, dword [ebp+.lparam]
        shr eax, 16
        push eax
        mov eax, dword [ebp+.lparam]
        and eax, 0xFFFF
        push eax
        call Graphics_on_window_resize

    ; }
    .msg_is_not_WM_SIZE:

    pop ebp
    ret .args_size


; #[stdcall]
; fn Graphics::on_redraw(window: &Window)
Graphics_on_redraw:
    push ebp
    push esi
    push ebx
    mov ebp, esp

    .argbase        equ 16
    .window         equ .argbase+0

    .args_size      equ .window-.argbase+4

    ; window := esi
    mov esi, dword [ebp+.window]

    ; let (graphics := ebx) = Self::GLOBAL_PTR
    mov ebx, dword [Graphics_GLOBAL_PTR]

    ; if graphics.is_null() { return }
    test ebx, ebx
    jz .exit

    

.exit:    pop ebx
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Graphics_on_window_resize(width: u32, height: u32)
Graphics_on_window_resize:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .width          equ .argbase+0
    .height         equ .argbase+4

    .args_size      equ .height-.argbase+4

    ; let (graphics := esi) = Self::GLOBAL_PTR
    mov esi, dword [Graphics_GLOBAL_PTR]

    ; if graphics.is_null() { return }
    test esi, esi
    jz .exit

    ; self.init_image(width, height)
    push dword [ebp+.height]
    push dword [ebp+.width]    
    push esi
    call Graphics_init_image

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Graphics::init_image(&mut self, width: u32, height: u32)
Graphics_init_image:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .width          equ .argbase+4
    .height         equ .argbase+8

    .args_size      equ .height-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    DEBUGLN `Graphics::init_image(`, dword [ebp+.width], `, `, dword [ebp+.height], `)`

    

    pop esi
    pop ebp
    ret .args_size