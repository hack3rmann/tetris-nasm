%ifndef _TETRIS_LIB_GRAPHICS_
%define _TETRIS_LIB_GRAPHICS_

%include "lib/winapi/windows.inc"



%define COLOR_RGB(r, g, b) ((r) | ((g) << 8)) | ((b) << 16)



struc ScreenImage
    .width          resd 1
    .height         resd 1
    .data_ptr       resd 1
    .sizeof         equ $-.width
endstruc

extern ScreenImage_new, ScreenImage_drop, ScreenImage_resize
extern ScreenImage_set_pixel, ScreenImage_fill_rect, ScreenImage_fill



struc Graphics
    .image                  resb ScreenImage.sizeof
    .frame_bitmap_info      resb BITMAPINFO.sizeof
    .frame_bitmap           resd 1 ; : HBITMAP
    .frame_device_context   resd 1 ; : HDC
    .sizeof                 equ $-.image
endstruc

extern Graphics_new, Graphics_drop, Graphics_on_window_resize
extern Graphics_window_event_listener, Graphics_on_redraw, Graphics_init_image



%endif ; !_TETRIS_LIB_GRAPHICS_