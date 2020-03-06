local Log = require ("api.Log")

Log.info("Hello from %s!", _MOD_NAME)

data:add {
    _type = "base.chara",
    _id = "my_chara",
    level = 1,
    faction = "base.enemy",
    race = "elona.slime",
    class = "elona.predator",
    image = "example_mod.programming_putit",
    color = { 175, 255, 175 },
    rarity = 0,
    coefficient = 0,
}

data:add {
  _type = "base.chip",
  _id = "programming_putit",

  --- The image to use for this chip.
  ---
  --- It can either be a string referencing an image file, or a table with these contents:
  --- - source: file containing a larger chip atlas to use.
  --- - x: x position of the chip on the atlas.
  --- - y: y position of the chip on the atlas.
  --- - width: width of one animation frame.
  --- - height: height of one animation frame.
  --- - count_x: animation frames in the x direction. This is multiplied by width for the total width.
  --- - count_y: animation frames in the y direction. This is multiplied by height for the total height.
  --- - key_color: if `source` is a BMP, controls the color to convert to transparency. Defaults to {0, 0, 0}.
  --- @type string|{source=string,x=int,y=int,width=int,height=int,count_x=int?,count_y=int?,key_color={int,int,int}?}
  image = "mod/example_mod/graphic/programming_putit.png",
  y_offset = 0
}