include windows.inc
include GraphX.inc
public dc
public wnd
public QUIT
.386
.model flat
data1 segment para public 'data'
   dc dd ?
   wnd dd ?
   QUIT db 0
   TANK_REF	db 'Танчики',0
   wc	WNDCLASSEX <size WNDCLASSEX,CS_HREDRAW or CS_VREDRAW,offset win_proc,0,0,?,?,?,0,0,offset TANK_REF,0>
   msg_	MSG	<0,0,0,0,0,0>
data1 ends
code1 segment para public 'code'
assume cs:code1, ds:data1, es:data1
main:
   cld
   xor ebx,ebx		
   push ebx
   call GetModuleHandle
   mov esi,eax		
   mov dword ptr wc.hInstance,eax 
   push offset wc
   call RegisterClassEx	
   push ebx		
   push esi		
   push ebx		
   push ebx	
ifdef FULLSCREEN
   push ebx
   call ShowCursor
   push HDISP
   push WDISP
   push ebx	
   push ebx	
   push WS_POPUP
else	
   push HDISP+48
   push WDISP+10
   push ebx	
   push ebx	
   push WS_OVERLAPPEDWINDOW
endif
   push offset TANK_REF	
   push offset TANK_REF	
   push ebx		
   call CreateWindowEx	
   mov wnd, eax
   push eax
   push eax		
   push SW_SHOWNORMAL	
   push eax		
   call ShowWindow	
   call UpdateWindow	
   call GetDC
   mov dc, eax
   call load
   message_loop:
      cmp msg_.message, WM_QUIT
      je exit_msg_loop
      cmp QUIT, 1
      je exit_msg_loop
      xor ebx, ebx
      mov edi, offset msg_ 
      push PM_REMOVE
      push	ebx	
      push	ebx	
      push	ebx	
      push	edi 	
      call PeekMessage
      test eax, eax
      jz short else1
         push	edi		
         call	TranslateMessage 
         push	edi
         call	DispatchMessage	
         jmp short message_loop
      else1:
      call update
   jmp short message_loop
   exit_msg_loop:
ifdef FULLSCREEN
   push 1
   call ShowCursor
   push 0
   push 0
   call ChangeDisplaySettings
endif
   push	0
   call	ExitProcess
win_proc proc
   push	ebp
   mov	ebp,esp
   wp_hWnd   equ  dword ptr [ebp+08h]	
   wp_uMsg   equ  dword ptr [ebp+0Ch]	
   wp_wParam equ  dword ptr [ebp+10h]	
   wp_lParam equ  dword ptr [ebp+14h]	
   cmp	wp_uMsg,WM_DESTROY
   jne short	not_wm_destroy
      push	0		
      call	PostQuitMessage	
      jmp short end_wm_check	
   not_wm_destroy:
   leave		
   jmp	DefWindowProc	
   end_wm_check:
	leave		
	ret 16		
win_proc endp
code1 ends
end main