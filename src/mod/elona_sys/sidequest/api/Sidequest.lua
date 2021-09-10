local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Enum = require("api.Enum")
local I18N = require("api.I18N")

local Sidequest = {}

function Sidequest.set_main_quest(sidequest_id, progress)
   progress = progress or 1

   local proto = data["elona_sys.sidequest"]:ensure(sidequest_id)
   if not proto.is_main_quest then
      error(("Quest %s is not useable as a main quest."):format(sidequest_id))
   end

   save.elona_sys.active_main_quests = {
      [sidequest_id] = true
   }
   Sidequest.set_progress(sidequest_id, progress)
end

function Sidequest.progress(sidequest_id)
   local proto = data["elona_sys.sidequest"]:ensure(sidequest_id)
   local sq = save.elona_sys.sidequest[sidequest_id]
   if sq == nil then
      return 0
   end

   if proto.is_main_quest and not Sidequest.is_active_main_quest(sidequest_id) then
      return 0
   end

   return sq.progress
end

function Sidequest.set_progress(sidequest_id, progress)
   data["elona_sys.sidequest"]:ensure(sidequest_id)
   progress = math.floor(progress or 0)
   assert(type(progress) == "number")

   local sidequest = save.elona_sys.sidequest
   if sidequest[sidequest_id] == nil then
      sidequest[sidequest_id] = {}
   end
   sidequest[sidequest_id].progress = progress
end

function Sidequest.is_complete(sidequest_id)
   -- TODO don't base progress on some arbitrary number, use a flag or something
   -- instead
   return Sidequest.progress(sidequest_id) >= 1000
end

function Sidequest.is_in_progress(sidequest_id)
   -- TODO don't base progress on some arbitrary number, use a flag or something
   -- instead
   local progress = Sidequest.progress(sidequest_id)
   return progress > 0 and progress < 1000
end

function Sidequest.is_active_main_quest(sidequest_id)
   local proto = data["elona_sys.sidequest"]:ensure(sidequest_id)

   if not proto.is_main_quest then
      return false
   end

   if not save.elona_sys.active_main_quests[sidequest_id] then
      return false
   end

   return true
end

function Sidequest.is_sub_quest(sidequest_id)
   local proto = data["elona_sys.sidequest"]:ensure(sidequest_id)
   return not proto.is_main_quest
end

local function iter_sub_quests(state, i)
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
   return proto_a._ordering < proto_b._ordering
end

function Sidequest.iter_active_main_quests()
   local sorted_keys = table.keys(save.elona_sys.sidequest)
   table.sort(sorted_keys, sort)
   return fun.iter(sorted_keys):filter(Sidequest.is_active_main_quest)
end

function Sidequest.iter_active_sub_quests()
   local sorted_keys = table.keys(save.elona_sys.sidequest)
   table.sort(sorted_keys, sort)
   return fun.wrap(iter_sub_quests, sorted_keys, 0)
end

function Sidequest.set_quest_targets(map)
   for _, v in Chara.iter_others(map) do
      if Chara.is_alive(v) then
         v.is_quest_target = true
         v.relation = Enum.Relation.Enemy
      end
   end
end

function Sidequest.no_targets_remaining(map)
   map = map or Map.current()

   for _, v in Chara.iter(map) do
      if Chara.is_alive(v) and v.is_quest_target then
         return false
      end
   end

   return true
end

function Sidequest.localize_progress_text(sidequest_id, progress)
   local sidequest_data = data["elona_sys.sidequest"]:ensure(sidequest_id)

   if sidequest_data.progress == nil then
      return nil
   end

   progress = progress or Sidequest.progress(sidequest_id)
   assert(type(progress) == "number")

   local text
   for _, req_progress in fun.iter(table.keys(sidequest_data.progress)):into_sorted() do
      if progress >= req_progress then
         text = sidequest_data.progress[req_progress]
      end
   end

   assert(progress == 0 or text, ("Invalid sidequest progress %d (%s)"):format(progress, sidequest_id))

   if type(text) == "function" then
      text = text(progress)
   elseif text then
      text = I18N.get_optional(text)
   else
      text = nil
   end

   return text
end

function Sidequest.update_journal()
   Gui.play_sound("base.write1");
   Gui.mes_c("quest.journal_updated", "Green");
end

return Sidequest
