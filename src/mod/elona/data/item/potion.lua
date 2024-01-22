local Item = require("api.Item")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local Skill = require("mod.elona_sys.api.Skill")
local light = require("mod.elona.data.item.light")
local IItemPotion = require("mod.elona.api.aspect.IItemPotion")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")

--
-- Potion
--

data:add({
	_type = "base.item",
	_id = "bottle_of_dirty_water",
	elona_id = 26,
	image = "elona.item_potion",
	value = 100,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "bottle",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_dirty_water", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_blindness",
	elona_id = 27,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 20,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_blind", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_confusion",
	elona_id = 28,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 30,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_confuse", power = 150 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_paralysis",
	elona_id = 29,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 40,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_paralyze", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "sleeping_drug",
	elona_id = 30,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 120,
	weight = 120,
	coefficient = 100,
	has_random_name = true,

	tags = { "nogive" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_sleep", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "poison",
	elona_id = 262,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 120,
	weight = 120,
	coefficient = 100,
	has_random_name = true,

	tags = { "nogive", "elona.is_acid" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_poison", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_potential",
	elona_id = 287,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 50000,
	weight = 120,
	level = 10,
	rarity = 80000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "spshop" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_spshop",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_gain_potential", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_defender",
	elona_id = 364,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 150,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_holy_shield", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_silence",
	elona_id = 368,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 40,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_mist_of_silence", power = 400 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_troll_blood",
	elona_id = 370,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 800,
	weight = 120,
	level = 9,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_regeneration", power = 300 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_resistance",
	elona_id = 372,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 700,
	weight = 120,
	level = 8,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_elemental_shield", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_speed",
	elona_id = 375,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 850,
	weight = 120,
	rarity = 700000,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_speed", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_slow",
	elona_id = 376,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 30,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_slow", power = 400 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_hero",
	elona_id = 379,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 450,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_hero", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_weakness",
	elona_id = 382,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 30,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.buff_mist_of_frailness", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_sulfuric",
	elona_id = 392,
	image = "elona.item_molotov",
	value = 800,
	weight = 50,
	coefficient = 0,
	originalnameref2 = "bottle",

	tags = { "nogive", "elona.is_acid" },

	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_sulfuric", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_weaken_resistance",
	elona_id = 429,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 150,
	weight = 120,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "neg" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_neg",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_weaken_resistance", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_mutation",
	elona_id = 432,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 5000,
	weight = 120,
	level = 8,
	rarity = 200000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,

	tags = { "nogive" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.mutation", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_cure_mutation",
	elona_id = 433,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 4000,
	weight = 120,
	level = 10,
	rarity = 400000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_cure_mutation", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_water",
	elona_id = 516,
	image = "elona.item_potion",
	value = 280,
	weight = 50,
	rarity = 400000,
	coefficient = 0,
	originalnameref2 = "bottle",

	prevent_dip = true,

	medal_value = 3,
	categories = {
		"elona.drink",
	},

	events = {
		{
			id = "base.on_drop_item",
			name = "Bless water on altar of god",

			callback = function(self, params)
				-- >>>>>>>> shade2/action.hsp:298 	if iId(ti)=idWater{ ...
				local chara = params.chara
				local god_id = chara:calc("god")
				if god_id == nil then
					return
				end

				local function find_altar(x, y, map)
					return Item.at(x, y, map)
						:filter(function(i)
							return i:has_category("elona.furniture_altar") and i.params.altar_god_id == god_id
						end)
						:nth(1)
				end

				local map = self:current_map()
				local altar = find_altar(self.x, self.y, map)
				if Item.is_alive(altar) and self.curse_state ~= Enum.CurseState.Blessed then
					Gui.play_sound("base.pray1", self.x, self.y)
					self.curse_state = Enum.CurseState.Blessed
					Gui.mes_c("action.drop.water_is_blessed", "Green")
				end
				-- <<<<<<<< shade2/action.hsp:301 		} ..
			end,
		},
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_water", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_dye",
	elona_id = 519,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 500,
	weight = 120,
	rarity = 2000000,
	coefficient = 100,
	originalnameref2 = "bottle",
	has_random_name = true,

	on_init_params = function(self, params)
		self.color = Rand.choice(Enum.Color:values())
	end,

	tags = { "nogive", "elona.is_acid" },
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_poison", power = 150 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_cure_corruption",
	elona_id = 559,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 100000,
	weight = 120,
	rarity = 30000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	medal_value = 10,
	categories = {
		"elona.drink",
	},

	events = {
		{
			id = "elona.on_item_created_from_wish",
			name = "Adjust amount",

			callback = function(self)
				-- >>>>>>>> shade2/command.hsp:1600 			if iId(ci)=idPotionCureCorrupt		:iNum(ci)=2+rnd ..
				self.amount = 2 + Rand.rnd(2)
				-- <<<<<<<< shade2/command.hsp:1600 			if iId(ci)=idPotionCureCorrupt		:iNum(ci)=2+rnd ..
			end,
		},
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_cure_corruption", power = 200 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "acidproof_liquid",
	elona_id = 566,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 1900,
	weight = 120,
	rarity = 300000,
	coefficient = 100,
	has_random_name = true,

	tags = { "nogive" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_sulfuric", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_milk",
	elona_id = 574,
	image = "elona.item_bottle_of_milk",
	value = 1000,
	weight = 300,
	rarity = 300000,
	coefficient = 100,
	originalnameref2 = "bottle",

	params = { chara_id = nil },

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_milk", power = 100 },
			},
		},
		IItemFromChara,
	},
})

data:add({
	_type = "base.item",
	_id = "molotov",
	elona_id = 577,
	knownnameref = "potion",
	image = "elona.item_molotov",
	value = 400,
	weight = 50,
	level = 10,
	coefficient = 0,
	has_random_name = true,

	tags = { "nogive" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_molotov", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "handful_of_snow",
	elona_id = 587,
	image = "elona.item_handful_of_snow",
	value = 10,
	weight = 50,
	rarity = 100000,
	coefficient = 100,
	originalnameref2 = "handful",

	elona_function = 14,

	on_throw = function(self, params)
		-- >>>>>>>> shade2/action.hsp:57 		if sync(tlocX,tlocY) : if iId(ci)=idSnow{ ...
		local chara = params.chara
		local map = chara:current_map()
		if map:is_in_fov(params.x, params.y) then
			Gui.play_sound("base.snow", params.x, params.y)
		end

		local target = Chara.at(params.x, params.y)
		if target then
			Gui.mes("action.throw.hits", target)
			Effect.get_wet(target, 25)
			target:interrupt_activity()
			if not target:is_player() then
				Gui.mes_c_visible("action.throw.snow.dialog", target.x, target.y, "SkyBlue")
			end
			return "turn_end"
		end
		-- <<<<<<<< shade2/action.hsp:69 			} ..

		-- >>>>>>>> shade2/action.hsp:86 		if iId(ci)=idSnow:if map(tlocX,tlocY,4)!0{ ...
		local snowman = Item.at(params.x, params.y, map)
			:filter(function(i)
				return i._id == "elona.snow_man"
			end)
			:nth(1)
		if snowman then
			if snowman:is_in_fov() then
				Gui.mes("action.throw.snow.hits_snowman", snowman:build_name(1))
			end
			snowman:remove(1)
			return "turn_end"
		end
		-- <<<<<<<< shade2/action.hsp:98 			} ..

		-- >>>>>>>> shade2/action.hsp:100 		if iId(ci)=idSnow{ ...
		if map:tile(params.x, params.y).kind == Enum.TileRole.Snow then
			return "turn_end"
		end
		if map:is_in_fov(params.x, params.y) then
			Gui.mes("action.throw.snow.melts")
		end

		Effect.create_potion_puddle(params.x, params.y, self, chara)
		return "turn_end"
		-- <<<<<<<< shade2/action.hsp:102 			if sync(tlocX,tlocY) :txtMore:txt lang("それは地面に落 ...         end,
	end,

	categories = {
		"elona.drink",
	},
	light = "elona.item",

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_water", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "love_potion",
	elona_id = 620,
	image = "elona.item_potion",
	value = 4500,
	weight = 50,
	level = 5,
	rarity = 150000,
	coefficient = 0,

	tags = { "nogive" },

	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	events = {
		{
			id = "elona.on_item_given",
			name = "Love potion give effect",

			callback = function(self, params)
				-- >>>>>>>> shade2/command.hsp:3826 				if (iId(ci)=idLovePotion){ ...
				local target = params.target

				Gui.mes_c("ui.inv.give.love_potion.text", "Purple", target)
				Gui.mes_c("ui.inv.give.love_potion.dialog", "SkyBlue", target)
				Skill.modify_impression(target, -20)
				target:set_emotion_icon("elona.angry", 3)
				self:remove(1)

				return "inventory_continue"
				-- <<<<<<<< shade2/command.hsp:3831 				} ..
			end,
		},
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_love_potion", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_hermes_blood",
	elona_id = 626,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 50000,
	weight = 120,
	level = 15,
	rarity = 10000,
	coefficient = 100,
	originalnameref2 = "bottle",
	has_random_name = true,

	is_precious = true,

	tags = { "spshop" },
	random_color = "Random",
	medal_value = 30,
	categories = {
		"elona.drink",
		"elona.tag_spshop",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_troll_blood", power = 500 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_salt_solution",
	elona_id = 698,
	image = "elona.item_handful_of_snow",
	value = 10,
	weight = 50,
	rarity = 100000,
	coefficient = 100,
	originalnameref2 = "potion",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_salt", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "vomit",
	elona_id = 704,
	image = "elona.item_vomit",
	value = 400,
	weight = 100,
	rarity = 10000,
	coefficient = 0,

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_dirty_water", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_descent",
	elona_id = 706,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 4500,
	weight = 120,
	rarity = 4000,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	events = {
		{
			id = "elona.on_item_created_from_wish",
			name = "Adjust amount",

			callback = function(self)
				-- >>>>>>>> shade2/command.hsp:1604 			if iId(ci)=idPotionDescent		:iNum(ci)=1 ..
				self.amount = 1
				-- <<<<<<<< shade2/command.hsp:1604 			if iId(ci)=idPotionDescent		:iNum(ci)=1 ..
			end,
		},
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_descent", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_evolution",
	elona_id = 711,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 12000,
	weight = 120,
	rarity = 5000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_evolution", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "fireproof_liquid",
	elona_id = 736,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 1500,
	weight = 120,
	rarity = 300000,
	coefficient = 100,
	has_random_name = true,

	tags = { "nogive" },
	random_color = "Random",
	categories = {
		"elona.drink",
		"elona.tag_nogive",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_sulfuric", power = 250 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_soda",
	elona_id = 770,
	image = "elona.item_bottle_of_soda",
	value = 500,
	weight = 50,
	fltselect = Enum.FltSelect.Sp,
	rarity = 400000,
	coefficient = 0,
	originalnameref2 = "bottle",

	tags = { "fest" },

	categories = {
		"elona.drink",
		"elona.tag_fest",
		"elona.no_generate",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_soda", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "blue_capsule_drug",
	elona_id = 771,
	image = "elona.item_blue_capsule_drug",
	value = 7500,
	weight = 100,
	fltselect = Enum.FltSelect.SpUnique,
	rarity = 5000,
	coefficient = 0,

	quality = Enum.Quality.Unique,

	categories = {
		"elona.drink",
		"elona.unique_item",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_cupsule", power = 100 },
			},
		},
	},
})

--
-- Healing Potion
--

data:add({
	_type = "base.item",
	_id = "potion_of_cure_minor_wound",
	elona_id = 68,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 150,
	weight = 120,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.heal_light", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_cure_major_wound",
	elona_id = 69,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 300,
	weight = 120,
	level = 4,
	coefficient = 100,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.heal_light", power = 300 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_cure_critical_wound",
	elona_id = 70,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 1280,
	weight = 120,
	level = 8,
	coefficient = 50,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.heal_critical", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_healing",
	elona_id = 71,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 3000,
	weight = 120,
	level = 15,
	rarity = 700000,
	coefficient = 50,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.heal_critical", power = 300 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_healer",
	elona_id = 72,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 5000,
	weight = 120,
	level = 25,
	rarity = 600000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.heal_critical", power = 400 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_healer_odina",
	elona_id = 74,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 7500,
	weight = 120,
	level = 35,
	rarity = 500000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.cure_of_eris", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_healer_eris",
	elona_id = 75,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 10000,
	weight = 120,
	level = 45,
	rarity = 250000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.cure_of_eris", power = 300 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_healer_jure",
	elona_id = 76,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 15000,
	weight = 120,
	level = 45,
	rarity = 150000,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.cure_of_jure", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_restore_body",
	elona_id = 285,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 280,
	weight = 120,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.restore_body", power = 100 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "potion_of_restore_spirit",
	elona_id = 286,
	knownnameref = "potion",
	image = "elona.item_potion",
	value = 280,
	weight = 120,
	coefficient = 0,
	originalnameref2 = "potion",
	has_random_name = true,
	random_color = "Random",

	categories = {
		"elona.drink",
		"elona.drink_potion",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.restore_spirit", power = 100 },
			},
		},
	},
})

--
-- Alcohol
--

data:add({
	_type = "base.item",
	_id = "bottle_of_crim_ale",
	elona_id = 31,
	image = "elona.item_potion",
	value = 280,
	weight = 50,
	coefficient = 0,
	originalnameref2 = "bottle",

	categories = {
		"elona.drink",
		"elona.drink_alcohol",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_ale", power = 300 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_whisky",
	elona_id = 205,
	image = "elona.item_bottle_of_whisky",
	value = 180,
	weight = 50,
	coefficient = 100,
	originalnameref2 = "bottle",

	categories = {
		"elona.drink",
		"elona.drink_alcohol",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_ale", power = 500 },
			},
		},
	},
})

data:add({
	_type = "base.item",
	_id = "bottle_of_beer",
	elona_id = 253,
	image = "elona.item_molotov",
	value = 280,
	weight = 50,
	coefficient = 0,
	originalnameref2 = "bottle",

	categories = {
		"elona.drink",
		"elona.drink_alcohol",
	},

	_ext = {
		[IItemPotion] = {
			effects = {
				{ _id = "elona.effect_ale", power = 200 },
			},
		},
	},
})

--
-- Special
--

data:add({
	_type = "base.item",
	_id = "empty_bottle",
	elona_id = 601,
	image = "elona.item_empty_bottle",
	value = 100,
	weight = 120,
	rarity = 800000,
	coefficient = 100,

	on_throw = function(self, params)
		-- >>>>>>>> shade2/action.hsp:118 	if sync(tlocX,tlocY) : txt lang("それは地面に落ちて砕けた。"," ...
		Gui.mes("action.throw.shatters")
		Gui.play_sound("base.crush2", params.x, params.y)
		return "turn_end"
		-- <<<<<<<< shade2/action.hsp:120 	goto *turn_end ..
	end,

	categories = {
		"elona.drink",
	},
})
