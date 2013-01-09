include windows.inc
include GraphX.inc
public debug_val
public diff
public dplayer
public episode
public isresp
public score
public score1
public ismenu
public lev_time
public level
public lifetank
public game_over
public time_go
extrn QUIT:dword
extrn disp:dword
extrn kadr:dword
extrn seed:dword
extrn frame:dword
extrn tank:TANK
extrn tek_tank:dword
extrn tekm:dword
extrn WIN:DISP
extrn GAME_OVER:DISP
extrn tex_tank:textura
.386
.model flat
data5 segment para public 'data'
   fps_text db "FPS = ",0,16 dup(?)
   time_text db "Время",0 
   tex_pack db "textura.pkx",0
   score_text db "Очки",0
   zvanie_text db "   Рядовой   ",0,"   Черпак    ",0,"  Ефрейтор   ",0," Мл. сержант ",0,"   Сержант   ",0," Ст. сержант ",0,"  Старшина   ",0,"Мл. лейтенант",0,"  Лейтенант  ",0,"   Капитан   ",0,"    Майор    ",0,"  Полковник  ",0,"   Генерал   ",0,"   ТАНКИСТ   ",0,"  КАРАТЕЛЬ   ",0,"  ТРИЛЛИПУТ  ",0
   pl_proc dd offset new_level1,offset new_level2
   d1000 dd 1000
   time_nadp dd 0
   time_int dd 0
   name_fonm db "fon.bmp",0
   tex_fonm textura <?,?,offset pix_fonm,offset name_fonm>
   spr_time sprite <560,90,0,98,0,0>
   name_ind db "indicator.bmp",0
   tex_ind textura <?,?,offset pix_ind,offset name_ind>
   tex_black textura <64,8,offset pix_black,0>
   tex_black1 textura <32,8*32,offset pix_black1,0>
   n3125 dd 3125
   ismenu db 1
   time_render dd 0
data5 ends

data3 segment para public 'BSS'
   debug_val dd ?
   pix_fonm dd WDISP*HDISP dup(?)
   pix_ind dd 64*8 dup(?)
   pix_black dd 64*8 dup(?)
   pix_black1 dd 32*8*32 dup(?)
   buffer db 16 dup(?)
   debug_str db 16 dup(?)
   diff dd ?
   level db ?
   dplayer db ?
   isresp db ?
   lev_time dd ?
   konec db ?
   episode db ?
   score dd ?
   score1 dd ?
   lifetank db ?
   game_over db ?
   time_go dd ?
data3 ends
				
code1 segment dword public 'code'
new_level2:
   push tank[size TANK].skor
   movzx eax, tank[size TANK].tek_life
   push eax
   movzx eax, tank[size TANK].weapon.wkto
   push eax
   movzx eax, tank[size TANK].weapon.kol
   push eax 
   movzx eax, tank[size TANK].etap
   push eax 
   call new_level1
   pop eax
   cmp al, E_NET 
   jne short nett
      mov tank[size TANK].etap, al
   nett:
   pop eax
   mov tank[size TANK].weapon.kol, ax
   pop eax
   mov tank[size TANK].weapon.wkto, ax
   pop eax
   mov tank[size TANK].tek_life, al
   pop tank[size TANK].skor
   ret
new_level1:
   push tank[0].skor
   movzx eax, tank[0].tek_life
   push eax
   movzx eax, tank[0].weapon.wkto
   push eax
   movzx eax, tank[0].weapon.kol
   push eax
   movzx eax, tank[0].etap
   push eax
   call new_level
   pop eax
   cmp al, E_NET 
   jne short nett1
      mov tank[0].etap, al
   nett1:
   pop eax
   mov tank[0].weapon.kol, ax
   pop eax
   mov tank[0].weapon.wkto, ax
   pop eax
   mov tank[0].tek_life, al
   pop tank[0].skor
   ret
new_level:
   mov dl, level
   add dl, episode
   and dl, 15
   call load_level
   call reset_tank
   call reset_bonus
   mov edi, offset tank
   mov dl, T_PLAYER1
   call respown_tank
   cmp dplayer, 1
   jne short nep2
      mov edi, offset tank+size TANK
      mov dl, T_PLAYER2
      call respown_tank
   nep2:
   call TIME
   add eax, 101000
   mov lev_time, eax
   mov isresp, 1
   mov konec, 0
ret

