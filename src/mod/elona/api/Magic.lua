local Chara = require("api.Chara")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local IItem = require("api.item.IItem")
local Skill = require("mod.elona_sys.api.Skill")

local Magic = {}

function Magic.prompt_location(magic_id, caster)
   local magic = data["elona_sys.magic"]:ensure(magic_id)
   local params = {
      source = caster
   }

   if magic.target_type == "self" then
      params.target = caster
      return params
   end
end

--- to be used with IItem.on_drink
function Magic.drink_potion(magic_id, power)
   return function (item, params)
      local chara = params.chara
      local consume_type = params.consume_type
      local curse_state = "none"

      if consume_type == "thrown" then
         local throw_power = params.throw_power or 100
         power = power * throw_power / 100
         curse_state = item:calc("curse_state")
      elseif consume_type == "drunk" then
         curse_state = item:calc("curse_state")
         if chara:is_in_fov() then
            Gui.play_sound("base.drink1", chara.x, chara.y)
            Gui.mes("action.drink.potion", chara, item)
         end
      end
      local did_something, result = Magic.cast(magic_id, {power=power,item=item,target=params.chara,curse_state=curse_state})

      if result and chara:is_player() and result.obvious then
         Effect.identify_item(item, "partly")
      end
      -- Event will be triggered globally if potion is consumed
      -- through spilling, since there will be no item to pass
      if class.is_an(IItem, item) then
         item.amount = item.amount - 1
      end

      chara.nutrition = chara.nutrition + 150

      if chara:is_allied() and chara.nutrition > 12000 and Rand.one_in(5) then
         Effect.vomit(chara)
      end

      return "turn_end"
   end
end

local function proc_well_events(well, chara)
   local event = Rand.rnd(100)

   if not chara:is_player() and Rand.one_in(15) then
      -- Fall into well.
      Gui.mes("action.drink.well.effect.falls.text", chara)
      Gui.mes_c("action.drink.well.effect.falls.dialog", "Cyan", chara)
      if chara:calc("is_floating") and not chara:has_effect("elona.gravity") then
         Gui.mes_c("action.drink.well.effect.falls.floats", chara)
      else
         chara:damage_hp(9999, "elona.well")
      end
   end

   if well._id == "elona.holy_well" then
      if Rand.one_in(2) then
         Magic.cast("elona.wish")
         return
      end
   end

   if chara:is_player() then
      Gui.mes("action.drink.well.effect.default")
   end

   if chara:is_player() then
      chara.nutrition = chara.nutrition + 500
   else
      chara.nutrition = chara.nutrition + 4000
   end

   if well._id == "elona.holy_well" then
      save.elona.holy_well_count = save.elona.holy_well_count - 1
   else
      well.params.count_1 = well.params.count_1 - Rand.rnd(3)
      well.params.count_2 = well.params.count_2 + Rand.rnd(3)
      if well.params.count_2 >= 20 then
         Gui.mes("action.drink.well.completely_dried_up", well)
         return "turn_end"
      end
   end
   if well.params.count_1 < -5 then
      Gui.mes("action.drink.well.dried_up", well)
   end
   return "turn_end"
end

function Magic.drink_well(item, params)
   local chara = params.chara

   if item.params.count_1 < -5 or item.params.count_2 >= 20
      or (item._id == "elona.holy_well" and save.elona.holy_well_count <= 0)
   then
      Gui.mes("action.drink.well.is_dry", item)
      return "turn_end"
   end

   local sep = item:separate()
   Gui.play_sound("base.drink1", chara.x, chara.y)
   Gui.mes("action.drink.well.draw", chara, item)

   return proc_well_events(sep, chara)
end

function Magic.read_scroll(magic_id, power)
   return function(item, params)
      local chara = params.chara

      if chara:has_effect("elona.blindness") then
         if chara:is_in_fov() then
            Gui.mes("action.read.cannot_see", chara)
         end
         return "turn_end"
      end

      if chara:has_effect("elona.dimming") or chara:has_effect("elona.confusion") then
         if not Rand.one_in(4) then
            if chara:is_in_fov() then
               Gui.mes("action.read.scroll.dimmed_or_confused", chara)
            end
            return "turn_end"
         end
      end

      if chara:is_in_fov() then
         Gui.mes("action.read.scroll.execute", chara, item)
      end
      if not item:calc("can_read_multiple_times") then
         item.amount = item.amount - 1
         Skill.gain_skill_exp(chara, "elona.literacy", 25, 2)
      end

      local did_something, result = Magic.cast(magic_id, {power=power,item=item,source=params.chara})

      if result and chara:is_player() and result.obvious then
         Effect.identify_item(item, "partly")
      end

      return "turn_end"
   end
end

local function calc_wand_success(chara, params)
   local magic = data["elona_sys.magic"]:ensure(params.magic_id)
   local item = params.item

   if not chara:is_player() or item:calc("zap_always_succeeds") then
      return true
   end

   local magic_device = chara:skill_level("elona.magic_device")

   local success
   if magic.type == "magic" then
      success = false

      local skill = magic_device * 20 + 100
      if item:calc("curse_state") == "blessed" then
         skill = skill * 125 / 100
      end
      if Effect.is_cursed(item:calc("curse_state")) then
         skill = skill * 50 / 100
      elseif Rand.one_in(2) then
         success = true
      end
      if Rand.rnd(magic.difficulty + 1) / 2 <= skill then
         success = true
      end
   else
      success = true
   end

   if Rand.one_in(30) then
      success = false
   end

   return success
end

Event.register("elona.calc_wand_success", "Default", calc_wand_success)

--- to be used with IItem.on_zap
function Magic.zap_wand(magic_id, power)
   return function(item, params)
      local magic = data["elona_sys.magic"]:ensure(magic_id)
      local chara = params.chara

      local curse_state = item:calc("curse_state")
      if curse_state == "blessed" then
         curse_state = "none"
      end

      local x, y = prompt_magic_location()
      if x == nil then
         return "player_turn_query"
      end

      local target = Chara.at(x, y, chara:current_map())
      if target == nil then
         if chara:is_in_fov() then
            Gui.mes("action.zap.execute", item)
            Gui.mes("common.nothing_happens")
         end
         return "turn_end"
      end

      if chara:is_in_fov() then
         Gui.mes("action.zap.execute", item)
      end

      local magic_device = chara:skill_level("elona.magic_device")
      local stat_magic = chara:skill_level("elona.stat_magic")
      local stat_perception = chara:skill_level("elona.stat_perception")
      local adjusted_power = power * (100 + magic_device * 10 + stat_magic / 2 + stat_perception / 2) / 100

      local success = chara:emit("elona.calc_wand_success", {magic_id=magic_id,item=item}, false)

      if success then
         local did_something, result = Magic.cast(magic_id,
                                                  {
                                                     power=adjusted_power,
                                                     item=item,
                                                     target=params.chara,
                                                     curse_state=curse_state
                                                  })

         if result and chara:is_player() and result.obvious then
            Effect.identify_item(item, "partly")
         end
         if chara:is_player() then
            Skill.gain_skill_exp(chara, "elona.magic_device", 40)
         end
      else
         if chara:is_in_fov() then
            Gui.mes("action.zap.fail", chara)
         end
      end

      if Item.is_alive(item) and not item:is_on_ground() then
         local map = item:current_map()
         map:refresh_tile(item.x, item.y)
      end

      local sep = item:separate()
      sep.count = sep.count - 1

      return "turn_end"
   end
end

return Magic
