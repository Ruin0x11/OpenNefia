data:add {
   _type = "elona_sys.dialog",
   _id = "larnneire",

   root = "talk.unique.larnneire",
   nodes = {
      __start = {
         text = {
            {"talk.unique.larnneire.dialog"}
         },
         choices = {
            {"mission", "talk.unique.larnneire.choices.mission"},
            {"north_tyris", "talk.unique.larnneire.choices.north_tyris"},
            {"fairy_tale", "talk.unique.larnneire.choices.fairy_tale"},
            {"__END__", "ui.bye"}
         }
      },
      fairy_tale = {
         text = {
            {"talk.unique.larnneire.fairy_tale._0"},
            {"talk.unique.larnneire.fairy_tale._1"},
            {"talk.unique.larnneire.fairy_tale._2"},
            {"talk.unique.larnneire.fairy_tale._3"},
            {"talk.unique.larnneire.fairy_tale._4"},
            {"talk.unique.larnneire.fairy_tale._5"},
         },
         choices = {{"__start", "ui.more"}}
      },
      north_tyris = {
         text = {
            {"talk.unique.larnneire.north_tyris._0"},
            {"talk.unique.larnneire.north_tyris._1"},
         },
         choices = {{"__start", "ui.more"}}
      },
      mission = {
         text = {
            {"talk.unique.larnneire.mission"},
         },
         choices = {{"__start", "ui.more"}}
      }
   }
}
