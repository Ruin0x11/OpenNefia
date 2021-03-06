local Material = require("mod.elona.api.Material")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")

data:add_type {
   name = "material_spot",
   fields = {
      {
         name = "on_finish",
         type = "locale_key",
         default = nil,
      },
      {
         name = "materials",
         type = "table",
         default = {},
         template = true
      }
   }
}

local function try_get_spot_info(feat, property)
   local mat_spot_info = feat.params.material_spot_info
   if mat_spot_info then
      local info = data["elona.material_spot_feat_info"]:ensure(mat_spot_info)
      if info[property] then
         return info[property]
      end
   end
   return nil
end

data:add {
   _type = "base.feat",
   _id = "material_spot",

   is_solid = false,
   is_opaque = false,

   params = { material_spot_info = "string" },

   on_search = function(self, params)
      local chara = params.chara

      chara:start_activity("elona.searching", {feat=self})

      return "turn_end", "blocked"
   end,

   events = {
      {
         id = "base.on_build_feat",
         name = "Randomize image",

         callback = function(self)
            -- >>>>>>>> shade2/map_func.hsp:843 		cell_featSet x,y,tile_RE@+rnd(3),objRE ...
            local images = {
               "elona.feat_material_dig",
               "elona.feat_material_gem",
               "elona.feat_material_wood",
            }

            self.image = try_get_spot_info(self, "image") or Rand.choice(images)
            -- <<<<<<<< shade2/map_func.hsp:843 		cell_featSet x,y,tile_RE@+rnd(3),objRE ..
         end
      },
      {
         id = "elona.on_feat_calc_materials",
         name = "Material spot on_calc_materials handler",

         callback = function(self, params, result)
            local on_calc_materials = try_get_spot_info(self, "on_calc_materials")
            if on_calc_materials then
               print("GO")
               return on_calc_materials(self, params, result)
            end
         end
      }
   }
}

data:add_type {
   name = "material_spot_feat_info",

   fields = {
      {
         name = "auto_turn_anim",
         type = "id:base.auto_turn_anim",
         default = "base.searching",
         template = true
      },
      {
         name = "activity_name",
         type = "locale_key",
         default = "activity._.elona.searching.verb",
         template = true
      },
      {
         name = "activity_animation_wait",
         type = "number",
         default = 15,
         template = true
      },
      {
         name = "activity_default_turns",
         type = "integer",
         default = 20,
         template = true
      },
      {
         name = "image",
         type = "id:base.chip?",
         default = nil,
         template = true
      },
      {
         name = "material_spot_type",
         type = "id:elona.material_spot?",
         default = nil,
         template = true
      },
      {
         name = "on_start_gather_text",
         type = "locale_key",
         default = "activity.dig_spot.start.other",
         template = true
      },
      {
         name = "on_start_gather_sound",
         type = "id:base.sound?",
         default = nil,
      },
      {
         name = "on_gather_sound_text",
         type = "locale_key?",
         default = nil,
      },
      {
         name = "on_gather_no_more_text",
         type = "locale_key",
         default = "activity.material.searching.no_more",
         template = true
      },
   }
}

-- The reason all of this is so janky is because in vanilla, the activity for
-- searching material spots was hacked on top of the *regular* activities for
-- things like the fishing skill, mining walls, or digging for treasure in the
-- world map. A global flag was set each turn to indicate if the activity
-- counted as a material searching activity or the regular one. This was a
-- terrible way of doing things. Now all the material harvesting has been
-- extracted into its own activity, where all the logic is shared. But
-- everything that was originally tied to the activities has to be put somewhere
-- else, like the activity's name and auto turn animation. For now they're
-- placed inside some metadata of type `elona.material_spot_feat_info`, and
-- looked up inside the `elona.searching` activity.

