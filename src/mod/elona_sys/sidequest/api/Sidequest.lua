local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Enum = require("api.Enum")
local I18N = require("api.I18N")

local Sidequest = {}

function Sidequest.progress(sidequest_id)
   data["elona_sys.sidequest"]:ensure(sidequest_id)
   local sq = save.elona_sys.sidequest[sidequest_id]
   if sq == nil then
      return 0
   end

   return sq.progress
end

function Sidequest.set_progress(sidequest_id, progress)
   local sidequest_data = data["elona_sys.sidequest"]:ensure(sidequest_id)
   progress = math.floor(progress or 0)
   assert(type(progress) == "number")
   assert(progress == 0 or sidequest_data.progress[progress],
          ("Invalid sidequest progress %d (%s)"):format(progress, sidequest_id))

   local sidequest = save.elona_sys.sidequest
   if sidequest[sidequest_id] == nil then
      sidequest[sidequest_id] = {}
   end
   sidequest[sidequest_id].progress = progress
end

local function iter(state, i)
   local progress = 0
   local sidequest_id
   while progress <= 0 and i < #state do
      i = i + 1
      sidequest_id = state[i]
      local sidequest = save.elona_sys.sidequest[sidequest_id]
      progress = sidequest and sidequest.progress or 0
   end

   if i >= #state and progress == 0 then
      return nil
   end

   return i, sidequest_id, progress
end

local function sort(a, b)
   local proto_a = data["elona_sys.sidequest"]:ensure(a)
   local proto_b = data["elona_sys.sidequest"]:ensure(a)
   return proto_a.ordering < proto_b.ordering
end

function Sidequest.iter()
   local sorted_keys = table.keys(save.elona_sys.sidequest)
   table.sort(sorted_keys, sort)
   return fun.wrap(iter, sorted_keys, 0)
end

function Sidequest.set_quest_targets(map)
   map = map or Map.current()

   for _, v in Chara.iter_others(map) do
      if Chara.is_alive(v, map) then
         v.is_quest_target = true
         v.relation = Enum.Relation.Enemy
      end
   end
end

function Sidequest.no_targets_remaining(map)
   map = map or Map.current()

   for _, v in Chara.iter(map) do
      if Chara.is_alive(v, map) and v.is_quest_target then
         return false
      end
   end

   return true
end

function Sidequest.localize_progress_text(sidequest_id, progress)
   local sidequest_data = data["elona_sys.sidequest"]:ensure(sidequest_id)

   progress = progress or Sidequest.progress(sidequest_id)
   assert(type(progress) == "number")

   local text = sidequest_data.progress[progress]
   assert(progress == 0 or sidequest_data.progress[progress],
          ("Invalid sidequest progress %d (%s)"):format(progress, sidequest_id))

   if type(text) == "function" then
      text = text()
   else
      text = I18N.get_optional(text)
   end

   if type(text) ~= "string" then
      error(("Progress text must be string (%s)"):format(sidequest_id))
   end

   return text
end

function Sidequest.update_journal()
   Gui.play_sound("base.write1");
   Gui.mes_c("quest.journal_updated", "Green");
end

return Sidequest
