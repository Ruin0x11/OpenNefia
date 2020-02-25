@echo off
set PATH=%cd%\lib\luautf8;%PATH%

pushd src
..\lib\luajit-2.0\luajit.exe repl.lua
popd
