include windows.inc
include GraphX.inc
extrn disp:dword
extrn frame:dword
extrn kadr:dword
extrn debug_val:dword
extrn pix_lev:dword
extrn tank:TANK
extrn score:dword
extrn score1:dword
extrn game_over:byte
extrn time_go:dword
pole equ pix_lev
.386
.model flat
data8 segment para public 'data'
   name_bul db "Pula.bmp",0
   tex_bul  textura 4 dup(?)
   name_rock db "Rocket.bmp",0
   tex_rock textura 4 dup(?)
   name_bur db "Burner1.bmp",0
   tex_bur textura 8 dup(?)
   name_fire db "Bullet1.bmp",0
   tex_fire textura 4*4 dup(?)
   sin dd -8, 16, 40,  16
   cos dd   16, 40, 16, -8
   sinf dd -0.1, 0.0, 0.1,  0.0
   cosf dd  0.0, 0.1, 0.0, -0.1
   grouph db 0,0,1,1,1,1,1,2
   add_ft db 3,3,3,3,3,2,1,2
   damage db 1,1,1,2,0
   skor_bul dd 1.92,4.80,4.80,4.80,1.60
   add_score dd 0,0,1,2,3,5,8,1
   razr_tabl db T_HALF_BRICK,T_HALF_BRICK,T_HALF_BRICK,T_PUSTO,T_PUSTO
   bet_tabl db T_BETON,T_BETON,T_BETON,T_PUSTO
   tex_tabl dd offset tex_bul,offset tex_bul,offset tex_bul,offset tex_bul,offset tex_rock,offset tex_fire
   off_tabl dd 16*WDISP*4+8*4,32*4-8*WDISP*4,-32*WDISP*4+8*4,-16*4-8*WDISP*4
   nWPOLE dw WPOLE
data8 ends

data3 segment para public 'BSS'
   pix_bul dd 16*16*4 dup(?)
   pix_rock dd 16*16*4 dup(?)
   pix_bur dd 32*32*8 dup(?)
   pix_fire dd 16*16*4*4 dup(?)
data3 ends
				
code1 segment dword public 'code'
load_fire:
   mov esi, offset tex_fire
   mov edi, offset tex_fire+(size textura)*4
   mov ecx, 12
   ld1:
      mov eax, [esi+offset textura.pix]
      add eax, 16*16*4*4
      mov [edi+offset textura.pix], eax
      call rotate_tex
      add esi, size textura
      add edi, size textura
   loop ld1
ret

load_weapon proc near
   load_all_kadr name_bul, tex_bul, pix_bul, 204h
   load_all_kadr name_rock, tex_rock, pix_rock, 204h
   load_all_kadr name_bur, tex_bur, pix_bur, 408h
   load_all_kadr name_fire, tex_fire, pix_fire, 204h
   jmp load_fire
load_weapon endp

draw_bul:
   push ecx
   push edi
   mov esi, edi
   mov ecx, [esi+offset BULLET.bxi]
   sub ecx, 8
   mov ebx, [esi+offset BULLET.byi]
   sub ebx, 8
   setxyv
   mov eax, [esi+offset BULLET.bangle]
   movzx ecx, word ptr [esi+offset BULLET.bkto]
   cmp ecx, W_ROCKET
   jnz short neshl
      push eax
      push edi
      mov ebx, eax
      imul eax, size textura
      lea esi, [eax+offset tex_bur]
      push ecx
      call TIME
      pop ecx
      sub eax, [esi+offset BULLET.time_ani]
      shr eax, 7
      and eax, 1
      imul eax, 4*(size textura)
      add esi, eax
      sub edi, off_tabl[ebx*4]
      call draw_blend_lerp
      pop edi
      pop eax
   neshl:
   test ecx, W_FIRE
   jz short nef
      mov ecx, 5
      shl eax, 2
      mov ebx, eax
      push ecx
      call TIME
      pop ecx
      sub eax, [esi+offset BULLET.time_ani]
      shr eax, 6
      and eax, 3
      add eax, ebx
   nef:
   imul eax, size textura
   add eax, tex_tabl[ecx*4]
   mov esi, eax
   call draw_fast_s
   pop edi
   pop ecx
   ret
get_xy:
   mov eax, esi
   sub eax, offset pole
   shr eax, 2
   xor dx, dx
   div nWPOLE
   xchg ax, dx
   movzx eax, ax
   movzx ebx, dx
   shl eax, 4
   add eax, 32
   shl ebx, 4
   add ebx, 32
   ret
