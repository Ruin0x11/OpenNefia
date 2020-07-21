return {
   element = {
      death = {
         elona = {
            fire = {
               active = function(_1, _2)
                  return ("burn%s %s to death.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s burnt to ashes.")
                     :format(name(_1), is(_1))
               end
            },
            cold = {
               active = function(_1, _2)
                  return ("transform%s %s to an ice sculpture.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s frozen and turn%s into an ice sculpture.")
                     :format(name(_1), is(_1), s(_1))
               end
            },
            lightning = {
               active = function(_1, _2)
                  return ("electrocute%s %s to death.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s struck by lightning and die%s.")
                     :format(name(_1), is(_1), s(_1))
               end
            },
            darkness = {
               active = function(_1, _2)
                  return ("let%s the depths swallow %s.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s consumed by darkness.")
                     :format(name(_1), is(_1))
               end
            },
            mind = {
               active = function(_1, _2)
                  return ("completely disable%s %s.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s lose%s %s mind and commit%s a suicide.")
                     :format(name(_1), s(_1), his(_1), s(_1))
               end
            },
            poison = {
               active = function(_1, _2)
                  return ("kill%s %s with poison.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s poisoned to death.")
                     :format(name(_1), is(_1))
               end
            },
            nether = {
               active = function(_1, _2)
                  return ("entrap%s %s into the inferno.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s go%s to hell.")
                     :format(name(_1), s(_1, true))
               end
            },
            sound = {
               active = function(_1, _2)
                  return ("shatter%s %s to atoms.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s resonate%s and break up.")
                     :format(name(_1), s(_1))
               end
            },
            nerve = {
               active = function(_1, _2)
                  return ("destroy%s %s nerves.")
                     :format(s(_2), his(_1))
               end,
               passive = function(_1)
                  return ("%s die%s from neurofibroma.")
                     :format(name(_1), s(_1))
               end
            },
            chaos = {
               active = function(_1, _2)
                  return ("let%s the chaos consume %s.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s drawn into a chaotic vortex.")
                     :format(name(_1), is(_1))
               end
            },
            acid = {
               active = function(_1, _2)
                  return ("cut%s %s into thin strips.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s cut into thin strips.")
                     :format(name(_1), is(_1))
               end
            },
            acid = {
               active = function(_1, _2)
                  return ("melt%s %s away.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s melt%s.")
                     :format(name(_1), s(_1))
               end
            },
            default = {
               active = function(_1, _2)
                  return ("kill%s %s.")
                     :format(s(_2), him(_1))
               end,
               passive = function(_1)
                  return ("%s %s killed.")
                     :format(name(_1), is(_1))
               end
            }
         }
      },
      damage = {
         elona = {
            fire = function(_1)
               return ("%s %s burnt.")
                  :format(name(_1), is(_1))
            end,
            cold = function(_1)
               return ("%s %s frozen.")
                  :format(name(_1), is(_1))
            end,
            lightning = function(_1)
               return ("%s %s shocked.")
                  :format(name(_1), is(_1))
            end,
            darkness = function(_1)
               return ("%s %s struck by dark force.")
                  :format(name(_1), is(_1))
            end,
            mind = function(_1)
               return ("%s suffer%s a splitting headache.")
                  :format(name(_1), s(_1))
            end,
            poison = function(_1)
               return ("%s suffer%s from venom.")
                  :format(name(_1), s(_1))
            end,
            nether = function(_1)
               return ("%s %s chilled by infernal squall.")
                  :format(name(_1), is(_1))
            end,
            sound = function(_1)
               return ("%s %s shocked by a shrill sound.")
                  :format(name(_1), is(_1))
            end,
            nerve = function(_1)
               return ("%s%s nerves are hurt.")
                  :format(name(_1), his_owned(_1))
            end,
            chaos = function(_1)
               return ("%s %s hurt by chaotic force.")
                  :format(name(_1), is(_1))
            end,
            cut = function(_1)
               return ("%s get%s a cut.")
                  :format(name(_1), s(_1))
            end,
            acid = function(_1)
               return ("%s %s burnt by acid.")
                  :format(name(_1), is(_1))
            end,
            default = function(_1)
               return ("%s %s wounded.")
                  :format(name(_1), is(_1))
            end
         },
         name = {
            elona = {
               fire = "burning",
               cold = "icy",
               lightning = "electric",
               darkness = "gloomy",
               mind = "psychic",
               poison = "poisonous",
               nether = "infernal",
               sound = "shivering",
               nerve = "numb",
               chaos = "chaotic",
               cut = "cut",
               ether = "ether",

               fearful = "fearful",
               rotten = "rotten",
               silky = "silky",
               starving = "starving"
            },
         },
      },
      resist = {
         gain = {
            elona = {
               fire = function(_1)
                  return ("Suddenly, %s feel%s very hot.")
                     :format(name(_1), s(_1))
               end,
               cold = function(_1)
                  return ("Suddenly, %s feel%s very cool.")
                     :format(name(_1), s(_1))
               end,
               lightning = function(_1)
                  return ("%s %s struck by an electric shock.")
                     :format(name(_1), is(_1))
               end,
               darkness = function(_1)
                  return ("%s no longer fear%s darkness.")
                     :format(name(_1), s(_1))
               end,
               mind = function(_1)
                  return ("Suddenly, %s%s mind becomes very clear.")
                     :format(name(_1), his_owned(_1))
               end,
               poison = function(_1)
                  return ("%s now %s antibodies to poisons.")
                     :format(name(_1), have(_1))
               end,
               nether = function(_1)
                  return ("%s %s no longer afraid of hell.")
                     :format(name(_1), is(_1))
               end,
               sound = function(_1)
                  return ("%s%s eardrums get thick.")
                     :format(name(_1), his_owned(_1))
               end,
               nerve = function(_1)
                  return ("%s%s nerve is sharpened.")
                     :format(name(_1), his_owned(_1))
               end,
               chaos = function(_1)
                  return ("Suddenly, %s understand%s chaos.")
                     :format(name(_1), s(_1))
               end,
               magic = function(_1)
                  return ("%s%s body is covered by a magical aura.")
                     :format(name(_1), his_owned(_1))
               end
            }
         },
         lose = {
            elona = {
               fire = function(_1)
                  return ("%s sweat%s.")
                     :format(name(_1), s(_1))
               end,
               cold = function(_1)
                  return ("%s shiver%s.")
                     :format(name(_1), s(_1))
               end,
               lightning = function(_1)
                  return ("%s %s shocked.")
                     :format(name(_1), is(_1))
               end,
               darkness = function(_1)
                  return ("Suddenly, %s fear%s darkness.")
                     :format(name(_1), s(_1))
               end,
               mind = function(_1)
                  return ("%s%s mind becomes slippery.")
                     :format(name(_1), his_owned(_1))
               end,
               poison = function(_1)
                  return ("%s lose%s antibodies to poisons.")
                     :format(name(_1), s(_1))
               end,
               nether = function(_1)
                  return ("%s %s afraid of hell.")
                     :format(name(_1), is(_1))
               end,
               sound = function(_1)
                  return ("%s become%s very sensitive to noises.")
                     :format(name(_1), s(_1))
               end,
               nerve = function(_1)
                  return ("%s become%s dull.")
                     :format(name(_1), s(_1))
               end,
               chaos = function(_1)
                  return ("%s no longer understand%s chaos.")
                     :format(name(_1), s(_1))
               end,
               magic = function(_1)
                  return ("The magical aura disappears from %s%s body.")
                     :format(name(_1), his_owned(_1))
               end
            }
         }
      }
   }
}
