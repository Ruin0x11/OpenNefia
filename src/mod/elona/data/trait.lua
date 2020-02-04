-- TODO categories need to be corrected

local trait = {
   {
      _id = "desire_for_violence",
      elona_id = 207,
      category = "feat",

      on_refresh = function(self, chara)
         local dv_delta = -(15 + math.floor(chara:calc("level") * 3 / 2))
         chara:mod("dv", dv_delta, "add")
      end
   },
   {
      _id = "opatos",
      elona_id = 164,
      category = "etc"
   },
   {
      _id = "long_distance_runner",
      elona_id = 24,
      category = "feat"
   },
   {
      _id = "extra_bonus_points",
      elona_id = 154,
      category = "feat"
   },
   {
      _id = "extra_body_parts",
      elona_id = 0,
      category = "race"
   },
   {
      _id = "weight_lifting",
      elona_id = 201,
      category = "feat"
   },
   {
      _id = "weight_lifting_2",
      elona_id = 205,
      category = "feat",

      on_refresh = function(self, chara)
         chara:mod("is_floating", true)
         local speed_delta = 12 + math.floor(chara:calc("level") / 4)
         chara:mod_skill_level("elona.stat_speed", speed_delta, "add")
      end
   },
   {
      _id = "slow_digestion",
      elona_id = 158,
      category = "feat"
   },
   {
      _id = "more_materials",
      elona_id = 159,
      category = "feat"
   },
   {
      _id = "reduce_overcast_damage",
      elona_id = 156,
      category = "feat"
   },
   {
      _id = "slow_ether_disease",
      elona_id = 168,
      category = "feat"
   },
   {
      _id = "magic_resistance",
      elona_id = 153,
      category = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.magic", self.level * 50, "add")
      end
   },
   {
      _id = "fairy_resistances",
      elona_id = 160,
      category = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.magic", 150, "add")
         chara:mod_resist_level("elona.lightning", 100, "add")
         chara:mod_resist_level("elona.darkness", 200, "add")
         chara:mod_resist_level("elona.sound", 50, "add")
         chara:mod_resist_level("elona.chaos", 100, "add")
         chara:mod_resist_level("elona.mind", 200, "add")
         chara:mod_resist_level("elona.nerve", 100, "add")
         chara:mod_resist_level("elona.cold", 100, "add")
      end
   },
   {
      _id = "fairy_equip_restriction",
      elona_id = 161,
      category = "race",

      on_refresh = function(self, chara)
         local dv = chara:calc("dv")
         if dv > 0 then
            dv = math.floor(dv * 125 / 100) + 50
            chara:mod("dv", dv)
         end
      end
   },
   {
      _id = "resist_cold",
      elona_id = 151,
      category = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.cold", self.level * 50, "add")
      end
   },
   {
      _id = "resist_poison",
      elona_id = 152,
      category = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.poison", self.level * 50, "add")
      end
   },
   {
      _id = "resist_darkness",
      elona_id = 155,
      category = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.darkness", self.level * 50, "add")
      end
   },
   {
      _id = "immune_to_dimming",
      elona_id = 157,
      category = "feat"
   },
   {
      _id = "no_guilt",
      elona_id = 162,
      category = "feat"
   },
   {
      _id = "good_person",
      elona_id = 169,
      category = "feat"
   },
   {
      _id = "can_eat_human_flesh",
      elona_id = 41,
      category = "mutation"
   },
   {
      _id = "cures_sanity",
      elona_id = 166,
      category = "race"
   },
   {
      _id = "no_inflict_fear",
      elona_id = 44,
      category = "feat"
   }
}
data:add_multi("base.trait", trait)
