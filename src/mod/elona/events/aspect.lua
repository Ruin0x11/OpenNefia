local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Event = require("api.Event")
local IEvented = require("mod.elona.api.aspect.IEvented")
local Prompt = require("api.gui.Prompt")
local Gui = require("api.Gui")
local IItemThrowable = require("mod.elona.api.aspect.IItemThrowable")
local IItemFood = require("mod.elona.api.aspect.IItemFood")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")

local function permit_item_actions(item)
   if item:get_aspect(IItemFood) then
      item.can_eat = true
   end

   if item:has_category("elona.drink") then
      item.can_throw = true
   end

   if item:iter_aspects(IItemUseable):length() > 0 then
      item.can_use = true
   end

   if item:iter_aspects(IItemThrowable):length() > 0 then
      item.can_throw = true
   end

   if item:iter_aspects(IItemReadable):length() > 0 then
      item.can_read = true
   end
end
Event.register("base.on_item_instantiated", "Permit item actions", permit_item_actions)

local function prompt_aspect(iface, name, cb_name)
   return function(item, params, result)
      local aspects = item:iter_aspects(iface):to_list()

      if #aspects == 0 then
         return result
      elseif #aspects == 1 then
         local aspect = aspects[1]
         return aspect[cb_name](aspect, item, params, result)
      else
         local map = function(aspect)
            return aspect:localize_action(item, iface)
         end

         local choices = fun.iter(aspects):map(map):to_list()

         Gui.mes("base:aspect._.elona." .. name .. ".prompt", item:build_name(1))
         local result, canceled = Prompt:new(choices):query()

         if canceled then
            return "player_turn_query"
         end

         local aspect = aspects[result.index]
         return aspect[cb_name](aspect, item, params, result)
      end
   end
end

local aspect_item_useable = prompt_aspect(IItemUseable, "IItemUseable", "on_use")
Event.register("elona_sys.on_item_use", "Aspect: IItemUseable", aspect_item_useable)

local aspect_item_readable = prompt_aspect(IItemReadable, "IItemReadable", "on_read")
Event.register("elona_sys.on_item_read", "Aspect: IItemReadable", aspect_item_readable)

local _retain = setmetatable({}, { __mode = "k" })
local function aspect_evented(obj, params, result)
   for _, aspect in obj:iter_aspects(IEvented) do
      obj:connect_self_multiple(aspect:get_events(obj), true)
   end
   _retain[obj] = true

   return result
end
Event.register("base.on_object_instantiated", "Aspect: IEvented", aspect_evented)

local function aspect_item_throwable(obj, params, result)
   local did_something

   for _, aspect in obj:iter_aspects(IItemThrowable) do
      if aspect:on_thrown(obj, params, result) then
         did_something = true
      end
   end

   if did_something then
      return "turn_end"
   end

   return result
end
Event.register("elona_sys.on_item_throw", "Aspect: IItemThrowable", aspect_item_throwable)

require("mod.elona.events.aspect.sand_bag")
