#!/usr/bin/env bash
set -euo pipefail

TL_PATH='types/luafilesystem/?.lua;types/luasocket/?.lua' tl -l main check $@
