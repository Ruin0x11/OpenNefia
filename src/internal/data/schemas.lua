local schema = require("thirdparty.schema")
local data = require("internal.data")
local CodeGenerator = require("api.CodeGenerator")
local Enum = require("api.Enum")
local IEventEmitter = require("api.IEventEmitter")

local ty_data_ext_field = types.fields {
   name = types.string,
   type = types.type,
   default = types.any
}

data:add_type {
   name = "data_ext",
   fields = {
      {
         name = "fields",
         template = true,
         type = types.list(ty_data_ext_field),
         default = {}
      }
   }
}

data:add_type {
   name = "event",
   fields = {},
   doc = [[
Events that can be fired.
]]
}

local IChara = require("api.chara.IChara")
local IItem = require("api.item.IItem")
local IFeat = require("api.feat.IFeat")
local IActivity = require("api.activity.IActivity")
local IMef = require("api.mef.IMef")

local ty_event = types.fields {
   id = types.data_id("base.event"),
   name = types.string,
   callback = types.callback("self", types.interface(IEventEmitter), "params", types.table, "result", types.any),
}

local ty_color_value = types.range(types.int, 0, 255)
local ty_color = types.tuple {
   ty_color_value,
   ty_color_value,
   ty_color_value,
   types.optional(ty_color_value),
}
local ty_light = types.fields {
   chip = types.data_id("base.chip"),
   brightness = types.positive(types.number),
   offset_y = types.number,
   power = types.number,
   flicker = types.positive(types.number),
   always_on = types.optional(types.boolean)
}

