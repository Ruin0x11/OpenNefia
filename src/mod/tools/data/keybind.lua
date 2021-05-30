data:add {
   _type = "base.keybind",
   _id = "m_x",
   default = "alt_x"
}

data:add {
   _type = "base.keybind",
   _id = "prefix_m_x",
   default = "ctrl_alt_x"
}

data:add {
   _type = "base.keybind",
   _id = "prompt_previous",
   default = "ctrl_p"
}

data:add {
   _type = "base.keybind",
   _id = "prompt_next",
   default = "ctrl_n"
}

data:add {
   _type = "base.keybind",
   _id = "toggle_fps",
   default = "ctrl_="
}

data:add {
   _type = "base.keybind",
   _id = "toggle_log",
   default = "ctrl_-"
}

data:add {
   _type = "base.keybind",
   _id = "show_debug_menu",
   default = "f12"
}

local editor = {
   { _id = "map_editor_new", default = "ctrl_n" },
   { _id = "map_editor_open", default = "ctrl_o" },
   { _id = "map_editor_save", default = "ctrl_s" },
   { _id = "map_editor_save_as", default = "ctrl_shift_s" },
   { _id = "map_editor_rename", default = "ctrl_r" },
   { _id = "map_editor_close", default = "ctrl_w" },
   { _id = "map_editor_quit", default = "ctrl_q" },
}
for i = 1, 9 do
   editor[#editor+1] = {
      _id = ("map_editor_switch_map_%d"):format(i),
      default = ("ctrl_%d"):format(i)
   }
end
data:add_multi("base.keybind", editor)
