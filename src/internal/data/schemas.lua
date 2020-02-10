local schema = require("thirdparty.schema")
local data = require("internal.data")
local Doc = require("api.Doc")

data:add_type {
   name = "event",
   schema = schema.Record {
      observer = schema.Optional(schema.String)
   },
   on_document = function(dat)
      return Doc.make_ldoc_doc(dat, dat.params, dat.returns)
   end,
   doc = [[
Events that can be fired.
]]
}

local IChara = require("api.chara.IChara")
local IItem = require("api.item.IItem")
local IFeat = require("api.feat.IFeat")
local ITrap = require("api.feat.ITrap")
local IActivity = require("api.activity.IActivity")

data:add_type(
   {
      name = "resource",
      schema = schema.Record {
         type = schema.String,
         value = schema.Any
      }
   }
)

data:add_type(
   {
      name = "chara",
      fields = {
         level = {
            default = 1,
            template = true,
            doc = [[
Relative strength of this character.
]]
         },
         ai_move = {
            default = 100,
            doc = [[
Chance this unit will take an idle action if they have no target.
]]
         },
         ai_dist = {
            default = 1,
            doc = [[
Minimum distance before this unit starts moving toward their target.
]]
         },
         ai_calm = {
            default = 1,
         },
         ai_act_sub_freq = {
            default = 0,
         },
         portrait = {
            default = nil,
            type = "base.portrait"
         },
         resistances = {
            default = {},
         },
         item_type = {
            default = 0,
            doc = [[
The kind of item this character drops on death.
]]
         },
         tags = {
            default = {},
            doc = [[
A list of strings used for filtering during character generation.
]]
         },
         can_talk = {
            default = false
         },
         faction = {
            default = "base.enemy",
            template = true,
            doc = [[
What alignment this character has.

This determines if it will act hostile toward the player on first sight.
]]
         },
         race = {
            default = "base.default",
            template = true,
            doc = [[
The race of this character.
]]
         },
         class = {
            default = "base.default",
            template = true,
            doc = [[
The class of this character.
]]
         },
         image = {
            default = "",
            template = true,
            type = "base.chip",
            doc = [[
The character's image.
]]
         },
         male_image = {
            default = nil,
            type = "base.chip",
         },
         female_image = {
            default = nil,
            type = "base.chip",
         },
         gender = {
            default = "female",
            doc = [[
The character's gender, either male or female.
]]
         },
         fixlv = {
            default = nil
         },
         fltselect = {
            default = 0
         },
         rarity = {
            default = 0,
            template = true,
            doc = [[
Variable affecting the chance this character is generated.
]]
         },
         coefficient = {
            default = 0,
            template = true,
            doc = [[
Variable affecting the chance this character is generated.
]]
         },
         dialog = {
            default = nil,
            type = "elona_sys.dialog",
            doc = [[
Dialog tree to run upon bumping into this character.

The character must have `can_talk` set to `true` for this to trigger.
]]
         },
         cspecialeq = {
            default = nil
         },
         eqweapon1 = {
            default = nil
         },
         creaturepack = {
            default = nil
         },
         flags = {
            default = {}
         },
         on_eat_corpse = {
            default = nil,
            type = "function"
         },
         events = {
            default = nil,
            type = "table",
            doc = [[
List of events to bind to this character when they are spawned.
]]
         },
         category = {
            default = nil,
            type = "number"
         },
         color = {
            default = nil,
            type = "table"
         },
         is_unique = {
            default = false
         },
         drops = {
            default = nil,
            type = "table",
         },
         ai = {
            default = "elona.elona_default_ai",
            type = "base.ai_action"
         }
      },
      fallbacks = {
         state = "Dead",
         name = "",
         title = "",
         max_level = 1,
         experience = 0,
         required_experience = 0,
         sleep_experience = 0,
         fame = 0,
         dv = 0,
         pv = 0,
         hit_bonus = 0,
         damage_bonus = 0,
         curse_power = 0,
         critical_rate = 0,
         fov = 15,
         time_this_turn = 0,
         turns_alive = 0,
         insanity = 0,
         armor_class = "",
         direction = "South",

         gold = 0,
         platinum = 0,
         karma = 0,

         number_of_weapons = 0,
         initial_x = 0,
         initial_y = 0,
         ai_config = {
            min_distance = 1,
            follow_player_when_calm = false,

            on_low_hp = nil,
            on_idle_action = nil
         },

         known_abilities = {},

         hp = 1,
         mp = 1,
         stamina = 1,
         max_hp = 1,
         max_mp = 1,
         max_stamina = 1,

         nutrition = 0;

         pierce_chance = 0,
         physical_damage_reduction = 0,

         is_quest_target = nil,
         was_passed_item = nil,

         date_to_revive_on = 0,

         aquirable_feat_count = 0,
         skill_bonus = 0,
         total_skill_bonus = 0,
         speed_correction = 0,
         current_speed = 0,
         speed_percentage = 0,
         speed_percentage_in_next_turn = 0,
         inventory_weight = 0,
         max_inventory_weight = 0,
         inventory_weight_type = 0,
         cargo_weight = 0,
         max_cargo_weight = 0,
         initial_max_cargo_weight = 0,

         is_temporary = nil,

         height = 0,
         weight = 0,
         personality = 0,
         talk_type = 0,
         interest = 0,
         impression = 0,

         shop_rank = 0,
         shop_restock_date = 0,

         breaks_into_debris = nil,
         is_solid = true,

         anorexia_count = 0,

         melee_attack_type = 0,

         ether_disease_corruption = 0,
         ether_disease_speed = 0,

         roles = {},

         drawables = {}
      }
   },
   { interface = IChara }
)

