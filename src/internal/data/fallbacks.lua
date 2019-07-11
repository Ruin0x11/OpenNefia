-- data that has to exist for no errors to occur
local data = require("internal.data")

local Resolver = require("api.Resolver")

data:add_multi(
   "base.event",
   {
      {
         _id = "before_handle_self_event"
      },
      {
         _id = "before_ai_decide_action"
      },
      {
         _id = "after_chara_damaged",
      },
      {
         _id = "on_calc_damage"
      },
      {
         _id = "after_damage_hp",
      },
      {
         _id = "on_player_bumped_into_chara",
      },
      {
         _id = "before_player_map_leave"
      },
      {
         _id = "on_player_bumped_into_object"
      },
      {
         _id = "before_chara_moved"
      },
      {
         _id = "on_chara_moved"
      },
      {
         _id = "on_chara_hostile_action",
      },
      {
         _id = "on_chara_killed",
      },
      {
         _id = "on_calc_kill_exp"
      },
      {
         _id = "on_chara_turn_end"
      },
      {
         _id = "before_chara_turn_start"
      },
      {
         _id = "on_chara_pass_turn"
      },
      {
         _id = "on_game_initialize"
      },
      {
         _id = "on_map_generated"
      },
      {
         _id = "on_map_loaded"
      },
      {
         _id = "on_proc_status_effect"
      },
      {
         _id = "on_object_instantiated"
      },
      {
         _id = "on_chara_instantiated"
      },
      {
         _id = "on_item_instantiated"
      },
      {
         _id = "on_feat_instantiated"
      },
      {
         _id = "on_apply_status_effect"
      },
      {
         _id = "on_chara_revived",
      },
      {
         _id = "on_talk",
      },
      {
         _id = "on_calc_chara_equipment_stats",
      }
   }
)

data:add {
   _type = "base.map_tile",
   _id = "floor",

   is_solid = false,
   is_opaque = false,

   image = "mod/base/graphic/map_tile/floor.png"
}

data:add {
   _type = "base.class",
   _id = "debugger",

   ordering = 0,
   item_type = 1,
   is_extra = true,
   equipment_type = 1,

   on_generate = function(self)
      for _, stat in data["base.stat"]:iter() do
         self.stats[stat._id] = 50
      end
   end,
}


data:add {
   _type = "base.resolver",
   _id = "race",

   ordering = 100000,
   method = "add",
   invariants = { race = "string" },

   resolve = function(self, params)
      local race = data["base.race"][self.race or params.chara.race or ""]
      if not race then
         return {}
      end
      return Resolver.resolve(race.copy_to_chara, params)
   end
}

data:add {
   _type = "base.resolver",
   _id = "class",

   ordering = 200000,
   method = "add",
   invariants = { class = "string" },

   resolve = function(self, params)
      local class = data["base.class"][self.class or params.chara.class or ""]
      if not class then
         return {}
      end
      return Resolver.resolve(class.copy_to_chara, params)
   end
}
