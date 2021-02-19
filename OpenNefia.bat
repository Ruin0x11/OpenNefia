@echo off

if not exist src\\deps\\elona (
    call runtime\\setup.bat
)

rem LuaJIT ffi bindings depend on PATH; ensure versioned libs are
rem ordered first to avoid missing entry point errors
set PATH=%cd%\lib\luajit-2.0;%cd%\lib\luautf8;%cd%\lib\libvips;%PATH%

pushd src
    if "%1"=="" (
        rem don't try to load luafilesystem, etc. if no arguments are provided, so the
        rem user doesn't have to install a full luajit environment just to run the game.
        if not exist "%programfiles%\love\love.exe" (
            echo the love runtime is not installed. please install it from https://www.love2d.org.
            pause
            exit /b 1
        )
        "%programfiles%\love\love.exe" .
    ) else (
        luajit opennefia.lua --working-dir "src/" %*
    )
popd

if %errorlevel% neq 0 exit /b %errorlevel%
