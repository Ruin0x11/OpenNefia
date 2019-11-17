local Draw = require("api.Draw")
local Env = require("api.Env")
local Gui = require("api.Gui")
local Object = require("api.Object")
local circular_buffer = require("thirdparty.circular_buffer")
local queue = require("util.queue")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local LuaReplMode = require("api.gui.menu.LuaReplMode")
local TextHandler = require("api.gui.TextHandler")
local ReplCompletion = require("api.gui.menu.ReplCompletion")

local ReplLayer = class.class("ReplLayer", IUiLayer)

ReplLayer:delegate("input", IInput)

function ReplLayer:init(env, history)
   self.text = ""
   self.env = env or {}
   self.result = ""
   self.size = 10000
   self.color = {17, 17, 65, 192}

   self.scrollback = circular_buffer:new(self.size)
   self.scrollback_index = 0

   self.history = history or {}
   self.history_index = 0

   self.output = {}

   -- quake pulldown
   self.pulldown = true
   self.pulldown_y = 0
   self.pulldown_speed = 8
   self.frames = 0

   -- line editing support
   self.cursor_pos = 0
   self.cursor_x = 0

   -- tab completion
   self.completion = nil

   self.deferred = queue:new()

   self.print_varargs = false

   -- mode of operation. could implement Elona-style console if
   -- desired.
   self.mode = LuaReplMode:new(env)

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys {
      text_entered = function(t)
         self:insert_text(t)
         self.completion = nil
      end,
      backspace = function()
         self:delete_char()
         self.completion = nil
      end,
      text_submitted = function()
         self:submit()
         local res, err = pcall(Gui.update_screen)
         if not res then
            self:print("[DRAW ERROR] " .. err)
         end
         self.input:halt_input()
      end,
      text_canceled = function()
         self.finished = true
      end,
      up = function()
         self:history_next()
      end,
      down = function()
         self:history_prev()
      end,
      left = function()
         self:move_cursor(-1)
      end,
      right = function()
         self:move_cursor(1)
      end,
      pageup = function()
         self:scrollback_up()
      end,
      pagedown = function()
         self:scrollback_down()
      end,
      home = function()
         self:set_cursor_pos(0)
      end,
      ["end"] = function()
         self:set_cursor_pos(#self.text)
      end,
      tab = function()
         local function complete(cand)
            local text = self.completion.base .. cand.text
            if cand.type == "function" then
               text = text .. "("
            end
            self:set_text(text)
         end

         if not self.completion then
            local cp = ReplCompletion:new()
            self.completion = cp:complete(self.text, self.env)
            if self.completion then
               local complete_single = true
               if #self.completion.candidates == 1 and complete_single then
                  complete(self.completion.candidates[1])
                  self.completion = nil
               else
                  self:print(inspect(fun.iter(self.completion.candidates):extract("text"):to_list()))
               end
            end
         else
            self.completion.selected =
               (self.completion.selected + 1) % #self.completion.candidates
            local cand = self.completion.candidates[self.completion.selected+1]
            complete(cand)
         end
      end
   }
   self.input:halt_input()
end

function ReplLayer:on_query()
   self.completion = nil
   if self.scrollback:len() == 0 then
      self:print(string.format("Elona_next(仮 REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                               Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
   end
end

function ReplLayer:history_prev()
   self.scrollback_index = 0
   self.history_index = math.max(self.history_index - 1, 0)
   self:set_text(self.history[self.history_index])
   self.completion = nil
end

function ReplLayer:history_next()
   self.scrollback_index = 0
   self.history_index = math.min(self.history_index + 1, #self.history)
   self:set_text(self.history[self.history_index])
   self.completion = nil
end

function ReplLayer:set_text(text)
   self.text = text or ""

   self:set_cursor_pos(#self.text)
end

function ReplLayer:scrollback_up()
   self.scrollback_index = math.clamp(self.scrollback_index + math.floor(self.max_lines / 2),
                                      0,
                                      math.max(self.scrollback:len() - self.max_lines, 0))
end

function ReplLayer:scrollback_down()
   self.scrollback_index = math.clamp(self.scrollback_index - math.floor(self.max_lines / 2),
                                      0,
                                      math.max(self.scrollback:len() - self.max_lines, 0))
end

function ReplLayer:clear()
   self.scrollback = circular_buffer:new(self.size)
   self.scrollback_index = 0

   self:set_text("")
end

function ReplLayer:move_cursor(codepoints)
   local pos = utf8.find_next_pos(self.text, self.cursor_pos, codepoints)
   if codepoints > 0 and pos == 0 then
      pos = utf8.offset(self.text, 1)
   end
   if pos < 1 then
      self.cursor_pos = 0
      self.cursor_x = 0
      return
   end

   self:set_cursor_pos(pos)
end

function ReplLayer:insert_text(t)
   if self.cursor_pos == #self.text then
      self.text = self.text .. t
   elseif self.cursor_pos == 0 then
      self.text = t .. self.text
   else
      local a, b = string.split_at_pos(self.text, self.cursor_pos)
      self.text = a .. t .. b
   end

   self:move_cursor(utf8.len(t))
end

function ReplLayer:delete_char()
   if self.cursor_pos == 0 then
      return
   end

   if self.cursor_pos == #self.text then
      self.text = utf8.pop(self.text)
   elseif self.cursor_pos == 1 then
      self.text = utf8.sub(self.text, 2)
   else
      local a, b = string.split_at_pos(self.text, self.cursor_pos)
      a = utf8.sub(a, 1, utf8.len(a)-1)
      self.text = a .. b
   end

   self:move_cursor(-1)
end

function ReplLayer:set_cursor_pos(byte)
   self.cursor_pos = math.clamp(0, byte, #self.text)

   Draw.set_font(self.font_size)
   local rest = string.sub(self.text, 0, self.cursor_pos)
   self.cursor_x = Draw.text_width(rest)
   self.frames = 0
end

function ReplLayer:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height() / 3
   self.font_size = 15
   Draw.set_font(self.font_size)
   self.max_lines = math.floor((self.height - 5) / Draw.text_height()) - 1

   if self.pulldown then
      self.pulldown = false
      self.pulldown_y = self.max_lines
   end
end

function ReplLayer:print(text)
   Draw.set_font(self.font_size)
   local success, err, wrapped = xpcall(function() return Draw.wrap_text(text, self.width) end, debug.traceback)
   if not success then
      self.scrollback:push("[REPL] error printing result: " .. string.split(err)[1])
      print(err)
   else
      for _, line in ipairs(wrapped) do
         self.scrollback:push(line)
      end
   end
end

function ReplLayer:execute(code)
   self:set_text(code)
   self:submit()
end

function ReplLayer.format_repl_result(result)
   local result_text
   local stop = false

   if type(result) == "table" then
      -- HACK: Don't print out unnecessary class fields. In the future
      -- `inspect` should be modified to account for this.
      if result._type and result._id then
         result_text = inspect(Object.make_prototype(result))
      elseif tostring(result) == "<generator>" then
         local max = 10
         local list = result:take(max + 1)
         local first = list:nth(1)
         if type(first) == "table" and first._type then
            list = list:map(Object.make_prototype)
         end
         if list:length() == max + 1 then
            result_text = "(iterator): " .. inspect(list:take(10):to_list())
            result_text = string.strip_suffix(result_text, " }")
            result_text = result_text .. ", <...> }"
         else
            result_text = "(iterator): " .. inspect(list:to_list())
         end
         stop = true
      else
         result_text = inspect(result)
      end
   else
      result_text = tostring(result)
   end

   return result_text, stop
end

local function join_results(acc, x, stop)
   if acc.stop then
      return acc
   end

   if stop then
      acc.stop = true
   end
   if not acc.text then
      acc.text = x
   else
      acc.text = acc.text .. "\t" .. x
   end

   return acc
end

function ReplLayer.format_results(results, print_varargs)
   local result_text

   if type(results) == "table" then
      if print_varargs then
         result_text = fun.iter(results):map(ReplLayer.format_repl_result):foldl(join_results, {}).text
      else
         result_text = ReplLayer.format_repl_result(results[1])
      end

      if result_text == nil then
         result_text = tostring(result_text)
      end
   else
      result_text = results
   end

   return result_text
end

function ReplLayer:submit()
   local text = self.text
   self.text = ""
   self.scrollback_index = 0
   self.history_index = 0
   self.cursor_pos = 0
   self.cursor_x = 0
   self.completion = nil

   self:print(self.mode.caret .. text)
   if string.nonempty(text) then
      table.insert(self.history, 1, text)
   end

   local success, results = self.mode:submit(text)

   local print_varargs
   if self.print_varargs then
      local print_varargs = true
   else
      print_varargs = fun.iter(results):all(function(r) return type(r) ~= "table" end)
   end

   local result_text = ReplLayer.format_results(results, print_varargs)

   if not success then
      print(result_text)
   end

   self.output[#self.output+1] = result_text

   self:print(result_text)

   self:save_history()
end

function ReplLayer:save_history()
   -- HACK: this must go through the config API eventually.
   local file = io.open("repl_history.txt", "w")
   for i, v in ipairs(self.history) do
      file:write(v)
      file:write("\n")
   end
   file:close()
end

function ReplLayer:last_input()
   local line = self.history[2]
   if line then
      return line
   end

   return nil
end

function ReplLayer:last_output()
   local output = self.output[#self.output]
   if output then
      return output
   end

   return nil
end

function ReplLayer:defer_execute(code)
   self.deferred:push(code)
end

function ReplLayer:execute_all_deferred()
   local code = self.deferred:pop()
   local success, results
   while code do
      if type(code) == "function" then
         success, results = xpcall(code, debug.traceback)
      else
         success, results = self.mode:submit(code)
      end
      code = self.deferred:pop()

      if not success then
         error(results[1])
      end
   end
   return success, results
end

function ReplLayer:draw()
   Draw.set_font(self.font_size)

   -- background
   local top = self.height - self.pulldown_y * Draw.text_height()
   Draw.filled_rect(self.x, self.y, self.width, top, self.color)

   -- caret
   Draw.set_color(255, 255, 255)
   Draw.text(self.mode.caret, self.x + 5, self.y + top - Draw.text_height() - 5)
   Draw.text(self.text, self.x + 5 + Draw.text_width(self.mode.caret), self.y + top - Draw.text_height() - 5)

   -- blinking cursor
   if math.floor(self.frames * 2) % 2 == 0 then
      local x = self.x + 5 + Draw.text_width(self.mode.caret) + self.cursor_x + 1
      local y = self.y + top - Draw.text_height() - 5
      Draw.line(x, y, x, y + Draw.text_height() - 1)
   end

   -- scrollback counter
   if self.scrollback_index > 0 then
      local scrollback_count = string.format("%d/%d",self.scrollback_index + self.max_lines, self.scrollback:len())
      Draw.text(scrollback_count, self.width - Draw.text_width(scrollback_count) - 5, self.y + top - Draw.text_height() - 5)
   end

   -- scrollback display
   local offset = 0
   if self.completion and #self.completion.candidates > 1 then
      offset = 1
   end

   for i=1,self.max_lines do
      local t = self.scrollback[self.scrollback_index + i]
      if t == nil then
         break
      end
      Draw.text(t, self.x + 5, self.y + top - Draw.text_height() * (i+1+offset) - 5)
   end
end

function ReplLayer:update(dt)
   self.frames = self.frames + dt

   if self.finished then
      -- delay closing until pullup finishes
      self.pulldown = true
      if self.pulldown_y > self.max_lines then
         self.finished = false
         self.pulldown = true
         return true
      end
   end

   if self.finished then
      self.pulldown_y = math.min(self.pulldown_y + self.pulldown_speed, self.max_lines + 1)
   else
      if self.pulldown_y > 0 then
         self.pulldown_y = math.max(self.pulldown_y - self.pulldown_speed, 0)
      end
   end
end

function ReplLayer.on_hotload(old, new)
   require("game.field").repl = nil
   class.hotload(old, new)
end

return ReplLayer
