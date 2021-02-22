return {
   enchantment = {
      it = function(desc)
         return ("It %s"):format(desc)
      end,
      item_ego = {
         major = {
            elona = {
               silence = function(_1) return ("%s of silence"):format(_1) end,
               res_blind = function(_1) return ("%s of resist blind"):format(_1) end,
               res_confuse = function(_1) return ("%s of resist confusion"):format(_1) end,
               fire = function(_1) return ("%s of fire"):format(_1) end,
               cold = function(_1) return ("%s of cold"):format(_1) end,
               lightning = function(_1) return ("%s of lightning"):format(_1) end,
               healer = function(_1) return ("%s of healing"):format(_1) end,
               res_paralyze = function(_1) return ("%s of resist paralysis"):format(_1) end,
               res_fear = function(_1) return ("%s of resist fear"):format(_1) end,
               res_sleep = function(_1) return ("%s of resist sleep"):format(_1) end,
               defender = function(_1) return ("%s of defender"):format(_1) end,
            }
         },
         minor = {
            elona = {
               singing = function(_1) return ("singing %s"):format(_1) end,
               servants = function(_1) return ("servant's %s"):format(_1) end,
               followers = function(_1) return ("follower's %s"):format(_1) end,
               howling = function(_1) return ("howling %s"):format(_1) end,
               glowing = function(_1) return ("glowing %s"):format(_1) end,
               conspicuous = function(_1) return ("conspicuous %s"):format(_1) end,
               magical = function(_1) return ("magical %s"):format(_1) end,
               enchanted = function(_1) return ("enchanted %s"):format(_1) end,
               mighty = function(_1) return ("mighty %s"):format(_1) end,
               trustworthy = function(_1) return ("trustworthy %s"):format(_1) end
            }
         }
      },
      level = "#",
      with_parameters = {
         ammo = {
            max = function(_1)
               return ("[Max %s]")
                  :format(_1)
            end,
            text = function(_1)
               return ("can be loaded with %s.")
                  :format(_1)
            end
         },
         attribute = {
            in_food = {
               decreases = function(_1)
                  return ("has which deteriorates your %s.")
                     :format(_1)
               end,
               increases = function(_1)
                  return ("has essential nutrients to enhance your %s.")
                     :format(_1)
               end
            },
            other = {
               decreases = function(_1, _2)
                  return ("decreases your %s by %s.")
                     :format(_1, _2)
               end,
               increases = function(_1, _2)
                  return ("increases your %s by %s.")
                     :format(_1, _2)
               end
            }
         },
         extra_damage = function(_1)
            return ("deals %s damage.")
               :format(_1)
         end,
         invokes = function(_1)
            return ("invokes %s.")
               :format(_1)
         end,
         resistance = {
            decreases = function(_1)
               return ("weakens your resistance to %s.")
                  :format(_1)
            end,
            increases = function(_1)
               return ("grants your resistance to %s.")
                  :format(_1)
            end
         },
         skill = {
            decreases = function(_1)
               return ("decreases your %s skill.")
                  :format(_1)
            end,
            increases = function(_1)
               return ("improves your %s skill.")
                  :format(_1)
            end
         },
         skill_maintenance = {
            in_food = function(_1)
               return ("can help you exercise your %s faster.")
                  :format(_1)
            end,
            other = function(_1)
               return ("maintains %s.")
                  :format(_1)
            end
         }
      }
   }
}
