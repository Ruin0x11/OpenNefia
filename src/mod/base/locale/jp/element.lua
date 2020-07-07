return {
   element = {
      death = {
         elona = {
            fire = {
               active = "燃やし尽くした。",
               passive = function(_1)
                  return ("%sは燃え尽きて灰になった。")
                     :format(name(_1))
               end
            },
            cold = {
               active = "氷の塊に変えた。",
               passive = function(_1)
                  return ("%sは氷の彫像になった。")
                     :format(name(_1))
               end
            },
            lightning = {
               active = "焦げカスにした。",
               passive = function(_1)
                  return ("%sは雷に打たれ死んだ。")
                     :format(name(_1))
               end
            },
            darkness = {
               active = "闇に飲み込んだ。",
               passive = function(_1)
                  return ("%sは闇に蝕まれて死んだ。")
                     :format(name(_1))
               end
            },
            mind = {
               active = "再起不能にした。",
               passive = function(_1)
                  return ("%sは発狂して死んだ。")
                     :format(name(_1))
               end
            },
            poison = {
               active = "毒殺した。",
               passive = function(_1)
                  return ("%sは毒に蝕まれて死んだ。")
                     :format(name(_1))
               end
            },
            nether = {
               active = "冥界に墜とした。",
               passive = function(_1)
                  return ("%sは冥界に墜ちた。")
                     :format(name(_1))
               end
            },
            sound = {
               active = "聴覚を破壊し殺した。",
               passive = function(_1)
                  return ("%sは朦朧となって死んだ。")
                     :format(name(_1))
               end
            },
            nerve = {
               active = "神経を破壊した。",
               passive = function(_1)
                  return ("%sは神経を蝕まれて死んだ。")
                     :format(name(_1))
               end
            },
            chaos = {
               active = "混沌の渦に吸い込んだ。",
               passive = function(_1)
                  return ("%sは混沌の渦に吸収された。")
                     :format(name(_1))
               end
            },
            cut = {
               active = "千切りにした。",
               passive = function(_1)
                  return ("%sは千切りになった。")
                     :format(name(_1))
               end
            },
            acid = {
               active = "ドロドロに溶かした。",
               passive = function(_1)
                  return ("%sは酸に焼かれ溶けた。")
                     :format(name(_1))
               end
            },
            default = {
               active = "殺した。",
               passive = function(_1)
                  return ("%sは死んだ。")
                     :format(name(_1))
               end
            }
         }
      },
      damage = {
         elona = {
            fire = function(_1)
               return ("%sは燃え上がった。")
                  :format(name(_1))
            end,
            cold = function(_1)
               return ("%sは凍えた。")
                  :format(name(_1))
            end,
            lightning = function(_1)
               return ("%sに電流が走った。")
                  :format(name(_1))
            end,
            darkness = function(_1)
               return ("%sは闇の力で傷ついた。")
                  :format(name(_1))
            end,
            mind = function(_1)
               return ("%sは狂気に襲われた。")
                  :format(name(_1))
            end,
            poison = function(_1)
               return ("%sは吐き気を催した。")
                  :format(name(_1))
            end,
            nether = function(_1)
               return ("%sは冥界の冷気で傷ついた。")
                  :format(name(_1))
            end,
            sound = function(_1)
               return ("%sは轟音の衝撃を受けた。")
                  :format(name(_1))
            end,
            nerve = function(_1)
               return ("%sの神経は傷ついた。")
                  :format(name(_1))
            end,
            chaos = function(_1)
               return ("%sは混沌の渦で傷ついた。")
                  :format(name(_1))
            end,
            cut = function(_1)
               return ("%sは切り傷を負った。")
                  :format(name(_1))
            end,
            acid = function(_1)
               return ("%sは酸に焼かれた。")
                  :format(name(_1))
            end,
            default = "は傷ついた。"
         },
         name = {
            elona = {
               fire = "燃える",
               cold = "冷たい",
               lightning = "放電する",
               darkness = "暗黒の",
               mind = "霊的な",
               poison = "毒の",
               nether = "地獄の",
               sound = "震える",
               nerve = "痺れる",
               chaos = "混沌の",
               cut = "出血の",
               ether = "エーテルの",

               fearful = "恐ろしい",
               rotten = "腐った",
               silky = "柔らかい",
               starving = "飢えた"
            },
         },
         resist = {
            gain = {
               elona = {
                  fire = function(_1)
                     return ("%sの身体は急に火照りだした。")
                        :format(name(_1))
                  end,
                  cold = function(_1)
                     return ("%sの身体は急に冷たくなった。")
                        :format(name(_1))
                  end,
                  lightning = function(_1)
                     return ("%sの身体に電気が走った。")
                        :format(name(_1))
                  end,
                  darkness = function(_1)
                     return ("%sは急に暗闇が怖くなくなった。")
                        :format(name(_1))
                  end,
                  mind = function(_1)
                     return ("%sは急に明晰になった。")
                        :format(name(_1))
                  end,
                  poison = function(_1)
                     return ("%sの毒への耐性は強くなった。")
                        :format(name(_1))
                  end,
                  nether = function(_1)
                     return ("%sの魂は地獄に近づいた。")
                        :format(name(_1))
                  end,
                  sound = function(_1)
                     return ("%sは騒音を気にしなくなった。")
                        :format(name(_1))
                  end,
                  nerve = function(_1)
                     return ("%sは急に神経が図太くなった。")
                        :format(name(_1))
                  end,
                  chaos = function(_1)
                     return ("%sは騒音を気にしなくなった。")
                        :format(name(_1))
                  end,
                  magic = function(_1)
                     return ("%sの皮膚は魔力のオーラに包まれた。")
                        :format(name(_1))
                  end
               }
            },
            lose = {
               elona = {
                  fire = function(_1)
                     return ("%sは急に汗をかきだした。")
                        :format(name(_1))
                  end,
                  cold = function(_1)
                     return ("%sは急に寒気を感じた。")
                        :format(name(_1))
                  end,
                  lightning = function(_1)
                     return ("%sは急に電気に敏感になった。")
                        :format(name(_1))
                  end,
                  darkness = function(_1)
                     return ("%sは急に暗闇が怖くなった。")
                        :format(name(_1))
                  end,
                  mind = function(_1)
                     return ("%sは以前ほど明晰ではなくなった。")
                        :format(name(_1))
                  end,
                  poison = function(_1)
                     return ("%sの毒への耐性は薄れた。")
                        :format(name(_1))
                  end,
                  nether = function(_1)
                     return ("%sの魂は地獄から遠ざかった。")
                        :format(name(_1))
                  end,
                  sound = function(_1)
                     return ("%sは急に辺りをうるさく感じた。")
                        :format(name(_1))
                  end,
                  nerve = function(_1)
                     return ("%sの神経は急に萎縮した。")
                        :format(name(_1))
                  end,
                  chaos = function(_1)
                     return ("%sはカオスへの理解を失った。")
                        :format(name(_1))
                  end,
                  magic = function(_1)
                     return ("%sの皮膚から魔力のオーラが消えた。")
                        :format(name(_1))
                  end
               }
            }
         }
      }
   }
}
