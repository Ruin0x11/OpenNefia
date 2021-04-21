# Architecture

This document should hopefully explain the design of OpenNefia at a high-enough level for people just getting familiar with the codebase.

Only the parts of the engine that are unlikely to change are touched on here, to prevent this document from getting outdated quickly.

Also, "engine" in this document is intended to mean the platform in OpenNefia in which you can write mods and the API this platform encompasses. It's not meant to refer to LÖVE, the underlying game engine that actually handles things like graphics and sound. I don't think it makes sense to call OpenNefia a "game engine," but more of an API that exposes the features in previous versions of Elona that were difficult to "mod".

## 1000-Foot View

OpenNefia uses a game loop based on coroutines. There is an update phase and a draw phase that get called on every frame, and each phase gets its own coroutine.

Input and interface interaction is handled by a "draw layer" system. A draw layer is a thing that can be updated and drawn, and potentially receives input from the underlying game engine. Whenever input from a keyboard or mouse is received, it gets forwarded to the draw layer that is currently active.

Draw layers are held in a stack, and can have a custom rendering order defined. There is at most one currently active draw layer at a time, which is the one that is at the top of the stack. Entering and exiting menus is accomplished by pushing to or popping off the topmost slot on the draw layer stack.

This is the sequence of actions that happens on every frame of the engine for the currently active draw layer:

1. If the draw layer can receive input, then any actions that are bound to the sent key/mouse input are run.
2. The draw layer's update routine is called.
3. The draw layer's drawing routine is called.

Additionally, there is a level of abstraction on top of the draw layer system, which is called the "UI layer" system. These are special draw layers which can return results in the update routine, which will cause the layer to be popped off the stack and the focus to return to the previous layer. UI layers also have some extra features for things like keybinding. Almost all interactive user interface components in OpenNefia are constructed in terms of UI layers.

### Data System

One of the core principles of OpenNefia is that the average player should be able to easily extend the game's data. There's a wide variety of data types available, from important things like characters and items to more mundane ones like the kinds of seeds you can plant or the randomly generated equipment loadouts of new monsters.

Game data is kept in one massive `data` table, shared by every mod. Mods can add new data prototypes and brand new types of data. These new types can then be extended by other mods in turn, keeping the ever-continuing cycle of modding and extension alive.

### Event System

When declarative modification of game data isn't enough to achieve a desired behavior, the game's logic can be altered by inserting new pieces logic through an event system.

The event system is rather simple: there are a variety of different event types, and each event type can have one or more event callbacks registered for it. Each event callback gets its own *priority*, which affects the order in which the callback is run. Also, event callbacks can *block* the event callbacks that follow it, in order to change the flow of existing game logic.

The usage of event callbacks is extremely common in the codebase, and they implement the majority of Elona's original logic in a way that is much more extensible than before, at the cost of somewhat decreased maintainability.

## Codemap

This section will touch on some important places in the codebase.

### `editor`

This folder holds some editor plugins to make developing OpenNefia easier. Because the author of OpenNefia uses Emacs as a primary editor, only the Emacs support is continually kept up-to-date.

### `runtime`

This folder contains some scripts that need to be run outside the game itself before it's first launched. They are used for downloading a copy of Elona 1.22 from the official webpage and obtaining the current Git commit hash so it can be referenced in-game.

### `src/game`

The main game loop. This is where input from the player is queried and all characters in the current map act out their turns. It also holds the initialization code for the game's tile atlases. This is the part of the code that is the closest to the top-level program loop.

The actual input to the game for things like movement and actions is handled in the `field_layer` class. This is the draw layer that handles updating and rendering the tilemap and is pretty much always active except when inside the main title screen.

Turn actions in OpenNefia are mainly focused on two kinds of turn results: ones that end the current character's turn, and ones that return control back to the player. Each callback in the turn order logic will return one of those results in the order the characters act.

### `src/util/class.lua`

Contains the implementation of OpenNefia's object oriented programming system.

The features in this system include "interfaces" that act like mixins, classes that can implement these interfaces, and delegation of methods to child properties. There are no abstract classes or explicit inheritance trees.

### `src/internal/draw.lua`

Holds the list of active draw layers, and provides some functions for pushing/popping draw layers from the stack. Also holds some low-level drawing code, which is consumed by the `Draw` module.

### `src/internal/layer`

Holds rendering logic for the tilemap. This is where tiles, objects on the map, and special effects like shadows or light get rendered.

Note that the "tile layers" inside this folder are *separate* from the "draw layer" system discussed above. They are specific to rendering the tilemap, and are all contained solely within the overarching `field_layer` draw layer.

Each of the tile layers is assigned a priority, so the order of rendering can be controlled. They are passed the current map in order to update sprite batches and other things.

It is also possible for mods to add their own tile layers. This is used in practice for mods that add damage number popups or speech bubbles when a character says something.

### `src/internal/data_table.lua`

