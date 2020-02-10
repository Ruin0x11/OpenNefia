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

(Gui.bind_keys {:raw_m cast :raw_shift_s spawn})

(fn scratch [player map]
  (each [_ entry (: (. data "elona_sys.magic") :iter)]
    (player:gain_magic entry._id 100))
  (Chara.create "test_room.breather" 10 5 {} map)
  (each [_ x y (map:iter_tiles)]
    (when (and (= (% x 2) 0) (= (% y 2) 0) (map:can_access x y))
      (each [_ id (ipairs ["elona.guava" "elona.scroll_of_return" "elona.safe"])]
        (Item.create id x y {} map))
      (when (Rand.one_in 3)
        (Item.create "elona.putitoro" x y {} map)))))

(fn test-room [self player]
  (let [width 20
        height 20
        map (InstancedMap:new width height)]
    (map:clear "elona.cobble")
    (each [_ x y (Pos.iter_border 0 0 (- (map:width) 1) (- (map:height) 1))]
      (map:set_tile x y "elona.wall_dirt_dark_top"))

    (scratch player map)

    (Map.reveal_all map)

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
