local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")
local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")
local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

--
-- Small Ring
--

data:add({
	_type = "base.item",
	_id = "decorative_ring",
	elona_id = 13,
	knownnameref = "ring",
	image = "elona.item_decorative_ring",
	value = 450,
	weight = 50,
	material = "elona.soft",
	coefficient = 100,
	has_random_name = true,
	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},
	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
		},
	},
})

data:add({
	_type = "base.item",
	_id = "ring_of_steel_dragon",
	elona_id = 357,
	image = "elona.item_decorative_ring",
	value = 30000,
	weight = 1200,
	material = "elona.mithril",
	level = 30,
	fltselect = Enum.FltSelect.SpUnique,
	coefficient = 100,

	is_precious = true,
	identify_difficulty = 500,
	quality = Enum.Quality.Unique,
	categories = {
		"elona.equip_ring_ring",
		"elona.unique_item",
		"elona.equip_ring",
	},
	light = "elona.item",

	enchantments = {
		{ _id = "elona.eater", power = 100 },
		{ _id = "elona.modify_resistance", power = 250, params = { element_id = "elona.magic" } },
		{ _id = "elona.modify_resistance", power = 450, params = { element_id = "elona.lightning" } },
		{ _id = "elona.modify_attribute", power = 450, params = { skill_id = "elona.stat_strength" } },
		{ _id = "elona.modify_skill", power = 550, params = { skill_id = "elona.weight_lifting" } },
		{ _id = "elona.modify_attribute", power = -1400, params = { skill_id = "elona.stat_speed" } },
		{ _id = "elona.res_fear", power = 100 },
		{ _id = "elona.res_paralyze", power = 100 },
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
			pv = 50,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "palmia_pride",
	elona_id = 360,
	image = "elona.item_decorative_ring",
	value = 30000,
	weight = 500,
	material = "elona.mithril",
	level = 30,
	fltselect = Enum.FltSelect.SpUnique,
	coefficient = 100,

	is_precious = true,
	identify_difficulty = 500,
	quality = Enum.Quality.Unique,

	categories = {
		"elona.equip_ring_ring",
		"elona.unique_item",
		"elona.equip_ring",
	},
	light = "elona.item",

	enchantments = {
		{ _id = "elona.res_steal", power = 100 },
		{ _id = "elona.modify_attribute", power = 700, params = { skill_id = "elona.stat_luck" } },
		{ _id = "elona.modify_attribute", power = 350, params = { skill_id = "elona.stat_speed" } },
		{ _id = "elona.modify_attribute", power = 550, params = { skill_id = "elona.stat_charisma" } },
		{ _id = "elona.modify_resistance", power = 200, params = { element_id = "elona.darkness" } },
		{ _id = "elona.modify_resistance", power = 200, params = { element_id = "elona.chaos" } },
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
			pv = 5,
			dv = 15,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "composite_ring",
	elona_id = 474,
	knownnameref = "ring",
	image = "elona.item_composite_ring",
	value = 450,
	weight = 50,
	material = "elona.metal",
	level = 15,
	coefficient = 100,
	has_random_name = true,
	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
			damage_bonus = 2,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "armored_ring",
	elona_id = 475,
	knownnameref = "ring",
	image = "elona.item_armored_ring",
	value = 450,
	weight = 50,
	material = "elona.metal",
	level = 15,
	coefficient = 100,
	has_random_name = true,
	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},
	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
			pv = 2,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "ring",
	elona_id = 476,
	knownnameref = "ring",
	image = "elona.item_ring",
	value = 450,
	weight = 50,
	material = "elona.metal",
	level = 10,
	coefficient = 100,
	has_random_name = true,
	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},
	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
		},
	},
})

data:add({
	_type = "base.item",
	_id = "engagement_ring",
	elona_id = 477,
	knownnameref = "ring",
	image = "elona.item_engagement_ring",
	value = 5200,
	weight = 50,
	material = "elona.metal",
	rarity = 700000,
	coefficient = 100,
	has_random_name = true,
	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
		},
	},

	events = {
		{
			id = "elona.on_item_given",
			name = "Engagement item effects",

			callback = function(self, params)
				-- >>>>>>>> shade2/command.hsp:3821 				if (iId(ci)=idRingEngage)or(iId(ci)=idAmuEngag ...
				-- TODO dedup
				local target = params.target
				Gui.mes_c("ui.inv.give.engagement", "Green", target)
				Skill.modify_impression(target, 15)
				target:set_emotion_icon("elona.heart", 3)
				-- <<<<<<<< shade2/command.hsp:3825 				} ..
			end,
		},
		{
			id = "elona.on_item_taken",
			name = "Swallow engagement item",

			callback = function(self, params)
				-- >>>>>>>> shade2/command.hsp:3935 			if (iId(ci)=idRingEngage)or(iId(ci)=idAmuEngage ...
				local target = params.target

				Gui.mes_c("ui.inv.take_ally.swallows_ring", "Purple", target, self:build_name(1))
				Gui.play_sound("base.offer1")
				Skill.modify_impression(target, -20)
				target:set_emotion_icon("elona.angry", 3)
				self:remove(1)

				return "inventory_continue"
				-- <<<<<<<< shade2/command.hsp:3939 				} ..
			end,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "aurora_ring",
	elona_id = 558,
	knownnameref = "ring",
	image = "elona.item_engagement_ring",
	value = 17000,
	weight = 50,
	material = "elona.metal",
	level = 15,
	rarity = 25000,
	coefficient = 100,
	has_random_name = true,

	before_wish = function(filter, chara)
		-- >>>>>>>> shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
		filter.quality = Calc.calc_object_quality(Enum.Quality.Good)
		return filter
		-- <<<<<<<< shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
	end,

	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},

	enchantments = {
		{ _id = "elona.res_weather", power = 100 },
		{ _id = "elona.modify_resistance", power = 100, params = { element_id = "elona.sound" } },
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
			pv = 2,
			dv = 2,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "speed_ring",
	elona_id = 664,
	knownnameref = "ring",
	image = "elona.item_engagement_ring",
	value = 50000,
	weight = 50,
	material = "elona.metal",
	level = 15,
	rarity = 30000,
	coefficient = 100,
	has_random_name = true,

	on_init_params = function(self)
		local power = Rand.rnd(Rand.rnd(1000) + 1)
		assert(self:add_enchantment("elona.modify_attribute", power, { skill_id = "elona.stat_speed" }, 0, "special"))
	end,

	before_wish = function(filter, chara)
		-- >>>>>>>> shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
		filter.quality = Calc.calc_object_quality(Enum.Quality.Good)
		return filter
		-- <<<<<<<< shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
	end,

	categories = {
		"elona.equip_ring_ring",
		"elona.equip_ring",
	},

	_ext = {
		[IItemEquipment] = {
			equip_slots = { "elona.ring" },
		},
	},
})
