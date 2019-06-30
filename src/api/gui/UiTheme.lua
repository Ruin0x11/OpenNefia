local UiTheme = {}

local Asset = require("api.Asset")
local Log = require("api.Log")

local data = require("internal.data")
local env = require("internal.env")
local asset_drawable = require("internal.draw.asset_drawable")

local current_theme = "base.default"
local theme_table = nil
local cache = setmetatable({}, { __mode = "v" })
local asset_used = {}

function UiTheme.reload()
   theme_table = table.maybe(data, "base.ui_theme", current_theme)
end

function UiTheme.set_theme(id)
   for k, _ in pairs(asset_used) do
      Asset.mark_outdated(k)
   end

   current_theme = id
   theme_table = nil
   cache = setmetatable({}, { __mode = "v" })
   asset_used = {}
end

function UiTheme.load(instance)
   local fq_name

   if type(instance) == "string" then
      fq_name = instance
   else
      fq_name = env.get_require_path(instance)
   end

   if cache[fq_name] then
      return cache[fq_name]
   end

   if theme_table == nil then
      UiTheme.reload()
   end

   local dat = nil

   if string.nonempty(fq_name) then
      local base = table.maybe(theme_table, "base") or {}

      dat = table.maybe(theme_table, "items", fq_name)
      if not dat then
         -- TODO: fallback to base.default here, and warn if still not found
         Log.warn("No theme data for %s was configured.", fq_name)
         return base
      end

      cache[fq_name] = cache[fq_name] or {}

      dat = table.merge_missing(dat, base)

      for k, v in pairs(dat) do
         local _type
         local _value
         if type(v) == "string" then
            _type = "image"
            _value = v
         else
            _type = v.type
            _value = v.value
         end

         if _type == "color" or _type == "font" then
            cache[fq_name][k] = _value
         elseif type == "asset" then
            -- will be cached inside Asset
            cache[fq_name][k] = Asset.load(_value)
            asset_used[k] = true
         else
            -- cache is managed by UiTheme as there is no asset ID to
            -- provide to Asset for caching
            cache[fq_name][k] = cache[fq_name][k] or asset_drawable:new(_value)
         end
      end
   end

   return cache[fq_name]
end

return UiTheme
