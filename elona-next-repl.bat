set PATH=%cd%\lib\luautf8;%PATH%

pushd src
..\lib\luajit-2.0\bin\luajit.exe repl.lua
popd