data:add_type(
   {
      name = "chara",
      fields = {
         {
            name = "level",
            type = types.uint,
            default = 1,
            template = true,
            doc = [[
Relative strength of this character.
]]
         },
         {
            name = "ai_move_chance",
            type = types.uint,
            default = 100,
            doc = [[
Chance this unit will take an idle action if they have no target.
]]
         },
         {
            name = "ai_distance",
            type = types.uint,
            default = 1,
            doc = [[
Minimum distance before this unit starts moving toward their target.
]]
         },
         {
            name = "portrait",
            type = types.optional(types.data_id("base.portrait")),
            default = nil,
            doc = [[
Portrait displayed when conversing with this character.

Remove this to use the character's sprite instead.
]]
         },
         {
            name = "resistances",
            type = types.map(types.data_id("base.resistance"), types.int),
            default = {},
            no_fallback = true
         },
         {
            name = "tags",
            type = types.list(types.string),
            default = {},
            doc = [[
A list of strings used for filtering during character generation.
]]
         },
         {
            name = "can_talk",
            type = types.boolean,
            default = false,
            doc = [[
If true, you can talk to this character by bumping into them.
]]
         },
         {
            name = "relation",
            type = types.enum(Enum.Relation),
            default = Enum.Relation.Enemy,
            template = true,
            doc = [[
What alignment this character has.

This determines if it will act hostile toward the player on first sight.
]]
         },
         {
            name = "race",
            type = types.data_id("base.race"),
            default = "elona.slime",
            template = true,
            doc = [[
The race of this character.
]]
         },
         {
            name = "class",
            type = types.data_id("base.class"),
            default = "elona.predator",
            template = true,
            doc = [[
The class of this character.
]]
         },
         {
            name = "image",
            type = types.optional(types.data_id("base.chip")),
            default = nil,
            template = true,
            doc = [[
The character's image. Can be nil to use the race's default image.
]]
         },
         {
            name = "male_image",
            type = types.optional(types.data_id("base.chip")),
            default = nil,
            doc = [[
The character's male image. Can be nil to use the race's default image.
]]
         },
         {
            name = "female_image",
            type = types.optional(types.data_id("base.chip")),
            default = nil,
            doc = [[
The character's female image. Can be nil to use the race's default image.
]]
         },
         {
            name = "gender",
            type = types.literal("female", "male"), -- TODO allow arbitrary genders
            default = "female",
            no_fallback = true,
            doc = [[
The character's gender, either "male" or "female".
]]
         },
         {
            name = "fltselect",
            type = types.enum(Enum.FltSelect),
            default = Enum.FltSelect.None,
            doc = [[
Determines if the character is spawned in towns, etc.
]]
         },
         {
            name = "rarity",
            type = types.int,
            default = 100000,
            template = true,
            doc = [[
Controls how common this character is.

Increase to make more common; set to 0 to disable random generation entirely.
]]
         },
         {
            name = "coefficient",
            type = types.int,
            default = 400,
            template = true,
            doc = [[
Controls the chance this character will be randomly generated in dungeons with a
large level difference against the character's level.

Higher means a smaller range of dungeon levels the character appears in. Lower
means the character has a greater chance of appearing in both high-level and
low-level dungeons.
]]
         },
         {
            name = "dialog",
            type = types.optional(types.data_id("elona_sys.dialog")),
            default = nil,
            doc = [[
Dialog tree to run upon bumping into this character.

The character must have `can_talk` set to `true` for this to trigger.
]]
         },
         {
            name = "tone",
            type = types.optional(types.data_id("base.tone")),
            default = nil,
            doc = [[
Custom talk tone for this character.

This is for making characters say custom text on certain events.
]]
         },
         {
            -- TODO
            name = "cspecialeq",
            type = types.optional(types.literal(1)),
            default = nil
         },
         {
            -- TODO
            name = "eqweapon1",
            type = types.optional(types.int),
            default = nil
         },
         {
            name = "creaturepack",
            type = types.enum(Enum.CharaCategory),
            default = Enum.CharaCategory.None,
         },
         {
            -- TODO remove
            name = "flags",
            type = types.list(types.string),
            default = {}
         },
         {
            name = "on_eat_corpse",
            type = types.optional(types.callback("corpse", types.map_object("base.item"),
                                                 "params", types.fields { chara = types.map_object("base.chara") })),
            doc = [[
A callback to be run when this character's corpse is eaten.
   ]]
         },
         {
            name = "events",
            default = nil,
            type = types.list(ty_event),
            doc = [[
List of events to bind to this character when they are spawned.
]]
         },
         {
            name = "category",
            type = types.enum(Enum.CharaCategory),
            default = Enum.CharaCategory.None,
         },
         {
            name = "color",
            type = types.optional(ty_color),
            default = nil,
            doc = [[
Color to display on the character's sprite.
]]
         },
         {
            -- TODO
            name = "is_unique",
            type = types.boolean,
            default = false
         },
         {
            name = "ai",
            type = types.data_id("base.ai_action"),
            default = "elona.elona_default_ai",
            doc = [[
AI callback to run on this character's turn.
]]
         },
         {
            name = "damage_reaction",
            type = types.optional(
               types.fields {
                  _id = types.data_id("base.damage_reaction"),
                  power = types.int
               }
            ),
            default = nil,
            doc = [[
A damage reaction to trigger if this character is melee attacked.
]]
         },
         {
            name = "skills",
            type = types.optional(types.list(types.data_id("base.skill"))),
            default = nil,
            no_fallback = true,
            doc = [[
Skills this character will already know when they're created.
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

         hp = 1,
         mp = 1,
         stamina = 1,
         max_hp = 1,
         max_mp = 1,
         max_stamina = 1,

         nutrition = 0;

         is_quest_target = nil,
         was_passed_quest_item = nil,

         respawn_date = 0,

         aquirable_feat_count = 0,
         skill_bonus = 0,
         total_skill_bonus = 0,
         speed_correction = 0,
         current_speed = 0,
         speed_percentage = 0,
         speed_percentage_in_next_turn = 0,
         inventory_weight = 0,
         max_inventory_weight = 0,
         inventory_weight_type = Enum.Burden.None,
         cargo_weight = 0,
         max_cargo_weight = 0,
         initial_max_cargo_weight = 0,

         is_temporary = nil,

         height = 0,
         weight = 0,
         personality = 0,
         talk_type = 0,
         interest = 0,
         interest_renew_date = 0,
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

         emotion_icon = nil,
         emotion_icon_turns = 0,

         god = nil,
         prayer_charge = 0,

         buffs = {},

         travel_speed = 0,

         pierce_rate = 0,
         extra_melee_attack_rate = 0,
         extra_ranged_attack_rate = 0,
         damage_resistance = 0,
         damage_immunity_rate = 0,
         damage_reflection = 0,
         aggro = 0,
         noise = 0,
         relation = 0,

         splits = nil,
         splits2 = nil,
         is_quick_tempered = nil,
         has_lay_hand = nil,
         is_lay_hand_available = nil,
         is_invisible = nil,
         is_summoned = nil,
         taught_words = nil,

         prevent_sell_in_own_shop = nil
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
            type = types.uint,
            default = 1,
            template = true,
            doc = [[
Relative strength of this item.
]]
         },
         {
            name = "weight",
            type = types.uint,
            default = 0,
            template = true
         },
         {
            name = "value",
            type = types.uint,
            default = 0,
            template = true
         },
         {
            name = "color",
            type = types.optional(ty_color),
            default = nil,
         },
         {
            name = "image",
            type = types.data_id("base.chip"),
            template = true,
            doc = [[
The item's image.
]]
         },
         {
            name = "rarity",
            type = types.int,
            default = 0,
            template = true,
            doc = [[
Controls how common this item is.

Increase to make more common; set to 0 to disable random generation entirely.
]]
         },
         {
            name = "coefficient",
            type = types.int,
            default = 0,
            template = true,
            doc = [[
Controls the chance this item will be randomly generated in dungeons with a
large level difference against the item's level.

Higher means a smaller range of dungeon levels the item appears in. Lower means
the item has a greater chance of appearing in both high-level and low-level
dungeons.
]]
         },
         {
            name = "flags",
            type = types.list(types.string),
            default = {}
         },
         {
            name = "params",
            type = types.table,
            default = {}
         },
         {
            name = "categories",
            type = types.list(types.data_id("base.item_type")),
            default = {},
            template = true
         },
         {
            name = "on_read",
            type = types.optional(types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))),
            default = nil,
         },
         {
            name = "on_zap",
            type = types.optional(types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))),
            default = nil,
         },
         {
            name = "on_eat",
            type = types.optional(types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))),
            default = nil,
         },
         {
            name = "on_drink",
            type = types.optional(types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))),
            default = nil,
         },
         {
            name = "fltselect",
            type = types.enum(Enum.FltSelect),
            default = Enum.FltSelect.None,
         },
         {
            name = "tags",
            type = types.list(types.string),
            default = {},
            template = true,
            doc = [[
A list of strings used for filtering during item generation.
]]
         },
         {
            -- TODO
            name = "originalnameref2",
            type = types.optional(types.string),
            default = nil,
         },
         {
            name = "count",
            type = types.optional(types.int),
            default = nil,
         },
         {
            name = "gods",
            type = types.list(types.data_id("elona.god")),
            default = {},
            doc = [[
What gods this item can be offered to.
]]
         },
         {
            name = "enchantments",
            type = types.list(
               types.fields {
                  _id = types.data_id("base.enchantment"),
                  power = types.number,
                  params = types.optional(types.table)
               }
            ),
            default = {},
         },
         {
            name = "identify_difficulty",
            type = types.number,
            default = 0,
         },
         {
            name = "is_precious",
            type = types.boolean,
            default = false,
         },
         {
            name = "skill",
            type = types.optional(types.data_id("base.skill")),
            default = nil,
         },
         {
            name = "material",
            type = types.data_id("base.material"),
            template = true,
            doc = [[
Material of this item.

You can set it to "elona.metal" or "elona.soft" to autogenerate a material based
on vanilla's formula.
]]
         },
         {
            name = "effective_range",
            type = types.list(types.number),
            default = {100, 20, 20, 20, 20, 20, 20, 20, 20, 20},
         },
         {
            name = "pierce_rate",
            type = types.number,
            default = 0,
         },
         {
            name = "events",
            type = types.list(ty_event),
            default = {},
            doc = [[
List of events to bind to this item when it is spawned.
]]
         },
         {
            name = "is_light_source",
            type = types.boolean,
            default = false,
            doc = [[
If true, lights up dungeons if in the player's inventory.
]]
         },
         {
            name = "light",
            type = types.optional(ty_light),
            default = nil,
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
         },
         {
            name = "spoilage_hours",
            type = types.optional(types.number),
            default = nil,
            doc = [[
Hours until the item spoils. Used for items of material "elona.fresh" only.
]]
         },
         {
            name = "is_wishable",
            type = types.boolean,
            default = true,
            doc = [[
If false, this item cannot be wished for.
]]
         }
      },
      fallbacks = {
         amount = 1,
         own_state = Enum.OwnState.None,
         curse_state = Enum.CurseState.Normal,
         identify_state = Enum.IdentifyState.None,
         bonus = 0,
         name = "item",
         value = 1,
         params = {},

         x_offset = nil,
         y_offset = nil,

         can_use_flight_on = nil -- elona.cooler_box
      }
   },
   { interface = IItem }
)

