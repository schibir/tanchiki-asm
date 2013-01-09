include windows.inc
include GraphX.inc
extrn disp:dword
extrn frame:dword
extrn kadr:dword
extrn debug_val:dword
public pix_lev
.386
.model flat
data6 segment para public 'data'
   fon_pack db "fon.pkx",0
   fon_name db "Tex .bmp",0
   tex_fon textura <?,?,offset pix_fon,offset fon_name>
   spr_fon sprite <32,32,32+WPOLE*16,32+HPOLE*16,0,0>
   spr_ram1 sprite <32,0,32+WPOLE*16,32,0,0>
   spr_ram2 sprite <32,32+HPOLE*16,32+WPOLE*16,HDISP,0,0>
   spr_ram3 sprite <0,32,32,32+HPOLE*16,0,0>
   spr_ram4 sprite <32+WPOLE*16,32,64+WPOLE*16,32+HPOLE*16,0,0>
   lev_pack db "level.pkx",0
   lev_name db "Test .bmp",0
   level textura <?,?,offset pix_lev,offset lev_name>
   name_kir db "Stena1.bmp",0
   tex_kir textura <?,?,offset pix_kir,offset name_kir>
   name_half db "Stena2.bmp",0
   tex_half textura <?,?,offset pix_half,offset name_half>
   name_bet db "Stena7.bmp",0
   tex_bet textura <?,?,offset pix_bet,offset name_bet>
   name_les db "les.bmp",0
   tex_les textura <?,?,offset pix_les,offset name_les>
   name_mask db "mask.bmp",0
   tex_mask textura <?,?,offset pix_mask,offset name_mask>
   tex_mask1 textura <?,?,offset pix_mask+32*32*4,?>
   tex_mask2 textura <?,?,offset pix_mask+32*32*8,?>
   tex_mask3 textura <?,?,offset pix_mask+32*32*12,?>
   name_wat db "water.bmp",0
   tex_wat textura <?,?,offset pix_wat,offset name_wat>
   name_basa db "Basa.bmp",0
   tex_basa textura <?,?,offset pix_basa,offset name_basa>
   name_ugol db "ugol.bmp",0
   tex_ugol textura <?,?,offset pix_ugol,offset name_ugol>
   name_ram db "ramka.bmp",0
   tex_ram textura <?,?,offset pix_ram,offset name_ram>
   name_ram1 db "ramka1.bmp",0
   tex_ram1 textura <?,?,offset pix_ram1,offset name_ram1>
   temp dd ?
   n01 dd 0.1
   ram_count dd 0
   ram_call equ 20
   water_x dd 0
   water_time dd 0
   tex_pole dd offset tex_kir,offset tex_half,offset tex_bet,offset tex_les,offset tex_mask,offset tex_ugol,offset tex_ram,offset tex_ram1
data6 ends

data3 segment para public 'BSS'
   pix_fon dd 128*128 dup(?)
   pix_kir dd 32*32 dup(?)
   pix_half dd 32*32 dup(?)
   pix_bet dd 128*128 dup(?)
   pix_les dd 32*32 dup(?)
   pix_mask dd 32*32*4 dup(?)
   pix_wat dd 2048*64 dup(?)
   pix_basa dd 32*32 dup(?)
   pix_ugol dd 32*32 dup(?)
   pix_ram dd 256*32 dup(?)
   pix_ram1 dd 16*HPOLE*32 dup(?)
   pix_lev dd WPOLE*HPOLE dup(?)
   spr_brick sprite <?>
data3 ends
				
code1 segment dword public 'code'
load_level proc near
   push edx
   add dl, 'a'
   mov lev_name[4], dl
   mov esi, offset lev_pack
   call openpack
   mov edi, offset level
   call _load_bmp
   call closepack
   pop edx
   and dl, 7
   add dl, '0'
   mov fon_name[3], dl
   mov esi, offset fon_pack
   call openpack
   mov edi, offset tex_fon
   call _load_bmp
   call closepack
   mov edi, offset pix_lev
   mov ecx, HPOLE*WPOLE
   st1:
      mov eax, [edi]
      and eax, 00ffffffh
      cmp eax, 00ffffffh
      jne short ne1
         mov ax, T_PUSTO
      ne1:
      cmp eax, 00000000h
      jne short ne2
         mov ax, T_BETON
      ne2:
      cmp eax, 0000ff00h
      jne short ne3
         mov al, T_LES
         jmp short ne55
      ne3:
      cmp eax, 000000ffh
      jne short ne4
         mov al, T_WATER
         rnd 4
         mov ah, dl
      ne4:
      cmp eax, 00804000h
      jne short ne5
         mov al, T_BRICK
         ne55:
         rnd 2
         mov ah, dl
         rnd 2
         shl dl, 4
         or ah, dl
      ne5:
      stosd
   loop st1  
   mov pix_lev[4*WPOLE*(HPOLE-1)-4*15], T_BASA
   mov pix_lev[4*WPOLE*(HPOLE-1)-4*16], T_BASA
   mov pix_lev[4*WPOLE*HPOLE-4*15], T_BASA
   mov pix_lev[4*WPOLE*HPOLE-4*16], T_BASA
   ret
