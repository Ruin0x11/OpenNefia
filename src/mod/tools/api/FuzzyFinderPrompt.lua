local Draw = require("api.Draw")
local FuzzyMatch = require("mod.tools.api.FuzzyMatch")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local TextPrompt = require("api.gui.TextPrompt")
local FuzzyFinderList = require("mod.tools.api.FuzzyFinderList")
local TextHandler = require("api.gui.TextHandler")

local FuzzyFinderPrompt = class.class("FuzzyFinderPrompt", IUiLayer)

FuzzyFinderPrompt:delegate("input", IInput)

function FuzzyFinderPrompt:init(cands, opts)
   opts = opts or {}

   self.height = 200

   if tostring(cands) == "<generator>" then
      cands = cands:to_list()
   end

   opts.get_name = opts.get_name or tostring
   opts.prompt_length = opts.prompt_length or 20

   for i=1,#cands do
      if type(cands[i]) == "string" then
         cands[i] = { cands[i], data = cands[i] }
      else
         cands[i] = { opts.get_name(cands[i]), data = cands[i] }
      end
   end

   self.cands = cands
   self.matched_cands = {}
   self.match_opts = opts.match_opts or {}
   self.last_search = nil
   self.list = FuzzyFinderList:new(cands)
   self.text_prompt = TextPrompt:new(opts.prompt_length, true, false, false, nil, opts.initial_prompt, false)
   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:forward_to({self.list, self.text_prompt})

   self:update_match()
end

function FuzzyFinderPrompt:make_keymap()
   return {
      text_entered = function(t)
         self.text_prompt:run_key_action(t)
         self:update_match()
      end,
      raw_backspace = function()
         self.text_prompt:run_key_action("backspace")
         self:update_match()
      end,
      north = function()
         self.list:run_keybind_action("north")
      end,
      south = function()
         self.list:run_keybind_action("south")
      end,
      ["tools.prompt_previous"] = function()
         self.list:run_keybind_action("north")
      end,
      ["tools.prompt_next"] = function()
         self.list:run_keybind_action("south")
      end,
      repl_page_up = function()
         self.list:run_keybind_action("repl_page_up")
      end,
      repl_page_down = function()
         self.list:run_keybind_action("repl_page_down")
      end,
      repl_paste = function()
         self.text_prompt:run_key_action("repl_paste")
         self:update_match()
      end,
      repl_cut = function()
         self.text_prompt:run_key_action("repl_cut")
         self:update_match()
      end,
      repl_copy = function()
         self.text_prompt:run_key_action("repl_copy")
         self:update_match()
      end,
      repl_clear = function()
         self.text_prompt:run_key_action("repl_clear")
         self:update_match()
      end
   }
end

local function get_matched_regions(query, cand)
   Draw.set_font(14)

   local parts = string.split(query, " ")
   local regions = {}
   local the_start = 0
   for _, part in ipairs(parts) do
      if query == "" or part == "" then
         regions[#regions+1] = {0, 0}
      else
         local regex = ("(%s).*"):format(part)
         local start, _, matched = string.find(cand:lower(), regex, the_start)
         start = start or the_start

         local start_pos = Draw.text_width(cand:sub(1, start-1))
         local part_len = Draw.text_width(matched)
         the_start = start
         regions[#regions+1] = {start_pos, part_len}
      end
   end
   return regions
end

function FuzzyFinderPrompt:update_match()
   local cands = self.cands
   local query = self.text_prompt:get_text()
   if self.last_search and string.match(query, "^" .. string.escape_for_gsub(self.last_search)) then
      -- exclude candidates that didn't match last time.
      cands = self.matched_cands
   end

   self.matched_cands = FuzzyMatch.match(query, cands, self.match_opts)

   for i, cand in ipairs(self.matched_cands) do
      cand.matched_regions = get_matched_regions(query, cand[1])
   end

   self.list:set_data(self.matched_cands)
   self.last_search = self.prompt
end

function FuzzyFinderPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function FuzzyFinderPrompt:relayout()
   self.width = self.text_prompt.length * 16 + 60

   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.y = self.y

   self.text_prompt.width = self.width
   self.text_prompt:relayout(self.x, self.y)
   self.list:relayout(self.x, self.y+self.text_prompt.height, self.width, self.height)
end

function FuzzyFinderPrompt:draw()
   self.list:draw()
   self.text_prompt:draw()
end

function FuzzyFinderPrompt:update(dt)
   self.list:update(dt)

   local text, canceled = self.text_prompt:update(dt)
   if canceled then
      return nil, "canceled"
   elseif text then
      -- { "base.test", 0.75, data = "data", matched_regions = {{200, 20}} }
      local item = self.list:selected_item()
      if item == nil then
         return nil
      end
      return item.data
   end
end

return FuzzyFinderPrompt
