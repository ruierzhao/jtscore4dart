@REM 遍历文件夹并删除 package-info.java

@echo off


for /r ../lib/src  %%i in (package-info.*) do ( 
    echo ruier %%i
    set originFile=%%i
    del /f /p %originFile%
 )
