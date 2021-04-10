local Draw = require("api.Draw")
local Gui = require("api.Gui")
local UiTheme = require("api.gui.UiTheme")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local I18N = require("api.I18N")
local UiHelpMarkup = require("api.gui.UiHelpMarkup")
local TopicWindow = require("api.gui.TopicWindow")
local Ui = require("api.Ui")
local MorePrompt = require("api.gui.MorePrompt")

local ExHelpPrompt = class.class("ExHelpPrompt", IUiLayer)

ExHelpPrompt:delegate("input", IInput)

-- string.split is dumb and doesn't support delimiters with more than 1
-- character...
local function split(str, delimiter)
   local result = {}
   local from  = 1
   local delim_from, delim_to = string.find(str, delimiter, from)
   while delim_from do
      result[#result+1] = string.sub(str, from, delim_from-1)
      from  = delim_to + 1
      delim_from, delim_to = string.find(str, delimiter, from)
   end
   result[#result+1] = string.sub(str, from)
   return result
end

function ExHelpPrompt:init(help_id)
   data["elona.ex_help"]:ensure(help_id)

   local text = assert(I18N.get_optional(("elona.ex_help._.%s"):format(help_id)), "missing help text for " .. help_id)

   self.sections = split(text, "\n\n")
   if #self.sections == 0 then
      error("No sections found.")
   end
   self.section_index = 1
   self.finished = false

   local font_size = 14 -- 15
   self.text = UiHelpMarkup:new(self.sections[self.section_index], font_size, true)

   self.topic_win_a = TopicWindow:new(4, 0)
   self.topic_win_b = TopicWindow:new(0, 1)
   self.more_prompt = MorePrompt:new()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:halt_input()
end

function ExHelpPrompt:make_keymap()
   local next_section = function()
      self.more_prompt:run_keybind_action("enter")
   end

   return {
      cancel = next_section,
      escape = next_section,
      enter = next_section,
   }
end

function ExHelpPrompt:on_query()
   Gui.play_sound("base.chime")
end

function ExHelpPrompt:proceed()
   self.section_index = self.section_index + 1

   if self.section_index > #self.sections then
      self.finished = true
   else
      self.text:set_data(self.sections[self.section_index])
   end
end

function ExHelpPrompt:relayout(x, y, width, height)
   -- >>>>>>>> shade2/help.hsp:152 	dx=480:dy=175 ...
   self.width = 480
   self.height = 175
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   self.topic_win_a:relayout(self.x, self.y, self.width, self.height)

   local wx, wy = Ui.params_centered(325, self.height)
   self.topic_win_b:relayout(wx, wy + 6, 325, 32)
   -- <<<<<<<< shade2/help.hsp:155 	window2 winPosX(325),winPosY(dy)+6,325,32,0,1 ..

   -- >>>>>>>> shade2/init.hsp:3895 	#deffunc help_halt ...
   self.more_prompt:relayout(self.x + self.width - 140, self.y + self.height - 1)
   -- <<<<<<<< shade2/init.hsp:3898 	return ..

   self.text:relayout(self.x + 120, self.y + 55, self.width - 158, self.height - 55)
   self.text:set_color(self.t.elona.help_markup_text_color)
end

function ExHelpPrompt:draw()
   self.topic_win_a:draw()
   self.topic_win_b:draw()

   self.t.base.deco_help_a:draw(self.x + 5, self.y + 4)
   self.t.base.deco_help_a:draw(self.x + self.width - 55, self.y + 4)
   self.t.base.deco_help_b:draw(self.x + 10, self.y + 42)

   Draw.set_font(16, "bold")
   Draw.text_shadowed(I18N.get("ui.exhelp.title"), self.x + 142, self.y + 13,
                      self.t.elona.ex_help_title_color, self.t.elona.ex_help_title_outline_color)

   self.text:draw()

   self.more_prompt:draw()
end

function ExHelpPrompt:update(dt)
   self.topic_win_a:update(dt)
   self.topic_win_b:update(dt)
   self.text:update(dt)

  if self.more_prompt:update(dt) then
    self:proceed()
    self.more_prompt:init()
  end

  local finished = self.finished
  self.finished = false

  if finished then
     return true, nil
  end
end

return ExHelpPrompt
