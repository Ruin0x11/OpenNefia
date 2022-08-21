local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

--
-- Small Shield
--

data:add({
	_type = "base.item",
	_id = "knight_shield",
	elona_id = 59,
	image = "elona.item_knight_shield",
	value = 4800,
	weight = 2200,
	material = "elona.metal",
	level = 30,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 8,
			dv = -2,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "small_shield",
	elona_id = 449,
	image = "elona.item_small_shield",
	value = 500,
	weight = 1200,
	material = "elona.metal",
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 4,
			dv = 3,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "round_shield",
	elona_id = 450,
	image = "elona.item_round_shield",
	value = 1200,
	weight = 1500,
	material = "elona.metal",
	level = 10,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 5,
			dv = 4,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "shield",
	elona_id = 451,
	image = "elona.item_shield",
	value = 2500,
	weight = 1000,
	material = "elona.metal",
	level = 20,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 6,
			dv = 3,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "large_shield",
	elona_id = 452,
	image = "elona.item_large_shield",
	value = 7500,
	weight = 1400,
	material = "elona.metal",
	level = 40,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 8,
			dv = 2,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "kite_shield",
	elona_id = 453,
	image = "elona.item_kite_shield",
	value = 10000,
	weight = 3500,
	material = "elona.metal",
	level = 50,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 13,
			dv = -3,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "tower_shield",
	elona_id = 454,
	image = "elona.item_tower_shield",
	value = 18000,
	weight = 2400,
	material = "elona.metal",
	level = 60,
	coefficient = 100,

	skill = "elona.shield",

	categories = {
		"elona.equip_shield_shield",
		"elona.equip_shield",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 10,
			dv = -1,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "alud",
	elona_id = 726,
	image = "elona.item_alud",
	value = 7500,
	weight = 2850,
	material = "elona.wood",
	level = 15,
	fltselect = Enum.FltSelect.SpUnique,
	coefficient = 100,

	skill = "elona.shield",

	is_precious = true,
	identify_difficulty = 500,
	quality = Enum.Quality.Unique,

	color = { 255, 255, 175 },

	categories = {
		"elona.equip_shield_shield",
		"elona.unique_item",
		"elona.equip_shield",
	},

	light = "elona.item",

	enchantments = {
		{ _id = "elona.modify_skill", power = -450, params = { skill_id = "elona.performer" } },
		{ _id = "elona.damage_resistance", power = 400 },
		{ _id = "elona.damage_immunity", power = 400 },
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			pv = 35,
			dv = -1,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "shield_of_thorn",
	elona_id = 727,
	image = "elona.item_small_shield",
	value = 17500,
	weight = 950,
	material = "elona.coral",
	level = 15,
	fltselect = Enum.FltSelect.Unique,
	coefficient = 100,

	skill = "elona.shield",

	is_precious = true,
	identify_difficulty = 500,
	quality = Enum.Quality.Unique,

	color = { 255, 155, 155 },

	categories = {
		"elona.equip_shield_shield",
		"elona.unique_weapon",
		"elona.equip_shield",
	},

	light = "elona.item",

	enchantments = {
		{ _id = "elona.damage_reflection", power = 1000 },
		{ _id = "elona.modify_resistance", power = 450, params = { element_id = "elona.nerve" } },
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.hand" },
			damage_bonus = 14,
			pv = 1,
		},
	},
})
