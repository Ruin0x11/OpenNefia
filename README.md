# Elona_next (仮
Moddable rewrite of Elona 1.22 in Lua/Love2D.

It is in a **very early** stage of development. There is not yet a stable modding API since the best ways of modding various parts of the system are still being figured out through trial and error. Also, there are currently no guarantees of save compatibility between versions of `Elona_next`.

The title `Elona_next` is temporary since nothing better has been decided yet. (There actually was a variant named `Elona_next` at some point.)

## Requirements
- [LÖVE](https://love2d.org) 0.10.0
    + NOTE: At some point the project will move to a custom build of the LÖVE runtime due to missing features (font styling, MIDI playback, CJK text wrapping, etc.)
- [LuaJIT](http://luajit.org) 2.0.5
- [luasocket]()
    + Provided by LÖVE.
- [luautf8](https://github.com/starwing/luautf8)
    + Replacement for LÖVE's `utf8` module.
- [luafilesystem](https://keplerproject.github.io/luafilesystem)
    + Replacement for LÖVE's `love.filesystem` module.

If using a Unix-based operating system and are installing dependencies with `luarocks`, then `luarocks` must be configured to use `luajit` or `lua5.1` as its interpreter, as the build process uses `luajit`.

If using Windows, all dependencies needed for building are already included.

## Build

### Windows

Run the following under a Visual Studio x64 command prompt.
```
build.bat
```

### macOS

Ensure all dependencies are installed.

Run the following in `bash` or similar.
```
./build.sh
```

### Linux

Ensure all dependencies are installed.

Run the following in `bash` or similar.
```
./build.sh
```

## Running

Ensure the `love` binary is on your `PATH`.

Run `elona-next.bat` on Windows or `elona-next.sh` on macOS/Linux.
```

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
    + Based on [RemDebug](https://web.archive.org/web/20140928055353/http://www.keplerproject.org/remdebug). (MIT/X11)
    + Uses [serpent](https://github.com/pkulchenko/serpent). (MIT)
- [Penlight](https://github.com/stevedonovan/Penlight) (MIT) [excerpts]
- [profile.lua](https://bitbucket.org/itraykov/profile.lua) (unlicensed) [modified]
- [strict.lua](http://lua-users.org/lists/lua-l/2005-08/msg00737.html) (unlicensed)

Individual mods that are versioned in this repository may have additional dependencies; see their READMEs for details.
