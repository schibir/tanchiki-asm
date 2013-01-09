include windows.inc
include GraphX.inc
extrn disp:dword
extrn frame:dword
extrn kadr:dword
extrn debug_val:dword
extrn tank:TANK
extrn pix_lev:dword
pole equ pix_lev
MAX_EXP equ 10
MAX_PART equ 32
.386
.model flat
data9 segment para public 'data'
   name_exp db "Expl00  .bmp",0
   exp EXPLODE MAX_EXP dup(<0,0,0,0,0,0>)
   name_exp2 db "explosions.bmp",0
   name_kir db "кирпичи.bmp",0
   tex_kir textura <?,?,offset pix_kir,offset name_kir>
   exp_tabl dd 32,16
   life_rnd dw 0,1,300,1,300,300,300
   life_add dd 0,512,200,512,200,200,200
   pos_rnd dw 0,14,16,12,1,1,1
   sub_rnd dd 0,7,8,7,0,0,0
   sinf dd 0.07, 0.0, -0.07,  0.0
   cosf dd  0.0, -0.07, 0.0, 0.07
   skorx dd -0.06
   skory dd -0.04
   kol_kadr dd 41800000h,0,63,40800000h,40800000h,15,15
   shl_tabl db 4,0,0,2,2
   tex_tabl dd offset tex_kir,0,0,offset tex_gdust,offset tex_mdust
   head dd 0
   end_part=MAX_PART*(size PARTICLE)
   name_gdust db "GDust.bmp",0
   name_mdust db "MDust.bmp",0
   tex_gdust textura <?,?,offset pix_gdust,offset name_gdust>
   tex_mdust textura <?,?,offset pix_mdust,offset name_mdust>
   name_iskra db "искра.bmp",0
   tex_iskra textura <?,?,offset pix_iskra,offset name_iskra>
data9 ends

data3 segment para public 'BSS'
   particle PARTICLE MAX_PART dup(?)
   tex_exp textura 29*4 dup(?)
   pix_exp dd 64*64*29*4 dup(?)
   tex_exp2 textura 8*4 dup(?)
   pix_exp2 dd 64*64*8*4 dup(?)
   pix_kir dd 128*128 dup(?)
   pix_gdust dd 32*8 dup(?)
   pix_mdust dd 32*8 dup(?)
   pix_iskra dd 64*16 dup(?)
   spr_kir sprite <?>
data3 ends
				
code1 segment dword public 'code'
load_exp:
   push ecx
   push edi
   mov dword ptr [edi+offset textura.file], offset name_exp
   mov dword ptr [edi+offset textura.pix], ebp
   call _load_bmp
   pop esi
   mov ecx, 3
   st:
      push esi
      lea edi, [esi+size textura]
      mov eax, [esi+offset textura.pix]
      add eax, 64*64*4
      mov [edi+offset textura.pix], eax
      call rotate_tex
      pop edi
      lea esi, [edi+size textura]
   loop st
   pop ecx
   ret
load_exp2:
   mov esi, offset tex_exp2
   mov edi, offset tex_exp2+(size textura)*8
   mov ecx, 8*3
   ld1:
      mov eax, [esi+offset textura.pix]
      add eax, 64*64*8*4
      mov [edi+offset textura.pix], eax
      call rotate_tex
      add esi, size textura
      add edi, size textura
   loop ld1
ret

load_particle proc near
   xor ecx, ecx
   mov edi, offset tex_exp
   mov ebp, offset pix_exp
   st1:
      mov ax, cx
      aam
      or ax, 3030h
      xchg al, ah
      mov word ptr name_exp[6], ax
      push edi
      call load_exp
      add ebp, 64*64*4*4
      pop edi
      add edi, 4*(size textura)
      inc ecx
      cmp ecx, 29
   jb short st1
   load_all_kadr name_exp2, tex_exp2, pix_exp2, 208h
   call load_exp2
   mov edi, offset tex_kir
   call _load_bmp
   mov edi, offset tex_gdust
   call _load_bmp
   mov edi, offset tex_mdust
   call _load_bmp
   mov edi, offset tex_iskra
   jmp _load_bmp
load_particle endp

