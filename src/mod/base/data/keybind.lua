local Input = require("api.Input")
local Env = require("api.Env")

local function add_keybinds(raw)
   local kbs = {}
   for id, default in pairs(raw) do
      if type(default) == "table" then
         local rest = table.deepcopy(default)
         table.remove(rest, 1)
         kbs[#kbs+1] = { _id = id, default = default[1], default_alternate = rest }
      else
         kbs[#kbs+1] = { _id = id, default = default }
      end
   end
   data:add_multi("base.keybind", kbs)
end

local keybinds = {
   cancel = "shift",
   escape = "escape",
   quit = "escape",
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
   quick_menu = "z",
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
   alt_movement = "alt",
   portrait = "p",

   repl = "`",
   repl_page_up = {"pageup", "ctrl_u"},
   repl_page_down = {"pagedown", "ctrl_d"},
   repl_first_char = {"home", "ctrl_a"},
   repl_last_char = {"end", "ctrl_e"},
   repl_paste = "ctrl_v",
   repl_cut = "ctrl_x",
   repl_copy = "ctrl_c",
   repl_clear = "ctrl_l",
   repl_complete = "tab",
}

local dualshock = {
   north = {"joystick_14", "joystick_axis_2_-"},
   south = {"joystick_15", "joystick_axis_2_+"},
   west = {"joystick_16", "joystick_axis_1_-"},
   east = {"joystick_17", "joystick_axis_1_+"},
   enter = "joystick_2",
   quick_inv = "joystick_3",
   fire = "joystick_6",
   quick_menu = "joystick_4",
   escape = "joystick_1",
   quit = "joystick_10",
   get = "joystick_1",
   target = "joystick_5",
   previous_page = "joystick_5",
   next_page = "joystick_6",
   identify = "joystick_4",
}

for action, keys in pairs(dualshock) do
   if type(keys) == "string" then
      keys = {keys}
   end

   if type(keybinds[action]) == "string" then
      keybinds[action] = {keybinds[action]}
   end

   for _, key in ipairs(keys) do
      table.insert(keybinds[action], key)
   end
end

add_keybinds(keybinds)

if Env.is_hotloading() then
   Input.reload_keybinds()
end
