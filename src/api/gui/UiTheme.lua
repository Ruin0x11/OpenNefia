local UiTheme = {}

local Log = require("api.Log")

local fs = require("util.fs")
local data = require("internal.data")
local asset_drawable = require("internal.draw.asset_drawable")

local assets = {}
local cache = {}

local theme_proxy = class.class("theme_proxy")

function theme_proxy:init(namespace)
   assert(type(namespace) == "string")
   self._namespace = namespace
end

local function load_asset(id)
   if cache[id] then
      return cache[id]
   end

   -- BUG: The following causes flickering if the asset is being loaded in the
   -- middle of the draw() loop, because apparently LÖVE stops drawing in the
   -- middle of the frame if it can't finish within an alotted period of time
   -- (16ms?). I would rather load everything up front, but because BMP loading
   -- is expensive and it takes almost a minute to load it all at once I'd
   -- rather just load it lazily for the time being.

   local proto = assets[id]
   if not proto then
      return nil
   end

   local obj

   if type(proto) == "string" then
      proto = { image = proto }
   end

   if type(proto) == "table" then
      local _type = proto.type

      if _type == nil or _type == "asset" then
         local copy = table.shallow_copy(proto)
         obj = asset_drawable:new(copy)
      elseif _type == "font" then
         obj = { size = proto.size }
      elseif _type == "color" then
         obj = proto.color
      else
         error("invalid asset type " .. id .. " " .. tostring(_type))
      end
   else
      error("invalid asset " .. id)
   end

   Log.debug("Load new asset: %s", id)

   cache[id] = obj

   return cache[id]
end

function theme_proxy:__index(asset)
   local v = rawget(theme_proxy, asset)
   if v then
      return v
   end

   local id = self._namespace .. "." .. asset

   return load_asset(id)
end

local theme_holder = class.class("theme_holder")

function theme_holder:init()
end

function theme_holder:__index(namespace)
   if data["base.asset"][namespace] then
      return load_asset(namespace)
   end

   return theme_proxy:new(namespace)
end

function UiTheme.clear_cache()
   cache = {}
end

function UiTheme.clear()
   assets = {}
   cache = {}
end

function UiTheme.set_assets(_assets)
   assets = _assets
   cache = {}
end

function UiTheme.load(instance)
   return theme_holder:new()
end

function UiTheme.preload_all()
   data["base.asset"]:iter():each(function(a) load_asset(a._id) end)
end

function UiTheme.on_hotload(old, new)
   table.replace_with(old, new)
   new.preload_all()
end

return UiTheme