data:add_type(
   {
      name = "item",
      fields = {
         level = {
            default = 1,
            template = true,
            doc = [[
Relative strength of this item.
]]
         },
         weight = {
            default = 0,
            template = true
         },
         value = {
            default = 0,
            template = true
         },
         dv = {
            default = 0
         },
         pv = {
            default = 0
         },
         dice_x = {
            default = 0
         },
         dice_y = {
            default = 0
         },
         hit_bonus = {
            default = 0
         },
         damage_bonus = {
            default = 0
         },
         color = {
            default = nil,
            type = "table"
         },
         image = {
            default = "",
            template = true,
            type = "base.chip",
            doc = [[
The item's image.
]]
         },
         rarity = {
            default = 1000000,
            template = true,
            doc = [[
Variable affecting the chance this item is generated.
]]
         },
         coefficient = {
            default = 100,
            template = true,
            doc = [[
Variable affecting the chance this item is generated.
]]
         },
         flags = {
            default = {}
         },
         params = {
            default = {}
         },
         categories = {
            default = {},
            template = true
         },
         equip_slots = {
            default = {},
            template = true
         },
         on_read = {
            default = nil,
            type = "function"
         },
         on_zap = {
            default = nil,
            type = "function"
         },
         on_eat = {
            default = nil,
            type = "function"
         },
         on_drink = {
            default = nil,
            type = "function"
         },
         fltselect = {
            default = nil,
            type = "number"
         },
         tags = {
            default = {},
            template = true,
            doc = [[
A list of strings used for filtering during item generation.
]]
         },
         originalnameref2 = {
            default = nil,
            type = "string"
         },
         count = {
            default = nil,
            type = "number"
         },
         has_charge = {
            default = nil,
            type = "boolean"
         },
         chargelevel = {
            default = nil,
            type = "number"
         },
         gods = {
            default = {},
            doc = [[
What gods this item can be offered to.
]]
         },
         enchantments = {
            default = nil,
            type = "table",
         },
         fixlv = {
            default = nil,
            type = "string"
         },
         identify_difficulty = {
            default = nil,
            type = "string"
         },
         is_precious = {
            default = nil,
            type = "boolean"
         },
         skill = {
            default = nil,
            type = "base.skill"
         },
         material = {
            default = nil,
            type = "number"
         },
         effective_range = {
            default = {100, 20, 20, 20, 20, 20, 20, 20, 20, 20},
            type = "table"
         },
         pierce_rate = {
            default = 0,
            type = "number"
         },
         events = {
            default = nil,
            type = "table",
            doc = [[
List of events to bind to this item when it is spawned.
]]
         },
         is_light_source = {
            default = false,
            doc = [[
If true, lights up dungeons if in the player's inventory.
]]
         },
         light = {
            default = nil,
            type = "table",
            doc = [[
Ambient light information. Each one is a table or nil. Same
format as vanilla:
- chip (id:base.chip): chip with animation to play over tile.
- brightness (uint): alpha value of chip animation.
- offset_y (int): offset of chip animation.
- power (int): magnitude of shadow decrease. affected by player
               distance to light.
- flicker (uint): random flicker to add to light. Added as
                  Rand.rnd(flicker + 1).
- always_on (bool): if true, ignore time of day when displaying
                    the light. normally lights are only
                    displayed if 17 < date.hour || date.hour < 6.
]]
         }
      },
      fallbacks = {
         amount = 1,
         ownership = "none",
         curse_state = "none",
         identify_state = "completely",
         bonus = 0,
         name = "item",
         ammo_type = "",
         value = 1,

         cargo_weight = 0,
      }
   },
   { interface = IItem }
)

data:add_type {
   name = "item_type",
   schema = schema.Record {
      no_generate = schema.Optional(schema.Boolean)
   }
}

