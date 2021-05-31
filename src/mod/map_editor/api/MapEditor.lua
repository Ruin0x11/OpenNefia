local Gui = require("api.Gui")
local Log = require("api.Log")
local Draw = require("api.Draw")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Input = require("api.Input")
local SaveFs = require("api.SaveFs")
local Fs = require("api.Fs")
local MapSerial = require("mod.tools.api.MapSerial")
local CodeGenerator = require("api.CodeGenerator")
local Codegen = require("api.Codegen")

local MapRenderer = require("api.gui.MapRenderer")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")
local MapEditorTileWidget = require("mod.map_editor.api.MapEditorTileWidget")
local MapEditTileList = require("mod.elona.api.gui.MapEditTileList")
local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local UiMouseManager = require("mod.mouse_ui.api.gui.UiMouseManager")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")

local MapEditorNewPanel = require("mod.map_editor.api.panel.MapEditorNewPanel")

local MapEditor = class.class("MapEditor", IUiLayer)

MapEditor:delegate("input", IInput)

function MapEditor:init(maps)
   self.update_cursor = true

   self.mouse_menu = UiMouseMenu:new {
      children = {
         UiMouseButton:new { text = "Pick tile...", callback = function() self:pick_from_tile_list() end },
         UiMouseButton:new { text = "Test1", callback = function() Log.info("Dood") end },
         UiMouseButton:new { text = "Test2", callback = function() Log.warn("Dood") end },
         UiMouseButton:new { text = "Test3", callback = function() Log.error("Dood") end },
         UiMouseButton:new { text = "Test4", callback = function() Log.debug("Dood") end },
      }
   }
   self.menu_x = 0
   self.menu_y = 0
   self.menu_shown = false
   self:show_mouse_menu(false)

   self.opened_maps = {}

   self.current_map = nil
   self.renderer = MapRenderer:new()
   self.renderer_offset_x = 0
   self.renderer_offset_y = 0
   self.renderer_offset_delta = 50

   self.target_tile_x = 0
   self.target_tile_y = 0
   self.tile_width = 0
   self.tile_height = 0
   self.selected_tile = "elona.grass"
   self.placing_tile = false
   self.selected_wall = false
   self.tile_widget = MapEditorTileWidget:new(self.selected_tile)
   self.panning = false
   self.pan_x = 0
   self.pan_y = 0

   self.toolbar = UiMouseMenu:new {
      display_direction = "horizontal",
      child_width = 96,
      child_height = 32,
      children = {
         UiMouseMenuButton:new { text = "File", id = "menu_file", display_direction = "vertical", menu =
              UiMouseMenu:new {
                  children = {
                     UiMouseButton:new { text = "New...", callback = function() self:act_new() end },
                     UiMouseButton:new { text = "Open...", callback = function() self:act_open() end },
                     UiMouseButton:new { text = "Save", callback = function() self:act_save() end },
                     UiMouseButton:new { text = "Save As...", callback = function() self:act_save_as() end },
                     UiMouseButton:new { text = "Rename...", callback = function() self:act_rename() end },
                     UiMouseButton:new { text = "Close", callback = function() self:act_close() end },
                     UiMouseButton:new { text = "Quit", callback = function() self:act_quit() end },
                  }
              }
         },
         UiMouseMenuButton:new { text = "Switch", id = "menu_switch", display_direction = "vertical" },
         UiMouseMenuButton:new { text = "Plugin", id = "menu_plugin", display_direction = "vertical" },
      }
   }

   self.plugins = {}
   for _, proto in data["map_editor.plugin"]:iter() do
      local klass = proto.impl
      local plugin = klass:new()
      plugin:on_install(self)
      self.plugins[#self.plugins+1] = plugin
   end

   self.mouse_manager = UiMouseManager:new {
      self.toolbar,
      self.mouse_menu
   }

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:bind_mouse(self:make_mousemap())
   self.input:bind_mouse_elements(self:get_mouse_elements(true))
   self.input:forward_to(self.mouse_manager)

   if maps then
      if class.is_an(InstancedMap, maps) then
         maps = {maps}
      end
      for _, map in ipairs(maps) do
         assert(class.is_an(InstancedMap, map))
         self:add_map(map)
      end
      if self.opened_maps[1] then
         self:switch_to_map(1)
      end
   end
end

function MapEditor:make_keymap()
   local keymap = {
      cancel = function() self:cancel() end,
      escape = function() self:quit() end,

      north = function() self:pan(0, -self.renderer_offset_delta) end,
      south = function() self:pan(0, self.renderer_offset_delta) end,
      east = function() self:pan(self.renderer_offset_delta, 0) end,
      west = function() self:pan(-self.renderer_offset_delta, 0) end,

      ["map_editor.new"] = function() self:act_new() end,
      ["map_editor.open"] = function() self:act_open() end,
      ["map_editor.save"] = function() self:act_save() end,
      ["map_editor.save_as"] = function() self:act_save_as() end,
      ["map_editor.rename"] = function() self:act_rename() end,
      ["map_editor.close"] = function() self:act_close() end,
      ["map_editor.quit"] = function() self:act_quit() end,
   }

   for i = 1, 10 do
      keymap[("map_editor.switch_map_%d"):format(i)] = function() self:switch_to_map(i) end
   end

   return keymap
end

function MapEditor:default_z_order()
   return 100000000 - 10
end

function MapEditor:update_draw_pos()
   self.renderer:set_draw_pos(self.renderer_offset_x, self.renderer_offset_y)
   if self.current_map and self.width then
      local tx, ty = Gui.screen_to_tile(-self.renderer_offset_x + math.floor(self.width / 2), -self.renderer_offset_y + math.floor(self.height / 2))
      self.current_map.map:calc_screen_sight(tx, ty, "all")
   end
end

function MapEditor:pan(dx, dy)
   self.renderer_offset_x = self.renderer_offset_x + dx
   self.renderer_offset_y = self.renderer_offset_y + dy
   self:update_draw_pos()
end

function MapEditor:show_mouse_menu(show)
   self.menu_shown = show
   for _, element in self.mouse_menu:iter_mouse_elements(true) do
      element:set_enabled(show)
      if show then
         element:set_pressed(false)
      end
   end
end

function MapEditor:make_mousemap()
   return {
      element = function(element, pressed)
         if not pressed then
            if class.is_an(UiMouseButton, element) then
               self:show_mouse_menu(false)
            end
         end
         -- Pass `element` event to child UiMouseManager to unpress other
         -- buttons
         return true
      end,
      button_1 = function(x, y, pressed)
         self.placing_tile = pressed
      end,
      button_2 = function(x, y, pressed)
         if pressed then
            if self.input:is_modifier_held("ctrl") then
               local tx, ty = Draw.get_coords():screen_to_tile(x - self.renderer_offset_x, y - self.renderer_offset_y)
               self:copy_tile_at(tx, ty)
            elseif self.input:is_modifier_held("shift") then
               local tx, ty = Draw.get_coords():screen_to_tile(x - self.renderer_offset_x, y - self.renderer_offset_y)
               self:flood_fill(tx, ty, self.selected_tile)
            else
               if self.menu_shown then
                  self:show_mouse_menu(false)
               else
                  self.menu_x = x
                  self.menu_y = y
                  self.mouse_menu:relayout(x, y, 96, 48 * 4)
                  self:show_mouse_menu(true)
               end
            end
         end
      end,
      button_3 = function(x, y, pressed)
         if pressed then
            self.pan_x = x
            self.pan_y = y
         end
         self.panning = pressed
      end
   }
end

function MapEditor:get_mouse_elements(recursive)
   return self.mouse_manager:get_mouse_elements(recursive)
end

function MapEditor.get_save_dir()
   return "mod/tools/maps"
end

function MapEditor:on_query()
   Gui.play_sound("base.pop2")
end

function MapEditor:cancel()
   if self.menu_shown then
      self:show_mouse_menu(false)
      return false
   end
   return true
end

function MapEditor:quit()
   if self:cancel() then
      if Input.yes_no() then
         self.quitting = true
      end
   end
end

function MapEditor:switch_to_map(index)
   local opened_map = self.opened_maps[index]
   if opened_map == nil then
      return
   end

   local prev_map = self.current_map
   if prev_map then
      prev_map.offset_x = self.renderer_offset_x
      prev_map.offset_y = self.renderer_offset_y
   end

   self.current_map = opened_map

   local map = opened_map.map
   map:iter_tiles():each(function(x, y) map:memorize_tile(x, y) end)
   map:redraw_all_tiles()

   self.renderer:set_map(map)
   self.renderer_offset_x = opened_map.offset_x
   self.renderer_offset_y = opened_map.offset_y
   self:update_draw_pos()
end

function MapEditor:_refresh_switcher()
   local map = function(i, map)
      return UiMouseButton:new {
         text = ("(%d) %s"):format(i, map.map.name),
         callback = function() self:switch_to_map(i) end
      }
   end

   local buttons = fun.iter(self.opened_maps):enumerate():map(map):to_list()
   local menu = UiMouseMenu:new { children = buttons }
   self.toolbar.children[2]:set_menu(menu)
   self.input:bind_mouse_elements(menu:get_mouse_elements(true))

   if self.x then
      self:relayout()
   end
end

function MapEditor:current_map_index()
   return table.index_of(self.opened_maps, self.current_map)
end

function MapEditor:select_tile(id)
   self.selected_tile = id
   self.tile_widget:set_tile(id)

   local tile_data = data["base.map_tile"]:ensure(self.selected_tile)
   self.placing_wall = tile_data.is_solid
end

function MapEditor:place_tile(tx, ty, tile_id)
   self.mouse_manager:unpress_mouse_elements()
   self:show_mouse_menu(false)

   local map = self.current_map.map

   if map:tile(tx, ty)._id == tile_id then
      return
   end

   if self.placing_wall then
      Gui.play_sound("base.offer1", tx, ty)
   end
   map:set_tile(tx, ty, tile_id)

   map:reveal_tile(tx, ty)

   -- Reveal everything surrounding also, to make sure wall tiles don't bug out.
   for _, x, y in Pos.iter_surrounding(tx, ty) do
      if map:is_in_bounds(x, y) then
         map:reveal_tile(x, y)
      end
   end

   self:update_draw_pos()
end

function MapEditor:pick_from_tile_list()
   local sort = function(a, b)
      if (a.elona_atlas or -1) == (b.elona_atlas or -1) then
         return (a.elona_id or -1) < (b.elona_id or -1)
      end
      return (a.elona_atlas or -1) < (b.elona_atlas or -1)
   end
   local all_tiles = data["base.map_tile"]:iter():into_sorted(sort):extract("_id"):to_list()

   self.update_cursor = false
   local tile_id, canceled = MapEditTileList:new(all_tiles):query(self:default_z_order() + 1)
   self.update_cursor = true

   if tile_id and not canceled then
      self:select_tile(tile_id)
   end
end

function MapEditor:copy_tile_at(tx, ty)
   if not self.current_map then
      return
   end
   if not self.current_map.map:is_in_bounds(tx, ty) then
      return
   end

   local tile_id = self.current_map.map:tile(tx, ty)._id
   Gui.play_sound("base.ok1")
   self:select_tile(tile_id)
end

function MapEditor:flood_fill(tx, ty, tile_id)
   if not self.current_map then
      return
   end
   if not self.current_map.map:is_in_bounds(tx, ty) then
      return
   end

   local target_tile = self.current_map.map:tile(tx, ty)._id
   if target_tile == tile_id then
      return
   end

   local function flood(x, y, map)
      if not map:is_in_bounds(x, y) then return end
      local other_tile = map:tile(x, y)._id
      if other_tile == target_tile then
         map:set_tile(x, y, tile_id)
         flood(x + 1, y, map)
         flood(x - 1, y, map)
         flood(x, y + 1, map)
         flood(x, y - 1, map)
      end
   end

   if self.placing_wall then
      Gui.play_sound("base.offer1", tx, ty)
   end
   flood(tx, ty, self.current_map.map)

   self:update_draw_pos()
end

function MapEditor:add_map(map)
   local tw, th = Draw.get_coords():get_size()
   local offset_x = Draw.get_width() / 2 - (tw * map:width()) / 2
   local offset_y = Draw.get_height() / 2 - (th * map:height()) / 2

   local opened_map = {
      map = map,
      modified = false,
      offset_x = offset_x,
      offset_y = offset_y
   }

   table.insert(self.opened_maps, opened_map)
   self:_refresh_switcher()

   return #self.opened_maps
end

function MapEditor:get_opened_map(i)
   return self.opened_maps[i]
end

function MapEditor:get_current_map()
   return self.current_map
end

function MapEditor.serial_to_editor(onmap)
   local map = MapSerial.build_geometry(onmap)

   return {
      map = map,
      modified = false,
      offset_x = 0,
      offset_y = 0
   }
end

function MapEditor.editor_to_serial(opened_map)
   local width = opened_map.map:width()
   local height = opened_map.map:height()

   local tiles = {}
   local tileset = {}
   local tile_index = 0
   local seen = table.set {}

   for _, x, y, tile in opened_map.map:iter_tiles() do
      local index = seen[tile._id]
      if index == nil then
         tile_index = tile_index + 1
         seen[tile._id] = tile_index
         tileset[tile_index] = tile._id
         index = tile_index
      end
      tiles[#tiles+1] = index
   end

   return {
      width = width,
      height = height,
      tiles = tiles,
      tileset = tileset
   }
end

--
-- Editor Actions
--

function MapEditor:create_new_map(width, height)
   local map = InstancedMap:new(width, height)
   map:clear("elona.grass")
   return map
end

function MapEditor:act_new()
   local size, canceled = MapEditorNewPanel:new():query()
   if canceled then
      return
   end

   local map = self:create_new_map(size.width, size.height)
   local index = self:add_map(map)
   self:switch_to_map(index)
end

function MapEditor:act_open()
   local dir = MapEditor.get_save_dir()
   local real_dir = SaveFs.save_path(dir, "global")
   local files = Fs.iter_directory_items(real_dir, "full_path"):to_list()
   local filepath, canceled = FuzzyFinderPrompt:new(files):query()
   if canceled then
      return
   end

   local code, err = Fs.read_all(filepath, "global")
   if not code then
      error(err)
   end

   local chunk, err = Codegen.loadstring(code)
   if err then
      error(err)
   end

   local raw = chunk()
   assert(type(raw) == "table" and type(raw.tiles) == "table")

   local opened_map = MapEditor.serial_to_editor(raw)
   opened_map.filepath = filepath

   table.insert(self.opened_maps, opened_map)
   self:_refresh_switcher()
   self:switch_to_map(#self.opened_maps)
end

function MapEditor:act_save()
   if self.current_map == nil then
      return
   end

   if self.current_map.filepath == nil then
      return self:act_save_as()
   end

   local raw = MapEditor.editor_to_serial(self.current_map)
   local str = "return " .. CodeGenerator.inspect(raw)
   assert(SaveFs.write_raw(self.current_map.filepath, str, "global"))
end

function MapEditor:act_save_as()
   local filename, canceled = Input.query_text(255, true, false)
   if canceled then
      return
   end

   filename = Fs.sanitize(filename)

   local dir = MapEditor.get_save_dir()
   local filepath = Fs.join(dir, ("%s.lua"):format(filename))

   if SaveFs.exists(filepath, "global") then
      if not Input.yes_no() then
         return
      end
   end

   self.current_map.filepath = filepath

   self:act_save()
end

function MapEditor:act_rename()
   if self.current_map == nil then
      return
   end

   local name, canceled = Input.query_text(64, true, false)
   if name == "" or canceled then
      return
   end

   self.current_map.map.name = name
   self:_refresh_switcher()
end

function MapEditor:act_close()
   if self.current_map == nil then
      return
   end
   local index = self:current_map_index()

   table.remove(self.opened_maps, index)
   self:_refresh_switcher()

   if #self.opened_maps > 0 then
      self:switch_to_map(math.clamp(index, 1, #self.opened_maps))
   else
      self.renderer:set_map(nil)
      self.current_map = nil
   end

   collectgarbage()
end

function MapEditor:act_quit()
   self:quit()
end

--
-- UI Layer Draw/Update
--

function MapEditor:relayout(x, y, width, height)
   self.x = x or self.x
   self.y = y or self.y
   self.width = width or self.width
   self.height = height or self.height
   self.t = UiTheme.load(self)

   self.tile_width, self.tile_height = Draw.get_coords():get_size()

   self.renderer:relayout(self.x, self.y, self.width, self.height)
   self:update_draw_pos()
   self.tile_widget:relayout(self.width - 80, self.y + 20, 80, 80)

   self.mouse_menu:relayout(self.menu_x, self.menu_y, 96, 48 * 4)
   self.toolbar:relayout(0, 0, Draw.get_width(), 48)
end

function MapEditor:draw()
   Draw.clear(0, 0, 0, 255)

   local x = self.x + self.renderer_offset_x
   local y = self.y + self.renderer_offset_y

   local width = math.floor(self.width)
   local height = math.floor(self.height)

   self.renderer:relayout_inner(x, y, width, height)

   Draw.set_color(255, 255, 255)
   self.renderer:draw()

   local tx, ty = Gui.tile_to_screen(self.target_tile_x, self.target_tile_y)
   Draw.set_blend_mode("add")
   Draw.filled_rect(tx + self.renderer_offset_x, ty + self.renderer_offset_y, self.tile_width, self.tile_height, {127, 127, 255, 50})
   Draw.set_blend_mode("alpha")

   Draw.set_color(255, 255, 255)
   self.tile_widget:draw()

   Draw.set_font(14)
   Draw.text_shadowed(("(%d, %d)"):format(self.target_tile_x, self.target_tile_y), self.x + 5, self.y + self.height - 5 - Draw.text_height())

   if self.current_map then
      local info = ("Map: %s (%d x %d)"):format(self.current_map.map.name, self.current_map.map:width(), self.current_map.map:height())
      Draw.text_shadowed(info, self.x + self.width / 2 - Draw.text_width(info) / 2, self.y + 50 - Draw.text_height() / 2)
   end

   if self.menu_shown then
      self.mouse_menu:draw()
   end
   self.toolbar:draw()
end

function MapEditor:update(dt)
   local canceled = self.canceled
   local quitting = self.quitting

   self.canceled = false
   self.quitting = false

   if quitting then
      return nil, "canceled"
   end

   self.renderer:update(dt)
   self.tile_widget:update(dt)

   if self.menu_shown then
      self.mouse_menu:update(dt)
   end
   self.toolbar:update(dt)

   if self.update_cursor then
      local mouse_x, mouse_y = Input.mouse_pos()
      self.target_tile_x, self.target_tile_y = Draw.get_coords():screen_to_tile(mouse_x - self.renderer_offset_x, mouse_y - self.renderer_offset_y)
   end

   if self.current_map and self.placing_tile and self.current_map.map:is_in_bounds(self.target_tile_x, self.target_tile_y) then
      self:place_tile(self.target_tile_x, self.target_tile_y, self.selected_tile)
   end

   if self.panning then
      local mouse_x, mouse_y = Input.mouse_pos()
      self:pan(mouse_x - self.pan_x, mouse_y - self.pan_y)
      self.pan_x = mouse_x
      self.pan_y = mouse_y
   end
end

return MapEditor
