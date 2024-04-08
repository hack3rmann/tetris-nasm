%ifndef _TETRIS_LIB_WINAPI_WINDOW_
%define _TETRIS_LIB_WINAPI_WINDOW_



extern GetModuleHandleA@4, RegisterClassA@4, CreateWindowExA@48, ShowWindow@8
extern DefWindowProcA@16, UnregisterClassA@8, DestroyWindow@4
extern SetWindowLongA@12, GetWindowLongA@8, PostQuitMessage@4
extern PeekMessageA@20, TranslateMessage@4, DispatchMessageA@4
extern GetMessageA@16, AdjustWindowRect@12, GetDC@4, ReleaseDC@8
extern UpdateWindow@4, CreateSolidBrush@4, DeleteObject@4, SelectObject@8
extern PatBlt@24, InvalidateRect@12, BeginPaint@8, EndPaint@8
extern BitBlt@36, CreateCompatibleDC@4, CreateDIBSection@24, DeleteDC@4
extern GetLastError@0, CreateBitmap@20

%define GetModuleHandle     GetModuleHandleA@4
%define RegisterClass       RegisterClassA@4
%define CreateWindow        CreateWindowExA@48
%define ShowWindow          ShowWindow@8
%define DefWindowProc       DefWindowProcA@16
%define UnregisterClass     UnregisterClassA@8
%define DestroyWindow       DestroyWindow@4
%define SetWindowLong       SetWindowLongA@12
%define GetWindowLong       GetWindowLongA@8
%define PostQuitMessage     PostQuitMessage@4
%define PeekMessage         PeekMessageA@20
%define TranslateMessage    TranslateMessage@4
%define DispatchMessage     DispatchMessageA@4
%define GetMessage          GetMessageA@16
%define AdjustWindowRect    AdjustWindowRect@12
%define GetDC               GetDC@4
%define ReleaseDC           ReleaseDC@8
%define UpdateWindow        UpdateWindow@4
%define CreateSolidBrush    CreateSolidBrush@4
%define DeleteObject        DeleteObject@4
%define SelectObject        SelectObject@8
%define PatBlt              PatBlt@24
%define InvalidateRect      InvalidateRect@12
%define BeginPaint          BeginPaint@8
%define EndPaint            EndPaint@8
%define BitBlt              BitBlt@36
%define CreateCompatibleDC  CreateCompatibleDC@4
%define CreateDIBSection    CreateDIBSection@24
%define DeleteDC            DeleteDC@4
%define GetLastError        GetLastError@0
%define CreateBitmap        CreateBitmap@20



%define WM_SETFOCUS         0x0007
%define WM_KILLFOCUS        0x0008
%define WM_ENABLE           0x000A
%define WM_SETREDRAW        0x000B
%define WM_SETTEXT          0x000C
%define WM_GETTEXT          0x000D
%define WM_GETTEXTLENGTH    0x000E
%define WM_PAINT            0x000F
%define WM_CLOSE            0x0010
%define WM_NCCREATE         0x0081
%define WM_QUIT             0x0012
%define WM_SYSKEYDOWN       0x0104
%define WM_SYSKEYUP         0x0105
%define WM_KEYDOWN          0x0100
%define WM_KEYUP            0x0101
%define WM_SIZE             0x0005

%define WS_CAPTION          0x00C00000
%define WS_MINIMIZEBOX      0x00020000
%define WS_SYSMENU          0x00080000

%define CW_USEDEFAULT       0x80000000

%define GWLP_USERDATA       -21
%define GWLP_WNDPROC        -4

%define PM_REMOVE           0x0001

%define CS_OWNDC            0x0020

%define PATCOPY             0x00F00021
%define PATINVERT           0x005A0049
%define DSTINVERT           0x00550009
%define BLACKNESS           0x00000042
%define WHITENESS           0x00FF0062
%define SRCCOPY             0x00CC0020

%define BI_RGB              0x00000000

%define DIB_RGB_COLORS      0x00000000



struc WNDCLASSA
    .style          resd 1
    .lpfnWndProc    resd 1
    .cbClsExtra     resd 1
    .cbEndExtra     resd 1
    .hInstance      resd 1
    .hIcon          resd 1
    .hCursor        resd 1
    .hbrBackgroung  resd 1
    .lpszMenuName   resd 1
    .lpszClassName  resd 1
    .sizeof         equ $-.style
endstruc

struc CREATESTRUCTA
    .lpCreateParams     resd 1
    .hInstance          resd 1
    .hMenu              resd 1
    .hwndParent         resd 1
    .cy                 resd 1
    .cx                 resd 1
    .y                  resd 1
    .x                  resd 1
    .style              resd 1
    .lpszName           resd 1
    .lpszClass          resd 1
    .dwExStyle          resd 1
    .sizeof             equ $-.lpCreateParams
endstruc

struc MSG
    .hwnd               resd 1
    .message            resd 1
    .wParam             resd 1
    .lParam             resd 1
    .time               resd 1
    .pt                 resd 1
    .sizeof             equ $-.hwnd
endstruc

struc RECT
    .left               resd 1
    .top                resd 1
    .right              resd 1
    .bottom             resd 1
    .sizeof             equ $-.left
endstruc

struc PAINTSTRUCT
    .hdc                resd 1
    .fErase             resd 1
    .rcPaint            resb RECT.sizeof
    .fRestore           resd 1
    .fIncUpdate         resd 1
    .rgbReserved        resb 32
    .sizeof             equ $-.hdc
endstruc

struc BITMAPINFOHEADER
    .biSize             resd 1
    .biWidth            resd 1
    .biHeight           resd 1
    .biPlanes           resw 1
    .biBitCount         resw 1
    .biCompression      resd 1
    .biSizeImage        resd 1
    .biXPelsPerMeter    resd 1
    .biYPelsPerMeter    resd 1
    .biClrUsed          resd 1
    .biClrImportant     resd 1
    .sizeof             equ $-.biSize
endstruc

struc RGBQUAD
    .rgbBlue            resb 1
    .rgbGreen           resb 1
    .rgbRed             resb 1
    .rgbReserved        resb 1
    .sizeof             equ $-.rgbBlue
endstruc

struc BITMAPINFO
    .bmiHeader          resb BITMAPINFOHEADER.sizeof
    .bmiColors          resb RGBQUAD.sizeof
    .sizeof             equ $-.bmiHeader
endstruc

struc BITMAP
    .bmType             resd 1
    .bmWidth            resd 1
    .bmHeight           resd 1
    .bmWidthBytes       resd 1
    .bmPlanes           resw 1
    .bmBitsPixel        resw 1
    .bmBits             resd 1
    .sizeof             equ $-.bmType
endstruc



%endif ; !_TETRIS_LIB_WINAPI_WINDOW_