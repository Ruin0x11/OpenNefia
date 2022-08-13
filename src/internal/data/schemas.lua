local data = require("internal.data")
local Enum = require("api.Enum")
local IEventEmitter = require("api.IEventEmitter")
local InstancedMap = require("api.InstancedMap")
local InstancedArea = require("api.InstancedArea")
local IConfigMenu = require("api.gui.menu.config.IConfigMenu")
local IConfigItemWidget = require("api.gui.menu.config.item.IConfigItemWidget")

local ty_data_ext_field = types.fields({
	name = types.string,
	type = types.type,
	default = types.any,
})

data:add_type({
	name = "data_ext",
	fields = {
		{
			name = "fields",
			template = true,
			type = types.list(ty_data_ext_field),
			default = {},
		},
	},
})

data:add_type({
	name = "event",
	fields = {},
	doc = [[
Events that can be fired.
]],
})

local IChara = require("api.chara.IChara")
local IItem = require("api.item.IItem")
local IFeat = require("api.feat.IFeat")
local IActivity = require("api.activity.IActivity")
local IMef = require("api.mef.IMef")

local ty_event = types.fields({
	id = types.data_id("base.event"),
	name = types.string,
	callback = types.callback("self", types.interface(IEventEmitter), "params", types.table, "result", types.any),
})

local ty_light = types.fields({
	chip = types.string,
	bright = types.positive(types.number),
	offset_y = types.number,
	power = types.number,
	flicker = types.positive(types.number),
	always_on = types.optional(types.boolean),
})

local ty_shadow_type = types.literal("none", "normal", "drop_shadow")

local ty_chara_filter = types.fields({
	quality = types.enum(Enum.Quality),
	level = types.uint,
	initial_level = types.uint,
	id = types.data_id("base.chara"),
	fltselect = types.enum(Enum.FltSelect),
	category = types.enum(Enum.CharaCategory),
	create_params = types.table,
	tag_filters = types.list(types.string),
	race_filter = types.data_id("base.race"),
	ownerless = types.boolean,
})

local ty_item_filter = types.fields({
	quality = types.enum(Enum.Quality),
	level = types.uint,
	id = types.data_id("base.chara"),
	categories = types.some(types.data_id("base.item_type"), types.list(types.data_id("base.item_type"))),
	create_params = types.table,
	ownerless = types.boolean,
})

local ty_ai_action = types.all(
	types.fields({
		id = types.data_id("base.ai_action"),
	}),
	types.map(types.string, types.any)
)

local ty_chara_ai_actions = types.fields({
	main = types.optional(types.list(ty_ai_action)),
	sub = types.optional(types.list(ty_ai_action)),
})

local ty_equip_spec = types.map(
	types.string,
	types.fields({
		_id = types.optional(types.data_id("base.item")),
		category = types.optional(types.data_id("base.item_type")),
		quality = types.optional(types.enum(Enum.Quality)),
	})
)

local ty_drop = types.fields({
	_id = types.data_id("base.item"),
	amount = types.uint,
	on_create = types.callback(
		"item",
		types.map_object("base.item"),
		"chara",
		types.map_object("base.chara"),
		"attacker",
		types.optional(types.map_object("base.chara"))
	),
})