uron:
   push edi
   xor edi, edi
   mov ecx, MAX_TANK
   add eax, 16
   add ebx, 16
   allt: 
      push eax
      push ebx
      cmp tank.etap[edi], E_EST
      jne short nextt
         sub eax, tank.xi[edi]
         sub ebx, tank.yi[edi]
         imul eax, eax
         imul ebx, ebx
         add eax, ebx 
         cmp eax, 40*40
         ja short nextt
            mov dl, 2
            xchg esi, edi
            call do_damage
            xchg esi, edi
      nextt:
      add edi, size TANK
      pop ebx
      pop eax
   loop allt
   pop edi
ret

explode proc near
   push edi
   push ecx
   mov ecx, MAX_EXP
   xor edi, edi
   st2:
      cmp exp.eest[edi], 0
      jne short next
         mov exp.eest[edi], 1
         movzx edx, dl
         sub eax, exp_tabl[edx*4]
         sub ebx, exp_tabl[edx*4]
         mov exp.ex[edi], eax
         mov exp.ey[edi], ebx
         mov exp.is_tank[edi], dl
         test dl, dl
         jnz short ner
            call uron
         ner:
         call TIME
         mov exp.life[edi], eax
         rnd 4
         movzx edx, dx
         mov exp.eangle[edi], edx
         jmp short break
      next:
      add edi, size EXPLODE
   loop st2
   break:
   pop ecx
   pop edi
   ret
explode endp

draw_exp:
   push edi
   cmp exp.is_tank[edi], 1
   jnz short netank1
      shl eax, 2
      add eax, exp.eangle[edi]
      mov ebp, offset tex_exp
      jmp short nerock1
   netank1:
      mov ebx, exp.eangle[edi]
      lea eax, [ebx*8+eax]
      mov ebp, offset tex_exp2
   nerock1:
   push eax
   mov ecx, exp.ex[edi]
   mov ebx, exp.ey[edi]
   setxyv
   pop eax
   imul eax, size textura
   lea esi, [eax+ebp]
   call draw_blend_lerp
   pop edi
ret

update_exp proc near
   mov ecx, MAX_EXP
   xor edi, edi
   st3:
      push ecx
      cmp exp.eest[edi], 0
      je short next1
         call TIME
         sub eax, exp.life[edi]
         cmp exp.is_tank[edi], 1
         jnz short netank
            imul eax, 0aaah
            shr eax, 16
            cmp eax, 28
            jmp short nerock
         netank:
            shr eax, 6
            cmp eax, 7
         nerock:
         jbe short kon
            mov exp.eest[edi], 0
            jmp short next1
         kon:
         call draw_exp
      next1:
      pop ecx
      add edi, size EXPLODE
   loop st3
   ret
update_exp endp

kill_part:
   push esi
   mov particle.pest[edi], 0
   cmp particle.pprev[edi], 0
   je short net1
      mov esi, particle.pprev[edi]
      push particle.pnext[edi]
      pop particle.pnext[esi]
   net1:
   cmp particle.pnext[edi], 0
   je short net2
      mov esi, particle.pnext[edi]
      push particle.pprev[edi]
      pop particle.pprev[esi]
      jmp short net3
   net2:
      push particle.pprev[edi]
      pop head
   net3:
   pop esi
   ret
gen_vel:
   cmp particle.pkto[edi], P_FIRE
   jne short nefire
      rnd 4
      movzx edx, dx
      mov particle.pangle[edi], edx
      fld skorx
      fstp particle.vx[edi]
      fld skory
      fstp particle.vy[edi]
      ret
   nefire:
   razbros 12
   fstp particle.vx[edi]
   razbros 12
   fstp particle.vy[edi]
   cmp particle.pkto[edi], P_KIRP
   jne short nekir
      rnd 48
      movzx edx, dx
      mov particle.pkadr[edi], edx
      ret
   nekir:
   mov dword ptr particle.pkadr[edi], 0
   rndf
   fmul cosf[ebp*4]
   fadd particle.vx[edi]
   fstp particle.vx[edi]
   rndf
   fmul sinf[ebp*4]
   fadd particle.vy[edi]
   fstp particle.vy[edi]
