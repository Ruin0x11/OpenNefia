@echo off

if not exist src\\deps\\elona (
    call runtime\\setup.bat
)

rem LuaJIT ffi bindings depend on PATH; ensure versioned libs are
rem ordered first to avoid missing entry point errors
set PATH=%cd%\lib\luautf8;%cd%\lib\libvips;%PATH%

pushd src
..\lib\luajit-2.0\luajit.exe repl.lua %*
popd