data:add_type({
	name = "chara",
	fields = {
		{
			name = "elona_id",
			type = types.optional(types.uint),
			indexed = true,
		},
		{
			name = "level",
			type = types.uint,
			default = 1,
			template = true,
			doc = [[
Relative strength of this character.
]],
		},
		{
			name = "quality",
			type = types.optional(types.enum(Enum.Quality)),
		},
		{
			name = "ai_actions",
			type = ty_chara_ai_actions,
			default = {},
			doc = [[
Chance this unit will take an idle action if they have no target.
]],
		},
		{
			name = "ai_move_chance",
			type = types.uint,
			default = 100,
			doc = [[
Chance this unit will take an idle action if they have no target.
]],
		},
		{
			-- TODO should be ID
			name = "ai_calm_action",
			type = types.optional(types.string),
			doc = [[
Idle AI action this unit will take if they have no target.
]],
		},
		{
			name = "ai_sub_action_chance",
			type = types.uint,
			default = 0,
			doc = [[
Chance this character will use an AI sub action.
]],
		},
		{
			name = "ai_distance",
			type = types.uint,
			default = 1,
			doc = [[
Minimum distance before this unit starts moving toward their target.
]],
		},
		{
			name = "portrait",
			type = types.optional(types.some(types.data_id("base.portrait"), types.literal("random"))),
			default = nil,
			doc = [[
Portrait displayed when conversing with this character.

Remove this to use the character's sprite instead.
]],
		},
		{
			name = "resistances",
			type = types.map(types.data_id("base.resistance"), types.int),
			default = {},
			no_fallback = true,
		},
		{
			name = "tags",
			type = types.list(types.string),
			default = {},
			doc = [[
A list of strings used for filtering during character generation.
]],
		},
		{
			name = "has_own_name",
			type = types.boolean,
			default = false,
		},
		{
			name = "can_talk",
			type = types.boolean,
			default = false,
			doc = [[
If true, you can talk to this character by bumping into them.
]],
		},
		{
			name = "relation",
			type = types.enum(Enum.Relation),
			default = Enum.Relation.Neutral,
			template = true,
			doc = [[
What alignment this character has.

This determines if it will act hostile toward the player on first sight.
]],
		},
		{
			-- TODO should be data ID in key positions
			name = "initial_equipment",
			type = ty_equip_spec,
		},
		{
			name = "race",
			type = types.data_id("base.race"),
			default = "elona.slime",
			template = true,
			doc = [[
The race of this character.
]],
		},
		{
			name = "class",
			type = types.data_id("base.class"),
			default = "elona.predator",
			template = true,
			doc = [[
The class of this character.
]],
		},
		{
			name = "image",
			type = types.optional(types.data_id("base.chip")),
			default = nil,
			template = true,
			doc = [[
The character's image. Can be nil to use the race's default image.
]],
		},
		{
			name = "male_image",
			type = types.optional(types.data_id("base.chip")),
			default = nil,
			doc = [[
The character's male image. Can be nil to use the race's default image.
]],
		},
		{
			name = "female_image",
			type = types.optional(types.data_id("base.chip")),
			default = nil,
			doc = [[
The character's female image. Can be nil to use the race's default image.
]],
		},
		{
			name = "gender",
			type = types.literal("female", "male"), -- TODO allow arbitrary genders
			default = "female",
			no_fallback = true,
			doc = [[
The character's gender, either "male" or "female".
]],
		},
		{
			name = "shadow_type",
			type = ty_shadow_type,
			default = "normal",
		},
		{
			name = "fltselect",
			type = types.enum(Enum.FltSelect),
			default = Enum.FltSelect.None,
			doc = [[
Determines if the character is spawned in towns, etc.
]],
		},
		{
			name = "rarity",
			type = types.int,
			default = 100000,
			template = true,
			doc = [[
Controls how common this character is.

Increase to make more common; set to 0 to disable random generation entirely.
]],
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
]],
		},
		{
			name = "loot_type",
			type = types.optional(types.data_id("base.loot_type")),
			default = nil,
			doc = [[
Type of loot this character drops on death.
]],
		},
		{
			name = "dialog",
			type = types.optional(types.data_id("elona_sys.dialog")),
			default = nil,
			doc = [[
Dialog tree to run upon bumping into this character.

The character must have `can_talk` set to `true` for this to trigger.
]],
		},
		{
			name = "tone",
			type = types.optional(types.data_id("base.tone")),
			default = nil,
			doc = [[
Custom talk tone for this character.

This is for making characters say custom text on certain events.
]],
		},
		{
			-- TODO
			name = "cspecialeq",
			type = types.optional(types.literal(1)),
			default = nil,
		},
		{
			-- TODO
			name = "eqweapon1",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqtwohand",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqrange",
			type = types.optional(types.some(types.uint, types.tuple(types.uint, types.uint))),
			default = nil,
		},
		{
			-- TODO
			name = "eqrange_0",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqrange_1",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqammo",
			type = types.optional(types.tuple(types.uint, types.uint)),
			default = nil,
		},
		{
			-- TODO
			name = "eqammo_0",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqammo_1",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqring1",
			type = types.optional(types.int),
			default = nil,
		},
		{
			-- TODO
			name = "eqmultiweapon",
			type = types.optional(types.int),
			default = nil,
		},
		{
			name = "effect_immunities",
			type = types.list(types.data_id("base.effect")),
			default = {},
		},
		{
			name = "unarmed_element_id",
			type = types.optional(types.data_id("base.element")),
			default = nil,
		},
		{
			name = "unarmed_element_power",
			type = types.optional(types.int),
			default = nil,
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
			default = {},
		},
		{
			name = "on_eat_corpse",
			type = types.optional(
				types.callback(
					"corpse",
					types.map_object("base.item"),
					"params",
					types.fields({ chara = types.map_object("base.chara") })
				)
			),
			doc = [[
A callback to be run when this character's corpse is eaten.
   ]],
		},
		{
			name = "events",
			default = nil,
			type = types.list(ty_event),
			doc = [[
List of events to bind to this character when they are spawned.
]],
		},
		{
			name = "category",
			type = types.enum(Enum.CharaCategory),
			default = Enum.CharaCategory.None,
		},
		{
			name = "color",
			type = types.optional(types.color),
			default = nil,
			doc = [[
Color to display on the character's sprite.
]],
		},
		{
			-- TODO
			name = "is_unique",
			type = types.boolean,
			default = false,
		},
		{
			name = "splits",
			type = types.boolean,
			default = false,
		},
		{
			name = "splits2",
			type = types.boolean,
			default = false,
		},
		{
			name = "has_lay_hand",
			type = types.boolean,
			default = false,
		},
		{
			name = "can_cast_rapid_magic",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_invisible",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_floating",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_immune_to_mines",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_explodable",
			type = types.boolean,
			default = false,
		},
		{
			name = "always_drops_gold",
			type = types.boolean,
			default = false,
		},
		{
			name = "ai_regenerates_mana",
			type = types.boolean,
			default = false,
		},
		{
			name = "rich_loot_amount",
			type = types.uint,
			default = 0,
		},
		{
			name = "can_use_snow",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_immune_to_elemental_damage",
			type = types.boolean,
			default = false,
		},
		{
			name = "on_initialize_equipment",
			type = types.optional(
				types.callback(
					"self",
					types.map_object("base.chara"),
					"params",
					types.table,
					"equip_spec",
					ty_equip_spec
				)
			),
		},
		{
			name = "on_drop_loot",
			type = types.optional(
				types.callback(
					"self",
					types.map_object("base.chara"),
					"params",
					types.table,
					"drops",
					types.list(ty_drop)
				)
			),
		},
		{
			name = "calc_initial_gold",
			type = types.optional(types.callback({ "self", types.map_object("base.chara") }, types.uint)),
		},
		{
			name = "ai",
			type = types.data_id("base.ai_action"),
			default = "elona.elona_default_ai",
			doc = [[
AI callback to run on this character's turn.
]],
		},
		{
			name = "damage_reaction",
			type = types.optional(types.fields({
				id = types.data_id("base.damage_reaction"),
				power = types.int,
			})),
			default = nil,
			doc = [[
A damage reaction to trigger if this character is melee attacked.
]],
		},
		{
			name = "skills",
			type = types.optional(types.list(types.data_id("base.skill"))),
			default = nil,
			no_fallback = true,
			doc = [[
Skills this character will already know when they're created.
]],
		},
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
			on_idle_action = nil,
		},

		hp = 1,
		mp = 1,
		stamina = 1,
		max_hp = 1,
		max_mp = 1,
		max_stamina = 1,

		nutrition = 0,

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
		scroll_x_offset = 0,
		scroll_y_offset = 0,

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

		is_quick_tempered = nil,
		is_lay_hand_available = nil,
		is_invisible = nil,
		is_summoned = nil,
		taught_words = nil,

		prevent_sell_in_own_shop = nil,
	},
}, { interface = IChara })

local ty_enchantment_def = types.fields({
	_id = types.data_id("base.enchantment"),
	power = types.number,
	params = types.optional(types.table),
})

