local I18N = require("api.I18N")

local Draw = require("api.Draw")
local Prompt = require("api.gui.Prompt")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")

local DeathMenu = class.class("DeathMenu", IUiLayer)

DeathMenu:delegate("input", IInput)

local function build_death_desc(bone)
   local desc = ("%s %s %s "):format(bone.title, bone.name, bone.last_words)
   desc = ("%-60s"):format(desc)
   desc = desc .. I18N.get("misc.death.date", bone.date.year, bone.date.month, bone.date.day)

   local cause = I18N.get("misc.death.you_died", bone.death_cause, bone.map_name)

   return desc, cause
end

function DeathMenu:init(bones, this_bone)
   self.this_bone_idx = fun.iter(bones):index(this_bone)
   assert(self.this_bone_idx)

   local function map(bone)
      local desc, cause = build_death_desc(bone)
      return {
         description = desc,
         death_cause = cause,
         image = bone.image,
         color = bone.color,
         score = bone.score
      }
   end
   self.bones = fun.iter(bones):take(8):map(map):to_list()

   self.caption = CharaMakeCaption:new("misc.death.you_are_about_to_be_buried")
   self.prompt = Prompt:new({"misc.death.crawl_up", "misc.death.lie_on_your_back"}, 240)

   self.chip_batch = nil

   self.input = InputHandler:new()
   self.input:forward_to(self.prompt)
   self.input:bind_keys(self:make_keymap())
end

function DeathMenu:make_keymap()
   return {
      shift = function() self.canceled = true end
   }
end

function DeathMenu:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   self.chip_batch = Draw.make_chip_batch("chip")

   self.caption:relayout(self.x + 20, self.y + 30)
   self.prompt:relayout(nil, 100)
end

function DeathMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.void:draw(self.x, self.y, self.width, self.height)

   local x = 135
   local y = 134
   Draw.set_font(14) -- 14 - en * 2

   Draw.set_color(138, 131, 100)
   for i = 1, 8 do
      y = y + 46

      local text
      if i == self.this_bone_idx then
         text = "New!"
      else
         text = I18N.get("misc.score.rank", i)
      end

      Draw.set_color(10, 10, 10)

      Draw.text(text, x - 80, y + 10)

      local no_entry = i > #self.bones
      if no_entry then
         Draw.text("no_entry", x, y)
      else
         local bone = self.bones[i]
         Draw.text(bone.description, x, y)
         Draw.text(bone.death_cause, x, y + 20)
         Draw.text(I18N.get("misc.score.score", bone.score), x + 480, y + 20)
         Draw.set_color(255, 255, 255)
         self.chip_batch:add(bone.image, x - 22, y + 12, nil, nil, nil, true)
      end
   end

   self.chip_batch:draw()
   self.chip_batch:clear()

   self.caption:draw()
   self.prompt:draw()
end

function DeathMenu:update()
   self.caption:update()

   local result, canceled = self.prompt:update()
   if result then
      return result, canceled
   end
end

function DeathMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
end

return DeathMenu
