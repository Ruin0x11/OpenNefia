local Map = require("api.Map")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Input = require("api.Input")
local MapEdit = require("mod.elona.api.MapEdit")

local MapEditTileList = require("mod.elona.api.gui.MapEditTileList")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local MapEditLayer = class.class("MapEditLayer", IUiLayer)

MapEditLayer:delegate("input", IInput)

function MapEditLayer:init()
  self.finished = false

  local player = Chara.player()
  self.save_x = player.x
  self.save_y = player.y

  self.target_x = 0
  self.target_y = 0
  self.selected_tile = "elona.grass"
  self.placing = false

  self.input = InputHandler:new()
  self.input:bind_keys(self:make_keymap())
  self.input:bind_mouse(self:make_mousemap())
  self.input:halt_input()
end

local function move_player(dir)
  local player = Chara.player()
  local x, y = Pos.add_direction(dir, player.x, player.y)
  if Map.is_in_bounds(x, y) then
    player:set_pos(x, y, true)
  end
  Gui.update_screen()
end

function MapEditLayer:make_keymap()
  return {
    enter = function() self:pick_from_tile_list() end,
    escape = function() self.finished = true end,
    cancel = function() self.finished = true end,
    north = function()
      move_player("North")
    end,
    south = function()
      move_player("South")
    end,
    east = function()
      move_player("East")
    end,
    west = function()
      move_player("West")
    end,
    northwest = function()
      move_player("Northwest")
    end,
    northeast = function()
      move_player("Northeast")
    end,
    southwest = function()
      move_player("Southwest")
    end,
    southeast = function()
      move_player("Southeast")
    end,
  }
end

function MapEditLayer:make_mousemap()
  return {
    button_1 = function(x, y, pressed)
      self.placing = pressed
    end,
    button_2 = function(x, y, pressed)
      if pressed then
        local tx, ty = Gui.visible_screen_to_tile(x, y)
        if Map.is_in_bounds(tx, ty) then
          self:copy_tile_at(tx, ty)
        end
      end
    end
  }
end

function MapEditLayer:copy_tile_at(tx, ty)
  local tile_id = Map.tile(tx, ty)._id
  if MapEdit.is_tile_selectable(tile_id) then
    Gui.play_sound("base.cursor1")
    self:select_tile(tile_id)
  else
    Gui.play_sound("base.fail1")
  end
end

function MapEditLayer:pick_from_tile_list()
  local tile_id, canceled = MapEditTileList:new():query()
  if tile_id and not canceled then
    self:select_tile(tile_id)
  end
end

function MapEditLayer:select_tile(id)
  self.selected_tile = id

  self.tile_batch:clear()
  --TODO
  local width = 48
  local height = 48
  self.tile_batch:add(self.selected_tile, self.width - 80, self.x + 20, width, height)
end

function MapEditLayer:show_tiles()
end

function MapEditLayer:on_query()
  assert(Gui.field_is_active(), "Can only start in-game")
  assert(not Map.is_world_map(), "Can't start in world map")
end

function MapEditLayer:relayout(x, y, width, height)
  self.x = 0
  self.y = 0
  self.width = Draw.get_width()
  self.height = Draw.get_height()
  self.t = UiTheme.load(self)
  self.tile_width, self.tile_height = Draw.get_coords():get_size()
  self.tile_batch = Draw.make_chip_batch("tile")
  self:select_tile(self.selected_tile)
end

function MapEditLayer:draw()
  local x, y = Gui.tile_to_visible_screen(self.target_x, self.target_y)
  Draw.set_blend_mode("add")
  Draw.filled_rect(x, y, self.tile_width, self.tile_height, {127, 127, 255, 50})
  Draw.set_blend_mode("alpha")
  Draw.set_color(255, 255, 255)
  self.tile_batch:draw()
end

local function place_tile(map, tx, ty, tile_id)
  if map:tile(tx, ty)._id == tile_id then
    return
  end

  local tile_data = data["base.map_tile"]:ensure(tile_id)
  if tile_data.is_solid then
    Gui.play_sound("base.offer1")
  end
  map:set_tile(tx, ty, tile_id)
  map:reveal_tile(tx, ty)
  Gui.update_screen()
end

function MapEditLayer:update(dt)
  if self.finished then
    local player = Chara.player()
    player:set_pos(self.save_x, self.save_y)
    return true
  end

  local mouse_x, mouse_y = Input.mouse_pos()
  local sx, sy = Gui.field_draw_pos()
  self.target_x, self.target_y = Gui.screen_to_tile(mouse_x + sx, mouse_y + sy)
  local map = Map.current()

  if self.placing and map:is_in_bounds(self.target_x, self.target_y) then
    place_tile(map, self.target_x, self.target_y, self.selected_tile)
  end
end

return MapEditLayer