data:add_type {
   name = "item_type",
   fields = {
      {
         name = "no_generate",
         type = types.boolean,
         default = false,
         doc = [[
If true, don't randomly generate items with this category in the wild.
]]
      }
   }
}

data:add_type(
   {
      name = "feat",
      fields = {
         {
            name = "elona_id",
            type = types.optional(types.uint),
         },
         {
            name = "params",
            type = types.table,
            default = {}
         },
         {
            name = "is_solid",
            type = types.boolean,
            default = true,
         },
         {
            name = "is_opaque",
            type = types.boolean,
            default = true,
         },
         {
            name = "image",
            type = types.data_id("base.chip"),
         },
         {
            name = "on_refresh",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_bumped_into",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_open",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_close",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_bash",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_activate",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_ascend",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_descend",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "on_stepped_on",
            type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table))
         },
         {
            name = "events",
            type = types.list(ty_event),
            default = {},
            doc = [[
List of events to bind to this feat when it is created.
]]
         },
      },
   },
   { interface = IFeat }
)

data:add_type(
   {
      name = "mef",
      fields = {
         {
            name = "elona_id",
            type = types.optional(types.uint),
         },
         {
            -- TODO
            name = "params",
            type = types.table,
            default = {}
         },
         {
            name = "image",
            type = types.data_id("base.chip"),
         },
         {
            name = "on_stepped_on",
            type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table))
         },
         {
            name = "on_stepped_off",
            type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table))
         },
         {
            name = "on_updated",
            type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table))
         },
         {
            name = "on_removed",
            type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table))
         },
         {
            name = "events",
            type = types.list(ty_event),
            default = {},
            doc = [[
List of events to bind to this mef when it is created.
]]
         },
      },
   },
   { interface = IMef }
)

