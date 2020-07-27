--- Item name functions.
---
--- There's really no good way of abstracting the logic except for
--- writing a separate function for each language.
---
--- @module Itemname
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Text = require("mod.elona.api.Text")
local Enum = require("api.Enum")
local Quality = Enum.Quality
local IdentifyState = Enum.IdentifyState
local CurseState = Enum.CurseState
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Effect = require("mod.elona.api.Effect")
local elona_Item = require("mod.elona.api.Item")
local Ui = require("api.Ui")
local World = require("api.World")

local Itemname = {}

function Itemname.food_name(food_type, original_name, food_quality, chara_id)
   local origin = original_name

   if origin == nil then
      origin = I18N.get("food.names." .. food_type .. ".default_origin")
   end

   if chara_id then
      origin = I18N.get("chara." .. chara_id .. ".name")
   end

   return I18N.get("food.names." .. food_type .. "._" .. food_quality, origin)
end

local function number_string(i)
   if i >= 0 then
      return "+" .. tostring(i)
   end

   return tostring(i)
end

-- >>>>>>>> shade2/item_func.hsp:616 	if iKnown(id)>=knownFull{ ..
local function item_known_info(item)
   local s = ""

   local bonus = (item:calc("bonus") or 0)
   if bonus ~= 0 then
      s = s .. number_string(bonus)
   end
   if item.charges and item.charges > 0 then
      s = s .. I18N.get("item.charges", item.charges)
   end

   local dice_x = item:calc("dice_x") or 0
   local dice_y = item:calc("dice_y") or 0
   local damage_bonus = item:calc("damage_bonus") or 0

   if dice_x ~= 0 or item.hit_bonus ~= 0 or damage_bonus ~= 0 then
      local hit_bonus = item:calc("hit_bonus") or 0

      s = s .. " ("
      if dice_x ~= 0 then
         s = s .. tostring(dice_x) .. "d" .. tostring(dice_y)

         if damage_bonus ~= 0 then
            if damage_bonus > 0 then
               s = s .. "+" .. tostring(damage_bonus)
            else
               s = s .. tostring(damage_bonus)
            end
         end
         s = s .. ")"

         if hit_bonus ~= 0 then
            s = s .. "(" .. tostring(hit_bonus) .. ")"
         end
      else
         s = s .. tostring(hit_bonus) .. "," .. tostring(damage_bonus) .. ")"
      end
   end

   local pv = item:calc("pv") or 0
   local dv = item:calc("dv") or 0
   if dv ~= 0 or pv ~= 0 then
      s = s .. " [" .. dv .. "," .. pv .. "]"
   end

   return s
end
-- <<<<<<<< shade2/item_func.hsp:634 		} ...

