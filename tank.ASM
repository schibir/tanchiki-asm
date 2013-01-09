include windows.inc
include GraphX.inc
public tank
public tek_tank
public tex_tank
extrn disp:dword
extrn frame:dword
extrn kadr:dword
extrn debug_val:dword
extrn pix_lev:dword
extrn diff:dword
extrn usl:dword
extrn isresp:byte
extrn dplayer:byte
extrn lifetank:byte
extrn game_over:byte
extrn time_go:dword
pole equ pix_lev
.386
.model flat
data7 segment para public 'data'
   name_tank db "Tank .bmp",0
   tex_tank textura KOL_TANK*4 dup(?)
   sin dd -0.1,  0.0, 0.1, 0.0
   cos dd  0.0, 0.1, 0.0, -0.1
   time_resp dd 0
   my_key db VK_DOWN,VK_LEFT,VK_RIGHT,VK_UP,VK_SPACE,'S','A','D','W',VK_CONTROL
   key_tabl db K_DOWN,K_LEFT,K_RIGHT,K_UP
            dd A_DOWN,A_LEFT,A_RIGHT,A_UP
   ver_nap dw 5,3,3,1,12   ;down,left,right,up,sum
   wea_tabl dw W_NORMAL,W_NORMAL,W_NORMAL,W_SINGLE,W_NORMAL,W_NORMAL,W_POWER or W_ROCKET
   life_tabl db 1,1,1,1,1,4,6
   fire_time dd 0,300,250,200,150,100,100,100
   name_resp db "Rozd.bmp",0
   tex_resp textura 8 dup(?)
   name_bron db "shield.bmp",0
   tex_bron textura 16 dup(?)
   tex_temp textura <?,?,offset pix_temp,?>
   tabl dd 0,0,28,0,28,28,0,28
   skor_bot dd 1.12,1.12,0.80,0.80,1.60,0.64,0.48
   tabl_resp dd 3000,2750,2500,2250,2000,1875,1750,1625,1500,1375,1250,1125,1000,900,850,800
   tabl_shoot dd 1000,975,950,925,900,870,840,800,750,690,630,570,500,400,300,200
   tek_tank dd ?
data7 ends

data3 segment para public 'BSS'
   tank TANK MAX_TANK dup(?)
   pix_tank dd 32*32*4*KOL_TANK dup(?)
   pix_resp dd 64*64*8 dup(?)
   pix_bron dd 48*48*16 dup(?)
   pix_temp dd 192*192 dup(?)
data3 ends
				
code1 segment dword public 'code'
load_resp proc near
   mov tex_temp.file, esi
   push edi
   mov edi, offset tex_temp
   call _load_bmp
   mov esi, offset tex_temp
   pop edi
   movzx dx, ch
   f1:
      mov [edi+offset textura.pix], ebp
      call get_kadr
      add edi, size textura
      inc dh
      dec cl
   jnz short f1
   ret
load_resp endp

reset_tank proc near
   mov edi, offset tank
   mov ecx, (size TANK)*MAX_TANK
   xor al, al
   rep stosb
   mov time_resp, 0
   ret
reset_tank endp

load_tank proc near
   load_all_kadr name_resp, tex_resp, pix_resp, 408h
   load_all_kadr name_bron, tex_bron, pix_bron, 410h
   call reset_tank
   xor cl, cl
   mov edi, offset tex_tank
   mov edx, offset pix_tank
   st1:
      mov al, cl
      add al, '0'
      mov name_tank[4], al
      mov [edi+offset textura.pix], edx
      mov dword ptr [edi+offset textura.file], offset name_tank
      push edi
      call _load_bmp
      pop esi
      lea edi, [esi+size textura]
      mov ch, 3
      st2:
         add edx, 32*32*4
         mov [edi+offset textura.pix], edx
         call rotate_tex
         add esi, size textura
         add edi, size textura
         dec ch
      jnz short st2
      add edx, 32*32*4
      inc cl
      cmp cl, KOL_TANK
   jne short st1
   ret
load_tank endp

