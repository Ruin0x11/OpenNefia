return {
  quest = {
    journal = {
       common = {
          client = function(_1) return ("Client  : %s"):format(_1) end,
          complete = "Complete",
          deadline = function(_1) return ("Deadline: %s"):format(_1) end,
          detail = function(_1) return ("Detail  : %s"):format(_1) end,
          job = "Job",
          location = function(_1) return ("Location: %s"):format(_1) end,
          remaining = function(_1) return ("%s"):format(_1) end,
          report_to_the_client = "Report to the client.",
          reward = function(_1) return ("Reward  : %s"):format(_1) end
       },
      item = {
        fools_magic_stone = "Fool's magic stone",
        kings_magic_stone = "King's magic stone",
        letter_to_the_king = "A letter to the king",
        old_talisman = "An old talisman",
        sages_magic_stone = "Sage's magic stone"
      },
      main = {
        progress = {
          _0 = "I should check the dungeon called Lesimas. It's located south of Vernis.",
          _1 = "The injured scout asked me to deliver a letter to the king of Palmia. Palmia is located east of Vernis.",
          _2 = "Erystia will have some tasks for me if I want to work for Palmia. She's in the library of the castle.",
          _3 = "Erystia asked to look for an adventurer called Karam in the dungeon of Lesimas. He was on the 16th level of the dungeon the last time he sent a report. I may have to go deeper if I am to find him.",
          _4 = "I need to bring information Karam gave me to Erystia at once.",
          _5 = "I need to find 3 magic stones to break the seal of Lesimas. They can be found at the Tower of Fire, the crypt of the damned and the Ancient Castle",
          _6 = "With 3 magic stones I have, I need to get to the deepest level of Lesimas and break the seal. Then bring back an item called Hidden Artifact of Lesimas, whatever it is.",
          _7 = "You have completed the main quest."
        },
        title = "Main Quest"
      }
    }
  }
}
