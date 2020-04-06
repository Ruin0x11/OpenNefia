(require* "api.InstancedMap"
          "api.Rand"
          "api.Pos"
          "api.Log"
          "api.Event"
          "api.Chara"
          "api.Item"
          "api.Feat"
          "api.Map"
          "api.Gui"
          "api.Env"
          "mod.elona_sys.api.Anim"
          "mod.elona_sys.api.Magic"
          "mod.tools.api.Tools"
          "mod.elona.api.Text")

(local magic "elona.lightning_breath")

(fn cast [me]
  (let [enemy (Tools.enemy)]
    (if enemy
        (Magic.cast magic {:source me :target enemy})
        (Magic.cast magic {:source me :x 10 :y 10}))
    "turn_end"))

(fn spawn [me]
  (me:start_activity "elona.digging_material" {:type "rubble"})
  "player_turn_query")

(fn anim [me]
  (let [anim (Anim.melee_attack 10 10 false 0 50 false)]
    (Gui.start_draw_callback anim)))

(Gui.bind_keys {:raw_m cast :raw_shift_s spawn :raw_shift_a anim})

(fn set-pcc [chara]
  (let [Pcc (require "api.gui.Pcc")]
    (tset chara :pcc
          (Pcc:new [{:id "elona.body_1" :z_order 0}
                    {:id "elona.eye_7" :z_order 10}
                    {:id "elona.hair_2" :z_order 20}
                    {:id "elona.cloth_1" :z_order 30}
                    {:id "elona.pants_1" :z_order 20}]))
    (tset chara :dir 4))
    (tset chara :portrait "elona.man1")
    (tset chara :title (Text.random_title)))

;;
;; scratch
;;

(fn scratch [player map]
  (each [_ entry (: (. data "elona_sys.magic") :iter)]
    (player:gain_magic entry._id 100))
  ;(Chara.create "test_room.breather" 10 5 {} map)
  (set-pcc player)
  ;(Feat.create "elona.pot" 10 7 {} map)

  (let [item (Item.create "elona.long_bow" nil nil {} player)]
    (player:equip_item item))
  (let [item (Item.create "elona.arrow" nil nil {} player)]
    (player:equip_item item)))

(fn test-room [self player]
  (let [width 20
        height 20
        map (InstancedMap:new width height)]
    (map:clear "elona.cobble")
    (tset map :is_indoor true)
    (each [_ x y (Pos.iter_border 0 0 (- (map:width) 1) (- (map:height) 1))]
      (map:set_tile x y "elona.wall_dirt_dark_top"))

    (scratch player map)

    (each [_ x y (map:iter_tiles)]
      (map:memorize_tile x y))

    (Map.set_map map)
    (assert (: (Map.current) :take_object player (/ width 2) (/ height 2)))))

(definst test-room base.scenario
  (on-game-start test-room))

(definst breather base.chara
  (class "elona.predator")
  (race "elona.slime")
  (faction "base.enemy")
  (color [100 255 100])
  (level 40)
  (ai-act-sub-freq 100)
  (abilities
   (base.skill
    (elona.stat-life 100))
   (base.magic
    (elona.fire-breath 20))
   (base.element
    (elona.fire 200)))
  (special-abilities ["elona.fire-breath"]))

(defhandler "base.on_startup" "Set quickstart scenario"
  []
  (tset config "base.quickstart_scenario" "test_room.test_room"))