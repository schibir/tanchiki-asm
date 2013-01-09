include windows.inc
include GraphX.inc
extrn wnd:dword
extrn debug_val:dword
extrn disp:dword
public kadr
public seed
public frame
.386
.model flat
data4 segment para public 'data'
   frame dd 0
   n600 dd 1000
   fr1 dd 0
   last1 dd 0
   now1 dd 0
data4 ends

data3 segment para public 'BSS'
   str db 16 dup(?)
   kadr dd ?
   seed dd ?
   keys db 256 dup(?)
data3 ends
				
code1 segment para public 'code'
GetKeyPress proc near
   push edx
   KEYDOWN edx
   pop edx
   test ax, ax
   jz short else1
      mov al, keys[edx]
      mov byte ptr keys[edx], -1
      not al
      ret
   else1:
      mov keys[edx], al
   ret
GetKeyPress endp

_printint proc near
   push edi
   mov  ebx, 10
   xor ecx, ecx
   do1:
      xor edx, edx 
      div ebx
      push edx
      inc ecx
      test eax, eax
   jnz short do1
   do2:
      pop eax
      add al, '0'
      stosb
   loop do2
   mov [edi], cl  ;byte ptr 0
   pop edi
   ret
_printint endp

calc_fps proc near
   inc fr1
   cmp fr1, 32
   jne short ne32
      call TIME
      push eax
      sub eax, last1
      mov now1, eax
      pop last1
      fild now1
      fild fr1
      fdiv
      fst dword ptr frame
      fild n600
      fxch
      fdiv
      fistp kadr
      mov fr1, 0
   ne32:
   ret
calc_fps endp

rand proc near
   mov eax, seed
   imul eax, 343FDh
   add eax, 269EC3h
   mov seed, eax
   shr eax, 17
   ret
rand endp

random proc near
   push eax
   call rand
   xor dx, dx
   div bx
   pop eax
   ret
random endp

_setxyv proc near
   neg ebx
   lea eax, [ebx+HDISP-1]
   mov ebx, eax
   shl eax, 9
   shl ebx, 7
   add eax, ebx
   add eax, ecx
   lea edi, [eax*4+offset disp]
   ret
_setxyv endp

_load_bmp proc near
   pusha
   push dword ptr [edi+offset textura.file]
   push edi
   mov edi, [edi+offset textura.file]
   call unpack
   pop edi
   call load_bmp
   call remove
   add esp, 4
   popa
   ret
_load_bmp endp
code1 ends
end