local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local Event = require("api.Event")
local IEvented = require("mod.elona.api.aspect.IEvented")
local I18N = require("api.I18N")
local Prompt = require("api.gui.Prompt")
local Gui = require("api.Gui")
local IItemThrowable = require("mod.elona.api.aspect.IItemThrowable")

local function aspect_item_useable(item, params, result)
   local aspects = item:iter_aspects(IItemUseable):to_list()

   if #aspects == 0 then
      return result
   elseif #aspects == 1 then
      return aspects[1]:on_use(item, params, result)
   else
      local map = function(aspect)
         return aspect:localize_action(item, IItemUseable)
      end

      local choices = fun.iter(aspects):map(map):to_list()

      Gui.mes("base:aspect._.elona.IItemUseable.prompt", item:build_name(1))
      local result, canceled = Prompt:new(choices):query()

      if canceled then
         return "player_turn_query"
      end

      return aspects[result.index]:on_use(item, params, result)
   end
end
Event.register("elona_sys.on_item_use", "Aspect: IItemUseable", aspect_item_useable)

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
