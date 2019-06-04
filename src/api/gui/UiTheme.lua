local UiTheme = {}

local Asset = require("api.Asset")
local data = require("internal.data")
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
   local fq_name = instance
   if instance.get_fq_name then
      fq_name = instance:get_fq_name()
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

data:add_multi(
   "base.ui_theme",

   {
      _id = "default",

      base = {
         text_color = {
            type = "color",
            value = {0, 0, 0}
         },
         text_color_light = {
            type = "color",
            value = {255, 255, 255}
         },
         text_color_light_shadow = {
            type = "color",
            value = {0, 0, 0}
         },
      },

      items = {
         ["api.gui.hud.MainHud"] = {
            minimap = "graphic/temp/hud_minimap.bmp",
            map_name_icon = "graphic/temp/map_name_icon.bmp",
            bar = "graphic/temp/hud_bar.bmp",
            message_window = "graphic/temp/message_window.bmp",
            skill_icons = {
               type = "asset",
               value = {
                  image = "graphic/temp/hud_skill_icons.bmp",
                  count_x = 10
               }
            },
            attribute_font = {
               type = "font",
               value = 13
            },
            map_name_font = {
               type = "font",
               value = 12
            }
         },
         ["api.gui.hud.UiGoldPlatinum"] = {
            gold_coin = "graphic/temp/gold_coin.bmp",
            platinum_coin = "graphic/temp/platinum_coin.bmp",
         },
         ["api.gui.hud.UiLevel"] = {
            character_level_icon = "graphic/temp/character_level_icon.bmp",
         },
         ["api.gui.hud.UiClock"] = {
            clock = "graphic/temp/clock.bmp",
            clock_hand = "graphic/temp/clock_hand.bmp",
            date_label_frame = "graphic/temp/date_label_frame.bmp",
         },
      }
   }
)

data:add_multi(
   "base.asset",

   {
      _id = "skill_icons",
      image = "graphic/temp/skill_icons.bmp",
      count_x = 10
   }
)

return UiTheme
