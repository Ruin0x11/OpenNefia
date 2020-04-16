local Mx = require("mod.tools.api.Mx")

local PicViewer = require("mod.tools.api.PicViewer")
local function cands()
   local keys = table.keys(data["base.theme"]["elona_sys.default"].assets)
   return Mx.completing_read(keys)
end
Mx.make_interactive("pic_viewer_start", PicViewer, "start", {cands})


local Input = require("api.Input")
Mx.make_interactive("input_reload_keybinds", Input, "reload_keybinds")


local Tools = require("mod.tools.api.Tools")
Mx.make_interactive("goto_down_stairs", Tools, "goto_down_stairs")
Mx.make_interactive("goto_up_stairs", Tools, "goto_up_stairs")
Mx.make_interactive("goto_map", Tools, "goto_map",
                    {
                       { type="elona_sys.map_template" }
                    })


local Chara = require("api.Chara")
local chara_create = function(id, x, y, amount)
   local map = Chara.player():current_map()
   for i=1, amount or 1 do
      Chara.create(id, x, y, {}, map)
   end
end
Mx.make_interactive("chara_create", chara_create,
                    {
                       { type="base.chara" },
                       function() return Chara.player().x end,
                       function() return Chara.player().y end,
                       function(arg)
                          if arg then
                             return Mx.read_type("number", { max=100, initial_amount=5 })
                          end
                       end
                    }
)


local Item = require("api.Item")
Mx.make_interactive("item_create", Item, "create",
                    {
                       { type="base.item" },
                       function() return Chara.player().x end,
                       function() return Chara.player().y end,
                       function()
                          return {
                             amount = Mx.read_type("number", { max=1000, initial_amount=1 })
                          }
                       end
                    })

local Watcher = require("mod.tools.api.Watcher")
local Map = require("api.Map")
Mx.make_interactive("start_watching", Watcher, "start_watching_object",
                       function()
                          local get_name = function(obj)
                             return ("%d (%s) [%s]"):format(obj.uid, obj.name or obj._id, obj._type)
                          end
                          local objects = Map.current():iter()
                          local object, canceled = Mx.read_type("choice", {candidates=objects, get_name=get_name})
                          if canceled then
                             return nil, canceled
                          end

                          return {
                             ("%d (%s)"):format(object.uid, object.name or object._id),
                             object,
                             config["tools.default_watches"]
                          }
                       end)

Mx.make_interactive("stop_watching", Watcher, "stop_watching_object",
                    {
                       function()
                          local conv = function(name, watch)
                             return name
                          end
                          local cands = fun.iter(Watcher.get_widget().watches):map(conv)

                          return Mx.read_type("choice", {candidates=cands})
                       end
                    })

Mx.make_interactive("start_watching_index", Watcher, "start_watching_index",
                    {
                       function()
                          local widget = Watcher.get_widget()
                          local conv = function(name, watch)
                             return name
                          end
                          local cands = fun.iter(widget.watches):map(conv)

                          return Mx.read_type("choice", {candidates=cands})
                       end,
                       { type = "string" }
                    })

Mx.make_interactive("stop_watching_index", Watcher, "stop_watching_index",
                    function()
                       local widget = Watcher.get_widget()
                       local conv = function(name, watch)
                          return name
                       end
                       local cands = fun.iter(widget.watches):map(conv)

                       local name, canceled = Mx.read_type("choice", {candidates=cands})
                       if canceled then
                          return nil, canceled
                       end

                       cands = widget.watches[name].indices
                       local index, canceled = Mx.read_type("choice", {candidates=cands})
                       if canceled then
                          return nil, canceled
                       end

                       return {name, index}
                    end)

Mx.make_interactive("watcher_clear", Watcher, "clear")

Mx.make_interactive("restart_scenario", Tools, "restart_scenario")

Mx.make_interactive("chara_sheet", Tools, "chara_sheet")

--
-- Keybinds
--

local Gui = require("api.Gui")
Gui.bind_keys {
   ["tools.m_x"] = function()
      Mx.start()
   end,
   ["tools.prefix_m_x"] = function()
      Mx.start(true)
   end,
}
