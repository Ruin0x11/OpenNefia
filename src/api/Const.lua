local Const = {}

--- Number of hours before killed citizens are respawned.
Const.CITIZEN_RESPAWN_HOURS = 48

Const.MAX_CHARAS_ALLY = 16
Const.MAX_CHARAS_ADVENTURER = 40
Const.MAX_CHARAS_SAVED = Const.MAX_CHARAS_ALLY + Const.MAX_CHARAS_ADVENTURER
Const.MAX_CHARAS = 245
Const.MAX_CHARAS_OTHER = Const.MAX_CHARAS - Const.MAX_CHARAS_SAVED

Const.KARMA_BAD = -30
Const.KARMA_GOOD = 20

Const.MAP_RENEW_MAJOR_HOURS = 120
Const.MAP_RENEW_MINOR_HOURS = 24

return Const