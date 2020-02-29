local Gui = require("api.Gui")
local Input = require("api.Input")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")

local Mx = {}

local match_opts = {
   max_gap = 5,
   ignore_spaces = true
}

function Mx.completing_read(cands, opts)
   opts = opts or {}
   opts.match_opts = opts.match_opts or match_opts
   opts.prompt_length = 30

   return FuzzyFinderPrompt:new(cands, opts):query()
end

function Mx.read_type(ty, entry)
   if type(entry) == "table" and entry.prompt then
      Gui.mes(entry.prompt)
   end

   if data:has_type(ty) then
      local cands = data[ty]:iter():extract("_id"):to_list()
      return Mx.completing_read(cands)
   elseif ty == "number" then
      return Input.query_number(entry.max or nil, entry.initial_amount or nil)
   elseif ty == "string" then
      return Input.query_text(entry.length or 20, true, false)
   elseif ty == "choice" then
      assert(entry.candidates, "argument must have 'candidates' field")
      return Mx.completing_read(entry.candidates, { get_name = entry.get_name } )
   else
      error(("unknown argument type '%s'"):format(ty))
   end
end

local function get_single_arg(entry, arg)
   if type(entry) == "function" then
      return entry(arg)
   elseif type(entry) ~= "table" then
      return entry
   end

   local ty = assert(entry.type, "spec entry must have 'type' field")
   return Mx.read_type(ty, entry)
end

function Mx.get_args(spec, arg)
   local args = {}
   local canceled

   if type(spec) == "function" then
      args, canceled = spec(arg)
      if canceled then
         return nil, canceled
      end
      assert(type(args) == "table" and args[1])
   else
      for i, entry in ipairs(spec) do
         local arg, canceled = get_single_arg(entry, arg)
         if canceled then
            return nil, canceled
         end
         args[i] = arg
      end
   end

   return args, nil
end

function Mx.start(arg)
   local cands = data["tools.interactive_fn"]:iter():extract("_id"):to_list()

   local id, canceled = Mx.completing_read(cands)

   if canceled then
      return nil, canceled
   end

   if id == nil then
      return "player_turn_query"
   end

   local entry = data["tools.interactive_fn"]:ensure(id)
   local args, canceled = Mx.get_args(entry.spec, arg)
   if canceled then
      return nil, canceled
   end

   entry.func(table.unpack(args))

   return "player_turn_query"
end

function Mx.make_interactive(name, tbl, func, spec)
   if type(tbl) == "function" then
      spec = func
      func = "func"
      tbl = { func = tbl }
   end

   assert(tbl[func], ("Function '%s' not found in table"):format(func))
   local func = function(...) return tbl[func](...) end

   if data["tools.interactive_fn"][name] then
      data:replace {
         _type = "tools.interactive_fn",
         _id = name,
         func = func,
         spec = spec or {}
      }
   else
      data:add {
         _type = "tools.interactive_fn",
         _id = name,
         func = func,
         spec = spec or {}
      }
   end
end

return Mx
