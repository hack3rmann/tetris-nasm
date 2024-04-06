%ifndef _TETRIS_LIB_WINAPI_WINDOW_
%define _TETRIS_LIB_WINAPI_WINDOW_



extern GetModuleHandleA@4, RegisterClassA@4, CreateWindowExA@48, ShowWindow@8
extern DefWindowProcA@16, UnregisterClassA@8, DestroyWindow@4
extern SetWindowLongA@12, GetWindowLongA@8, PostQuitMessage@4
extern PeekMessageA@20, TranslateMessage@4, DispatchMessageA@4
extern GetMessageA@16

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

%define WS_CAPTION          0x00C00000
%define WS_MINIMIZEBOX      0x00020000
%define WS_SYSMENU          0x00080000

%define CW_USEDEFAULT       0x80000000

%define GWLP_USERDATA       -21
%define GWLP_WNDPROC        -4

%define PM_REMOVE           0x0001



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
    .hwnd                resd 1
    .message             resd 1
    .wParam              resd 1
    .lParam              resd 1
    .time                resd 1
    .pt                  resd 1
    .sizeof             equ $-.hwnd
endstruc



%endif ; !_TETRIS_LIB_WINAPI_WINDOW_