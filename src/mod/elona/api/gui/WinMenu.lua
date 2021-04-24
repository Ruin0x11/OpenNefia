local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local UiWindow = require("api.gui.UiWindow")
local Ui = require("api.Ui")
local World = require("api.World")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")
local Gui = require("api.Gui")

local WinMenu = class.class("WinMenu", IUiLayer)

WinMenu:delegate("input", IInput)

function WinMenu:init(chara, win_comment)
   self.chara = chara
   self.win_comment = win_comment or "???"

   -- >>>>>>>> shade2/main.hsp:1442 	s= lang(""+cnAka(pc)+cnName(pc)+"に祝福あれ！あなたは遂にレシマス ...
   self.caption = CharaMakeCaption:new(I18N.get("win.you_acquired_codex", chara:calc("title"), chara:calc("name")))
   -- <<<<<<<< shade2/main.hsp:1443 	gosub *screen_drawMsg2 ..

   -- >>>>>>>> shade2/main.hsp:1445 	s=lang("*勝利*","*Win*"),""+strHint3 ...
   self.window = UiWindow:new("win.window.title", true, "key help")
   -- <<<<<<<< shade2/main.hsp:1447 	display_window 60,70,680,488 ..

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function WinMenu:on_query()
   Gui.fade_in()
end

function WinMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function WinMenu:relayout(x, y, width, height)
   -- >>>>>>>> shade2/main.hsp:1447 	display_window 60,70,680,488 ...
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   local win_x = 60
   local win_y = 70
   local win_width = 680
   local win_height = 488
   self.window:relayout(win_x, win_y, win_width, win_height)

   self.caption:relayout(self.x + 20, self.y + 30)

   self.t = UiTheme.load(self)
   -- <<<<<<<< shade2/main.hsp:1447 	display_window 60,70,680,488 ..
end

local function count_chars(base, pattern)
    return select(2, string.gsub(base, pattern, ""))
end

function WinMenu:draw()
   -- >>>>>>>> shade2/main.hsp:1448 	cmBG=0:x=wW/3-20:y=wH-140:gmode 4,180,300,250:pos ...
   self.t.base.void:draw(self.x, self.y, self.width, self.height)
   if Draw.has_active_global_draw_callbacks(true) then
      return
   end

   self.caption:draw()

   self.window:draw()
   self.t.base.g1:draw(
      self.window.x + self.window.width - 120,
      self.window.y + self.window.height / 2,
      self.window.width / 3 - 20,
      self.window.height - 140,
      {255, 255, 255, 250},
      true)

   Ui.draw_topic("win.window.caption", self.window.x + 28, self.window.y + 40)
   Draw.set_color(self.t.base.text_color)
   Draw.set_font(14)

   local th = Draw.text_height()
   local x = self.window.x + 40
   local y = self.window.y + 76
   local function mes(k, ...)
      local nl = 1
      if k then
         local s = I18N.get(k, ...)
         Draw.text(s, x, y)
         nl = count_chars(s, "\n") + 1
      end
      y = y + th * (nl)
   end

   local initial_date = save.base.initial_date
   local date = save.base.date
   mes("win.window.arrived_at_tyris", initial_date.year, initial_date.day, initial_date.month)
   mes()
   mes("win.window.have_killed", save.base.deepest_level, save.base.total_killed)
   mes("win.window.score", World.calc_score())
   mes()
   mes("win.window.lesimas", date.year, date.day, date.month)
   mes("win.window.comment", self.win_comment)
   mes()
   mes("win.window.your_journey_continues")
   -- <<<<<<<< shade2/main.hsp:1461 	redraw 1:key_list=key_enter:keyRange=0 ..
end

function WinMenu:update(dt)
   local canceled = self.canceled

   self.canceled = nil
   self.window:update(dt)
   self.caption:update(dt)

   if canceled then
      return nil, "canceled"
   end
end

return WinMenu
