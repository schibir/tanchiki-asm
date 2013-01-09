includelib import32.lib
   extrn	DispatchMessageA:near
   extrn	TranslateMessage:near
   extrn	GetMessageA:near
   extrn	UpdateWindow:near
   extrn	ShowWindow:near
   extrn	CreateWindowExA:near
   extrn	DefWindowProcA:near
   extrn	PostQuitMessage:near
   extrn	RegisterClassExA:near
   extrn	SetWindowTextA:near
   extrn	PeekMessageA:near
   extrn	SetDIBitsToDevice:near
   extrn	GetDC:near
   extrn 	SetWindowTextA:near
   extrn 	timeGetTime:near
   extrn 	GetAsyncKeyState:near
   extrn 	LoadImageA:near
   extrn 	CreateCompatibleDC:near
   extrn 	ShowCursor:near
   DispatchMessage	equ	DispatchMessageA
   GetMessage	equ	GetMessageA
   CreateWindowEx	equ	CreateWindowExA
   DefWindowProc	equ	DefWindowProcA
   RegisterClassEx	equ	RegisterClassExA
   SetWindowText	equ	SetWindowTextA
   PeekMessage		equ	PeekMessageA
   SetWindowText	equ	SetWindowTextA
   LoadImage equ LoadImageA
WS_OVERLAPPEDWINDOW 	equ	0CF0000h
WS_POPUP         	equ     80000000h
WM_DESTROY		equ	2
WM_COMMAND		equ	111h
WM_QUIT                 equ     0012h
PM_REMOVE               equ	0001h
CS_HREDRAW		equ	2
CS_VREDRAW		equ	1
CW_USEDEFAULT		equ	80000000h
SW_SHOWNORMAL		equ	1
BI_RGB        		equ	0h
DIB_RGB_COLORS      	equ	0

WNDCLASSEX	struc
   cbSize		dd	?
   style		dd	?
   lpfnWndProc	dd	?
   cbClsExtra	dd	?
   cbWndExtra	dd	?
   hInstance	dd	?
   hIcon		dd	?
   hCursor		dd	?
   hbrBackground	dd	?
   lpszMenuName	dd	?
   lpszClassName	dd	?
   hIconSm		dd	?
WNDCLASSEX	ends

MSG	struc
   hwnd	dd	?
   message	dd	?
   wParam	dd	?
   lParam	dd	?
   time	dd	?
   pt	dd	?
MSG	ends

BITMAPINFOHEADER struc
   biSize dd ?
   biWidth dd ? 
   biHeight dd ?
   biPlanes dw ?
   biBitCount dw ?
   biCompression dd ?
   biSizeImage dd ?
   biXPelsPerMeter dd ?
   biYPelsPerMeter dd ?
   biClrUsed dd ?
   biClrImportant dd ?
BITMAPINFOHEADER ends

BITMAPINFO  struc
    bmiHeader BITMAPINFOHEADER <?>
    bmiColors dd ?
BITMAPINFO ends

BITMAP struc
    bmType dd ?
    bmWidth dd ?
    bmHeight dd ?
    bmWidthBytes dd ?
    bmPlanes dw ?
    bmBitsPixel dw ?
    bmBits dd ?
BITMAP ends
   extrn	ExitProcess:near
   extrn	GetModuleHandleA:near
   extrn	CloseHandle:near
   extrn	GlobalAlloc:near
   extrn	GlobalFree:near
   GetModuleHandle	equ	GetModuleHandleA
VK_ESCAPE  equ       1Bh
VK_SPACE   equ       20h
VK_RETURN  equ       0Dh
VK_LEFT    equ       25h
VK_UP      equ       26h
VK_RIGHT   equ       27h
VK_DOWN    equ       28h
VK_CONTROL equ       11h
LR_CREATEDIBSECTION equ 2000h
LR_LOADFROMFILE     equ 0010h
IMAGE_BITMAP        equ    0h
extrn GetObjectA:near
GetObject equ GetObjectA
extrn SelectObject:near
extrn GetPixel:near
extrn DeleteObject:near
extrn DeleteDC:near
   extrn 	CreateCompatibleDC:near

CCHDEVICENAME equ 32
CCHFORMNAME equ 32

DEVMODE struc 
    dmDeviceName db CCHDEVICENAME dup(?)
    dmSpecVersion dw ?
    dmDriverVersion dw ?
    dmSize dw ?
    dmDriverExtra dw ?
    dmFields dd ?
    dmPosition  dd ?
    dmScale dw ?
    dmCopies dw ?
    dmDefaultSource dw ?
    dmPrintQuality dw ?
    dmColor dw ?
    dmDuplex dw ?
    dmYResolution dw ?
    dmTTOption dw ?
    dmCollate dw ?
    dmFormName db CCHFORMNAME dup(?)
    dmLogPixels dw ?
    dmBitsPerPel dd ?
    dmPelsWidth dd ?
    dmPelsHeight dd ?
    dmDisplayFlags dd ?
    dmDisplayFrequency dd ?
    dmICMMethod dd ?
    dmICMIntent dd ?
    dmMediaType dd ?
    dmDitherType dd ?
    dmReserved1 dd ?
    dmReserved2 dd ?
    dmPanningWidth dd ?
    dmPanningHeight dd ?
DEVMODE ends

DM_PELSWIDTH  equ      00080000h
DM_PELSHEIGHT equ      00100000h
DM_BITSPERPEL equ      00040000h
CDS_FULLSCREEN  equ    00000004h
extrn ChangeDisplaySettingsA:near
ChangeDisplaySettings equ ChangeDisplaySettingsA
extrn EnumDisplaySettingsA:near
EnumDisplaySettings equ EnumDisplaySettingsA

RECT struc
    left dd ?
    top dd ?
    right dd ?
    bottom dd ?
RECT ends

extrn GetWindowRect:near
extrn StretchDIBits:near
SRCCOPY   equ          00CC0020h

FILE struc
    _ptr dd ?
    _cnt dd ? 
    _base dd ?
    _flag dd ?
    _file dd ?
    _charbuf dd ?
    _bufsize dd ?
    _tmpfname dd ?
FILE ends

SEEK_CUR  equ  1
SEEK_END  equ  2
SEEK_SET  equ  0
extrn fopen:near
extrn fread:near
extrn fwrite:near
extrn fclose:near
extrn fseek:near
extrn strcmp:near
extrn remove:near