data:add_type({
	name = "item",
	fields = {
		{
			name = "elona_id",
			type = types.optional(types.uint),
			indexed = true,
		},
		{
			name = "custom_author",
			type = types.optional(types.string),
		},
		{
			name = "level",
			type = types.uint,
			default = 1,
			template = true,
			doc = [[
Relative strength of this item.
]],
		},
		{
			name = "weight",
			type = types.uint,
			default = 0,
			template = true,
		},
		{
			name = "value",
			type = types.uint,
			default = 0,
			template = true,
		},
		{
			name = "color",
			type = types.optional(types.color),
			default = nil,
		},
		{
			name = "random_color",
			type = types.optional(types.literal("Random", "Furniture")),
			default = nil,
		},
		{
			name = "container_params",
			type = types.optional(
				types.fields({
					type = types.literal("local"),
					max_capacity = types.optional(types.uint),
					combine_weight = types.optional(types.boolean),
				})
			),
			default = nil,
		},
		{
			name = "image",
			type = types.data_id("base.chip"),
			template = true,
			doc = [[
The item's image.
]],
		},
		{
			name = "shadow_type",
			type = ty_shadow_type,
			default = "normal",
		},
		{
			name = "rarity",
			type = types.int,
			default = 1000000,
			template = true,
			doc = [[
Controls how common this item is.

Increase to make more common; set to 0 to disable random generation entirely.
]],
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
]],
		},
		{
			name = "flags",
			type = types.list(types.string),
			default = {},
		},
		{
			name = "params",
			type = types.table,
			default = {},
		},
		{
			name = "quality",
			type = types.optional(types.enum(Enum.Quality)),
		},
		{
			name = "medal_value",
			type = types.uint,
			default = 0,
		},
		{
			name = "categories",
			type = types.fields({ no_implicit = types.optional(types.boolean) }, types.data_id("base.item_type")),
			default = { "elona.equip_melee", "elona.equip_ranged" },
			template = true,
			doc = [[
Valid item categories this enchantment skill applies to.
]],
		},
		{
			name = "on_generate",
			type = types.optional(types.callback("self", types.map_object("base.item"))),
			default = nil,
		},
		{
			name = "on_init_params",
			type = types.optional(types.callback("self", types.map_object("base.item"))),
			default = nil,
		},
		{
			name = "before_wish",
			type = types.optional(
				types.callback({ "self", types.map_object("base.item"), "params", types.table }, ty_item_filter)
			),
			default = nil,
		},
		{
			name = "on_read",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_zap",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_eat",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_drink",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_open",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_throw",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_use",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_ascend",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
			default = nil,
		},
		{
			name = "on_descend",
			type = types.optional(
				types.callback("self", types.map_object("base.item"), "chara", types.map_object("base.chara"))
			),
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
]],
		},
		{
			-- TODO
			name = "knownnameref",
			type = types.optional(types.string),
			default = nil,
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
]],
		},
		{
			name = "enchantments",
			type = types.list(ty_enchantment_def),
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
			name = "is_handmade",
			type = types.boolean,
			default = false,
		},
		{
			name = "is_showroom_only",
			type = types.boolean,
			default = false,
		},
		{
			name = "has_random_name",
			type = types.boolean,
			default = false,
		},
		{
			-- TODO remove
			name = "elona_function",
			type = types.optional(types.uint),
		},
		{
			-- TODO remove
			name = "elona_type",
			type = types.optional(types.string),
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
]],
		},
		{
			name = "effective_range",
			type = types.list(types.number),
			default = { 100, 20, 20, 20, 20, 20, 20, 20, 20, 20 },
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
]],
		},
		{
			name = "is_light_source",
			type = types.boolean,
			default = false,
			doc = [[
If true, lights up dungeons if in the player's inventory.
]],
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
]],
		},
		{
			name = "spoilage_hours",
			type = types.optional(types.number),
			default = nil,
			doc = [[
Hours until the item spoils. Used for items of material "elona.fresh" only.
]],
		},
		{
			name = "cooldown_hours",
			type = types.optional(types.uint),
			default = nil,
		},
		{
			name = "ambient_sounds",
			type = types.optional(types.list(types.data_id("base.sound"))),
			default = nil,
		},
		{
			name = "is_wishable",
			type = types.boolean,
			default = true,
			doc = [[
If false, this item cannot be wished for.
]],
		},
		{
			name = "cannot_use_flight_on",
			type = types.optional(types.boolean),
			default = nil,
		},
		{
			name = "prevent_sell_in_own_shop",
			type = types.optional(types.boolean),
			default = nil,
		},
		{
			name = "always_drop",
			type = types.optional(types.boolean),
			default = nil,
		},
		{
			name = "always_stack",
			type = types.boolean,
			default = false,
		},
		{
			name = "prevent_dip",
			type = types.optional(types.boolean),
			default = nil,
		},
		{
			name = "can_read_in_world_map",
			type = types.optional(types.boolean),
			default = nil,
		},
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
	},
}, { interface = IItem })

data:add_type({
	name = "item_type",
	fields = {
		{
			name = "no_generate",
			type = types.boolean,
			default = false,
			doc = [[
If true, don't randomly generate items with this category in the wild.
]],
		},
		{
			name = "is_major",
			type = types.boolean,
			default = false,
		},
		{
			name = "parents",
			type = types.list(types.data_id("base.item_type")),
			default = {},
		},
	},
})

data:add_type({
	name = "feat",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "elona_sub_id",
			type = types.optional(types.uint),
		},
		{
			name = "params",
			type = types.map(types.string, types.fields({ type = types.type, default = types.optional(types.any) })),
			default = {},
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
			name = "shadow_type",
			type = ty_shadow_type,
			default = "none",
		},
		{
			name = "image",
			type = types.optional(types.data_id("base.chip")),
		},
		{
			name = "on_refresh",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_search",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_search_from_distance",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_bumped_into",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_open",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_close",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_bash",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_activate",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_ascend",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_descend",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "on_stepped_on",
			type = types.optional(types.callback("self", types.map_object("base.feat"), "params", types.table)),
		},
		{
			name = "events",
			type = types.list(ty_event),
			default = {},
			doc = [[
List of events to bind to this feat when it is created.
]],
		},
	},
}, { interface = IFeat })

data:add_type({
	name = "mef",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			-- TODO
			name = "params",
			type = types.table,
			default = {},
		},
		{
			name = "image",
			type = types.data_id("base.chip"),
		},
		{
			name = "on_stepped_on",
			type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table)),
		},
		{
			name = "on_stepped_off",
			type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table)),
		},
		{
			name = "on_updated",
			type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table)),
		},
		{
			name = "on_removed",
			type = types.optional(types.callback("self", types.map_object("base.mef"), "params", types.table)),
		},
		{
			name = "events",
			type = types.list(ty_event),
			default = {},
			doc = [[
List of events to bind to this mef when it is created.
]],
		},
	},
}, { interface = IMef })

data:add_type({
	name = "class",
	fields = {
		{
			name = "is_extra",
			type = types.boolean,
			default = false,
		},
		{
			name = "properties",
			type = types.map(types.string, types.any),
			default = {},
		},
		{
			name = "skills",
			type = types.map(types.data_id("base.skill"), types.number),
			default = {},
		},
		{
			name = "on_init_player",
			type = types.optional(types.callback("chara", types.map_object("base.chara"))),
		},
	},
})

data:add_type({
	name = "race",
	fields = {
		{
			name = "is_extra",
			type = types.boolean,
			default = false,
		},
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "properties",
			type = types.map(types.string, types.any),
			default = {},
		},
		{
			name = "male_ratio",
			type = types.number,
			default = 50,
		},
		{
			name = "height",
			type = types.number,
			default = 10,
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
			type = types.map(types.data_id("base.skill"), types.number),
		},
		{
			name = "traits",
			type = types.map(types.data_id("base.trait"), types.number),
			default = {},
		},
		{
			name = "body_parts",
			type = types.list(types.data_id("base.body_part")),
		},
		{
			name = "resistances",
			type = types.list(types.data_id("base.element")),
			default = {},
		},
		{
			name = "effect_immunities",
			type = types.list(types.data_id("base.effect")),
			default = {},
		},
	},
})

