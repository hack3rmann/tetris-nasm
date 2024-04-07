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

    ; return.width = width
    mov eax, dword [ebp+.width]
    mov dword [edi+ScreenImage.width], eax

    ; return.height = height
    mov edx, dword [ebp+.height]
    mov dword [edi+ScreenImage.height], edx

    ; return.data_ptr = null
    mov dword [edi+ScreenImage.data_ptr], 0

    pop esi
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

    ; return.image = ScreenImage::new(window.width, window.height)
    push dword [esi+Window.height]
    push dword [esi+Window.width]
    lea eax, dword [edi+Graphics.image]
    push eax
    call ScreenImage_new

    ; return.frame_bitmap_info = mem::zeroed()
    MEM_ZEROED BITMAPINFO, edi+Graphics.frame_bitmap_info

    ; return.frame_bitmap_info.bmiHeader.biSize = sizeof(BITMAPINFOHEADER)
    mov dword [edi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biSize], BITMAPINFOHEADER.sizeof

    ; return.frame_bitmap_info.bmiHeader.biPlanes = 1
    mov dword [edi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biPlanes], 1

    ; return.frame_bitmap_info.bmiHeader.biBitCount = 32
    mov dword [edi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biBitCount], 32

    ; return.frame_bitmap_info.bmiHeader.biCompression = BI_RGB
    mov dword [edi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biCompression], BI_RGB

    ; return.frame_device_context = CreateCompatibleDC(0)
    push 0
    call CreateCompatibleDC
    mov dword [edi+Graphics.frame_device_context], eax

    ; return.frame_bitmap = null
    mov dword [edi+Graphics.frame_bitmap], 0

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

    ; DeleteDC(self.frame_device_context)
    push dword [esi+Graphics.frame_device_context]
    call DeleteDC

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
    ret 16


; #[stdcall]
; fn Graphics::on_redraw(window: &Window)
Graphics_on_redraw:
    push ebp
    push esi
    push ebx
    mov ebp, esp

    .paint_desc     equ -PAINTSTRUCT.sizeof - 4
    .device_context equ -4

    .argbase        equ 16
    .window         equ .argbase+0

    .args_size      equ .window-.argbase+4
    .stack_size     equ -.paint_desc

    sub esp, .stack_size

    ; window := esi
    mov esi, dword [ebp+.window]

    ; let (graphics := ebx) = Self::GLOBAL_PTR
    mov ebx, dword [Graphics_GLOBAL_PTR]

    ; if graphics.is_null() { return }
    test ebx, ebx
    jz .exit

    ; device_context = BeginPaint(window.hwnd, &mut paint_desc)
    lea eax, dword [ebp+.paint_desc]
    push eax
    push dword [esi+Window.hwnd]
    call BeginPaint
    mov dword [ebp+.device_context], eax

    ; graphics.image.fill(COLOR_RGB(0, 0, 0))
    push COLOR_RGB(38, 26, 27)
    lea eax, dword [ebx+Graphics.image]
    push eax
    call ScreenImage_fill

    ; graphics.image.fill_rect(200 + x, 200, 100, 100, COLOR_RGB(%color))
    push COLOR_RGB(179, 78, 233)
    push 100
    push 100
    push 200
    mov eax, dword [x]
    add eax, 200
    push eax
    lea eax, dword [ebx+Graphics.image]
    push eax
    call ScreenImage_fill_rect

    inc dword [y]
    cmp dword [y], 256
    jb .y_below_256

        mov dword [y], 0
        inc dword [x]
        and dword [x], 255

    .y_below_256:

    ; BitBlt(device_context,
    ;        paint_desc.rcPaint.left, paint_desc.rcPaint.top,
    ;        paint_desc.rcPaint.right - paint_desc.rcPaint.left, paint_desc.rcPaint.bottom - paint_desc.rcPaint.top,
    ;        graphics.frame_device_context,
    ;        paint_desc.rcPaint.left, paint_desc.rcPaint.top,
    ;        SRCCOPY)
    push SRCCOPY
    push dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.top]
    push dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.left]
    push dword [ebx+Graphics.frame_device_context]
    mov eax, dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.bottom]
    sub eax, dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.top]
    push eax
    mov eax, dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.right]
    sub eax, dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.left]
    push eax
    push dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.top]
    push dword [ebp+.paint_desc+PAINTSTRUCT.rcPaint+RECT.left]
    push dword [ebp+.device_context]
    call BitBlt

    ; EndPaint(window.hwnd, &paint_desc)
    lea eax, dword [ebp+.paint_desc]
    push eax
    push dword [esi+Window.hwnd]
    call EndPaint

.exit:
    add esp, .stack_size

    pop ebx
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

    ; self.image.resize(width, height)
    push dword [ebp+.height]
    push dword [ebp+.width]
    lea eax, dword [esi+Graphics.image]
    push eax
    call ScreenImage_resize
    
    ; self.frame_bitmap_info.bmiHeader.biWidth = width
    mov eax, dword [ebp+.width]
    mov dword [esi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biWidth], eax

    ; self.frame_bitmap_info.bmiHeader.biHeight = height
    mov eax, dword [ebp+.height]
    mov dword [esi+Graphics.frame_bitmap_info+BITMAPINFO.bmiHeader+BITMAPINFOHEADER.biHeight], eax

    ; if !self.frame_bitmap.is_null() {
    cmp dword [esi+Graphics.frame_bitmap], 0
    je .self_frame_bitmap_is_null

        ; DeleteObject(self.frame_bitmap)
        push dword [esi+Graphics.frame_bitmap]
        call DeleteObject
    
    ; }
    .self_frame_bitmap_is_null:

    ; self.frame_bitmap = CreateDIBSection(null, &self.frame_bitmap_info, DIB_RGB_COLORS, &mut self.image.data_ptr, 0, 0)
    push 0
    push 0
    lea eax, dword [esi+Graphics.image+ScreenImage.data_ptr]
    push eax
    push DIB_RGB_COLORS
    lea eax, dword [esi+Graphics.frame_bitmap_info]
    push eax
    push 0
    call CreateDIBSection
    mov dword [esi+Graphics.frame_bitmap], eax

    ; SelectObject(self.frame_device_context, self.frame_bitmap)
    push dword [esi+Graphics.frame_bitmap]
    push dword [esi+Graphics.frame_device_context]
    call SelectObject

    pop esi
    pop ebp
    ret .args_size