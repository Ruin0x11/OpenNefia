#!/bin/bash

if ! hash luajit 2>/dev/null; then
    echo "LuaJIT is not installed. Please install it with your operating system's package manager."
    exit 1
fi

if [ ! -d "deps/elona" ]; then
    pushd deps
    rm *.zip
    wget "http://ylvania.style.coocan.jp/file/elona122.zip"
    unzip elona122.zip
    popd
fi

luajit build.lua
