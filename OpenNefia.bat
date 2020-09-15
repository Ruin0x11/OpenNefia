@echo off

if not exist "%programfiles%\LOVE\love.exe" (
    echo The LOVE runtime is not installed. Please install it from https://www.love2d.org.
    pause
    goto :end
)

if not exist src\\deps\\elona (
    call runtime\\setup.bat
)

rem LuaJIT ffi bindings depend on PATH; ensure versioned libs are
rem ordered first to avoid missing entry point errors
set PATH=%cd%\lib\luajit-2.0;%cd%\lib\luautf8;%cd%\lib\libvips;%PATH%

pushd src
luajit opennefia.lua --working-dir "src/" %*
popd

:end