data:add_type(
   {
      name = "class",
      fields = {
         {
            name = "properties",
            type = types.map(types.string, types.any),
            default = {}
         },
         {
            name = "skills",
            type = types.map(types.data_id("base.skill"), types.number),
            default = {}
         },
         {
            name = "on_init_player",
            type = types.optional(types.callback("chara", types.map_object("base.chara")))
         }
      }
   }
)

data:add_type(
   {
      name = "race",
      fields = {
         {
            name = "is_extra",
            type = types.boolean,
            default = false
         },
         {
            name = "elona_id",
            type = types.optional(types.uint),
         },
         {
            name = "properties",
            type = types.map(types.string, types.any),
            default = {}
         },
         {
            name = "male_ratio",
            type = types.number,
            default = 50,
         },
         {
            name = "height",
            type = types.number,
         },
         {
            name = "age_min",
            type = types.number,
         },
         {
            name = "age_max",
            type = types.number,
         },
         {
            name = "skills",
            type = types.map(types.data_id("base.skill"), types.number)
         },
         {
            name = "body_parts",
            type = types.list(types.data_id("base.body_part")),
         }
      },
   }
)

data:add_type(
   {
      name = "element",
      fields = {
         {
            name = "elona_id",
            type = types.optional(types.uint),
         },
         {
            name = "color",
            type = types.optional(ty_color)
         },
         {
            name = "ui_color",
            type = types.optional(ty_color)
         },
         {
            name = "can_resist",
            type = types.optional(types.boolean)
         },
         {
            name = "sound",
            type = types.optional(types.data_id("base.sound"))
         },
         {
            name = "death_anim",
            type = types.optional(types.data_id("base.asset"))
         },
         {
            name = "death_anim_dy",
            type = types.optional(types.number)
         },
         {
            name = "rarity",
            type = types.optional(types.number)
         },
         {
            name = "on_modify_damage",
            type = types.optional(types.callback("chara", types.map_object("base.chara"),
                                                 "damage", types.number))
         },
         {
            name = "on_damage_tile",
            type = types.optional(types.callback("self", types.data_entry("base.element"),
                                                 "x", types.uint,
                                                 "y", types.uint,
                                                 "source", types.map_object("base.chara")))
         },
         {
            name = "on_damage",
            type = types.optional(types.callback("chara", types.map_object("base.chara"),
                                                 "params", types.table)) -- TODO
         },
         {
            name = "on_kill",
            type = types.optional(types.callback("chara", types.map_object("base.chara"),
                                                 "params", types.table)) -- TODO
         },
         {
            name = "calc_initial_resist_level",
            type = types.optional(types.callback("chara", types.map_object("base.chara"),
                                                 "level", types.number))
         }
      }
   }
)

