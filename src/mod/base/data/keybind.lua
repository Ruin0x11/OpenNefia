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
   quick_inv = "x",
   repl = "`"
}