-- >>>>>>>> shade2/item_func.hsp:394 *itemNameSub ..
local function item_name_sub(s, item, jp)
   local _id = item._id
   local skip = false
   local identify = item:calc("identify_state")

   if _id == "elona.kitty_bank" then
      s = s .. I18N.get("item.info." .. _id .. ".amount", "item.info." .. _id .. ".names._" .. item.params.bank_gold_increment)
   elseif _id == "elona.bait" then
   elseif _id == "elona.ancient_book" then
      if jp and item.params.ancient_book_is_decoded then
         s = s .. "解読済みの"
      end
      if identify >= IdentifyState.Full then
         local title = "item.info." .. _id .. ".titles._" .. item.params.ancient_book_difficulty
         s = s .. I18N.get("item.info." .. _id .. ".title", title)
      end
   elseif _id == "elona.recipe" then
      -- TODO recipe
   end

   if item:has_category("elona.book") then
      if _id == "elona.textbook" then
         local skill_name = I18N.get("ability." .. item.params.textbook_skill_id .. ".name")
         s = s .. I18N.get("item.info." .. _id .. ".title", skill_name)
      elseif _id == "elona.book_of_rachel" then
         s = s .. I18N.get("item.info." .. _id .. ".title", item.params.book_of_rachel_no)
      elseif _id == "elona.book" then
         s = s .. I18N.get("item.info." .. _id .. ".title", "???") -- TODO book
      end
   end

   if item._id == "elona.recipe" then
      -- TODO recipe
   end

   if item:has_category("elona.furniture_altar") and item.params.altar_god_id then
      local god_name = I18N.get("god." .. item.params.altar_god_id .. ".name")
      s = s .. I18N.get("item.altar_god_name", god_name)
   end

   if item:has_category("elona.food") then
      local is_cooked_dish =
         item:has_category("elona.food") and item.params.food_type and (item.params.food_quality or 0) > 0
      if is_cooked_dish then
         skip = true
         if _id == "elona.fish_a" then
            local fish_name = "??? fish" -- TODO fishing
            s = s .. Itemname.food_name(item.params.food_type, fish_name, item.params.food_quality)
         else
            local original_name = "item.info." .. _id .. ".name"
            local chara_id = item.params.chara_id or nil
            s = s .. Itemname.food_name(item.params.food_type, original_name, item.params.food_quality, chara_id)
         end
      end

      if item.own_state == "harvested" then
         local weight = 1234 -- TODO quest harvest
         s = s .. I18N.get("item.harvest_grown", Ui.format_weight(weight))
      end
   end

   if _id == "elona.fish_a" or _id == "elona.fish_b" then
      local fish_name = "??? fish" -- TODO fishing
      s = s .. fish_name
   end

   if item.params.chara_id and item.own_state ~= "harvested" then
      local chara_name = I18N.get("chara." .. item.params.chara_id .. ".name")
      if not jp then
         s = s .. "of "
      end
      s = s .. chara_name
      if jp then
         s = s .. "の"
      end
   end

   if item:has_category("elona.furniture") and jp and item.params.furniture_quality then
      s = s .. I18N.get("ui.furniture._" .. item.params.furniture_quality)
   end

   if _id == "elona.deed" then
      local home_name = "ui.home." .. item.params.deed_home_id
      s = s .. I18N.get("item.info." .. _id .. ".title", home_name)
   elseif _id == "elona.bill" then
      s = s .. I18N.get("item.info." .. _id .. ".title", item.params.bill_amount)
   elseif _id == "elona.vomit" and item.params.chara_id then
      local chara_name = I18N.get("chara." .. item.params.chara_id .. ".name")
      if not jp then
         s = s .. "of "
      end
      s = s .. chara_name
      if jp then
         s = s .. "の"
      end
   elseif _id == "elona.secret_treasure" then
      s = s .. I18N.get("item.info." .. _id .. ".of." .. item.params.secret_treasure_trait)
   end

   return s, skip
end
-- <<<<<<<< shade2/item_func.hsp:457 	return ...

local itemname = {}

local function starts_with_katakana(s)
   local cp = utf8.codepoint(s, 1, 1)
   return cp >= 0x30A0 and cp <= 0x30FF
end

