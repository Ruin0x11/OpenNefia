@echo off

if not exist src\\deps\\elona (
    call runtime\\setup.bat
)

set PATH=%cd%\lib\luautf8;%PATH%

pushd src
..\lib\luajit-2.0\luajit.exe repl.lua %*
popd
