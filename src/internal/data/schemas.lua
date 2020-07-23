local schema = require("thirdparty.schema")
local data = require("internal.data")
local Doc = require("api.Doc")
local CodeGenerator = require("api.CodeGenerator")

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
local IMef = require("api.mef.IMef")

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
         {
            name = "level",
            default = 1,
            template = true,
            doc = [[
Relative strength of this character.
]]
         },
         {
            name = "ai_move",
            default = 100,
            doc = [[
Chance this unit will take an idle action if they have no target.
]]
         },
         {
            name = "ai_dist",
            default = 1,
            doc = [[
Minimum distance before this unit starts moving toward their target.
]]
         },
         {
            name = "ai_calm",
            default = 1,
            doc = [[
Controls the default AI's idle behavior.
]]
         },
         {
            name = "ai_act_sub_freq",
            default = 0,
         },
         {
            name = "portrait",
            default = nil,
            type = "base.portrait",
            doc = [[
Portrait displayed when conversing with this character.

Remove this to use the character's sprite instead.
]]
         },
         {
            name = "resistances",
            default = {},
         },
         {
            name = "item_type",
            default = 0,
            doc = [[
The kind of item this character drops on death.
]]
         },
         {
            name = "tags",
            default = {},
            doc = [[
A list of strings used for filtering during character generation.
]]
         },
         {
            name = "can_talk",
            default = false,
            doc = [[
If true, you can talk to this character by bumping into them.
]]
         },
         {
            name = "faction",
            default = "base.enemy",
            template = true,
            type = "id:base.faction",
            doc = [[
What alignment this character has.

This determines if it will act hostile toward the player on first sight.
- base.enemy: hostile towards the player
- base.citizen: shopkeepers, etc.
- base.neutral: ignores the player, can swap places with them
- base.friendly: acts like an ally
]]
         },
         {
            name = "race",
            default = "elona.slime",
            template = true,
            type = "id:base.race",
            doc = [[
The race of this character.
]]
         },
         {
            name = "class",
            default = "elona.predator",
            template = true,
            type = "id:base.class",
            doc = [[
The class of this character.
]]
         },
         {
            name = "image",
            default = "elona.chara_race_slime",
            template = true,
            type = "id:base.chip",
            doc = [[
The character's image. Can be nil to use the race's default image.
]]
         },
         {
            name = "male_image",
            default = nil,
            type = "base.chip",
            doc = [[
The character's male image. Can be nil to use the race's default image.
]]
         },
         {
            name = "female_image",
            default = nil,
            type = "base.chip",
            doc = [[
The character's female image. Can be nil to use the race's default image.
]]
         },
         {
            name = "gender",
            default = "female",
            type = "string",
            doc = [[
The character's gender, either "male" or "female".
]]
         },
         {
            name = "fixlv",
            default = nil
         },
         {
            name = "fltselect",
            default = 0
         },
         {
            name = "rarity",
            default = 0,
            template = true,
            doc = [[
Variable affecting the chance this character is generated.
]]
         },
         {
            name = "coefficient",
            default = 0,
            template = true,
            doc = [[
Variable affecting the chance this character is generated.
]]
         },
         {
            name = "dialog",
            default = nil,
            type = "elona_sys.dialog",
            doc = [[
Dialog tree to run upon bumping into this character.

The character must have `can_talk` set to `true` for this to trigger.
]]
         },
         {
            name = "cspecialeq",
            default = nil
         },
         eqweapon1 = {
            default = nil
         },
         {
            name = "creaturepack",
            default = nil
         },
         {
            name = "flags",
            default = {}
         },
         {
            name = "on_eat_corpse",
            default = nil,
            type = "function(IItem, {chara=IChara})",
               doc = [[
A callback to be run when this character's corpse is eaten.
   ]]
         },
         {
            name = "events",
            default = nil,
            type = "table",
            doc = [[
List of events to bind to this character when they are spawned.
]]
         },
         {
            name = "category",
            default = nil,
            type = "number"
         },
         {
            name = "color",
            default = nil,
            type = "{int,int,int}",
            doc = [[
Color to display on the character's sprite.
]]
         },
         {
            name = "is_unique",
            default = false
         },
         {
            name = "drops",
            default = nil,
            type = "table",
         },
         {
            name = "ai",
            default = "elona.elona_default_ai",
            type = "base.ai_action",
            doc = [[
AI callback to run on this character's turn.
]]
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
         equipment_weight = 0,
         critical_rate = 0,
         fov = 15,
         time_this_turn = 0,
         turns_alive = 0,
         insanity = 0,
         armor_class = "",
         direction = "South",
         piety = 0,

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

         melee_style = nil,
         cast_style = nil,

         ether_disease_corruption = 0,
         ether_disease_speed = 0,

         roles = {},

         drawables = {},

         x_offset = nil,
         y_offset = nil,

         materials = {},
         spell_stocks = {},

         feats_acquirable = 0,
         traits = {},

         absorbed_charges = 0,

         emotion_icon = nil,
         emotion_icon_turns = 0,

         god = nil,
         prayer_charge = 0
      }
   },
   { interface = IChara }
)

