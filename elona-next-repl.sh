#!/bin/bash

pushd src
luajit repl.lua $*
popd