respown_tank proc near
   push ecx
   mov al, dl
   and al, 15
   cmp al, T_PLAYER2
   ja short else1
      mov ebx, 32+(WPOLE/2-5)*16
      jne short ne2
         add ebx, 8*16
      ne2:
      pshf ebx
      pop dword ptr [edi+offset TANK.x]
      pshf 32+(HPOLE-2)*16
      pop dword ptr [edi+offset TANK.y]
      mov dword ptr [edi+offset TANK.angle], A_UP
      mov byte ptr [edi+offset TANK.kto], al
      jmp short endif1
   else1:
      mov dword ptr [edi+offset TANK.angle], A_DOWN
      rnd KOL_TANK-3
      add dx, 2
      mov [edi+offset TANK.kto], dl
      mov esi, edi
      lp1:
         pshf 32
         pop dword ptr [esi+offset TANK.y]
         rnd (WPOLE-1)*16
         add edx, 32
         and edx, 0fff0h
         pshf edx
         pop dword ptr [esi+offset TANK.x]
         call tank_pole
      jc short lp1
      mov edi, esi
   endif1:
   movzx eax, byte ptr [edi+offset TANK.kto]
   mov eax, skor_bot[eax*4]
   mov dword ptr [edi+offset TANK.skor], eax
   mov byte ptr [edi+offset TANK.etap], E_RESP
   mov byte ptr [edi+offset TANK.key], 0
   call TIME
   add eax, 2000
   mov dword ptr [edi+offset TANK.tik], eax
   mov dword ptr [edi+offset TANK.firetime], 0
   movzx eax, byte ptr [edi+offset TANK.kto]
   mov dl, life_tabl[eax]
   mov [edi+offset TANK.tek_life], dl
   mov dx, wea_tabl[eax*2]
   lea edi, [edi+offset TANK.weapon]
   pop ecx
   jmp reset_weapon
respown_tank endp

keydown macro k
   push ecx
   movzx eax, byte ptr k
   push eax
   call GetAsyncKeyState
   pop ecx
endm

my_tank:
   push ecx
   cmp game_over, 1
   je short nesh
   mov byte ptr [esi+offset TANK.key], 0
   movzx edi, byte ptr [esi+offset TANK.kto]
   imul edi, 5
   mov ecx, 3
   stk:
      keydown my_key[edi+ecx]
      test ax, ax
      jz short neup
         mov al, key_tabl[ecx]
         mov byte ptr [esi+offset TANK.key], al
         mov eax, dword ptr key_tabl[ecx*4+4]
         mov dword ptr [esi+offset TANK.angle], eax
      neup:
      dec ecx
   jns short stk
   movzx edx, my_key[edi+4]
   call GetKeyPress
   test al, al
   jz short nesh
      call shoot
   nesh:
   pop ecx
   ret
bot_tank:
   push ecx
   inc tek_tank
   call TIME
   cmp eax, [esi+offset TANK.time_nap]
   jb short netik
      rnd 2000
      movzx edx, dx
      lea eax, [eax+edx+500]
      mov [esi+offset TANK.time_nap], eax
      rnd ver_nap[8]
      mov ecx, 3
      stbot:
         sub dx, ver_nap[ecx*2]
         jae short netup
            mov al, key_tabl[ecx]
            mov byte ptr [esi+offset TANK.key], al
            mov eax, dword ptr key_tabl[ecx*4+4]
            mov dword ptr [esi+offset TANK.angle], eax
            jmp short netik
         netup:
         dec ecx
      jns short stbot
   netik:
   call TIME
   cmp eax, [esi+offset TANK.time_shoot]
   jb short neshoot
      mov ebx, diff
      add eax, tabl_shoot[ebx*4]
      mov [esi+offset TANK.time_shoot], eax
      rnd 2
      test dx, dx
      jz short neshoot
         rnd 3
         call shoot
   neshoot:
   pop ecx
   ret
tank_pole:
   push dword ptr [esi+offset TANK.x]
   popi ebx
   sub ebx, 30
   jbe short set
   cmp ebx, 2+(WPOLE-2)*16+1
   jae short set
   push dword ptr [esi+offset TANK.y]
   popi eax
   sub eax, 30
   jbe short set
   cmp eax, 2+(HPOLE-2)*16+1
   jae short set
   mov edx, eax
   mov ebp, ebx
   mov ecx, 6
   lp:
      add ebx, tabl[ecx*4]
      add eax, tabl[ecx*4+4]
      shr eax, 4
      shr ebx, 4
      imul eax, WPOLE
      add eax, ebx
      lea edi, [offset pole+eax*4]
      cmp byte ptr [edi], T_LES
      ja short set
      mov eax, edx
      mov ebx, ebp
      sub ecx, 2
   jns short lp
   clc
   ret
set:
   stc
   ret
