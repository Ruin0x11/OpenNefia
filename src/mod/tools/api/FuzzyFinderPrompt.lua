
local Draw = require("api.Draw")
local FuzzyMatch = require("mod.tools.api.FuzzyMatch")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local TopicWindow = require("api.gui.TopicWindow")
local TextPrompt = require("api.gui.TextPrompt")
local TextHandler = require("api.gui.TextHandler")

local FuzzyFinderPrompt = class.class("FuzzyFinderPrompt", IUiLayer)

FuzzyFinderPrompt:delegate("input", IInput)

function FuzzyFinderPrompt:init(cands, initial_prompt, match_opts)
   self.width = 360
   self.height = 200

   self.cands = cands
   self.matched_cands = {}
   self.match_opts = match_opts or {}
   self.last_search = nil
   self.topic_win = TopicWindow:new(1, 1)
   self.text_prompt = TextPrompt:new(20, true, false, false, nil, initial_prompt, false)
   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:forward_to(self.text_prompt)

   self:update_match()
end

function FuzzyFinderPrompt:make_keymap()
   return {
      text_entered = function(t)
         print"enter"
         self.text_prompt:run_key_action(t)
         self:update_match()
      end,
      raw_backspace = function()
         print"raw"
         self.text_prompt:run_key_action("backspace")
         self:update_match()
      end,
      north = function()
         print"north"
      end,
      south = function()
      end,
      west = function()
      end,
      east = function()
      end,
      repl_page_up = function()
      end,
      repl_page_down = function()
      end,
      repl_first_char = function()
      end,
      repl_last_char = function()
      end,
      repl_paste = function()
      end,
      repl_cut = function()
      end,
      repl_copy = function()
      end,
      repl_clear = function()
      end
   }
end

local function gen_regex(text)
   return string.gsub(text, " ", "(.*)")
end

function FuzzyFinderPrompt:update_match()
   local cands = self.cands
   local text = self.text_prompt:get_text()
   if self.last_search and string.match(text, "^" .. string.escape_for_gsub(self.last_search)) then
      -- exclude candidates that don't match.
      cands = fun.iter(self.matched_cands):extract(1):to_list()
   end
   self.matched_cands = FuzzyMatch.match(text, cands, self.match_opts)

   local regex = gen_regex(text)
   for _, cand in ipairs(self.matched_cands) do
   end

   self.last_search = self.prompt
end

function FuzzyFinderPrompt:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.y = self.y

   self.text_prompt.width = self.width
   self.text_prompt:relayout(self.x, self.y)
   self.topic_win:relayout(self.x, self.y+self.text_prompt.height, self.width, self.height)
end

function FuzzyFinderPrompt:draw()
   self.topic_win:draw()
   Draw.set_font(14)
   local y = self.topic_win.y
   for i=1,math.min(10, #self.matched_cands) do
      y = y + Draw.text_height()
      local cand = self.matched_cands[i]
      Draw.text(("%s  %01.02f"):format(cand[1], cand[2]), self.x + 10, y)
   end

   self.text_prompt:draw()
end

function FuzzyFinderPrompt:update(dt)
   self.topic_win:update(dt)

   local text, canceled = self.text_prompt:update(dt)
   if canceled then
      return nil, "canceled"
   elseif text then
      return text
   end
end

return FuzzyFinderPrompt
