%include "lib/window.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"


section .rodata align 4
    Window_CLASS_NAME db "window_class", 0, 0, 0, 0


section .text

; #[stdcall]
; fn Window::WindowClass::new(name: *const u8) -> Self
WindowClass_new:
    push ebp
    push edi
    mov ebp, esp

    .desc       equ -WNDCLASSA.sizeof
    
    .argbase    equ 12
    .return     equ .argbase+0
    .name       equ .argbase+4

    .stack_size equ -.desc

    sub esp, .stack_size

    ; Self
    mov edi, dword [ebp+.return]

    ; var desc: WNDCLASSA = mem::zeroed()
    MEM_ZEROED WNDCLASSA, ebp+.desc

    ; desc.lpfnWndProc = Self::_window_procedure
    mov dword [ebp+.desc+WNDCLASSA.lpfnWndProc], Window__window_setup_procedure

    ; desc.hInstance = GetModuleHandle(null)
    ; return.hinstance = desc.hInstance
    push 0
    call GetModuleHandle
    mov dword [ebp+.desc+WNDCLASSA.hInstance], eax
    mov dword [edi+WindowClass.hinstance], eax

    ; desc.lpszClassName = name
    ; return.name = name
    mov eax, dword [ebp+.name]
    mov dword [ebp+.desc+WNDCLASSA.lpszClassName], eax
    mov dword [edi+WindowClass.name], eax

    ; desc.style = CS_OWNDC
    mov dword [ebp+.desc+WNDCLASSA.style], CS_OWNDC

    ; RegisterClass(&desc)
    lea eax, dword [ebp+.desc]
    push eax
    call RegisterClass

    add esp, .stack_size

    pop edi
    pop ebp
    ret 8


; #[stdcall]
; fn Window::WindowClass::drop(&mut self)
WindowClass_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    ; self
    mov esi, dword [ebp+.self]

    ; UnregisterClass(self.name, self.hinstance)
    push dword [esi+WindowClass.hinstance]
    push dword [esi+WindowClass.name]
    call UnregisterClass

    pop esi
    pop ebp
    ret 4



; #[stdcall]
; fn Window::new(name: *const u8, width: u32, height: u32) -> Self
Window_new:
    push ebp
    push edi
    mov ebp, esp

    .rect           equ -RECT.sizeof

    .argbase        equ 12
    .return         equ .argbase+0
    .name           equ .argbase+4
    .width          equ .argbase+8
    .height         equ .argbase+12

    .stack_size     equ -.rect

    sub esp, .stack_size

    ; return := edi
    mov edi, dword [ebp+.return]

    ; return.class = Self::WindowClass::new(Self::CLASS_NAME)
    push Window_CLASS_NAME
    lea eax, [edi+Window.class]
    push eax
    call WindowClass_new

    ; rect.left = Window_DEFAULT_POS_X
    mov dword [ebp+.rect+RECT.left], Window_DEFAULT_POS_X

    ; rect.top = Window_DEFAULT_POS_Y
    mov dword [ebp+.rect+RECT.top], Window_DEFAULT_POS_Y

    ; rect.right = width + Window_DEFAULT_POS_X
    mov eax, dword [ebp+.width]
    add eax, Window_DEFAULT_POS_X
    mov dword [ebp+.rect+RECT.right], eax

    ; rect.bottom = height + Window_DEFAULT_POS_Y
    mov eax, dword [ebp+.height]
    add eax, Window_DEFAULT_POS_Y
    mov dword [ebp+.rect+RECT.bottom], eax

    ; AdjustWindowRect(&mut rect, WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU, FALSE)
    push 0
    push WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU
    lea eax, dword [ebp+.rect]
    push eax
    call AdjuctWindowRect

    ; return.hwnd = CreateWindow(
    ;     0,
    ;     return.class.name,
    ;     name,
    ;     WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU,
    ;     Window::DEFAULT_POS_X, Window::DEFAULT_POS_Y,
    ;     rect.right - rect.left, rect.bottom - rect.top,
    ;     null, null,
    ;     return.class.hinstance,
    ;     self)
    push edi
    push dword [edi+WindowClass.hinstance]
    push 0
    push 0
    mov eax, dword [ebp+.rect+RECT.bottom]
    sub eax, dword [ebp+.rect+RECT.top]
    push eax
    mov eax, dword [ebp+.rect+RECT.right]
    sub eax, dword [ebp+.rect+RECT.left]
    push eax
    push Window_DEFAULT_POS_Y
    push Window_DEFAULT_POS_X
    push WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU
    push dword [ebp+.name]
    push dword [edi+Window.class+WindowClass.name]
    push 0
    call CreateWindow
    mov dword [edi+Window.hwnd], eax

    ; return.msg = mem::zeroed()
    MEM_ZEROED MSG, edi+Window.msg

    ; return.callbacks = mem::zeroed()
    MEM_ZEROED WindowCallbacks, edi+Window.callbacks

    ; ShowWindow(return.hwnd, 1)
    push 1
    push dword [edi+Window.hwnd]
    call ShowWindow

    add esp, .stack_size

    pop edi
    pop ebp
    ret 16