data:add_type({
	name = "element",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "color",
			type = types.optional(types.color),
		},
		{
			name = "ui_color",
			type = types.optional(types.color),
		},
		{
			name = "can_resist",
			type = types.boolean,
			default = false,
		},
		{
			name = "preserves_sleep",
			type = types.boolean,
			default = false,
		},
		{
			name = "sound",
			type = types.optional(types.data_id("base.sound")),
		},
		{
			name = "death_anim",
			type = types.optional(types.data_id("base.asset")),
		},
		{
			name = "death_anim_dy",
			type = types.optional(types.number),
		},
		{
			name = "rarity",
			type = types.optional(types.number),
		},
		{
			name = "on_modify_damage",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "damage", types.number)),
		},
		{
			name = "on_damage_tile",
			type = types.optional(
				types.callback(
					"self",
					types.data_entry("base.element"),
					"x",
					types.uint,
					"y",
					types.uint,
					"source",
					types.map_object("base.chara")
				)
			),
		},
		{
			name = "on_damage",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "params", types.table)), -- TODO
		},
		{
			name = "after_apply_damage",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "params", types.table)), -- TODO
		},
		{
			name = "on_kill",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "params", types.table)), -- TODO
		},
		{
			name = "calc_initial_resist_level",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "level", types.number)),
		},
	},
})

local ty_indicator_text = types.some(types.string, types.fields({ text = types.string, color = types.color }))
local ty_indicator_cb = types.callback({ "chara", types.map_object("base.chara") }, ty_indicator_text)
local ty_indicator = types.some(types.locale_id, ty_indicator_cb)

data:add_type({
	name = "effect",
	fields = {
		{
			name = "color",
			type = types.color,
		},
		{
			name = "indicator",
			type = ty_indicator,
		},
		{
			name = "emotion_icon",
			type = types.optional(types.string), -- TODO
		},
		{
			name = "on_add",
			type = types.optional(types.callback("chara", types.map_object("base.chara"))),
		},
		{
			name = "on_remove",
			type = types.optional(types.callback("chara", types.map_object("base.chara"))),
		},
		{
			name = "on_turn_start",
			type = types.optional(types.callback("chara", types.map_object("base.chara"))),
		},
		{
			name = "on_turn_end",
			type = types.optional(types.callback("chara", types.map_object("base.chara"))),
		},
		{
			name = "stops_activity",
			type = types.boolean,
			default = false,
			template = true,
			doc = [[
If true, this effect will stop any active activities on the applied character.
]],
		},
		{
			name = "related_element",
			type = types.optional(types.data_id("base.element")),
		},
		{
			name = "calc_adjusted_power",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "power", types.number)),
		},
		{
			name = "calc_additive_power",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "power", types.number)),
		},
		{
			name = "on_sleep",
			type = types.optional(
				types.some(types.literal("remove"), types.callback("chara", types.map_object("base.chara")))
			),
		},
		{
			name = "auto_heal",
			type = types.boolean,
			default = true,
			template = true,
			doc = [[
If true, this effect will be healed when the turn starts.

False for sickness and choking on mochi.
]],
		},
	},
})

data:add_type({
	name = "activity",
	fields = {
		{
			name = "elona_id",
			type = types.optional(types.uint),
		},
		{
			name = "params",
			type = types.map(types.string, types.type),
			default = {},
		},
		{
			name = "default_turns",
			type = types.some(types.uint, types.callback({ "self", types.interface(IActivity) }, types.int)),
			default = 10,
		},
		{
			name = "animation_wait",
			type = types.some(
				types.positive(types.number),
				types.callback({ "self", types.interface(IActivity) }, types.number)
			),
		},
		{
			name = "auto_turn_anim",
			type = types.optional(
				types.some(
					types.data_id("base.auto_turn_anim"),
					types.callback({ "self", types.interface(IActivity) }, types.data_id("base.auto_turn_anim"))
				)
			),
		},
		{
			name = "localize",
			type = types.optional(
				types.some(types.locale_id, types.callback({ "self", types.interface(IActivity) }, types.locale_id))
			),
		},
		{
			name = "can_scroll",
			type = types.boolean,
			default = false,
		},
		{
			name = "on_start",
			type = types.optional(types.callback("self", types.interface(IActivity), "params", types.table)),
		},
		{
			name = "on_finish",
			type = types.optional(types.callback("self", types.interface(IActivity), "params", types.table)),
		},
		{
			name = "on_pass_turns",
			type = types.optional(
				types.callback({ "self", types.interface(IActivity), "params", types.table }, types.string)
			),
		},
		{
			name = "on_interrupt",
			type = types.literal("ignore", "prompt", "stop"),
		},
		{
			name = "interrupt_on_displace",
			type = types.boolean,
			default = false,
		},
		{
			name = "events",
			type = types.list(ty_event),
			default = {},
			doc = [[
List of events to bind to this activity when it is created.
]],
		},
	},
}, { interface = IActivity })

data:add_type({
	name = "body_part",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "icon",
			type = types.uint, -- TODO: needs to be themable
		},
	},
})

local ty_image_entry = types.some(
	-- "graphic/chip.png",
	types.path,

	-- {
	--   image = "graphic/chip.bmp",
	--   count_x = 1,
	--   key_color = {0, 0, 0}
	-- }
	types.fields_strict({
		image = types.path,
		count_x = types.optional(types.uint),
		key_color = types.optional(types.some(types.color, types.literal("none"))),
	}),

	-- {
	--   height = 48,
	--   source = "graphic/map0.bmp",
	--   width = 48,
	--   x = 0,
	--   y = 0,
	--   count_x = 1,
	--   key_color = {0, 0, 0}
	-- }
	types.fields_strict({
		source = types.path,
		width = types.uint,
		height = types.uint,
		x = types.uint,
		y = types.uint,
		count_x = types.optional(types.uint),
		count_y = types.optional(types.uint),
		key_color = types.optional(types.some(types.color, types.literal("none"))),
	})
)

-- {
--   default = "graphic/chip.bmp",
--   anim1 = { image = "graphic/chip1.bmp", count_x = 2 }
-- }
local ty_image_anims = types.map(types.string, ty_image_entry)

local ty_image = types.some(ty_image_entry, ty_image_anims)

data:add_type({
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
			type = ty_image,
		},
		{
			name = "field_type",
			type = types.optional(types.data_id("elona.field_type")),
		},
		{
			name = "kind",
			type = types.enum(Enum.TileRole),
			default = Enum.TileRole.None,
		},
		{
			name = "kind2",
			type = types.enum(Enum.TileRole),
			default = Enum.TileRole.None,
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
			name = "is_feat",
			type = types.boolean,
			default = false,
		},
		{
			name = "show_name",
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
			name = "mining_difficulty",
			type = types.uint,
			default = 0,
		},
		{
			name = "mining_difficulty_coefficient",
			type = types.uint,
			default = 30,
		},
		{
			name = "anime_frame",
			type = types.optional(types.uint),
		},
		{
			name = "count_x",
			type = types.optional(types.uint),
		},
		{
			name = "disable_in_map_edit",
			type = types.boolean,
			default = false,
		},
	},
})

local ty_alignment = types.literal("positive", "negative")

