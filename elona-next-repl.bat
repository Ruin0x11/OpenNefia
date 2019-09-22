set PATH=%PATH%;%cd%\lib\luautf8

pushd src
..\lib\luajit-2.0\bin\luajit.exe repl.lua
popd
