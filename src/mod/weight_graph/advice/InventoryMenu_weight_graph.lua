local InventoryWeightGraph = require("mod.weight_graph.api.gui.InventoryWeightGraph")
local Advice = require("api.Advice")
local Extend = require("api.Extend")
local I18N = require("api.I18N")

local InventoryMenu_weight_graph = {}

InventoryMenu_weight_graph.after = {}
InventoryMenu_weight_graph.before = {}

function InventoryMenu_weight_graph.after:init(...)
   local ext = Extend.get_or_create(self, "weight_graph")

   ext.weight_graph = InventoryWeightGraph:new(config.weight_graph.position)
   ext.enabled = false
end

function InventoryMenu_weight_graph.after:relayout(...)
   local x = self.x
   local y = self.y
   local w = self.width

   local ext = Extend.get_or_create(self, "weight_graph")
   local weight_graph = ext.weight_graph
   weight_graph.position = config.weight_graph.position

   if weight_graph.position == "left" then
      weight_graph:relayout(x - 40, y, 24, 416)
   else
      weight_graph:relayout(x + w + 14, y, 24, 416)
   end
end

-- TODO data edits, data_ext
local ADDITIVE_PROTOS = table.set {
   "elona.inv_get",
   "elona.inv_take_container",
   "elona.inv_buy",
   "elona.inv_trade",
}

local function get_proto_kind(ctxt)
   if ADDITIVE_PROTOS[ctxt.proto._id] then
      return "add"
   else
      return "subtract"
   end
end

function InventoryMenu_weight_graph.after:draw(...)
   local ext = Extend.get(self, "weight_graph")
   if config.weight_graph.enabled and ext.enabled then
      ext.weight_graph:draw()
   end
end

function InventoryMenu_weight_graph.before:update(dt, ...)
   if not self.pages.changed or self.pages.chosen then
      return
   end

   local ext = Extend.get(self, "weight_graph")

   local item = self:selected_item_object()
   local item_weight = item and (item:calc("weight") * item.amount) or 0

   local current_weight = self.ctxt.chara and self.ctxt.chara:calc("inventory_weight")
   local max_weight = self.ctxt.chara and self.ctxt.chara:calc("max_inventory_weight")
   local proto_kind = get_proto_kind(self.ctxt)

   if proto_kind == nil or current_weight == nil or max_weight == nil then
      ext.enabled = false
   else
      local burden = max_weight * 2
      local display = math.max(burden, current_weight)

      ext.enabled = true
      ext.weight_graph:set_weight(display, current_weight, item_weight, proto_kind)

      ext.weight_graph:set_markers {
         { weight = max_weight * 2, text = I18N.get("effect.indicator.burden._4") },
         { weight = max_weight, text = I18N.get("effect.indicator.burden._3") },
         { weight = max_weight / 4 * 3, text = I18N.get("effect.indicator.burden._2") },
         { weight = max_weight / 2, text = I18N.get("effect.indicator.burden._1") },
      }
   end

      print(current_weight, max_weight, proto_kind, ext.enabled)

   if config.weight_graph.enabled and ext.enabled then
      ext.weight_graph:update(dt)
   end
end

for where, t in pairs(InventoryMenu_weight_graph) do
   for fn_name, fn in pairs(t) do
      Advice.add(where, "api.gui.menu.InventoryMenu", fn_name, ("Weight Graph: %s()"):format(fn_name), fn)
   end
end
