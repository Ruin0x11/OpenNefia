require("mod.elona.init.god")

require("mod.elona.data")

require("mod.elona.events.init")

local Gui = require("api.Gui")
local ElonaCommand = require("mod.elona.api.ElonaCommand")

data:add_multi(
   "base.config_option",
   {
      { _id = "hide_shop_results", type = "enum", choices = {"none", "could_not_sell", "all"}, default = "none" },
      { _id = "hide_autoidentify", type = "enum", choices = {"none", "quality", "all"}, default = "none" },
      { _id = "skip_fishing_animation", type = "boolean", default = false },
      { _id = "item_shortcuts_respect_curse_state", type = "boolean", default = false },

      { _id = "debug_living_weapon", type = "boolean", default = false },
      { _id = "debug_always_drop_figure_card", type = "boolean", default = false },
      { _id = "debug_always_drop_remains", type = "boolean", default = false },
      { _id = "debug_production_versatile_tool", type = "boolean", default = false },
      { _id = "debug_fishing", type = "boolean", default = false },
      { _id = "debug_no_encounters", type = "boolean", default = false },
   }
)

Gui.register_draw_layer("cloud", "mod.elona.api.gui.CloudLayer", { enabled = false })

Gui.bind_keys {
   quick_inv = function(_, me)
      return ElonaCommand.quick_inv(me)
   end,
   inventory = function(_, me)
      return ElonaCommand.inventory(me)
   end,
   bash = function(_, me)
      return ElonaCommand.bash(me)
   end,
   eat = function(_, me)
      return ElonaCommand.eat(me)
   end,
   fire = function(_, me)
      return ElonaCommand.fire(me)
   end,
   dig = function(_, me)
      return ElonaCommand.dig(me)
   end,
   read = function(_, me)
      return ElonaCommand.read(me)
   end,
   drink = function(_, me)
      return ElonaCommand.drink(me)
   end,
   zap = function(_, me)
      return ElonaCommand.zap(me)
   end,
   use = function(_, me)
      return ElonaCommand.use(me)
   end,
   dip = function(_, me)
      return ElonaCommand.dip(me)
   end,
   throw = function(_, me)
      return ElonaCommand.throw(me)
   end,
   rest = function(_, me)
      return ElonaCommand.rest(me)
   end,
   ammo = function(_, me)
      return ElonaCommand.ammo(me)
   end,
   open = function(_, me)
      return ElonaCommand.open(me)
   end,
   enter = function(_, me)
      return ElonaCommand.enter_action(me)
   end,
   go_down = function(_, me)
      return ElonaCommand.descend(me)
   end,
   go_up = function(_, me)
      return ElonaCommand.ascend(me)
   end,
}

local function to_shortcut_key(i)
   i = i - 1
   local action = ("shortcut_%d"):format(i)
   local fn = function(_, me)
      return ElonaCommand.shortcut(me, i)
   end
   return action, fn
end
local shortcut_keys = fun.range(40):map(to_shortcut_key):to_map()
Gui.bind_keys(shortcut_keys)
