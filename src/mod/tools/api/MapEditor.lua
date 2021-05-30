local Ui = require("api.Ui")
local Gui = require("api.Gui")
local Log = require("api.Log")
local Draw = require("api.Draw")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Input = require("api.Input")
local SaveFs = require("api.SaveFs")
local Fs = require("api.Fs")
local MapSerial = require("mod.tools.api.MapSerial")

local MapRenderer = require("api.gui.MapRenderer")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")
local UiMouseButton = require("api.gui.UiMouseButton")
local MapEditorTileWidget = require("mod.tools.api.MapEditorTileWidget")
local MapEditTileList = require("mod.elona.api.gui.MapEditTileList")
local UiMouseMenu = require("api.gui.UiMouseMenu")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")

local MapEditor = class.class("MapEditor", IUiLayer)

MapEditor:delegate("input", IInput)

function MapEditor:init(maps)
   self.update_cursor = true

   local menu = {
      { text = "Pick tile...", cb = function() self:pick_from_tile_list() end },
      { text = "Test1", cb = function() Log.info("Dood") end },
      { text = "Test2", cb = function() Log.warn("Dood") end },
      { text = "Test3", cb = function() Log.error("Dood") end },
      { text = "Test4", cb = function() Log.debug("Dood") end },
   }

   self.mouse_menu = Ui.make_mouse_menu(menu)
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
   self.tile_widget = MapEditorTileWidget:new(self.selected_tile)
   self.panning = false
   self.pan_x = 0
   self.pan_y = 0

   self.toolbar = Ui.make_toolbar {
      { text = "File", id = "menu_file", menu =
          {
              { text = "New...", cb = function() self:act_new() end },
              { text = "Open...", cb = function() self:act_open() end },
              { text = "Save", cb = function() self:act_save() end },
              { text = "Save As...", cb = function() self:act_save_as() end },
              { text = "Rename...", cb = function() self:act_rename() end },
              { text = "Close", cb = function() self:act_close() end },
              { text = "Quit", cb = function() self:act_quit() end },
          }
      },
      { text = "Switch", id = "menu_switch", menu = {} },
      { text = "Plugin", id = "menu_plugin", menu = {} },
   }

   self.plugins = {}
   for _, proto in data["tools.map_editor_plugin"]:iter() do
      local klass = proto.impl
      local plugin = klass:new()
      plugin:on_install(self)
      self.plugins[#self.plugins+1] = plugin
   end

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:bind_mouse(self:make_mousemap())
   self.input:bind_mouse_elements(self:get_mouse_elements(true))

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
      repl_copy = function() self:pick_from_tile_list() end,

      ["tools.map_editor_new"] = function() self:act_new() end,
      ["tools.map_editor_open"] = function() self:act_open() end,
      ["tools.map_editor_save"] = function() self:act_save() end,
      ["tools.map_editor_save_as"] = function() self:act_save_as() end,
      ["tools.map_editor_rename"] = function() self:act_rename() end,
      ["tools.map_editor_close"] = function() self:act_close() end,
      ["tools.map_editor_quit"] = function() self:act_quit() end,
   }

   for i = 1, 9 do
      keymap[("tools.map_editor_switch_map_%d"):format(i)] = function() self:switch_to_map(i) end
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

function MapEditor:unpress_mouse_elements()
   for _, other in self:iter_mouse_elements(true) do
      other:set_pressed(false)
   end
   self:show_mouse_menu(false)
end

function MapEditor:unpress_unfocused_mouse_elements(element)
   local p = table.set {}
   while element do
      p[element] = true
      element = element:get_parent()
   end
   for _, other in self:iter_mouse_elements(true) do
      if not p[other] then
         other:set_pressed(false)
      end
   end
end

function MapEditor:make_mousemap()
   return {
      element = function(element, pressed)
         if pressed then
            self:unpress_unfocused_mouse_elements(element)
         else
            if class.is_an(UiMouseButton, element) then
               self:unpress_mouse_elements(element)
            end
         end
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
   return table.append(self.mouse_menu:get_mouse_elements(true), self.toolbar:get_mouse_elements(true))
end

function MapEditor.get_save_dir()
   return "mod/tools/maps"
end

function MapEditor:on_query()
   Gui.play_sound("base.pop2")

   if #self.opened_maps == 0 then
      self:act_new(20, 20)
   end
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
      self.quitting = true
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
      return UiMouseButton:new(
         ("(%d) %s"):format(i, map.map.name),
         function() self:switch_to_map(i) end
      )
   end

   local buttons = fun.iter(self.opened_maps):enumerate():map(map):to_list()
   local menu = UiMouseMenu:new(buttons)
   self.toolbar.buttons[2]:set_menu(menu)
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
end

function MapEditor:place_tile(tx, ty, tile_id)
   self:unpress_mouse_elements()

   local map = self.current_map.map

   if map:tile(tx, ty)._id == tile_id then
      return
   end

   local tile_data = data["base.map_tile"]:ensure(tile_id)
   if tile_data.is_solid then
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

   local tile_data = data["base.map_tile"]:ensure(tile_id)
   if tile_data.is_solid then
      Gui.play_sound("base.offer1", tx, ty)
   end
   flood(tx, ty, self.current_map.map)

   self:update_draw_pos()
end

function MapEditor:add_map(map)
   local opened_map = {
      map = map,
      modified = false,
      offset_x = 0,
      offset_y = 0
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

--
-- Editor Actions
--

function MapEditor:create_new_map(width, height)
   local map = InstancedMap:new(width, height)
   map:clear("elona.grass")
   return map
end

function MapEditor:act_new(width, height)
   if not width then
      local canceled
      width, canceled = Input.query_number(1000, 20)
      if canceled then
         return
      end
      height, canceled = Input.query_number(1000, 20)
      if canceled then
         return
      end
   end


   local map = self:create_new_map(width, height)
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

   local raw, err = Fs.read_all(filepath, "global")
   if not raw then
      error(err)
   end

   raw = SaveFs.deserialize(raw)
   local opened_map = MapSerial.serial_to_editor(raw)
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

   local raw = MapSerial.editor_to_serial(self.current_map)
   assert(SaveFs.write(self.current_map.filepath, raw, "global"))
end

function MapEditor:act_save_as()
   local filename, canceled = Input.query_text(255, true, false)
   if canceled then
      return
   end

   filename = Fs.sanitize(filename)

   local dir = MapEditor.get_save_dir()
   local filepath = Fs.join(dir, ("%s.onmap"):format(filename))
   self.current_map.filepath = filepath

   local raw = MapSerial.editor_to_serial(self.current_map)
   assert(SaveFs.write(self.current_map.filepath, raw, "global"))
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

   if self.menu_shown then
      self.mouse_menu:draw()
   end
   self.toolbar:draw()

   Draw.set_font(14)
   Draw.text_shadowed(("(%d, %d)"):format(self.target_tile_x, self.target_tile_y), self.x + 5, self.y + self.height - 5 - Draw.text_height())

   if self.current_map then
      local info = ("Map: %s (%d x %d)"):format(self.current_map.map.name, self.current_map.map:width(), self.current_map.map:height())
      Draw.text_shadowed(info, self.x + self.width / 2 - Draw.text_width(info) / 2, self.y + 50 - Draw.text_height() / 2)
   end
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
