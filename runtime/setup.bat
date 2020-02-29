@echo off

rem We want to copy dependencies at game startup to avoid a second
rem preprocessing step, but since LÖVE has no ability to read files
rem outside the game's root folder we have to put it somewhere in src\.

if not exist src\\deps\\elona (
    echo Downloading Elona 1.22...
    pushd src\\deps
    powershell -NoProfile -Command "if (Test-Path .\\elona122.zip) { Remove-Item elona122.zip -Force }"
    powershell -NoProfile -Command "Invoke-WebRequest http://ylvania.style.coocan.jp/file/elona122.zip -OutFile elona122.zip"
    powershell -NoProfile -Command "Expand-Archive -Path elona122.zip -DestinationPath (Resolve-Path .); Remove-Item elona122.zip -Force"
    popd
)
