--
-- The key names in this file refer to raw LÖVE key names. The ones that are
-- commented out are transformed from the raw key name programmatically
-- depending on capitalization/etc.
--

return {
   keyboard = {
      --
      -- Character keys
      --

      -- ["a"] = "a",
      -- ["b"] = "b",
      -- ["c"] = "c",
      -- ["d"] = "d",
      -- ["e"] = "e",
      -- ["f"] = "f",
      -- ["g"] = "g",
      -- ["h"] = "h",
      -- ["i"] = "i",
      -- ["j"] = "j",
      -- ["k"] = "k",
      -- ["l"] = "l",
      -- ["m"] = "m",
      -- ["n"] = "n",
      -- ["o"] = "o",
      -- ["p"] = "p",
      -- ["q"] = "q",
      -- ["r"] = "r",
      -- ["s"] = "s",
      -- ["t"] = "t",
      -- ["u"] = "u",
      -- ["v"] = "v",
      -- ["w"] = "w",
      -- ["x"] = "x",
      -- ["y"] = "y",
      -- ["z"] = "z",
      -- ["0"] = "0",
      -- ["1"] = "1",
      -- ["2"] = "2",
      -- ["3"] = "3",
      -- ["4"] = "4",
      -- ["5"] = "5",
      -- ["6"] = "6",
      -- ["7"] = "7",
      -- ["8"] = "8",
      -- ["9"] = "9",
      ["space"] = "Space",
      -- ["!"] = "!",
      -- ['"'] = '"',
      -- ["#"] = "#",
      -- ["$"] = "$",
      -- ["&"] = "&",
      -- ["'"] = "'",
      -- ["("] = "(",
      -- [")"] = ")",
      -- ["*"] = "*",
      -- ["+"] = "+",
      -- [","] = ",",
      -- ["-"] = "-",
      -- ["."] = ".",
      -- ["/"] = "/",
      -- [":"] = ":",
      -- [";"] = ";",
      -- ["<"] = "<",
      -- ["="] = "=",
      -- [">"] = ">",
      -- ["?"] = "?",
      -- ["@"] = "@",
      -- ["["] = "[",
      -- ["\\"] = "\\",
      -- ["]"] = "]",
      -- ["^"] = "^",
      -- ["_"] = "_",
      -- ["`"] = "`",

      --
      -- Numpad keys
      --

      keypad = "Numpad",
      -- ["kp0"] = "kp0",
      -- ["kp1"] = "kp1",
      -- ["kp2"] = "kp2",
      -- ["kp3"] = "kp3",
      -- ["kp4"] = "kp4",
      -- ["kp5"] = "kp5",
      -- ["kp6"] = "kp6",
      -- ["kp7"] = "kp7",
      -- ["kp8"] = "kp8",
      -- ["kp9"] = "kp9",
      -- ["kp."] = "kp.",
      -- ["kp,"] = "kp,",
      -- ["kp/"] = "kp/",
      -- ["kp*"] = "kp*",
      -- ["kp-"] = "kp-",
      -- ["kp+"] = "kp+",
      -- ["kpenter"] = "kpenter",
      -- ["kp="] = "kp=",

      --
      -- Navigation keys
      --

      ["up"] = "Up",
      ["down"] = "Down",
      ["right"] = "Right",
      ["left"] = "Left",
      ["home"] = "Home",
      ["end"] = "End",
      ["pageup"] = "Page Up",
      ["pagedown"] = "Page Down",

      --
      -- Editing keys
      --

      ["insert"] = "Insert",
      ["backspace"] = "Backspace",
      ["tab"] = "Tab",
      ["clear"] = "Clear",
      ["return"] = "決定",
      ["delete"] = "Delete",

      --
      -- Function keys
      --

      -- ["f1"] = "f1",
      -- ["f2"] = "f2",
      -- ["f3"] = "f3",
      -- ["f4"] = "f4",
      -- ["f5"] = "f5",
      -- ["f6"] = "f6",
      -- ["f7"] = "f7",
      -- ["f8"] = "f8",
      -- ["f9"] = "f9",
      -- ["f10"] = "f10",
      -- ["f11"] = "f11",
      -- ["f12"] = "f12",
      -- ["f13"] = "f13",
      -- ["f14"] = "f14",
      -- ["f15"] = "f15",
      -- ["f16"] = "f16",
      -- ["f17"] = "f17",
      -- ["f18"] = "f18",

      --
      -- Modifier keys
      --

      ["numlock"] = "NumLock",
      ["capslock"] = "CapsLock",
      ["scrolllock"] = "ScrollLock",

      -- "lshift" and "rshift" are treated equally.
      ctrl = "Ctrl",
      shift = "Shift",
      alt = "Alt",
      gui = "Gui",

      ["mode"] = "Mode",

      --
      -- Application keys
      --

      ["www"] = "WWW",
      ["mail"] = "Mail",
      ["calculator"] = "Calculator",
      ["computer"] = "Computer",
      ["appsearch"] = "AppSearch",
      ["apphome"] = "AppHome",
      ["appback"] = "AppBack",
      ["appforward"] = "AppForward",
      ["apprefresh"] = "AppRefresh",
      ["appbookmarks"] = "AppBookmarks",

      --
      -- Miscellaneous keys
      --

      ["pause"] = "Pause",
      ["escape"] = "Esc",
      ["help"] = "Help",
      ["printscreen"] = "PrintScreen",
      ["sysreq"] = "SysReq",
      ["menu"] = "Menu",
      ["application"] = "Application",
      ["power"] = "Power",
      ["currencyunit"] = "CurrencyUnit",
      ["undo"] = "Undo",

      --
      -- Joystick
      --

      joypad = "Joypad",
      axis = "Axis"
   }
}