tank_tank:
   push ecx
   push dword ptr [esi+offset TANK.x]
   popi eax
   add eax, 8
   and al, 0f0h
   push dword ptr [esi+offset TANK.y]
   popi ebx
   add ebx, 8
   and bl, 0f0h
   push dword ptr [edi+offset TANK.x]
   popi ecx
   add ecx, 8
   and cl, 0f0h
   push dword ptr [edi+offset TANK.y]
   popi edx
   add edx, 8
   and dl, 0f0h
   sub eax, ecx
   cmp eax, 32
   jge short neset
   cmp eax, -32
   jle short neset
   sub ebx, edx
   cmp ebx, 32
   jge short neset
   cmp ebx, -32
   jle short neset
   stc
   pop ecx
   ret
neset:
   clc
   pop ecx
   ret
draw_tank:
   push ecx
   push esi
   mov ecx, [esi+offset TANK.xi]
   mov ebx, [esi+offset TANK.yi]
   setxyv
   movzx eax, byte ptr [esi+offset TANK.kto]
   shl eax, 2
   add eax, [esi+offset TANK.angle]
   imul eax, size textura
   lea esi, [eax+offset tex_tank]
   call draw_fast_s
   pop esi
   pop ecx
   ret
draw_resp:
   push eax
   push ecx
   push esi
   mov ecx, [esi+offset TANK.xi]
   sub ecx, edx
   mov ebx, [esi+offset TANK.yi]
   sub ebx, edx
   push eax
   setxyv
   pop eax
   mov ebx, [esi+offset TANK.tik]
   sub ebx, eax
   cmp ebp, offset tex_resp
   jne short ner
      shr ebx, 6
      and ebx, 7
      imul ebx, size textura
      lea esi, [ebx+ebp]
      call draw_blend_lerp
      jmp short ener
   ner:
      shr ebx, 5
      and ebx, 15
      imul ebx, size textura
      lea esi, [ebx+ebp]
      call draw_blend_add
   ener:
   pop esi
   pop ecx
   pop eax
   ret
collide_pole:
   sx=dword ptr [esp+4]
   sy=dword ptr [esp+8]
   fld dword ptr [esi+offset TANK.x]
   fsub sx
   fstp dword ptr [esi+offset TANK.x]
   fld dword ptr [esi+offset TANK.y]
   fsub sy
   fstp dword ptr [esi+offset TANK.y]
   mov byte ptr [esi+offset TANK.key], 0
   call TIME
   add eax, 100
   rnd 300
   movzx edx, dx
   add eax, edx
   mov [esi+offset TANK.time_nap], eax
   ret
move_tank:
   push ecx
   push eax
   push eax
   sx=dword ptr [esp]
   sy=dword ptr [esp+4]
   mov eax, [esi+offset TANK.angle]
   fld dword ptr [esi+offset TANK.skor]
   fmul frame
   fld st
   fmul dword ptr cos[eax*4]
   fst sx
   fadd dword ptr [esi+offset TANK.x]
   fstp dword ptr [esi+offset TANK.x]
   fmul dword ptr sin[eax*4]
   fst sy
   fadd dword ptr [esi+offset TANK.y]
   fstp dword ptr [esi+offset TANK.y]
   call tank_pole
   jnc short nepole
      call collide_pole
   nepole:
   mov edi, offset tank
   mov ecx, MAX_TANK
   all_tank:
      cmp byte ptr [edi+offset TANK.etap], E_EST
      jb short nexttank
      cmp esi, edi
      je short nexttank
         call tank_tank
         jnc short nexttank
            call collide_pole
            jmp short break
      nexttank:
      add edi, size TANK
   loop all_tank
   break:
   add esp, 8
   xor edi, edi
   test byte ptr [esi+offset TANK.key], K_LEFT or K_RIGHT
   jz short nelr
      lea edi, [esi+offset TANK.y]
   nelr:
   test byte ptr [esi+offset TANK.key], K_UP or K_DOWN
   jz short neud
      lea edi, [esi+offset TANK.x]
   neud:
   test edi, edi
   jz short rtr
   push dword ptr [edi]
   popi eax
   add eax, 8
   and ax, 0fff0h
   pshf eax
   pop dword ptr [edi]
   rtr:
   pop ecx
   jmp return