data:add_type{
   name = "effect",
   fields = {
      {
         name = "color",
         type = ty_color,
      },
      {
         name = "indicator",
         type = types.some(types.locale_id, types.callback("chara", types.map_object("base.chara")))
      },
      {
         name = "emotion_icon",
         type = types.optional(types.string) -- TODO
      },
      {
         name = "on_turn_start",
         type = types.optional(types.callback("chara", types.map_object("base.chara")))
      },
      {
         name = "on_turn_end",
         type = types.optional(types.callback("chara", types.map_object("base.chara")))
      },
      {
         name = "stops_activity",
         type = types.boolean,
         default = false,
         template = true,
         doc = [[
If true, this effect will stop any active activities on the applied character.
]]
      },
      {
         name = "related_element",
         type = types.optional(types.data_id("base.element"))
      },
      {
         name = "calc_adjusted_power",
         type = types.optional(types.callback("chara", types.map_object("base.chara"), "power", types.number))
      },
      {
         name = "calc_additive_power",
         type = types.optional(types.callback("chara", types.map_object("base.chara"), "power", types.number))
      },
      {
         name = "on_sleep",
         type = types.optional(types.some(types.literal("remove"),
                                          types.callback("chara", types.map_object("base.chara"))))
      },
      {
         name = "auto_heal",
         type = types.boolean,
         default = true,
         template = true,
         doc = [[
If true, this effect will be healed when the turn starts.

False for sickness and choking on mochi.
]]
      },
   }
}

data:add_type(
   {
      name = "activity",
      fields = {
         {
            name = "elona_id",
            type = types.optional(types.uint)
         },
         {
            name = "params",
            type = types.map(types.string, types.type),
            default = {}
         },
         {
            name = "default_turns",
            type = types.some(types.uint,
                              types.callback({"self", types.interface(IActivity)}, types.int)),
            default = 10
         },
         {
            name = "animation_wait",
            type = types.some(types.positive(types.number),
                              types.callback({"self", types.interface(IActivity)}, types.number))
         },
         {
            name = "auto_turn_anim",
            type = types.optional(types.some(types.data_id("base.auto_turn_anim"),
                                             types.callback({"self", types.interface(IActivity)}, types.data_id("base.auto_turn_anim"))))
         },
         {
            name = "localize",
            type = types.optional(types.some(types.locale_id,
                                             types.callback({"self", types.interface(IActivity)}, types.locale_id)))
         },
         {
            name = "can_scroll",
            type = types.boolean,
            default = false
         },
         {
            name = "on_interrupt",
            type = types.literal("ignore", "prompt", "stop"),
         },
         {
            name = "interrupt_on_displace",
            type = types.boolean,
            default = false
         },
         {
            name = "events",
            type = types.list(ty_event),
            default = {},
            doc = [[
List of events to bind to this activity when it is created.
]]
         },
      },
   },
   { interface = IActivity }
)

data:add_type {
   name = "body_part",
   fields = {
      {
         name = "elona_id",
         type = types.optional(types.uint)
      },
      {
         name = "icon",
         type = types.uint -- TODO: needs to be themable
      }
   }
}

