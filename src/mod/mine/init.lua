local Sstp = require("mod.sstp.api.Sstp")
local Event = require("api.Event")

Event.register("base.on_chara_killed", "Notify when dead",
               function(chara, params)
                  if chara:is_player() then
                     local name = "???"
                     if params.source then
                        name = params.source.name
                     end
                     Sstp.send("You died at the hands of \"" .. name .. "\"...")
                  end
end)

data:add {
   _type = "elona_sys.dialog",
   _id = "main",

   root = "",
   nodes = {
      __start = {
         text = {
            {"dood"}
         },

         choices = {
            {"mine.sub:subnode", "Test subnode"},
            {"myself", "Test myself"},
            {"args", "Test args"},
            {"__END__", "__BYE__"},
         }
      },

      myself = {
         text = {
            {"Inside main node"}
         },

         choices = {
            {"__start", "back to main"}
         }
      },

      args = {
         text = {
            {"argument text"}
         },

         choices = function()
            local choices = {}
            for i in fun.range(4) do
               choices[#choices+1] = {"recv_args", "The arg " .. tostring(i), i, i + 4, "test"}
            end
            return choices
         end
      },

      recv_args = {
         text = function(t, ...)
            local buf = ""
            for _, v in ipairs({...}) do
               buf = buf .. tostring(v) .. "\n"
            end
            return buf
         end,

         choices = function(t, ...)
            local choices = {{"__BYE__", "__END__"}}
            for _, v in ipairs({...}) do
               choices[#choices+1] = {"mine.main:__start", "it's a good", v}
            end
            return choices
         end
      }
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "sub",

   root = "",
   nodes = {
      __start = function()
         return "subnode"
      end,

      subnode = {
         text = {
            {"inside the subnode"}
         },
         inherit = "mine.main"
      }
   }
}
