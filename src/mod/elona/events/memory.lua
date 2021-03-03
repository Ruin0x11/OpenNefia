local Event = require("api.Event")
local Text = require("mod.elona.api.Text")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Chara = require("api.Chara")
local Log = require("api.Log")

Event.register("base.generate_title", "Elona title generation", function(_, params, result)
                  if result and result ~= "" then
                     return result
                  end
                  return Text.random_title(params.kind, params.seed or nil)
end)

Event.register("base.on_chara_generated", "npc memory", function(chara) NpcMemory.on_generated(chara._id) end)
Event.register("base.on_object_cloned", "npc memory",
               function(_, params)
                  if params.owned and params.object._type == "base.chara" then
                     NpcMemory.on_generated(params.object._id)
                  end
end)
Event.register("base.on_kill_chara", "npc memory",
               function(victim, params)
                  -- >>>>>>>> shade2/chara_func.hsp:1685 		if tc=pc : gDeath++	 ..
                  if victim:is_player() then
                     save.base.total_deaths = save.base.total_deaths + 1
                  end
                  -- <<<<<<<< shade2/chara_func.hsp:1685 		if tc=pc : gDeath++	 ..
                  -- >>>>>>>> shade2/chara_func.hsp:1726 		if tc!pc{ ..
                  if not victim:is_player() then
                     NpcMemory.on_killed(victim._id)
                     -- TODO custom talk
                     if victim:is_in_player_party() then
                        Gui.mes("damage.you_feel_sad")
                     end
                  end
                  local map = victim:current_map()
                  map.crowd_density = map.crowd_density - 1
                  Effect.on_kill(params.source, victim)
                  -- TODO riding
                  -- TODO crowd
                  -- <<<<<<<< shade2/chara_func.hsp:1735 		check_kill dmgSource,tc ..
end)
Event.register("base.on_map_leave", "npc memory",
               function(map)
                  if map.is_temporary then
                     for _, v in map:iter_charas() do
                        if Chara.is_alive(v) then
                           Log.debug("forgetting chara " .. v._id)
                           NpcMemory.forget_generated(v._id)
                        end
                     end
                  end
end)
