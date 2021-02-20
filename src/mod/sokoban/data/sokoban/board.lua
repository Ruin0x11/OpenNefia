data:add_type {
   name = "board",
   fields = {
      {
         name = "layout",
         type = "string",
         default = "",
         template = true
      }
   }
}

require("mod.sokoban.data.sokoban.board.builtin")
