include windows.inc
include GraphX.inc
.386
.model flat

PACK_HEAD struc 
   type db 4 dup(?)
   kol_file dd ?
PACK_HEAD ends

PACK_FILE struc 
   filename db 16 dup(?)
   offset dd 2 dup(?)
   size dd ?
PACK_FILE ends

MAX_FILE equ 64
MAX_SIZE equ 100000h 

data11 segment para public 'data'
   rb db "rb",0
   wb db "wb",0
data11 ends

data3 segment para public 'BSS'
   head PACK_HEAD ?
   File PACK_FILE ?
   ddt dd ?
   data db MAX_SIZE dup(?)
   pack dd ?   ;FILE*
   temp dd ?   ;FILE*
data3 ends
				
code1 segment dword public 'code'
openpack proc near
   push offset rb
   push esi
   call fopen
   mov pack, eax
   push pack
   push size PACK_HEAD
   push 1
   push offset head
   call fread
   add esp, 18h
   ret
openpack endp

unpack proc near
   push ecx
   push SEEK_SET
   push size PACK_HEAD
   push pack
   call fseek
   add esp, 0ch
   mov ecx, head.kol_file
   st:
      push ecx
      push pack
      push size PACK_FILE+4
      push 1
      push offset File
      call fread
      push edi
      push offset File.filename
      call strcmp
      add esp, 18h
      test eax, eax
      jnz short ne0
         push pack
         push File.size
         push 1
         push offset data
         call fread
         push offset wb
         push edi
         call fopen
         mov temp, eax
         push temp
         push 1
         push File.size
         push offset data
         call fwrite
         push temp
         call fclose
         add esp, 30h
         pop ecx
         ret
      ne0:
      push SEEK_CUR
      push File.size
      push pack
      call fseek
      add esp, 0ch
      pop ecx
      dec ecx
   jnz st
   pop ecx
   ret
unpack endp

closepack proc near
   push pack
   call fclose
   add esp, 4
   ret
closepack endp
code1 ends
end 