update_fire:
   push ecx
   call TIME
   cmp dword ptr [esi+offset TANK.firetime], 0
   je short nefire
   cmp eax, [esi+offset TANK.time_fire]
   jb short nefire
      mov ebx, [esi+offset TANK.firetime]
      add eax, fire_time[ebx*4]
      mov [esi+offset TANK.time_fire], eax
      mov dl, P_FIRE
      mov ecx, 1
      mov eax, [esi+offset TANK.xi]
      sub eax, 16
      mov ebx, [esi+offset TANK.yi]
      sub ebx, 16
      cmp byte ptr [esi+offset TANK.kto], T_TRUP
      call part
   nefire:
   pop ecx
ret

update_tank proc near
   mov tek_tank, 0
   call TIME
   cmp eax, time_resp
   jb short neresp
      cmp isresp, 0
      je short neresp
      mov ebx, diff
      add eax, tabl_resp[ebx*4]
      rnd 3000
      movzx edx, dx
      add eax, edx
      mov time_resp, eax
      mov esi, offset tank+2*(size TANK)
      mov ecx, MAX_TANK
      beg1:
         mov al, [esi+offset TANK.etap]
         test al, al
         jnz short estb
            mov dl, RANDOM_TANK
            mov edi, esi
            call respown_tank
            jmp short neresp
         estb:
         add esi, size TANK
      loop beg1
   neresp:
   movzx ecx, dplayer
   inc ecx
   xor esi, esi
   mov al, -1
   mytank:
      cmp tank.etap[esi], E_NET
      jne short ne22
         cmp lifetank, 0
         jz short neresp1
            mov dl, tank.kto[esi]
            push esi
            push edi
            push eax
            lea edi, tank[esi]
            call respown_tank
            pop eax
            dec lifetank
            pop edi
            pop esi
            jmp short ne22
         neresp1:
            inc al
      ne22:
      add esi, size TANK
   loop mytank
   cmp al, dplayer
   jne short nego
      cmp game_over, 1
      je short nego
      call TIME
      add eax, 3000
      mov time_go, eax
      mov game_over, 1
   nego:
   mov esi, offset tank
   mov ecx, MAX_TANK
   next:
      fld dword ptr [esi+offset TANK.x]
      fistp dword ptr [esi+offset TANK.xi]
      fld dword ptr [esi+offset TANK.y]
      fistp dword ptr [esi+offset TANK.yi]
      mov al, [esi+offset TANK.etap]
      push eax
      cmp al, E_EST
      jb short resptank
         call draw_tank
         mov al, [esi+offset TANK.etap]
         cmp byte ptr [esi+offset TANK.etap], E_BRON
         jne short nebron
            push ecx
            call TIME
            pop ecx
            mov edx, 8
            mov ebp, offset tex_bron
            call draw_resp
            cmp eax, [esi+offset TANK.tik]
            jb short nebron
               mov byte ptr [esi+offset TANK.etap], E_EST
         nebron:
         call update_fire
         cmp byte ptr [esi+offset TANK.kto], T_PLAYER2
         ja short bot 
            call my_tank
            jmp short ebot
         bot:
            cmp byte ptr [esi+offset TANK.kto], T_TRUP
            je resptank
            call bot_tank
         ebot:
         mov al, [esi+offset TANK.key]
         test al, al
         jnz move_tank
         return:
      resptank:
      pop eax
      cmp al, E_RESP
      jne short nettank
         push ecx
         call TIME
         pop ecx
         mov edx, 16
         mov ebp, offset tex_resp
         call draw_resp
         cmp eax, [esi+offset TANK.tik]
         jb short nettank
            mov byte ptr [esi+offset TANK.etap], E_BRON
            add eax, 3000
            mov [esi+offset TANK.tik], eax
            mov edi, offset tank
            push ecx
            mov ecx, MAX_TANK
            allt:
               cmp esi, edi
               je short nextt
               cmp byte ptr [edi+offset TANK.etap], E_EST
               jb short nextt
                  call tank_tank
                  jnc short nextt
                     mov byte ptr [edi+offset TANK.etap], E_NET
                     push dword ptr [edi+offset TANK.x]
                     popi eax
                     push dword ptr [edi+offset TANK.y]
                     popi ebx
                     mov dl, 1
                     call explode
               nextt:
               add edi, size TANK
            loop allt
            pop ecx
      nettank:
      push esi
      lea esi, [esi+offset TANK.weapon]
      call update_weapon
      pop esi 
      add esi, size TANK
      dec ecx
   jnz next
   ret
update_tank endp
code1 ends
end 