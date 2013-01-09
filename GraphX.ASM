include windows.inc
include GraphX.inc
public disp
extrn dc:dword
extrn wnd:dword
extrn debug_val:dword
.386
.mmx
.model flat
data2 segment para public 'data'
   bmi BITMAPINFO <0>
   font_name db "fonts1.bmp",0
   font textura <?,?,offset font_pix,offset font_name>
   font_param dd 7,10,100,15,20,212
   n20 db 20
   n3 dw 3
   flag db ?
data2 ends

data3 segment para public 'BSS'
   reserve_disp dd WDISP*16 dup(?)
   disp dd WDISP*(HDISP+16) dup(?)
   font_pix dd 512*256 dup(?)
   sprite_font sprite <?>
   bmp BITMAP <?>
   hdc dd ?
   pic dd ?
   rect RECT <?>
   devmode DEVMODE <?>
   masky dd ?
   v dd ?
   maskx dd ?
   tpix dd ?
   sx dd ?
   dlina dd ?
   w dd ?
data3 ends
				
code1 segment para public 'code'
create_graphx proc near
   mov bmi.bmiHeader.biSize, size BITMAPINFOHEADER
   mov bmi.bmiHeader.biWidth, WDISP
   mov bmi.bmiHeader.biHeight, HDISP
   mov bmi.bmiHeader.biPlanes, 1 
   mov bmi.bmiHeader.biBitCount, 32
   mov bmi.bmiHeader.biCompression, BI_RGB
   mov edi, offset font
   call _load_bmp
ifdef FULLSCREEN
   push offset devmode
   push -1
   push 0
   call EnumDisplaySettings
   mov devmode.dmPelsWidth, 32
   mov devmode.dmPelsHeight, WDISP
   mov devmode.dmDisplayFlags, HDISP
   push CDS_FULLSCREEN
   push offset devmode
   call ChangeDisplaySettings
endif
   ret
create_graphx endp

clear proc near
   mov edi, offset disp
   mov ecx, 640*480
   mov eax, 0
   rep stosd   
   ret
clear endp

render proc near
   xor ebx, ebx
   push DIB_RGB_COLORS
   push offset bmi
   push offset disp
   push HDISP
   push ebx
   push ebx
   push ebx
   push HDISP
   push WDISP
   push ebx
   push ebx
   push dc
   call SetDIBitsToDevice
   ret 
render endp

load_bmp proc near
   push ecx
   push LR_LOADFROMFILE or LR_CREATEDIBSECTION
   push 0
   push 0
   push IMAGE_BITMAP
   push dword ptr [edi+offset textura.file]
   push 0
   call LoadImage
   mov pic, eax 
   push 0
   call CreateCompatibleDC
   mov hdc, eax 
   push offset bmp
   push size bmp
   push pic
   call GetObject
   push pic
   push hdc
   call SelectObject
   mov eax, bmp.bmWidth
   mov [edi+offset textura.width], eax
   mov eax, bmp.bmHeight
   mov [edi+offset textura.height], eax
   mov esi, edi
   mov edi, [esi+offset textura.pix]
   xor ecx, ecx
   lp1:
      xor ebx, ebx
      lp2:
         push ecx
         push ecx
         push ebx
         push hdc
         call GetPixel
         xor edx, edx
         mov ecx, eax
         shr ecx, 16
         add dl, cl
         mov ch, ah
         add dl, ch
         adc dh, 0
         add dl, al
         adc dh, 0
         shl eax, 16
         mov ax, cx
         and eax, 00ffffffh
         push eax
         mov ax, dx
         xor dx, dx
         div n3
         mov dh, al
         shl edx, 16
         and edx, 0ff000000h
         pop eax
         or eax, edx
         stosd
         pop ecx
         inc ebx
         cmp ebx, [esi+offset textura.width]
      jne short lp2
      inc ecx
      cmp ecx, [esi+offset textura.height]
   jne short lp1
   push pic
   call DeleteObject
   push hdc
   call DeleteDC
   pop ecx
   ret