data:add_type({
	name = "enchantment",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "level",
			type = types.int,
			default = 1,
			template = true,
			doc = [[
Level of this enchantment.
]],
		},
		{
			name = "value",
			type = types.uint,
			default = 100,
			template = true,
			doc = [[
Value of this enchantment.
]],
		},
		{
			name = "rarity",
			type = types.uint,
			template = true,
			doc = [[
Rarity of this enchantment. Lower means more rare.
]],
		},
		{
			name = "icon",
			type = types.optional(types.uint), -- TODO: needs to be themable
		},
		{
			name = "color",
			type = types.optional(types.color),
		},
		{
			name = "params",
			type = types.map(types.string, types.type),
			default = {},
		},
		{
			name = "filter",
			type = types.optional(types.callback({ "item", types.map_object("base.item") }, types.boolean)),
			template = true,
			doc = [[
Function to filter which items this enchantment will get applied to. If nil, it
can be applied to any item generated randomly.
]],
		},
		{
			name = "on_generate",
			type = types.optional(
				types.callback(
					{
						"self",
						types.data_entry("base.enchantment"),
						"item",
						types.map_object("base.item"),
						"params",
						types.table,
					},
					types.boolean
				)
			),
			template = true,
		},
		{
			name = "on_initialize",
			type = types.optional(
				types.callback(
					"self",
					types.data_entry("base.enchantment"),
					"item",
					types.map_object("base.item"),
					"params",
					types.table
				)
			),
			template = true,
		},
		{
			name = "localize",
			type = types.optional(
				types.callback(
					{ "power", types.number, "params", types.table, "item", types.map_object("base.item") },
					types.string
				)
			),
			template = true,
		},
		{
			name = "on_refresh",
			type = types.optional(
				types.callback(
					"power",
					types.number,
					"params",
					types.table,
					"item",
					types.map_object("base.item"),
					"chara",
					types.map_object("base.chara")
				)
			),
			template = true,
		},
		{
			name = "on_attack_hit",
			type = types.optional(
				types.callback(
					"power",
					types.number,
					"enc_params",
					types.table,
					"chara",
					types.map_object("base.chara"),
					"params",
					types.table
				)
			),
			template = true,
		},
		{
			name = "on_turns_passed",
			type = types.optional(
				types.callback(
					"power",
					types.number,
					"params",
					types.table,
					"item",
					types.map_object("base.item"),
					"chara",
					types.map_object("base.chara")
				)
			),
			template = true,
		},
		{
			name = "on_eat_food",
			type = types.optional(
				types.callback(
					"power",
					types.number,
					"enc_params",
					types.table,
					"item",
					types.map_object("base.item"),
					"chara",
					types.map_object("base.chara")
				)
			),
			template = true,
		},
		{
			name = "compare",
			type = types.optional(
				types.callback({ "my_params", types.table, "other_params", types.table }, types.boolean)
			),
		},
		{
			name = "alignment",
			type = types.some(ty_alignment, types.callback({ "power", types.number }, ty_alignment)),
			default = "positive",
			template = true,
			doc = [[
Determines if this enchantment is beneficial or not. One of "positive" or "negative".
]],
		},
		{
			name = "adjusted_power",
			type = types.optional(types.callback({ "power", types.number }, types.number)),
			--          default = CodeGenerator.gen_literal [[
			-- function(power, item, wearer)
			--       return power / 50
			--    end
			-- ]],
			template = true,
			doc = [[
How to adjust the power when applying the enchantment.
]],
		},
		{
			name = "no_merge",
			type = types.boolean,
			default = false,
		},
	},
})

data:add_type({
	name = "ego_enchantment",
	fields = {
		{
			name = "level",
			type = types.uint,
			template = true,
			doc = [[
Level of this ego enchantment. Typically between 0-3.
]],
		},
		{
			name = "filter",
			type = types.callback("item", types.map_object("base.item")),
			template = true,
			doc = [[
A function to filter which items this ego can get applied to.
]],
		},
		{
			name = "enchantments",
			type = types.list(ty_enchantment_def),
			default = {},
			template = true,
			doc = [[
List of enchantments and their powers to apply.
]],
		},
	},
})

data:add_type({
	name = "ego_minor_enchantment",
	fields = {},
})

local ty_target_type = types.literal(
	"self",
	"nearby",
	"self_or_nearby",
	"enemy",
	"other",
	"location",
	"direction",
	"target_or_location"
)
local ty_triggered_by = types.literal(
	"spell",
	"action",
	"wand",
	"potion",
	"potion_thrown",
	"potion_spilt",
	"use",
	"open"
)

data:add_type({
	name = "enchantment_skill",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "skill_id",
			type = types.data_id("base.skill"),
			template = true,
			doc = [[
Skill to trigger.
]],
		},
		{
			name = "target_type",
			type = ty_target_type,
			default = "self",
			template = true,
			doc = [[
The target of the skill. Same format as that of "base.skill". Usually either "self" or "enemy".
]],
		},
		{
			name = "rarity",
			type = types.uint,
			default = 100,
			template = true,
			doc = [[
Rarity of this enchantment skill when generating an enchantment containing it.
]],
		},
		{
			name = "categories",
			type = types.list(types.data_id("base.item_type")),
			default = { "elona.equip_melee", "elona.equip_ranged" },
			template = true,
			doc = [[
Valid item categories this enchantment skill applies to.
]],
		},
		{
			name = "power",
			type = types.number,
			default = 10,
			template = true,
			doc = [[
Power of the skill when it is triggered.
]],
		},
		{
			name = "chance",
			type = types.number,
			default = 10,
			template = true,
			doc = [[
Chance to trigger skill.
]],
		},
	},
})

data:add_type({
	name = "ammo_enchantment",
	fields = {
		{
			name = "ammo_amount",
			type = types.uint,
			default = 30,
			template = true,
			doc = [[
Controls the starting amount of ammo.
]],
		},
		{
			name = "ammo_factor",
			type = types.uint,
			default = 70,
			template = true,
			doc = [[
Controls the starting amount of ammo.
]],
		},
		{
			name = "stamina_cost",
			type = types.number,
			default = 1,
			template = true,
			doc = [[
Stamina cost of the ammo when fired.
]],
		},
		{
			name = "on_calc_damage",
			type = types.optional(
				types.callback(
					{ "ammo", types.map_object("base.item"), "params", types.table },
					types.fields({ damage = types.number })
				)
			),
		},
		{
			name = "on_ranged_attack",
			type = types.optional(
				types.callback(
					"chara",
					types.map_object("base.chara"),
					"weapon",
					types.optional(types.map_object("base.item")),
					"target",
					types.map_object("base.chara"),
					"skill",
					types.data_id("base.skill"),
					"ammo",
					types.map_object("base.item"),
					"ammo_enchantment_id",
					types.data_id("base.skill")
				)
			),
		},
		{
			name = "on_attack_hit",
			type = types.optional(types.callback("chara", types.map_object("base.chara"), "params", types.table)),
		},
	},
})

local ty_dice = types.fields_strict({
	x = types.number,
	y = types.number,
	bonus = types.number,
})

local ty_damage_params = types.fields({
	dmgfix = types.number,
	dice_x = types.int,
	dice_y = types.int,
	multiplier = types.number,
	pierce_rate = types.number,
})

