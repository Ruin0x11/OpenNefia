local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Text = require("mod.elona.api.Text")
local Area = require("api.Area")
local Home = require("mod.elona.api.Home")
local Log = require("api.Log")
local World = require("api.World")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local News = require("mod.elona.api.News")
local Building = require("mod.elona.api.Building")
local Skill = require("mod.elona_sys.api.Skill")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Equipment = require("mod.elona.api.Equipment")
local ElonaChara = require("mod.elona.api.ElonaChara")
local InstancedArea = require("api.InstancedArea")
local MapObject = require("api.MapObject")

local Adventurer = {}

-- >>>>>>>> shade2/init.hsp:85 	#define global maxAdv		40-maxNullChara ...
Adventurer.MAX_ADVENTURERS = 40 - 1
-- <<<<<<<< shade2/init.hsp:85 	#define global maxAdv		40-maxNullChara ..

function Adventurer.is_adventurer(chara)
   return chara:find_role("elona.adventurer") ~= nil
end

function Adventurer.iter_all(map)
   return fun.chain(Adventurer.iter_staying(), Adventurer.iter_in_map(map))
end

function Adventurer.iter_in_map(map)
   return Chara.iter(map):filter(Adventurer.is_adventurer)
end

function Adventurer.iter_staying(map)
   return save.elona.staying_adventurers:iter()
end

function Adventurer.area_of(adv)
   local map = adv:current_map()
   if map then
      return Area.for_map(map)
   end
   local staying_area = save.elona.staying_adventurers:get_staying_area_for(adv)
   local area, floor
   if staying_area ~= nil then
      area = Area.get(staying_area.area_uid)
      floor = staying_area.area_floor
   end
   return area, floor
end

function Adventurer.location_name(adv)
   local role = adv:find_role("elona.adventurer")
   if role == nil then
      return I18N.get("ui.adventurers.unknown")
   end

   if role.state == "Hospital" then
      return I18N.get("ui.adventurers.hospital")
   end

   local area, floor = Adventurer.area_of(adv)
   if area then
      return area.name
   end

   return I18N.get("ui.adventurers.unknown")
end

function Adventurer.initialize()
   -- >>>>>>>> shade2/adv.hsp:21 *adv_init ...
   for _ = 1, Adventurer.MAX_ADVENTURERS do
      Adventurer.generate_and_place()
   end
   -- <<<<<<<< shade2/adv.hsp:26 	return ..
end

local ADVENTURER_IDS = {
   "elona.warrior",
   "elona.wizard",
   "elona.mercenary_archer"
}

function Adventurer.random_adventurer_id(player)
   return Rand.choice(ADVENTURER_IDS)
end

function Adventurer.calc_adventurer_level(player)
   player = player or Chara.player()
   -- >>>>>>>> shade2/adv.hsp:30 	flt 0,fixGreat: initLv=rnd(60+cLevel(pc))+1 ...
   return Rand.rnd(60 + (player and player.level or 0)) + 1
   -- <<<<<<<< shade2/adv.hsp:30 	flt 0,fixGreat: initLv=rnd(60+cLevel(pc))+1 ..
end

function Adventurer.is_valid_exploring_area(area)
   if area == nil then
      return false
   end

   if area:has_type("quest")
      or area:has_type("player_owned")
      or Home.is_home_area(area)
   then
      return false
   end

   return true
end

function Adventurer.calc_starting_area(adv)
   -- >>>>>>>> shade2/adv.hsp:40 	p=rnd(headRandArea) ...
   local area = Rand.choice(Area.iter())
   if not area or Adventurer.is_valid_exploring_area(area) then
      area = Area.create_unique("elona.north_tyris")
   end
   if Rand.one_in(4) then
      area = Area.get_unique("elona.vernis")
   end
   if Rand.one_in(4) then
      area = Area.get_unique("elona.vernis")
   end
   if Rand.one_in(6) then
      area = Area.get_unique("elona.yowyn")
   end
   return area or Area.get_unique("elona.north_tyris")
   -- <<<<<<<< shade2/adv.hsp:44 	if rnd(6)=0:p=areaYowyn ..