data:add_type(
   {
      name = "item",
      fields = {
         {
            name = "level",
            default = 1,
            type = "number",
            template = true,
            doc = [[
Relative strength of this item.
]]
         },
         {
            name = "weight",
            default = 0,
            type = "number",
            template = true
         },
         {
            name = "value",
            default = 0,
            type = "number",
            template = true
         },
         {
            name = "dv",
            default = 0,
            type = "number",
            doc = [[
DV of this item. Applies if it is equipment.
]]
         },
         {
            name = "pv",
            type = "number",
            default = 0
         },
         {
            name = "dice_x",
            type = "number",
            default = 0
         },
         {
            name = "dice_y",
            type = "number",
            default = 0
         },
         {
            name = "hit_bonus",
            type = "number",
            default = 0
         },
         {
            name = "damage_bonus",
            type = "number",
            default = 0
         },
         {
            name = "color",
            default = nil,
            type = "table?"
         },
         {
            name = "image",
            default = "",
            template = true,
            type = "base.chip",
            doc = [[
The item's image.
]]
         },
         {
            name = "rarity",
            default = 1000000,
            type = "uint",
            template = true,
            doc = [[
Variable affecting the chance this item is generated.
]]
         },
         {
            name = "coefficient",
            default = 100,
            type = "uint",
            template = true,
            doc = [[
Variable affecting the chance this item is generated.
]]
         },
         {
            name = "flags",
            type = "table",
            default = {}
         },
         {
            name = "params",
            type = "table",
            default = {}
         },
         {
            name = "categories",
            default = {},
            type = "table",
            template = true
         },
         {
            name = "equip_slots",
            default = {},
            type = "table",
            template = true
         },
         {
            name = "on_read",
            default = nil,
            type = "function(IItem,IChara)?"
         },
         {
            name = "on_zap",
            default = nil,
            type = "function(IItem,IChara)?"
         },
         {
            name = "on_eat",
            default = nil,
            type = "function(IItem,IChara)?"
         },
         {
            name = "on_drink",
            default = nil,
            type = "function(IItem,IChara)?"
         },
         {
            name = "fltselect",
            default = nil,
            type = "number?"
         },
         {
            name = "tags",
            default = {},
            template = true,
            doc = [[
A list of strings used for filtering during item generation.
]]
         },
         originalnameref2 = {
            default = nil,
            type = "string?"
         },
         {
            name = "count",
            default = nil,
            type = "number?"
         },
         {
            name = "charges",
            default = nil,
            type = "number?"
         },
         {
            name = "has_charge",
            default = nil,
            type = "boolean"
         },
         {
            name = "charge_level",
            default = nil,
            type = "number?"
         },
         {
            name = "gods",
            default = {},
            doc = [[
What gods this item can be offered to.
]]
         },
         {
            name = "enchantments",
            default = nil,
            type = "table?",
         },
         {
            name = "fixlv",
            default = nil,
            type = "string?"
         },
         {
            name = "identify_difficulty",
            default = 0,
            type = "string?"
         },
         {
            name = "is_precious",
            default = nil,
            type = "boolean"
         },
         {
            name = "skill",
            default = nil,
            type = "base.skill?"
         },
         {
            name = "material",
            default = nil,
            type = "number?"
         },
         {
            name = "effective_range",
            default = {100, 20, 20, 20, 20, 20, 20, 20, 20, 20},
            type = "table"
         },
         {
            name = "pierce_rate",
            default = 0,
            type = "number"
         },
         {
            name = "events",
            default = nil,
            type = "table?",
            doc = [[
List of events to bind to this item when it is spawned.
]]
         },
         {
            name = "is_light_source",
            default = false,
            doc = [[
If true, lights up dungeons if in the player's inventory.
]]
         },
         {
            name = "light",
            default = nil,
            type = "table?",
            doc = [[
Ambient light information.
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
         params = {},

         cargo_weight = 0,

         is_melee_weapon = nil,
         is_ranged_weapon = nil,
         x_offset = nil,
         y_offset = nil,
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
      name = "mef",
      fields = {
      },
      fallbacks = {
      }
   },
   { interface = IMef }
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
   fields = {
      {
         name = "type",
         default = "effect",
         template = true,
         doc = [[
Determines how this skill is treated in the interface. Available options:

- "skill": Only viewable in the player's skills list in the character sheet. (default)
- "spell": Castable from the player's Spells menu.
- "action": Useable from the player's Skills menu.
]]
      },
      {
         name = "effect_id",
         default = nil,
         template = true,
         doc = [[
The related magic of this skill to trigger when its entry in the menu is selected.

*Required* if the skill's `type` is "spell" or "action".
]]
      },
      {
         name = "related_skill",
         default = "elona.stat_strength",
         template = true,
         doc = [[
A related skill to improve when this skill is used. Affects the skill's icon in the menus.
]]
      },
      {
         name = "cost",
         default = 10,
         template = true,
         doc = [[
Cost to apply when triggering this skill.

Used only when the skill's `type` is "spell" or "action".
]]
      },
      {
         name = "range",
         default = 0,
         template = true,
         doc = [[
Range of this skill, passed to the magic casting system.

This parameter also affects how the default AI will attempt to use the skill, in
combination with the `target_type` field.

Used only when the skill's `type` is "spell" or "action".
]]
      },
      {
         name = "difficulty",
         default = 100,
         template = true,
         doc = [[
Difficulty of triggering this skill.

Used only when the skill's `type` is "spell" or "action".
]]
      },
      {
         name = "target_type",
         default = "self",
         template = true,
         doc = [[
What target this skill applies to. Available options:

- "self": Only affects the caster
- "self_or_nearby": Can affect the caster or someone nearby, but only if a wand is being used. Fails if no character on tile (heal, holy veil)
- "nearby": Can affect the caster or someone nearby, fails if no character on tile (touch, steal, dissasemble)
- "location": Affects a ground position (web, create wall)
- "target_or_location": Affects the currently targeted character or ground position (breaths, bolts)
- "enemy": Affects the currently targeted character, prompts if friendly (most attack magic)
- "other": Affects the currently targeted character, does not prompt (shadow step)
- "direction": Casts in a cardinal direction (teleport other)

This parameter also affects how the default AI will attempt to use the skill.
For example, the range of the Suicide Attack action is set to "nearby" in order
to ensure the AI is right next to its target before exploding.

Used only when the skill's `type` is "spell" or "action".
]]
      },
   }
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
      {
         name = "on_game_begin",
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
   fields = {
      {
         name = "overrides",
         default = {},
         template = true,
      }
   }
}

data:add_type {
   name = "asset",
   schema = schema.Record {
   },
}

data:add_type {
   name = "chip",
   fields = {
      {
         name = "image",
         default = "mod/<mod_id>/graphic/image.png",
         template = true,
         type = "string|{source=string,x=int,y=int,width=int,height=int,count_x=int?,count_y=int?,key_color={int,int,int}?}",
         doc = [[
The image to use for this chip.

It can either be a string referencing an image file, or a table with these contents:
- source: file containing a larger chip atlas to use.
- x: x position of the chip on the atlas.
- y: y position of the chip on the atlas.
- width: width of one animation frame.
- height: height of one animation frame.
- count_x: animation frames in the x direction. This is multiplied by width for the total width.
- count_y: animation frames in the y direction. This is multiplied by height for the total height.
- key_color: if `source` is a BMP, controls the color to convert to transparency. Defaults to {0, 0, 0}.
]]
      },
      {
         name = "y_offset",
         default = 0,
         template = true,
         doc = [[
Y offset of the sprite in pixels.
         ]]
      }
   }
}

data:add_type {
   name = "asset",
   schema = schema.Record {
      target = schema.String,
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
   fields = {
      {
         name = "act",
         default = CodeGenerator.gen_literal [[
function(chara, params)
      return true
   end]],
         template = true,
         type = "function(IChara,table)",
doc = [[
   Runs arbitrary AI actions. Is passed the character and extra parameters, differing depending on the action.

   Returns true if the character acted, false if not.
]]
      }
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

data:add_type {
   name = "map_template",
   schema = schema.Record {
      map = schema.String,
      copy = schema.Optional(schema.Table),
      areas = schema.Optional(schema.Table),
      on_generate = schema.Optional(schema.Function),
   },
   fields = {
      {
         name = "copy",
         default = {},
         template = true,
         type = "table",
         doc = [[
List of fields to copy to the map when it is instantiated.
]]
      },
      {
         name = "areas",
         default = nil,
         template = false,
         type = "table",
         doc = [[
List of map entrances to other maps contained in this map.
]]
      },
   }
}