data:add_type({
	name = "skill",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "type",
			type = types.literal(
				"stat",
				"stat_special",
				"skill",
				"spell",
				"action",
				"skill_action",
				"effect",
				"weapon_proficiency"
			),
			default = "skill",
			template = true,
			doc = [[
Determines how this skill is treated in the interface.
]],
		},
		{
			name = "is_main_skill",
			type = types.boolean,
			default = false,
			doc = [[
If true, this skill will gain a level bonus for every character that is created.
]],
		},
		{
			name = "related_skill",
			type = types.optional(types.data_id("base.skill")),
			default = nil,
			template = true,
			doc = [[
A related stat to improve when this skill is used. Affects the skill's icon in the menus.
]],
		},
		{
			name = "cost",
			type = types.number,
			default = 10,
			template = true,
			doc = [[
Cost to apply when triggering this skill.

Used only when the skill's `type` is "spell" or "action".
]],
		},
		{
			name = "range",
			type = types.uint,
			default = 0,
			template = true,
			doc = [[
Range of this skill, passed to the magic casting system.

This parameter also affects how the default AI will attempt to use the skill, in
combination with the `target_type` field.

Used only when the skill's `type` is "spell" or "action".
]],
		},
		{
			name = "difficulty",
			type = types.uint,
			default = 0,
			template = true,
			doc = [[
Difficulty of triggering this skill.

Used only when the skill's `type` is "spell" or "action".
]],
		},
		{
			name = "effect_id",
			type = types.optional(types.data_id("elona_sys.magic")),
		},
		{
			name = "is_rapid_magic",
			type = types.boolean,
			default = false,
		},
		{
			name = "alignment",
			type = types.optional(ty_alignment),
		},
		{
			name = "calc_initial_level",
			type = types.optional(types.callback("level", types.number, "chara", types.map_object("base.chara"))),
		},
		{
			name = "calc_critical_damage",
			type = types.optional(types.callback("self", types.table, "params", types.table)),
		},
		{
			name = "calc_damage_params",
			type = types.optional(
				types.callback(
					{
						"self",
						types.data_entry("base.skill"),
						"chara",
						types.map_object("base.chara"),
						"weapon",
						types.optional(types.map_object("base.item")),
						"target",
						types.map_object("base.chara"),
					},
					ty_damage_params
				)
			),
		},
		{
			name = "calc_final",
			type = types.optional(
				types.callback({ "level", types.int }, types.fields({ level = types.int, potential = types.uint }))
			),
		},
		{
			name = "on_check_can_cast",
			type = types.optional(
				types.callback(
					{ "skill_data", types.data_entry("base.skill"), "caster", types.map_object("base.chara") },
					types.boolean
				)
			),
		},
		{
			name = "on_choose_target",
			type = types.optional(
				types.callback(
					"target_type",
					ty_target_type,
					"range",
					types.number,
					"caster",
					types.map_object("base.chara"),
					"triggered_by",
					ty_triggered_by,
					"ai_target",
					types.map_object("base.chara"),
					"check_ranged_if_self",
					types.boolean
				)
			),
		},
		{
			name = "calc_desc",
			type = types.optional(
				types.callback("chara", types.map_object("base.chara"), "power", types.number, "dice", ty_dice)
			),
		},
		{
			name = "calc_mp_cost",
			type = types.optional(
				types.callback("skill_entry", types.data_entry("base.skill"), "chara", types.map_object("base.chara"))
			),
		},
		{
			-- TODO should be themable
			name = "attack_animation",
			type = types.optional(types.uint),
		},
		{
			name = "target_type",
			type = ty_target_type,
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
]],
		},
		{
			name = "ignore_missing_target",
			type = types.boolean,
			default = false,
			doc = [[
If true, continue to use the skill even if a target character was not found.

This is used by the Pickpocket skill to select an item on the ground independent of a target character.
]],
		},
		{
			name = "ai_check_ranged_if_self",
			type = types.boolean,
			default = false,
		},
	},
})

data:add_type({
	name = "trait",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "level_min",
			type = types.int,
		},
		{
			name = "level_max",
			type = types.int,
		},
		{
			name = "type",
			type = types.literal("feat", "mutation", "race", "ether_disease"),
		},
		{
			name = "can_acquire",
			type = types.optional(
				types.callback(
					{ "self", types.data_entry("base.trait"), "chara", types.map_object("base.chara") },
					types.boolean
				)
			),
		},
		{
			name = "on_modify_level",
			type = types.optional(
				types.callback("cur_level", types.int, "chara", types.map_object("base.chara"), "prev_level", types.int)
			),
		},
		{
			name = "on_refresh",
			type = types.optional(
				types.callback("self", types.data_entry("base.trait"), "chara", types.map_object("base.chara"))
			),
		},
		{
			name = "on_turn_begin",
			type = types.optional(
				types.callback(
					{ "self", types.data_entry("base.trait"), "chara", types.map_object("base.chara") },
					types.any
				)
			),
		},
		{
			name = "locale_params",
			type = types.optional(
				types.callback(
					{ "self", types.data_entry("base.trait"), "chara", types.map_object("base.chara") },
					types.any
				)
			),
		},
	},
})

data:add_type({
	name = "sound",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "file",
			type = types.path,
		},
		{
			name = "volume",
			type = types.number,
			default = 1.0,
		},
	},
})

data:add_type({
	name = "music",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "file",
			type = types.path,
		},
	},
})

data:add_type({
	name = "ui_indicator",
	fields = {
		{
			name = "indicator",
			type = ty_indicator_cb,
		},
	},
})

data:add_type({
	name = "scenario",
	fields = {
		{
			name = "on_game_start",
			type = types.callback("self", types.data_entry("base.scenario"), "player", types.map_object("base.chara")),
			template = true,
			doc = [[
Function called on game begin. Is passed the created player.
]],
		},
	},
})

data:add_type({
	name = "theme",
	fields = {
		{
			name = "overrides",
			type = types.map(types.data_type_id, types.table),
			template = true,
		},
	},
})

data:add_type({
	name = "theme_transform",

	fields = {
		{
			name = "applies_to",
			type = types.data_type_id,
			template = true,
		},
		{
			name = "transform",
			type = types.callback({ "old", types.table, "new", types.table }, types.table),
			template = true,
		},
	},
})

local ty_region = types.tuple(types.uint, types.uint, types.uint, types.uint)

data:add_type({
	name = "asset",
	fields = {
		{
			name = "type",
			type = types.literal("asset", "font", "color"),
			default = "asset",
		},

		-- asset
		{
			name = "image",
			type = types.optional(types.path),
		},
		{
			name = "source",
			type = types.optional(types.path),
		},
		{
			name = "x",
			type = types.optional(types.uint),
		},
		{
			name = "y",
			type = types.optional(types.uint),
		},
		{
			name = "width",
			type = types.optional(types.uint),
		},
		{
			name = "height",
			type = types.optional(types.uint),
		},
		{
			name = "count_x",
			type = types.optional(types.uint),
		},
		{
			name = "count_y",
			type = types.optional(types.uint),
		},
		{
			name = "regions",
			type = types.optional(
				types.some(
					types.values(ty_region),
					types.callback({ "width", types.number, "height", types.number }, types.values(ty_region))
				)
			),
		},
		{
			name = "key_color",
			type = types.optional(types.some(types.literal("none"), types.color)),
		},

		-- font
		{
			name = "size",
			type = types.optional(types.uint),
		},

		-- color
		{
			name = "color",
			type = types.optional(types.color),
		},
	},
})

