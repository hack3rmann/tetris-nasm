%ifndef _TETRIS_LIB_GRAPHICS_
%define _TETRIS_LIB_GRAPHICS_

%include "lib/winapi/windows.inc"
%include "lib/mem.inc"



%define RGB(r, g, b) ((b) | ((g) << 8)) | ((r) << 16)



struc ScreenImage
    .width              resd 1
    .height             resd 1
    .data_ptr           resd 1
    .device_context     resd 1
    .bitmap             resd 1
    .changed            resb 1
    ._padding           resb 3
    .bitmap_info        resb BITMAPINFO.sizeof
    .sizeof             equ ALIGNED($-.width)
endstruc

extern ScreenImage_new, ScreenImage_drop, ScreenImage_resize
extern ScreenImage_set_pixel, ScreenImage_fill_rect, ScreenImage_fill
extern ScreenImage_show, ScreenImage_fill_box, ScreenImage_draw_text
extern ScreenImage_draw_char



struc Graphics
    .image              resb ScreenImage.sizeof
    .sizeof             equ ALIGNED($-.image)
endstruc

extern Graphics_new, Graphics_drop, Graphics_on_window_resize
extern Graphics_window_event_listener, Graphics_on_redraw



%endif ; !_TETRIS_LIB_GRAPHICS_