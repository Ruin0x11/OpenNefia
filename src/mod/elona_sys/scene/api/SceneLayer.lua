local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Log = require("api.Log")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local DialogMenu = require("mod.elona_sys.dialog.api.DialogMenu")
local MorePrompt = require("api.gui.MorePrompt")

local SceneLayer = class.class("SceneLayer", IUiLayer)

SceneLayer:delegate("input", IInput)

function SceneLayer:init(scene)
  self.scene = assert(scene)
  self.index = 0
  self.lines = {}
  self.bg = nil
  self.wait = 0
  self.more_prompt = MorePrompt:new()
  self.first = true

  self.actors = {}

  self.finished = false
  self.proceeded = false

  self.input = InputHandler:new()
  self.input:bind_keys(self:make_keymap())
  self.input:halt_input()

  self:proceed()
end

function SceneLayer:make_keymap()
  return {
    enter = function()
      if self.wait > 0 then
        return
      end
      self.more_prompt:run_keybind_action("enter")
    end,
    escape = function()
      if self.wait > 0 then
        return
      end
      self.finished = true
    end
  }
end

function SceneLayer:current_node()
  return self.scene[self.index]
end

local function fade_between()
   local canvas = Draw.copy_to_canvas()

   local anim = function()
     Draw.image(canvas, 0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255})
     local frame = 1
     while frame < 30 do
       local _, _, frames_passed = Draw.yield(30)
       Draw.image(canvas, 0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255, ((30-frame) * 16)})
       frame = frame + frames_passed
     end
   end

   Draw.add_global_draw_callback(anim)
   Draw.wait_global_draw_callbacks()
end

local function fade_in()
   local anim = function()
     Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {0, 0, 0})
     local frame = 1
     while frame < 50 do
       local _, _, frames_passed = Draw.yield(10)
       Draw.set_blend_mode("subtract")
       Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height(), {255, 255, 255, ((50-frame) * 15)})
       Draw.set_blend_mode("alpha")
       frame = frame + frames_passed
     end
   end

   Draw.add_global_draw_callback(anim)
   Draw.wait_global_draw_callbacks()
end

function SceneLayer:proceed()
  local finished = false

  while not finished do
    self.index = self.index + 1
    local t = self.scene[self.index]

    if self.index > #self.scene then
      finished = true
      self.finished = true
    else
      local id = t[1]
      if id == "txt" then
        self.lines = string.split(t[2])
        finished = true
      elseif id == "pic" then
        self.bg = t[2]
      elseif id == "chat" then
        finished = true
      elseif id == "actor" then
        self.actors[t[2]] = { name = I18N.get_optional(t.name) or t.name, portrait = t.portrait, chip = t.chip }
      elseif id == "se" then
        Gui.play_sound(t[2])
      elseif id == "mc" then
        Gui.play_music(t[2])
      elseif id == "wait" then
        self.wait = 1.0
        finished = true
      elseif id == "fade" then
        if self.index ~= #self.scene then
          -- TODO
          Gui.fade_out()
        end
      elseif id == "fadein" then
        fade_in()
      end

      if id ~= "txt" and id ~= "fade" then
        self.lines = {}
      end
    end
  end

  self.proceeded = true
end

function SceneLayer:relayout(x, y, width, height)
  self.x = 0
  self.y = 0
  self.width = Draw.get_width()
  self.height = Draw.get_height()
  self.font_size = 16
  self.t = UiTheme.load(self)
  self.more_prompt:relayout(self.width - 120, self.height - 60)
end

function SceneLayer:draw()
  Draw.set_font(self.font_size)

  local y1 = 60
  local y2 = self.height - 60

  Draw.set_color(0, 0, 0)
  Draw.filled_rect(0, 0, self.width, self.height)
  if self.bg then
    Draw.set_color(255, 255, 255)
    self.t[self.bg]:draw(0, y1, self.width, y2-y1)
  end

  Draw.set_color(255, 255, 255)

  -- draw shadows
  for i, line in ipairs(self.lines) do
    local y = y1 + 31 + (9 - #self.lines / 2 + (i - 1)) * 20
    local width = 80 + Draw.text_width(line)
    if width < 180 then
      width = 0
    end
    Draw.set_blend_mode("subtract")
    self.t.base.scene_text_shadow:draw(self.width / 2, y + 4, width, nil, {255, 255, 255, 70}, true)
    Draw.set_blend_mode("alpha")
  end

  -- draw text
  for i, line in ipairs(self.lines) do
    local y = y1 + 28 + (9 - #self.lines / 2 + (i - 1)) * 20
    local x = self.width / 2 - Draw.text_width(line) / 2
    Draw.text_shadowed(line, x, y, {240, 240, 240}, {10, 10, 10})
  end

  local t = self:current_node()
  if t and t[1] == "txt" then
    self.more_prompt:draw()
  end
end

function SceneLayer:update(dt)
  if self.wait > 0 then
    self.wait = self.wait - dt
    if self.wait < 0 then
      self.wait = 0
      self:proceed()
    else
      return false
    end
  end

  if self.more_prompt:update(dt) then
    self:proceed()
    self.more_prompt:init()
  end

  if self.proceeded then
    local t = self:current_node()
    while t and t[1] == "chat" do
      if t[1] == "chat" then
        local actor_id = t[2]
        local txt = t[3]

        local actor = self.actors[actor_id]
        if actor == nil then
          error(("Actor '%d' was not declared in the scene."):format(actor_id))
        end
        local m = DialogMenu:new(txt, {}, actor.name, actor.portrait, actor.chip, 1)
        m:relayout(0, 0, self.width, self.height)
        if self.first then
          fade_between()
          self.first = false
        end
        local _, canceled = m:query()
        if canceled == "canceled" then
          self.finished = true
          break
        else
          self:proceed()
          t = self:current_node()
        end
      end
    end
    if t and t[1] == "txt" and not self.finished then
      fade_between()
    end
    self.proceeded = false
  end

  self.first = false

  if self.finished then
    Gui.fade_out()
    return true
  end
end

return SceneLayer