load_bmp endp

rotate_tex proc
   pusha
   mov ecx, [esi+offset textura.height]
   mov [edi+offset textura.height], ecx
   mov edx, [esi+offset textura.width]
   mov [edi+offset textura.width], edx
   mov esi, [esi+offset textura.pix]
   mov edi, [edi+offset textura.pix]
   lea ebx, [edx*4]
   add edi, ebx
   beg:
      push ecx
      mov ecx, edx
      push edi
      beg1:
         lodsd
         mov [edi], eax
         add edi, ebx
      loop beg1
      pop edi
      sub edi, 4
      pop ecx
   loop beg
   popa
   ret
rotate_tex endp

get_kadr proc near
   pusha
   mov eax, [esi+offset textura.width]
   div dl
   movzx eax, al
   mov [edi+offset textura.width], eax
   mov [edi+offset textura.height], eax
   movzx cx, dl
   movzx ax, dh
   xor dx, dx
   div cx
   movzx edx, dx
   push edx
   movzx eax, ax
   imul eax, [edi+offset textura.width]
   imul eax, [esi+offset textura.width]
   mov ebx, eax
   pop eax
   imul eax, [edi+offset textura.width]
   add eax, ebx
   mov ebx, [esi+offset textura.width]
   mov edx, [edi+offset textura.width]
   sub ebx, edx
   mov esi, [esi+offset textura.pix]
   lea esi, [esi+eax*4]
   mov edi, [edi+offset textura.pix]
   mov ecx, edx
   forj1:
      push ecx
      mov ecx, edx
      rep movsd
      lea esi, [esi+4*ebx]
      lea ebp, [ebp+4*edx]
      pop ecx
   loop forj1
   mov [esp+8], ebp
   popa
   ret
get_kadr endp

draw_fast proc near
   pusha
   mov ebx, [esi+offset textura.height]
   mov edx, [esi+offset textura.width]
   mov esi, [esi+offset textura.pix]
   st1:
      mov ecx, edx
      shr ecx, 2
      ff:
         movq mm0, [esi]
         movq mm1, [esi+8]
         movq [edi], mm0
         movq [edi+8], mm1
         add esi, 16
         add edi, 16
         sub ecx, 1
      jnz short ff
      lea eax, [edx*4+WDISP*4]
      sub edi, eax 
      dec ebx
   jnz short st1
   emms
   popa
   ret
draw_fast endp

draw_fast_t proc near
   pusha
   mov ecx, [edi+offset sprite.left]
   mov ebx, [edi+offset sprite.top]
   mov edx, edi
   setxyv
   mov eax, [esi+offset textura.pix]
   mov tpix, eax
   mov ecx, [edx+offset sprite.bottom]
   sub ecx, [edx+offset sprite.top]
   mov eax, [edx+offset sprite.ty]
   mov v, eax
   mov eax, [edx+offset sprite.tx]
   mov sx, eax
   mov eax, [edx+offset sprite.right]
   sub eax, [edx+offset sprite.left]
   mov dlina, eax
   mov eax, [esi+offset textura.width]
   mov w, eax
   dec eax
   mov ebp, eax
   mov eax, [esi+offset textura.height]
   dec eax
   mov masky, eax
   st5:
      mov ebx, sx
      mov esi, tpix
      push ecx
      mov ecx, dlina
      push ecx
      mov eax, v
      and eax, masky
      mul dword ptr w
      mov edx, eax
      test ecx, 1
      jnz short st66
      shr ecx, 1
      st6:
         mov eax, ebx
         add ebx, 2
         and eax, ebp
         add eax, edx
         movq mm0, [esi+eax*4]
         movq [edi], mm0
         add edi, 8
         sub ecx, 1
      jnz short st6
      jmp short st67
      st66:
         mov eax, ebx
         add ebx, 1
         and eax, ebp
         add eax, edx
         movd mm0, [esi+eax*4]
         movd [edi], mm0
         add edi, 4
         sub ecx, 1
      jnz short st66
      st67:
      inc dword ptr v
      pop ecx
      lea eax, [ecx*4+WDISP*4]
      sub edi, eax
      pop ecx
      dec cx
   jnz short st5
   emms
   popa
   ret