data:add {
   _type = "elona.material_spot_feat_info",
   _id = "default",

   -- >>>>>>>> shade2/action.hsp:1546 		if feat(1)=objREremain	:call search ...
   activity_auto_turn_anim = "base.searching",
   -- <<<<<<<< shade2/action.hsp:1546 		if feat(1)=objREremain	:call search ..

   -- >>>>>>>> shade2/proc.hsp:1007 		if cTurn(cc)¥5=0:txtActDigging ...
   on_gather_sound_text = "activity.dig_spot.sound",
   -- <<<<<<<< shade2/proc.hsp:1007 		if cTurn(cc)¥5=0:txtActDigging ..

   -- >>>>>>>> shade2/proc.hsp:997 		cRowAct(cc)=rowActSearch ...
   activity_name = "activity._.elona.searching.verb",
   activity_default_turns = 20,
   activity_animation_wait = 15,
   on_start_gather_text = "activity.dig_spot.start.other",
   -- <<<<<<<< shade2/proc.hsp:999 		if rowActRE=false:txt lang("地面を掘り始めた。","You star ..
}

data:add {
   _type = "elona.material_spot_feat_info",
   _id = "remains",

   -- >>>>>>>> shade2/map_func.hsp:828 			cell_featSet x,y,243,objREremain ...
   image = "elona.feat_material_crafting",
   -- <<<<<<<< shade2/map_func.hsp:828 			cell_featSet x,y,243,objREremain ..

   -- >>>>>>>> shade2/action.hsp:1546 		if feat(1)=objREremain	:call search ...
   activity_auto_turn_anim = "base.searching",
   -- <<<<<<<< shade2/action.hsp:1546 		if feat(1)=objREremain	:call search ..

   -- >>>>>>>> shade2/proc.hsp:997 		cRowAct(cc)=rowActSearch ...
   activity_name = "activity._.elona.searching.verb",
   activity_default_turns = 20,
   activity_animation_wait = 15,
   on_start_gather_text = "activity.dig_spot.start.other",
   -- <<<<<<<< shade2/proc.hsp:999 		if rowActRE=false:txt lang("地面を掘り始めた。","You star ..

   -- >>>>>>>> shade2/proc.hsp:1007 		if cTurn(cc)¥5=0:txtActDigging ...
   on_gather_sound_text = "activity.dig_spot.sound",
   -- <<<<<<<< shade2/proc.hsp:1007 		if cTurn(cc)¥5=0:txtActDigging ..

   -- >>>>>>>> shade2/proc.hsp:32 	if feat(1)=objREremain	:atxLv+=sAnatomy(pc)/3 ...
   on_calc_materials = function(self, params, result)
      result.level = math.floor(result.level + params.chara:skill_level("elona.anatomy") / 3)
      return result
   end
   -- <<<<<<<< shade2/proc.hsp:32 	if feat(1)=objREremain	:atxLv+=sAnatomy(pc)/3 ..
}

data:add {
   _type = "elona.material_spot_feat_info",
   _id = "spring",

   -- >>>>>>>> shade2/map_func.hsp:836 			cell_featSet x,y,245,objREspring ...
   image = "elona.feat_material_fish",
   -- <<<<<<<< shade2/map_func.hsp:836 			cell_featSet x,y,245,objREspring ..

   -- >>>>>>>> shade2/action.hsp:1547 		if feat(1)=objREspring	:call fishing ...
   activity_auto_turn_anim = "base.fishing",
   -- <<<<<<<< shade2/action.hsp:1547 		if feat(1)=objREspring	:call fishing ..

   -- >>>>>>>> shade2/proc.hsp:33 	if feat(1)=objREspring	:atxSpot=atxWater1 ...
   material_spot_type = "elona.water",
   -- <<<<<<<< shade2/proc.hsp:33 	if feat(1)=objREspring	:atxSpot=atxWater1 ..

   -- >>>>>>>> shade2/proc.hsp:887 		txt lang("釣りを始めた。","You start fishing.") ...
   activity_name = "activity._.elona.fishing.verb",
   activity_default_turns = 100,
   activity_animation_wait = 40,
   on_start_gather_text = "activity.fishing.start",
   on_start_gather_sound = "base.fish_cast",
   -- <<<<<<<< shade2/proc.hsp:890 		cRowAct(cc)=rowActFish ..

   -- >>>>>>>> shade2/proc.hsp:57 		if feat(1)=objREspring	:s=lang("泉は干上がった。","The s ...
   on_gather_no_more_text = "activity.material.fishing.no_more"
   -- <<<<<<<< shade2/proc.hsp:57 		if feat(1)=objREspring	:s=lang("泉は干上がった。","The s ..
}

data:add {
   _type = "elona.material_spot_feat_info",
   _id = "mine",

   -- >>>>>>>> shade2/map_func.hsp:832 			cell_featSet x,y,244,objREmine ...
   image = "elona.feat_material_mine",
   -- <<<<<<<< shade2/map_func.hsp:832 			cell_featSet x,y,244,objREmine ..

   -- >>>>>>>> shade2/action.hsp:1548 		if feat(1)=objREmine	:call dig ...
   activity_auto_turn_anim = "base.mining",
   -- <<<<<<<< shade2/action.hsp:1548 		if feat(1)=objREmine	:call dig ..

   -- >>>>>>>> shade2/proc.hsp:34 	if feat(1)=objREmine	:atxSpot=atxMine1 ...
   material_spot_type = "elona.mine",
   -- <<<<<<<< shade2/proc.hsp:34 	if feat(1)=objREmine	:atxSpot=atxMine1 ..

   -- >>>>>>>> shade2/proc.hsp:1042 		cRowAct(cc)=rowActDig ...
   activity_name = "activity._.elona.mining.verb",
   activity_default_turns = 40,
   activity_animation_wait = 15,
   on_start_gather_text ="activity.dig_mining.start.spot",
   -- <<<<<<<< shade2/proc.hsp:1044 		if rowActRE=false:txt lang("壁を掘りはじめた。","You star ..

   -- >>>>>>>> shade2/proc.hsp:1098 			if cTurn(cc)¥5=0:txtActDigging ...
   on_gather_sound_text = "activity.dig_spot.sound",
   -- <<<<<<<< shade2/proc.hsp:1098 			if cTurn(cc)¥5=0:txtActDigging ..

   -- >>>>>>>> shade2/proc.hsp:58 		if feat(1)=objREmine	:s=lang("鉱石を掘りつくした。","There ...
   on_gather_no_more_text = "activity.material.digging.no_more"
   -- <<<<<<<< shade2/proc.hsp:58 		if feat(1)=objREmine	:s=lang("鉱石を掘りつくした。","There ..
}

data:add {
   _type = "elona.material_spot_feat_info",
   _id = "bush",

   -- >>>>>>>> shade2/map_func.hsp:840 			cell_featSet x,y,246,objREbush ...
   image = "elona.feat_material_plant",
   -- <<<<<<<< shade2/map_func.hsp:840 			cell_featSet x,y,246,objREbush ..

   -- >>>>>>>> shade2/action.hsp:1549 		if feat(1)=objREbush	:call plant ...
   activity_auto_turn_anim = "base.harvesting",
   -- <<<<<<<< shade2/action.hsp:1549 		if feat(1)=objREbush	:call plant ..

   -- >>>>>>>> shade2/proc.hsp:35 	if feat(1)=objREbush	:atxSpot=atxBush1 ...
   material_spot_type = "elona.bush",
   -- <<<<<<<< shade2/proc.hsp:35 	if feat(1)=objREbush	:atxSpot=atxBush1 ..

   -- >>>>>>>> shade2/proc.hsp:982 		cRowAct(cc)=rowActPlant ...
   activity_name = "activity._.elona.digging_spot.verb",
   activity_default_turns = 40,
   activity_animation_wait = 15,
   on_start_gather_text = "activity.material.start",
   -- <<<<<<<< shade2/proc.hsp:984 		txt lang("採取を始めた。","You start to search the spot ..

   -- >>>>>>>> shade2/proc.hsp:59 		if feat(1)=objREbush	:s=lang("もう目ぼしい植物は見当たらない。", ...
   on_gather_no_more_text = "activity.material.harvesting.no_more"
   -- <<<<<<<< shade2/proc.hsp:59 		if feat(1)=objREbush	:s=lang("もう目ぼしい植物は見当たらない。", ..
}

-- These are special; they can always be found no matter what material spot is
-- being searched.
data:add {
   _type = "elona.material_spot",
   _id = "global",

   materials = {
      "elona.kuzu",
      "elona.casino_chip",
      "elona.coin_1",
      "elona.coin_2",
      "elona.paper",
      "elona.sumi",
      "elona.driftwood",
      "elona.stone",
      "elona.staff",
      "elona.cloth",
      "elona.yellmadman",
      "elona.magic_mass",
      "elona.elec",
      "elona.generate",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "general",

   materials = {
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "dungeon",

   materials = {
      "elona.magic_frag"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "forest",

   materials = {
      "elona.stick",
      "elona.leather",
      "elona.string",
      "elona.tight_wood",
      "elona.crooked_staff"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "field",

   materials = {
      "elona.adhesive",
      "elona.memory_frag",
      "elona.magic_paper",
      "elona.magic_ink"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "building",

   materials = {
      "elona.adhesive",
      "elona.memory_frag",
      "elona.magic_paper",
      "elona.magic_ink",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "water",

   -- >>>>>>>> shade2/proc.hsp:44 		if atxSpot=atxWater1{ ...
   get_verb = "activity.material.get_verb.fish_up",

   on_search = function(chara, feat, level, choices)
      if chara:skill_level("elona.fishing") < Rand.rnd(level * 2 + 1) or Rand.one_in(10) then
         Gui.mes("activity.material.fishing.fails")
         return nil
      end

      Skill.gain_skill_exp(chara, "elona.fishing", 40)

      return Material.random_material_id(level, 1, choices)
   end,
   -- <<<<<<<< shade2/proc.hsp:47 			} ..

   materials = {
      "elona.sea_water",
      "elona.waterdrop",
      "elona.tear_angel",
      "elona.hot_water",
      "elona.tear_witch",
      "elona.snow",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "mine",

   -- >>>>>>>> shade2/proc.hsp:40 		if atxSpot=atxMine1{ ...
   get_verb = "activity.material.get_verb.dig_up",

   on_search = function(chara, feat, level, choices)
      if chara:skill_level("elona.mining") < Rand.rnd(level * 2 + 1) or Rand.one_in(10) then
         Gui.mes("activity.material.digging.fails")
         return nil
      end

      Skill.gain_skill_exp(chara, "elona.mining", 40)

      return Material.random_material_id(level, 1, choices)
   end,
   -- <<<<<<<< shade2/proc.hsp:43 			} ..

   materials = {
      "elona.mithril_frag",
      "elona.steel_frag",
      "elona.fire_stone",
      "elona.ice_stone",
      "elona.elec_stone",
      "elona.good_stone",
      "elona.ether_frag",
      "elona.elem_frag",
      "elona.chaos_stone",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "bush",

   -- >>>>>>>> shade2/proc.hsp:48 		if atxSpot=atxBush1{ ...
   get_verb = "activity.material.get_verb.harvest",

   on_search = function(chara, feat, level, choices)
      if chara:skill_level("elona.gardening") < Rand.rnd(level * 2 + 1) or Rand.one_in(10) then
         Gui.mes("activity.material.searching.fails")
         return nil
      end

      Skill.gain_skill_exp(chara, "elona.gardening", 30)

      return Material.random_material_id(level, 1, choices)
   end,
   -- <<<<<<<< shade2/proc.hsp:51 			} ..

   materials = {
      "elona.plant_1",
      "elona.plant_2",
      "elona.plant_3",
      "elona.plant_4",
      "elona.plant_heal",
      "elona.flying_grass",
      "elona.plant_5",
      "elona.black_myst",
      "elona.sap",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "remains",

   materials = {
      "elona.feather",
      "elona.tail_rabbit",
      "elona.gen_human",
      "elona.tail_bear",
      "elona.gen_troll",
      "elona.eye_witch",
      "elona.fairy_dust",
   }
}
