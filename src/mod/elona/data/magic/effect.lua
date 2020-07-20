local Anim = require("mod.elona_sys.api.Anim")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")

local function per_curse_state(curse_state, doomed, cursed, none, blessed)
   if curse_state == "doomed" then
      return doomed
   elseif curse_state == "cursed" then
      return cursed
   elseif curse_state == "blessed" then
      return blessed
   end

   return none
end

data:add {
   _id = "milk",
   _type = "elona_sys.magic",
   elona_id = 1101,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.play_sound("base.atk_elec")
         if Effect.is_cursed(params.curse_state) then
            if target:is_player() then
               Gui.mes("magic.milk.cursed.self")
            else
               Gui.mes_c("magic.milk.cursed.other", "SkyBlue")
            end
         elseif target:is_player() then
            Gui.mes("magic.milk.self")
         else
            Gui.mes_c("magic.milk.other", "SkyBlue")
         end
      end

      if params.curse_state == "blessed" then
         Effect.modify_height(target, Rand.rnd(5) + 1)
      elseif Effect.is_cursed(params.curse_state) then
         Effect.modify_height(target, (Rand.rnd(5) + 1) * -1)
      end

      target.nutrition = target.nutrition + 1000 * math.floor(params.power / 100)
      if target:is_player() then
         Effect.show_eating_message(target)
      end

      Effect.apply_food_curse_state(target, params.curse_state)
      local anim = Anim.load("elona.anim_elec", target.x, target.y)
      Gui.start_draw_callback(anim)

      return true
   end
}

data:add {
   _id = "effect_ale",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if Effect.is_cursed(params.curse_state) then
            Gui.mes_c("magic.alcohol.cursed", "SkyBlue")
         else
            Gui.mes_c("magic.alcohol.normal", "SkyBlue")
         end
      end

      target:apply_effect("elona.drunk", params.power)
      Effect.apply_food_curse_state(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_sulfuric",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.acid.self")
         end
         Gui.mes("magic.acid.apply", target)
      end

      if target.is_pregnant then
         target.is_pregnant = false
         if target:is_in_fov() then
            Gui.mes("magic.common.melts_alien_children", target)
         end
      end

      target:damage_hp(params.power * per_curse_state(params.curse_state, 500, 400, 100, 50) / 1000,
                       "elona.acid",
                       {element="elona.acid", element_power=params.power})

      return true
   end
}

data:add {
   _id = "potion_water",
   _type = "elona_sys.magic",
   elona_id = 1103,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.water.self")
         else
            Gui.mes("magic.water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "potion_restore_stamina",
   _type = "elona_sys.magic",
   elona_id = 1146,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina.dialog")
         Gui.mes("magic.restore_stamina.apply", target)
      end

      target:heal_stamina(25)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_cupsule",
   _type = "elona_sys.magic",
   elona_id = 1147,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina_greater.dialog")
         Gui.mes("magic.restore_stamina_greater.apply", target)
      end

      target:heal_stamina(100)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_dirty_water",
   _type = "elona_sys.magic",
   elona_id = 1130,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.dirty_water.self")
         else
            Gui.mes("magic.dirty_water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_love_potion",
   _type = "elona_sys.magic",
   elona_id = 1135,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      if Effect.is_cursed(params.curse_state) then
         if params.target:is_player() then
         else
            Gui.mes("magic.love_potion.cursed", params.target)
            Skill.modify_impression(params.target, -15)
         end
         return true, { obvious = false }
      end

      local function love_miracle(chara)
         if Rand.one_in(2) or chara:is_player() then
            return
         end
         Gui.mes_c("misc.love_miracle.uh", "SkyBlue")
         if Rand.one_in(2) then
            local item = Item.create("elona.egg", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
               local weight = chara:calc("weight")
               item.weight = weight * 10 + 250
               item.value = math.clamp(math.floor(weight * weight / 10000), 200, 40000)
            end
         else
            local item = Item.create("elona.bottle_of_milk", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
            end
         end

         Gui.play_sound("base.atk_elec")
         local anim = Anim.load("elona.anim_elec", chara.x, chara.y)
         Gui.start_draw_callback(anim)
      end

      params.target:set_emotion_icon("elona.heart", 3)

      if params.triggered_by == "potion_spilt" or params.triggered_by == "potion_thrown" then
         Gui.mes("magic.love_potion.spill", params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 15, 0, 15))
         params.target:apply_effect("elona.dimming", 100)
         love_miracle(params.target)
         return true
      end

      if params.target:is_player() then
         Gui.mes("magic.love_potion.self", params.target)
      else
         Gui.mes("magic.love_potion.other", params.target)
         love_miracle(params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 4, 0, 25))
      end

      params.target:apply_effect("elona.dimming", 500)
      return true
   end
}

data:add {
   _id = "effect_salt",
   _type = "elona_sys.magic",
   elona_id = 1142,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if target.race == "elona.snail" then
         if target:is_in_fov() then
            Gui.mes_c("magic.salt.snail", "Red", target)
         end
         if target.hp > 10 then
            target:damage_hp(target.hp - Rand.rnd(10), "elona.acid")
         else
            target:damage_hp(Rand.rnd(20000), "elona.acid")
         end
      elseif target:is_in_fov() then
         Gui.mes_c("magic.salt.snail", "SkyBlue")
      end

      return true
   end
}