data:add_type({
	name = "chip",
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
			type = ty_image,
			template = true,
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
]],
		},
		{
			name = "group",
			type = types.string,
		},
		{
			name = "shadow",
			type = types.optional(types.uint),
			default = 0,
		},
		{
			-- TODO
			name = "effect",
			type = types.optional(types.uint),
		},
		{
			name = "is_tall",
			type = types.boolean,
			default = false,
		},
		{
			name = "stack_height",
			type = types.optional(types.int),
			default = 8,
		},
		{
			name = "y_offset",
			type = types.optional(types.int),
			default = 0,
			template = true,
			doc = [[
Y offset of the sprite in pixels.
         ]],
		},
	},
})

data:add_type({
	name = "ai_action",
	fields = {
		{
			name = "act",
			type = types.some(
				types.callback({ "chara", types.map_object("base.chara"), "params", types.table }, types.boolean),
				types.list(types.data_id("base.ai_action"))
			),
			template = true,
			doc = [[
Runs arbitrary AI actions. Is passed the character and extra parameters, differing depending on the action.

Returns true if the character acted, false if not.
]],
		},
	},
})

data:add_type({
	name = "talk_event",
	fields = {
		{
			name = "elona_txt_id",
			type = types.optional(types.string),
		},
		{
			name = "variant_ids",
			type = types.optional(types.table),
		},
		{
			name = "variant_txt_ids",
			type = types.optional(types.table),
		},
	},
})

data:add_type({
	name = "tone",

	fields = {
		{
			name = "author",
			type = types.optional(types.string),
		},
		{
			name = "show_in_menu",
			type = types.boolean,
			default = false,
		},
		{
			name = "texts",
			template = true,
			type = types.map(
				types.string,
				types.map(
					types.data_id("base.talk_event"),
					types.list(
						types.some(
							types.string,
							types.callback(
								"t",
								types.table,
								"env",
								types.table,
								"args",
								types.table,
								"chara",
								types.map_object("base.map_object")
							)
						)
					)
				)
			),
		},
	},
})

data:add_type({
	name = "portrait",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "image",
			type = ty_image,
		},
	},
})

data:add_type({
	name = "keybind",
	fields = {
		{
			name = "default",
			type = types.string,
		},
		{
			name = "default_alternate",
			type = types.optional(types.list(types.string)),
		},
		{
			name = "uses_shift_delay",
			type = types.boolean,
			default = false,
		},
	},
})

data:add_type({
	name = "pcc_part",
	fields = {
		{
			name = "kind",
			type = types.literal(
				"belt",
				"body",
				"boots",
				"chest",
				"cloth",
				"etc",
				"eye",
				"glove",
				"hair",
				"hairbk",
				"leg",
				"mantle",
				"mantlebk",
				"pants",
				"ride",
				"ridebk",
				"subhair"
			),
		},
		{
			name = "image",
			type = types.path,
		},
		{
			name = "key_color",
			type = types.optional(types.color),
		},
	},
})

data:add_type({
	name = "map_archetype",
	fields = {
		{
			name = "elona_id",
			type = types.optional(types.uint),
		},
		{
			name = "starting_pos",
			type = types.optional(
				types.callback(
					"map",
					types.class(InstancedMap),
					"chara",
					types.map_object("base.chara"),
					"prev_map",
					types.optional(types.class(InstancedMap)),
					"feat",
					types.optional(types.map_object("base.feat"))
				)
			),
			template = true,
			doc = [[
Callback run when this map is restocked, refreshing things like shop inventories.
]],
		},
		{
			name = "on_generate_map",
			type = types.optional(types.callback({ "area", types.class(InstancedArea) }, types.class(InstancedMap))),
			template = true,
			doc = [[
Callback run when this map is to be generated. Must return the final map.
]],
		},
		{
			name = "on_map_renew_minor",
			type = types.optional(types.callback("map", types.class(InstancedMap), "params", types.table)),
			template = true,
			doc = [[
Callback run when this map is restocked, refreshing things like shop inventories.
]],
		},
		{
			name = "on_map_renew_major",
			type = types.optional(types.callback("map", types.class(InstancedMap), "params", types.table)),
			template = true,
			doc = [[
Callback run when this map is renewed, in order to regenerate its geometry.
]],
		},
		{
			name = "on_map_renew_geometry",
			type = types.optional(types.callback("map", types.class(InstancedMap), "params", types.table)),
			template = true,
			doc = [[
Callback run when this map's geometry is recreated from scratch.

Used for restoring towns to their pristine condition after destroying their terrain.
]],
		},
		{
			name = "on_map_loaded",
			type = types.optional(types.callback("map", types.class(InstancedMap), "params", types.table)),
			template = true,
			doc = [[
Callback run when this map is about to be entered.
]],
		},
		{
			name = "on_map_entered",
			type = types.optional(types.callback("map", types.class(InstancedMap), "params", types.table)),
			template = true,
			doc = [[
Callback run when this map is being entered (after on_map_loaded is called).
]],
		},
		{
			name = "on_map_pass_turn",
			type = types.optional(
				types.callback(
					{ "map", types.class(InstancedMap), "params", types.table, "result", types.string },
					types.string
				)
			),
			template = true,
			doc = [[
Callback run when a turn is passed in this map.
]],
		},
		{
			name = "properties",
			type = types.map(types.string, types.any),
			template = true,
			doc = [[
Properties to copy to this map after it is generated. Does not override any values already set in the `on_generate` callback.
]],
		},
		{
			name = "chara_filter",
			type = types.optional(types.callback({ "map", types.class(InstancedMap) }, ty_chara_filter)),
			template = true,
			doc = [[
Properties to copy to this map after it is generated. Does not override any values already set in the `on_generate` callback.
]],
		},
		{
			name = "events",
			type = types.list(ty_event),
			default = {},
			template = false,
			doc = [[
Additional events to bind to this map when it is loaded.
]],
		},
	},
})

local ty_area_type = types.literal("town", "dungeon", "guild", "shelter", "field", "quest", "player_owned", "world_map")

data:add_type({
	name = "area_archetype",
	fields = {
		{
			name = "elona_id",
			type = types.optional(types.uint),
		},
		{
			name = "on_generate_floor",
			type = types.optional(
				types.callback({ "area", types.class(InstancedArea), "floor", types.int }, types.class(InstancedMap))
			),
			template = true,
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
]],
		},
		{
			name = "image",
			type = types.data_id("base.chip"),
			default = "elona.feat_area_village",
			template = true,
			doc = [[
Image this area will have when created with Area.create_entrance().
]],
		},
		{
			name = "types",
			type = types.list(ty_area_type),
			default = {},
		},
		{
			name = "metadata",
			type = types.fields({
				can_return_to = types.optional(types.boolean),
			}),
			default = {},
		},
		{
			name = "floors",
			type = types.map(types.int, types.data_id("base.map_archetype")),
			default = {},
		},
		{
			name = "deepest_floor",
			type = types.optional(types.int),
			default = nil,
			template = false,
			doc = [[
Deepest floor of this area. Used with generating dungeons.
]],
		},
		{
			name = "parent_area",
			type = types.optional(types.fields_strict({
				_id = types.data_id("base.area_archetype"),
				on_floor = types.uint,
				x = types.uint,
				y = types.uint,
				starting_floor = types.uint,
			})),
			default = nil,
			template = true,
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
]],
		},
	},
})