end

function Adventurer.calc_exploring_area(adv)
   local area
   for i = 1, 10 do
      if Rand.one_in(4) then
         area = Rand.choice(Building.iter())
      else
         area = Rand.choice(Area.iter())
      end

      if not Adventurer.is_valid_exploring_area(area) then
         area = Area.create_unique("elona.north_tyris")
      end

      if i <= 5 and area:has_type("town") then
         break
      end
   end
   return area
end

function Adventurer.set_area(adv, area, floor)
   assert(MapObject.is_map_object(adv, "base.chara"))
   class.assert_is_an(InstancedArea, area)

   if not Adventurer.is_adventurer(adv) then
      return
   end

   save.elona.staying_adventurers:register(adv, area, floor or area:starting_floor())
end

function Adventurer.calc_starting_fame(adv)
   return (adv.level ^ 2) * 30 + Rand.rnd(adv.level * 200 + 100) + Rand.rnd(500)
end

Adventurer.RESPAWN_HOURS = 24

function Adventurer.calc_respawn_hours()
   -- >>>>>>>> shade2/chara_func.hsp:1668 				cRespawn(tc)=dateId+respawnTimeAdv+rnd(respawn ...
   return Adventurer.RESPAWN_HOURS + Rand.rnd(Adventurer.RESPAWN_HOURS / 2)
   -- <<<<<<<< shade2/chara_func.hsp:1668 				cRespawn(tc)=dateId+respawnTimeAdv+rnd(respawn ..
end

function Adventurer.generate()
   -- >>>>>>>> shade2/adv.hsp:29 *adv_generate ...
   local filter = {
      level = 0,
      quality = Enum.Quality.Great,
      initial_level = Adventurer.calc_adventurer_level(),
      id = Adventurer.random_adventurer_id(),
      ownerless = true
   }
   local adv = Charagen.create(nil, nil, filter)
   adv.relation = Enum.Relation.Neutral
   adv.image = ElonaChara.random_human_image(adv)
   adv.name = Text.random_name()
   adv.title = Text.random_title()
   adv:add_role("elona.adventurer", { state = "Alive", contract_expiry_date = nil })
   adv.fame = Adventurer.calc_starting_fame(adv)

   -- In vanilla, adventurers were treated differently than mobs/villagers in
   -- the current map. They were always loaded into memory in slots 17-57 and
   -- swapped out depending on their current area when the player changed maps.
   -- As a result, we need a way to exclude certain characters from being
   -- iterated by Chara.iter_others().
   --
   -- By default, `is_other` on characters is nil, which will be treated as
   -- `true` by Chara.iter_others(). (the exclusion is explicit)
   adv.is_other = false

   return adv
   -- <<<<<<<< shade2/adv.hsp:47 	return ..
end

function Adventurer.generate_and_place()
   local adv = Adventurer.generate()

   local area = Adventurer.calc_starting_area()

   if area == nil then
      Log.warn("No area for adventurer %s found.", adv)
      return
   end

   if not save.elona.staying_adventurers:take_object(adv) then
      Log.error("Could not place adventurer in staying adventurers pool.")
      return nil
   end
   Adventurer.set_area(adv, area)

   return adv
end

function Adventurer.update_all(map)
   -- >>>>>>>> shade2/adv.hsp:51 	repeat maxAdv,maxFollower ...
   local to_generate = 0
   for _, adv in Adventurer.iter_all(map) do
      local role = adv:find_role("elona.adventurer")
      if role.contract_expiry_date ~= nil and role.contract_expiry_date < World.date_hours() then
         role.contract_expiry_date = nil
         adv.is_hired = false
         adv.relation = Enum.Relation.Neutral
         Gui.mes("chara.contract_expired", adv)
      end

      if role.state == "Dead" then
         adv:remove_ownership()
         to_generate = to_generate + 1
      elseif role.state == "Hospital" and adv.respawn_date >= World.date_hours() then
         if Rand.one_in(3) then
            -- >>>>>>>> shade2/text.hsp:1335 	if type=5{ ...
            local topic = I18N.get("news.retirement.title")
            local text = I18N.get("news.retirement.text", adv.title, adv.name)
            News.add(text, topic)
            -- <<<<<<<< shade2/text.hsp:1338 		} ..

            adv:remove_ownership()
            to_generate = to_generate + 1
         else
            -- >>>>>>>> shade2/text.hsp:1335 	if type=5{ ...
            local topic = I18N.get("news.recovery.title")
            local text = I18N.get("news.recovery.text", adv.title, adv.name)
            News.add(text, topic)
            -- <<<<<<<< shade2/text.hsp:1338 		} ..

            adv.state = "Alive"
            role.state = "Alive"
         end
      end
   end

   for _ = 1, Adventurer.MAX_ADVENTURERS - Adventurer.iter_all(map):length() do
      Adventurer.generate_and_place()
   end
   -- <<<<<<<< shade2/adv.hsp:75 		} ..

   Adventurer.iter_staying():each(Adventurer.act)
end

function Adventurer.gain_item(adv)
   -- >>>>>>>> shade2/adv.hsp:122 *adv_gainItem ...
   local filter = {
      level = adv.level,
      quality = Enum.Quality.Great
   }
   if Rand.one_in(3) then
      filter.categories = Rand.choice(Filters.fsetwear)
   else
      filter.categories = Rand.choice(Filters.fsetitem)
   end

   local item = Itemgen.create(nil, nil, filter, adv)
   if item then
      item.identify_state = Enum.IdentifyState.Full
      if item.quality >= Enum.Quality.Great and ElonaItem.is_equipment(item) then
         -- >>>>>>>> shade2/text.hsp:1335 	if type=5{ ...
         local staying_area = Adventurer.area_of(adv)
         if staying_area then
            local topic = I18N.get("news.discovery.title")
            local text = I18N.get("news.discovery.text", adv.title, adv.name, item:build_name(1), staying_area.name)
            News.add(text, topic)
         end
         -- <<<<<<<< shade2/text.hsp:1338 		} ..
      end

      Equipment.equip_all_optimally(adv)
   end
   -- <<<<<<<< shade2/adv.hsp:148 	return ..
end

function Adventurer.act(adv)
   -- >>>>>>>> shade2/adv.hsp:77 	if rnd(60)=0{ ...
   if adv:current_map() ~= nil then
      return
   end

   if Rand.one_in(60) then
      local area = Adventurer.calc_exploring_area()
      Adventurer.set_area(adv, area)
   end

   local area = Adventurer.area_of(adv)
   if area == nil then
      area = Adventurer.calc_exploring_area()
      if area == nil then
         Log.warn("No area for adventurer %s could be located.", adv)
         return
      end
      Adventurer.set_area(adv, area)
   end

   if Rand.one_in(200) and not area:has_type("town") then
      Adventurer.gain_item(adv)
   end

   if Rand.one_in(10) then
      adv.experience = adv.experience + (adv.level ^ 2) * 2
   end

   if Rand.one_in(20) then
      adv.fame = adv.fame + Rand.rnd(adv.level ^ 2 / 40 + 5) - Rand.rnd(adv.level ^ 2 / 50 + 5)
   end

   if Rand.one_in(2000) then
      adv.experience = adv.experience + (adv.level ^ 2) * 2
      local fame_gained = Rand.rnd(adv.level ^ 2 / 20 + 10) + 10
      adv.fame = adv.fame + fame_gained

      -- >>>>>>>> shade2/text.hsp:1331 	if type=4{ ...
      local topic = I18N.get("news.accomplishment.title")
      local text = I18N.get("news.accomplishment.text", adv.title, adv.name, fame_gained)
      News.add(text, topic)
      -- <<<<<<<< shade2/text.hsp:1334 		} ..

      Adventurer.gain_item(adv)
   end

   while adv.experience >= adv.required_experience do
      Skill.gain_level(adv, false)
   end
   -- <<<<<<<< shade2/adv.hsp:104  ..
end

return Adventurer
