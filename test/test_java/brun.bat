@REM 运行ruier文件夹下的 dart 测试代码
@REM eg: dart StrictfpTest  == run ruier/StrictfpTest.dart

@echo off

@REM 传入文件名
set p1=%1
set package=ruier

echo ===== start run %package%/%p1%.dart ====

call dart %package%/%p1%.dart

echo ===== end run %package%/%p1%.dart ====
