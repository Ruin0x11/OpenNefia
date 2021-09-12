data:add_type {
   name = "ex_help",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      }
   }
}

local helps = {
   { elona_id = 1, _id = "first"          },
   { elona_id = 2, _id = "world_map"      },
   { elona_id = 3, _id = "town"           },
   { elona_id = 4, _id = "quest"          },
   { elona_id = 5, _id = "material_spot"  },
   { elona_id = 6, _id = "nefia"          },
   { elona_id = 7, _id = "innkeeper"      },
   { elona_id = 8, _id = "trainer"        },
   { elona_id = 9, _id = "sleep"          },
   { elona_id = 10, _id = "hunger"        },
   { elona_id = 11, _id = "bad_weather"   },
   { elona_id = 12, _id = "snow"          },
   { elona_id = 13, _id = "etherwind"     },
   { elona_id = 14, _id = "shelter"       },
   { elona_id = 15, _id = "ether_disease" },
   { elona_id = 16, _id = "salary"        },
   { elona_id = 17, _id = "moongate"      },
}

for _, help in ipairs(helps) do
   data:add {
      _type = "elona.ex_help",
      _id = help._id,
      elona_id = help.elona_id
   }
end
