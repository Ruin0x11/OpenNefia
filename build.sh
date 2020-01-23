#!/bin/bash

if [ ! -f "deps/elona122.zip" ]; then
	pushd deps
    wget http://ylvania.style.coocan.jp/file/elona122.zip 
	popd 
fi

if [ ! -d "deps/elona" ]; then
	pushd deps
    unzip elona122.zip
	popd 
fi

luajit build.lua $@
