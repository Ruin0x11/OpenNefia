set LUAJIT_DIR=lib\luajit-2.0
set LUAJIT_BIN=%LUAJIT_DIR%\bin\luajit.exe
if not exist %LUAJIT_BIN% (
pushd %LUAJIT_DIR%\src
call msvcbuild
popd

mkdir %LUAJIT_DIR%\bin
xcopy /y /e /s %LUAJIT_DIR%\src\lua51.dll %LUAJIT_DIR%\bin
xcopy /y /e /s %LUAJIT_DIR%\src\luajit.exe %LUAJIT_DIR%\bin
)

set ELONA_DIR=deps\\elona
if not exist %ELONA_DIR% (
pushd deps
powershell -Command "Invoke-WebRequest http://ylvania.style.coocan.jp/file/elona122.zip -OutFile elona122.zip"
powershell -Command "Expand-Archive -Path elona122.zip -DestinationPath (Resolve-Path .)"
popd
)

rem LuaJIT ffi bindings depend on path; ensure versioned libs are
rem ordered first to avoid missing entry point errors
set PATH=%cd%\lib\libvips;%PATH%

%LUAJIT_BIN% build.lua %*
