--- @module Repl

local Codegen = require("api.Codegen")
local Env = require("api.Env")
local SaveFs = require("api.SaveFs")
local env = require("internal.env")
local field = require("game.field")
local repl = require("internal.repl")
local fs = require("util.fs")

local Repl = {}

function Repl.send(code)
   field.repl:execute(code)
end

function Repl.query()
   return field:query_repl()
end

function Repl.get()
   return field.repl
end

function Repl.clear()
   return Repl.get():clear()
end

function Repl.copy_last_input()
   local line = Repl.get():last_input()
   Env.set_clipboard_text(line)
   return line
end

function Repl.copy_last_output()
   local line = Repl.get():last_output()
   Env.set_clipboard_text(line)
   return line
end

function Repl.wrap_last_input_as_function()
   local line = Repl.get():last_input()
   if not line then return end

   line = "return " .. line

   -- HACK instead save mod sandbox somewhere
   local env = Repl.get().env
   local f, err = Codegen.loadstring(line)
   if f then
      setfenv(f, env)
   end
   return f, err
end

function Repl.wrap_last_input_as_iterator()
   local f, err = Repl.wrap_last_input_as_function()
   if not f then
      return f, err
   end

   return fun.tabulate(f)
end

--- Queues a code block that runs the next time execution enters the
--- player's control. If the code returns a turn result, it is used as
--- the player's turn.
function Repl.defer_execute(code)
   field.repl:defer_execute(code)
end

function Repl.generate_env(locals)
   locals = locals or {}

   local repl_env = env.generate_sandbox("repl")
   local apis = repl.require_all_apis("api", true)
   repl_env = table.merge(repl_env, apis)

   repl_env = table.merge(repl_env, _G)
   repl_env = table.merge(repl_env, repl.require_all_apis("internal", true))
   repl_env = table.merge(repl_env, repl.require_all_apis("game"))
   repl_env = table.merge(repl_env, repl.require_all_apis("util"))
   repl_env["save"] = require("internal.global.save")

   local history = {}
   if SaveFs.exists("data/repl_history") then
      local ok
      ok, history = SaveFs.read("data/repl_history")
      if not ok then
         error(history)
      end
   end

   local vars = { normal = repl_env, locals = locals }

   local env = setmetatable({}, {
         __index = function(self, ind)
            if rawget(vars.locals, ind) then
               return rawget(vars.locals, ind)
            end
            return rawget(vars.normal, ind)
         end,
         __newindex = function(self, ind, val)
            if rawget(vars.locals, ind) then
               rawset(vars.locals, ind, val)
            else
               rawset(vars.normal, ind, val)
            end
         end
   })

   if fs.exists("repl_startup.lua") then
      local chunk = loadfile("repl_startup.lua")
      setfenv(chunk, env)
      chunk()
   end

   return env, history
end

local paused = false

--- Stops execution at the point this function is called and starts
--- the REPL with all local variables in scope captured in its
--- environment. If any modifications are made to local variables,
--- they will be reflected when execution resumes.
function Repl.pause()
   if paused then
      return
   end
   paused = true

   local locals = repl.capture_locals(1)
   local repl_env, history = Repl.generate_env(locals)

   local mod, loc = env.find_calling_mod()
   local loc_string = ""
   if loc then
      loc_string = loc_string .. (" in %s on line %d"):format(fs.normalize(loc.short_src), loc.linedefined)
   end
   if mod then
      loc_string = loc_string .. (" (mod: `%s`)"):format(mod)
   end

   local mes = ("Breakpoint%s.\nLocals: %s"):format(loc_string, table.concat(table.keys(locals), ", "))
   local params = {
      history = history,
      color = {65, 17, 17, 192},
      message = mes
   }

   local ok, err = pcall(function()
         require("api.gui.menu.ReplLayer")
            :new(repl_env, params)
            :query(100000000) -- draw on top of everything
   end)

   repl.restore_locals(1, locals)

   paused = false

   if not ok then
      error(err)
   end
end

return Repl
