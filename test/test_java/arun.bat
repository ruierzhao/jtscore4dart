@REM 快捷编译运行java

@echo off

@REM 传入全类名
set p1=%1
set package=ruier

echo ===== start run %package%/%p1%.java ====

javac %package%/%p1%.java 
java %package%.%p1%

echo ===== end run %package%/%p1%.java ====