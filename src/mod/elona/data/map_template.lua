data:add {
   _type = "elona_sys.map_template",
   _id = "north_tyris",

   map = "ntyris",

   areas = {
      { map = "elona.vernis", x = 26, y = 23 },
      { map = "elona.yowyn", x = 43, y = 32 },
      { map = "elona.palmia", x = 53, y = 24 },
      { map = "elona.derphy", x = 14, y = 35 },
      { map = "elona.port_kapul", x = 3, y = 15 },
      { map = "elona.noyel", x = 89, y = 14 },
      { map = "elona.lumiest", x = 61, y = 32 },
      { map = "elona.your_home", x = 22, y = 21 },
      { map = "elona.show_house", x = 35, y = 27 },
      { map = "elona.lesimas", x = 23, y = 29 },
      { map = "elona.the_void", x = 81, y = 51 },
      { map = "elona.tower_of_fire", x = 43, y = 4 },
      { map = "elona.crypt_of_the_damned", x = 38, y = 20 },
      { map = "elona.ancient_castle", x = 26, y = 44 },
      { map = "elona.dragons_nest", x = 13, y = 32 },
      { map = "elona.mountain_pass", x = 64, y = 43 },
      { map = "elona.puppy_cave", x = 29, y = 24 },
      { map = "elona.minotaurs_nest", x = 43, y = 39 },
      { map = "elona.yeeks_nest", x = 38, y = 31 },
      { map = "elona.pyramid", x = 4, y = 11 },
      { map = "elona.lumiest_graveyard", x = 74, y = 31 },
      { map = "elona.truce_ground", x = 51, y = 9 },
      { map = "elona.jail", x = 28, y = 37 },
      { map = "elona.cyber_dome", x = 21, y = 27 },
      { map = "elona.larna", x = 64, y = 47 },
      { map = "elona.miral_and_garoks_workshop", x = 88, y = 25 },
      { map = "elona.mansion_of_younger_sister", x = 18, y = 2 },
      { map = "elona.embassy", x = 53, y = 21 },
      { map = "elona.north_tyris_south_border", x = 27, y = 52 },
      { map = "elona.fort_of_chaos_beast", x = 13, y = 43 },
      { map = "elona.fort_of_chaos_machine", x = 51, y = 32 },
      { map = "elona.fort_of_chaos_collapsed", x = 35, y = 10 },
      { map = "elona.test_site", x = 20, y = 20 },
   }
}

local dungeon = "dungeon1"

local temp = {
   vernis = "vernis",
   yowyn = "yowyn",
   palmia = "palmia",
   derphy = "derphy",
   port_kapul = "kapul",
   noyel = "noyel",
   lumiest = "lumiest",
   your_home = "home0",
   show_house = dungeon,
   lesimas = dungeon,
   the_void = dungeon,
   tower_of_fire = dungeon,
   crypt_of_the_damned = dungeon,
   ancient_castle = dungeon,
   dragons_nest = dungeon,
   mountain_pass = dungeon,
   puppy_cave = dungeon,
   minotaurs_nest = dungeon,
   yeeks_nest = dungeon,
   pyramid = "sqPyramid",
   lumiest_graveyard = "grave_1",
   truce_ground = "truce_ground",
   jail = "jail1",
   cyber_dome = "cyberdome",
   larna = "highmountain",
   miral_and_garoks_workshop = "smith0",
   mansion_of_younger_sister = "sister",
   embassy = "office_1",
   north_tyris_south_border = "station-nt1",
   fort_of_chaos_beast = "god",
   fort_of_chaos_machine = "god",
   fort_of_chaos_collapsed = "god",
   test_site = dungeon,
}

for k, v in pairs(temp) do
   data:add {
      _type = "elona_sys.map_template",
      _id = k,

      map = v
   }
end