data:add_type({
	name = "damage_reaction",
	fields = {
		{
			name = "on_damage",
			type = types.callback(
				"chara",
				types.map_object("base.chara", "power", types.number, "params", types.params)
			),
			template = true,
			doc = [[
Behavior to trigger when this character is melee attacked.
]],
		},
	},
})

data:add_type({
	name = "language",
	fields = {
		{
			name = "language_code",
			type = types.string,
			template = true,
			doc = [[
The language code for this language.

Translations will be loaded from the folder with this language code under the
locale/ folder of each mod. Prefer using an ISO 639-2/B code if available.

You can reuse the language code of an existing language, for example if you
wanted to create a mod that modifies the translated text using English as a
base.
]],
		},
	},
})

local ty_dialog_choice_entry = types.tuple(types.string, types.some(types.locale_id, types.literal("MORE", "BYE")))
local ty_dialog_choice_cb = types.callback(
	{ "speaker", types.map_object("base.chara"), "state", types.table },
	types.list(ty_dialog_choice_entry)
)
local ty_dialog_choice = types.some(ty_dialog_choice_entry, ty_dialog_choice_cb)

data:add_type({
	name = "role",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "dialog_choices",
			type = types.list(ty_dialog_choice),
			default = {},
		},
	},
})

data:add_type({
	name = "config_option_type",
	fields = {
		{
			name = "validate",
			type = types.callback(
				{ "option", types.data_entry("base.config_option"), "value", types.any },
				{ types.boolean, types.optional(types.string) }
			),
			template = true,
			doc = [[
Used to validate if a value for this config option type is valid.
]],
		},
		{
			name = "widget",
			type = types.some(
				types.require_path,
				types.callback({ "proto", types.data_entry("base.config_option") }, types.interface(IConfigItemWidget))
			),
			template = true,
			doc = [[
Require path of the widget used to display this config option type.

It must implement IConfigItemWidget.
]],
		},
		{
			name = "fields",
			type = types.map(types.string, types.type),
			doc = [[
Extra fields for configuring this config option type.
]],
		},
		{
			name = "default",
			type = types.some(
				types.serializable,
				types.callback({ "option", types.data_entry("base.config_option") }, types.serializable)
			),
			doc = [[
Default value of this config option type.
]],
		},
	},
})

data:add_type({
	name = "config_option",
	fields = {
		{
			name = "type",
			type = types.some(
				types.literal("boolean", "string", "number", "integer", "enum", "table", "data_id", "any"),
				types.data_id("base.config_option_type")
			),
			template = true,
			no_fallback = true,
			doc = [[
Type of this config option.

One of "boolean", "string", "number", "integer", "enum", "table", "data_id" or "any".
]],
		},
		{
			name = "default",
			type = types.any,
			template = true,
			no_fallback = true,
			doc = [[
Default value of this config option.
]],
		},
		{
			name = "choices",
			type = types.optional(types.some(types.list(types.string), types.callback({}, types.list(types.string)))),
			no_fallback = true,
			doc = [[
Only used if the type is "enum".

The list of enum variants of this config option.
]],
		},
		{
			name = "data_type",
			type = types.optional(types.data_type_id),
			no_fallback = true,
			doc = [[
Only used if the type is "data_id".

The data type of the ID in this config option.
]],
		},
		{
			name = "on_changed",
			type = types.optional(types.callback("value", types.any, "is_startup", types.boolean)),
			no_fallback = true,
			doc = [[
Callback run immediately after this option is changed in the settings menu.

"is_startup" is true if the option was set from the intial config load at startup.
]],
		},
	},
	validation = "permissive",
})

local ty_config_menu_item = types.some(
	types.data_id("base.config_option"),
	types.fields({ _type = types.literal("base.config_menu"), _id = types.data_id("base.config_menu") })
)

data:add_type({
	name = "config_menu",
	fields = {
		{
			name = "items",
			type = types.optional(types.list(ty_config_menu_item)),
			doc = [[
List of config options in this config menu.
]],
		},
		{
			name = "impl",
			type = types.optional(types.class_type_implementing(IConfigMenu)),
		},
		{
			name = "menu_width",
			type = types.uint,
			default = 440,
			doc = [[
Height of this menu in pixels, when using the default config menu UI.
]],
		},
		{
			name = "menu_height",
			type = types.uint,
			default = 300,
			doc = [[
Height of this menu in pixels, when using the default config menu UI.
]],
		},
	},
	on_validate = function(entry)
		if entry.items == nil and entry.impl == nil then
			return false, "One of 'items' or 'impl' must be specified."
		end

		return true
	end,
})

data:add_type({
	name = "auto_turn_anim",
	fields = {
		{
			name = "sound",
			type = types.data_id("base.sound"),
		},
		{
			name = "on_start_callback",
			type = types.optional(types.callback()),
		},
		{
			name = "callback",
			type = types.callback({ "x", types.number, "y", types.number, "t", types.table }, types.callback()),
		},
		{
			name = "draw",
			type = types.callback({ "x", types.number, "y", types.number, "t", types.table }),
		},
	},
})

data:add_type({
	name = "equipment_type",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "on_initialize_equipment",
			type = types.callback(
				"chara",
				types.map_object("base.chara"),
				"equip_spec",
				ty_equip_spec,
				"gen_chance",
				types.uint
			),
		},
		{
			name = "on_drop_loot",
			type = types.optional(
				types.callback(
					"chara",
					types.map_object("base.chara"),
					"attacker",
					types.optional(types.map_object("base.chara")),
					"drops",
					types.list(ty_drop)
				)
			),
		},
	},
})

data:add_type({
	name = "loot_type",
	fields = {
		{
			name = "elona_id",
			indexed = true,
			type = types.optional(types.uint),
		},
		{
			name = "on_drop_loot",
			type = types.callback(
				"chara",
				types.map_object("base.chara"),
				"attacker",
				types.optional(types.map_object("base.chara")),
				"drops",
				types.list(ty_drop)
			),
		},
	},
})

data:add_type({
	name = "trait_indicator",
	fields = {
		{
			name = "applies_to",
			type = types.callback("chara", types.map_object("base.chara")),
		},
		{
			name = "make_indicator",
			type = types.callback(
				{ "chara", types.map_object("base.chara") },
				types.fields_strict({ desc = types.string, color = types.optional(types.color) })
			),
		},
	},
})

data:add_type({
	name = "journal_page",
	fields = {
		{
			name = "render",
			type = types.callback({}, types.string),
		},
	},
})
