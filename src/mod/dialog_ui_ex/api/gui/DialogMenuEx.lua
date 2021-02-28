local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local TopicWindow = require("api.gui.TopicWindow")
local Easing = require("mod.extlibs.api.Easing")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")

local DialogMenuEx = class.class("DialogMenuEx", IUiLayer)

DialogMenuEx:delegate("input", IInput)

function DialogMenuEx:init()
   self.text = ""
   self.wrapped = {}
   self.wrapped_chars = {}
   self.choices = {}
   self.speaker_name = ""
   self.portrait = nil
   self.chara_image = nil
   self.image_color = nil
   self.default_choice = nil
   self.can_cancel = true
   self.is_in_game = false
   self.impression = 0
   self.interest = 0

   self.actors = {}
   self.advance_dt = 0.0
   self.dt_per_char = 0.5
   self.char_appear_speed = 3
   self.fully_displayed = false

   self.font_size = 20
   self.text_padding = 24

   self.dialog_win = TopicWindow:new(0, 1)
   self.speaker_name_win = TopicWindow:new(1, 4)
   self.chip_batch = nil
   self.portrait_batch = nil

   self.pages = UiList:new_paged(self.choices, 8)
   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function DialogMenuEx:make_keymap()
   return {
      cancel = function() self:cancel() end,
      escape = function() self:cancel() end,
      enter = function() self:proceed() end,
   }
end

function DialogMenuEx:cancel()
   if not self.fully_displayed then
      self:finish_displaying_text()
      self:halt_input()
      return
   end
   if true or self.default_choice then
      self.canceled = true
   end
end

function DialogMenuEx:proceed()
   if not self.fully_displayed then
      self:finish_displaying_text()
      self:halt_input()
      return
   end
end

function DialogMenuEx:finish_displaying_text()
   self.fully_displayed = true
   self.input:forward_to(self.more_prompt)
end

function DialogMenuEx:step_dialog(text,
                                  choices,
                                  speaker_name,
                                  portrait,
                                  chara_image,
                                  image_color,
                                  default_choice,
                                  is_in_game,
                                  impression,
                                  interest)
   self.text = text
   self.wrapped = {}
   self.choices = choices
   self.speaker_name = speaker_name or ""
   self.portrait = portrait
   self.chara_image = chara_image
   self.image_color = image_color
   self.default_choice = default_choice
   self.can_cancel = default_choice ~= nil
   self.is_in_game = is_in_game
   self.impression = impression
   self.interest = interest

   if self.choices == nil or #self.choices == 0 then
      self.choices = { I18N.get("ui.more") }
   end
end

local function sort_actors(a, b)
   if a.is_active then
      return false
   end
   if b.is_active then
      return true
   end
   return a.index < b.index
end

function DialogMenuEx:relayout(x, y, width, height)
   self.width = 800
   self.height = 600

   self.x = math.max(Draw.get_width() / 2 - self.width / 2, 0)
   self.y = math.max(Draw.get_height() - self.height, 0)
   self.t = UiTheme.load(self)

   self.actors = {
      {
         asset_id = "dialog_ui_ex.kumiromi",
         id = "elona.kumiromi",
         is_active = true,
         begin_x = 0,
         dest_x = 0,
         current_x = 0,
         elapsed_time = 0.0,
         total_time = 0.5
      },
      {
         asset_id = "dialog_ui_ex.mani",
         id = "elona.mani",
         is_active = false,
         begin_x = 0,
         dest_x = 0,
         current_x = 0,
         elapsed_time = 0.0,
         total_time = 0.5
      },
      {
         asset_id = "dialog_ui_ex.mani",
         id = "elona.opatos",
         is_active = false,
         begin_x = 0,
         dest_x = 0,
         current_x = 0,
         elapsed_time = 0.0,
         total_time = 0.5
      }
   }

   local scale = 1.0
   for i, actor in ipairs(self.actors) do
      actor.begin_x = 0
      actor.asset = self.t[actor.asset_id]

      local actor_width = actor.asset:get_width()
      local actor_height = actor.asset:get_height()

      if actor_width > width / 2 then
         scale = math.min(scale, width / 2 / actor_width)
      end
      if actor_height > height * 0.6 then
         scale = math.min(scale, height * 0.6 / actor_height)
      end

      actor.index = i
   end

   local space = self.width / #self.actors
   for i, actor in ipairs(self.actors) do
      actor.width = actor.asset:get_width() * scale
      actor.height = actor.asset:get_height() * scale

      actor.dest_x = self.x + space * (i - 1) + space / 2 - actor.height / 2
      actor.index = i
   end
   table.sort(self.actors, sort_actors)

   self.advance_dt = 0.0
   self.dt_per_char = 0.5
   self.fully_displayed = false

   -- ========================================

   Draw.set_font(self.font_size)

   local dialog_win_width = 700
   local dialog_win_x = self.x + (self.width - dialog_win_width) / 2
   local dialog_win_y = Gui.message_window_y() - 80
   local dialog_win_height = height - dialog_win_y
   self.dialog_win:relayout(dialog_win_x, dialog_win_y, dialog_win_width, dialog_win_height)

   -- self.pages:relayout(self.x + 136, self.y + self.height - 56 - self.pages:len() * 19 + 4, self.width, self.height)

   self.speaker_name = I18N.get("god.elona.kumiromi.name")
   local speaker_name_win_width = math.max(Draw.text_width(self.speaker_name), 10) + self.text_padding * 2
   local speaker_name_win_height = Draw.text_height() + self.text_padding
   self.speaker_name_win:relayout(dialog_win_x,
                                  dialog_win_y - speaker_name_win_height,
                                  speaker_name_win_width,
                                  speaker_name_win_height)

   self.chip_batch = Draw.make_chip_batch("chip")
   self.portrait_batch = Draw.make_chip_batch("portrait")

   self.text = I18N.get("action.use.secret_experience.kumiromi.not_enough_exp")
   local _, wrapped = Draw.wrap_text(self.text, self.dialog_win.width - self.text_padding * 2)
   local to_chars = function(line)
      local x = 0
      local result = {}
      for _, char in utf8.chars(line) do
         result[#result+1] = {
            x = x,
            char = Draw.make_text(char)
         }
         x = x + Draw.text_width(char)
      end
      return result
   end

   self.wrapped = fun.iter(wrapped):map(Draw.make_text):to_list()
   self.wrapped_chars = fun.iter(wrapped):map(to_chars):to_list()