Contains the implementation of the `data` table at the heart of the data declaration system discussed above. This table is globally available to all mods.

### `src/internal/i18n.lua`

This holds the core of OpenNefia's internationalization code. OpenNefia was designed to be agnostic to any language (unlike the original Elona, which only supported English and Japanese). This module is responsible for traversing the set of translations provided by mods, and indexing them into a format that can be quickly retrieved.

### `src/internal/theme.lua`

Contains the theme system. Themes allow you to dynamically replace certain game assets at runtime with a set of overrides that can be combined together. This is a much-needed improvement over vanilla's methodology for theming, which was "overwrite all the files you want to theme in your game's folder with the new versions."

### `src/internal/data/schemas.lua`

Defines the vast majority of the base engine types, like characters and items. If a data type is provided by the engine (like `base.chara`), then it originated either from here or the `base` mod under the `mod/` folder.

### `src/internal/data/config_option.lua`

Defines the base engine's config options. Config options are global to a single player profile and can be edited in the in-game settings menu. Of course, it's possible for mods to add their own config options as well.

### `src/api`

This holds the public API of OpenNefia. Mods can use anything that's available in this folder (and conversely, cannot use things in `src/game` or `src/internal`).

**Invariant:** The API modules try to operate on as little global state as possible. One of the largest pitfalls of Elona's original codebase was the sheer amount of global state, making even the smallest feature request become a grand journey of refactoring all sorts of disparate places.

Generally speaking, when you think of `api/`, you should think of "a collection of functions that only reads from or writes to the state you pass in, and preferably doesn't mutate any state at all." When writing new code in OpenNefia, it's a good idea not to do things like ask for the current global map in the logic you write, since global state can become ambiguous at times (like when the player is entering a new map). Instead, you should do things like ask a character object passed as an argument to your function for the map they're currently living in, and use that in your computations instead.

Also, when wanting to implement some new game logic, it's preferable to create API modules that are called inside event callbacks instead of using stateful class instances. Classes in OpenNefia work best when used inside the UI subsystem, where nearly everything is already OO-based.

### `src/api/Draw.lua`

Contains functions for drawing primitive shapes to the screen. Most of these functions are only usable in the drawing stage of the game loop.

### `src/api/InstancedMap.lua`

This is the main data structure that represents a game map. Nearly all of the game's state is held in one of these at any given time.

OpenNefia is designed such that you can create new maps and operate on them as individual objects. This is different than in vanilla, where if you wanted to load a map it would have to replace the one currently loaded. This is useful for things like events that are triggered when transitioning from one map to another, since the objects in either map can both be accessed at the same time.

### `src/api/Chara.lua` / `src/api/Item.lua` / `src/api/Feat.lua` / `src/api/Mef.lua`

Public interfaces for querying the four main types of game objects: characters, items, map features (feats) and map effects (mefs).

The most important thing these APIs provide is a way of iterating all of the objects of the relevant type in a map. Their interface was designed to be consistent with one another, so if you frequently use a function like `Chara.is_alive()` to check if a reference points to a living character, you can expect that the corresponding `Item.is_alive()` function will also exist and serve much the same purpose.

### `src/api/chara/IChara.lua` / `src/api/item/IItem.lua` / `src/api/feat/IFeat.lua` / `src/api/mef/IMef.lua`

These interfaces hold the instance methods for instantiated game objects of the relevant types. They all include the `IMapObject` interface, which specifies some common functions for moving objects from one location to another (such as between different maps) and removing objects from the map.

The "interface" terminology for parts of the API like this is somewhat of a misnomer. Interfaces in OpenNefia's OOP layer act more like mixins, since they can add extra state to the implementer. For example, `IIEventEmitter` is an interface which adds the ability for a game object to trigger event callbacks for an event type, passing in the object emitting the event as the main argument to the registered callbacks. But unlike interfaces in the purest OO sense, interfaces in OpenNefia can also add some extra state to the objects that implement them. In the case of `IIEventEmitter`, it holds data on event callbacks registered on that object individually, separate from the event callbacks that have been registered globally and affect all objects that emit an event.

### `src/api/Event.lua`

This module allows you to register new event callbacks and toggle them on and off. It's used very commonly in the codebase.

### `src/api/gui/IUiLayer.lua`

This is the interface that implements the "UI layer" abstraction discussed above. It's pretty important since it's used by everything in the engine that accepts player input.

## Mod Structure

The conventions for directory structure that mods in OpenNefia use is fairly standard at this point. This section discusses that structure.

Note that there isn't anything *requiring* mods to use this directory structure. The only things that are absolutely required to be placed in a mod's folder are `mod.lua`, which specifies the mod's version and dependencies, and `init.lua`, which is run when OpenNefia first starts up. However, using a fairly standard directory structure makes reasoning about unfamiliar mod codebases much easier.

### `mod/<...>/api`

API modules. This serves the exact same purpose as `src/api` in the base engine - it provides some public modules that can potentially be used by other mods.

