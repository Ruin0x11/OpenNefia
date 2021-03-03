local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local TopicWindow = require("api.gui.TopicWindow")
local UiShadowedText = require("api.gui.UiShadowedText")
local save = require("internal.global.save")
local data = require("internal.data")
local Log = require("api.Log")

local UiAutoTurn = class.class("UiAutoTurn", IUiWidget)

function UiAutoTurn:init()
   self.text = UiShadowedText:new("AUTO TURN", 13)
   self.callback = nil
   self.dt = 0
   self.shown = false
   self.auto_turn_anim = nil
   self.first_anim_frame = false

   -- >>>>>>>> shade2/screen.hsp:388 	window2 sx,sy,w,h,0,5  ...
   self.win = TopicWindow:new(0, 5)
   -- <<<<<<<< shade2/screen.hsp:388 	window2 sx,sy,w,h,0,5  ..
   -- >>>>>>>> shade2/screen.hsp:396 		window2 sx,sy-104,148,101,0,5  ...
   self.anim_win = TopicWindow:new(0, 5)
   -- <<<<<<<< shade2/screen.hsp:396 		window2 sx,sy-104,148,101,0,5  ..
end

function UiAutoTurn:set_data(callback)
   self.callback = nil
end

function UiAutoTurn:default_widget_position(x, y, width, height)
   -- >>>>>>>> shade2/screen.hsp:387 	sx=windowW-156 : sy=inf_ver-30 : w=148 : h=25	 ...
   return width - 156, height - 72 - 16 - 30, 148, 25
   -- <<<<<<<< shade2/screen.hsp:387 	sx=windowW-156 : sy=inf_ver-30 : w=148 : h=25	 ..
end

function UiAutoTurn:default_widget_refresh(player)
end

function UiAutoTurn:default_widget_z_order()
   return 100000
end

function UiAutoTurn:set_shown(shown, auto_turn_anim_id)
   self.shown = shown
   self.dt = 0
   self.first_anim_frame = true

   if shown and auto_turn_anim_id then
      local ata = data["base.auto_turn_anim"][auto_turn_anim_id]
      if ata then
         self.auto_turn_anim = ata
      else
         Log.error("Invalid auto turn animation '%s'", auto_turn_anim_id)
         self.auto_turn_anim = nil
      end
   else
      self.auto_turn_anim = nil
   end
end

function UiAutoTurn:pass_turn()
   self.dt = self.dt - 1
end

function UiAutoTurn:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   -- >>>>>>>> shade2/screen.hsp:391 	pos sx+43,sy+6::color 0,0,0:bmes "AUTO TURN",235, ...
   self.text.color = self.t.base.text_color_auto_turn
   self.text:relayout(self.x + 43, self.y + 6)
   self.win:relayout(self.x, self.y, self.width, self.height)
   -- <<<<<<<< shade2/screen.hsp:392 	pos sx+18,sy+12:gmode 2,24,24:grotate selInf,72,3 ..

   -- >>>>>>>> shade2/screen.hsp:396 		window2 sx,sy-104,148,101,0,5  ...
   self.anim_win:relayout(self.x, self.y - 104, 148, 101)
   -- <<<<<<<< shade2/screen.hsp:396 		window2 sx,sy-104,148,101,0,5  ..
end

function UiAutoTurn:draw()
   if self.shown == false then
      return
   end

   -- >>>>>>>> shade2/screen.hsp:390 	fontSize 13,01 ...
   self.win:draw()
   self.text:draw()

   Draw.set_color(255, 255, 255)
   local rotation = math.floor(save.base.date.minute / 4) % 2 * 90
   self.t.base.auto_turn_icon:draw(self.x + 18, self.y + 12, nil, nil, nil, true, rotation)

   if self.auto_turn_anim then
      self.anim_win:draw()
      local x = self.x + 2
      local y = self.y - 102
      Draw.set_color(255, 255, 255)
      self.auto_turn_anim.draw(x, y, self.t)
   end
   -- <<<<<<<< shade2/screen.hsp:423 		} ..
end

function UiAutoTurn:update(dt)
   if self.shown == false then
      return
   end

   if self.first_anim_frame then
      self.first_anim_frame = false
      if self.auto_turn_anim and self.auto_turn_anim.on_start_callback then
         self.auto_turn_anim.on_start_callback()
      end
   end

   if self.dt <= 0 then
      self.dt = 15
      local x = self.x + 2
      local y = self.y - 102

      if self.auto_turn_anim then
         -- We need to render this above the HUD layer or `self.anim_win` will be
         -- covering it. The global draw callbacks get drawn last, so that will
         -- have to do.
         Draw.add_global_draw_callback(self.auto_turn_anim.callback(x, y, self.t))
         Draw.wait_global_draw_callbacks()
      end
   end
end

return UiAutoTurn
