local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ChangeAppearanceMenu = require("api.gui.menu.ChangeAppearanceMenu")
local Chara = require("api.Chara")
local CharaMake = require("api.CharaMake")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local TopicWindow = require("api.gui.TopicWindow")
local UiBuffList = require("api.gui.menu.UiBuffList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local Env = require("api.Env")
local save = require("internal.global.save")

local CharacterSheetMenu = class.class("CharacterSheetMenu", IUiLayer)

CharacterSheetMenu:delegate("input", IInput)

function CharacterSheetMenu:init(behavior, chara)
   self.width = 700
   self.height = 400
   self.chara = chara

   if self.chara == nil and CharaMake.is_active() then
      self.chara = Chara.create("content.player", nil, nil, {ownerless = true})
   end

   self.portrait = self.chara:calc("portrait")
   self.chara_image = self.chara:calc("image")
   self.pcc = self.chara:calc("pcc")
   if self.pcc then
      self.pcc = table.deepcopy(self.pcc)
      self.pcc.dir = 1
      self.pcc.frame = 2
   end

   self.topic_win = TopicWindow:new(1, 10)

   self.buff_list = UiBuffList:new()

   self.texts = {}

   self.input = InputHandler:new()
   self.input:forward_to(self.buff_list)
   self.input:bind_keys(self:make_keymap())

   self.chip_batch = nil
   self.portrait_batch = nil

   self.caption = "chara_make.final_screen.caption"
end

function CharacterSheetMenu:make_keymap()
   return {
      portrait = function()
         ChangeAppearanceMenu:new():query()
      end,
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function CharacterSheetMenu:text_level()
   local level = 10
   local exp = 1000
   local required_exp = 1000
   local god_name = self.chara:calc("god") or "eyth"
   local guild_name = save.elona.guild or "none"

   self.texts["level"] =
      UiTextGroup:new({
         "ui.chara_sheet.exp.level",
         "ui.chara_sheet.exp.exp",
         "ui.chara_sheet.exp.next_level",
         "ui.chara_sheet.exp.god",
         "ui.chara_sheet.exp.guild"
      }, { size = 12, style = "bold"})
   self.texts["level"]:relayout(self.x + 355, self.y + 46)

   self.texts["level_val"] =
      UiTextGroup:new({
         tostring(level),
         tostring(exp),
         tostring(required_exp),
         I18N.get("god." .. god_name .. ".name"),
         I18N.get("guild." .. guild_name .. ".name")
      }, 14)
   self.texts["level_val"]:relayout(self.x + 410, self.y + 45)

end

function CharacterSheetMenu:text_name()
   local name = self.chara:calc("name")
   local title = self.chara:calc("title")
   local race = self.chara:calc("race")
   local gender = self.chara:calc("gender")
   local class = self.chara:calc("class")
   local age = self.chara:calc("age")
   local height = ("%d cm"):format(self.chara:calc("height"))
   local weight = ("%d kg"):format(self.chara:calc("weight"))

   self.texts["name"] =
      UiTextGroup:new({
         "ui.chara_sheet.personal.name",
         "ui.chara_sheet.personal.aka",
         "ui.chara_sheet.personal.race",
         "ui.chara_sheet.personal.sex",
         "ui.chara_sheet.personal.class",
         "ui.chara_sheet.personal.age",
         "ui.chara_sheet.personal.height",
         "ui.chara_sheet.personal.weight"
      }, { size = 12, style = "bold"},
         {20, 10, 0},
         4, 4)
   self.texts["name"]:relayout(self.x + 30, self.y + 61)
   self.texts["name_val"] =
      UiTextGroup:new({
         name,
         title,
         I18N.get("race." .. race .. ".name"),
         I18N.get("ui.sex3." .. gender),
         I18N.get("class." .. class .. ".name"),
         I18N.get("ui.chara_sheet.personal.age_counter", age),
         height,
         weight
      },
         14,
         {20, 10, 0},
         4, 4)

   self.texts["name_val"]:relayout(self.x + 68, -- + en * ((i > 3) * 12)
                                   self.y + 60)
end

local ATTRS = {
   "elona.stat_strength",
   "elona.stat_constitution",
   "elona.stat_dexterity",
   "elona.stat_perception",
   "elona.stat_learning",
   "elona.stat_will",
   "elona.stat_magic",
   "elona.stat_charisma",
}

function CharacterSheetMenu:text_attr()
   local attr = fun.iter(ATTRS):map(function(id) return "ability." .. id .. ".name" end):to_list()
   self.texts["attr"] = UiTextGroup:new(attr, 12)
   self.texts["attr"]:relayout(self.x + 54, self.y + 151)
end

local function conv_play_time(time)
   local hour = math.floor(time / 60 / 60)
   local minute = math.floor(time / 60) % 60
   local second = math.floor(time) % 60
   return I18N.get("ui.playtime", hour, minute, second)
end

function CharacterSheetMenu:text_time()
   local turns = save.base.play_turns
   local days = save.base.play_days
   local kills = 100
   local time = Env.get_play_time(save.base.play_time)

   self.texts["time"] =
      UiTextGroup:new({
         "ui.chara_sheet.time.turns",
         "ui.chara_sheet.time.days",
         "ui.chara_sheet.time.kills",
         "ui.chara_sheet.time.time"
      }, {size = 12, style = "bold"})
   self.texts["time"]:relayout(self.x + 32, self.y + 301)

   self.texts["time_val"] =
      UiTextGroup:new({
         I18N.get("ui.chara_sheet.time.turn_counter", turns),
         I18N.get("ui.chara_sheet.time.days_counter", days),
         tostring(kills),
         conv_play_time(time)
      }, 14)
   self.texts["time_val"]:relayout(self.x + 80, self.y + 299)

end

function CharacterSheetMenu:text_weight()
   local cargo_weight = self.chara:calc("cargo_weight")
   local cargo_limit = self.chara:calc("max_cargo_weight")
   local equip_weight = self.chara:calc("equipment_weight")
   local deepest_level = save.base.deepest_level

   self.texts["weight"] =
      UiTextGroup:new({
         "ui.chara_sheet.weight.cargo_weight",
         "ui.chara_sheet.weight.cargo_limit",
         "ui.chara_sheet.weight.equip_weight",
         "ui.chara_sheet.weight.deepest_level"
      }, {size = 12, style = "bold"})
   self.texts["weight"]:relayout(self.x + 224, self.y + 301)

   self.texts["weight_val"] =
      UiTextGroup:new({
         Ui.display_weight(cargo_weight),
         Ui.display_weight(cargo_limit),
         Ui.display_weight(equip_weight) .. " " .. Ui.display_armor_class(equip_weight),
         I18N.get("ui.chara_sheet.weight.level_counter", deepest_level)
      }, 14)
   self.texts["weight_val"]:relayout(self.x + 287, self.y + 299)
end

function CharacterSheetMenu:text_fame()
   local cur, base

   cur = self.chara:skill_level("elona.stat_life")
   base = self.chara:base_skill_level("elona.stat_life")
   local life = string.format("%d(%d)", cur, base)

   cur = self.chara:skill_level("elona.stat_mana")
   base = self.chara:base_skill_level("elona.stat_mana")
   local mana = string.format("%d(%d)", cur, base)

   local insanity = tostring(self.chara:calc("insanity"))

   cur = self.chara:skill_level("elona.stat_speed")
   base = self.chara:base_skill_level("elona.stat_speed")
   local speed = string.format("%d(%d)", cur, base)

   local fame = tostring(self.chara:calc("fame"))
   local karma = tostring(self.chara:calc("karma"))

   self.texts["fame"] =
      UiTextGroup:new({
         "ui.chara_sheet.attribute.life",
         "ui.chara_sheet.attribute.mana",
         "ui.chara_sheet.attribute.sanity",
         "ui.chara_sheet.attribute.speed",
         "",
         "ui.chara_sheet.attribute.fame",
         "ui.chara_sheet.attribute.karma"
      }, {size = 12, style = "bold"})
   self.texts["fame"]:relayout(self.x + 255, self.y + 151)

   self.texts["fame_val"] =
      UiTextGroup:new({
         life,
         mana,
         insanity,
         speed,
         "",
         fame,
         karma
      }, 14)
   self.texts["fame_val"]:relayout(self.x + 310, self.y + 151)
end

function CharacterSheetMenu:relayout(x, y)
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.x = self.x + x
   self.y = self.y + y
   self.t = UiTheme.load(self)

   self.topic_win:relayout(self.x + 557, self.y + 23, 87, 120)
   self.buff_list:relayout(self.x + 430, self.y + 151)

   self.chip_batch = Draw.make_chip_batch("chip")
   self.portrait_batch = Draw.make_chip_batch("portrait")

   self.texts = {}

   self:text_level()
   self:text_name()
   self:text_attr()
   self:text_time()
   self:text_weight()
   self:text_fame()
end

function CharacterSheetMenu:draw_text()
   self.texts["level"]:draw()
   self.texts["name"]:draw()

   local attr = self.texts["attr"]
   attr:draw()
   Draw.set_color(255, 255, 255)
   for i, t in ipairs(attr.texts) do
      self.t.skill_icons:draw_region(
                        i,
                        attr.x - 17,
                        attr.y + 6 + (i-1) * attr.item_height,
                        nil, nil,
                        {255, 255, 255},
                        true)
   end

   self.texts["time"]:draw()
   self.texts["weight"]:draw()
   self.texts["fame"]:draw()
end

function CharacterSheetMenu:potential_string(pot)
   if pot >= 200 then
      return "Superb"
   elseif pot >= 150 then
      return "Great"
   elseif pot >= 100 then
      return "Good"
   elseif pot >= 50 then
      return "Bad"
   end
   return "Hopeless"
end

function CharacterSheetMenu:draw_attribute_name(attr, x, y)
   local level = self.chara:skill_level(attr)
   local text = string.format("(%d)", level)
   local ench = false
   if ench then
      text = text .. "*"
   end
   Draw.text(tostring(self.chara:base_skill_level(attr)), x, y)
   Draw.text(text, x + 32, y)
end

function CharacterSheetMenu:draw_attribute_potential(attr, x, y)
   local pot = self:potential_string(self.chara:skill_potential(attr))
   Draw.text(pot, x, y)
end

function CharacterSheetMenu:draw_attributes()
   Draw.set_font(14)

   for i, attr in ipairs(ATTRS) do
      Draw.set_color(0, 0, 0)
      local x = self.x + 92
      local y = self.y + 152 + (i - 1) * 15
      self:draw_attribute_name(attr, x, y)
      self:draw_attribute_potential(attr, x + 84, y)
   end
end

local function format_damage_info(name, damage, hit)
   return {
      name = name,
      text = string.format("%dd%d x%.01f", damage.dice_x, damage.dice_y, damage.multiplier),
      subname = "ui.chara_sheet.damage.hit",
      subtext = string.format("%d%%", hit)
   }
end

local function calc_skill_damage(chara, weapon, attack_number)
   local Combat = require("mod.elona.api.Combat")

   local skill = weapon:calc("skill")
   local hit = Combat.calc_accuracy(chara, weapon, nil, skill, attack_number, false, false)
   local damage = Combat.calc_attack_raw_damage(chara, weapon, nil, skill, false, nil)
   local name = I18N.get("ui.chara_sheet.damage.melee") .. attack_number

   return format_damage_info(name, damage, hit)
end

local function calc_damage_info(chara)
   -- HACK: these are really bad dependencies.
   local Combat = require("mod.elona.api.Combat")
   local ElonaAction = require("mod.elona.api.ElonaAction")

   local info = {}

   local found = nil
   local attack_number = 0

   -- Melee
   for _, weapon in ElonaAction.get_melee_weapons(chara) do
      found = true
      attack_number = attack_number + 1
      info[#info+1] = calc_skill_damage(chara, weapon, attack_number)
   end

   -- Unarmed
   if found == nil then
      local skill = "elona.martial_arts"

      local hit = Combat.calc_accuracy(chara, nil, nil, skill, attack_number, false, false)
      local damage = Combat.calc_attack_raw_damage(chara, nil, nil, skill, false, nil)

      info[#info+1] = format_damage_info("ui.chara_sheet.damage.unarmed", damage, hit)
   end

   -- Ranged weapon
   local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
   if ranged then
      local skill = ranged:calc("skill")
      local hit = Combat.calc_accuracy(chara, ranged, nil, skill, 0, true, false)
      local damage = Combat.calc_attack_raw_damage(chara, ranged, nil, skill, true, ammo)

      info[#info+1] = format_damage_info("ui.chara_sheet.damage.dist", damage, hit)
   end

   -- Protection/Evade
   local prot = Combat.calc_protection(chara, nil, nil, "elona.martial_arts")
   local evade = Combat.calc_evasion(chara, nil, nil, "elona.martial_arts")
   info[#info+1] = {
      name = "ui.chara_sheet.damage.protect",
      text = string.format("%d%% + %dd%d", prot.amount, prot.dice_x, prot.dice_y),
      subname = "ui.chara_sheet.damage.evade",
      subtext = string.format("%d%%", evade)
   }

   return info
end

function CharacterSheetMenu:draw_weapon_info()
   local info = calc_damage_info(self.chara)

   local fullwidth = I18N.is_fullwidth()
   for i, entry in ipairs(info) do
      local size = 10
      if fullwidth then
         size = 12
      end
      Draw.set_font(size, "bold") -- + sizefix
      Draw.text(I18N.get_optional(entry.name) or entry.name,
                self.x + 417,
                self.y + 281 + (i-1) * 16
                )
      local offset_x = -16
      if fullwidth then
         offset_x = 0
      end
      Draw.text(I18N.get(entry.subname),
                self.x + 590 + offset_x,
                self.y + 281 + (i-1) * 16
                )
      Draw.set_font(14)
      offset_x = 8
      if fullwidth then
         offset_x = 0
      end
      Draw.text(entry.text,
                self.x + 460 + offset_x,
                self.y + 279 + (i-1) * 16
                )
      Draw.text(entry.subtext,
                self.x + 625 + offset_x,
                self.y + 279 + (i-1) * 16
                )
   end
end

function CharacterSheetMenu:draw_buffs()
   self.buff_list:draw()

   local buff_desc = self.buff_list:get_hint()

   Draw.set_font(13)
   Draw.text(buff_desc, self.x + 108, self.y + 366, {0, 0, 0})
   Draw.set_font(11, "bold") -- + sizefix * 2 - en * 2
   Draw.text(I18N.get("ui.chara_sheet.buff.hint"),
             self.x + 70,
             self.y + 369, -- - en * 3
             {0, 0, 0})
end

function CharacterSheetMenu:draw_values()
   Draw.set_font(14)

   self.texts["level_val"]:draw()
   self.texts["name_val"]:draw()
   self:draw_attributes()
   self.texts["fame_val"]:draw()
   self:draw_weapon_info()
   self.texts["time_val"]:draw()
   self.texts["weight_val"]:draw()
   self:draw_buffs()
end

function CharacterSheetMenu:draw()
   self.t.ie_sheet:draw(self.x, self.y, nil, nil, {255, 255, 255})

   Ui.draw_topic("ui.chara_sheet.attributes",       self.x + 28,  self.y + 122)
   Ui.draw_topic("ui.chara_sheet.combat_rolls",     self.x + 400, self.y + 253)
   Ui.draw_topic("ui.chara_sheet.history",          self.x + 28,  self.y + 273)
   Ui.draw_topic("ui.chara_sheet.blessing_and_hex", self.x + 400, self.y + 122)
   Ui.draw_topic("ui.chara_sheet.extra_info",       self.x + 220, self.y + 273)

   self.topic_win:draw()

   if self.portrait then
      self.portrait_batch:clear()
      self.portrait_batch:add(self.portrait, self.x + 560, self.y + 27, 80, 112)
      self.portrait_batch:draw()
   end

   if self.pcc then
      self.pcc:draw(self.x + 596, self.y + 86)
   elseif self.chara_image then
      self.chip_batch:clear()
      --TODO
      local width = 48
      local height = 48
      self.chip_batch:add(self.chara_image,
                           self.x + 596,
                           self.y + 86,
                           width,
                           height)
      self.chip_batch:draw()
   end

   self:draw_text()
   self:draw_values()
end

function CharacterSheetMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   self.topic_win:update()
   self.buff_list:update()

   local time = Env.get_play_time(save.base.play_time)
   self.texts["time_val"]:set_text(4, conv_play_time(time))
end

return CharacterSheetMenu
