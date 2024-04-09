%include "lib/window.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"


section .text

; #[stdcall]
; fn Window::WindowClass::new(name: *const u8) -> Self
WindowClass_new:
    push ebp
    push edi
    mov ebp, esp
    
    .argbase        equ 12
    .return         equ .argbase+0
    .name           equ .argbase+4

    .args_size      equ .name-.argbase+4

    ; Self
    mov edi, dword [ebp+.return]

    ; return = Self::with_icon(name, Self::DEFAULT_ICON_PATH)
    push Window_DEFAULT_ICON_PATH
    push dword [ebp+.name]
    push edi
    call WindowClass_with_icon

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn WindowClass::with_icon(name: *const u8, icon_path: *const u8) -> Self
WindowClass_with_icon:
    push ebp
    push edi
    mov ebp, esp

    .desc           equ -WNDCLASSA.sizeof

    .argbase        equ 12
    .return         equ .argbase+0
    .name           equ .argbase+4
    .icon_path      equ .argbase+8

    .args_size      equ .icon_path-.argbase+4
    .stack_size     equ -.desc

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

    ; if !icon_path.is_null() {
    cmp dword [ebp+.icon_path], 0
    je .icon_path_is_null

        ; desc.hIcon = LoadImage(return.hinstance, icon_path, IMAGE_ICON, 64, 64, LR_LOADFROMFILE)
        push LR_LOADFROMFILE
        push 64
        push 64
        push IMAGE_ICON
        push dword [ebp+.icon_path]
        push dword [edi+WindowClass.hinstance]
        call LoadImage
        mov dword [ebp+.desc+WNDCLASSA.hIcon], eax
    ; }
    .icon_path_is_null:

    ; RegisterClass(&desc)
    lea eax, dword [ebp+.desc]
    push eax
    call RegisterClass

    add esp, .stack_size

    pop edi
    pop ebp
    ret .args_size


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

    .rect           equ -RECT.sizeof-4
    .window_style   equ -4

    .argbase        equ 12
    .return         equ .argbase+0
    .name           equ .argbase+4
    .width          equ .argbase+8
    .height         equ .argbase+12

    .stack_size     equ -.rect

    sub esp, .stack_size

    ; return := edi
    mov edi, dword [ebp+.return]

    DEBUGLN `Window::new(<name at `, dword [ebp+.name], `>, `, dword [ebp+.width], `, `, dword [ebp+.height], `)`

    ; return.class = Self::WindowClass::new(Self::CLASS_NAME)
    push Window_CLASS_NAME
    lea eax, [edi+Window.class]
    push eax
    call WindowClass_new

    ; return.width = width
    mov eax, dword [ebp+.width]
    mov dword [edi+Window.width], eax

    ; return.height = height
    mov eax, dword [ebp+.height]
    mov dword [edi+Window.height], eax

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

    ; window_style = %style
    mov dword [ebp+.window_style], \
        WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU \
            | WS_SIZEBOX | WS_MAXIMIZEBOX | WS_VISIBLE

    ; AdjustWindowRect(&mut rect, window_style, FALSE)
    push 0
    push dword [ebp+.window_style]
    lea eax, dword [ebp+.rect]
    push eax
    call AdjustWindowRect

    ; return.hwnd = CreateWindow(
    ;     0,
    ;     return.class.name,
    ;     name,
    ;     window_style,
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
    push dword [ebp+.window_style]
    push dword [ebp+.name]
    push dword [edi+Window.class+WindowClass.name]
    push 0
    call CreateWindow
    mov dword [edi+Window.hwnd], eax

    ; return.subscribers = Vec32::with_capacity(4)
    push 4
    lea eax, dword [edi+Window.subscribers]
    push eax
    call Vec32_with_capacity

    ; return.msg = mem::zeroed()
    MEM_ZEROED MSG, edi+Window.msg

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

    ; Vec32::drop(&mut self.subscribers)
    lea eax, dword [esi+Window.subscribers]
    push eax
    call Vec32_drop

    DEBUGLN `Window::drop(<Self at `, esi, `>)`

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
    push ebx
    mov ebp, esp

    .argbase    equ 16
    .hwnd       equ .argbase+0
    .msg        equ .argbase+4
    .wparam     equ .argbase+8
    .lparam     equ .argbase+12

    ; var (window := esi): &mut Window = GetWindowLong(hwnd, GWLP_USERDATA)
    push GWLP_USERDATA
    push dword [ebp+.hwnd]
    call GetWindowLong
    mov esi, eax

    ; for subscriber in self.subscribers {
    xor ebx, ebx
    .for_subscriber_start:
        cmp ebx, dword [esi+Window.subscribers+Vec32.len]
        jnb .for_subscriber_end

        ; let (callback := ecx) = subscriber
        mov ecx, dword [esi+Window.subscribers+Vec32.ptr]
        mov ecx, dword [ecx+4*ebx]

        ; callback(window, msg, wparam, lparam)
        push dword [ebp+.lparam]
        push dword [ebp+.wparam]
        push dword [ebp+.msg]
        push esi
        call ecx

        inc ebx
        jmp .for_subscriber_start
    ; }
    .for_subscriber_end:

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

    ; if msg == WM_SIZE {
    cmp dword [ebp+.msg], WM_SIZE
    jne .msg_is_not_WM_SIZE
    
        ; window.width = lparam & 0xFFFF
        mov eax, dword [ebp+.lparam]
        and eax, 0xFFFF
        mov dword [esi+Window.width], eax

        ; window.height = lparam >> 16
        mov eax, dword [ebp+.lparam]
        shr eax, 16
        mov dword [esi+Window.height], eax

    ; }
    .msg_is_not_WM_SIZE:

    ; return DefWindowProc(hwnd, msg, wparam, lparam)
    push dword [ebp+.lparam]
    push dword [ebp+.wparam]
    push dword [ebp+.msg]
    push dword [ebp+.hwnd]
    call DefWindowProc

.exit:
    pop ebx
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
        test al, al
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

    ; InvalidateRect(self.hwnd, null, FALSE)
    push 0
    push 0
    push dword [esi+Window.hwnd]
    call InvalidateRect

    ; UpdateWindow(self.hwnd)
    push dword [esi+Window.hwnd]
    call UpdateWindow

    pop esi
    pop ebp
    ret 4


; #[stdcall]
; fn Window::add_event_listener(
;     &mut self, callback: #[stdcall] fn(&Window, UINT, WPARAM, LPARAM),
; )
Window_add_event_listener:
    push ebp
    push esi
    mov ebp, esp

    .argbase        equ 12
    .self           equ .argbase+0
    .callback       equ .argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.subscribers.push(callback)
    push dword [ebp+.callback]
    lea eax, dword [esi+Window.subscribers]
    push eax
    call Vec32_push

    pop esi
    pop ebp
    ret 8