include windows.inc
include GraphX.inc
public bonus
extrn disp:dword
extrn debug_val:dword
extrn tank:TANK
extrn diff:dword
extrn usl:dword
extrn isresp:byte
extrn lifetank:byte
.386
.model flat
B_STAR   equ 0
B_BRON   equ 1
B_SPEED  equ 2
B_FIRE   equ 3
B_LIFE   equ 4
B_BOMB   equ 5
data10 segment para public 'data'
   name_bfire db "fire_bonus.bmp",0
   name_life db "Zizn.bmp",0
   tex_life textura <?,?,offset pix_life,offset name_life>
   name_bom db "bom.bmp",0
   tex_bom textura <?,?,offset pix_bom,offset name_bom>
   name_shield db "PUShield.bmp",0
   name_speed db "PUSpeed.bmp",0
   name_star db "PUInvuln.bmp",0
   tex_bon dd offset tex_star,offset tex_shield,offset tex_speed,offset tex_bfire,offset tex_life,offset tex_bom
   proc_bon dd offset draw_sss,offset draw_sss,offset draw_sss,offset draw_ani,offset draw_lb,offset draw_lb
   proc_set dd b_star, b_bron, b_speed,b_fire, b_life, b_bomb
   time_per dw 15000,13000,12000,11000,10000,8000,7000,6000,5000,3000,2000,1000,1,1,1,1
   n48 dd 48
data10 ends

data3 segment para public 'BSS'
   bonus BONUS <?>
   tex_bfire textura 48 dup(?)
   pix_bfire dd 512*96 dup(?)
   pix_life dd 32*32 dup(?)
   pix_bom dd 32*32 dup(?)
   tex_shield textura 8 dup(?)
   pix_shield dd 128*64 dup(?)
   tex_speed textura 8 dup(?)
   pix_speed dd 128*64 dup(?)
   tex_star textura 8 dup(?)
   pix_star dd 128*64 dup(?)
data3 ends
				
code1 segment dword public 'code'
reset_bonus proc near
   mov edi, offset bonus
   xor al, al
   mov ecx, size BONUS
   rep movsb
   jmp netb1
reset_bonus endp

load_bonus proc near
   call reset_bonus
   mov edi, offset tex_life
   call _load_bmp
   load_all_kadr name_bfire, tex_bfire, pix_bfire, 1030h
   load_all_kadr name_shield, tex_shield, pix_shield, 408h
   load_all_kadr name_speed, tex_speed, pix_speed, 408h
   load_all_kadr name_star, tex_star, pix_star, 408h
   mov edi, offset tex_bom
   jmp _load_bmp
load_bonus endp

draw_ani:
   call TIME
   sub eax, bonus.time_ani
   shr eax, 4
   xor edx, edx
   div n48
   imul edx, size textura
   lea esi, [edx+ebp]
draw_kadr:
   mov ecx, bonus.ux
   mov ebx, bonus.uy
   setxyv
   jmp draw_fast_s
draw_sss:
   call TIME
   sub eax, bonus.time_ani
   shr eax, 6
   and eax, 7
   imul eax, size textura
   lea esi, [eax+ebp]
   jmp short draw_kadr
draw_lb:
   mov esi, ebp
   jmp short draw_kadr
create_bonus:
   rnd 6
   mov bonus.ukto, dl
   mov al, isresp
   mov bonus.uest, al
   rnd (WPOLE-1)*16
   add edx, 32
   and edx, 0fff0h
   mov bonus.ux, edx
   rnd (HPOLE-1)*16
   add edx, 32
   and edx, 0fff0h
   mov bonus.uy, edx
   call TIME
   add eax, 10000
   mov bonus.utime, eax
   ret
set_bonus: 
   movzx eax, bonus.ukto
   jmp proc_set[eax*4]
b_star:
   lea edi, tank.weapon[esi]
   call inc_wea
   inc tank.tek_life[esi]
   mov tank.firetime[esi], 0
   jmp netb1
b_bron:
   mov tank.etap[esi], E_BRON
   call TIME
   add eax, 15000
   mov tank.tik[esi], eax
   jmp netb1
b_speed:
   pshf100 160
   pop tank.skor[esi]
   jmp netb1
b_fire:
   or tank.weapon.wkto[esi], W_FIRE
   jmp netb1
b_life:
   cmp tank.kto[esi], T_PLAYER2
   ja netb1
   inc lifetank
   jmp netb1
b_bomb:
   cmp tank.kto[esi], T_PLAYER2
   ja netb1
   xor esi, esi
   mov ecx, MAX_TANK
   st1:
      cmp tank.etap[esi], E_EST
      jb short next1
      cmp tank.kto[esi], T_PLAYER2
      jbe short next1
      cmp tank.kto[esi], T_TRUP
      je short next1
         call do_damage2
      next1:
      add esi, size TANK
   loop st1
   jmp netb1
collide_bonus:
   mov ecx, MAX_TANK
   xor esi, esi
   mov eax, bonus.ux
   mov ebx, bonus.uy
   st2:
      push eax
      push ebx
      cmp tank.etap[esi], E_EST
      jb short next
         sub eax, tank.xi[esi]
         cmp eax, 32
         jge short next
         cmp eax, -32
         jle short next
         sub ebx, tank.yi[esi]
         cmp ebx, 32
         jge short next
         cmp ebx, -32
         jle short next
         call set_bonus
         mov ecx, 1
      next:
      pop ebx
      pop eax
      add esi, size TANK
   loop st2
ret

update_bonus proc near
   cmp bonus.uest, 0
   jz short netb
      call TIME
      cmp eax, bonus.utime
      ja short netb1
      movzx eax, bonus.ukto
      mov ebp, tex_bon[eax*4]
      call proc_bon[eax*4]
      jmp collide_bonus
   netb:
      call TIME
      cmp eax, bonus.utime
      ja create_bonus
      ret
   netb1:
      mov bonus.uest, 0
      call TIME
      mov ebx, diff
      rnd time_per[ebx*2]
      movzx edx, dx
      lea eax, [eax+edx+15000]
      mov bonus.utime, eax
   ret
update_bonus endp
code1 ends
end 