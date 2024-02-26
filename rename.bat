@REM 遍历文件夹并改名

@echo off


for /r .  %%i in (*.java) do ( 
    set originFile=%%i
    
    set newfile=%originFile:java=dart%
    echo newfile

    ren %originFile% %newfile% 

    echo %originFile% ===rename to=== %newfile%
 )
