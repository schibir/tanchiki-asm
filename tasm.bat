@echo off

tasm /m /ml window.asm
tasm32 /m /ml GraphX.asm
tasm /m /ml utility.asm
pause
tasm /m /ml game.asm
tasm /m /ml pole.asm
tasm /m /ml tank.asm
pause
tasm /m /ml weapon.asm
tasm /m /ml particle.asm
tasm /m /ml bonus.asm
pause
tasm /m /ml file.asm
tasm /m /ml menu.asm
pause
tlink32  /Tpe /aa /c /x tank.obj window.obj GraphX.obj menu.obj utility.obj game.obj pole.obj weapon.obj particle.obj bonus.obj file.obj 


del *.obj

rem  ..\upx\upx202w\upx window.exe

pause