; #[stdcall]
; fn Window::drop(&mut self)
Window_drop:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    mov esi, dword [ebp+.self]

    ; DestroyWindow(self.hwnd)
    push dword [edi+Window.hwnd]
    call DestroyWindow

    ; WindowClass::drop(&mut self.class)
    lea eax, [esi+Window.class]
    push eax
    call WindowClass_drop

    pop esi
    pop ebp
    ret 4


; #[stdcall]
; fn Window::_window_setup_procedure(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM)
;     -> LRESULT
Window__window_setup_procedure:
    push ebp
    push esi
    mov ebp, esp

    .argbase    equ 12
    .hwnd       equ .argbase+0
    .msg        equ .argbase+4
    .wparam     equ .argbase+8
    .lparam     equ .argbase+12

    ; if msg == WM_NCCREATE {
    cmp dword [ebp+.msg], WM_NCCREATE
    jne .msg_is_not_WM_NCCREATE

        ; var (window := esi): &mut Window = (lparam as &CREATESTRUCTA).lpCreateParams
        mov esi, dword [ebp+.lparam]
        mov esi, dword [esi+CREATESTRUCTA.lpCreateParams]

        ; SetWindowLong(hwnd, GWLP_USERDATA, window)
        push esi
        push GWLP_USERDATA
        push dword [ebp+.hwnd]
        call SetWindowLong

        ; SetWindowLong(hwnd, GWLP_WNDPROC, Window::_window_procedure)
        push Window__window_procedure
        push GWLP_WNDPROC
        push dword [ebp+.hwnd]
        call SetWindowLong

        ; return Window::_window_procedure(hwnd, msg, wparam, lparam);
        push dword [ebp+.lparam]
        push dword [ebp+.wparam]
        push dword [ebp+.msg]
        push dword [ebp+.hwnd]
        call Window__window_procedure
        jmp .exit
    ; }
    .msg_is_not_WM_NCCREATE:

    ; return DefWindowProc(hwnd, msg, wparam, lparam)
    push dword [ebp+.lparam]
    push dword [ebp+.wparam]
    push dword [ebp+.msg]
    push dword [ebp+.hwnd]
    call DefWindowProc

.exit:
    pop esi
    pop ebp
    ret 16


