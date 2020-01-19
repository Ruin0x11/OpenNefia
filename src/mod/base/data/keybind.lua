local Input = require("api.Input")
local Env = require("api.Env")

local function add_keybinds(raw)
   local kbs = {}
   for id, default in pairs(raw) do
      if type(default) == "table" then
         kbs[#kbs+1] = { _id = id, default = default[1], default_alternate = default[2] }
      else
         kbs[#kbs+1] = { _id = id, default = default }
      end
   end
   data:add_multi("base.keybind", kbs)
end

add_keybinds {
   --cancel = "shift",
   cancel = "lshift",
   escape = "escape",
   north = {"up", "kp8"},
   south = {"down", "kp2"},
   west = {"left", "kp4"},
   east = {"right", "kp6"},
   northwest = "kp7",
   northeast = "kp9",
   southwest = "kp1",
   southeast = "kp3",
   wait = {".", "kp5"},
   inventory = "i",
   help = "?",
   message_log = "/",
   page_up = "kp+",
   page_down = "kp-",
   get = "g",
   drop = "d",
   chara_info = "c",
   enter = "return",
   eat = "e",
   wear = "w",
   cast = "v",
   drink = "q",
   read = "r",
   zap = "Z",
   fire = "f",
   go_down = ">",
   go_up = "<",
   save = "S",
   search = "s",
   interact = "i",
   identify = "x",
   skill = "a",
   close = "C",
   rest = "R",
   target = "kp*",
   dig = "D",
   use = "t",
   bash = "b",
   open = "o",
   dip = "B",
   pray = "p",
   offer = "O",
   journal = "j",
   material = "m",
   quick = "z",
   trait = "F",
   look = "l",
   give = "G",
   throw = "T",
   mode = "z",
   mode2 = "kp*",
   ammo = "A",
   previous_page = "kp7",
   next_page = "kp9",
   quick_inv = "x",
   quicksave = "f2",
   quickload = "f3",

   repl = "`",
   repl_page_up = "pageup",
   repl_page_down = "pagedown",
   repl_first_char = "home",
   repl_last_char = "home",
   repl_paste = "ctrl_v",
   repl_cut = "ctrl_x",
   repl_copy = "ctrl_c",
   repl_complete = "tab",
}

if Env.is_hotloading() then
   local keybinds = {}
   for _, kb in data["base.keybind"]:iter() do
      local id = kb._id

      -- allow omitting "base." if the keybind is provided by the base
      -- mod.
      if string.match(id, "^base%.") then
         id = string.split(id, ".")[2]
      end

      keybinds[#keybinds+1] = {
         action = id,
         primary = kb.default,
         alternate = kb.default_alternate,
      }
   end
   config["base.keybinds"] = keybinds
   Input.reload_keybinds()
end
