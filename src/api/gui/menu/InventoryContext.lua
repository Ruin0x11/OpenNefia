local Gui = require("api.Gui")
local Input = require("api.Input")
local Log = require("api.Log")
local InputHandler = require("api.gui.InputHandler")
local Ui = require("api.Ui")
local ILocation = require("api.ILocation")
local Map = require("api.Map")
local Event = require("api.Event")

--- The underlying behavior of an inventory screen. Separating it like
--- this allows trivial creation of item shortcuts, since all that is
--- needed is creating the context and running its methods without
--- needing to open any windows.
local InventoryContext = class.class("InventoryContext")

local function source_chara(ctxt)
   return ctxt.chara:iter_inventory()
end

local function source_target(ctxt)
   return ctxt.target:iter_inventory()
end

local function source_ground(ctxt)
   local Item = require("api.Item")

   local ground_x = ctxt.ground_x or (ctxt.chara and ctxt.chara.x)
   local ground_y = ctxt.ground_y or (ctxt.chara and ctxt.chara.y)

   if type(ground_x) ~= "number" or type(ground_y) ~= "number" then
      Log.warn("Inventory ground position was invalid: %s,%s", tostring(ground_x), tostring(ground_y))
      return fun.iter({})
   end

   local map = ctxt.map or Map.current()
   return Item.at(ground_x, ground_y, map)
end

local function source_equipment(ctxt)
   return ctxt.chara:iter_equipment()
end

local function source_shop(ctxt)
   class.assert_is_an(ILocation, ctxt.shop)
   return ctxt.shop:iter()
end

local function source_container(ctxt)
   class.assert_is_an(ILocation, ctxt.container)
   return ctxt.container:iter()
end

local sources = {
   {
      name = "chara",
      getter = source_chara,
      order = 10000,
      params = {
         chara = "IChara"
      }
   },
   {
      name = "target",
      getter = source_target,
      order = 11000,
      params = {
         target = "IChara"
      }
   },
   {
      name = "ground",
      getter = source_ground,
      order = 9000,
      on_get_name = function(self, name, item, menu)
         return name .. " (Ground)"
      end,
      params = {
         ground_x = { type = "number", optional = true },
         ground_y = { type = "number", optional = true },
         chara    = { type = "IChara", optional = true },
      }
   },
   {
      name = "equipment",
      getter = source_equipment,
      order = 8000,
      on_get_name = function(self, name, item, menu)
         return name .. " (main hand)"
      end,
      on_draw = function(self, x, y, item, menu)
         menu.t.base.equipped_icon:draw(x - 12, y + 14)
      end,
      params = {
         chara = "IChara"
      }
   },
   {
      name = "shop",
      getter = source_shop,
      order = 7000,
      on_get_name = function(self, name, item, menu)
         return name .. " " .. Ui.display_weight(item:calc("weight"))
      end,
      on_get_subtext = function(self, subtext, item, menu)
         return tostring(item:calc("value")) .. " gp"
      end,
      params = {
         shop = "table"
      }
   },
   {
      -- TODO: maybe it would be better to have an IInventory interface so
      -- either IChara or Inventory can be passed transparently. However there
      -- are some assumptions made about position being available if a character
      -- is being used, but Inventory doesn't necessarily have position.
      name = "container",
      getter = source_container,
      order = 7000,
      params = {
         container = "table"
      }
   },
}

sources = fun.iter(sources):map(function(s) return s.name, s end):to_map()

local function gen_default_sort(user_sort)
   return function(a, b)
      if a.source == b.source then
         return user_sort(a, b)
      end

      return a.source.order < b.source.order
   end
end

function InventoryContext:init(proto, params)
   self.proto = proto
   self.input = InputHandler:new()

   self.sources = {}
   for _, source_name in ipairs(self.proto.sources) do
      local source = sources[source_name]
      if source == nil then
         error("unknown source " .. source_name)
      end
      self.sources[#self.sources+1] = source
   end

   self.query_amount = self.proto.query_amount
   self.show_money = self.proto.show_money
   self.shortcuts = self.proto.shortcuts
   self.stack = {}

   -- Valid parameters to pass in the `params` table.
   self.chara = params.chara or nil
   self.target = params.target or nil
   self.container = params.container or nil
   self.map = params.map or nil
   self.shop = params.shop or nil
   self.params = params.params or nil

   self.icon = (self.proto.icon or 0) + 1

   if self.proto.keybinds then
      self.input:bind_keys(self.proto.keybinds)
   end

   if self.proto.params then
      for name, required_type in pairs(self.proto.params) do
         local val = params[name]

         local ok = type(val) == required_type

         if not ok then
            ok = type(val) == "table"
               and val.is_a
               and val:is_a(required_type)
         end

         if not ok then
            error(string.format("Inventory context expects parameter %s (%s) to be passed.", name, required_type))
         end

         if self[name] ~= nil then
            error(string.format("Inventory context parameter has a name conflict: %s", name))
         end

         -- TODO move to ctxt.params
         self[name] = val
      end
   end
end

function InventoryContext:additional_keybinds()
   return {}
end

function InventoryContext:can_select(item)
   if self.proto.can_select then
      return self.proto.can_select(self, item)
   end

   return true
end

local function default_sort(a, b)
   return a.item._id > b.item._id
end

function InventoryContext:gen_sort(a, b)
   local f = default_sort

   if self.proto.sort then
      f = function(a, b) return self.proto.sort(self, a, b) end
   end

   return gen_default_sort(f)
end

function InventoryContext:on_shortcut(item)
   if self.proto.on_shortcut then
      return self.proto.on_shortcut(self, item)
   end

   return true
end

function InventoryContext:filter(item)
   local result = true

   if self.proto.filter then
      result = self.proto.filter(self, item)
   end

   result = Event.trigger("base.on_inventory_context_filter", {context=self, item=item}, result)

   return result
end

function InventoryContext:after_filter(filtered)
   if self.proto.after_filter then
      return self.proto.after_filter(self, filtered)
   end

   return nil
end

function InventoryContext:query_item_amount(item)
   local amount = item.amount
   local can_query = false

   if self.chara and self.chara:is_player() then
      can_query = true
   end

   if amount > 1 and self.query_amount and can_query then
      local canceled

      Gui.mes("How many? ")
      amount, canceled = Input.query_number(item.amount)
      if canceled then
         return nil, canceled
      end
   end

   return amount
end

function InventoryContext:on_select(item, amount, rest)
   -- assert(type(amount) == "number")
   amount = amount or item.amount

   if self.proto.on_select then
      return self.proto.on_select(self, item, amount, rest)
   end

   return "inventory_continue"
end

function InventoryContext:on_menu_enter()
   if self.proto.on_menu_enter then
      self.proto.on_menu_enter(self)
   end
end

function InventoryContext:on_menu_exit()
   if self.proto.on_menu_exit then
      return self.proto.on_menu_exit(self)
   end

   return "player_turn_query"
end

return InventoryContext