draw_fast_t endp

draw_fast_s proc near
   pusha
   mov ebx, [esi+offset textura.height]
   mov edx, [esi+offset textura.width]
   mov esi, [esi+offset textura.pix]
   lea ebp, [edx*4+WDISP*4]
   pxor mm3, mm3
   st2:
      mov ecx, edx
      st3:
         movq mm0, [esi]
         movq mm2, [edi]
         movq mm1, mm0
         pcmpeqd mm1, mm3
         pand mm2, mm1
         por mm2, mm0
         movq [edi], mm2
         add edi, 8
         add esi, 8
         sub ecx, 2
      jnz short st3
      sub edi, ebp 
      dec ebx
   jnz short st2
   emms
   popa
   ret
draw_fast_s endp

draw_fast_ts proc near
   pusha
   mov ecx, [edi+offset sprite.left]
   mov ebx, [edi+offset sprite.top]
   mov edx, edi
   setxyv
   mov eax, [esi+offset textura.pix]
   mov tpix, eax
   mov ecx, [edx+offset sprite.bottom]
   sub ecx, [edx+offset sprite.top]
   mov eax, [edx+offset sprite.ty]
   mov v, eax
   mov eax, [edx+offset sprite.tx]
   mov sx, eax
   mov eax, [edx+offset sprite.right]
   sub eax, [edx+offset sprite.left]
   mov dlina, eax
   mov eax, [esi+offset textura.width]
   mov w, eax
   dec eax
   mov ebp, eax
   mov eax, [esi+offset textura.height]
   dec eax
   mov masky, eax
   pxor mm3, mm3
   st7:
      mov ebx, sx
      mov esi, tpix
      push ecx
      mov ecx, dlina
      push ecx
      mov eax, v
      and eax, masky
      mul dword ptr w
      mov edx, eax
      test ecx, 1
      jnz short st667
      shr ecx, 1
      st61:
         mov eax, ebx
         add ebx, 2
         and eax, ebp
         add eax, edx
         movq mm0, [esi+eax*4]
         movq mm2, [edi]
         movq mm1, mm0
         pcmpeqd mm1, mm3
         pand mm2, mm1
         por mm2, mm0
         movq [edi], mm2
         add edi, 8
         sub ecx, 1
      jnz short st61
      jmp short st677
      st667:
         mov eax, ebx
         add ebx, 1
         and eax, ebp
         add eax, edx
         movd mm0, [esi+eax*4]
         movd mm2, [edi]
         movq mm1, mm0
         pcmpeqd mm1, mm3
         pand mm2, mm1
         por mm2, mm0
         movd [edi], mm2
         add edi, 4
         sub ecx, 1
      jnz short st667
      st677:
      inc dword ptr v
      pop ecx
      lea eax, [ecx*4+WDISP*4]
      sub edi, eax
      pop ecx
      dec ecx
   jnz st7
   emms
   popa
   ret
draw_fast_ts endp

