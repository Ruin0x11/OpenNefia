(require* "api.InstancedMap"
          "api.Rand"
          "api.Pos"
          "api.Log"
          "api.Event"
          "api.Chara"
          "api.Item"
          "api.Map"
          "api.Gui"
          "api.Env"
          "mod.elona_sys.api.Anim"
          "mod.elona_sys.api.Magic"
          "mod.tools.api.Tools")

(local magic "elona.lightning_breath")

(fn cast [me]
  (let [enemy (Tools.enemy)]
    (if enemy
        (Magic.cast magic {:source me :target enemy})
        (Magic.cast magic {:source me :x 10 :y 10}))
    "turn_end"))

(fn spawn [me]
  (Chara.create "test_room.breather")
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
    (tset chara :dir 4)))

;;
;; scratch
;;

(fn scratch [player map]
  (each [_ entry (: (. data "elona_sys.magic") :iter)]
    (player:gain_magic entry._id 100))
  (Chara.create "test_room.breather" 10 5 {} map)
  (each [_ x y (map:iter_tiles)]
    (when (and (= (% x 2) 0) (= (% y 2) 0) (map:can_access x y))
      (each [_ id (ipairs ["elona.guava" "elona.scroll_of_return" "elona.safe"])]
        (Item.create id x y {} map))
      (when (Rand.one_in 3)
        (Item.create "elona.putitoro" x y {} map))))
  (set-pcc player))

(fn test-room [self player]
  (let [width 20
        height 20
        map (InstancedMap:new width height)]
    (map:clear "elona.cobble")
    (each [_ x y (Pos.iter_border 0 0 (- (map:width) 1) (- (map:height) 1))]
      (map:set_tile x y "elona.wall_dirt_dark_top"))

    (scratch player map)

    (each [_ x y (map:iter_tiles)]
      (map:memorize_tile x y))

    (Map.set_map map)
    (assert (: (Map.current) :take_object player (/ width 2) (/ height 2)))
    (Chara.set_player player)

    {:map map :start_x (/ width 2) :start_y (/ height 2)}))

(definst test-room base.scenario
  (on-game-start test-room))

;; 0. On instantiate, reify skills/magic/element from 'abilities' table
;; 1. Take all skills.
;; 2. Take all AI actions.
;; 3. Take all magic (in elona_sys).
;; 4. Exclude special actions.
;; 5. Run random action.

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
  (Log.info "Set test room scenario")
  (tset config "base.quickstart_scenario" "test_room.test_room"))
