local repl = {}

-- from mobdebug
function repl.capture_locals(level, thread)
   level = (level or 0)+2 -- add two levels for this and debug calls
   local func = (thread and debug.getinfo(thread, level, "f") or debug.getinfo(level, "f") or {}).func
   if not func then return {} end

   local vars = {['...'] = {}}
   local i = 1
   while true do
      local name, value = debug.getupvalue(func, i)
      if not name then break end
      if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
      i = i + 1
   end
   i = 1
   while true do
      local name, value
      if thread then
         name, value = debug.getlocal(thread, level, i)
      else
         name, value = debug.getlocal(level, i)
      end
      if not name then break end
      if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
      i = i + 1
   end
   -- get varargs (these use negative indices)
   i = 1
   while true do
      local name, value
      if thread then
         name, value = debug.getlocal(thread, level, -i)
      else
         name, value = debug.getlocal(level, -i)
      end
      -- `not name` should be enough, but LuaJIT 2.0.0 incorrectly reports `(*temporary)` names here
      if not name or name ~= "(*vararg)" then break end
      vars['...'][i] = value
      i = i + 1
   end
   -- returned 'vars' table plays a dual role: (1) it captures local values
   -- and upvalues to be restored later (in case they are modified in "eval"),
   -- and (2) it provides an environment for evaluated chunks.
   -- getfenv(func) is needed to provide proper environment for functions,
   -- including access to globals, but this causes vars[name] to fail in
   -- restore_vars on local variables or upvalues with `nil` values when
   -- 'strict' is in effect. To avoid this `rawget` is used in restore_vars.
   setmetatable(vars, { __index = getfenv(func), __newindex = getfenv(func), __mode = "v" })
   return vars
end

-- from mobdebug
function repl.restore_locals(level, vars)
   if type(vars) ~= 'table' then return end
   level = (level or 0)+2 -- add two levels for this and debug calls

   -- locals need to be processed in the reverse order, starting from
   -- the inner block out, to make sure that the localized variables
   -- are correctly updated with only the closest variable with
   -- the same name being changed
   -- first loop find how many local variables there is, while
   -- the second loop processes them from i to 1
   local i = 1
   while true do
      local name = debug.getlocal(level, i)
      if not name then break end
      i = i + 1
   end
   i = i - 1
   local written_vars = {}
   while i > 0 do
      local name = debug.getlocal(level, i)
      if not written_vars[name] then
         if string.sub(name, 1, 1) ~= '(' then
            debug.setlocal(level, i, rawget(vars, name))
         end
         written_vars[name] = true
      end
      i = i - 1
   end

   i = 1
   local func = debug.getinfo(level, "f").func
   while true do
      local name = debug.getupvalue(func, i)
      if not name then break end
      if not written_vars[name] then
         if string.sub(name, 1, 1) ~= '(' then
            debug.setupvalue(func, i, rawget(vars, name))
         end
         written_vars[name] = true
      end
      i = i + 1
   end
end

return repl