bullet_pole:
   mov ebx, [edi+offset BULLET.bxi]
   sub ebx, 32
   jbe set
   cmp ebx, WPOLE*16
   jae set
   mov eax, [edi+offset BULLET.byi]
   sub eax, 32
   jbe set
   cmp eax, HPOLE*16
   jae set
   shr eax, 4
   shr ebx, 4
   imul eax, WPOLE
   add eax, ebx
   lea esi, [offset pole+eax*4]
   call neset
   neset:
      cmp byte ptr [esi], T_BETON
      jne short neb
         movzx eax, word ptr [edi+offset BULLET.bkto]
         and eax, 3
         mov al, bet_tabl[eax]
         mov byte ptr [esi], al
         mov word ptr [edi+offset BULLET.est], 0
         cmp word ptr [edi+offset BULLET.bkto], W_ROCKET
         je short neb
         mov dl, P_MDUST
         call particle
      neb:
      cmp byte ptr [esi], T_HALF_BRICK
      jne short neh
         mov byte ptr [esi], T_PUSTO
         mov word ptr [edi+offset BULLET.est], 0
         push ecx
         mov ecx, 4
         call get_xy
         mov dl, P_KIRP
         call part
         pop ecx
      neh:
      cmp byte ptr [esi], T_BASA
      jne short negameover
         push ecx
         call TIME
         pop ecx
         add eax, 3000
         mov time_go, eax
         mov game_over, 1
         call set
      negameover:
      cmp byte ptr [esi], T_BRICK
      jne short nebr
         movzx eax, word ptr [edi+offset BULLET.bkto]
         and eax, 7
         mov al, razr_tabl[eax]
         mov byte ptr [esi], al
         mov word ptr [edi+offset BULLET.est], 0
         push ecx
         mov ecx, 3
         call get_xy
         mov dl, P_KIRP
         call part
         pop ecx
      nebr:
      mov eax, [edi+offset BULLET.bangle]
      cmp cos[eax*4], 16
      jz short yy
         sub esi, WPOLE*4
         ret
      yy:
         sub esi, 4
         ret
set:
   mov word ptr [edi+offset BULLET.est], 0
   mov dl, P_GDUST
particle:
   test word ptr [edi+offset BULLET.bkto], W_FIRE
   jz short nei
      mov dl, P_ISKRA
   nei:
   push ecx
   mov ecx, 4
   mov ebp, [edi+offset BULLET.bangle]
   mov eax, [edi+offset BULLET.bxi]
   mov ebx, [edi+offset BULLET.byi]
   call part
   pop ecx
   ret
collide_bullet:
   mov eax, [esi+offset BULLET.bxi]
   mov ebx, [esi+offset BULLET.byi]
   sub eax, [edi+offset BULLET.bxi]
   cmp eax, 8
   jge short neset1
   cmp eax, -8
   jle short neset1
   sub ebx, [edi+offset BULLET.byi]
   cmp ebx, 8
   jge short neset1
   cmp ebx, -8
   jle short neset1
      mov dl, P_GDUST
      mov ax, [esi+offset BULLET.bkto]
      and ax, W_FIRE
      mov [esi+offset BULLET.est], ax
      mov ax, [edi+offset BULLET.bkto]
      and ax, W_FIRE
      mov [edi+offset BULLET.est], ax
      call particle
      xchg edi, esi
      call particle
      xchg edi, esi
   neset1:
   ret

do_damage proc near
   cmp tank.etap[esi], E_BRON
   je short ziv
   movzx eax, tank.kto[esi]
   movzx eax, add_ft[eax]
   add tank.firetime[esi], eax
   and tank.firetime[esi], 7
   push edx
   push edi
   lea edi, tank.weapon[esi]
   call dec_wea
   pop edi
   pop edx
   sub tank.tek_life[esi], dl
   jg short ziv
do_damage endp

do_damage2 proc near
      mov eax, tank.xi[esi]
      mov ebx, tank.yi[esi]
      mov dl, 1
      call explode
      cmp tank.kto[esi], T_NORMAL
      jne short nen
         mov tank.kto[esi], T_TRUP
         mov tank.tek_life[esi], 1
         stc
         ret
      nen:
      mov tank.etap[esi], E_NET
      stc
      ret
   ziv:
   clc
   ret
do_damage2 endp
   
bullet_tank:
   mov al, tank.etap[esi]
   cmp al, E_EST
   jb end2
      mov eax, tank.xi[esi]
      mov ebx, tank.yi[esi]
      sub eax, [edi+offset BULLET.bxi]
      cmp eax, -36
      jle short end2
      cmp eax, 4
      jge short end2
      sub ebx, [edi+offset BULLET.byi]
      cmp ebx, -36
      jle short end2
      cmp ebx, 4
      jge short end2
         cmp word ptr [edi+offset BULLET.bkto], W_ROCKET
         je short ne_r
            mov dl, P_GDUST
            call particle
         ne_r:
         mov word ptr [edi+offset BULLET.est], 0
         movzx eax, word ptr [edi+offset BULLET.type_tank]
         mov al, grouph[eax]
         movzx ebx, tank.kto[esi]
         mov ah, grouph[ebx]
         cmp al, ah
         je short end2
         movzx eax, word ptr [edi+offset BULLET.bkto]
         and eax, 7
         mov dl, damage[eax]
         call do_damage
         jnc short end2
         movzx ebx, tank.kto[esi]
         mov eax, add_score[ebx*4]
         add score, eax
         add score1, eax
   end2:
