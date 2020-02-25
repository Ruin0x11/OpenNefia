# Gwen
*Gwen* is an engine rewrite of the Japanese roguelike RPG [Elona](https://ylvania.style.coocan.jp) using Lua and the LÖVE game engine.

It is also an experiment to see if a game can be written in an extensible manner, using a mod system and an extensive API.

Note that it is currently **alpha-quality** and massive breakage *will* occur when attempting to play through the game normally. *Nearly everything is still a work-in-progress.* If you would like a stable experience, then please play vanilla Elona or a variant like oomSEST instead.

## Features
- Intended goal of being feature-compatible with Elona 1.22 (though still a work in progress).
- Ability to modify the flow of game logic using event hooks.
- Architecture based on APIs - mods can reuse pieces of functionality exposed by other mods.
- Quality-of-life features for developers like code hotloading and an in-game Lua REPL. Build things like new game UIs or features in an interactive manner.
- Supports Windows, macOS, and Linux.

## Requirements
*Note*: These requirements are only for headless mode. If you're just running the main game, [all you need is LÖVE](https://love2d.org).

- [LuaJIT](http://luajit.org) 2.0.5
- [luasocket](http://w3.impa.br/~diego/software/luasocket/)
    + Provided by LÖVE.
- [luautf8](https://github.com/starwing/luautf8)
    + Replacement for LÖVE's `utf8` module.
- [luafilesystem](https://keplerproject.github.io/luafilesystem)
    + Replacement for LÖVE's `love.filesystem` module.

If you're using a Unix-like platform and are installing dependencies with `luarocks`, then `luarocks` must be configured to use `luajit` or `lua5.1` as its interpreter.

If you're using Windows, all dependencies needed for running headless mode are already included.

## Setup
If using Windows, install LÖVE from https://love2d.org to your Program Files.

If using a Unix-like platform, ensure the `love` binary is on your `PATH`.

Run `setup.bat` for Windows or `setup` for Unix-like platforms to download and unpack Elona 1.22.

## Running
Run `elona-next.bat` or `elona-next`.

## Credits
Some of the code in this repository has been taken or adapted from the following sources.

- [Elona_foobar](https://github.com/ElonaFoobar/ElonaFoobar) (MIT) [excerpts]
- [30log](https://github.com/Yonaba/30log) (MIT) [excerpts]
- [automagic.lua](http://lua-users.org/wiki/AutomagicTables) (unlicensed) [excerpts]
- [circular_buffer](https://gist.github.com/johndgiese/3e1c6d6e0535d4536692) (unlicensed) [modified]
- [gambiarra](https://bitbucket.org/zserge/gambiarra) (MIT) [modified]
- [inspect](https://github.com/kikito/inspect.lua) (MIT)
- [lua-resty-tsort](https://github.com/bungle/lua-resty-tsort) (MIT) [modified]
- [lua-schema](https://github.com/sschoener/lua-schema) (MIT)
- [luacheck](https://github.com/mpeterv/luacheck) (MIT) [excerpts]
- [luafun](https://github.com/luafun/luafun) (MIT/X11) [modified]
- [mobdebug](https://github.com/pkulchenko/MobDebug) (MIT) [modified]
- [Penlight](https://github.com/stevedonovan/Penlight) (MIT) [excerpts]
- [profile.lua](https://bitbucket.org/itraykov/profile.lua) (unlicensed) [modified]
- [strict.lua](http://lua-users.org/lists/lua-l/2005-08/msg00737.html) (unlicensed)
