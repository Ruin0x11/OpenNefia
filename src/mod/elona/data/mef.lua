local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Event = require("api.Event")
local Mef = require("api.Mef")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Enum = require("api.Enum")
local Log = require("api.Log")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Effect = require("mod.elona.api.Effect")

data:add {
   _type = "base.mef",
   _id = "web",
   elona_id = 1,

   image = "elona.mef_web",

   on_stepped_off = function(self, params)
      local chara = params.chara
      local web_free_weight = 100
      if not chara:calc("can_pass_through_webs") then
         if Rand.rnd(self.power + 25) < Rand.rnd(chara:skill_level("elona.stat_strength") + chara:skill_level("elona.stat_dexterity") + 1)
            or chara:calc("weight") > web_free_weight
         then
            Gui.mes_visible("mef.destroys_cobweb", chara.x, chara.y, chara)
            self:remove_ownership()
         else
            self.power = math.floor(self.power * 3 / 4)
            Gui.mes_visible("mef.is_caught_in_cobweb", chara.x, chara.y, chara)
            return { blocked = true }
         end
      end
   end,
}

data:add {
   _type = "base.mef",
   _id = "mist",
   elona_id = 2,

   image = "elona.mef_mist"
}

local function proc_mist(chara, params, result)
   local mef = Mef.at(params.target.x, params.target.y)
   if mef and mef._id == "elona.mist" and Rand.one_in(2) then
      Gui.mes_visible("mef.attacks_illusion_in_mist", chara.x, chara.y, chara)
      result.blocked = true
   end
   return result
end

Event.register("elona.before_physical_attack", "Chance to fail attack if standing in mist", proc_mist)

data:add {
   _type = "base.mef",
   _id = "acid",
   elona_id = 3,

   image = "elona.mef_acid",

   on_stepped_on = function(self, params)
      local chara = params.chara

      if SkillCheck.is_floating(chara) then
         return
      end

      if chara:resist_level("elona.acid") / 50 >= 7 then
         return
      end

      if chara:is_in_fov() then
         Gui.play_sound("base.water2", self.x, self.y)
         Gui.mes("mef.melts", chara)
      end

      if self.origin and self.origin:is_player() and not chara:is_player() then
         self.origin:act_hostile_towards(chara)
      end
      local damage = Rand.rnd(self.power / 25 + 5) + 1
      chara:damage_hp(damage, "elona.mef_acid", { element = "elona.acid", element_power = self.power })
      if not Chara.is_alive(chara) then
         Effect.on_kill(self.origin, chara)
      end
   end,
}

data:add {
   _type = "base.mef",
   _id = "ether",
   elona_id = 4,

   image = "elona.mef_ether",
}

data:add {
   _type = "base.mef",
   _id = "fire",
   elona_id = 5,

   image = "elona.mef_fire",

   -- TODO check if tile is water, if so do not place

   on_updated = function(self, params)
      local map = self:current_map()
      if map == nil or Map.is_world_map(map) or map:calc("is_indoor") then
         return
      end

      -- TODO weather: rain

      local spread_count = 0

      if Rand.one_in(35) then
         spread_count = 3
         local player = Chara.player()
         if Pos.dist(self.x, self.y, player.x, player.y) < 6 then
            Gui.play_sound("base.fire1", self.x, self.y)
         end
      end

      for i = 1, spread_count do
         local x = self.x + Rand.rnd(2) - Rand.rnd(2)
         local y = self.y + Rand.rnd(2) - Rand.rnd(2)
         if map:is_in_bounds(x, y) then
            if map:is_floor(x, y) then
               local duration = Rand.rnd(15) + 20
               Mef.create("elona.fire", x, y, { origin = self.origin, duration = duration, power = 50 } )
               Effect.damage_map_fire(x, y, self.origin)
            else
               -- Destroy walls.
               map:set_tile(x, y, "elona.destroyed")
            end
         end
      end
   end,

   on_stepped_on = function(self, params)
      local chara = params.chara
      if chara:is_in_fov() then
         Gui.play_sound("base.fire1", self.x, self.y)
         Gui.mes("mef.is_burnt", chara)
      end

      if self.origin and self.origin:is_player() and not chara:is_player() then
         self.origin:act_hostile_towards(chara)
      end
      local damage = Rand.rnd(self.power / 15 + 5) + 1
      chara:damage_hp(damage, "elona.mef_fire", { element = "elona.fire", element_power = self.power })
      if not Chara.is_alive(chara) then
         Effect.on_kill(self.origin, chara)
      end
   end,

   events = {
      {
         id = "base.on_mef_instantiated",
         name = "Remove if tile is water",
         callback = function(self)
            local map = self:current_map()
            if map == nil then
               return
            end

            local tile = map:tile(self.x, self.y)
            if tile.kind == Enum.TileRole.Water then
               self:remove_ownership()
            end
         end
      }
   }
}

data:add {
   _type = "base.mef",
   _id = "potion",
   elona_id = 6,

   image = "elona.mef_potion",

   params = {
      item_id = "string",
      curse_state = "string"
   },

   on_stepped_on = function(self, params)
      local chara = params.chara

      if SkillCheck.is_floating(chara) then
         return
      end

      if chara:is_in_fov() then
         Gui.play_sound("base.fire1", self.x, self.y)
         Gui.mes("mef.steps_in_pool", chara)
      end

      Effect.get_wet(chara, 25)

      if self.origin and self.origin:is_player() and not chara:is_player() then
         self.origin:act_hostile_towards(chara)
      end

      local item_data = data["base.item"]:ensure(self.item_id)
      if item_data.on_drink then
         local params = {
            chara = chara,
            curse_state = self.curse_state,
            triggered_by = "potion_spilt"
         }
         item_data.on_drink(nil, params)
      else
         Log.warn("Potion mef '%s' missing 'on_drink' callback", self.item_id)
      end

      if not Chara.is_alive(chara) then
         Effect.on_kill(self.origin, chara)
      end

      self:remove_ownership()
   end,
}

data:add {
   _type = "base.mef",
   _id = "nuke",
   elona_id = 7,

   image = "elona.mef_web",

   on_updated = function(self, params)
      Gui.mes_c("action.use.nuke.countdown", "Red", self.turns)
   end,

   on_removed = function(self, params)
      Gui.mes("Nuke effect.")
   end
}