load_level endp

load_pole proc near
   mov ecx, 8
   tp:
      mov edi, tex_pole[ecx*4-4]
      call _load_bmp
   loop tp
   mov esi, offset tex_mask
   mov edi, offset tex_mask1
   mov ecx, 3
   ld1:
      call rotate_tex
      add esi, size textura
      add edi, size textura
   loop ld1
   mov edi, offset tex_wat
   call _load_bmp
   mov edi, offset tex_basa
   jmp _load_bmp
load_pole endp

draw_fon:
   mov esi, offset tex_fon
   mov edi, offset spr_fon
   call draw_fast_t
   dec ram_count
   jns short ne_ram
      mov ram_count, ram_call
      mov esi, offset tex_ugol
      setxyc 0, 0
      call draw_fast
      setxyc 32+WPOLE*16, 0
      call draw_fast
      setxyc 32+WPOLE*16, 32+HPOLE*16
      call draw_fast
      setxyc 0, 32+HPOLE*16
      call draw_fast
      mov esi, offset tex_ram
      mov edi, offset spr_ram1
      call draw_fast_t
      mov edi, offset spr_ram2
      call draw_fast_t
      mov esi, offset tex_ram1
      setxyc 0, 32
      call draw_fast
      setxyc 32+WPOLE*16, 32
      call draw_fast
   ne_ram:
ret

draw_pole proc near
   cmp dl, T_WATER
   jne short ne_fon 
      push edx
      call draw_fon
      call TIME
      pop edx
      cmp eax, water_time
      jb short ne_fon
         add eax, 32
         mov water_time, eax
         add water_x, 64
         and water_x, 2047
   ne_fon:
   push ebp
   mov esi, offset pix_lev
   mov edi, offset spr_brick
   mov ch, HPOLE
   mov ebp, ((HDISP*4-25*4)*WDISP+24*4)+offset disp
   st3:
      mov cl, WPOLE
      st4:
         lodsd
         pusha
         test al, dl
         jz end1
            mov ebx, WPOLE
            sub bl, cl
            shl ebx, 4
            add ebx, 32
            mov [edi+offset sprite.left], ebx
            add ebx, 16
            mov [edi+offset sprite.right], ebx
            mov ebx, HPOLE
            sub bl, ch
            shl ebx, 4
            add ebx, 32
            mov [edi+offset sprite.top], ebx
            add ebx, 16
            mov [edi+offset sprite.bottom], ebx
            movzx ebx, ah
            and bl, 15
            shl ebx, 4
            mov [edi+offset sprite.tx], ebx
            movzx ebx, ah
            and bl, 0f0h
            mov [edi+offset sprite.ty], ebx
            cmp al, T_BRICK
            jne short ne6
               mov esi, offset tex_kir
               call draw_fast_t
               jmp short end1
            ne6:
            cmp al, T_LES
            jne short ne8
               mov esi, offset tex_les
               call draw_fast_ts
               jmp short end1
            ne8:
            cmp al, T_HALF_BRICK
            jne short neh
               mov esi, offset tex_half
               call draw_fast_ts
               jmp short end1
            neh:
            cmp al, T_BETON
            jne short ne7
               mov ebx, [edi+offset sprite.left]
               mov      [edi+offset sprite.tx], ebx
               mov ebx, [edi+offset sprite.top]
               mov      [edi+offset sprite.ty], ebx
               mov esi, offset tex_bet
               call draw_fast_t
               jmp short end1
            ne7:
            cmp al, T_WATER
            jne short end1
               mov ebx, [edi+offset sprite.left]
               add ebx, water_x
               mov      [edi+offset sprite.tx], ebx
               mov ebx, [edi+offset sprite.top]
               mov      [edi+offset sprite.ty], ebx
               movzx eax, ah
               imul eax, size textura
               mov esi, offset tex_wat
               mov edx, edi
               lea edi, [eax+offset tex_mask]
               push edi
               call draw_tex_to_mask
               pop esi
               mov edi, ebp
               call draw_fast_s
         end1:
         popa
         add ebp, 16*4
         dec cl
      jnz st4
      sub ebp, (16*WPOLE)*4+16*4*WDISP
      dec ch
   jnz st3  
   pop ebp 
   cmp dl, T_WATER
   jne short ne_basa
      mov esi, offset tex_basa
      mov edi, (32+32)*WDISP*4+(32+(WPOLE/2-1)*16)*4+offset disp
      call draw_fast_s
   ne_basa:
   ret
draw_pole endp
code1 ends
end 