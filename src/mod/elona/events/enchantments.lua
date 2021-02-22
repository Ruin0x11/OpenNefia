local Event = require("api.Event")
local Rand = require("api.Rand")
local Enchantment = require("mod.elona.api.Enchantment")
local Enum = require("api.Enum")
local Log = require("api.Log")
local Const = require("api.Const")
local Text = require("mod.elona.api.Text")

local function add_stave_enchantments(item, params)
   -- >>>>>>>> shade2/item_data.hsp:770 	if refTypeMinor=fltStave{ ...
   local encs = {}

   for _ = 1, 1 do
      if Rand.one_in(10) then
         item:add_enchantment("elona.power_magic", Enchantment.random_enc_power(item), "randomized")
      end
      if Rand.one_in(10) then
         item:add_enchantment("elona.modify_attribute", Enchantment.random_enc_power(item), { skill_id = "elona.stat_magic" })
      end
      if Rand.one_in(10) then
         item:add_enchantment("elona.modify_skill", Enchantment.random_enc_power(item), { skill_id = "elona.stat_magic" })
         break
      end
      if Rand.one_in(10) then
         item:add_enchantment("elona.modify_attribute", Enchantment.random_enc_power(item), { skill_id = "elona.stat_mana" })
         break
      end
      if Rand.one_in(10) then
         item:add_enchantment("elona.modify_skill", Enchantment.random_enc_power(item), { skill_id = "elona.magic_capacity" })
         break
      end
   end

   fun.iter(encs):each(function(enc) item:add_enchantment(enc) end)
   -- <<<<<<<< shade2/item_data.hsp:778 		} ..
end
Event.register("elona.on_add_random_enchantments", "Add stave enchantments",
               add_stave_enchantments, { priority = 50000 })

local function add_ego_enchantments(item, params)
   -- >>>>>>>> shade2/item_data.hsp:780 	if fixLv < fixGreat{ ...
   if params.quality < Enum.Quality.Great then
      if Rand.one_in(2) then
         Enchantment.add_minor_ego_enchantments(item, params.ego_level)
      else
         Enchantment.add_major_ego_enchantments(item, params.ego_level)
      end
   end
   -- <<<<<<<< shade2/item_data.hsp:782 		} ..
end
Event.register("elona.on_add_random_enchantments", "Add ego enchantments",
               add_ego_enchantments, { priority = 60000 })

local function add_great_god_enchantments(item, params)
   -- >>>>>>>> shade2/item_data.hsp:784 	if (fixLv = fixGreat) or (fixLv = fixGod){ ...
   local quality = params.quality

   if not (quality == Enum.Quality.Great or quality == Enum.Quality.God) then
      return
   end

   item.title_seed = Rand.rnd(Const.RANDOM_ITEM_TITLE_SEED_MAX)
   item.title = Text.random_title("weapon", item.title_seed)

   if quality == Enum.Quality.God or (quality == Enum.Quality.Great and Rand.one_in(10)) then
      local enc = Enchantment.generate_fixed_level(item, 99)
      if enc then item:add_enchantment(enc) end
   end

   if Rand.one_in(100) or config.elona.debug_living_weapon then
      if item:has_category("elona.equip_ranged") or item:has_category("elona.equip_melee") then
         Log.warn("TODO living weapon")
      end
   end

   local enchantment_count
   if quality == Enum.Quality.Great then
      enchantment_count = Rand.rnd(Rand.rnd(Rand.rnd(10)+1)+3)+3
   elseif quality == Enum.Quality.God then
      enchantment_count = Rand.rnd(Rand.rnd(Rand.rnd(10)+1)+3)+6
   end
   if config.base.development_mode and quality == Enum.Quality.God then
      enchantment_count = 12
   end

   if enchantment_count > 11
      and (item:has_category("elona.equip_ranged") or item:has_category("elona.equip_melee") )
      and Rand.one_in(10)
   then
      item.is_eternal_force = true
      local enc = Enchantment.generate_fixed_level(item, 99)
      if enc then
         item:add_enchantment(enc)
      end
      item.curse_state = Enum.CurseState.Blessed
   end

   for _ = 1, enchantment_count do
      local _id = Enchantment.random_enc_id(item, Enchantment.random_enc_level(item, params.ego_level))
      local power = Enchantment.random_enc_power(item)
      if quality == Enum.Quality.God then
         power = power + 100
      end
      if item:calc("is_eternal_force") then
         power = power + 100
      end

      local curse_power = 20
      if quality == Enum.Quality.God then
         curse_power = curse_power - 10
      end
      if item:calc("is_eternal_force") then
         curse_power = curse_power - 20
      end

      item:add_enchantment(_id, power, "randomized", curse_power)
   end
   -- <<<<<<<< shade2/item_data.hsp:799 		} ..
end
Event.register("elona.on_add_random_enchantments", "Add great/god quality enchantments",
               add_great_god_enchantments, { priority = 70000 })

local function add_unique_enchantments(item, params)
   -- >>>>>>>> shade2/item_data.hsp:784 	if (fixLv = fixGreat) or (fixLv = fixGod){ ...
   if params.quality == Enum.Quality.Unique then
      for _ = 1, Rand.rnd(3) do
         local enc = Enchantment.generate(item, params.ego_level, 0, 10)
         item:add_enchantment(enc)
      end
   end
   -- <<<<<<<< shade2/item_data.hsp:799 		} ..
end
Event.register("elona.on_add_random_enchantments", "Add unique quality enchantments",
               add_unique_enchantments, { priority = 80000 })

local function add_cursed_doomed_enchantments(item, params)
   -- >>>>>>>> shade2/item_data.hsp:784 	if (fixLv = fixGreat) or (fixLv = fixGod){ ...
   local curse_state = item:calc("curse_state")
   if curse_state <= Enum.CurseState.Cursed then
      do
         local _id = Enchantment.random_enc_id(item, Enchantment.random_enc_level(item, params.ego_level))
         local power = Enchantment.random_enc_power(item)
         power = math.clamp(power, 250, 10000) * (125 + (curse_state == Enum.CurseState.Doomed and 25 or 0)) / 100
         item:add_enchantment(_id, power, "randomized")
      end

      local count = 1 + Rand.rnd(2)
      if curse_state == Enum.CurseState.Doomed then
         count = count + 1
      end

      for _ = 1, count do
         if Rand.one_in(3) then
            local power = Enchantment.random_enc_power(item) * 3 / 2
            item:add_enchantment("elona.modify_resistance", power, "randomized", 100)
         elseif Rand.one_in(3) then
            local power = Enchantment.random_enc_power(item) * 5 / 2
            item:add_enchantment("elona.modify_attribute", power, "randomized", 100)
         else
            local enc = Enchantment.generate_fixed_level(item, -1)
            item:add_enchantment(enc)
         end
      end
   end
   -- <<<<<<<< shade2/item_data.hsp:799 		} ..
end
Event.register("elona.on_add_random_enchantments", "Add cursed/doomed enchantments",
               add_cursed_doomed_enchantments, { priority = 90000 })
