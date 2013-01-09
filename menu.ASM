include windows.inc
include GraphX.inc
public tekm
public WIN
public GAME_OVER
extrn tex_tank
extrn disp:dword
extrn diff:dword
extrn dplayer:byte
extrn episode:byte
extrn QUIT:dword
extrn ismenu:byte
extrn lev_time:dword
extrn bonus:BONUS
extrn debug_val:dword
extrn level:byte
.386
.model flat
data12 segment para public 'data'
   main MENU_ITEM <"Один игрок",0,offset DIFF,300,M_ONE_PL>,<"Два игрока",0,offset DIFF,320,M_TWO_PL>,<"О программе",0,offset ABOUT,340,M_NONE>,<"Выход",0,offset EXIT,360,M_NONE>
   MENU DISP <"ГЛАВНОЕ МЕНЮ",0,offset main,4,offset EXIT,offset main>
   iexit MENU_ITEM <"Да конечно",0,offset EXIT,300,M_EXIT>,<"Нет ещё поиграю",0,offset MENU,320,M_NONE>
   EXIT DISP <"Выйти из игры?",0,offset iexit,2,offset MENU,offset iexit+size MENU_ITEM>
   idiff MENU_ITEM <"Рядовой",0,offset EPI,300,M_DIFF1>,<"Сержант",0,offset EPI,320,M_DIFF2>,<"Лейтенант",0,offset EPI,340,M_DIFF3>,<"Генерал",0,offset EPI,360,M_DIFF4>
   DIFF DISP <"СЛОЖНОСТЬ",0,offset idiff,4,offset MENU,offset idiff>
   iepi MENU_ITEM <"1 эпизод",0,offset EPI,300,M_EPI1>,<"2 эпизод",0,offset EPI,320,M_EPI2>,<"3 эпизод",0,offset EPI,340,M_EPI3>,<"4 эпизод",0,offset EPI,360,M_EPI4>
   EPI DISP <"ЭПИЗОД",0,offset iepi,4,offset DIFF,offset iepi>
   ipause MENU_ITEM <"Продолжить",0,offset PAUSE,300,M_CONT>,<"Выйти в меню",0,offset MENU,320,M_NONE>
   PAUSE DISP <"ПЕРЕРЫВ",0,offset ipause,2,offset PAUSE,offset ipause>
   iwin MENU_ITEM <"Следующий уровень",0,offset WIN,300,M_CONT2>
   WIN DISP <"Уровень пройден",0,offset iwin,1,offset WIN,offset iwin>
   ABOUT DISP <"О ПРОГРАММЕ",0,0,0,offset MENU,0>
   about db "Игра ",34,"Танчики",34," написана специально для конкурса на igdc.ru",0
   igo MENU_ITEM <"Начать заново",0,offset GAME_OVER,300,M_GO>,<"Выйти в меню",0,offset MENU,320,M_NONE>
   GAME_OVER DISP <"ГЕЙМОВЕР",0,offset igo,2,offset GAME_OVER,offset igo>
   tekm dd offset MENU
   time_pause dd 0
   rb db "rb",0
   wb db "wb",0
   dataf db "data.dat",0
   lock db "Закрыто",0
data12 ends

data3 segment para public 'BSS'
   opene dd ?
   file1 dd ?
   buf dd ?
   diff1 dd ?
data3 ends
				
code1 segment dword public 'code'
pause proc near
   mov ismenu, 1
   mov tekm, offset PAUSE
   call TIME
   mov time_pause, eax
   ret
pause endp

read:
   push offset rb
   push offset dataf
   call fopen
   mov file1, eax
   add esp, 8
   test eax, eax
   jz short set0
   push eax
   push 4
   push 1
   push offset buf
   call fread
   xor buf, 67390815h
   sub buf, 12345678h
   push file1
   call fclose
   add esp, 20
   xor eax, eax
   test buf, 0fffffffch
   jnz short set0
   ret
