data:add_type {
   name = "board",
   fields = {
      {
         name = "layout",
         type = types.string,
         template = true
      }
   }
}

require("mod.sokoban.data.sokoban.board.builtin")