ret

part proc near
      pusha
      mov esi, head
      lea edi, [esi+size PARTICLE]
      cmp edi, end_part
      jne short nee
         mov edi, size PARTICLE
      nee:
      cmp particle.pest[edi], 1
      jne short return
         call kill_part
      return:
      mov particle.pest[edi], 1
      mov particle.pkto[edi], dl
      mov particle.pprev[edi], esi
      mov particle.pnext[edi], 0
      mov particle.pnext[esi], edi
      mov head, edi
      movzx esi, dl
      cmp dl, P_ISKRA
      jne short nei
         sub eax, 8
         sub ebx, 8
      nei:
      push ebx
      rnd pos_rnd[esi+esi]
      movzx edx, dx
      sub edx, sub_rnd[esi*4]
      add eax, edx
      mov particle.px[edi], eax
      fild particle.px[edi]
      fstp particle.px[edi]
      rnd pos_rnd[esi+esi]
      movzx edx, dx
      sub edx, sub_rnd[esi*4]
      pop ebx
      add ebx, edx
      mov particle.py[edi], ebx
      fild particle.py[edi]
      fstp particle.py[edi]
      rnd life_rnd[esi+esi]
      movzx ebx, dx
      add ebx, life_add[esi*4]
      mov eax, ebx
      shr eax, 2
      mov particle.kadr_time[edi], eax
      call TIME
      add eax, ebx
      mov particle.plife[edi], eax
      call gen_vel
      popa
      dec ecx
   jnz part
   ret
part endp

draw_fire:
   push edi
   dec eax
   js short nefire2
   shr eax, 7
   and eax, 3
   sub eax, 3
   neg eax
   mov ebx, particle.pangle[edi]
   lea eax, [ebx*8+eax+4]
   imul eax, size textura
   lea esi, [eax+offset tex_exp2]
   push particle.px[edi]
   popi ecx
   push particle.py[edi]
   popi ebx
   setxyv
   call draw_blend_lerp
   nefire2:
   pop edi
   ret
draw_iskra:
   push edi
   mov spr_kir.ty, 0
   xor edx, edx
   div particle.kadr_time[edi]
   sub eax, 3
   neg eax
   and eax, 3
   shl eax, 4
   mov spr_kir.tx, eax
   mov esi, offset tex_iskra
   mov ebp, P_KIRP
   jmp short draw_sprite
draw_kirp:
   push edi
   movzx ebp, particle.pkto[edi]
   shr eax, 5
   add eax, particle.pkadr[edi]
   and eax, kol_kadr[ebp*4]
   mov ebx, eax
   mov cl, shl_tabl[ebp-2]
   and ebx, 7
   shl ebx, cl
   mov spr_kir.tx, ebx
   shr eax, 3
   shl eax, cl
   mov esi, tex_tabl[ebp*4-8]
   mov spr_kir.ty, eax
draw_sprite:
   fld particle.px[edi]
   fist spr_kir.left
   fadd kol_kadr[ebp*4-8]
   fistp spr_kir.right
   fld particle.py[edi]
   fist spr_kir.top
   fadd kol_kadr[ebp*4-8]
   fistp spr_kir.bottom
   mov edi, offset spr_kir
   call draw_fast_ts
   pop edi
ret

update_part proc near
   mov edi, head
   lp:
      test edi, edi
      jz short endlp
      call TIME
      sub eax, particle.plife[edi]
      jle short ziv
         call kill_part
         jmp short next2
      ziv:
      neg eax
      fld particle.vx[edi]
      fmul frame
      fadd particle.px[edi]
      fstp particle.px[edi]
      fld particle.vy[edi]
      fmul frame
      fadd particle.py[edi]
      fstp particle.py[edi]
      cmp particle.pkto[edi], P_ISKRA
      jne short neiskra
         call draw_iskra
         jmp short next2
      neiskra:
      cmp particle.pkto[edi], P_FIRE
      jne short nefire1
         call draw_fire
         jmp short next2
      nefire1:
         call draw_kirp
      next2:
      mov edi, particle.pprev[edi]
   jmp short lp
   endlp:
   ret
update_part endp
code1 ends
end 