write:
   mov al, level
   add al, episode
   and al, 15
   shr al, 2
   cmp al, byte ptr buf
   jbe short men
      movzx eax, al
      set0:
      push eax
      mov buf, eax
      push offset wb
      push offset dataf
      call fopen
      mov file1, eax
      add buf, 12345678h
      xor buf, 67390815h
      push eax
      push 4
      push 1
      push offset buf
      call fwrite
      push file1
      call fclose
      add esp, 28
      pop buf
   men:
   clc
   ret
ecx0:
   KEYPRESS VK_ESCAPE
   test al, al
   jz short neesc1
      mov tekm, offset MENU
   neesc1:
   mov esi, offset about
   mov ebx, WDISP/2
   mov edx, 300
   mov al, 7
   jmp draw_text
lockepi:
   cmp tekm, offset EPI
   jne short neep
      mov eax, buf
      sub eax, 4
      not eax
      cmp ecx, eax
      ja short neep
      mov esi, offset lock
      ret
   neep:
   mov esi, edi
ret

render_menu proc near
   mov esi, tekm
   mov ebx, WDISP/2
   mov edx, 250
   mov al, center or alpha
   call draw_text
   mov esi, tekm
   mov ecx, [esi+offset DISP.mkol]
   jecxz short ecx0
   mov edi, [esi+offset DISP.item]
   st:
      push ecx
      push edi
      call lockepi
      mov ebx, WDISP/2
      mov edx, [edi+offset MENU_ITEM.posy]
      mov al, alpha
      call draw_text
      pop edi
      add edi, size MENU_ITEM
      pop ecx
   loop st
   mov esi, tekm
   mov edi, [esi+offset DISP.teki]
   mov ecx, 280
   mov ebx, [edi+offset MENU_ITEM.posy]
   sub ebx, 6
   setxyv
   mov esi, offset tex_tank + size textura
   call draw_fast_s
   mov esi, tekm
   KEYPRESS VK_UP
   test al, al
   jz short neup
      mov eax, [esi+offset DISP.item]
      cmp eax, [esi+offset DISP.teki]
      je short neup
      sub dword ptr [esi+offset DISP.teki], size MENU_ITEM
   neup:
   KEYPRESS VK_DOWN
   test al, al
   jz short ned
      mov eax, [esi+offset DISP.mkol]
      dec eax
      imul eax, size MENU_ITEM
      add eax, [esi+offset DISP.item]
      cmp eax, [esi+offset DISP.teki]
      jz short ned
      add dword ptr [esi+offset DISP.teki], size MENU_ITEM
   ned:
   KEYPRESS VK_ESCAPE
   test al, al
   jz short neesc
      mov eax, [esi+offset DISP.esc]
      mov tekm, eax
   neesc:
   KEYPRESS VK_RETURN
   test al, al
   jz neret
      mov edi, [esi+offset DISP.teki]
      mov eax, [edi+offset MENU_ITEM.goto]
      mov tekm, eax
      mov eax, [edi+offset MENU_ITEM.act]
      test eax, M_ONE_PL or M_TWO_PL
      jz short ne12
         shr eax, 1
         mov dplayer, al
         jmp neret
      ne12:
      test eax, M_DIFF1 or M_DIFF2 or M_DIFF3 or M_DIFF4
      jz short nedif
         sub eax, 4
         mov diff, eax
         mov diff1, eax
         call read
         jmp neret
      nedif:
      test eax, M_EPI1 or M_EPI2 or M_EPI3 or M_EPI4
      jz short nediff
         shr eax, 6
         mov episode, al
         mov bl, byte ptr buf
         shl bl, 2
         cmp al, bl
         ja short neret
         newgame:
         mov eax, diff1
         mov diff, eax
         stc
         ret
      nediff:
      test eax, M_GO
      jnz short newgame
      test eax, M_CONT
      jz short nec
         mov ismenu, 0
         call clear
         call TIME
         sub eax, time_pause
         add lev_time, eax
         add bonus.utime, eax
         jmp short neret
      nec:
      test eax, M_CONT2
      jz short nec2
         mov ismenu, 0
         call clear
         jmp write
      nec2:
      test eax, M_EXIT
      jz short neret
         mov QUIT, 1
   neret:
   clc
   ret
render_menu endp
code1 ends
end 