data:add_type(
   {
      name = "feat",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         params = schema.Table,
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = IFeat }
)

data:add_type(
   {
      name = "trap",
      schema = schema.Record {
         name = schema.String,
         image = schema.Number,
         params = schema.Table,
         on_instantiate = schema.Optional(schema.Function),
      },
   },
   { interface = ITrap }
)

data:add_type(
   {
      name = "class",
      schema = schema.Record {
         on_generate = schema.Optional(schema.Function),
      },
   }
)

data:add_type(
   {
      name = "race",
      schema = schema.Record {
      },
   }
)

data:add_type(
   {
      name = "element",
      schema = schema.Record {
      },
   }
)

data:add_type{
   name = "effect",
   schema = {
      indicator = schema.Function,
   }
}

data:add_type(
   {
      name = "activity",
      schema = {
      },
   },
   { interface = IActivity }
)

data:add_type(
   {
      name = "map",
      schema = schema.Record {
         name = schema.String
      },
   }
)

data:add_type {
   name = "body_part",
   schema = schema.Record {
      name = schema.String,
      icon = schema.Number -- TODO: needs to be themable
   }
}

data:add_type {
   name = "map_tile",
   schema = schema.Record {
      image = schema.Number,
      is_solid = schema.Boolean,
   },
}

data:add_type {
   name = "enchantment",
   schema = schema.Record {
      item_method = schema.String,
      item = schema.Table,
      wielder_method = schema.String,
      wielder = schema.Table,
      orientation = schema.String,
   },
}

data:add_type {
   name = "stat",
   schema = schema.Record {
   },
}

data:add_type {
   name = "skill",
   schema = schema.Record {
      is_main_skill = schema.Boolean
   },
}

data:add_type {
   name = "magic",
   schema = schema.Record {
   },
}

data:add_type {
   name = "trait",
   schema = schema.Record {
   },
}

data:add_type {
   name = "sound",
   schema = schema.Record {
      file = schema.String
   },
}

data:add_type {
   name = "music",
   schema = schema.Record {
      file = schema.String
   },
}

data:add_type {
   name = "ui_indicator",
   schema = schema.Record {
      indicator = schema.Function
   },
}

data:add_type(
   {
      name = "resolver",
      schema = schema.Record {
         invariants = schema.Table,
         params = schema.Table,
         resolve = schema.Function,
      },
   }
)

data:add_type {
   name = "scenario",
   fields = {
      on_game_begin = {
         default = nil,
         template = true,
         type = "function(self,IChara)",
         doc = [[
Function called on game begin. Is passed the created player.
]]
      },
   }
}

data:add_type {
   name = "theme",
   schema = schema.Record {
      target = schema.Optional(schema.String),
      assets = schema.Table,
   },
}

data:add_type {
   name = "chip",
   schema = schema.Record {
   },
}

data:add_type {
   name = "asset",
   schema = schema.Record {
      target = schema.String,
   }
}

data:add_type {
   name = "map_generator",
   schema = schema.Record {
      generate = schema.Function,
   }
}

data:add_type {
   name = "faction",
   schema = schema.Record {
      reactions = schema.Table,
   },
}

data:add_type {
   name = "ai_action",
   schema = schema.Record {
      act = schema.Function
   }
}

data:add_type {
   name = "talk",
   schema = schema.Record {
      messages = schema.Table
   }
}

data:add_type {
   name = "talk_event",
   schema = schema.Record {
      params = schema.Table
   }
}

data:add_type {
   name = "portrait",
   schema = schema.Record {
      image = schema.String
   }
}

data:add_type {
   name = "config_option_boolean",
   schema = schema.Record {
      default = schema.Boolean,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_choice",
   schema = schema.Record {
      choices = schema.Table,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_number",
   schema = schema.Record {
      max = schema.Number,
      min = schema.Number,
      default = schema.Number,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_string",
   schema = schema.Record {
      max_length = schema.Number,
      min_length = schema.Number,
      default = schema.String,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_option_file",
   schema = schema.Record {
      default = schema.Optional(schema.String),
      on_generate = schema.Optional(schema.Function),
      on_validate_file = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_menu",
   schema = schema.Record {
      options = schema.Table,
      on_generate = schema.Optional(schema.Function),
   }
}

data:add_type {
   name = "config_custom_menu",
   schema = schema.Record {
      require_path = schema.String,
      options = schema.Table
   }
}

data:add_type {
   name = "keybind",
   schema = schema.Record {
      default = schema.String
   }
}

data:add_type {
   name = "pcc_part",
   schema = schema.Record {
      kind = schema.String,
      image = schema.String
   }
}

data:add_type {
   name = "map_entrance",
   schema = schema.Record {
      pos = schema.Function
   }
}