end

function DialogMenuEx:draw_actors()
   for _, actor in ipairs(self.actors) do
      if actor.is_active then
         Draw.set_color(255, 255, 255)
      else
         Draw.set_color(128, 128, 128)
      end

      local actor_y = self.y + (self.height - actor.height) - self.dialog_win.height
      actor.asset:draw(actor.current_x, actor_y, actor.width, actor.height)
   end
end

function DialogMenuEx:draw_text()
   if self.fully_displayed then
      for i, line in ipairs(self.wrapped) do
         local x = self.dialog_win.x + self.text_padding
         local y = self.dialog_win.y + self.text_padding * 0.9 + (i - 1) * 19
         Draw.text(line, x, y)
      end
      return
   end

   local function draw_partial_lines(r, g, b)
      local c = 0
      local alpha = 0
      for i, line in ipairs(self.wrapped_chars) do
         local y = self.dialog_win.y + self.text_padding * 0.9 + (i - 1) * 19
         for _, char in ipairs(line) do
            alpha = math.min(255 * self.char_appear_speed * (self.advance_dt) - c / self.dt_per_char * 10, 255)
            if alpha > 0 then
               Draw.set_color(r, g, b, alpha)
            end

            local x = self.dialog_win.x + self.text_padding + char.x
            Draw.text(char.char, x, y)
            c = c + 1
         end
      end
      if alpha == 255 then
         self.fully_displayed = true
      end
   end

   draw_partial_lines(40, 40, 40)
   draw_partial_lines(255, 255, 255)
end

function DialogMenuEx:draw()
   Draw.set_color(0, 0, 0, 64)
   Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height())
   Draw.set_color(255, 255, 255)
   Draw.line_rect(self.x, self.y, self.width, self.height)

   self:draw_actors()

   self.dialog_win:draw()

   Draw.set_font(self.font_size, nil, "normal")

   self:draw_text()

   self.speaker_name_win:draw()

   Draw.text(self.speaker_name,
             self.speaker_name_win.x + self.text_padding - 2,
             self.speaker_name_win.y + self.text_padding / 2 - 2)
end

function DialogMenuEx:update_actors(dt)
   for _, actor in ipairs(self.actors) do
      if actor.elapsed_time < actor.total_time then
         actor.elapsed_time = actor.elapsed_time + dt
         actor.current_x = Easing.out_quint(actor.elapsed_time, actor.begin_x, actor.dest_x - actor.begin_x, actor.total_time)
      end
   end
end

function DialogMenuEx:update(dt)
   self.advance_dt = self.advance_dt + dt

   self:update_actors(dt)

   self.dialog_win:update(dt)
   self.speaker_name_win:update(dt)
   self.pages:update(dt)

   local canceled = self.canceled
   local chosen = self.pages.chosen
   self.canceled = false
   self.pages.chosen = nil -- TODO #130

   if chosen then
      Gui.play_sound("base.more1")
      return self.pages.selected, self.pages:selected_item()
   end

   -- if self.default_choice and self.canceled then
   if canceled then
      Gui.play_sound("base.more1")
      return self.default_choice, "canceled"
   end
end

function DialogMenuEx:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
   if self.portrait_batch then
      self.portrait_batch:release()
   end
end

return DialogMenuEx