local ty_image_entry = types.some(
   -- "graphic/chip.png",
   types.string,

   -- {
   --   image = "graphic/chip.bmp",
   --   count_x = 1,
   --   key_color = {0, 0, 0}
   -- }
   types.fields_strict {
      image = types.string,
      count_x = types.optional(types.uint),
      key_color = types.optional(ty_color)
   },

   -- {
   --   height = 48,
   --   source = "graphic/map0.bmp",
   --   width = 48,
   --   x = 0,
   --   y = 0,
   --   count_x = 1,
   --   key_color = {0, 0, 0}
   -- }
   types.fields_strict {
      source = types.string,
      width = types.uint,
      height = types.uint,
      x = types.uint,
      y = types.uint,
      count_x = types.optional(types.uint),
      key_color = types.optional(ty_color)
   }
)

-- {
--   default = "graphic/chip.bmp",
--   anim1 = { image = "graphic/chip1.bmp", count_x = 2 }
-- }
local ty_image_anims = types.map(types.string, ty_image_entry)

local ty_image = types.some(ty_image_entry, ty_image_anims)

data:add_type {
   name = "map_tile",
   fields = {
      {
         name = "elona_id",
         type = types.optional(types.uint),
      },
      {
         name = "elona_atlas",
         type = types.optional(types.uint),
      },
      {
         name = "image",
         type = ty_image
      },
      {
         name = "field_type",
         type = types.optional(types.data_id("elona.field_type")),
      },
      {
         name = "kind",
         type = types.enum(Enum.TileRole),
         default = Enum.TileRole.None
      },
      {
         name = "kind2",
         type = types.enum(Enum.TileRole),
         default = Enum.TileRole.None
      },
      {
         name = "is_solid",
         type = types.boolean,
         default = false,
      },
      {
         name = "is_opaque",
         type = types.boolean,
         default = false,
      },
      {
         name = "is_road",
         type = types.boolean,
         default = false,
      },
      {
         name = "wall",
         type = types.optional(types.data_id("base.map_tile")),
      },
      {
         name = "wall_kind",
         type = types.optional(types.literal(1, 2)),
      },
      {
         name = "count_x",
         type = types.optional(types.uint),
      },
      {
         name = "disable_in_map_edit",
         type = types.boolean,
         default = false
      },
   }
}

data:add_type {
   name = "enchantment",
   fields = {
      {
         name = "level",
         type = types.uint,
         default = 1,
         template = true,
         doc = [[
Level of this enchantment.
]]
      },
      {
         name = "value",
         type = types.uint,
         default = 100,
         template = true,
         doc = [[
Value of this enchantment.
]]
      },
      {
         name = "level",
         type = types.uint,
         default = 100,
         template = true,
         doc = [[
Rarity of this enchantment. Lower means more rare.
]]
      },
      {
         name = "filter",
         template = true,
         doc = [[
Function to filter which items this enchantment will get applied to. If nil, it
can be applied to any item generated randomly.
]]
      },
      {
         name = "alignment",
         default = "positive",
         template = true,
         doc = [[
Determines if this enchantment is beneficial or not. One of "positive" or "negative".
]]
      },
      {
         name = "power",
         default = CodeGenerator.gen_literal [[
function(power, item, wearer)
      return power / 50
   end
]],
         template = true,
         doc = [[
How to adjust the power when applying the enchantment.
]]
      },
   }
}

data:add_type {
   name = "ego_enchantment",
   fields = {
      {
         name = "level",
         type = "int",
         default = 0,
         template = true,
         doc = [[
Level of this ego enchantment. Typically between 0-3.
]]
      },
      {
         name = "filter",
         type = "function",
         default = CodeGenerator.gen_literal [[
function(item)
   return true
end
]],
         template = true,
         doc = [[
A function to filter which items this ego can get applied to.
]]
      },
      {
         name = "enchantments",
         default = {},
         template = true,
         doc = [[
List of enchantments and their powers to apply.
]]
      },
   }
}

data:add_type {
   name = "ego_minor_enchantment",
   fields = {}
}