### `mod/<...>/data`

Holds data prototype and data type definitions.

The current convention is to put definitions for the base engine datatypes at the top of this folder, and nest data definitions for other mods under folders named after those mods. So for example, definitions for `base.chara` would exist in `data/chara.lua`, and maybe `data/chara/foo.lua` if there's a lot of definitions being added. Definitions for `sokoban.board` would go under `data/sokoban/board.lua`, and maybe under `data/sokoban/board/foo.lua` if there's a lot of data, as before.

### `mod/<...>/event`

Holds event callbacks. Each file under this folder would usually be named after what parts of the game the event callbacks affect. So event callbacks that would affect how characters move around would be under `chara.lua`, events from automatically picking up items might be under `autopickup.lua`, and so on. However, there is of course no strictly enforced naming scheme.

The *vast majority* of the actual logic for the game lives here, especially inside the `elona` mod.

### `mod/<...>/event/save.lua`

Mods can have their own separate save data which gets serialized along with the base save data. For mods where save data is a concern, an event callback which initializes the save data to some safe default values should be added. This callback is usually found under `event/save.lua`, so you can easily find out what save data a mod has.

### `mod/<...>/internal`

Internal modules. Synonymous with `src/internal` in the base engine.

**Invariant**: As far as my style of programming goes, it's very rare for me to use internal modules in OpenNefia mods. Having everything in a public API means that, while API breakage is a looming concern, it becomes possible to reuse the hard work of existing mods for entirely new features.

However, my opinion is likely to change when the main focus of OpenNefia turns to improving maintenance and stability.

### `mod/<...>/internal/global.lua`

A convention for declaring some state that's global to a mod. This module simply returns a table with the appropriate fields that can be modified at will. This is generally used for state that needs to be shared between more than one API/internal module, but should *not* be associated with a save. One example where this is used is for the damage popups mod, where it holds the elapsed time for each popup and their position/font/color. New popups are added through an API module that appends a new entry to the state. This data is then read by a separate tile layer class to render the damage popups to the screen.

### `mod/<...>/locale`

Holds translated text inside Lua files.

This is one of the few folders whose location is set in stone, since the translation subsystem will only look in the `locale/` folder for translations, but this makes it easier to reason about.

Locale files can optionally be namespaced, and each mod gets its own localization namespace. For example, `locale/en/autopickup/foo.lua` is namespaced for the `autopickup` mod, and can contain keys like `autopickup:ui.menu.name`. If no namespace folder is used, as in `locale/en/chara.lua`, the namespace defaults to `base` instead.

**Invariant**: Locale files are Lua files that are executed in a separate context from the main engine code. The reasoning for this is that translations shouldn't need to do things like spawn characters; they should only be responsible for taking some arguments like strings or game objects and return strings of translated text. As such, it is not possible to use any public API modules in locale files.

The functions that *can* be used in locale files are for purposes like obtaining the gendered pronouns of a character such as "her" or "his". Notably, this is a painful thing to do with systems like `gettext`, so my guess is that many games are designed such that they have no mechanism for localizing pronouns. But because these kinds of localizations existed in vanilla Elona, it was necessary to implement them in OpenNefia as well, hence the Lua-based translation system that's provided.

For the set of functions that can be used in locale files per language, see `src/internal/i18n/env`.

### `mod/<...>/graphic`

Holds images, for things like character/item chips or user interfaces.

### `mod/<...>/sound`

Holds sound and music.

### `mod/<...>/test`

Holds unit tests. See the "Testing" section below.

## Other Concerns

Here are some other features of the engine that are pretty important.

### Important Mods

At the time of writing, a base installation of OpenNefia must load these mods in order to function properly:

* `base` - Base engine data types.
* `extlibs` - Has some useful libraries like CSV parsers or color manipulation.
* `elona_sys` - Some abstractions commonly used by the engine, like character dialogs. (This will be removed and merged into `elona` at a later point)
* `elona` - Holds the game content of Elona, and some extra features from Elona built entirely in terms of the extension and modding features that OpenNefia provides.

There are currently some antipatterns being used in the base API where modules from the `elona` mod are imported within the base engine's code. This is bad. At some point in the future, the hope is that much of the code in `src/api` can be moved into the `elona` mod in order to break these dependencies, including most of the user interface code that touches on specific game mechanics.

Refactoring OpenNefia to have no dependencies on the `elona` mod isn't very high priority at the moment. Unlike some other game development frameworks, OpenNefia is *not* intended to be a general-purpose roguelike engine. It is only meant to be a way to mod the game systems specific to Elona in new and refreshing ways.

### Testing

Tests are run by the `test` command found under `src/tools/cli`. The base engine tests are found under `src/test` and comprise parts of the public API. It is also possible for mods to add their own tests by putting them under a top-level `test/` folder. To accommodate differing mod dependencies, for each mod-provided test suite that gets run, the engine will reset all of its global state back to a clean slate and rerun the mod loading process if necessary.