load proc near
   call TIME
   mov seed, eax
   mov esi, offset tex_pack
   call openpack
   call create_graphx
   call load_pole
   call load_tank
   call load_particle
   call load_bonus
   call load_weapon
   mov edi, offset tex_fonm
   call _load_bmp
   mov edi, offset tex_ind
   call _load_bmp
   call closepack
   mov edi, offset pix_black
   mov ecx, 64*8
   xor eax, eax
   rep stosd
   mov edi, offset pix_black1
   mov ecx, 32*8*32
   rep stosd
   finit
   ret
load endp

draw_interface:
   mov edi, offset fps_text+6
   mov eax, kadr
   call _printint
   mov esi, offset fps_text
   mov ebx, 64+WPOLE*16+10
   mov edx, 10
   mov al, small
   call draw_text
   mov edi, offset buffer
   mov eax, score
   call _printint
   mov esi, offset buffer
   mov ebx, 64+WPOLE*16+20
   mov edx, 130
   mov al, 0
   call draw_text
   mov esi, offset score_text
   mov ebx, 64+WPOLE*16+10
   mov edx, 110
   mov al, 0
   call draw_text
   imul eax, diff, 14
   lea esi, zvanie_text[eax]
   mov ebx, 64+WPOLE*16+5
   mov edx, HDISP-42
   mov al, small
   call draw_text
   mov esi, offset tex_black
   setxyc 561, 90
   call draw_fast
   mov esi, offset tex_black1
   setxyc 580, 190-32
   call draw_fast
   movzx ecx, lifetank
   jecxz short netlife
      cmp ecx, 8
      jb short ecx8
         mov ecx, 8
      ecx8:
      setxyc 580, 190-32
      drawlife:
         mov esi, offset tex_tank
         call draw_fast
         sub edi, 32*WDISP*4
      loop drawlife      
   netlife:
   call TIME
   sub eax, lev_time
   jae short endtime
      neg eax
      xor edx, edx
      shl eax, 1
      div n3125
      add eax, 561
      mov spr_time.right, eax
      mov esi, offset tex_ind
      mov edi, offset spr_time
      call draw_fast_t
      mov esi, offset time_text
      mov ebx, 64+WPOLE*16+10
      mov edx, 60
      mov al, 0
      jmp draw_text
   endtime:
      cmp tek_tank, 0
      jne short ne0
         cmp konec, 1
         jne short nec
            inc level
            movzx eax, dplayer
            mov ebx, offset WIN
            mov tekm, ebx
            mov ismenu, 1
            jmp pl_proc[eax*4]
         nec:
         call TIME
         add eax, 5000
         mov lev_time, eax
         mov konec, 1
      ne0:
      mov isresp, 0  
   ret
draw_menu:
   mov esi, offset tex_fonm
   setxyc 0, 0
   call draw_fast
   call render_menu
   jnc short endif2
      xor eax, eax
      mov ismenu, al
      mov score, eax
      mov score1, eax
      mov level, al
      mov game_over, al
      mov lifetank, 2
      mov cl, dplayer
      shl lifetank, cl
      call clear
      call new_level
   endif2:
ret

update proc near
   call calc_fps
   cmp ismenu, 1
   je menu
      mov dl, T_WATER
      call draw_pole
      mov dl, T_BRICK or T_HALF_BRICK or T_BETON
      call draw_pole
      call update_tank
      call update_exp
      call update_part
      mov dl, T_LES
      call draw_pole
      call update_bonus
      call TIME
      cmp eax, time_int
      jb short neint
         add eax, 1000
         mov time_int, eax
         call draw_interface
      neint:
      mov eax, score1
      cmp eax, 128
      jb short ne1
         inc diff
         cmp diff, 16
         jne short ne16
            mov diff, 15
         ne16:
         and score1, 127
         call TIME
         add eax, 5000
         mov time_nadp, eax
      ne1:
      call TIME
      cmp eax, time_nadp
      ja short nenadp
         imul eax, diff, 14
         lea esi, zvanie_text[eax]
         mov ebx, tank.xi
         sub ebx, 25
         mov edx, tank.yi
         sub edx, 8
         mov al, 6
         call draw_text
      nenadp:
      KEYPRESS VK_ESCAPE
      test al, al
      jnz pause
      cmp game_over, 0
      je short nemenu
         call TIME
         cmp eax, time_go
         jb short nemenu
         mov ismenu, 1
         mov tekm, offset GAME_OVER
   menu:
      call draw_menu
   nemenu:
   jmp render
update endp
code1 ends
end 