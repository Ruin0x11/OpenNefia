local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Save = require("api.Save")
local Action = require("api.Action")
local Item = require("api.Item")
local Enum = require("api.Enum")

local Autopickup = {}

local cache = nil

function Autopickup.clear_cache()
   cache = nil
end

Autopickup.OP = {
   DESTROY = "!",
   DESTROY_PROMPT = "!?",
   PROMPT = "?",
   NEGATION = "~",
   AUTOSAVE = "%",
   SET_NO_DROP = "=",
}

local VALID_OPS = {}
for k, v in pairs(Autopickup.OP) do
   VALID_OPS[v] = k
end

function Autopickup.compile_rule(rule)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:82451 						p = 0 ...
   local fns = {}

   rule = string.strip_whitespace(rule)

   local ops = {}

   local ch = rule:sub(0, 1)
   local op = VALID_OPS[ch]
   while op do
      rule = rule:sub(2)
      ops[#ops+1] = ch
      ch = rule:sub(0, 1)
      if ops[#ops] == Autopickup.OP.DESTROY and ch == "?" then
         ops[#ops] = Autopickup.OP.DESTROY_PROMPT
         rule = rule:sub(2)
         ch = rule:sub(0, 1)
      end
      op = VALID_OPS[ch]
   end

   local going = true
   while going do
      going = false
      for _, pred in data["autopickup.predicate"]:iter() do
         local ident = I18N.localize_optional("autopickup.predicate", pred._id, "identifier")
         if ident == nil then
            error(("Autopickup: Missing identifier for predicate %s"):format(pred._id))
         else
            if string.has_prefix(rule, ident) then
               rule = string.strip_prefix(rule, ident)
               rule = string.strip_whitespace(rule)
               fns[#fns+1] = function(item, chara)
                  return pred.match(item, chara)
               end
               going = true
               break
            end
         end
      end
   end

   -- item name or target identifier
   local name = rule
   local target_pred = nil

   for _, target in data["autopickup.target"]:iter() do
      local ident = I18N.localize_optional("autopickup.target", target._id, "identifier")
      if ident == nil then
         error(("Autopickup: Missing identifier for target %s"):format(rule))
      else
         if name == ident then
            target_pred = function(item, chara)
               return target.match(item, chara)
            end
            break
         end
      end
   end

   return function(item, chara)
      local matched = false
      for _, pred in ipairs(fns) do
         if not pred(item, chara) then
            return false
         end
         matched = true
      end

      if item:build_name():find(name) then
         return true, ops
      else
         if not matched then
            return false
         end
         if target_pred and target_pred(item, chara) then
            return true, ops
         end
      end

      return false
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:82859 						} ..
end

function Autopickup.run_rule(chara, item, rule)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:82860 						if (p == 1) { ...
   local matched, ops = rule(item, chara)
   if not matched then
      return false
   end

   ops = table.set(ops)

   local destroy = false
   if ops[Autopickup.OP.DESTROY_PROMPT] then
      Gui.mes("autopickup:act.destroy.prompt", item:build_name())
      Gui.update_screen()
      if Input.yes_no() then
         destroy = true
      else
         return true
      end
   elseif ops[Autopickup.OP.DESTROY] then
      destroy = true
   end

   if destroy then
      if config.autopickup.sound_on_destroy then
         Gui.play_sound("base.crush1", item.x, item.y)
      end
      item:remove_ownership()
      Gui.mes("autopickup:act.destroy.execute", item:build_name())
      return true
   end

   if ops[Autopickup.OP.NEGATION] then
      -- Stops running the rules after this one.
      return true
   end

   if ops[Autopickup.OP.PROMPT] then
      Gui.mes("autopickup:act.pick_up.prompt", item:build_name())
      Gui.update_screen()
      if not Input.yes_no() then
         return true
      end
   end

   if ops[Autopickup.OP.AUTOSAVE] then
      Save.queue_autosave()
   end

   if ops[Autopickup.OP.SET_NO_DROP] then
      Gui.mes("ui.inv.examine.no_drop.set", item:build_name())
      item.is_no_drop = true
   end

   Action.get(chara, item)

   return true
   -- <<<<<<<< oomSEST/src/southtyris.hsp:82911 						} ..
end

function Autopickup.can_autopickup(item)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:82445 		if (iNumber(cnt) > 0) { ...
   return Item.is_alive(item) and item:calc("own_state") < Enum.OwnState.NotOwned
   -- <<<<<<<< oomSEST/src/southtyris.hsp:82446 			if (iOwnState(cnt) < 1) { ..
end

function Autopickup.run(chara, rules, x, y)
   local map = chara:current_map()
   if map == nil then
      return
   end

   x = x or chara.x
   y = y or chara.y

   if rules == nil then
      if cache == nil then
         local rules_text = config.autopickup.rules
         if rules_text == "" then
            return false
         end

         local valid_rule = function(s) return s ~= "" and s:sub(0, 1) ~= "#" end

         cache = fun.wrap(fun.dup(string.lines(rules_text)))
            :filter(valid_rule)
            :map(Autopickup.compile_rule)
            :to_list()
      end
      rules = cache
   end

   local did_something = false
   for _, item in Item.at(x, y, map):filter(Autopickup.can_autopickup) do
      for _, rule in ipairs(rules) do
         if Autopickup.run_rule(chara, item, rule) then
            did_something = true
            break
         end
      end
   end

   return did_something
end

return Autopickup