data:add_type {
   name = "enchantment_skill",
   fields = {
      {
         name = "skill_id",
         default = "elona.short_teleport",
         template = true,
         doc = [[
Skill to trigger.
]]
      },
      {
         name = "target_type",
         default = "self",
         template = true,
         doc = [[
The target of the skill. Same format as that of "base.skill". Usually either "self" or "enemy".
]]
      },
      {
         name = "rarity",
         default = 100,
         template = true,
         doc = [[
Rarity of this enchantment skill when generating an enchantment containing it.
]]
      },
      {
         name = "categories",
         default = { "elona.equip_melee" },
         template = true,
         doc = [[
Valid item categories this enchantment skill applies to.
]]
      },
      {
         name = "power",
         default = 10,
         template = true,
         doc = [[
Power of the skill when it is triggered.
]]
      }
   }
}

data:add_type {
   name = "ammo_enchantment",
   fields = {
      {
         name = "ammo_amount",
         default = 30,
         template = true,
         doc = [[
Controls the starting amount of ammo.
]]
      },
      {
         name = "ammo_factor",
         default = 70,
         template = true,
         doc = [[
Controls the starting amount of ammo.
]]
      },
      {
         name = "stamina_cost",
         default = 1,
         template = true,
         doc = [[
Stamina cost of the ammo when fired.
]]
      }
   }
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
         default = nil,
         template = true,
         doc = [[
A related stat to improve when this skill is used. Affects the skill's icon in the menus.
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
      {
         name = "ignore_missing_target",
         default = false,
         doc = [[
If true, continue to use the skill even if a target character was not found.

This is used by the Pickpocket skill to select an item on the ground independent of a target character.
]]
      }
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
   name = "config_menu",
   schema = schema.Record {
      options = schema.Table,
      on_generate = schema.Optional(schema.Function),
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

data:add_type {
   name = "map_archetype",
   fields = {
      {
         name = "on_spawn_monster",
         default = CodeGenerator.gen_literal [[
function(map)
   end]],
         template = true,
         type = "function(InstancedMap)",
         doc = [[
Callback run when a monster is spawned in the map.
]]
      },
      {
         name = "on_map_restock",
         default = CodeGenerator.gen_literal [[
function(map)
   end]],
         template = true,
         type = "function(InstancedMap)",
         doc = [[
Callback run when this map is restocked, refreshing things like shop inventories.
]]
      },
      {
         name = "on_map_renew",
         default = CodeGenerator.gen_literal [[
function(map)
   end]],
         template = true,
         type = "function(InstancedMap)",
         doc = [[
Callback run when this map is renewed, in order to regenerate its geometry.
]]
      },
      {
         name = "on_generate_map",
         default = CodeGenerator.gen_literal [[
function(area, floor)
   return InstancedMap(20, 20)
end
]],
         template = true,
         type = "function(InstancedArea, int)?",
         doc = [[
How this map should be generated for the first time.

This is to be used for generating areas from `base.area_archetype` so you don't
have to create a new instance of `base.area_archetype` every single time for its
`on_generate_floor` callback if all you want is an area containing a single map.
If you don't list this map archetype in the `floors` property of any area
archetype, then this function can be omitted.
]]
      },
      {
         name = "properties",
         default = CodeGenerator.gen_literal [[
{
   is_indoor = true,
   level = 10
}]],
         template = true,
         type = "table",
         doc = [[
Properties to copy to this map after it is generated. Does not override any values already set in the `on_generate` callback.
]]
      },
      {
         name = "_events",
         default = {},
         template = false,
         type = "table",
         doc = [[
Additional events to bind to this map when it is loaded.
]]
      },
   }
}

data:add_type {
   name = "area_archetype",
   fields = {
      {
         name = "on_generate_floor",
         default = CodeGenerator.gen_literal [[
   function(area, floor)
      return InstancedMap:new(25, 25)
end
]],
         template = true,
         type = "function(InstancedArea, int)",
         doc = [[
Map generator for this area. Determines how maps in this area should be created
when they're initially generated. Takes an area and a floor number and returns a
new map for that floor.

Note that this function is responsible for setting up the entrances to adjacent
maps in the same area. As in, if this function does not create the stairs
leading to the other floors, then the player won't be able to access them.

To prevent the floor from being saved, for example if you want to emulate the
behavior of the Puppy Cave or The Void where the floor is generated every time,
set `is_temporary` to `true` on the generated map.
]]
      },
      {
         name = "image",
         default = "elona.feat_area_village",
         template = true,
         type = "id:base.chip",
         doc = [[
Image this area will have when created with Area.create_entrance().
]]
      },
      {
         name = "deepest_floor",
         default = nil,
         template = false,
         type = "int?",
         doc = [[
Deepest floor of this area. Used with generating dungeons.
]]
      },
      {
         name = "parent_area",
         default = nil,
         template = true,
         type = "{_id=id:base.unique_area,on_floor=uint,x=uint,y=uint,starting_floor=uint}",
         doc = [[
Parent area that this area is contained in. If present, an entrance leading to
this area on floor `starting_floor` will be created when the given parent area's
floor is generated for the first time.

This is merely for convenience; you can always create an entrance leading to
this area as follows:

```lua
local parent_map = Map.current()
local parent_area = Area.for_map(parent_map)
local parent_floor = Area.floor_number(parent_map)

local _id = "elona.north_tyris"
local on_floor = 1

if parent_area._id == _id and parent_floor == on_floor then
   local my_area = Area.get_unique("elona.vernis")
   local starting_floor = my_area:starting_floor()
   local entrance = Area.create_entrance(my_area, starting_floor, 10, 10, {}, parent_map)
   assert(entrance.params.area_uid == my_area.uid)
   assert(entrance.params.area_floor == floor_number)
end
```
]]
      },
   }
}

data:add_type {
   name = "damage_reaction",
   fields = {
      {
         name = "on_damage",
         default = CodeGenerator.gen_literal [[
   function(chara, power, params)
end
]],
         template = true,
         type = "function(IChara, int, table)",
         doc = [[
Behavior to trigger when this character is melee attacked.
]]
      },
   }
}

data:add_type {
   name = "language",
   fields = {
      {
         name = "language_code",
         template = true,
         default = "",
         doc = [[
The language code for this language.

Translations will be loaded from the folder with this language code under the
locale/ folder of each mod. Prefer using an ISO 639-2/B code if available.

You can reuse the language code of an existing language, for example if you
wanted to create a mod that modifies the translated text using English as a
base.
]]
      }
   }
}

data:add_type {
   name = "role",
}

data:add_type {
   name = "config_option_type",
   fields = {
      {
         name = "validate",
         template = true,
         default = CodeGenerator.gen_literal [[
   function(value, option)
      return true
end
]],
         doc = [[
Used to validate if a value for this option is valid.
]]
      },
      {
         name = "widget",
         template = true,
         type = "string",
         doc = [[
Require path of the widget used to display this config option.

It must implement IConfigItemWidget.
]]
      },
      {
         name = "fields",
         type = "table",
         doc = [[
Extra fields for configuring this config option.
]]
      }
   }
}

data:add_type {
   name = "config_option",
   fields = {
      {
         name = "type",
         template = true,
         default = "boolean",
         no_fallback = true,
         doc = [[
Type of this config option.

One of "boolean", "string", "number", "int" "enum", "table", "data_id" or "any".
]]
      },
      {
         name = "default",
         template = true,
         default = true,
         no_fallback = true,
         doc = [[
Default value of this config option.
]]
      },
      {
         name = "choices",
         default = CodeGenerator.gen_literal "{}",
         no_fallback = true,
         doc = [[
Only used if the type is "enum".

The list of enum variants of this config option.
]]
      },
      {
         name = "data_type",
         default = "base.chara",
         no_fallback = true,
         doc = [[
Only used if the type is "data_id".

The data type of the ID in this config option.
]]
      }
   }
}

data:add_type {
   name = "auto_turn_anim",
   fields = {
   }
}

data:add_type {
   name = "equipment_type",
   fields = {}
}

data:add_type {
   name = "loot_type",
   fields = {}
}

data:add_type {
   name = "trait_indicator",
   fields = {}
}

data:add_type {
   name = "journal_page",
   fields = {}
}