; #[stdcall]
; fn Window::_window_procedure(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM)
;     -> LRESULT
Window__window_procedure:
    push ebp
    push esi
    mov ebp, esp

    .argbase    equ 12
    .hwnd       equ .argbase+0
    .msg        equ .argbase+4
    .wparam     equ .argbase+8
    .lparam     equ .argbase+12

    ; var (window := esi): &mut Window = GetWindowLong(hwnd, GWLP_USERDATA)
    push GWLP_USERDATA
    push dword [ebp+.hwnd]
    call GetWindowLong
    mov esi, eax

    ; if msg == WM_CLOSE {
    cmp dword [ebp+.msg], WM_CLOSE
    jne .msg_is_not_WM_CLOSE

        ; Window::close()
        call Window_close

        ; return 0
        xor eax, eax
        jmp .exit

    ; }
    .msg_is_not_WM_CLOSE:

    ; if msg == WM_SYSKEYDOWN || msg == WM_KEYDOWN {
    cmp dword [ebp+.msg], WM_SYSKEYDOWN
    sete al
    cmp dword [ebp+.msg], WM_KEYDOWN
    sete ah
    or al, ah
    test al, al
    jz .msg_is_not_WM_SYSKEYDOWN_and_not_WM_KEYDOWN

        ; (self.callbacks.on_key_down)(window, wparam)
        mov ecx, dword [esi+Window.callbacks+WindowCallbacks.on_key_down]
        test ecx, ecx
        jz .on_key_down_callback_is_null
        push dword [ebp+.wparam]
        push esi
        call ecx
        .on_key_down_callback_is_null:

    ; }
    .msg_is_not_WM_SYSKEYDOWN_and_not_WM_KEYDOWN:
    
    ; if msg == WM_SYSKEYUP || msg == WM_KEYUP {
    cmp dword [ebp+.msg], WM_SYSKEYUP
    sete al
    cmp dword [ebp+.msg], WM_KEYUP
    sete ah
    or al, ah
    test al, al
    jne .msg_is_not_WM_SYSKEYUP_and_not_WM_KEYUP

        ; (self.callbacks.on_key_up)(window, wparam)
        mov ecx, dword [esi+Window.callbacks+WindowCallbacks.on_key_up]
        test ecx, ecx
        jz .on_key_up_callback_is_null
        push dword [ebp+.wparam]
        push esi
        call ecx
        .on_key_up_callback_is_null:

    ; }
    .msg_is_not_WM_SYSKEYUP_and_not_WM_KEYUP:
    
    ; if msg == WM_PAINT {
    cmp dword [ebp+.msg], WM_PAINT
    jne .msg_is_not_WM_PAINT

        ; (self.callbacks.on_draw)(window)
        mov ecx, dword [esi+Window.callbacks+WindowCallbacks.on_draw]
        test ecx, ecx
        jz .on_draw_callback_is_null
        push esi
        call ecx
        .on_draw_callback_is_null:

    ; }
    .msg_is_not_WM_PAINT:

    ; return DefWindowProc(hwnd, msg, wparam, lparam)
    push dword [ebp+.lparam]
    push dword [ebp+.wparam]
    push dword [ebp+.msg]
    push dword [ebp+.hwnd]
    call DefWindowProc

.exit:
    pop esi
    pop ebp
    ret 16


; #[stdcall]
; fn Window::close()
Window_close:
    push ebp
    mov ebp, esp

    ; PostQuitMessage(0)
    push 0
    call PostQuitMessage

    pop ebp
    ret


; #[stdcall]
; fn Window::process_messages(&mut self) -> (u32 := eax, bool := dl)
Window_process_messages:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    ; &mut self := esi
    mov esi, dword [ebp+.self]

    ; while 0 != PeekMessage(&mut self.msg, null, 0, 0, PM_REMOVE) {
    .while_peek_message_start:
        push PM_REMOVE
        push 0
        push 0
        push 0
        lea eax, dword [esi+Window.msg]
        push eax
        call PeekMessage
        test al, 1
        jz .while_peek_message_end

        ; if self.msg.message == WM_QUIT {
        cmp dword [esi+Window.msg+MSG.message], WM_QUIT
        jne .self_msg_message_is_not_WM_QUIT

            ; return (self.msg.wParam, true)
            mov eax, dword [esi+Window.msg+MSG.wParam]
            mov dl, 1
            jmp .exit

        ; }
        .self_msg_message_is_not_WM_QUIT:

        ; TranslateMessage(&self.msg)
        lea eax, dword [esi+Window.msg]
        push eax
        call TranslateMessage

        ; DispatchMessage(&self.msg)
        lea eax, dword [esi+Window.msg]
        push eax
        call DispatchMessage

        jmp .while_peek_message_start
    .while_peek_message_end:

    ; return (0, false)
    xor eax, eax
    xor dl, dl

.exit:
    pop esi
    pop ebp
    ret 4


; #[stdcall]
; fn Window::request_redraw(&self)
Window_request_redraw:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0

    mov esi, dword [ebp+.self]

    ; UpdateWindow(self.hwnd)
    push dword [esi+Window.hwnd]
    call UpdateWindow

    pop esi
    pop ebp
    ret 4