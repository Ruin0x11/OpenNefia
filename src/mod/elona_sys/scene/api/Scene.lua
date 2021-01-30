local Compat = require("mod.elona_sys.api.Compat")
local Fs = require("api.Fs")
local Log = require("api.Log")
local I18N = require("api.I18N")
local SceneLayer = require("mod.elona_sys.scene.api.SceneLayer")

local Scene = {}

function Scene.play(id)
   if config.base.skip_scene_playback then
      return
   end
   local scene_data = data["elona_sys.scene"][id]
   if scene_data then
      scene_data = scene_data.content[I18N.language()]
   end

   if scene_data then
      SceneLayer:new(scene_data):query()
   else
      Log.warn("Scene '%s' does not exist, skipping playback", id)
   end
end

function Scene.convert(text)
   local scenes = {}
   local scene = {}
   local index
   local state = "none"
   local txt = ""
   local chat

   local map = function(e) return Fs.basename(e.file:lower()), e._id end
   local lookup_se = data["base.sound"]:iter():map(map):to_map()
   local lookup_mc = data["base.music"]:iter():map(map):to_map()

   lookup_mc["mcunrest2"] = "elona.unrest2"
   lookup_mc["mctown1"] = "elona.town1"
   lookup_mc["mcmemory"] = "elona.memory"
   lookup_mc["mcintro"] = "elona.intro"

   for line in string.lines(text) do
      local id = line:match("{(.*)}")
      if id then
         if state == "txt" then
            scene[#scene+1] = { "txt", txt }
            txt = ""
         elseif state == "chat" then
            scene[#scene+1] = { "chat", chat, txt }
            chat = nil
            txt = ""
         end
         state = "none"
         if id:match("^[0-9]+") then
            if index then
               scenes[index] = scene
            end
            scene = {}
            index = tonumber(id)
         else
            local rest = line:gsub("{.*}", ""):gsub("[ \t\"]+", "")
            if id == "pic" then
               scene[#scene+1] = { "pic", rest }
            elseif id == "mc" then
               scene[#scene+1] = { "mc", lookup_mc[rest:lower()] }
            elseif id == "se" then
               scene[#scene+1] = { "se", lookup_se[rest:lower()] }
            elseif id == "txt" then
               state = "txt"
            elseif id == "fade" then
               scene[#scene+1] = { "fade" }
            elseif id == "fadein" then
               scene[#scene+1] = { "fadein" }
            elseif id == "wait" then
               scene[#scene+1] = { "wait" }
            elseif id:match("^actor_") then
               local actor = id:gsub("^actor_", "")
               local name, portrait = rest:match("(.*),([0-9]+)")
               actor = tonumber(actor)
               portrait = Compat.convert_122_id("base.portrait", tonumber(portrait))
               scene[#scene+1] = { "actor", actor, name = name, portrait = portrait }
            elseif id:match("^chat_") then
               state = "chat"
               chat = id:gsub("^chat_", "")
               chat = tonumber(chat)
            elseif id == "end" then
               scenes[index] = scene
               index = nil
               scene = {}
            else
               error(id)
            end
         end
      else
         if state == "txt" or state == "chat" then
            if txt == "" then
               txt = line
            else
               txt = txt .. "\n" .. line
            end
         end
      end
   end

   if index then
      scenes[index] = scene
   end
   return scenes
end

return Scene
