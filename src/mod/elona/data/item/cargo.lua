local light = require("mod.elona.data.item.light")
local IItemCargo = require("mod.elona.api.aspect.IItemCargo")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

--
-- Cargo
--

data:add({
	_type = "base.item",
	_id = "cargo_rag_doll",
	elona_id = 399,
	image = "elona.item_rag_doll",
	value = 700,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 1,
			cargo_weight = 6500,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_barrel",
	elona_id = 400,
	image = "elona.item_barrel",
	value = 420,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 2,
			cargo_weight = 10000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_piano",
	elona_id = 401,
	image = "elona.item_piano",
	value = 4000,
	rarity = 200000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 4,
			cargo_weight = 50000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_rope",
	elona_id = 402,
	image = "elona.item_rope",
	value = 550,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 5,
			cargo_weight = 4800,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_coffin",
	elona_id = 403,
	image = "elona.item_coffin",
	value = 2200,
	rarity = 700000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 3,
			cargo_weight = 12000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_manboo",
	elona_id = 404,
	image = "elona.item_manboo",
	value = 800,
	rarity = 1500000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 0,
			cargo_weight = 10000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_grave",
	elona_id = 405,
	image = "elona.item_grave",
	value = 2800,
	rarity = 800000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 3,
			cargo_weight = 48000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_tuna_fish",
	elona_id = 406,
	image = "elona.item_tuna_fish",
	value = 350,
	rarity = 2000000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 0,
			cargo_weight = 7500,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_whisky",
	elona_id = 407,
	image = "elona.item_whisky",
	value = 1400,
	rarity = 600000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 2,
			cargo_weight = 16000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_noble_toy",
	elona_id = 408,
	image = "elona.item_noble_toy",
	value = 1200,
	rarity = 500000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 1,
			cargo_weight = 32000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_inner_tube",
	elona_id = 409,
	image = "elona.item_inner_tube",
	value = 340,
	rarity = 1500000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 5,
			cargo_weight = 1500,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_christmas_tree",
	elona_id = 597,
	image = "elona.item_christmas_tree",
	value = 3500,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	light = "elona.crystal_high",

	_ext = {
		[IItemCargo] = {
			cargo_quality = 6,
			cargo_weight = 60000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_snow_man",
	elona_id = 598,
	image = "elona.item_snow_man",
	value = 1200,
	rarity = 800000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	light = "elona.item",

	_ext = {
		[IItemCargo] = {
			cargo_quality = 6,
			cargo_weight = 11000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_art",
	elona_id = 669,
	image = "elona.item_painting_of_landscape",
	value = 3800,
	rarity = 150000,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 7,
			cargo_weight = 35000,
		},
	},
})

data:add({
	_type = "base.item",
	_id = "cargo_canvas",
	elona_id = 670,
	image = "elona.item_canvas",
	value = 750,
	coefficient = 100,

	categories = {
		"elona.cargo",
	},

	_ext = {
		[IItemCargo] = {
			cargo_quality = 7,
			cargo_weight = 7000,
		},
	},
})

--
-- Cargo Food
--

data:add({
	_type = "base.item",
	_id = "cargo_travelers_food",
	elona_id = 333,
	image = "elona.item_travelers_food",
	value = 40,
	coefficient = 100,

	categories = {
		"elona.cargo_food",
	},

	_ext = {
		[IItemFood] = {
			food_quality = 3,
		},
		[IItemCargo] = {
			cargo_quality = 0,
			cargo_weight = 2000,
		},
	},
})
