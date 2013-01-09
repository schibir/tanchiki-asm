FULLSCREEN equ 1
global create_graphx:near
global clear:near
global render:near
global load_bmp:near
global rotate_tex:near
global get_kadr:near
global draw_fast:near
global draw_fast_t:near
global draw_fast_s:near
global draw_fast_ts:near
global draw_text:near
global draw_blend_lerp:near
global draw_blend_add:near
global draw_blend_mul:near
global draw_tex_to_mask:near
global _printint:near
printint macro kuda, num
   mov edi, offset kuda
   mov eax, num
   call _printint
endm
global calc_fps:near
global rand:near
global random:near
rnd macro num
   mov bx, num
   call random
endm

global GetKeyPress:near
KEYPRESS macro key
   mov edx, key
   call GetKeyPress
endm

rndf macro
   call rand
   push eax
   push 07fffh
   fild dword ptr [esp+4]
   fild dword ptr [esp]
   fdiv 
   add esp, 4
   pop eax
endm

global _load_bmp:near
global update:near
global load:near
global load_pole:near
global draw_pole:near
global load_level:near

T_PUSTO        equ 0
T_LES          equ 1
T_HALF_BRICK   equ 2
T_BRICK        equ 4
T_BETON        equ 8
T_WATER        equ 16
T_BASA         equ 32
WDISP equ 640
HDISP equ 480
TIME equ timeGetTime
WPOLE equ 30
HPOLE equ 26
center equ 1
small equ 2
alpha equ 4

KEYDOWN macro key
   push key
   call GetAsyncKeyState
endm

setxyc macro x, y
   mov edi, offset disp+(WDISP*(HDISP-(y)-1)+(x))*4
endm

global _setxyv:near
setxyv macro
   call _setxyv
endm

textura struc
   width dd ?
   height dd ?
   pix dd ?
   file dd ?
textura ends

sprite struc
   left dd ?
   top dd ?
   right dd ?
   bottom dd ?
   tx dd ?
   ty dd ?
sprite ends

global load_weapon:near
global update_weapon:near
global reset_weapon:near
global shoot:near
global bullet_bullet:near
global do_damage:near
global do_damage2:near
global inc_wea:near
global dec_wea:near

W_NORMAL    equ 0
W_SINGLE    equ 1
W_DOUBLE    equ 2
W_POWER     equ 3
W_ROCKET    equ 4
W_FIRE      equ 8

BULLET struc
   bx dd ? 
   by dd ?
   bskor dd ?
   bangle dd ?
   bkto dw ?
   est dw ?
   time_ani dd ?
   type_tank dw ?
   bxi dd ?
   byi dd ?
BULLET ends

WEAPON struc
   wkto dw ?
   kol dw ?
   bullet BULLET 2 dup(?)
WEAPON ends

global load_tank:near
global update_tank:near
global load_resp:near
global reset_tank:near

load_all_kadr macro file, tex, pix, k
   mov esi, offset file
   mov edi, offset tex
   mov ebp, offset pix
   mov cx, k
   call load_resp
endm

T_PLAYER1      equ 0
T_PLAYER2      equ 1
T_NORMAL       equ 2
T_SKOROSTREL   equ 3
T_ACTIV        equ 4
T_PANZER       equ 5
T_ROCKET       equ 6
T_TRUP         equ 7
KOL_TANK       equ 8
RANDOM_TANK    equ 9
A_UP     equ 0
A_RIGHT  equ 1
A_DOWN   equ 2
A_LEFT   equ 3
K_UP     equ 1
K_LEFT   equ 2
K_DOWN   equ 4
K_RIGHT  equ 8
MAX_TANK equ 32
E_NET equ 0
E_RESP equ 1
E_EST equ 2
E_BRON equ 3

TANK struc
   etap db ?
   kto db ?
   key db ? 
   tek_life db ?   
   tik dd ?
   time_nap dd ?
   time_shoot dd ?
   time_fire dd ?
   x dd ?
   y dd ?
   skor dd ?
   angle dd ?
   weapon WEAPON ?
   xi dd ?
   yi dd ?
   firetime dd ?
TANK ends

global respown_tank:near

pshf macro num
   push num
   fild dword ptr [esp]
   fstp dword ptr [esp]
endm

pshf100 macro num
   push num
   push 100
   fild dword ptr [esp+4]
   fild dword ptr [esp]
   fdivp
   fstp dword ptr [esp+4]
   add esp, 4
endm

razbros macro r
   rndf
   push 3f000000h
   fsub dword ptr [esp]
   add esp, 4
   pshf100 r
   fmul dword ptr [esp]
   add esp, 4
endm

popi macro reg
   fld dword ptr [esp]
   fistp dword ptr [esp]
   pop reg
endm

global load_particle:near
global update_exp:near
global explode:near
global part:near
global update_part:near

P_SMOKE  equ 0
P_FIRE   equ 1
P_KIRP   equ 2
P_DYM    equ 3
P_ISKRA  equ 4
P_GDUST  equ 5
P_MDUST  equ 6

EXPLODE struc
   ex dd ?
   ey dd ?
   life dd ?
   eangle dd ?
   eest db ?
   is_tank db ?
EXPLODE ends

PARTICLE struc
   pnext dd ?
   pprev dd ?
   px dd ?
   py dd ?
   vx dd ?
   vy dd ?
   pkto db ?
   pest db ?
   depth db ?
   reserve db ?
   plife dd ?
   pangle dd ?
   pkadr dd ?
   kadr_time dd ?
PARTICLE ends

BONUS struc
   ukto db ?
   uest db ?
   utime dd ?
   ux dd ?
   uy dd ?
BONUS ends

global reset_bonus:near
global load_bonus:near
global update_bonus:near
global openpack:near
global unpack:near
global closepack:near

MENU_ITEM struc
   nadp db 19 dup(?)
   zero db ?
   goto dd ?
   posy dd ?
   act dd ?
MENU_ITEM ends

DISP struc
   mnadp db 15 dup(?)
   mzero db ?
   item dd ?
   mkol dd ?
   esc dd ?
   teki dd ?
DISP ends

M_NONE=0
M_ONE_PL=1
M_TWO_PL=2
M_EXIT=4096
M_DIFF1=4
M_DIFF2=8
M_DIFF3=12
M_DIFF4=16
M_EPI1=32
M_EPI2=256
M_EPI3=512
M_EPI4=768
M_CONT=1024
M_CONT2=2048
M_GO=4096*2

global render_menu:near
global pause:near