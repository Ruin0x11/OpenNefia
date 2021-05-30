local editor = {
   { _id = "new", default = "ctrl_n" },
   { _id = "open", default = "ctrl_o" },
   { _id = "save", default = "ctrl_s" },
   { _id = "save_as", default = "ctrl_shift_s" },
   { _id = "rename", default = "ctrl_r" },
   { _id = "close", default = "ctrl_w" },
   { _id = "quit", default = "ctrl_q" },
}
for i = 1, 10 do
   editor[#editor+1] = {
      _id = ("switch_map_%d"):format(i),
      default = ("ctrl_%d"):format(i % 10)
   }
end
data:add_multi("base.keybind", editor)
