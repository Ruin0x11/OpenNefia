local UiTheme = {}

local Log = require("api.Log")

local fs = require("util.fs")
local data = require("internal.data")
local asset_drawable = require("internal.draw.asset_drawable")

local active_themes = {}
local cache = {}

local theme_proxy = class.class("theme_proxy")

function theme_proxy:init(namespace)
   assert(type(namespace) == "string")
   self._namespace = namespace
end

function theme_proxy:serialize()
end

function theme_proxy:deserialize()
end

local function find_asset(namespace, asset)
   for i = #active_themes, 1, -1 do
      local theme = active_themes[i]
      local ns = theme.assets[namespace]
      if ns then
         local proto = ns[asset]
         if proto then
            return proto, theme
         end
      end
   end

   return nil
end

function theme_proxy:__index(asset)
   local v = rawget(theme_proxy, asset)
   if v then
      return v
   end

   local id = self._namespace .. "." .. asset
   if cache[id] then
      return cache[id]
   end

   local proto, theme = find_asset(self._namespace, asset)
   if not proto then
      error("Cannot find asset " .. id)
   end

   local root = theme.root
   local obj

   if type(proto) == "string" then
      proto = { image = proto }
   end

   if type(proto) == "table" then
      local _type = proto.type

      if _type == nil or _type == "asset" then
         local copy = {
            image = proto.image,
            count_x = proto.count_x,
            count_y = proto.count_y,
            regions = proto.regions
         }
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

function UiTheme.clear_cache()
   cache = {}
end

function UiTheme.clear()
   active_themes = {}
   cache = {}
end

function UiTheme.add_theme(id)
   local theme = data["base.theme"]:ensure(id)
   active_themes[#active_themes+1] = theme
   cache = {}
   -- TEMP: validate file existence
   local p = theme_proxy:new("elona")
   for k, _ in pairs(theme.assets.elona) do
      assert(p[k])
   end
end

function UiTheme.theme_id()
   return active_themes[1] and active_themes[1]._id
end

function UiTheme.load(instance)
   return theme_proxy:new("elona")
end

function UiTheme.load_asset(id)
   return UiTheme.load(nil)[id]
end

function UiTheme.on_hotload(old, new)
   local id = old.theme_id()
   assert(id)
   new.add_theme(id)
end

return UiTheme
