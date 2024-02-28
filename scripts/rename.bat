@REM 遍历文件夹并删除 package-info.java

@echo off

del /f /s /q package-info.java

@REM for /r ../lib/src  %%i in (package-info.*) do ( 
@REM     echo ruier %%i
@REM     set originFile=%%i
@REM     del /f %originFile%
@REM  )
