local News = require("mod.elona.api.News")
local Event = require("api.Event")
local I18N = require("api.I18N")
local MapObject = require("api.MapObject")
local Enum = require("api.Enum")
local Map = require("api.Map")
local Chara = require("api.Chara")
local World = require("api.World")
local Adventurer = require("mod.elona.api.Adventurer")

local function add_news_gain_level(chara, params)
   if not chara:find_role("elona.adventurer") or not params.show_message then
      return
   end

   -- >>>>>>>> shade2/text.hsp:1323 	if type=2{ ...
   local topic = I18N.get("news.growth.title")
   local text = I18N.get("news.growth.text", chara.title, chara.name, chara.level)
   -- <<<<<<<< shade2/text.hsp:1326 		} ..

   -- >>>>>>>> shade2/calculation.hsp:52 		addNews 2,r1 ...
   News.add(text, topic)
   -- <<<<<<<< shade2/calculation.hsp:52 		addNews 2,r1 ..
end
Event.register("elona_sys.on_chara_gained_level", "Add news for adventurer level gain", add_news_gain_level)

local function cleanup_adventurer(chara)
   if not MapObject.is_map_object(chara, "base.chara")
      or not chara:find_role("elona.adventurer")
   then
      return
   end

   save.elona.staying_adventurers:unregister(chara)

   -- >>>>>>>> shade2/text.hsp:1323 	if type=2{ ...
   local topic = I18N.get("news.growth.title")
   local text = I18N.get("news.growth.text", chara.title, chara.name, chara.level)
   -- <<<<<<<< shade2/text.hsp:1326 		} ..

   -- >>>>>>>> shade2/calculation.hsp:52 		addNews 2,r1 ...
   News.add(text, topic)
   -- <<<<<<<< shade2/calculation.hsp:52 		addNews 2,r1 ..
end
Event.register("base.on_object_removed", "Clean up adventurer status", cleanup_adventurer)

local function should_transfer(chara, map)
   local role = chara:find_role("elona.adventurer")
   if role == nil then
      return false
   end

   if role.state ~= "Alive" then
      return false
   end

   if chara:calc("is_hired") then
      return true
   end

   if not (map:has_type("town")
              or map:has_type("guild")
           -- XXX: not in vanilla
              or map:has_type("player_owned"))
   then
      return false
   end

   -- TODO arena

   return true
end

local function transfer_staying_adventurers(prev_map, params)
   -- >>>>>>>> shade2/map.hsp:1875 	repeat maxAdv,maxFollower ...
   local next_map = params.next_map

   local player = Chara.player()
   for _, adv in save.elona.staying_adventurers:do_transfer(prev_map, next_map, should_transfer) do
      if adv:calc("is_hired") then
         adv.relation = Enum.Relation.Ally
         Map.try_place_chara(adv, player.x, player.y, next_map)
      else
         Map.try_place_chara(adv, nil, nil, next_map)
         adv.hp = adv:calc("max_hp")
         adv.mp = adv:calc("max_mp")
         adv.stamina = adv:calc("max_stamina")
      end
   end
   -- <<<<<<<< shade2/map.hsp:1892 	loop ..
end
Event.register("base.on_map_leave", "Transfer staying adventurers", transfer_staying_adventurers, { priority = 350000 })

local function set_adventurer_killed_state(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1666 			if cRole(tc)=cRoleAdv{ ...
   local role = chara:find_role("elona.adventurer")
   if not role then
      return
   end

   chara.state = "Alive"
   role.state = "Hospital"
   chara.respawn_date = World.date_hours() + Adventurer.calc_respawn_hours(chara)
   save.elona.staying_adventurers:take_object(chara)
   -- <<<<<<<< shade2/chara_func.hsp:1668 				cRespawn(tc)=dateId+respawnTimeAdv+rnd(respawn ..
end
Event.register("base.on_chara_killed", "Set adventurer killed state", set_adventurer_killed_state, { priority = 300000 })

local function on_adventurer_place_failure(chara)
   -- >>>>>>>> shade2/chara.hsp:437 		if cRole(rc)=cRoleAdv	: cExist(rc)=cAdvHospital ...
   local role = chara:find_role("elona.adventurer")
   if not role then
      return
   end

   chara.state = "Alive"
   role.state = "Hospital"
   save.elona.staying_adventurers:take_object(chara)
   -- <<<<<<<< shade2/chara.hsp:437 		if cRole(rc)=cRoleAdv	: cExist(rc)=cAdvHospital ..
end
Event.register("base.on_chara_place_failure", "Set adventurer killed state", on_adventurer_place_failure, { priority = 300000 })

local function cleanup_dead_adventurers(map)
   -- >>>>>>>> shade2/chara_func.hsp:1666 			if cRole(tc)=cRoleAdv{ ...
   local filter = function(c)
      return not Chara.is_alive(c) and Adventurer.is_adventurer(c)
   end
   for _, chara in Chara.iter_all(map):filter(filter) do
      local role = assert(chara:find_role("elona.adventurer"))

      chara.state = "Alive"
      role.state = "Hospital"
      chara.respawn_date = World.date_hours() + Adventurer.calc_respawn_hours(chara)
      save.elona.staying_adventurers:take_object(chara)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1668 				cRespawn(tc)=dateId+respawnTimeAdv+rnd(respawn ..
end
Event.register("base.on_map_enter", "Cleanup dead adventurers", cleanup_dead_adventurers, { priority = 300000 })
