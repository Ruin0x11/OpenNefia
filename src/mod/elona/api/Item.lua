local I18N = require("api.I18N")
local Log = require("api.Log")
local Enum = require("api.Enum")
local Text = require("mod.elona.api.Text")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Rand = require("api.Rand")
local CharaMake = require("api.CharaMake")
local ItemMaterial = require("mod.elona.api.ItemMaterial")

local Item = {}

function Item.generate_oracle_text(item)
   -- >>>>>>>> shade2/item.hsp:631 	if fixLv=fixUnique:if mode!mode_shop:if noOracle= ...
   local date = save.base.date
   local known_name = "item.info." .. item._id .. ".name"

   local owner = item:get_owning_chara()

   if owner then
      if owner.roles["elona.adventurer"] then
         -- TODO adventurer
         local map_name = "TODO"
         return I18N.get("magic.oracle.was_held_by", known_name, owner, map_name, date.day, date.month, date.year)
      end
   end

   local map = item:containing_map()
   local map_name = "?"
   if map == nil then
      Log.error("No containing map for %s!", item:build_name())
   else
      map_name = map.name
   end
   return I18N.get("magic.oracle.was_created_at", known_name, map_name, date.day, date.month, date.year)
   -- <<<<<<<< shade2/item.hsp:636  	} ...
end

local NORMAL_ITEMS = table.set {
   "elona.platinum_coin",
   "elona.gold_piece",
   "elona.small_medal",
   "elona.music_ticket",
   "elona.token_of_friendship",
   "elona.bill",
}

-- HACK
local EQUIPMENT_CATEGORIES = {
   "elona.equip_melee",
   "elona.equip_head",
   "elona.equip_shield",
   "elona.equip_body",
   "elona.equip_leg",
   "elona.equip_cloak",
   "elona.equip_back",
   "elona.equip_wrist",
   "elona.equip_ranged",
   "elona.equip_ammo",
   "elona.equip_ring",
   "elona.equip_neck",
}

-- HACK
local NON_USEABLE_CATEGORIES = {
   "elona.furniture",
   "elona.furniture_well",
   "elona.furniture_altar",
   "elona.remains",
   "elona.junk",
   "elona.gold",
   "elona.platinum",
   "elona.container",
   "elona.ore",
   "elona.tree",
   "elona.cargo_food",
   "elona.cargo",
   "elona.bug",
}

local function has_any_category(item, cats)
   return fun.iter(cats):any(function(cat) return item:has_category(cat) end)
end

function Item.is_equipment(item)
   return has_any_category(item, EQUIPMENT_CATEGORIES)
end

function Item.is_non_useable(item)
   return has_any_category(item, NON_USEABLE_CATEGORIES)
end

local function is_randomized_material(material)
   return material == "elona.metal" or material == "elona.soft"
end

local function apply_enchantments(item)
  -- >>>>>>>> shade2/item_data.hsp:754 *item_enc ...)
  -- TODO
  -- <<<<<<<< shade2/item_data.hsp:815 	return ...
end

local function fix_item_2(item, params)
   -- >>>>>>>> shade2/item.hsp:519 *item_fix ...
   if not Item.is_non_useable(item) then
      if Rand.one_in(12) then
         item.curse_state = "blessed"
      end
      if Rand.one_in(13) then
         item.curse_state = "cursed"
         if Item.is_equipment(item) and Rand.one_in(4) then
            item.curse_state = "doomed"
         end
      end
   end

   -- HACK
   if CharaMake.is_active() then
      item.curse_state = "none"
   end

   if item.quality == Enum.Quality.Unique then
      item.curse_state = "none"
   end

   if Item.is_equipment(item) or item:has_category("elona.furniture") and Rand.one_in(5) then
      if is_randomized_material(item.material) or item:has_category("elona.furniture") then
         local chara_level
         if CharaMake.is_active() then
            -- TODO need the level of the generated character
            chara_level = 1
         end
         local level = params.level
         local quality = params.quality
         local material = ItemMaterial.choose_random_material(item, nil, level, quality, chara_level)
         ItemMaterial.apply_item_material(item, material)
      else
         -- If a Unique quality item is generated with a material already
         -- defined on it (like the Blood Moon), then the stat bonuses from the
         -- material will *not* be applied, but the enchantments will.
         ItemMaterial.apply_material_enchantments(item)
      end
   end

   -- TODO enchantments: fixed

   -- NOTE: fltPotion instead of fltHeadItem
   if Item.is_equipment(item) then
      -- TODO enchant item
      apply_enchantments(item)
   else
      if item.quality ~= Enum.Quality.Unique then
         item.quality = Enum.Quality.Normal
      end
   end
   -- >>>>>>>> shade2/item.hsp:549 	return ...
end

function Item.fix_item(item, params)
   -- If true:
   --  - Do not autoidentify with Sense Quality immediately upon creation.
   --  - No chance to generate unique items.
   --  - No artifact generation log for oracle.
   --  - Can generate any kind of home deed.
   --  - Can generate cooked food in addition to raw food.
   local is_shop = params.is_shop

   -- If true, do not allow the item to appear in the text when casting Oracle.
   local no_oracle = params.no_oracle or is_shop

   -- >>>>>>>> shade2/item.hsp:615 	iCol(ci)=iColOrg(ci) ...
   local _, default_color = Text.unidentified_item_params(item)
   item.color = default_color

   ItemMemory.on_generated(item._id)
   item.quality = params.quality or item.quality

   if item.quality == Enum.Quality.Unique and not no_oracle then
      local text = Item.generate_oracle_text(item)
      table.insert(save.elona.artifact_locations, text)
   end
   -- >>>>>>>> shade2/item.hsp:636  	} ...

   -- >>>>>>>> shade2/item.hsp:705 	if refType=fltFurniture:if rnd(3)=0:iSubName(ci)= ...
   fix_item_2(item, params)

   if item:has_category("elona.furniture") then
      item.subname = 0
      if Rand.one_in(3) then
         item.subname = Rand.rnd(Rand.rnd(12) + 1)
      end
   end

   if NORMAL_ITEMS[item._id] then
      item.identify_state = "completely"
      item.curse_state = "none"
   end

   if item:has_category("elona.cargo") then
      item.identify_state = "completely"
      item.curse_state = "none"
      ItemMemory.set_known(item._id, true)
   end

   if item:has_category("elona.remains")
      or item:has_category("elona.junk")
      or item:has_category("elona.ore")
   then
      item.curse_state = "none"
   end
   -- <<<<<<<< shade2/item.hsp:711  ...
end

return Item