function itemname.jp(item, amount, no_article)
   local _id = item._id
   local quality = item:calc("quality")
   local identify = item:calc("identify_state")
   local curse = item:calc("curse_state")
   local name = I18N.get("item.info." .. _id .. ".name")

   local is_cooked_dish =
      item:has_category("elona.food") and item.params.food_type and (item.params.food_quality or 0) > 0

   local s = ""
   local s2 = ""

   -- >>>>>>>> shade2/item_func.hsp:473 	if jp@{ ..
   if amount > 1 then
      s2 = "個の"
      if item:has_category("elona.equip_body") then s2 = "着の" end
      if item:has_category("elona.spellbook")
         or item:has_category("elona.book")
      then
         if _id == "elona.recipe" then s2 = "枚の" else s2 = "冊の" end
      end
      if item:has_category("elona.equip_melee") then s2 = "本の" end
      if item:has_category("elona.drink") then s2 = "服の" end
      if item:has_category("elona.scroll") then s2 = "巻の" end
      if item:has_category("elona.equip_wrist")
         or item:has_category("elona.equip_leg")
      then
         s2 = "対の"
      end
      if item:has_category("elona.gold")
         or item:has_category("elona.platinum")
         or _id == "elona.small_medal"
         or _id == "elona.music_ticket"
         or _id == "elona.token_of_friendship"
      then
         s2 = "枚の"
      end
      if _id == "elona.fish" then s2 = "匹の" end

      s = ("%d%s"):format(amount, s2)
   end

   if identify >= IdentifyState.Full then
      if curse == CurseState.Blessed then
         s = s .. I18N.get("ui.curse_state.blessed")
      elseif curse == CurseState.Cursed then
         s = s .. I18N.get("ui.curse_state.cursed")
      elseif curse == CurseState.Doomed then
         s = s .. I18N.get("ui.curse_state.doomed")
      end
   end
   -- <<<<<<<< shade2/item_func.hsp:494  ..

   -- >>>>>>>> shade2/item_func.hsp:523 	if iMaterial(id)=mtFresh{ ..
   if item.material == "elona.fresh" and (item.spoilage_date or 0) < 0 then
      s = s .. "rotten "
   end
   -- <<<<<<<< shade2/item_func.hsp:525 		} ..

   -- >>>>>>>> shade2/item_func.hsp:545 	if iId(id)=idMaterialKit:s+=""+mtName@(0,iMateria ..
   if _id == "elona.material_kit" then
      s = s .. I18N.get("item_material." .. item.material .. ".name") .. "製の"
   end

   local skip
   s, skip = item_name_sub(s, item, true)

   if item:has_category("elona.furniture") and item.material then
      s = s .. I18N.get("item_material." .. item.material .. ".name") .. "細工の"
   end

   if _id == "elona.gift" then
      s = s .. I18N.get("item.info." .. _id .. ".ranks._" .. item.params.gift_value)
   end

   local katakana = false
   if not skip then
      if identify >= IdentifyState.Full and elona_Item.is_equipment(item) then
         if item:calc("is_eternal_force") then
            s = s .. "eternal force" .. I18N.space()
         else
            if item.enchant_major_name_id then
               s = s .. I18N.get("enchantment.item_ego.major._" .. item.enchant_major_name_id)
            end
            if item.enchant_minor_name_id then
               s = s .. I18N.get("enchantment.item_ego.minor._" .. item.enchant_minor_name_id)
            end

            if quality ~= Quality.Unique and quality >= Quality.Great then
               s = s .. I18N.get("item_material." .. item.material .. ".alias")
            else
               local material_name = I18N.get("item_material." .. item.material .. ".name")
               s = s .. material_name
               if starts_with_katakana(material_name) then
                  katakana = true
               else
                  s = s .. "の"
               end
            end
         end
      end
   end

   local unknown_name = Text.unidentified_item_name(item)
   if identify == IdentifyState.None then
      s = s .. unknown_name
   elseif identify < IdentifyState.Full then
      if quality < Quality.Great or not elona_Item.is_equipment(item) then
         s = s .. name
      else
         s = s .. unknown_name
      end
   else
      if quality == Quality.Unique or item:calc("is_precious") then
         s = "★" .. s .. name
      else
         if quality >= Quality.Great then
            s = "☆" .. s
         end
         if katakana then
            s = s .. I18N.get("item.info." .. _id .. ".katakana_name")
         else
            s = s .. name
         end

         local title_seed = item:calc("title_seed")
         if title_seed then
            local title = Text.random_title("weapon", title_seed)
            if quality == Quality.Great then
               s = s .. I18N.get("item.title_paren.great", title)
            else
               s = s .. I18N.get("item.title_paren.god", title)
            end
         end
      end
   end
   -- <<<<<<<< shade2/item_func.hsp:605 *skipName ..

   -- >>>>>>>> shade2/item_func.hsp:616 	if iKnown(id)>=knownFull{ ..
   if identify >= IdentifyState.Full then
      s = s .. item_known_info(item)
   end
   -- <<<<<<<< shade2/item_func.hsp:615 		} ..

   -- >>>>>>>> shade2/item_func.hsp:640 	if iId(id)=idFishingPole{ ..
   if _id == "elona.fishing_pole" then
      if item.charges > 0 then
         s = s .. I18N.get("item.info." .. _id .. ".remaining", "item.info.elona.bait.rank." .. item.params.fishing_pole_bait, item.charges)
      end
   elseif _id == "elona.monster_ball" then
      local chara_id = item.params.monster_ball_captured_chara_id
      if chara_id then
         local chara_name = I18N.get("chara." .. chara_id .. ".name")
         s = s .. ("(%s)"):format(chara_name)
      else
         s = s .. I18N.get("item.info." .. _id .. ".level", item.params.monster_ball_max_level)
      end
   elseif _id == "elona.small_gamble_chest" then
      s = s .. I18N.get("item.info." .. _id .. ".level", item.params.lockpick_difficulty)
   end

   if identify == IdentifyState.Quality and elona_Item.is_equipment(item) then
      local material_name = "item_material." .. item.material .. ".name"
      s = s .. I18N.get("ui.sense_quality", "ui.quality._" .. quality, material_name)
      if curse == CurseState.Cursed then
         s = s .. I18N.get("item.approximate_curse_state.cursed")
      elseif curse == CurseState.Doomed then
         s = s .. I18N.get("item.approximate_curse_state.doomed")
      end
   end

   if item:has_category("elona.container") then
      if _id == "elona.shopkeepers_trunk" then
         s = s .. I18N.get("item.info." .. _id .. ".temporal")
      else
         if item.inv == nil and item.params.chest_item_level == 0 then
            s = s .. I18N.get("item.chest_empty")
         end
      end
   end

   if item:has_category("elona.cargo") and item.params.cargo_buying_price then
      s = s .. I18N.get("item.cargo_buying_price", item.params.cargo_buying_price)
   end

   if item:calc("is_spiked_with_love_potion") then
      s = s .. I18N.get("item.aphrodisiac")
   end

   if item:calc("is_poisoned") then
      s = s .. I18N.get("item.poisoned")
   end

   if item.next_use_date then
      local date = World.date_hours()
      if date < item.next_use_date then
         s = s .. I18N.get("item.interval", item.next_use_date - date)
      end
   end

   if _id == "elona.shelter" then
      s = s .. I18N.get("item.serial_no", item.params.shelter_serial_no)
   elseif _id == "elona.disc" then
      local bgm_number = "???"
      local music = data["base.music"][item.params.disc_music_id]
      if music and music.elona_id then
         bgm_number = tostring(music.elona_id)
      end
      s = s .. (" <BGM%s>"):format(bgm_number)
   end

   return s
   -- <<<<<<<< shade2/item_func.hsp:685 	return s ..
end

local VOWELS = table.set { "a", "e", "i", "o", "u" }
local function starts_with_vowel(s)
   local c = s:sub(1, 1):lower()
   return VOWELS[c]
end

function itemname.en(item, amount, no_article)
   local _id = item._id
   local quality = item:calc("quality")
   local identify = item:calc("identify_state")
   local curse = item:calc("curse_state")
   local name = I18N.get("item.info." .. _id .. ".name")

   local is_cooked_dish =
      item:has_category("elona.food") and item.params.food_type and (item.params.food_quality or 0) > 0

   local s = ""

   -- >>>>>>>> shade2/item_func.hsp:495 		}else{	 ..
   if identify >= IdentifyState.Full then
      if curse == CurseState.Blessed then
         s = s .. I18N.get("ui.curse_state.blessed") .. " "
      elseif curse == CurseState.Cursed then
         s = s .. I18N.get("ui.curse_state.cursed") .. " "
      elseif curse == CurseState.Doomed then
         s = s .. I18N.get("ui.curse_state.doomed") .. " "
      end
   end

   local s2 = ""
   local s3 = ""
   if not (item.has_random_name and identify < IdentifyState.Name) then
      s2 = item.originalnameref2 or ""

      if string.match(name, "with") then
         s3 = "with"
      else
         s3 = "of"
      end

      if identify > IdentifyState.None and s2 == "" then
         if (item:calc("cargo_weight") or 0) > 0 then
            s2 = "cargo"
         end
         if item:has_category("elona.equip_wrist") or item:has_category("elona.equip_leg") then
            s2 = "pair"
         end
      end

      if is_cooked_dish then
         s2 = "dish"
      end
   end

   if s2 ~= "" then
      if amount > 1 then
         -- [3] [blessed ][pair]s [of]
         s = ("%d %s%ss %s "):format(amount, s, s2, s3)
      else
         -- [blessed ][pair] [of]
         s = ("%s%s %s "):format(s, s2, s3)
      end
   else
      if amount > 1 then
         -- [3] [blessed ]
         s = ("%d %s"):format(amount, s)
      end
   end

   if item.material == "elona.fresh" and (item.spoilage_date or 0) < 0 then
      s = s .. "rotten "
   end
   -- <<<<<<<< shade2/item_func.hsp:521 		} ..

   -- >>>>>>>> shade2/item_func.hsp:527 	if en@{ ..
   local skip = false
   if is_cooked_dish then
      skip = true
   end
   if (item.params.furniture_quality or 0) > 0 then
      s = s .. I18N.get("ui.furniture._" .. item.params.furniture_quality) .. " "
   end
   if item.params.ancient_book_is_decoded == false then
      s = s .. "undecoded "
   end
   -- TODO recipe
   -- <<<<<<<< shade2/item_func.hsp:534 	} ..

   -- >>>>>>>> shade2/item_func.hsp:545 	if iId(id)=idMaterialKit:s+=""+mtName@(0,iMateria ..
   if _id == "elona.material_kit" then
      s = s .. I18N.get("item_material." .. item.material .. ".name") .. " "
   end
   -- <<<<<<<< shade2/item_func.hsp:546 			 ...

   -- >>>>>>>> shade2/item_func.hsp:549 	if a=fltFurniture{ ..
   if item:has_category("elona.furniture") and item.material then
      s = s .. I18N.get("item_material." .. item.material .. ".name") .. "work "
   end

   if _id == "elona.gift" then
      s = s .. I18N.get("item.info." .. _id .. ".ranks._" .. item.params.gift_value) .. " "
   end

   if not skip then
      if identify >= IdentifyState.Full and elona_Item.is_equipment(item) then
         if item:calc("is_eternal_force") then
            s = s .. "eternal force" .. I18N.space()
         else
            if item.enchant_minor_name_id then
               s = s .. I18N.get("enchantment.item_ego.minor._" .. item.enchant_minor_name_id) .. " "
            end

            if quality ~= Quality.Unique and quality >= Quality.Great then
               s = s .. I18N.get("item_material." .. item.material .. ".alias") .. " "
            else
               s = s .. I18N.get("item_material." .. item.material .. ".name") .. " "
            end
         end
      end
   end

   local unknown_name = Text.unidentified_item_name(item)
   if identify == IdentifyState.None then
      s = s .. unknown_name
   elseif identify < IdentifyState.Full then
      if quality < Quality.Great or not elona_Item.is_equipment(item) then
         s = s .. name
      else
         s = s .. unknown_name
      end
   else
      if quality == Quality.Unique or item:calc("is_precious") then
         s = s .. name
      else
         if elona_Item.is_equipment(item) and item.enchant_major_name_id then
            s = s .. " " .. I18N.get("enchantment.item_ego.major._" .. item.enchant_major_name_id)
         end

         s = s .. name

         local title_seed = item:calc("title_seed")
         if title_seed then
            local title = Text.random_title("weapon", title_seed)
            if quality == Quality.Great then
               s = s .. I18N.get("item.title_paren.great", title)
            else
               s = s .. I18N.get("item.title_paren.god", title)
            end
         end
      end
   end
   -- <<<<<<<< shade2/item_func.hsp:605 *skipName ..
   -- >>>>>>>> shade2/item_func.hsp:606 	if en@{ ..
   if not no_article then
      if identify >= IdentifyState.Full and quality >= Quality.Great and elona_Item.is_equipment(item) then
         s = "the " .. s
      elseif amount == 1 then
         if starts_with_vowel(s) then
            s = "an " .. s
         else
            s = "a " .. s
         end
      end
   end

   if s2 == "" and item._id ~= "elona.fish_a" and amount > 1 then
      s = s .. "s"
   end

   s = item_name_sub(s, item, false)

   if identify >= IdentifyState.Full then
      s = s .. item_known_info(item)
   end
   -- <<<<<<<< shade2/item_func.hsp:615 		} ..

   -- >>>>>>>> shade2/item_func.hsp:636 	if en@{ ...
   if _id == "elona.wallet" or _id == "elona.suitcase" then
      s = s .. "(Lost property)"
   end
   -- <<<<<<<< shade2/item_func.hsp:638 		} ..

   -- >>>>>>>> shade2/item_func.hsp:640 	if iId(id)=idFishingPole{ ..
   if _id == "elona.fishing_pole" then
      if item.charges > 0 then
         s = s .. I18N.get("item.info." .. _id .. ".remaining", "item.info.elona.bait.rank." .. item.params.fishing_pole_bait, item.charges)
      end
   elseif _id == "elona.monster_ball" then
      local chara_id = item.params.monster_ball_captured_chara_id
      if chara_id then
         local chara_name = I18N.get("chara." .. chara_id .. ".name")
         s = s .. ("(%s)"):format(chara_name)
      else
         s = s .. I18N.get("item.info." .. _id .. ".level", item.params.monster_ball_max_level)
      end
   elseif _id == "elona.small_gamble_chest" then
      s = s .. I18N.get("item.info." .. _id .. ".level", item.params.lockpick_difficulty)
   end

   if identify == IdentifyState.Quality and elona_Item.is_equipment(item) then
      local material_name = "item_material." .. item.material .. ".name"
      s = s .. I18N.get("ui.sense_quality", "ui.quality._" .. quality, material_name)
      if curse == CurseState.Cursed then
         s = s .. I18N.get("item.approximate_curse_state.cursed")
      elseif curse == CurseState.Doomed then
         s = s .. I18N.get("item.approximate_curse_state.doomed")
      end
   end

   if item:has_category("elona.container") then
      if _id == "elona.shopkeepers_trunk" then
         s = s .. I18N.get("item.info." .. _id .. ".temporal")
      else
         if item.inv == nil and item.params.chest_item_level == 0 then
            s = s .. I18N.get("item.chest_empty")
         end
      end
   end

   if item:has_category("elona.cargo") and item.params.cargo_buying_price then
      s = s .. I18N.get("item.cargo_buying_price", item.params.cargo_buying_price)
   end

   if item:calc("is_spiked_with_love_potion") then
      s = s .. I18N.get("item.aphrodisiac")
   end

   if item:calc("is_poisoned") then
      s = s .. I18N.get("item.poisoned")
   end

   if item.next_use_date then
      local date = World.date_hours()
      if date < item.next_use_date then
         s = s .. I18N.get("item.interval", item.next_use_date - date)
      end
   end

   if _id == "elona.shelter" then
      s = s .. I18N.get("item.serial_no", item.params.shelter_serial_no)
   elseif _id == "elona.disc" then
      local bgm_number = "???"
      local music = data["base.music"][item.params.disc_music_id]
      if music and music.elona_id then
         bgm_number = tostring(music.elona_id)
      end
      s = s .. (" <BGM%s>"):format(bgm_number)
   end

   return s
   -- <<<<<<<< shade2/item_func.hsp:685 	return s ..
end

function Itemname.build_name(item, amount, no_article)
   amount = amount or item.amount

   if ItemMemory.is_known(item._id) and item.identify_state == IdentifyState.None  then
      Effect.identify_item(item, IdentifyState.Name)
   end

   local f = itemname[I18N.language()] or itemname.en

   return f(item, amount, no_article)
end

return Itemname