draw_text proc near
   mov flag, al
   mov ecx, esi
   st9:
      lodsb
      test al, al
   jnz short st9
   sub esi, ecx
   xchg ecx, esi
   xor edi, edi
   test flag, small
   jnz short end2
      mov edi, 12
   end2:
   test flag, center
   jz short end1
      push edx
      mov eax, font_param[edi]
      shr eax, 1
      mul ecx
      sub ebx, eax
      pop edx
   end1:
   mov sprite_font.left, ebx
   mov sprite_font.top, edx
   mov eax, ebx
   add eax, font_param[edi]
   mov sprite_font.right, eax
   mov eax, edx
   add eax, font_param[edi+4]
   mov sprite_font.bottom, eax
   st10:
      xor eax, eax
      lodsb
      sub al, 32
      test flag, small
      jz short else1
         mov bh, al
         shr bh, 4
         mov bl, al
         and bl, 15
         jmp short end3
      else1:
         mov bl, al
         div n20
         mov bh, al
         mul n20
         sub bl, al
      end3:
      xor eax, eax
      mov al, bl
      mul font_param[edi]
      add eax, font_param[edi+8]
      mov sprite_font.tx, eax
      xor eax, eax
      mov al, bh
      mul font_param[edi+4]
      mov sprite_font.ty, eax
      push esi
      push edi
      mov esi, offset font
      mov edi, offset sprite_font
      test flag, alpha
      jz short neal
         call draw_fast_ts
         jmp short endal
      neal:
         call draw_fast_t
      endal:
      pop edi
      pop esi
      mov eax, font_param[edi]
      add sprite_font.left, eax
      add sprite_font.right, eax
      dec ecx
   jnz st10
   ret
draw_text endp

draw_blend_lerp proc near
   pusha
   mov ecx, [esi+offset textura.height]
   mov edx, [esi+offset textura.width]
   mov esi, [esi+offset textura.pix]
   pxor mm7, mm7
   st11:
      push ecx
      mov ecx, edx
      push edx
      blending:
         mov eax, [esi]
         movd mm0, eax
         mov ebx, eax
         rol ebx, 8
         mov al, bl
         mov ah, al
         rol eax, 8
         movd mm4, eax
         punpcklbw mm4, mm7
         movd mm1, [edi]
         punpcklbw mm0, mm7
         punpcklbw mm1, mm7
         psubw mm0, mm1
         psllw mm1, 8
         pmullw mm0, mm4
         paddw mm1, mm0
         psrlw mm1, 8
         packuswb mm1, mm1
         movd [edi], mm1
         add edi, 4
         add esi, 4
         dec ecx
      jnz blending
      pop edx
      lea eax, [edx*4+WDISP*4]
      sub edi, eax 
      pop ecx
      dec ecx
   jnz st11
   emms
   popa
   ret
draw_blend_lerp endp

draw_blend_add proc near
   pusha
   mov ecx, [esi+offset textura.height]
   mov edx, [esi+offset textura.width]
   mov esi, [esi+offset textura.pix]
   st12:
      push ecx
      mov ecx, edx
      push edx
      blending1:
         movq mm0, [esi]
         movq mm1, [edi]
         paddusb mm0, mm1
         movq [edi], mm0
         add esi, 8
         add edi, 8
         sub ecx, 2
      jnz short blending1
      pop edx
      lea eax, [edx*4+WDISP*4]
      sub edi, eax 
      pop ecx
   loop st12
   emms
   popa
   ret
draw_blend_add endp

draw_tex_to_mask proc near
   pusha
   mov eax, [esi+offset textura.pix]
   mov tpix, eax
   mov ecx, 32 
   mov eax, [edx+offset sprite.ty]
   mov ebp, eax
   mov eax, [edx+offset sprite.tx]
   mov sx, eax
   mov edi, [edi+offset textura.pix]
   pxor mm7, mm7
   pcmpeqd mm6, mm6
   st14:
      mov ebx, sx
      mov esi, tpix
      push ecx
      mov ecx, 32
      mov edx, ebp
      and edx, 63
      shl edx, 11
      st15:
         mov eax, ebx
         and eax, 2047
         add eax, edx
         inc ebx
         movd mm0, [edi]
         movd mm1, [esi+eax*4]
         pcmpeqd mm0, mm7
         pxor mm0, mm6
         pand mm0, mm1
         movd [edi], mm0
         add edi, 4
         dec ecx
      jnz short st15
      inc ebp
      pop ecx
      dec ecx
   jnz short st14
   emms
   popa
   ret
draw_tex_to_mask endp
code1 ends
end