ret

bullet_bullet proc near
   push ecx
   mov ecx, MAX_TANK
   xor esi, esi
   st2:
      push ecx
      movzx ecx, tank.weapon.kol[esi]
      push esi
      jecxz short next2
         lea esi, tank.weapon.bullet[esi]
         st3:
            cmp word ptr [esi+offset BULLET.est], 0
            je short next3
            cmp esi, edi
            je short next3
               call collide_bullet
            next3:
            add esi, size BULLET
         loop st3
      next2:
      pop esi
      call bullet_tank
      add esi, size TANK
      pop ecx
   loop st2
   pop ecx
   ret
bullet_bullet endp

update_weapon proc near
   push ecx
   movzx ecx, word ptr [esi+offset WEAPON.kol]
   jecxz short end1
   lea edi, [esi+offset WEAPON.bullet]
   st1:
      cmp word ptr [edi+offset BULLET.est], 0
      je short next1
         mov ax, [edi+offset BULLET.bkto]
         and eax, 7
         fld skor_bul[eax*4]
         fmul frame
         fld st
         mov eax, [edi+offset BULLET.bangle]
         fmul cosf[eax*4]
         fadd dword ptr [edi]
         fist dword ptr [edi+offset BULLET.bxi]
         fstp dword ptr [edi]
         fmul sinf[eax*4]
         fadd dword ptr [edi+offset BULLET.by]
         fist dword ptr [edi+offset BULLET.byi]
         fstp dword ptr [edi+offset BULLET.by]
         call draw_bul
         call bullet_pole
         call bullet_bullet
         cmp word ptr [edi+offset BULLET.est], 0
         jne short next1
            cmp word ptr [edi+offset BULLET.bkto], W_ROCKET
            jne short next1
               mov eax, [edi+offset BULLET.bxi]
               mov ebx, [edi+offset BULLET.byi]
               xor dl, dl
               call explode
      next1:
      add edi, size BULLET
      dec ecx
   jnz short st1
   end1:
   pop ecx
   ret
update_weapon endp

inc_wea proc near
   mov dx, [edi+offset WEAPON.wkto]
   inc dx
   and dx, W_POWER
   jnz short ne0
      mov dx, W_POWER
   ne0:
   and word ptr [edi+offset WEAPON.wkto], 0fffch
   or dx, [edi+offset WEAPON.wkto]
   jmp short setw
inc_wea endp

dec_wea proc near
   mov dx, [edi+offset WEAPON.wkto]
   and dx, W_POWER
   dec dx
   jns short ne3
      xor dx, dx
   ne3:
   and word ptr [edi+offset WEAPON.wkto], 0fffch
   or dx, [edi+offset WEAPON.wkto]
   jmp short setw
dec_wea endp

reset_weapon proc near
setw:
   mov [edi+offset WEAPON.wkto], dx
   mov ax, 1
   shr dx, 2
   adc ax, 0
   mov [edi+offset WEAPON.kol], ax
   ret
reset_weapon endp

shoot proc near
   movzx ecx, word ptr [esi+offset TANK.weapon.kol]
   lea edi, [esi+offset TANK.weapon.bullet]
   st:
      cmp word ptr [edi+offset BULLET.est], 0
      jne short next
         mov word ptr [edi+offset BULLET.est], 1
         mov eax, [esi+offset TANK.angle]
         mov [edi+offset BULLET.bangle], eax
         push dword ptr [esi+offset TANK.x]
         popi ebx
         add ebx, cos[eax*4]
         pshf ebx
         pop dword ptr [edi]
         push dword ptr [esi+offset TANK.y]
         popi ebx
         add ebx, sin[eax*4]
         pshf ebx
         pop dword ptr [edi+offset BULLET.by]
         mov ax, [esi+offset TANK.weapon.wkto]
         and ax, W_FIRE or W_POWER
         test dl, dl
         jnz short ner
            test word ptr [esi+offset TANK.weapon.wkto], W_ROCKET
            jz short ner
               mov ax, W_ROCKET
         ner:
         mov [edi+offset BULLET.bkto], ax
         call TIME
         mov [edi+offset BULLET.time_ani], eax
         movzx ax, byte ptr [esi+offset TANK.kto]
         mov [edi+offset BULLET.type_tank], ax
         jmp short break
      next:
      add edi, size BULLET
   loop st
   break:
   ret
shoot endp
code1 ends
end 