local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Ui = require("api.Ui")
local Skill = require("mod.elona_sys.api.Skill")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiWindow = require("api.gui.UiWindow")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local RollAttributesMenu = class.class("RollAttributesMenu", ICharaMakeSection)

RollAttributesMenu:delegate("input", IInput)

local UiListExt = function(roll_attributes_menu)
   local E = {}

   function E:get_item_text(item)
      return item.text
   end
   function E:on_choose(item)
      if item.on_choose then
         self.chosen = false
         item.on_choose()
      end
   end
   function E:draw_item(item, i, x, y, key_name)
      UiList.draw_item(self, item, i, x, y, key_name)
      if item.value then
         roll_attributes_menu:draw_attribute(item, i, x, y)
      end
   end

   return E
end

local ATTRIBUTES = {
   "elona.stat_strength",
   "elona.stat_constitution",
   "elona.stat_dexterity",
   "elona.stat_perception",
   "elona.stat_learning",
   "elona.stat_will",
   "elona.stat_magic",
   "elona.stat_charisma",
}

function RollAttributesMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 360
   self.height = 352

   self.locks_left = 2
   self.locks = {}
   self.finished = false

   local texts = fun.iter(ATTRIBUTES)
      :map(function(id)
            return {
               id = id,
               text = I18N.get("ability." .. id .. ".name")
            }
          end)
      :to_list()
   self.data = {
      {
         text = I18N.get("chara_make.common.reroll"),
         on_choose = function() self:reroll(true) end
      },
      {
         text = I18N.get("chara_make.roll_attributes.proceed")
      },
   }
   local function lock(attr)
      return function()
         self:lock(attr.id)
      end
   end
   for _, v in ipairs(texts) do
      self.data[#self.data + 1] = { id = v.id, text = v.text, on_choose = lock(v), locked = false, value = {} }
   end

   self.alist = UiList:new(self.data, 23)
   table.merge(self.alist, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.alist)
   self.input:bind_keys(self:make_keymap())

   self.win = UiWindow:new("chara_make.roll_attributes.title")

   self.caption = "chara_make.roll_attributes.caption"
   self.intro_sound = "base.skill"

   self:reroll()
end

function RollAttributesMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      mode2 = function() self:reroll(true, true) end
   }
end

function RollAttributesMenu:on_query()
   self.alist.chosen = false
end

local function calc_rolled_attributes(race_id, class_id)
   local temp = Chara.create("base.player", nil, nil, {no_build = true, ownerless = true})
   temp.level = 0

   Skill.apply_race_params(temp, race_id)
   Skill.apply_class_params(temp, class_id)

   return temp.skills
end

function RollAttributesMenu:reroll(play_sound, minimum)
   local race = self.charamake_data.chara.race
   local class = self.charamake_data.chara.class

   local skills = calc_rolled_attributes(race, class)
   for _, v in ipairs(self.data) do
      if v.value and not v.locked then
         local skill = skills["base.skill:" .. v.id]
         if skill then
            if minimum then
               skill.level = skill.level - math.floor(skill.level / 2)
            else
               skill.level = skill.level - Rand.rnd(skill.level / 2 + 1)
            end
            v.value = skill
         end
      end
   end

   if play_sound then
      Gui.play_sound("base.dice")
   end
end

function RollAttributesMenu:lock(attr)
   local a = fun.iter(self.data):filter(function(i) return i.id == attr end):nth(1)
   if not a or a.locked == nil then return end
   if a.locked == true then
      a.locked = false
      self.locks_left = self.locks_left + 1
   else
      if self.locks_left == 0 then return end
      a.locked = true
      self.locks_left = self.locks_left - 1
   end

   Gui.play_sound("base.ok1")
end

function RollAttributesMenu:draw_attribute(item, i, x, y)
   Draw.set_font(15, "bold")

   local quad = Ui.skill_icon(item.id)
   if quad then
      self.t.base.skill_icons:draw_region(quad, x + 160, y + 10, nil, nil, {255, 255, 255}, true)
   end

   Draw.text(tostring(item.value.level), x + 172, y, {0, 0, 0})

   if item.locked == true then
      Draw.set_font(12, "bold") -- 12 - en * 2
      Draw.text("Locked!", x + 202, y + 2, {20, 20, 140})
   end
end

function RollAttributesMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 20
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.alist:relayout(self.x + 38, self.y + 66)
end

function RollAttributesMenu:draw()
   self.win:draw()
   self.t.base.g1:draw(self.x + 85, self.y + self.height / 2, 150, 240, {255, 255, 255, 30}, true)

   Draw.set_color(255, 255, 255)
   Ui.draw_topic("chara_make.roll_attributes.attributes", self.x + 28, self.y + 30)

   Draw.set_color(0, 0, 0)
   Draw.set_font(12) -- 12 + sizefix - en * 2
   Draw.text(I18N.get("chara_make.roll_attributes.locked_items_desc"), self.x + 175, self.y + 52)
   Draw.set_font(13, "bold") -- 13 - en * 2
   Draw.text(I18N.get("chara_make.roll_attributes.locks_left") .. ": " .. self.locks_left, self.x + 180, self.y + 84)

   self.alist:draw()
end

function RollAttributesMenu:get_charamake_result(charamake_data, retval)
   local chara = charamake_data.chara
   for skill_id, skill in pairs(retval) do
      chara:set_base_skill(skill_id, skill.level, skill.potential, 0)
   end
   return charamake_data
end

function RollAttributesMenu:update()
   if self.alist.chosen then
      local result = {}
      for _, v in ipairs(self.data) do
         if v.value then
            result[v.id] = v.value
         end
      end

      return result
   end

   self.win:update()
   self.alist:update()

   if self.canceled then
      return nil, "canceled"
   end
end

return RollAttributesMenu
